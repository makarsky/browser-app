import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'dart:async';
import 'package:flutter/animation.dart';

class WebViewScreen extends StatefulWidget {
  final String startUrl;

  WebViewScreen({@required this.startUrl});

  @override
  _WebViewScreenState createState() => _WebViewScreenState();
}

class _WebViewScreenState extends State<WebViewScreen>
    with TickerProviderStateMixin {
  Completer<WebViewController> _controller = Completer<WebViewController>();

  final _history = <String>[];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();

    _history.add(widget.startUrl);
  }

  void onPageStarted(String url) {
    _history.add(url);
    setState(() {
      _isLoading = true;
    });
  }

  void onPageFinished(String url) {
    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Stack(children: <Widget>[
      WebView(
        initialUrl: widget.startUrl,
        onWebViewCreated: (WebViewController webViewController) {
          _controller.complete(webViewController);
        },
        onPageStarted: onPageStarted,
        onPageFinished: onPageFinished,
        javascriptMode: JavascriptMode.unrestricted,
      ),
      Visibility(
          visible: _isLoading,
          child: Align(
              alignment: Alignment.topCenter,
              child: LinearProgressIndicator())),
    ]));
  }
}
