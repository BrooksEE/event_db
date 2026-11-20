// A web view that shows one page for a kiosk or display, and says whether it
// loaded - so the screen can show "can't load, retrying" rather than a
// spinner that never ends.
//
// It only goes where it was sent: the page given to [WebPage.load], and any
// other page [allow] lets through. A link or a script trying to take it
// elsewhere is refused. Frames inside the page (an image, an embedded page)
// are the page's business and load from anywhere.
//
// Behind an interface so tests can stand in for the web view.

import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

abstract class WebPage {
  Widget get view;

  /// Loads [url]. True once it has loaded, false if it failed.
  Future<bool> load(Uri url);

  Future<void> runJavaScript(String js);

  /// Called when the loaded page fails later, e.g. a reload with no network.
  set onFailure(VoidCallback? f);

  void dispose() {}
}

/// A page the web view may go to: the one it was sent to ([target]), or
/// "about:blank".
bool sameUrl(Uri url, Uri target) => url.toString() == "about:blank" || (url.origin == target.origin && url.path == target.path);

class WebViewPage implements WebPage {
  late final WebViewController _controller;
  Uri? _target;
  Completer<bool>? _loading;
  bool _failed = false;
  @override
  VoidCallback? onFailure;

  /// Other pages it may go to, besides the one it was sent to: (url, the one
  /// it was sent to).
  final bool Function(Uri url, Uri target)? allow;

  WebViewPage({Color background = Colors.black, this.allow}) {
    _controller = WebViewController();
    // On web the page is an iframe, which can only be pointed at a URL; none
    // of the rest is there (and no load is ever reported finished).
    if (kIsWeb) return;
    _controller.setJavaScriptMode(JavaScriptMode.unrestricted);
    // macOS's web view has no background color (UnimplementedError).
    if (defaultTargetPlatform != TargetPlatform.macOS) _controller.setBackgroundColor(background);
    _controller.setNavigationDelegate(NavigationDelegate(
      onPageStarted: (_) => _failed = false,
      onWebResourceError: (e) {
        if (e.isForMainFrame == false) return; // an image or an embedded page
        _failed = true;
        // iOS reports a failed load here and never finishes it
        final l = _loading;
        _loading = null;
        if (l != null) {
          l.complete(false);
        } else {
          onFailure?.call();
        }
      },
      onPageFinished: (_) {
        final l = _loading;
        _loading = null;
        l?.complete(!_failed);
      },
      // iOS and macOS ask this about the app's own load too, so the page it
      // was sent to must get through.
      onNavigationRequest: (r) => !r.isMainFrame || _allowed(Uri.parse(r.url)) ? NavigationDecision.navigate : NavigationDecision.prevent,
    ));
  }

  bool _allowed(Uri url) {
    final t = _target;
    if (t == null) return false;
    return sameUrl(url, t) || (allow?.call(url, t) ?? false);
  }

  @override
  Widget get view => WebViewWidget(controller: _controller);

  @override
  Future<bool> load(Uri url) {
    _target = url;
    if (kIsWeb) {
      _controller.loadRequest(url);
      return Future.value(true);
    }
    _loading?.complete(false);
    final l = _loading = Completer<bool>();
    _controller.loadRequest(url).catchError((_) {
      if (identical(_loading, l)) {
        _loading = null;
        l.complete(false);
      }
    });
    return l.future;
  }

  @override
  Future<void> runJavaScript(String js) => _controller.runJavaScript(js);

  @override
  void dispose() {}
}
