import 'package:browserapp/screens/browser/local_widgets/rating_stars.dart';
import 'dart:core';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class NavigationDrawer extends StatefulWidget {
  @override
  _NavigationDrawerState createState() => _NavigationDrawerState();
}

class _NavigationDrawerState extends State<NavigationDrawer> {
  final Uri _emailLaunchUri = Uri(
      scheme: 'mailto',
      path: 'support@browserapp.com',
      queryParameters: {'subject': 'Issue Report'});

  void _rateUsAppHandler(context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Rate Us!'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Do you like this app? Take a little bit of your time to leave a rating:',
            ),
            RatingStars(),
          ],
        ),
        actions: <Widget>[
          FlatButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text('Dismiss'),
          ),
          SizedBox(height: 16),
          FlatButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text('Rate!'),
          ),
        ],
      ),
    );
  }

  Widget _createHeader() {
    return DrawerHeader(
      margin: EdgeInsets.zero,
      padding: EdgeInsets.zero,
      decoration: BoxDecoration(
        color: Colors.blue,
      ),
      child: Stack(
        children: <Widget>[
          Positioned(
            bottom: 12.0,
            left: 16.0,
            child: Text(
              'BrowserApp',
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 20.0,
                  fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }

  Widget _getDrawer(context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          _createHeader(),
          ListTile(
            leading: Icon(Icons.star_rate),
            title: Text('Rate Us!'),
            onTap: () => _rateUsAppHandler(context),
          ),
          ListTile(
            leading: Icon(Icons.border_color),
            title: Text('Feedback'),
            onTap: () => launch(_emailLaunchUri.toString()),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return _getDrawer(context);
  }
}
