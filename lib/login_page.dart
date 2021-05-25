import 'dart:io';

import 'package:LESSs/services/circular_progress.dart';
import 'package:LESSs/widget/countdown_timer.dart';
import 'package:auto_size_text/auto_size_text.dart';
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

  int _forceResendingToken;
  bool showLoading = false;

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
  void setState(fn) {
    if (mounted) {
      super.setState(fn);
    }
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

          child: Stack(
            children: [
              Container(
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
                      SizedBox(
                          height: MediaQuery.of(context).size.height * .05),
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
                                      text:
                                          "By clicking Continue, I agree to the "),
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
                          ? Container(
                              child: Text('$_errorMsg', style: errorTextStyle))
                          : Container()),
                      // Container(
                      //   padding: EdgeInsets.all(5),
                      //   alignment: Alignment.center,
                      //   width: MediaQuery.of(context).size.width * .8,
                      //   child: Text(
                      //     "To know more about LESSs",
                      //     style: TextStyle(
                      //       color: Colors.white,
                      //     ),
                      //   ),
                      // ),
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
                                    side:
                                        BorderSide(color: Colors.blueGrey[600]),
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
                                    side:
                                        BorderSide(color: Colors.blueGrey[600]),
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
              if (showLoading)
                Center(
                  child: Container(
                    width: MediaQuery.of(context).size.width,
                    height: MediaQuery.of(context).size.height,
                    color: Colors.black.withOpacity(.5),
                    // decoration: BoxDecoration(
                    //   color: Colors.white,
                    //   backgroundBlendMode: BlendMode.saturation,
                    // ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Container(
                          color: Colors.transparent,
                          padding: EdgeInsets.all(12),
                          width: MediaQuery.of(context).size.width * .15,
                          height: MediaQuery.of(context).size.width * .15,
                          child: CircularProgressIndicator(
                            backgroundColor: Colors.black,
                            valueColor:
                                AlwaysStoppedAnimation<Color>(Colors.white),
                            strokeWidth: 2,
                          ),
                        )
                      ],
                    ),
                  ),
                )
            ],
          ),
        ),
      ),
      onWillPop: () async {
        return true;
      },
    );
  }

  void submitForm() {
    setState(() {
      showLoading = true;
    });
    EventBus.registerEvent(OTP_RESEND_EVENT, context, (evt, obj) {
      resendOTP(_mobile);
    });
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
        showLoading = false;
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

  handleAuthException(FirebaseAuthException authException) {
    String message;
//Handle errors -
//1.User Not found
//2. OTP invalid
//3.User disable
//4.Network error
//5. Default
    switch (authException.code) {
      case 'invalid-phone-number':
        message = "The provided phone number is not valid.";
        break;
      case 'firebaseAuth':
        message = 'Invalid phone number';
        break;
      case 'too-many-requests':
        message =
            'You have sent too many requests, Account is disabled temporarily..';
        break;
      case 'invalid-verification-code':
        message = 'OTP is invalid, Please try again.';
        break;
      case "session-expired":
        message = 'The OTP has expired. Please click ReSend OTP.';
        break;
      case 'firebaseAuth':
        message = 'Phone number is invalid, Please enter a valid Phone number.';
        break;
      case 'user-disabled':
        message =
            'The user account has been disabled by an admin. Please contact our team.';
        break;

      default:
        //if (authException.message.contains('not authorized'))
        //  message = 'Something has gone wrong, please try again later.';
        // else
        if (authException.message != null) {
          if (authException.message.contains('network'))
            message =
                'There seems to be some problem with your internet connection. Please Check.';
        } else
          message =
              'Oops, Something went wrong. Check your internet connection.';
        break;
    }

    Utils.showMyFlushbar(context, Icons.error, Duration(seconds: 6), message,
        "Please try again later.");
  }

  Future<void> resendOTP(String phone) async {
    verifyPhone(phone);
  }

  Future<void> verifyPhone(phoneNo) async {
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
        handleAuthException(authException);
        return;
        //handleError(authException);
      };

      final PhoneCodeSent otpSent = (String verId, [int forceResend]) {
        print("Main - code sent");
        this.verificationId = verId;
        if (mounted) {
          setState(() {
            showLoading = false;
          });
        }
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
      print(e.toString());
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
    bool timeLapsed = false;
    bool codeFilled = false;
    bool autoReadFailed = false;
    double dialogWidth = MediaQuery.of(context).size.width * .85;
    await showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) {
          String _errorMessage;
          return StatefulBuilder(builder: (context, setState) {
            //this dialog is shown on Login once, but the event should be unregistered when the user logs-out
            EventBus.registerEvent(AUTO_VERIFICATION_COMPLETED_EVENT, context,
                (evt, obj) {
              AutoVerificationCompletedData data =
                  evt.eventData as AutoVerificationCompletedData;
              _pinPutController.text = data.code;
              //Highlight approve
              codeFilled = true;
              if (mounted) {
                setState(() {});
              }
            });
            if (mounted) {
              setState(() {
                _errorMessage = null;
              });
            }

            Future.delayed(Duration(seconds: 30)).then((value) {
              timeLapsed = true;
            });
            return AlertDialog(
              insetPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 20),
              backgroundColor: Colors.white,
              titleTextStyle: inputTextStyle,
              elevation: 10.0,
              contentTextStyle: TextStyle(color: primaryDarkColor),
              content: Container(
                //height: MediaQuery.of(context).size.height * .25,
                width: dialogWidth,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Container(
                      height: MediaQuery.of(context).size.height * .05,
                      child: Row(
                        // mainAxisSize: MainAxisSize.max,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          // Container(
                          //   width: dialogWidth * .1,
                          // ),
                          Container(
                            alignment: Alignment.center,
                            width: dialogWidth * .9,
                            padding: EdgeInsets.fromLTRB(10, 0, 0, 0),
                            margin: EdgeInsets.zero,

                            height: MediaQuery.of(context).size.height * .04,
                            //  transform: Matrix4.translationValues(12.0, -10, 0),
                            child: AutoSizeText("Enter One-Time Password",
                                minFontSize: 16,
                                maxFontSize: 18,
                                style: TextStyle(
                                  //  fontWeight: FontWeight.w800,
                                  color: Colors.blueGrey[800],
                                )),
                          ),
                          Container(
                            width: MediaQuery.of(context).size.height * .04,
                            padding: EdgeInsets.zero,
                            margin: EdgeInsets.zero,
                            height: MediaQuery.of(context).size.height * .04,
                            transform: Matrix4.translationValues(0, -14, 0),
                            child: IconButton(
                              icon: Icon(
                                Icons.cancel,
                                color: Colors.grey[600],
                                size: 30,
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
                                  fontSize: 15,
                                  fontFamily: 'Roboto',
                                  color: Colors.blueGrey[800],
                                )),
                            TextSpan(
                                text:
                                    ' will be sent on your phone number ending with',
                                style: TextStyle(
                                  fontSize: 15,
                                  fontFamily: 'Roboto',
                                  color: Colors.blueGrey[800],
                                )),
                            TextSpan(
                                text: ' $last4digits',
                                style: TextStyle(
                                  fontSize: 17,
                                  fontWeight: FontWeight.w800,
                                  color: Colors.blueGrey[800],
                                )),
                          ]),
                    ),
                    verticalSpacer, verticalSpacer,
                    Container(
                      padding: EdgeInsets.all(0),
                      child: PinPut(
                        fieldsCount: 6,
                        onSubmit: (String pin) {
                          //_submitPin(pin, context);

                          //   _pin = pin;
                          print(pin);
                          codeFilled = true;
                          timeLapsed = false;
                          if (mounted) {
                            setState(() {});
                          }
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

                    // (_errorMessage != null
                    //     ? Text(
                    //         _errorMessage,
                    //         textAlign: TextAlign.left,
                    //         style: errorTextStyle,
                    //       )
                    //     : SizedBox(height: 1)),
                    if (Platform.isAndroid)
                      (!timeLapsed)
                          ? Container(
                              padding: EdgeInsets.fromLTRB(0, 12, 0, 12),
                              width: dialogWidth,
                              height: MediaQuery.of(context).size.width * .15,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Container(
                                    width: dialogWidth * .7,
                                    alignment: Alignment.centerLeft,
                                    padding: EdgeInsets.zero,
                                    margin: EdgeInsets.zero,
                                    //width: dialogWidth * .7,
                                    child: AutoSizeText(
                                        "Automatically reading OTP in ",
                                        minFontSize: 13,
                                        maxFontSize: 16,
                                        style: TextStyle(
                                          fontFamily: 'Roboto',
                                          color: Colors.blueGrey[800],
                                        )),
                                  ),
                                  Container(
                                      padding: EdgeInsets.all(0),
                                      margin: EdgeInsets.zero,
                                      alignment: Alignment.bottomLeft,
                                      width: dialogWidth * .1,
                                      height:
                                          MediaQuery.of(context).size.width *
                                              .11,
                                      //  width: 50,
                                      child: CountDownTimer()),
                                  Container(
                                    alignment: Alignment.centerLeft,
                                    padding: EdgeInsets.only(top: 4),
                                    margin: EdgeInsets.zero,
                                    width: dialogWidth * .16,
                                    child: AutoSizeText("seconds. ",
                                        minFontSize: 10,
                                        maxFontSize: 12,
                                        style: TextStyle(
                                          fontFamily: 'Roboto',
                                          color: Colors.blueGrey[800],
                                        )),
                                  ),
                                ],
                              ))
                          : Container(
                              padding: EdgeInsets.fromLTRB(0, 12, 0, 12),
                              width: dialogWidth,
                              height: 80,
                              child: Text(
                                  "Could not read OTP automatically. Click 'Resend' to receive a new OTP.  ",
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontFamily: 'Roboto',
                                    color: Colors.blueGrey[800],
                                  )),
                            ),
                    Divider(
                      color: Colors.blueGrey[400],
                      height: 1,
                      //indent: 40,
                      //endIndent: 30,
                    ),
                    // SizedBox(height: 10),
                    //Divider(),
                  ],
                ),
              ),
              contentPadding: EdgeInsets.all(10),
              actionsPadding: EdgeInsets.symmetric(horizontal: 8),
              actions: <Widget>[
                SizedBox(
                  height: 40,
                  width: dialogWidth * .4,
                  child: MaterialButton(
                    color: Colors.white,
                    textColor: btnColor,
                    shape: RoundedRectangleBorder(
                        side: BorderSide(color: btnColor),
                        borderRadius: BorderRadius.all(Radius.circular(3.0))),
                    child: Text(
                      'Clear',
                      style: TextStyle(fontSize: dialogWidth * .047),
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
                if (timeLapsed)
                  SizedBox(
                    height: 40,
                    width: dialogWidth * .5,
                    child: MaterialButton(
                      color: timeLapsed ? btnColor : Colors.white,
                      textColor: timeLapsed ? Colors.white : btnColor,
                      shape: RoundedRectangleBorder(
                          side: BorderSide(color: btnColor),
                          borderRadius: BorderRadius.all(Radius.circular(3.0))),
                      child: Text(
                        'Resend OTP',
                        style: TextStyle(fontSize: dialogWidth * .047),
                      ),
                      onPressed: () {
                        if (timeLapsed)
                          EventBus.fireEvent(OTP_RESEND_EVENT, null, null);
                        else
                          return;
                      },
                    ),
                  ),
                if (!timeLapsed)
                  SizedBox(
                    width: dialogWidth * .5,
                    height: 40,
                    child: MaterialButton(
                      color: !timeLapsed ? btnColor : Colors.white,
                      textColor: !timeLapsed ? Colors.white : btnColor,
                      shape: RoundedRectangleBorder(
                          side: BorderSide(color: btnColor),
                          borderRadius: BorderRadius.all(Radius.circular(3.0))),
                      child: Text('Approve OTP',
                          style: TextStyle(fontSize: dialogWidth * .047)),
                      onPressed: () {
                        if (!timeLapsed) {
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
                                      builder: (context) => UserHomePage(
                                            dontShowUpdate: false,
                                          )));
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
                                  Navigator.of(context).pop();
                                  Navigator.pushReplacement(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => UserHomePage(
                                                dontShowUpdate: false,
                                              )));
                                }).catchError((onError) {
                                  handleAuthException(onError);

                                  setState(() {});
                                });
                              }
                            }
                          } catch (err) {
                            print("$err.toString()");
                            setState(() {
                              _errorMessage = err.toString();
                            });
                          }
                        } else {
                          return;
                        }
                      },
                    ),
                  ),
              ],
            );
          });
        });
  }

  handleError(FirebaseAuthException error) {
    print(error);
    switch (error.code) {
      case 'ERROR_INVALID_VERIFICATION_CODE':
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
