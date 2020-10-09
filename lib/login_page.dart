import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:noq/pages/otpdialog.dart';
import 'package:noq/pages/terms_of_use.dart';
import 'package:noq/userHomePage.dart';
import 'package:noq/utils.dart';
import 'package:noq/widget/widgets.dart';
import 'package:pinput/pin_put/pin_put.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'style.dart';
import 'package:noq/constants.dart';
import 'services/authService.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
  String _errorMsg;
  String _mobile, smsCode;
  String verificationId;
  final _loginPageFormKey = new GlobalKey<FormState>();
  bool codeSent = false;
  bool _autoValidate = false;
  bool isButtonPressed = false;
  String _errorMessage;
  //METHODS

  //UI ELEMENTS
  final headingText = Text(
    loginMainTxt,
    textAlign: TextAlign.left,
    //textDirection: TextDirection.ltr,
    //textWidthBasis: TextWidthBasis.longestLine,
    style: headingTextStyle,
  );
  final subHeadingText = Text(
    loginSubTxt,
    textAlign: TextAlign.center,
    style: logoSubTextStyle,
  );

  @override
  Widget build(BuildContext context) {
    final phNumField = TextFormField(
      obscureText: false,
      maxLines: 1,
      minLines: 1,
      style: lightInputTextStyle,
      inputFormatters: <TextInputFormatter>[
        WhitelistingTextInputFormatter.digitsOnly,
      ],
      keyboardType: TextInputType.phone,

      decoration: InputDecoration(
        // errorStyle: errorTextStyle,
        labelStyle: lightLabelTextStyle,
        prefixStyle: lightLabelTextStyle,
        // hintStyle: hintTextStyle,
        prefixText: '+91',
        labelText: 'Phone Number',
        enabledBorder:
            UnderlineInputBorder(borderSide: BorderSide(color: Colors.grey)),
        focusedBorder:
            UnderlineInputBorder(borderSide: BorderSide(color: Colors.orange)),
      ),
      validator: Utils.validateMobile,
      onSaved: (value) => _mobile = "+91" + value,
      onChanged: (value) {
        setState(() {
          // if (_errorMsg != null) {
          //   _errorMsg = null;
          // }
          this._mobile = "+91" + value;
          _prefs.then((SharedPreferences prefs) {
            prefs.setString("phone", '$_mobile');
          });
        });
      },
      // onSaved: (value) => _mobile = value,
      //onSubmitted: _phoneNumberValidator,
    );
    final loginButon = Material(
      elevation: 10.0,
      color: btnColor,
      //  isButtonPressed
      //     ? Theme.of(context).primaryColor
      //     : Theme.of(context).accentColor,
      child: MaterialButton(
        minWidth: MediaQuery.of(context).size.width,
        // padding: EdgeInsets.fromLTRB(10.0, 7.5, 10.0, 7.5),
        onPressed: submitForm,
        child: Text(
          "Continue",
          textAlign: TextAlign.center,
          style: buttonTextStyle,
        ),
      ),
    );

    return Scaffold(
      backgroundColor: Colors.grey[850],
      body: Container(
        decoration: BoxDecoration(
            image: DecorationImage(
                image: AssetImage("assets/background.png"), fit: BoxFit.cover)),
        //color: Colors.white,
        margin: new EdgeInsets.fromLTRB(10, 5.0, 10, 5),
        child: SafeArea(
          child: new Form(
            key: _loginPageFormKey,
            autovalidate: _autoValidate,
            child: SingleChildScrollView(
              child: new Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  SizedBox(
                    height: 250.0,
                    child: Image.asset(
                      "assets/logo.png",
                      fit: BoxFit.contain,
                    ),
                  ),
                  // Column(
                  //     //mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  //     crossAxisAlignment: CrossAxisAlignment.start,
                  //     children: <Widget>[headingText, subHeadingText]),
                  verticalSpacer,
                  verticalSpacer,
                  phNumField,
                  verticalSpacer,
                  Container(
                    child: Row(
                      children: <Widget>[
                        RichText(
                          text: TextSpan(
                            style: subHeadingTextStyle,
                            children: <TextSpan>[
                              TextSpan(
                                  text:
                                      "By clicking Continue, I agree to the "),
                              TextSpan(
                                text: 'Terms of Use',
                                style: new TextStyle(
                                    color: primaryAccentColor,
                                    //decoration: TextDecoration.underline,
                                    decorationColor: primaryDarkColor),
                                recognizer: new TapGestureRecognizer()
                                  ..onTap = () {
                                    Navigator.pop(context);
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                TermsOfUsePage()));
                                  },
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  verticalSpacer,
                  loginButon,
                  verticalSpacer,
                  (_errorMsg != null
                      ? Text('$_errorMsg', style: errorTextStyle)
                      : Container()),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void submitForm() {
    if (_loginPageFormKey.currentState.validate()) {
      _loginPageFormKey.currentState.save();
      codeSent
          ? AuthService().signInWithOTP(smsCode, verificationId, context)
          : verifyPhone(_mobile);
    } else {
      setState(() {
        _autoValidate = true;
      });
    }

    //verifyPhone(_mobile);
    // if (codeSent) {
    //   if (smsOTPDialog(context, codeSent) != null) {
    //     print("From main otp shown");

    //     if (formKey.currentState.validate()) {
    //       // If the form is valid, display a snackbar. In the real world,
    //       // you'd often call a server or save the information in a database.
    //       formKey.currentState.save();
    //       // Scaffold.of(context)
    //       //     .showSnackBar(SnackBar(content: Text('Processing Data')));
    //       // Navigator.push(context,
    //       //     MaterialPageRoute(builder: (context) => LandingPage()));
    //     }
    //   }
    // } else {
    //   setState(() {
    //     _autoValidate = true;
    //   });
    // }
  }

  Future<void> verifyPhone(phoneNo) async {
    int _forceResendingToken;
    try {
      final PhoneVerificationCompleted phoneVerified =
          (AuthCredential authResult) {
        print("Main - verification completed");
        showDialogForOtp(verificationId, authResult);
        AuthService().signIn(authResult, context);
      };

      final PhoneVerificationFailed verificationFailed =
          (FirebaseAuthException authException) {
        setState(() {
          _errorMsg = '${authException.message}';

          print("Error message: " + _errorMsg);
          if (authException.message.contains('not authorized'))
            _errorMsg = 'Something has gone wrong, please try later';
          else if (authException.message.contains('Network'))
            _errorMsg = 'Please check your internet connection and try again';
          else if (authException.message.contains('Network'))
            _errorMsg = 'The phone number is not correct, try again.';
          else
            _errorMsg = '$_errorMsg';
        });
        print("Main - verification failed");
        return;
        //handleError(authException);
      };

      final PhoneCodeSent otpSent = (String verId, [int forceResend]) {
        print("Main - code sent");
        this.verificationId = verId;
        print("before dialog callhbksdjfhskjfyhewroiuytfewqorhy");
        showDialogForOtp(verId, null);
        _forceResendingToken = forceResend;
        //smsOTPDialog(context, verificationId).then((value) {
        //print('sign in');
        // });
        // smsOTPDialog(context, this.verificationId);
        setState(() {
          this.codeSent = true;
        });
      };

      final PhoneCodeAutoRetrievalTimeout autoTimeout = (String verId) {
        this.verificationId = verId;
        print("Main - Time out");
      };

      await FirebaseAuth.instance.verifyPhoneNumber(
          phoneNumber: phoneNo,
          timeout: Duration(seconds: 120),
          verificationCompleted: phoneVerified,
          verificationFailed: verificationFailed,
          forceResendingToken: _forceResendingToken,
          codeSent: otpSent,
          codeAutoRetrievalTimeout: autoTimeout);
    } catch (e) {
      setState(() {
        _errorMsg = "Invalid phone number.";
      });
      print(e.toString());
      print("Main - in catch");
      handleError(e);
    }
  }

  final TextEditingController _pinPutController = TextEditingController();
  final FocusNode _pinPutFocusNode = FocusNode();
  String _pin;

  String _phoneNo;

  BoxDecoration get _pinPutDecoration {
    return BoxDecoration(
      border: Border.all(color: highlightColor),
      //borderRadius: BorderRadius.circular(15),
    );
  }

//ToDo Smita - PHASE2
  // void resendVerificationCode(String phoneNumber, var token) {
  //   final PhoneVerificationCompleted phoneVerified =
  //       (AuthCredential authResult) {
  //     AuthService().signIn(authResult, context);
  //   };

  //   final PhoneVerificationFailed verificationFailed =
  //       (FirebaseAuthException authException) {
  //     print("Resend - verification failed");
  //   };

  //   final PhoneCodeSent otpSent = (String verId, [int forceResend]) {
  //     this.verificationId = verId;
  //     print("Resend - code sent");
  //   };

  //   final PhoneCodeAutoRetrievalTimeout autoTimeout = (String verId) {
  //     this.verificationId = verId;
  //     print("Resend - time out");
  //   };

  //   FirebaseAuth.instance.verifyPhoneNumber(
  //       phoneNumber: _mobile,
  //       timeout: const Duration(seconds: 60),
  //       verificationCompleted: phoneVerified,
  //       verificationFailed: verificationFailed,
  //       codeSent: otpSent,
  //       codeAutoRetrievalTimeout: autoTimeout,
  //       forceResendingToken: token);
  // }

  // void _submitPin(String pin, BuildContext context) {
  //   _pin = pin;
  //   print(_pin);
  //   try {
  //     FirebaseAuth.instance.currentUser().then((user) {
  //       if (user != null) {
  //         Navigator.of(context).pop();
  //         Navigator.of(context).pushReplacementNamed('/dashboard');
  //       } else {
  //         if (_pin == null || _pin == "") {
  //           setState(() {
  //             _errorMessage = "Enter 6 digit otp sent on your phone.";
  //           });
  //         } else {
  //           AuthCredential authCreds = PhoneAuthProvider.getCredential(
  //               verificationId: verificationId, smsCode: _pin);
  //           FirebaseAuth.instance
  //               .signInWithCredential(authCreds)
  //               .then((AuthResult authResult) {
  //             // AuthService()
  //             //     .signInWithOTP(_pin, verificationId, context)
  //             // .then(() {
  //             print("inside then");
  //             Navigator.of(context).pop();
  //             Navigator.of(context).pushReplacementNamed('/dashboard');
  //           }).catchError((onError) {
  //             print("printing Errorrrrrrrrrr");
  //             // print(onError.toString());
  //             handleError(onError);
  //           });
  //         }
  //       }
  //     });
  //   } catch (err) {
  //     print("$err.toString()");
  //     setState(() {
  //       _errorMessage = err.toString();
  //     });
  //   }
  // }

  showDialogForOtp(String verId, AuthCredential autoAuth) async {
    String last4digits = _mobile.substring(_mobile.length - 4);
    _errorMessage = "";

    await showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) {
          String _errorMessage;
          return StatefulBuilder(builder: (context, setState) {
            if (autoAuth != null) {
              //  _pinPutController.text = autoAuth.;
            }
            return AlertDialog(
              // title:
              backgroundColor: Colors.grey[200],
              titleTextStyle: inputTextStyle,
              elevation: 10.0,
              contentTextStyle: TextStyle(color: primaryDarkColor),
              content: Container(
                //height: MediaQuery.of(context).size.height * .25,
                width: MediaQuery.of(context).size.width * .85,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Container(
                      height: MediaQuery.of(context).size.height * .05,
                      child: Row(
                        // mainAxisSize: MainAxisSize.max,
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: <Widget>[
                          Container(
                            height: MediaQuery.of(context).size.height * .06,
                            transform: Matrix4.translationValues(12.0, -10, 0),
                            child: IconButton(
                              icon: Icon(
                                Icons.cancel,
                                color: Colors.grey[600],
                              ),
                              onPressed: () {
                                codeSent = false;
                                Navigator.of(context).pop();
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                    // verticalSpacer,
                    RichText(
                      text: TextSpan(
                          style: highlightSubTextStyle,
                          children: <TextSpan>[
                            TextSpan(
                                text: 'OTP',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w800,
                                  color: Colors.blueGrey[500],
                                )),
                            TextSpan(
                                text:
                                    ' is sent on your phone number ending with $last4digits',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.blueGrey[500],
                                )),
                          ]),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Container(
                      //     height: MediaQuery.of(context).size.height * .09,
                      //color: Colors.black,
                      //margin: EdgeInsets.all(5),
                      padding: EdgeInsets.all(0),
                      child: PinPut(
                        fieldsCount: 6,
                        onSubmit: (String pin) {
                          //_submitPin(pin, context);

                          //   _pin = pin;
                          print(pin);
                          try {
                            User user = FirebaseAuth.instance.currentUser;
                            if (user != null) {
                              Navigator.of(context).pop();
                              Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => UserHomePage()));
                            } else {
                              if (pin == null || pin == "") {
                                setState(() {
                                  _errorMessage =
                                      "Enter 6 digit otp sent on your phone.";
                                });
                              } else {
                                AuthCredential authCreds =
                                    PhoneAuthProvider.credential(
                                        verificationId: verificationId,
                                        smsCode: pin);
                                FirebaseAuth.instance
                                    .signInWithCredential(authCreds)
                                    .then((UserCredential authResult) {
                                  // AuthService()
                                  //     .signInWithOTP(_pin, verificationId, context)
                                  // .then(() {
                                  print("inside then");
                                  Navigator.of(context).pop();
                                  Navigator.pushReplacement(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              UserHomePage()));
                                }).catchError((onError) {
                                  print("printing Errorrrrrrrrr in Login");
                                  // print(onError.toString());
                                  //handleError(onError);
                                  switch (onError.code) {
                                    case 'ERROR_INVALID_VERIFICATION_CODE':
                                      // FocusScope.of(context).requestFocus(new FocusNode());
                                      setState(() {
                                        _errorMessage =
                                            'Please enter a valid OTP code.';
                                      });

                                      print(_errorMessage);

                                      break;
                                    case 'firebaseAuth':
                                      _errorMessage =
                                          'Please enter a valid Phone number.';
                                      print(_errorMessage);

                                      break;
                                    default:
                                      _errorMessage =
                                          'Oops, something went wrong. Try again.';
                                      print(_errorMessage);

                                      break;
                                  }
                                });
                              }
                            }
                          } catch (err) {
                            print("$err.toString()");
                            setState(() {
                              _errorMessage = err.toString();
                            });
                          }
                          // setState(() {
                          //   errorMsg = _errorMessage;
                          // });
                        },
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
                  height: 30,
                  child: FlatButton(
                    color: Colors.transparent,
                    textColor: btnColor,
                    shape: RoundedRectangleBorder(
                        side: BorderSide(color: btnColor),
                        borderRadius: BorderRadius.all(Radius.circular(3.0))),
                    child: Text(
                      'Clear All',
                      style: TextStyle(fontSize: 11),
                    ),
                    onPressed: () {
                      setState(() {
                        _errorMessage = null;
                      });
                      _pinPutController.text = '';
                      _pinPutFocusNode.requestFocus();
                    },
                  ),
                ),
                // Container(
                //   height: 30,
                //   alignment: Alignment.center,
                //   child: FlatButton(
                //     color: disabledColor,
                //     textColor: Colors.white,
                //     shape: RoundedRectangleBorder(
                //         // side: BorderSide(color: btnColor),
                //         borderRadius: BorderRadius.all(Radius.circular(3.0))),
                //     child: Text(
                //       'Resend OTP',
                //       style: TextStyle(fontSize: 11),
                //     ),
                //     onPressed: () {
                //       //TODO SMITA add code for resend
                //       //verifyPhone(_mobile);
                //       // resendVerificationCode(_phoneNo, verId);
                //     },
                //   ),
                // ),
                SizedBox(
                  height: 30,
                  child: RaisedButton(
                    color: btnColor,
                    textColor: Colors.white,
                    shape: RoundedRectangleBorder(
                        side: BorderSide(color: btnColor),
                        borderRadius: BorderRadius.all(Radius.circular(3.0))),
                    child: Text('Submit', style: TextStyle(fontSize: 11)),
                    onPressed: () {
                      print(_pinPutController.text);
                      _pin = _pinPutController.text;

                      try {
                        User user = FirebaseAuth.instance.currentUser;

                        if (user != null) {
                          Navigator.of(context).pop();
                          Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => UserHomePage()));
                        } else {
                          if (_pin == null || _pin == "") {
                            setState(() {
                              _errorMessage =
                                  "Please enter 6 digit OTP sent on your phone.";
                            });
                          } else {
                            AuthCredential authCreds =
                                PhoneAuthProvider.credential(
                                    verificationId: verificationId,
                                    smsCode: _pin);
                            FirebaseAuth.instance
                                .signInWithCredential(authCreds)
                                .then((UserCredential authResult) {
                              // AuthService()
                              //     .signInWithOTP(_pin, verificationId, context)
                              // .then(() {
                              print("inside then");
                              Navigator.of(context).pop();
                              Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => UserHomePage()));
                            }).catchError((onError) {
                              // print("printing Errorrrrrrrrrr");
                              // // print(onError.toString());
                              // handleError(onError);
                              switch (onError.code) {
                                case 'ERROR_INVALID_VERIFICATION_CODE':
                                  // FocusScope.of(context).requestFocus(new FocusNode());
                                  setState(() {
                                    _errorMessage =
                                        'OTP is invalid, Please try again.';
                                  });

                                  print(_errorMessage);

                                  break;
                                case 'firebaseAuth':
                                  _errorMessage =
                                      'Phone number is invalid, Please enter a valid Phone number.';
                                  print(_errorMessage);

                                  break;
                                case 'ERROR_USER_DISABLED':
                                  setState(() {
                                    _errorMessage = 'User has been disabled.';
                                  });
                                  break;

                                default:
                                  _errorMessage =
                                      'Oops, something went wrong. Check your internet connection and try again.';
                                  print(_errorMessage);

                                  break;
                              }
                            });
                          }
                        }
                      } catch (err) {
                        print("$err.toString()");
                        setState(() {
                          _errorMessage = err.toString();
                        });
                      }
                    },
                  ),
                ),
              ],
            );
            //  OTPDialog(verificationId: verId, phoneNo: _mobile);
          });
        });
  }

  handleError(FirebaseAuthException error) {
    print(error);
    switch (error.code) {
      case 'ERROR_INVALID_VERIFICATION_CODE':
        // FocusScope.of(context).requestFocus(new FocusNode());
        setState(() {
          _errorMsg = 'Invalid OTP Code';
        });
        break;
      case 'firebaseAuth':
        setState(() {
          _errorMsg = 'Invalid phone number';
        });
        break;
      default:
        setState(() {
          _errorMsg = 'Oops, something went wrong. Try again.';
        });

        break;
    }
  }
}
