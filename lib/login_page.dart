import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:noq/pages/otpdialog.dart';
import 'package:noq/pages/terms_of_use.dart';
import 'package:noq/utils.dart';
import 'package:noq/widget/widgets.dart';
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
    try {
      final PhoneVerificationCompleted phoneVerified =
          (AuthCredential authResult) {
        AuthService().signIn(authResult, context);
      };

      final PhoneVerificationFailed verificationFailed =
          (AuthException authException) {
        setState(() {
          _errorMsg = '${authException.message}';

          print("Error message: " + _errorMsg);
          if (authException.message.contains('not authorized'))
            _errorMsg = 'Something has gone wrong, please try later';
          else if (authException.message.contains('Network'))
            _errorMsg = 'Please check your internet connection and try again';
          else
            _errorMsg = 'Something has gone wrong, please try later';
        });
        //handleError(authException);
      };

      final PhoneCodeSent otpSent = (String verId, [int forceResend]) {
        this.verificationId = verId;
        print("before dialog callhbksdjfhskjfyhewroiuytfewqorhy");
        showDialogForOtp(verId);
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
      };

      await FirebaseAuth.instance.verifyPhoneNumber(
          phoneNumber: phoneNo,
          timeout: const Duration(seconds: 5),
          verificationCompleted: phoneVerified,
          verificationFailed: verificationFailed,
          codeSent: otpSent,
          codeAutoRetrievalTimeout: autoTimeout);
    } catch (e) {
      setState(() {
        _errorMsg = "Invalid phone number.";
      });
      print(e.toString());
      handleError(e);
    }
  }

  showDialogForOtp(String verId) async {
    await showDialog(
        context: context,
        barrierDismissible: true,
        builder: (BuildContext context) {
          return StatefulBuilder(builder: (context, setState) {
            return OTPDialog(verificationId: verId, phoneNo: _mobile);
          });
        });
  }

  handleError(AuthException error) {
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
