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

  @override
  Widget build(BuildContext context) {
    return Container(
        height: height ?? 100.0,
        child: WebView(
          initialUrl: Uri.dataFromString(
              widget.html,
              mimeType: 'text/html',
              encoding: Encoding.getByName('utf-8')
          ).toString(),//'about:blank',
          navigationDelegate: (req) {
            canLaunch(req.url).then((result) {
              if(result) {
                launch(req.url);
              }
            });
            return NavigationDecision.prevent;
          },
          onWebViewCreated: (WebViewController webViewController) {
            _controller = webViewController;
          },
          onPageFinished: (some) async {
            if(_controller != null) {
              double h = double.parse(await _controller!.evaluateJavascript("document.documentElement.scrollHeight;"));
              setState(() {
                height = h;
              });
            }
          },
          javascriptMode: JavascriptMode.unrestricted,
        ));
  }

}
