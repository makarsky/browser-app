import 'package:flutter/material.dart';
import 'package:english_words/english_words.dart';
import './widgets/webview_screen.dart';

class HomePage extends StatefulWidget {
  HomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentIndex = 0;
  final List<Widget> _children = [];

  final _randomWordPairs = <WordPair>[];
  final _savedWordPairs = Set<WordPair>();

  _HomePageState() {
    _children.add(buildList());
    _children.add(
      WebViewScreen(
        startUrl: 'https://medium.com/nonstopio/tagged/mobile-app-development',
      ),
    );
  }

  Widget buildList() {
    return ListView.builder(
      padding: const EdgeInsets.all(6.0),
      itemBuilder: (BuildContext context, int itemIndex) {
        if (itemIndex.isOdd) return Divider();

        final index = itemIndex ~/ 2;

        if (index >= _randomWordPairs.length) {
          _randomWordPairs.addAll(generateWordPairs().take(10));
        }

        return _buildRow(_randomWordPairs[index]);
      },
    );
  }

  Widget _buildRow(WordPair pair) {
    final _alreadySaved = _savedWordPairs.contains(pair);

    return ListTile(
      title: Text(
        pair.asPascalCase,
        style: TextStyle(fontSize: 18),
      ),
      trailing: Icon(
        _alreadySaved ? Icons.favorite : Icons.favorite_border,
        color: _alreadySaved ? Colors.red : null,
      ),
      onTap: () {
        setState(() {
          if (_alreadySaved) {
            _savedWordPairs.remove(pair);
          } else {
            _savedWordPairs.add(pair);
          }
        });
      },
    );
  }

  void _pushSaved() {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (BuildContext context) {
        final Iterable<ListTile> tiles = _savedWordPairs.map((WordPair pair) {
          return ListTile(
            title: Text(
              pair.asPascalCase,
              style: TextStyle(fontSize: 16.0),
            ),
          );
        });

        final List<Widget> divided =
            ListTile.divideTiles(context: context, tiles: tiles).toList();

        return Scaffold(
            appBar: AppBar(
              title: Text('Bookmarks'),
            ),
            body: ListView(
              children: divided,
            ));
      },
    ));
  }

  void onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.list),
            onPressed: _pushSaved,
          ),
        ],
      ),
      body: _children[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.bookmark),
            title: Text('Bookmarks'),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.web),
            title: Text('Browser'),
          ),
        ],
        currentIndex: _currentIndex,
        selectedItemColor: Colors.yellow[300],
        unselectedItemColor: Colors.white,
        backgroundColor: Colors.blue,
        onTap: onTabTapped,
      ),
    );
  }
}
