import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'dart:async';
import 'package:flutter/animation.dart';
import '../classes/constants.dart';
import 'navigation_drawer.dart';

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
  String _cachedUrl;
  bool _isCurrentUrlInBookmarks = false;
  bool _isCurrentUrlDirty = false;
  bool _canGoBack = false;
  bool _canGoForward = false;

  @override
  void initState() {
    super.initState();

    _textEditingController.value = TextEditingValue(text: _currentUrl);
    _cachedUrl = _currentUrl;
  }

  void onPageStarted(String url) {
    setState(() {
      _isLoading = true;
      _cachedUrl = _currentUrl = url;
      _isCurrentUrlDirty = false;
      _isCurrentUrlInBookmarks = _bookmarks.contains(_cachedUrl);
      _textEditingController.value = TextEditingValue(text: _currentUrl);
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
      _bookmarks.add(_cachedUrl);
      _isCurrentUrlInBookmarks = true;
    });
  }

  void _removeCurrentUrlFromBookmarks() {
    setState(() {
      _bookmarks.remove(_cachedUrl);
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
              title: Text(Constants.OPTION_BOOKMARKS),
            ),
            body: ListView(
              children: divided,
            ));
      },
    ));
  }

  void _triggerOption(String option) {
    switch (option) {
      case Constants.OPTION_REFRESH:
        _controller.future
            .then((WebViewController controller) => controller.reload());
        setState(() {
          _currentUrl = _cachedUrl;
          _textEditingController.value = TextEditingValue(text: _currentUrl);
        });
        break;
      case Constants.OPTION_BOOKMARKS:
        _viewBookmarks();
        break;
      default:
        throw ("The option '$option' has not been implemented.");
    }
  }

  void _updateWebView([String url]) {
    if (_isCurrentUrlDirty) {
      _controller.future.then(
          (WebViewController controller) => controller.loadUrl(_currentUrl));
    } else {
      _controller.future
          .then((WebViewController controller) => controller.reload());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false, // removes default drawer icon
        title: TextField(
            style: TextStyle(fontSize: 14),
            autofocus: false,
            keyboardType: TextInputType.url,
            maxLines: 1,
            controller: _textEditingController,
            onChanged: (String newUrl) {
              setState(() {
                _currentUrl = newUrl;
                _isCurrentUrlDirty = _currentUrl != _cachedUrl;
              });
            },
            onSubmitted: _updateWebView,
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
            icon: Icon(_isCurrentUrlDirty ? Icons.forward : Icons.refresh),
            onPressed: _updateWebView,
          ),
          PopupMenuButton<String>(
            icon: Icon(Icons.more_vert),
            onSelected: _triggerOption,
            itemBuilder: (BuildContext context) {
              return Constants.OPTIONS.keys.map((key) {
                return PopupMenuItem(
                  child: Text(Constants.OPTIONS[key]),
                  value: Constants.OPTIONS[key],
                );
              }).toList();
            },
          ),
        ],
      ),
      body: Stack(children: <Widget>[
        WebView(
          initialUrl: _cachedUrl,
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
      drawer: NavigationDrawer(),
    );
  }
}
