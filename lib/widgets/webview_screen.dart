import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'dart:async';
import 'package:flutter/animation.dart';
import '../classes/constants.dart';

class WebViewScreen extends StatefulWidget {
  @override
  _WebViewScreenState createState() => _WebViewScreenState();
}

class _WebViewScreenState extends State<WebViewScreen>
    with TickerProviderStateMixin {
  Completer<WebViewController> _controller = Completer<WebViewController>();
  final _formKey = GlobalKey<FormState>();
  TextEditingController _textEditingController = TextEditingController();

  final Set<String> _bookmarks = Set<String>();
  bool _isLoading = true;
  String _currentUrl =
      'https://medium.com/nonstopio/tagged/mobile-app-development';
  bool _isCurrentUrlInBookmarks = false;
  bool _canGoBack = false;
  bool _canGoForward = false;

  @override
  void initState() {
    super.initState();

    _textEditingController.value = TextEditingValue(text: _currentUrl);
  }

  void onPageStarted(String url) {
    setState(() {
      _isLoading = true;
      _currentUrl = url;
      _isCurrentUrlInBookmarks = _bookmarks.contains(_currentUrl);
    });
    setState(() async {
      _canGoBack = await _controller.future
          .then((WebViewController controller) => controller.canGoBack());
      _canGoForward = await _controller.future
          .then((WebViewController controller) => controller.canGoForward());
    });
  }

  void onPageFinished(String url) {
    setState(() {
      _isLoading = false;
    });
  }

  void _addCurrentUrlToBookmarks() {
    setState(() {
      _bookmarks.add(_currentUrl);
      _isCurrentUrlInBookmarks = true;
    });
  }

  void _removeCurrentUrlFromBookmarks() {
    setState(() {
      _bookmarks.remove(_currentUrl);
      _isCurrentUrlInBookmarks = false;
    });
  }

  void _viewBookmarks() {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (BuildContext context) {
        final Iterable<ListTile> tiles = _bookmarks.map((String url) {
          return ListTile(
            title: Text(
              url,
              style: TextStyle(fontSize: 16.0),
            ),
          );
        });

        final List<Widget> divided =
            ListTile.divideTiles(context: context, tiles: tiles).toList();

        return Scaffold(
            appBar: AppBar(
              title: Text(Constants.SETTINGS_BOOKMARKS),
            ),
            body: ListView(
              children: divided,
            ));
      },
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: TextField(
            style: TextStyle(fontSize: 14),
            autofocus: false,
            keyboardType: TextInputType.url,
            maxLines: 1,
            controller: _textEditingController,
            decoration: new InputDecoration(
                filled: true,
                fillColor: Colors.white,
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.all(
                    Radius.circular(50.0),
                  ),
                  borderSide: BorderSide(color: Colors.white),
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(
                    Radius.circular(50.0),
                  ),
                  borderSide: BorderSide(color: Colors.white),
                ),
                isDense: true,
                contentPadding: const EdgeInsets.only(
                    top: 10.0, bottom: 10.0, left: 12.0, right: 12.0))),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.forward),
            onPressed: () {},
          ),
          PopupMenuButton<String>(
            icon: Icon(Icons.more_vert),
            onSelected: (String s) => print(s),
            itemBuilder: (BuildContext context) {
              return Constants.SETTINGS.keys.map((key) {
                return PopupMenuItem(
                  child: Text(Constants.SETTINGS[key]),
                  value: Constants.SETTINGS[key],
                );
              }).toList();
            },
          ),
        ],
      ),
      body: Stack(children: <Widget>[
        WebView(
          initialUrl: _currentUrl,
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
                child: LinearProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  backgroundColor: Colors.blue,
                ))),
      ]),
      bottomNavigationBar: BottomAppBar(
        child: new Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            FutureBuilder<WebViewController>(
                future: _controller.future,
                builder: (BuildContext context,
                    AsyncSnapshot<WebViewController> controller) {
                  return IconButton(
                    disabledColor: Colors.grey,
                    icon: Icon(Icons.chevron_left),
                    onPressed: _canGoBack ? controller.data.goBack : null,
                  );
                }),
            FutureBuilder<WebViewController>(
                future: _controller.future,
                builder: (BuildContext context,
                    AsyncSnapshot<WebViewController> controller) {
                  return IconButton(
                    disabledColor: Colors.grey,
                    icon: Icon(Icons.chevron_right),
                    onPressed: _canGoForward ? controller.data.goForward : null,
                  );
                }),
            IconButton(
              icon: Icon(_isCurrentUrlInBookmarks
                  ? Icons.bookmark
                  : Icons.bookmark_border),
              onPressed: () {
                _isCurrentUrlInBookmarks
                    ? _removeCurrentUrlFromBookmarks()
                    : _addCurrentUrlToBookmarks();
              },
            ),
            IconButton(
              icon: Icon(Icons.list),
              onPressed: _viewBookmarks,
            ),
          ],
        ),
      ),
    );
  }
}
