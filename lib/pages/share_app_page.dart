import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../constants.dart';
import '../style.dart';
import '../userHomePage.dart';
import '../utils.dart';
import '../widget/appbar.dart';
import '../widget/header.dart';
import '../widget/widgets.dart';
import 'package:share/share.dart';

class ShareAppPage extends StatefulWidget {
  @override
  _ShareAppPageState createState() => _ShareAppPageState();
}

class _ShareAppPageState extends State<ShareAppPage> {
  Uri dynamicLink;
  String inviteText;

  String inviteSubject = "Invite friends via..";
  bool _initCompleted = false;
  @override
  void initState() {
    super.initState();
    Utils.createDynamicLinkWithParams(null, appShareHeading).then((value) {
      setState(() {
        _initCompleted = true;
        dynamicLink = value;
        inviteText = appShareMessage + "\n" + dynamicLink.toString();
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
      debugShowCheckedModeBanner: false,
      theme: ThemeData.light().copyWith(),
      home: WillPopScope(
        child: Scaffold(
          // drawer: CustomDrawer(
          //   //TODO: provide phone of user here
          //   phone: null,
          // ),
          appBar: CustomAppBarWithBackButton(
            backRoute: UserHomePage(),
            titleTxt: title,
          ),
          body: Center(
              child: Container(
                  margin: EdgeInsets.fromLTRB(10, 10, 10, 10),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Container(
                          padding: EdgeInsets.all(0),
                          height: MediaQuery.of(context).size.height * .35,
                          child: Image.asset('assets/sharing.png')),
                      Container(
                        child: Column(
                          children: <Widget>[
                            Padding(
                              padding: EdgeInsets.symmetric(
                                  vertical: 8.0, horizontal: 16.0),
                              child: Text(shareWithFriends,
                                  style: userAccountHeadingTextStyle),
                            ),
                            Padding(
                              padding: EdgeInsets.symmetric(
                                  vertical: 8.0, horizontal: 16.0),
                              child: Text(shareWithOwners,
                                  style: shareAppTextStyle),
                            ),
                            Padding(
                              padding: EdgeInsets.symmetric(
                                  vertical: 8.0, horizontal: 16.0),
                              child: RaisedButton(
                                  color: btnColor,
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
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: <Widget>[
                                      new Icon(Icons.share,
                                          color: Colors.white),
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
        onWillPop: () async {
          return true;
        },
      ),
    );
  }
}
