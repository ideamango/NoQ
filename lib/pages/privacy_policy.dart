import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:noq/constants.dart';
import 'package:noq/login_page.dart';
import 'package:noq/style.dart';
import 'package:noq/userHomePage.dart';

class PrivacyPolicyPage extends StatefulWidget {
  @override
  _PrivacyPolicyPageState createState() => _PrivacyPolicyPageState();
}

class _PrivacyPolicyPageState extends State<PrivacyPolicyPage> {
  Future<bool> userAlreadyLoggedIn() async {
    final User fireUser = FirebaseAuth.instance.currentUser;
    if (fireUser == null) {
      return false;
    } else
      return true;
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData.light().copyWith(),
      home: WillPopScope(
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
                User value = FirebaseAuth.instance.currentUser;
                if (value == null) {
                  print("No user");
                  Navigator.push(context,
                      MaterialPageRoute(builder: (context) => LoginPage()));
                } else {
                  print("Go to dashboard");
                  Navigator.push(context,
                      MaterialPageRoute(builder: (context) => UserHomePage()));
                }
              },
            ),
            title: Text(
              "Privacy Policy",
              style: drawerdefaultTextStyle,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          body: SingleChildScrollView(
            padding: EdgeInsets.all(16),
            physics: BouncingScrollPhysics(),
            child: Column(
              children: [
                RichText(
                  text: TextSpan(
                      style: highlightSubTextStyle,
                      children: <TextSpan>[
                        TextSpan(text: privacyPolicy),
                      ]),
                ),
              ],
            ),
          ),
        ),
        onWillPop: () async {
          return true;
        },
      ),
    );
  }
}
