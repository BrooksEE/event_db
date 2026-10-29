// Social login (Google, and whatever else the server's allauth has configured)
// through the system browser. The server side is brooksee3port's
// accounts/app_login.py: auth/app/start/<provider> runs the provider's web
// login and sends the browser back to the app's callback with a short-lived
// code, which rest/User/redeem_login_code trades for the app's session.
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
import 'RPC.dart';

class SocialProvider {
  final String id;
  final String name;
  final List<String> flows; // "redirect", and "token" where a native SDK could log in instead

  SocialProvider.fromJson(Map m)
      : id = m["id"],
        name = m["name"],
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

  /// Logs the app's session in with providerId. Returns the user, as
  /// rest/User/login does. Throws SocialLoginCancelled if the user backs out.
  Future<Map> login(String providerId) async {
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
