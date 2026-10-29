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
// Each app that turns this on (MyUserProvider's socialLoginScheme) needs:
//  - Android: flutter_web_auth_2's CallbackActivity in AndroidManifest.xml
//    for its scheme.
//  - Web: web/auth.html, flutter_web_auth_2's postMessage page.
//  - Its callback allowed in the server's settings.APP_LOGIN_CALLBACKS.
import 'dart:convert';
import 'dart:math';
import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_web_auth_2/flutter_web_auth_2.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'RPC.dart';

class SocialProvider {
  final String id;
  final String name;
  final String? clientId; // the server's OAuth client, which native SDKs ask for tokens for
  final List<String> flows; // "redirect", and "token" where a native SDK could log in instead

  SocialProvider.fromJson(Map m)
      : id = m["id"],
        name = m["name"],
        clientId = m["client_id"],
        flows = List<String>.from(m["flows"] ?? []);
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
        if (e.code == GoogleSignInExceptionCode.canceled) {
          throw SocialLoginCancelled();
        }
        print("Google account picker failed, using the browser: $e");
        return await _redirectLogin(provider.id);
      }
      return await RPC().rpc("rest", "User", "login_with_token", {"provider": provider.id, "token": {"id_token": idToken}},
          "Logging In", retryLogin: false, forceLogin: false);
    }
    return await _redirectLogin(provider.id);
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
    try {
      result = await FlutterWebAuth2.authenticate(url: url.toString(), callbackUrlScheme: scheme);
    } on PlatformException catch (e) {
      if (e.code == "CANCELED") {
        throw SocialLoginCancelled();
      }
      rethrow;
    }

    final params = Uri.parse(result).queryParameters;
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
