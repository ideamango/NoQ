//import 'dart:js';

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:noq/dashboard.dart';
import 'package:noq/login_page.dart';
import 'package:noq/userHomePage.dart';

class AuthService {
  handleAuth() {
    return StreamBuilder(
        stream: FirebaseAuth.instance.onAuthStateChanged,
        builder: (BuildContext context, snapshot) {
          if (snapshot.hasData) {
            return UserHomePage();
          } else {
            return LoginPage();
          }
        });
  }

  signOut(BuildContext context) {
    FirebaseAuth.instance.signOut().whenComplete(() {
      Navigator.pop(context);
      Navigator.push(
          context, MaterialPageRoute(builder: (context) => LoginPage()));
    }).catchError((error) {
      print("error in signout $error");
    });
  }

//SignIn
  AuthResult signIn(AuthCredential authCreds, BuildContext context) {
    AuthResult result;
    FirebaseAuth.instance
        .signInWithCredential(authCreds)
        .then((AuthResult authResult) {
      result = authResult;
    });
    return result;
    // Navigator.pop(context);
    // Navigator.push(
    //   context, MaterialPageRoute(builder: (context) => LandingPage()));
  }

  AuthResult signInWithOTP(smsCode, verId, context) {
    AuthCredential authCreds = PhoneAuthProvider.getCredential(
        verificationId: verId, smsCode: smsCode);
    return signIn(authCreds, context);
  }
}
