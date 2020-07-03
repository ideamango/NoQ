import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:noq/services/authService.dart';
import 'package:noq/style.dart';
import 'package:noq/widget/widgets.dart';
import 'package:pinput/pin_put/pin_put.dart';

class OTPDialog extends StatefulWidget {
  final String verificationId;
  OTPDialog({Key key, @required this.verificationId}) : super(key: key);
  @override
  _OTPDialogState createState() => _OTPDialogState();
}

class _OTPDialogState extends State<OTPDialog> {
  String verId;
  final TextEditingController _pinPutController = TextEditingController();
  final FocusNode _pinPutFocusNode = FocusNode();
  String _pin;
  String _errorMessage;

  BoxDecoration get _pinPutDecoration {
    return BoxDecoration(
      border: Border.all(color: highlightColor),
      //borderRadius: BorderRadius.circular(15),
    );
  }

  @override
  void initState() {
    super.initState();

    verId = widget.verificationId;
  }

  void _submitPin(String pin, BuildContext context) {
    _pin = pin;
    print(_pin);
    try {
      FirebaseAuth.instance.currentUser().then((user) {
        if (user != null) {
          Navigator.of(context).pop();
          Navigator.of(context).pushReplacementNamed('/dashboard');
        } else {
          if (_pin == null) {
            setState(() {
              _errorMessage = "Enter 6 digit otp sent on your phone.";
            });
          } else {
            AuthCredential authCreds = PhoneAuthProvider.getCredential(
                verificationId: verId, smsCode: _pin);
            FirebaseAuth.instance
                .signInWithCredential(authCreds)
                .then((AuthResult authResult) {
              // AuthService()
              //     .signInWithOTP(_pin, verificationId, context)
              // .then(() {
              print("inside then");
              //Navigator.of(context).pop();
              Navigator.of(context).pushReplacementNamed('/landingPage');
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

    // final snackBar = SnackBar(
    //   //duration: Duration(seconds: 3),
    //   content: Container(
    //       height: 80.0,
    //       child: Center(
    //         child: Text(
    //           'Pin Submitted. Value: $pin',
    //           style: TextStyle(fontSize: 25.0),
    //         ),
    //       )),
    //   backgroundColor: Colors.teal,
    // );
    // Scaffold.of(context).hideCurrentSnackBar();
    // Scaffold.of(context).showSnackBar(snackBar);
  }

  handleError(PlatformException error) {
    print(error);
    switch (error.code) {
      case 'ERROR_INVALID_VERIFICATION_CODE':
        // FocusScope.of(context).requestFocus(new FocusNode());
        setState(() {
          _errorMessage = 'Invalid OTP Code';
        });

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

  @override
  Widget build(BuildContext context) {
    // return showDialog(
    //     context: context,
    //     barrierDismissible: false,
    //     builder: (BuildContext context) {
    return new AlertDialog(
      // title:
      backgroundColor: Colors.grey[200],
      titleTextStyle: inputTextStyle,
      elevation: 10.0,
      contentTextStyle: TextStyle(color: primaryDarkColor),
      content: Container(
        height: MediaQuery.of(context).size.height * .2,
        child: Column(
          mainAxisSize: MainAxisSize.max,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text('Enter OTP',
                style: TextStyle(
                  fontSize: 20,
                  color: Colors.blueGrey[600],
                )),
            Text('One time password(OTP) is sent on your mobile device',
                style: TextStyle(
                  fontSize: 10,
                  color: Colors.blueGrey[500],
                )),
            SizedBox(
              height: 10,
            ),
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
                    color: btnColor,
                  ),
                ),
              ),
            ),
            Divider(
              color: Colors.blueGrey[400],
              height: 1,
              //indent: 40,
              //endIndent: 30,
            ),
            (_errorMessage != null
                ? Text(
                    _errorMessage,
                    textAlign: TextAlign.left,
                    style: errorTextStyle,
                  )
                : SizedBox(height: 1)),
            // SizedBox(height: 10),
            //Divider(),
          ],
        ),
      ),
      // titlePadding: EdgeInsets.fromLTRB(5, 10, 0, 0),
      contentPadding: EdgeInsets.all(8),
      actionsPadding: EdgeInsets.all(0),
      actions: <Widget>[
        SizedBox(
          height: 28,
          width: 80,
          child: RaisedButton(
            color: btnColor,
            textColor: Colors.white,
            // shape:
            //     RoundedRectangleBorder(side: BorderSide(color: highlightColor)),
            child: Text('Clear All'),
            onPressed: () {
              setState(() {
                _errorMessage = null;
              });
              _pinPutController.text = '';
            },
          ),
        ),
        // FlatButton(
        //   color: Colors.orange,
        //   textColor: Colors.white,
        //   child: Text('Submit'),
        //   onPressed: () {
        //     print("OTP Submitted");
        //     print(_pinPutController.text);
        //     //  print('$_pinPutController.text');
        //     try {
        //       FirebaseAuth.instance.currentUser().then((user) {
        //         if (user != null) {
        //           Navigator.of(context).pop();
        //           Navigator.of(context).pushReplacementNamed('/dashboard');
        //         } else {
        //           if (_pin == null) {
        //             setState(() {
        //               _errorMessage = "Enter 6 digit otp sent on your phone.";
        //             });
        //           } else {
        //             AuthCredential authCreds = PhoneAuthProvider.getCredential(
        //                 verificationId: verId, smsCode: _pin);
        //             FirebaseAuth.instance
        //                 .signInWithCredential(authCreds)
        //                 .then((AuthResult authResult) {
        //               // AuthService()
        //               //     .signInWithOTP(_pin, verificationId, context)
        //               // .then(() {
        //               print("inside then");
        //               //Navigator.of(context).pop();
        //               Navigator.of(context)
        //                   .pushReplacementNamed('/landingPage');
        //             }).catchError((onError) {
        //               print("printing Errorrrrrrrrrr");
        //               // print(onError.toString());
        //               handleError(onError);
        //             });
        //           }
        //         }
        //       });
        //     } catch (err) {
        //       print("$err.toString()");
        //       _errorMessage = err.toString();
        //     }

        //     //     : verifyPhone(_mobile);
        //     //if success proceed to next screen
        //     // Navigator.of(context).pop();
        //     // Navigator.of(context).pushReplacementNamed('/landingPage');
        //     //else go back to signin page
        //   },
        // ),
      ],
    );
    // });
  }
}
