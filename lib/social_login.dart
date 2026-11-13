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

  const SocialButtonColors({required this.bg, required this.fg, required this.border});

  SocialButtonColors.fromJson(Map m)
      : bg = _color(m["bg"]),
        fg = _color(m["fg"]),
        border = _color(m["border"]);

  static Color _color(String hex) => Color(0xFF000000 | int.parse(hex.substring(1), radix: 16));
}

/// A provider's login button. All are the same size and shape, with the logo
/// at the same inset from the left and the label centered (the left-aligned
/// layout both Google and Apple offer), and none takes anything from the
/// app's button themes, so no race theme can resize or recolor them.
///
/// Google's follows its branding guidelines: its light theme (the server's
/// colors) on light and dark backgrounds alike, matching the white Apple
/// button in visual weight, as Google asks; the full-color G and Google Sans
/// Medium 14/20, all scaled by height / 40 (Google's button is 40 tall and
/// may be scaled as a whole), with its iOS or Android padding.
///
/// Apple's follows its Human Interface Guidelines for a custom button: white
/// with a black outline on light backgrounds, plain white on dark, the logo
/// and title in black, the title in the system font at 43% of the height,
/// and the logo (the sign_in_with_apple package's painter) the title's
/// height, as the package's own button draws it.
///
/// Any other provider (RunSignup) gets Google's light colors and type, so the
/// set matches.
class SocialLoginButton extends StatelessWidget {
  final SocialProvider provider;
  final VoidCallback onPressed;
  static const double height = 44;
  static const radius = BorderRadius.all(Radius.circular(4));
  static const double _scale = height / 40; // Google's button is 40 tall
  static const double logoSize = 20 * _scale; // the logo's frame; Google's G is 18 in it

  const SocialLoginButton({Key? key, required this.provider, required this.onPressed}) : super(key: key);

  static bool get _ios => !kIsWeb && (defaultTargetPlatform == TargetPlatform.iOS || defaultTargetPlatform == TargetPlatform.macOS);

  // Google's padding before the logo and between it and the label
  static double get _inset => (_ios ? 16 : 12) * _scale;
  static double get _gap => (_ios ? 12 : 10) * _scale;

  static const _googleLight = SocialButtonColors(bg: Color(0xFFFFFFFF), fg: Color(0xFF1F1F1F), border: Color(0xFF747775));

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final button = provider.button;
    final label = button?.label ?? "Continue with ${provider.name}";
    if (provider.id == "apple") {
      const fontSize = height * 0.43;
      return _button(context, label,
          bg: Colors.white,
          fg: Colors.black,
          border: dark ? null : Colors.black,
          style: TextStyle(
              fontSize: fontSize,
              fontWeight: FontWeight.w500,
              letterSpacing: -0.41,
              // the system font, named, or the race theme's would be inherited
              fontFamily: _ios ? "CupertinoSystemText" : "Roboto"),
          logo: Padding(
            padding: const EdgeInsets.only(bottom: 4 / 44 * height),
            child: SizedBox(
              width: fontSize * (25 / 31),
              height: fontSize,
              child: CustomPaint(painter: AppleLogoPainter(color: Colors.black)),
            ),
          ));
    }
    // Google's light theme on dark backgrounds too, for the visual weight of
    // Apple's button beside it, which can only be white there.
    final colors = button?.light ?? _googleLight;
    return _button(context, label,
        bg: colors.bg,
        fg: colors.fg,
        border: colors.border,
        style: const TextStyle(fontSize: 14 * _scale, height: 20 / 14, fontWeight: FontWeight.w500, fontFamily: "GoogleSans", package: "db"),
        logo: button?.logo == null
            ? null
            : SvgPicture.string(button!.logo!, width: 18 * _scale, height: 18 * _scale,
                theme: SvgTheme(currentColor: colors.fg)));
  }

  Widget _button(BuildContext context, String label,
      {required Color bg, required Color fg, Color? border, Widget? logo, required TextStyle style}) {
    // Room for the logo on both sides keeps the label centered on the button.
    final side = _inset + logoSize + _gap;
    return SizedBox(
      height: height,
      child: Material(
        color: bg,
        shape: RoundedRectangleBorder(
            borderRadius: radius, side: border == null ? BorderSide.none : BorderSide(color: border)),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onPressed,
          child: Stack(alignment: Alignment.center, children: [
            if (logo != null)
              Positioned(left: _inset, width: logoSize, top: 0, bottom: 0, child: Center(child: logo)),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: side),
              child: Text(label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                  textScaler: TextScaler.noScaling,
                  style: style.copyWith(color: fg)),
            ),
          ]),
        ),
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
