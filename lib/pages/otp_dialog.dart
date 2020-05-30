import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:noq/db/db_service/db_main.dart';
import 'package:pinput/pin_put/pin_put.dart';
import 'package:noq/style.dart';
import 'package:noq/services/authService.dart';

final TextEditingController _pinPutController = TextEditingController();
final FocusNode _pinPutFocusNode = FocusNode();
String _pin;
String _errorMessage;

BoxDecoration get _pinPutDecoration {
  return BoxDecoration(
    border: Border.all(color: Colors.orange),
    //borderRadius: BorderRadius.circular(15),
  );
}

void _submitPin(String pin, BuildContext context) {
  _pin = pin;
  print(_pin);
  final snackBar = SnackBar(
    //duration: Duration(seconds: 3),
    content: Container(
        height: 80.0,
        child: Center(
          child: Text(
            'Pin Submitted. Value: $pin',
            style: TextStyle(fontSize: 25.0),
          ),
        )),
    backgroundColor: Colors.teal,
  );
  Scaffold.of(context).hideCurrentSnackBar();
  Scaffold.of(context).showSnackBar(snackBar);
}

handleError(PlatformException error) {
  print(error);
  switch (error.code) {
    case "ERROR_INVALID_VERIFICATION_CODE":
      // FocusScope.of(context).requestFocus(new FocusNode());

      _errorMessage = 'Invalid OTP Code';
      print(_errorMessage);

      break;
    case 'firebaseAuth':
      _errorMessage = 'Invalid phone number';
      print(_errorMessage);

      break;
    default:
      _errorMessage = 'Oops, something went wrong. Try again.';
      print(_errorMessage);

      break;
  }
}

Future<bool> smsOTPDialog(BuildContext context, String verificationId) {
  return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return new AlertDialog(
          title: Text('Enter OTP',
              style: TextStyle(
                fontSize: 20,
                color: Colors.grey,
              )),
          backgroundColor: Colors.grey[200],
          titleTextStyle: inputTextStyle,
          elevation: 10.0,
          content: Container(
            height: 50,
            child: Column(
              mainAxisSize: MainAxisSize.max,
              children: <Widget>[
                Container(
                  //color: Colors.black,
                  //margin: EdgeInsets.all(5),
                  // padding: EdgeInsets.all(0),
                  child: PinPut(
                    fieldsCount: 6,
                    onSubmit: (String pin) => _submitPin(pin, context),
                    focusNode: _pinPutFocusNode,
                    controller: _pinPutController,
                    submittedFieldDecoration: _pinPutDecoration.copyWith(
                        borderRadius: BorderRadius.circular(10)),
                    selectedFieldDecoration: _pinPutDecoration,
                    followingFieldDecoration: _pinPutDecoration.copyWith(
                      borderRadius: BorderRadius.circular(5),
                      border: Border.all(
                        color: Colors.deepPurpleAccent[200].withOpacity(.5),
                      ),
                    ),
                  ),
                ),
                // SizedBox(height: 10),
                //Divider(),
              ],
            ),
          ),
          contentPadding: EdgeInsets.all(10),
          actions: <Widget>[
            FlatButton(
              color: Colors.transparent,
              textColor: Colors.orange,
              shape: RoundedRectangleBorder(
                  side: BorderSide(color: Colors.orange)),
              child: Text('Clear All'),
              onPressed: () => _pinPutController.text = '',
            ),
            FlatButton(
              color: Colors.orange,
              textColor: Colors.white,
              child: Text('Submit'),
              onPressed: () {
                print("OTP Submitted");
                print(_pinPutController.text);
                //  print('$_pinPutController.text');
                try {
                  FirebaseAuth.instance.currentUser().then((user) {
                    if (user != null) {
                      Navigator.of(context).pop();
                      Navigator.of(context).pushReplacementNamed('/dashboard');
                    } else {
                      if (_pin == null) {
                        _errorMessage = "Enter 6 digit otp sent on your phone.";
                      } else {
                        AuthCredential authCreds =
                            PhoneAuthProvider.getCredential(
                                verificationId: verificationId, smsCode: _pin);
                        FirebaseAuth.instance
                            .signInWithCredential(authCreds)
                            .then((AuthResult authResult) {
                          // AuthService()
                          //     .signInWithOTP(_pin, verificationId, context)
                          // .then(() {
                          print("inside then");
                          //Navigator.of(context).pop();

                          Navigator.of(context)
                              .pushReplacementNamed('/landingPage');
                        }).catchError((onError) {
                          print("printing Errorrrrrrrrrr");
                          // print(onError.toString());
                          handleError(onError);
                        });
                      }
                    }
                  });
                } catch (err) {
                  print("$err.toString()");
                  _errorMessage = err.toString();
                }

                //     : verifyPhone(_mobile);
                //if success proceed to next screen
                // Navigator.of(context).pop();
                // Navigator.of(context).pushReplacementNamed('/landingPage');
                //else go back to signin page
              },
            ),
            (_errorMessage != null
                ? Text(
                    _errorMessage,
                    style: TextStyle(color: Colors.red),
                  )
                : Container()),
          ],
        );
      });
}
