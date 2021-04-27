//import 'dart:js';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../login_page.dart';
import '../userHomePage.dart';

class AuthService {
  AuthService(FirebaseApp fb) {
    _fb = fb;
  }

  FirebaseApp _fb;

  FirebaseAuth getFirebaseAuth() {
    if (_fb == null) return FirebaseAuth.instance;
    return FirebaseAuth.instanceFor(app: _fb);
  }

  handleAuth() {
    return StreamBuilder(
        stream: getFirebaseAuth().authStateChanges(),
        builder: (BuildContext context, snapshot) {
          if (snapshot.hasData) {
            return UserHomePage();
          } else {
            return LoginPage();
          }
        });
  }

  signOut(BuildContext context) {
    getFirebaseAuth().signOut().whenComplete(() {
      Navigator.pop(context);
      Navigator.push(
          context, MaterialPageRoute(builder: (context) => LoginPage()));
    }).catchError((error) {
      print("error in signout $error");
    });
  }

//SignIn
  UserCredential signIn(AuthCredential authCreds, BuildContext context) {
    UserCredential result;
    getFirebaseAuth()
        .signInWithCredential(authCreds)
        .then((UserCredential authResult) {
      result = authResult;
    });
    return result;
    // Navigator.pop(context);
    // Navigator.push(
    //   context, MaterialPageRoute(builder: (context) => LandingPage()));
  }

  UserCredential signInWithOTP(smsCode, verId, context) {
    AuthCredential authCreds =
        PhoneAuthProvider.credential(verificationId: verId, smsCode: smsCode);
    return signIn(authCreds, context);
  }

  void verifyPhoneNumber(
      String phoneNumber,
      Duration timeout,
      PhoneVerificationCompleted verificationCompleted,
      PhoneVerificationFailed verificationFailed,
      int forceResendingToken,
      PhoneCodeSent codeSent,
      PhoneCodeAutoRetrievalTimeout codeAutoRetrievalTimeout) {
    FirebaseAuth fAuth = getFirebaseAuth();

    fAuth.verifyPhoneNumber(
        phoneNumber: phoneNumber,
        timeout: timeout,
        verificationCompleted: verificationCompleted,
        verificationFailed: verificationFailed,
        forceResendingToken: forceResendingToken,
        codeSent: codeSent,
        codeAutoRetrievalTimeout: codeAutoRetrievalTimeout);
  }
}
