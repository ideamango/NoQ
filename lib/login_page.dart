import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import './events/auto_verification_completed_data.dart';
import './events/event_bus.dart';
import './events/events.dart';
import './global_state.dart';
import './pages/explore_page_for_business.dart';
import './pages/search_entity_page.dart';
import './pages/explore_page_for_user.dart';
import './pages/otpdialog.dart';
import './pages/terms_of_use.dart';
import './userHomePage.dart';
import './utils.dart';
import './widget/page_animation.dart';
import './widget/widgets.dart';
import 'package:pinput/pin_put/pin_put.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'style.dart';
import './constants.dart';
import 'services/auth_service.dart';

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
  GlobalState _state;
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
  void initState() {
    super.initState();
    GlobalState.getGlobalState().then((value) {
      _state = value;
    });
  }

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
          _errorMsg = null;
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

    return WillPopScope(
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        backgroundColor: Colors.grey[850],
        body: Container(
          height: double.infinity,
          decoration: BoxDecoration(
              image: DecorationImage(
                  image: AssetImage("assets/background.png"),
                  fit: BoxFit.cover)),
          //color: Colors.white,
          margin: new EdgeInsets.fromLTRB(10, 5.0, 10, 5),
          child: new Form(
            key: _loginPageFormKey,
            autovalidate: _autoValidate,
            child: new Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                //  SizedBox(height: MediaQuery.of(context).size.height * .1),
                SizedBox(
                  //height: MediaQuery.of(context).size.height * .15,
                  child: Image.asset(
                    "assets/less_name.png",
                    fit: BoxFit.contain,
                  ),
                  // child: Text(
                  //   "LESSs",
                  //   style: TextStyle(
                  //       fontFamily: "AnandaNamaste",
                  //       fontSize: 90,
                  //       color: primaryAccentColor),
                  // ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    SizedBox(
                        //height: MediaQuery.of(context).size.height * .07,
                        width: MediaQuery.of(context).size.width * .7,
                        child: Image.asset(
                          "assets/sukoon_subheading.png",
                          fit: BoxFit.contain,
                        )),
                  ],
                ),
                SizedBox(height: MediaQuery.of(context).size.height * .05),
                phNumField,
                verticalSpacer,
                Container(
                  height: MediaQuery.of(context).size.height * .05,
                  child: Row(
                    children: <Widget>[
                      RichText(
                        text: TextSpan(
                          style: subHeadingTextStyle,
                          children: <TextSpan>[
                            TextSpan(
                                text: "By clicking Continue, I agree to the "),
                            TextSpan(
                              text: 'Terms of Use',
                              style: new TextStyle(
                                  color: Colors.cyan[400],
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
                Container(
                  padding: EdgeInsets.all(5),
                  alignment: Alignment.center,
                  width: MediaQuery.of(context).size.width * .8,
                  child: Text(
                    "To know more how LESSs help Save Lives",
                    style: TextStyle(
                      color: Colors.white,
                    ),
                  ),
                ),
                Container(
                  alignment: Alignment.center,
                  width: MediaQuery.of(context).size.width * .8,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    //mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Container(
                        //alignment: Alignment.centerLeft,
                        padding: EdgeInsets.all(0),
                        margin: EdgeInsets.all(0),
                        height: MediaQuery.of(context).size.height * .05,
                        width: MediaQuery.of(context).size.width * .4,
                        child: RaisedButton(
                          elevation: 20,
                          shape: RoundedRectangleBorder(
                              side: BorderSide(color: Colors.blueGrey[600]),
                              borderRadius:
                                  BorderRadius.all(Radius.circular(5.0))),
                          padding: EdgeInsets.all(0),
                          color: Colors.transparent,
                          splashColor: highlightColor.withOpacity(.8),
                          onPressed: () {
                            Navigator.of(context).push(
                                PageAnimation.createRoute(
                                    ExplorePageForBusiness()));
                          },
                          child: Text(
                            "Business Owners",
                            style: TextStyle(
                              color: highlightColor,
                            ),
                          ),
                        ),
                      ),
                      //horizontalSpacer,
                      Container(
                        //  alignment: Alignment.centerRight,
                        padding: EdgeInsets.all(0),
                        margin: EdgeInsets.all(0),
                        height: MediaQuery.of(context).size.height * .05,
                        width: MediaQuery.of(context).size.width * .4,
                        child: RaisedButton(
                          elevation: 20,
                          shape: RoundedRectangleBorder(
                              side: BorderSide(color: Colors.blueGrey[600]),
                              borderRadius:
                                  BorderRadius.all(Radius.circular(5.0))),
                          padding: EdgeInsets.all(0),
                          color: Colors.transparent,
                          splashColor: highlightColor.withOpacity(.8),
                          onPressed: () {
                            Navigator.of(context).push(
                                PageAnimation.createRoute(
                                    ExplorePageForUser()));
                          },
                          child: Text(
                            "Users",
                            textAlign: TextAlign.right,
                            style: TextStyle(
                              color: highlightColor,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      onWillPop: () async {
        return true;
      },
    );
  }

  void submitForm() {
    if (_loginPageFormKey.currentState.validate()) {
      _errorMsg = null;
      _loginPageFormKey.currentState.save();
      codeSent
          ? _state
              .getAuthService()
              .signInWithOTP(smsCode, verificationId, context)
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
          (PhoneAuthCredential authResult) {
        print("Main - verification completed");
        print(authResult.smsCode);

        AutoVerificationCompletedData data =
            new AutoVerificationCompletedData(code: authResult.smsCode);
        EventBus.fireEvent(AUTO_VERIFICATION_COMPLETED_EVENT, null, data);

        //  showDialogForOtp(verificationId, authResult.smscode.toString());
        // AuthService().signIn(authResult, context);
      };

      final PhoneVerificationFailed verificationFailed =
          (FirebaseAuthException authException) {
        setState(() {
          _errorMsg = '${authException.message}';
          if (Utils.isNotNullOrEmpty(_errorMsg)) {
            print("Error message: " + _errorMsg);
            if (authException.message.contains('not authorized'))
              _errorMsg = 'Something has gone wrong, please try again later.';
            else if (authException.message.contains('network'))
              _errorMsg =
                  'Please check your internet connection and try again.';
            // else if (authException.message.contains(''))
            //   _errorMsg = 'The phone number is not correct, try again.';
          } else
            _errorMsg =
                'We are trying to figure out what went wrong, Please check the Phone Number and try again.';
        });
        print("Main - verification failed");
        return;
        //handleError(authException);
      };

      final PhoneCodeSent otpSent = (String verId, [int forceResend]) {
        print("Main - code sent");
        this.verificationId = verId;
        print(verId);
        _forceResendingToken = forceResend;
        showDialogForOtp(verificationId);
        setState(() {
          this.codeSent = true;
        });
      };

      final PhoneCodeAutoRetrievalTimeout autoTimeout = (String verId) {
        this.verificationId = verId;
        print("Main - Time out");
      };

      _state.getAuthService().verifyPhoneNumber(
          phoneNo,
          Duration(seconds: 30),
          phoneVerified,
          verificationFailed,
          _forceResendingToken,
          otpSent,
          autoTimeout);
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

  showDialogForOtp(String verId) async {
    String last4digits = _mobile.substring(_mobile.length - 4);
    _errorMessage = "";

    await showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) {
          String _errorMessage;
          return StatefulBuilder(builder: (context, setState) {
            // if (smsCode != null) {
            //   _pinPutController.text = smsCode;
            // }

            //this dialog is shown on Login once, but the event should be unregistered when the user logs-out
            EventBus.registerEvent(AUTO_VERIFICATION_COMPLETED_EVENT, context,
                (evt, obj) {
              AutoVerificationCompletedData data =
                  evt.eventData as AutoVerificationCompletedData;
              _pinPutController.text = data.code;
            });

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
                          // try {
                          //   User user = FirebaseAuth.instance.currentUser;
                          //   if (user != null) {
                          //     Navigator.of(context).pop();
                          //     Navigator.pushReplacement(
                          //         context,
                          //         MaterialPageRoute(
                          //             builder: (context) => UserHomePage()));
                          //   } else {
                          //     if (pin == null || pin == "") {
                          //       setState(() {
                          //         _errorMessage =
                          //             "Enter 6 digit otp sent on your phone.";
                          //       });
                          //     } else {
                          //       AuthCredential authCreds =
                          //           PhoneAuthProvider.credential(
                          //               verificationId: verificationId,
                          //               smsCode: pin);
                          //       FirebaseAuth.instance
                          //           .signInWithCredential(authCreds)
                          //           .then((UserCredential authResult) {
                          //         // AuthService()
                          //         //     .signInWithOTP(_pin, verificationId, context)
                          //         // .then(() {
                          //         print("inside then");
                          //         Navigator.of(context).pop();
                          //         Navigator.pushReplacement(
                          //             context,
                          //             MaterialPageRoute(
                          //                 builder: (context) =>
                          //                     UserHomePage()));
                          //       }).catchError((onError) {
                          //         print("printing Errorrrrrrrrr in Login");
                          //         // print(onError.toString());
                          //         //handleError(onError);
                          //         switch (onError.code) {
                          //           case 'ERROR_INVALID_VERIFICATION_CODE':
                          //             // FocusScope.of(context).requestFocus(new FocusNode());
                          //             setState(() {
                          //               _errorMessage =
                          //                   'Please enter a valid OTP code.';
                          //             });

                          //             print(_errorMessage);

                          //             break;
                          //           case 'firebaseAuth':
                          //             _errorMessage =
                          //                 'Please enter a valid Phone number.';
                          //             print(_errorMessage);

                          //             break;
                          //           default:
                          //             _errorMessage =
                          //                 'Oops, something went wrong. Try again.';
                          //             print(_errorMessage);

                          //             break;
                          //         }
                          //       });
                          //     }
                          //   }
                          // } catch (err) {
                          //   print("$err.toString()");
                          //   setState(() {
                          //     _errorMessage = err.toString();
                          //   });
                          // }
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
                    child: Text('Approve OTP', style: TextStyle(fontSize: 11)),
                    onPressed: () {
                      print(_pinPutController.text);
                      _pin = _pinPutController.text;

                      try {
                        User user = _state
                            .getAuthService()
                            .getFirebaseAuth()
                            .currentUser;

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
                            _state
                                .getAuthService()
                                .getFirebaseAuth()
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
                                case 'invalid-verification-code':
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

    //  _errorMsg = '${authException.message}';
    //       if (Utils.isNotNullOrEmpty(_errorMsg)) {
    //         print("Error message: " + _errorMsg);
    //         if (authException.message.contains('not authorized'))
    //           _errorMsg = 'Something has gone wrong, please try later';
    //         else if (authException.message.contains('network'))
    //           _errorMsg =
    //               'Please check your internet connection and try again.';
    //         else if (authException.message.contains(''))
    //           _errorMsg = 'The phone number is not correct, try again.';
    //         else
    //           _errorMsg = '$_errorMsg';
    //       } else
    //         _errorMsg =
    //             'We are trying to figure out what went wrong, Please check the Phone Number and try again.';
  }
}
