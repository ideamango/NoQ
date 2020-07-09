import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:noq/constants.dart';
import 'package:noq/pages/notifications_page.dart';
import 'package:noq/services/qr_code_generate.dart';

import 'package:noq/userHomePage.dart';
import 'package:noq/widget/appbar.dart';
import 'package:noq/widget/bottom_nav_bar.dart';
import 'package:noq/widget/header.dart';
import 'package:share/share.dart';

class UserAccountPage extends StatefulWidget {
  @override
  _UserAccountPageState createState() => _UserAccountPageState();
}

class _UserAccountPageState extends State<UserAccountPage> {
  int _page = 0;
  PageController _pageController;
  List drawerItems = [
    {
      "icon": Icons.account_circle,
      "name": "My Account",
      "pageRoute": UserAccountPage(),
    },
    {
      "icon": Icons.notifications,
      "name": "Notifications",
      "pageRoute": UserNotificationsPage(),
    },
  ];

  void onPageChanged(int page) {
    setState(() {
      _page = page;
    });
  }

  void navigationTapped(int page) {
    _pageController.jumpToPage(page);
  }

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: 8);
    // _initializeUserProfile();
  }

  @override
  void dispose() {
    super.dispose();
    _pageController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    String message = 'Hey,' +
        appName +
        ' app is simple and fast way that\n'
            'I use to book appointment for the\n'
            'places I wish to go. It helps to \n'
            'avoid waiting. Check it out yourself.';
    String link = "www.playstore.com";
    String inviteText = message + link;
    String inviteSubject = "Invite friends via..";
    String title = "My Account";
    return MaterialApp(
      theme: ThemeData.light().copyWith(),
      home: Scaffold(
        drawer: CustomDrawer(),
        appBar: CustomAppBar(
          titleTxt: title,
        ),
        body: Center(
          child: Column(
            children: <Widget>[
              RaisedButton(
                child: Text("Back"),
                onPressed: () => Navigator.push(context,
                    MaterialPageRoute(builder: (context) => UserHomePage())),
              ),
              Padding(
                padding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                child: RaisedButton(
                    color: Colors.blue,
                    textColor: Colors.white,
                    splashColor: Colors.blueGrey,
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => GenerateScreen()),
                      );
                    },
                    child: const Text('GENERATE QR CODE')),
              ),
              Padding(
                padding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                child: RaisedButton(
                    color: Colors.blue,
                    textColor: Colors.white,
                    splashColor: Colors.blueGrey,
                    onPressed: inviteText.isEmpty
                        ? null
                        : () {
                            // A builder is used to retrieve the context immediately
                            // surrounding the RaisedButton.
                            //
                            // The context's `findRenderObject` returns the first
                            // RenderObject in its descendent tree when it's not
                            // a RenderObjectWidget. The RaisedButton's RenderObject
                            // has its position and size after it's built.
                            final RenderBox box = context.findRenderObject();
                            try {
                              Share.share(inviteText,
                                  subject: inviteSubject,
                                  sharePositionOrigin:
                                      box.localToGlobal(Offset.zero) &
                                          box.size);
                            } on PlatformException catch (e) {
                              print('${e.message}');
                            }
                          },
                    child: const Text('Invite friends')),
              ),
            ],
          ),
        ),
        bottomNavigationBar: CustomBottomBar(
          barIndex: 3,
        ),
      ),
    );
  }
}
