// The web build's social login: opens the server's login in a new tab and
// waits for the server's last page (accounts/app_login.py's finish) to post
// the result back: {"app-login": "<callback>?code=..."} or "...?error=...".
//
// The tab is opened without noopener (unlike url_launcher, and so
// flutter_web_auth_2), because that page needs window.opener to post to. The
// result then never visits the callback's URL, which an installed app's App
// Link or universal link for the same host would take out of the browser.
import 'dart:async';
import 'dart:js_interop';
import 'dart:js_interop_unsafe';

@JS('window.open')
external JSObject? _open(String url, String target);

@JS('window.addEventListener')
external void _addEventListener(String type, JSFunction listener);

@JS('window.removeEventListener')
external void _removeEventListener(String type, JSFunction listener);

/// Opens url in a new tab right away (call it straight from the tap, before
/// any await, or a popup blocker may stop it) and completes with the callback
/// URL the server's page posts from serverOrigin, or null if nothing comes
/// within timeout (the tab was closed or abandoned).
Future<String?> webLoginPopup(String url, String serverOrigin, Duration timeout) {
  if (_open(url, "_blank") == null) {
    return Future.error(Exception("Your browser blocked the login window. Allow pop-ups for this site and try again."));
  }
  final completer = Completer<String?>();
  late final JSFunction listener;
  late final Timer timer;
  void done(String? result) {
    if (completer.isCompleted) {
      return;
    }
    _removeEventListener("message", listener);
    timer.cancel();
    completer.complete(result);
  }

  listener = ((JSObject e) {
    if (e.getProperty<JSAny?>("origin".toJS).dartify() != serverOrigin) {
      return;
    }
    final data = e.getProperty<JSAny?>("data".toJS).dartify();
    final result = data is Map ? data["app-login"] : null;
    if (result is String) {
      done(result);
    }
  }).toJS;
  _addEventListener("message", listener);
  timer = Timer(timeout, () => done(null));
  return completer.future;
}
