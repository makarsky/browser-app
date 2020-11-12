import 'dart:convert';
import 'package:browserapp/models/bookmark.dart';
import 'package:browserapp/screens/bookmarks/local_widgets/vertical_progress_bar.dart';
import 'package:flutter/material.dart';
import '../../classes/constants.dart';
import 'package:shared_preferences/shared_preferences.dart';

class BookmarksScreen extends StatefulWidget {
  BookmarksScreen({Key key, this.bookmarks}) : super(key: key);

  final List<Bookmark> bookmarks;

  @override
  _BookmarksScreenState createState() => _BookmarksScreenState();
}

class _BookmarksScreenState extends State<BookmarksScreen>
    with SingleTickerProviderStateMixin {
  void _deleteBookmark(Bookmark bookmark) async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    setState(() {
      widget.bookmarks.remove(bookmark);
      sharedPreferences.setString('bookmarks', jsonEncode(widget.bookmarks));
    });
  }

  void _undoBookmarkDeletion(Bookmark bookmark) async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    setState(() {
      widget.bookmarks.insert(0, bookmark);
      sharedPreferences.setString('bookmarks', jsonEncode(widget.bookmarks));
    });
  }

  @override
  Widget build(BuildContext context) {
    final Center emptyContainer =
        Center(child: Text('You haven\'t added any bookmarks yet.'));

    Widget listView = ListView.separated(
        separatorBuilder: (context, index) => Divider(
              height: 0,
            ),
        itemCount: widget.bookmarks.length,
        itemBuilder: (context, index) {
          final bookmark = widget.bookmarks[index];

          return Dismissible(
            key: Key(bookmark.url),
            onDismissed: (direction) async {
              _deleteBookmark(bookmark);

              Scaffold.of(context).showSnackBar(
                SnackBar(
                  content: Row(
                    children: [
                      VerticalProgressBar(),
                      Expanded(
                        child: Text(
                          'Deleting "${bookmark.title}"',
                          softWrap: false,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  action: SnackBarAction(
                    label: 'Undo',
                    onPressed: () => _undoBookmarkDeletion(bookmark),
                  ),
                ),
              );
            },
            background: Container(color: Colors.red),
            child: ListTile(
              title: Text(
                bookmark.title,
                style: TextStyle(fontSize: 16.0),
              ),
              subtitle: Text(
                bookmark.url,
                style: TextStyle(
                  fontSize: 14.0,
                ),
                softWrap: false,
                overflow: TextOverflow.ellipsis,
              ),
              onTap: () => Navigator.pop(context, bookmark.url),
            ),
          );
        });

    return WillPopScope(
      onWillPop: () async {
        if (Navigator.of(context).userGestureInProgress)
          return false;
        else
          return true;
      },
      child: Scaffold(
          appBar: AppBar(
            title: Text(Constants.OPTION_BOOKMARKS),
          ),
          body: widget.bookmarks.isEmpty ? emptyContainer : listView),
    );
  }
}
