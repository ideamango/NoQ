import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:noq/constants.dart';
import 'package:noq/style.dart';
import 'package:noq/widget/appbar.dart';
import 'package:noq/widget/bottom_nav_bar.dart';
import 'package:noq/widget/header.dart';
import 'package:noq/widget/widgets.dart';
import 'package:share/share.dart';

class ShareAppPage extends StatefulWidget {
  @override
  _ShareAppPageState createState() => _ShareAppPageState();
}

class _ShareAppPageState extends State<ShareAppPage> {
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
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

    String title = "Share our App";
    return MaterialApp(
      theme: ThemeData.light().copyWith(),
      home: Scaffold(
        drawer: CustomDrawer(),
        appBar: CustomAppBar(
          titleTxt: title,
        ),
        body: Center(
            child: Container(
                margin: EdgeInsets.fromLTRB(10, 10, 10, 10),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Text("Share and spread happiness!!",
                        style: highlightTextStyle),
                    Text('Sharing is Caring.', style: highlightSubTextStyle),
                    Padding(
                      padding:
                          EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                      child: RaisedButton(
                          color: primaryAccentColor,
                          textColor: Colors.white,
                          splashColor: highlightColor,
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
                                  final RenderBox box =
                                      context.findRenderObject();
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
                          child: Row(
                            children: <Widget>[
                              new Icon(Icons.people, color: Colors.white),
                              horizontalSpacer,
                              horizontalSpacer,
                              Text('Invite friends'),
                            ],
                          )),
                    ),
                  ],
                ))),
        bottomNavigationBar: CustomBottomBar(
          barIndex: 3,
        ),
      ),
    );
  }
}
