import 'package:LESSs/services/url_services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import '../constants.dart';
import '../login_page.dart';
import '../style.dart';
import '../userHomePage.dart';
import '../widget/page_animation.dart';

class PrivacyPolicyPage extends StatefulWidget {
  @override
  _PrivacyPolicyPageState createState() => _PrivacyPolicyPageState();
}

class _PrivacyPolicyPageState extends State<PrivacyPolicyPage> {
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
            "Privacy Policy",
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
                            child: Image.asset('assets/privacy.png')),
                        Container(
                          padding: EdgeInsets.all(8),
                          child: RichText(
                            text: TextSpan(
                                style: documentTextStyle,
                                children: <TextSpan>[
                                  TextSpan(
                                      text: privacyPolicy1,
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold)),
                                  TextSpan(text: privacyPolicy2),
                                  TextSpan(
                                    text: " Read Privacy Policy",
                                    style: TextStyle(color: Colors.blue),
                                    recognizer: new TapGestureRecognizer()
                                      ..onTap = () => launchUri(
                                          "https://lesss.bigpiq.com/privacy-policy"),
                                  ),
                                ]),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                // Card(
                //   elevation: 8,
                //   child: Container(
                //     padding: EdgeInsets.all(8),
                //     color: Colors.blue[50],
                //     child: RichText(
                //       text:
                //           TextSpan(style: documentTextStyle, children: <TextSpan>[
                //         TextSpan(text: privacyPolicy2),
                //       ]),
                //     ),
                //   ),
                // ),
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
