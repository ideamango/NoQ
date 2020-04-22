//import 'dart:js';

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:noq/dashboard.dart';
import 'package:noq/login_page.dart';

class AuthService {
  handleAuth() {
    return StreamBuilder(
        stream: FirebaseAuth.instance.onAuthStateChanged,
        builder: (BuildContext context, snapshot) {
          if (snapshot.hasData) {
            return LandingPage();
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
  signIn(AuthCredential authCreds, BuildContext context) {
    FirebaseAuth.instance.signInWithCredential(authCreds);
    Navigator.pop(context);
    Navigator.push(
        context, MaterialPageRoute(builder: (context) => LandingPage()));
  }

  signInWithOTP(smsCode, verId, context) {
    AuthCredential authCreds = PhoneAuthProvider.getCredential(
        verificationId: verId, smsCode: smsCode);
    signIn(authCreds, context);
  }
}
