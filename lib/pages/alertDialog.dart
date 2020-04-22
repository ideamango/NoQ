import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:pinput/pin_put/pin_put.dart';
import 'package:noq/style.dart';
import 'package:noq/services/authService.dart';

final TextEditingController _pinPutController = TextEditingController();
final FocusNode _pinPutFocusNode = FocusNode();
String _pin = null;

BoxDecoration get _pinPutDecoration {
  return BoxDecoration(
    border: Border.all(color: Colors.orange),
    //borderRadius: BorderRadius.circular(15),
  );
}

void _submitPin(String pin, BuildContext context) {
  _pin = pin;
  // final snackBar = SnackBar(
  //   duration: Duration(seconds: 3),
  //   content: Container(
  //       height: 80.0,
  //       child: Center(
  //         child: Text(
  //           'Pin Submitted. Value: $pin',
  //           style: TextStyle(fontSize: 25.0),
  //         ),
  //       )),
  //   backgroundColor: deepPurpleAccent[200],
  // );
  // Scaffold.of(context).hideCurrentSnackBar();
  // Scaffold.of(context).showSnackBar(snackBar);
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
              color: Colors.orange,
              textColor: Colors.white,
              child: Text('Clear All'),
              onPressed: () => _pinPutController.text = '',
            ),
            FlatButton(
              color: Colors.orange,
              textColor: Colors.white,
              child: Text('Submit'),
              onPressed: () {
                print("OTP Submitted");
                //  print('$_pinPutController.text');
                print('pin ::' + _pin);
                AuthService()
                    .signInWithOTP(_pin, verificationId, context)
                    .then(() {
                  //Navigator.of(context).pop();
                  Navigator.of(context).pushReplacementNamed('/landingPage');
                });
                print("Error: invalid OTP");

                //     : verifyPhone(_mobile);
                //if success proceed to next screen
                // Navigator.of(context).pop();
                // Navigator.of(context).pushReplacementNamed('/landingPage');
                //else go back to signin page
              },
            )
          ],
        );
      });
}
