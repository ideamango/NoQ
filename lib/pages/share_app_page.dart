import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:noq/constants.dart';
import 'package:noq/style.dart';
import 'package:noq/userHomePage.dart';
import 'package:noq/utils.dart';
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
  Uri dynamicLink;
  String inviteText;
  String message;
  String inviteSubject = "Invite friends via..";
  bool _initCompleted = false;
  @override
  void initState() {
    super.initState();
    Utils.createDynamicLink().then((value) {
      setState(() {
        _initCompleted = true;
        dynamicLink = value;
        message = 'Hey,' +
            appName +
            ' is simple and fast way that\n'
                'I use to book appointment for the\n'
                'places I wish to go. It helps to \n'
                'avoid waiting and crowd. Check it out.';
        inviteText = dynamicLink.toString();
      });
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    String title = "Share our App";
    return MaterialApp(
      theme: ThemeData.light().copyWith(),
      home: Scaffold(
        drawer: CustomDrawer(
          //TODO: provide phone of user here
          phone: null,
        ),
        appBar: CustomAppBarWithBackButton(
          backRoute: UserHomePage(),
          titleTxt: title,
        ),
        body: Center(
            child: Container(
                margin: EdgeInsets.fromLTRB(10, 10, 10, 10),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    Card(
                      elevation: 20,
                      child: Container(
                          padding: EdgeInsets.all(0),
                          height: MediaQuery.of(context).size.height * .35,
                          child: Image.asset('assets/sharing.png')),
                    ),
                    Card(
                      child: Column(
                        children: <Widget>[
                          Padding(
                            padding: EdgeInsets.symmetric(
                                vertical: 8.0, horizontal: 16.0),
                            child: Text(shareWithFriends,
                                style: highlightSubTextStyle),
                          ),
                          Padding(
                            padding: EdgeInsets.symmetric(
                                vertical: 8.0, horizontal: 16.0),
                            child: Text(shareWithOwners,
                                style: highlightSubTextStyle),
                          ),
                          Padding(
                            padding: EdgeInsets.symmetric(
                                vertical: 8.0, horizontal: 16.0),
                            child: RaisedButton(
                                color: primaryAccentColor,
                                textColor: Colors.white,
                                splashColor: highlightColor,
                                onPressed: () {
                                  if (_initCompleted) {
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
                                  } else {
                                    Utils.showMyFlushbar(
                                        context,
                                        Icons.info,
                                        Duration(seconds: 4),
                                        "Sharing the details..",
                                        "");
                                  }
                                },
                                child: Row(
                                  children: <Widget>[
                                    new Icon(Icons.share, color: Colors.white),
                                    horizontalSpacer,
                                    horizontalSpacer,
                                    Text('Send invites'),
                                  ],
                                )),
                          ),
                        ],
                      ),
                    )
                  ],
                ))),
        // bottomNavigationBar: CustomBottomBar(
        //   barIndex: 3,
        // ),
      ),
    );
  }
}
