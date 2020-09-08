import 'package:flutter/material.dart';
import '../classes/constants.dart';

class BookmarksScreen extends StatefulWidget {
  BookmarksScreen({Key key, this.bookmarks}) : super(key: key);

  final Set<String> bookmarks;

  @override
  _BookmarksScreenState createState() => _BookmarksScreenState();
}

class _BookmarksScreenState extends State<BookmarksScreen> {
  @override
  Widget build(BuildContext context) {
    final Iterable<ListTile> tiles = widget.bookmarks.map((String url) {
      return ListTile(
        title: Text(
          url,
          style: TextStyle(fontSize: 16.0),
        ),
      );
    });

    final List<Widget> dividedTiles =
        ListTile.divideTiles(context: context, tiles: tiles).toList();

    final Center emptyContainer =
        Center(child: Text('You haven\'t added any bookmarks yet.'));

    Widget listView = ListView(
      children: dividedTiles,
    );

    return Scaffold(
        appBar: AppBar(
          title: Text(Constants.OPTION_BOOKMARKS),
        ),
        body: widget.bookmarks.isEmpty ? emptyContainer : listView);
  }
}
