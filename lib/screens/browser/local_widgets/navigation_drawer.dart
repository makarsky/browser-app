import 'dart:io';
import 'dart:core';
import 'package:flutter/material.dart';
import 'package:rate_my_app/rate_my_app.dart';
import 'package:url_launcher/url_launcher.dart';

class NavigationDrawer extends StatefulWidget {
  @override
  _NavigationDrawerState createState() => _NavigationDrawerState();
}

class _NavigationDrawerState extends State<NavigationDrawer> {
  WidgetBuilder builder = buildProgressIndicator;

  static Widget buildProgressIndicator(BuildContext context) => const Center();

  final Uri _emailLaunchUri = Uri(
      scheme: 'mailto',
      path: 'support@browserapp.com',
      queryParameters: {'subject': 'Issue Report'});

  void _rateMyAppHandler(RateMyApp rateMyApp) {
    Navigator.of(context).pop();

    rateMyApp.showStarRateDialog(
      context,
      title: 'Rate us!',
      message:
          'Do you like this app? Take a little bit of your time to leave a rating:',
      // contentBuilder: (context, defaultContent) => content, // This one allows you to change the default dialog content.
      actionsBuilder: (context, stars) {
        // Triggered when the user updates the star rating.
        return [
          FlatButton(
            child: Text('Dismiss'),
            onPressed: () async {
              await rateMyApp.callEvent(RateMyAppEventType.laterButtonPressed);
              Navigator.pop<RateMyAppDialogButton>(
                  context, RateMyAppDialogButton.rate);
            },
          ),
          Spacer(
            flex: 1,
          ),
          FlatButton(
            child: Text('Rate'),
            onPressed: () async {
              print('Thanks for the ' +
                  (stars == null ? '0' : stars.round().toString()) +
                  ' star(s) !');
              // You can handle the result as you want (for instance if the user puts 1 star then open your contact page, if he puts more then open the store page, etc...).
              // This allows to mimic the behavior of the default "Rate" button. See "Advanced > Broadcasting events" for more information :
              await rateMyApp.callEvent(RateMyAppEventType.rateButtonPressed);
              Navigator.pop<RateMyAppDialogButton>(
                  context, RateMyAppDialogButton.rate);
            },
          )
        ];
      },
      ignoreNativeDialog: Platform
          .isAndroid, // Set to false if you want to show the Apple's native app rating dialog on iOS or Google's native app rating dialog (depends on the current Platform).
      dialogStyle: DialogStyle(
        titleAlign: TextAlign.center,
        messageAlign: TextAlign.center,
        messagePadding: EdgeInsets.only(bottom: 20),
      ),
      starRatingOptions: StarRatingOptions(), // Custom star bar rating options.
      onDismissed: () => rateMyApp.callEvent(RateMyAppEventType
          .laterButtonPressed), // Called when the user dismissed the dialog (either by taping outside or by pressing the "back" button).
    );
  }

  Widget _getDrawer(RateMyApp rateMyApp) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          DrawerHeader(
            child: Text(
              'Browser',
              style: TextStyle(color: Colors.white, fontSize: 18),
            ),
            decoration: BoxDecoration(
              color: Colors.blue,
            ),
          ),
          ListTile(
            leading: Icon(Icons.star_rate),
            title: Text('Rate The App'),
            onTap: () => _rateMyAppHandler(rateMyApp),
          ),
          ListTile(
            leading: Icon(Icons.border_color),
            title: Text('Feedback'),
            onTap: () => {launch(_emailLaunchUri.toString())},
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return RateMyAppBuilder(
      builder: builder,
      onInitialized: (context, rateMyApp) {
        setState(() => builder = (context) => _getDrawer(rateMyApp));
        rateMyApp.conditions.forEach((condition) {
          if (condition is DebuggableCondition) {
            print(condition.valuesAsString);
          }
        });

        print('Are all conditions met ? ' +
            (rateMyApp.shouldOpenDialog ? 'Yes' : 'No'));

        if (rateMyApp.shouldOpenDialog) {
          rateMyApp.showStarRateDialog(context);
        }
      },
    );
  }
}
