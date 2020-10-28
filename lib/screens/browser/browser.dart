import 'dart:convert';
import 'package:browserapp/models/bookmark.dart';
import 'package:browserapp/screens/bookmarks/bookmarks.dart';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'dart:async';
import 'package:flutter/animation.dart';
import '../../classes/constants.dart';
import './local_widgets/navigation_drawer.dart';
import 'package:validators/validators.dart';
import 'package:shared_preferences/shared_preferences.dart';

class BrowserScreen extends StatefulWidget {
  @override
  _BrowserScreenState createState() => _BrowserScreenState();
}

class _BrowserScreenState extends State<BrowserScreen>
    with TickerProviderStateMixin {
  SharedPreferences sharedPreferences;
  Completer<WebViewController> _controller = Completer<WebViewController>();
  TextEditingController _textEditingController = TextEditingController();
  AnimationController _refreshIconRotationController;

  List<Bookmark> _bookmarks = List<Bookmark>();
  double _linearLoaderHeight = 4.0;
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

    _refreshIconRotationController = AnimationController(
        duration: const Duration(milliseconds: 1000), vsync: this);
    initSharedPreferencesAndCurrentUrl();
  }

  void initSharedPreferencesAndCurrentUrl() async {
    sharedPreferences = await SharedPreferences.getInstance();
    setState(() {
      _currentUrl =
          _cachedUrl = sharedPreferences.getString('lastUrl') ?? _currentUrl;
      _textEditingController.value = TextEditingValue(text: _cachedUrl);
      _linearLoaderHeight = 0.0;
      _bookmarks =
          (jsonDecode(sharedPreferences.getString('bookmarks')) as List)
              .map((data) => Bookmark.fromJson(data))
              .toList();
    });
  }

  Widget _getBody() {
    if (sharedPreferences != null) {
      return WebView(
        initialUrl: _cachedUrl,
        onWebViewCreated: (WebViewController webViewController) {
          _controller.complete(webViewController);
        },
        onPageStarted: onPageStarted,
        onPageFinished: onPageFinished,
        javascriptMode: JavascriptMode.unrestricted,
      );
    }
    return Container();
  }

  void onPageStarted(String url) {
    setState(() {
      _linearLoaderHeight = 4.0;
      _cachedUrl = _currentUrl = url;
      _isCurrentUrlDirty = false;
      _isCurrentUrlInBookmarks =
          _bookmarks.any((Bookmark bookmark) => bookmark.url == _cachedUrl);
      _textEditingController.value = TextEditingValue(text: _currentUrl);
      _refreshIconRotationController.reset();
      sharedPreferences.setString('lastUrl', _cachedUrl);
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
      _linearLoaderHeight = 0.0;
    });
  }

  void _addCurrentUrlToBookmarks() async {
    sharedPreferences = await SharedPreferences.getInstance();
    setState(() {
      _controller.future
          .then((WebViewController controller) => controller.getTitle())
          .then((String title) {
        _bookmarks.add(Bookmark(title: title, url: _cachedUrl));
        sharedPreferences.setString('bookmarks', jsonEncode(_bookmarks));
        _isCurrentUrlInBookmarks = true;
      });
    });
  }

  void _removeCurrentUrlFromBookmarks() {
    setState(() {
      _bookmarks.removeWhere((Bookmark bookmark) => bookmark.url == _cachedUrl);
      _isCurrentUrlInBookmarks = false;
    });
  }

  void _viewBookmarks() async {
    final result = await Navigator.of(context).push(MaterialPageRoute(
      builder: (BuildContext context) => BookmarksScreen(bookmarks: _bookmarks),
    ));

    if (result is String) {
      setState(() {
        _linearLoaderHeight = 4.0;
        _controller.future
            .then((WebViewController controller) => controller.loadUrl(result));
      });
    }
  }

  void _triggerOption(String option) {
    switch (option) {
      case Constants.OPTION_REFRESH:
        _refreshIconRotationController.repeat();
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

    FocusManager.instance.primaryFocus.unfocus();
  }

  void _updateWebView([String url]) {
    bool isValidURL = false;
    try {
      isValidURL = isURL(_currentUrl, requireTld: true, requireProtocol: true);
    } catch (e) {}

    if (_isCurrentUrlDirty) {
      if (isValidURL) {
        _controller.future.then(
            (WebViewController controller) => controller.loadUrl(_currentUrl));
      } else {
        String encodedString = Uri.encodeFull(_currentUrl);
        _controller.future.then((WebViewController controller) => controller
            .loadUrl('https://www.google.com/search?q=$encodedString'));
      }
    } else {
      _refreshIconRotationController.repeat();
      _controller.future
          .then((WebViewController controller) => controller.reload());
    }

    FocusManager.instance.primaryFocus.unfocus();
  }

  Future<bool> _onBackPressed() async {
    WebViewController webViewController = await _controller.future;
    _canGoBack = await webViewController.canGoBack();

    if (_canGoBack) {
      webViewController.goBack();
      return false;
    }

    return showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text('Confirm'),
            content: Text('Do you want to exit?'),
            actions: <Widget>[
              FlatButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: Text('No'),
              ),
              SizedBox(height: 16),
              FlatButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: Text('Yes'),
              ),
            ],
          ),
        ) ??
        false;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        onWillPop: _onBackPressed,
        child: Scaffold(
          appBar: AppBar(
            automaticallyImplyLeading: false, // Removes the default drawer icon
            title: TextField(
                style: TextStyle(fontSize: 14),
                autofocus: false,
                keyboardType: TextInputType.url,
                maxLines: 1,
                controller: _textEditingController,
                onTap: () => _textEditingController.selection = TextSelection(
                    baseOffset: 0,
                    extentOffset: _textEditingController.text.length),
                onChanged: (String newUrl) {
                  setState(() {
                    _currentUrl = newUrl.trim();
                    _isCurrentUrlDirty = _currentUrl != _cachedUrl;
                  });
                },
                onSubmitted: _updateWebView,
                decoration: InputDecoration(
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
                        top: 10.0, bottom: 10.0, left: 15.0, right: 15.0))),
            actions: <Widget>[
              RotationTransition(
                  turns: Tween(begin: 0.0, end: 1.0)
                      .animate(_refreshIconRotationController),
                  child: IconButton(
                    icon: Icon(
                        _isCurrentUrlDirty ? Icons.forward : Icons.refresh),
                    onPressed: _updateWebView,
                  )),
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
            _getBody(),
            Align(
                alignment: Alignment.topCenter,
                child: AnimatedContainer(
                    curve: Curves.easeInOut,
                    height: _linearLoaderHeight,
                    duration: Duration(milliseconds: 200),
                    child: LinearProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      backgroundColor: Colors.blue,
                    ))),
          ]),
          bottomNavigationBar: BottomAppBar(
            child: Row(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
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
                        onPressed:
                            _canGoForward ? controller.data.goForward : null,
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
        ));
  }
}
