import 'package:firebase_auth/firebase_auth.dart';
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
    final User fireUser = FirebaseAuth.instance.currentUser;
    if (fireUser == null) {
      return false;
    } else
      return true;
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
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
              "Terms of Use",
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
                        TextSpan(text: agreement),
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
