import 'package:LESSs/services/url_services.dart';
import 'package:LESSs/widget/page_animation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import '../constants.dart';
import '../login_page.dart';
import '../style.dart';
import '../userHomePage.dart';

class TermsOfUsePage extends StatefulWidget {
  @override
  _TermsOfUsePageState createState() => _TermsOfUsePageState();
}

class _TermsOfUsePageState extends State<TermsOfUsePage> {
  Future<bool> userAlreadyLoggedIn() async {
    final User? fireUser = FirebaseAuth.instance.currentUser;
    if (fireUser == null) {
      return false;
    } else
      return true;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      child: Scaffold(
        appBar: AppBar(
          actions: <Widget>[],
          flexibleSpace: Container(
            decoration: gradientBackground,
          ),
          leading: IconButton(
            padding: EdgeInsets.all(0),
            alignment: Alignment.center,
            highlightColor: highlightColor,
            icon: Icon(Icons.arrow_back),
            color: Colors.white,
            onPressed: () {
              print("going back");
              User? value = FirebaseAuth.instance.currentUser;
              if (value == null) {
                print("No user");
                Navigator.of(context)
                    .push(PageNoAnimation.createRoute(LoginPage()));
              } else {
                print("Go to dashboard");
                Navigator.of(context)
                    .push(PageNoAnimation.createRoute(UserHomePage()));
              }
            },
          ),
          title: Text(
            "Terms of Use",
            style: drawerdefaultTextStyle,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        body: Center(
          child: SingleChildScrollView(
            padding: EdgeInsets.all(12),
            physics: BouncingScrollPhysics(),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Card(
                  elevation: 8,
                  child: Padding(
                    padding: EdgeInsets.all(8),
                    child: Column(
                      children: [
                        Container(
                            decoration: BoxDecoration(
                                border: Border.all(color: borderColor!),
                                color: Colors.white,
                                shape: BoxShape.rectangle,
                                borderRadius:
                                    BorderRadius.all(Radius.circular(5.0))),
                            padding: EdgeInsets.all(0),
                            height: MediaQuery.of(context).size.height * .3,
                            child: Image.asset('assets/terms.png')),
                        Container(
                          padding: EdgeInsets.all(8),
                          child: RichText(
                            text: TextSpan(
                                style: documentTextStyle,
                                children: <TextSpan>[
                                  TextSpan(text: agreement1),
                                  TextSpan(text: agreement2),
                                  TextSpan(
                                    text: agreement3,
                                    style: TextStyle(color: Colors.blue),
                                    recognizer: new TapGestureRecognizer()
                                      ..onTap = () => launchUri(
                                          "https://lesss.bigpiq.com/terms-of-use"),
                                  ),
                                  TextSpan(text: agreement4),
                                  TextSpan(
                                    text: agreement5,
                                    style: TextStyle(color: Colors.blue),
                                    recognizer: new TapGestureRecognizer()
                                      ..onTap = () => launchUri(
                                          "https://lesss.bigpiq.com/privacy-policy"),
                                  ),
                                  TextSpan(text: agreement6),
                                ]),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      onWillPop: () async {
        Navigator.of(context).popUntil(ModalRoute.withName('/dashboard'));
        Navigator.of(context).push(new MaterialPageRoute(
            builder: (BuildContext context) => UserHomePage()));
        return false;
      },
    );
  }
}
