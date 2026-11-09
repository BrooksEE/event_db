// Social login (Google, and whatever else the server's allauth has configured)
// through the system browser. The server side is brooksee3port's
// accounts/app_login.py: auth/app/start/<provider> runs the provider's web
// login and sends the browser back to the app's callback with a short-lived
// code, which rest/User/redeem_login_code trades for the app's session.
//
// On Android, Google logs in with the phone's own account picker instead
// (Credential Manager, through google_sign_in) and rest/User/login_with_token
// checks its ID token. That needs an Android OAuth client for the app's
// package and signing key in the same Google Cloud project as the server's
// web client; until there is one, the picker fails and the browser is used.
//
// On iOS, Apple logs in with Apple's own sheet (sign_in_with_apple) and
// rest/User/login_with_token checks its ID token, which is issued to the app's
// bundle ID: the server's APPLE_CLIENT_ID must list it, and the app needs the
// "Sign In with Apple" capability (com.apple.developer.applesignin in
// Runner.entitlements). An iOS app whose bundle ID the server doesn't list
// (social_providers' client_id for apple) uses the browser instead, so a new
// white-label app works before it's added there. Android, macOS and web log
// in with Apple through the browser, as any other provider.
//
// Each app that turns this on (MyUserProvider's socialLoginScheme) needs:
//  - Android: flutter_web_auth_2's CallbackActivity in AndroidManifest.xml
//    for its scheme.
//  - Web: nothing for the login itself, which opens its own tab and gets the
//    result posted back from the server (web_login_popup_web.dart); keep
//    web/auth.html for the server's fallback when the tab lost its opener.
//  - Its callback allowed in the server's settings.APP_LOGIN_CALLBACKS.
import 'dart:convert';
import 'dart:math';
import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_web_auth_2/flutter_web_auth_2.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'RPC.dart';
import 'web_login_popup.dart';

class SocialProvider {
  final String id;
  final String name;
  final String? clientId; // the server's OAuth client, which native SDKs ask for tokens for
  final List<String> flows; // "redirect", and "token" where a native SDK could log in instead

  final SocialButton? button; // its look, from the server (accounts.app_login.button)

  SocialProvider.fromJson(Map m)
      : id = m["id"],
        name = m["name"],
        clientId = m["client_id"],
        flows = List<String>.from(m["flows"] ?? []),
        button = m["button"] == null ? null : SocialButton.fromJson(m["button"]);
}

/// A provider's login button after its branding guidelines, as the server's
/// login page draws it: a label, an SVG logo (its currentColor is fg), and
/// colors for light and dark backgrounds. A provider the server hasn't
/// branded has no logo or colors.
class SocialButton {
  final String? label;
  final String? logo;
  final SocialButtonColors? light;
  final SocialButtonColors? dark;

  SocialButton.fromJson(Map m)
      : label = m["label"],
        logo = m["logo"],
        light = m["light"] == null ? null : SocialButtonColors.fromJson(m["light"]),
        dark = m["dark"] == null ? null : SocialButtonColors.fromJson(m["dark"]);
}

class SocialButtonColors {
  final Color bg, fg, border;

  SocialButtonColors.fromJson(Map m)
      : bg = _color(m["bg"]),
        fg = _color(m["fg"]),
        border = _color(m["border"]);

  static Color _color(String hex) => Color(0xFF000000 | int.parse(hex.substring(1), radix: 16));
}

/// A provider's login button, as the server's login page draws it. Apple's is
/// the sign_in_with_apple package's own, which App Review looks for, in the
/// same size and shape as the others.
class SocialLoginButton extends StatelessWidget {
  final SocialProvider provider;
  final VoidCallback onPressed;
  static const double height = 44;
  static const radius = BorderRadius.all(Radius.circular(4));

  const SocialLoginButton({Key? key, required this.provider, required this.onPressed}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final button = provider.button;
    final label = button?.label ?? "Continue with ${provider.name}";
    if (provider.id == "apple") {
      return SignInWithAppleButton(
        onPressed: onPressed,
        text: label,
        height: height,
        borderRadius: radius,
        style: dark ? SignInWithAppleButtonStyle.white : SignInWithAppleButtonStyle.whiteOutlined,
      );
    }
    final colors = dark ? button?.dark : button?.light;
    return SizedBox(
      height: height,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          backgroundColor: colors?.bg,
          foregroundColor: colors?.fg,
          side: colors == null ? null : BorderSide(color: colors.border),
          shape: const RoundedRectangleBorder(borderRadius: radius),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        ),
        child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          if (button?.logo != null) ...[
            SvgPicture.string(button!.logo!, width: 20, height: 20,
                theme: SvgTheme(currentColor: colors?.fg ?? Theme.of(context).colorScheme.primary)),
            const SizedBox(width: 10),
          ],
          Flexible(child: Text(label, overflow: TextOverflow.ellipsis)),
        ]),
      ),
    );
  }
}

class SocialLoginCancelled implements Exception {}

class SocialLogin {
  /// The app's custom URL scheme, e.g. "com.laurelt.timer".
  final String scheme;
  SocialLogin(this.scheme);

  /// Windows and Linux would log in in an embedded webview, which Google refuses.
  static bool get supported =>
      kIsWeb ||
      defaultTargetPlatform == TargetPlatform.android ||
      defaultTargetPlatform == TargetPlatform.iOS ||
      defaultTargetPlatform == TargetPlatform.macOS;

  Future<List<SocialProvider>> providers() async {
    if (!supported) {
      return [];
    }
    final list = await RPC().rpcAny("rest", "User", "social_providers", {}, null, retryLogin: false, forceLogin: false) as List;
    return list.map((m) => SocialProvider.fromJson(m)).toList();
  }

  /// Logs the app's session in with provider. Returns the user, as
  /// rest/User/login does. Throws SocialLoginCancelled if the user backs out.
  Future<Map> login(SocialProvider provider) async {
    if (!kIsWeb &&
        defaultTargetPlatform == TargetPlatform.android &&
        provider.id == "google" &&
        provider.flows.contains("token") &&
        provider.clientId != null) {
      final String? idToken;
      try {
        idToken = await _googleIdToken(provider.clientId!);
      } on GoogleSignInException catch (e) {
        print("Google account picker: code=${e.code} description=${e.description} details=${e.details}");
        // An app whose package and signing key have no Android OAuth client
        // (a debug or sideloaded build, or a race left without one) still gets
        // the account picker, then fails with "[16] Account reauth failed.",
        // which google_sign_in reports as canceled: that one isn't the user.
        final reauthFailed = (e.description ?? "").contains("reauth failed");
        if (e.code == GoogleSignInExceptionCode.canceled && !reauthFailed) {
          throw SocialLoginCancelled();
        }
        print("Google account picker failed, using the browser: $e");
        return await _redirectLogin(provider.id);
      }
      return await RPC().rpc("rest", "User", "login_with_token", {"provider": provider.id, "token": {"id_token": idToken}},
          "Logging In", retryLogin: false, forceLogin: false);
    }
    if (!kIsWeb &&
        defaultTargetPlatform == TargetPlatform.iOS &&
        provider.id == "apple" &&
        provider.flows.contains("token") &&
        await _serverAcceptsThisApp(provider)) {
      return await _appleLogin(provider);
    }
    return await _redirectLogin(provider.id);
  }

  /// Whether provider's client_id (for Apple, the server's APPLE_CLIENT_ID:
  /// the Services ID, then every bundle ID it takes native tokens from) lists
  /// this app's bundle ID. An app not on it logs in through the browser, which
  /// uses the Services ID, instead of with a token the server would reject.
  Future<bool> _serverAcceptsThisApp(SocialProvider provider) async {
    final bundleId = (await PackageInfo.fromPlatform()).packageName;
    final accepted = (provider.clientId ?? "").split(",").map((s) => s.trim());
    if (!accepted.contains(bundleId)) {
      print("$bundleId isn't in the server's APPLE_CLIENT_ID, using the browser for Apple");
      return false;
    }
    return true;
  }

  Future<Map> _appleLogin(SocialProvider provider) async {
    final AuthorizationCredentialAppleID credential;
    try {
      credential = await SignInWithApple.getAppleIDCredential(
          scopes: [AppleIDAuthorizationScopes.email, AppleIDAuthorizationScopes.fullName]);
    } on SignInWithAppleAuthorizationException catch (e) {
      if (e.code == AuthorizationErrorCode.canceled) {
        throw SocialLoginCancelled();
      }
      rethrow;
    }
    // Apple gives the name only on the user's first login, and not in the ID
    // token: the server uses it to name the user it makes.
    return await RPC().rpc("rest", "User", "login_with_token", {
          "provider": provider.id,
          "token": {
            "id_token": credential.identityToken,
            "name": {"firstName": credential.givenName, "lastName": credential.familyName},
          }
        }, "Logging In", retryLogin: false, forceLogin: false);
  }

  static bool _googleInitialized = false;

  Future<String?> _googleIdToken(String serverClientId) async {
    if (!_googleInitialized) {
      await GoogleSignIn.instance.initialize(serverClientId: serverClientId);
      _googleInitialized = true;
    }
    final account = await GoogleSignIn.instance.authenticate();
    return account.authentication.idToken;
  }

  Future<Map> _redirectLogin(String providerId) async {
    final random = Random.secure();
    final verifier = base64Url.encode(List<int>.generate(32, (_) => random.nextInt(256))).replaceAll("=", "");
    final challenge = base64Url.encode(sha256.convert(utf8.encode(verifier)).bytes).replaceAll("=", "");
    final callback = kIsWeb ? "${Uri.base.origin}/auth.html" : "$scheme://auth";
    final url = Uri.parse(RPC().server).replace(
        path: "/auth/app/start/$providerId",
        queryParameters: {"callback": callback, "challenge": challenge});

    final String result;
    if (kIsWeb) {
      // Its own tab and a message back from the server's last page, never a
      // visit to auth.html: an installed app's App Link for this host would
      // take that out of the browser (web_login_popup_web.dart).
      final posted = await webLoginPopup(url.toString(), Uri.parse(RPC().server).origin, const Duration(minutes: 5));
      if (posted == null) {
        throw SocialLoginCancelled();
      }
      result = posted;
    } else try {
      result = await FlutterWebAuth2.authenticate(url: url.toString(), callbackUrlScheme: scheme);
    } on PlatformException catch (e) {
      print("Browser login ended: code=${e.code} message=${e.message} details=${e.details}");
      if (e.code == "CANCELED") {
        throw SocialLoginCancelled();
      }
      rethrow;
    }

    final params = Uri.parse(result).queryParameters;
    print("Browser login returned: ${params.keys.toList()} error=${params["error"]}");
    if (params["error"] == "cancelled") {
      throw SocialLoginCancelled();
    }
    if (params["code"] == null) {
      throw Exception(params["message"] ?? "Login failed. Please try again.");
    }
    return await RPC().rpc("rest", "User", "redeem_login_code", {"code": params["code"], "verifier": verifier}, "Logging In",
        retryLogin: false, forceLogin: false);
  }
}
