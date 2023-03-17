library db;
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import "dart:convert";

class HtmlView extends StatefulWidget {
  String html;
  HtmlView(this.html) : super();

  @override
  _HtmlState createState() => _HtmlState();
}

class _HtmlState extends State<HtmlView> {
  WebViewController? _controller;
  double? height;

  @override void initState() {
    super.initState();
    _controller = WebViewController()
    ..setJavaScriptMode(JavaScriptMode.unrestricted)
    ..setBackgroundColor(const Color(0x00000000))
    ..setNavigationDelegate(
    NavigationDelegate(
      onProgress: (int progress) {
        // Update loading bar.
      },
      onPageStarted: (String url) {},
      onPageFinished: (String url) async {
        if(_controller != null) {
          try {
            double h = (await _controller!.runJavaScriptReturningResult(
                "document.documentElement.scrollHeight;")) as double;
            setState(() {
              height = h;
            });
          } catch(e, stack_trace) {
            print(e);
            print(stack_trace);
          }
        }
      },
      onWebResourceError: (WebResourceError error) {},
      onNavigationRequest: (NavigationRequest req) {
        canLaunch(req.url).then((result) {
          if(result) {
            launch(req.url);
          }
        });
        return NavigationDecision.prevent;
      },
    ),
  )
  ..loadRequest(Uri.dataFromString(
        widget.html,
        mimeType: 'text/html',
        encoding: Encoding.getByName('utf-8')
    ));

  }

  @override
  Widget build(BuildContext context) {
    return Container(
        height: height ?? 100.0,
        child: _controller == null ? Container(width:0) : WebViewWidget(
          controller: _controller!,
        ));
  }

}
