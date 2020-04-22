import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:noq/dashboard.dart';
import 'pages/alertDialog.dart';
import 'style.dart';
import 'package:noq/constants.dart';
import 'services/authService.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  String _mobile, smsCode;
  String verificationId;
  final formKey = new GlobalKey<FormState>();
  bool codeSent = false;
  bool _autoValidate = false;
  bool isButtonPressed = false;
  //METHODS
  String validateMobile(String value) {
    var potentialNumber = int.tryParse(value);
    if (potentialNumber == null) {
      return 'Enter a phone number';
    } else if ((value.length > 10)) {
      return 'Enter a valid phone number';
    } else if ((value.length < 8)) {
      return 'Enter a valid phone number';
    } else
      return null;
  }

  //UI ELEMENTS
  final headingText = Text(
    loginMainTxt,
    textAlign: TextAlign.left,
    //textDirection: TextDirection.ltr,
    //textWidthBasis: TextWidthBasis.longestLine,
    style: labelTextStyle,
  );
  final loginText = Text(
    loginSubTxt,
    textAlign: TextAlign.left,
    style: subLabelTextStyle,
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Container(
          color: Colors.white,
          margin: new EdgeInsets.all(5.0),
          child: new Form(
            key: formKey,
            autovalidate: _autoValidate,
            child: formUI(context),
          ),
        ),
      ),
    );
  } //widget

  Widget formUI(BuildContext context) {
    final phNumField = TextFormField(
      obscureText: false,
      maxLines: 1,
      minLines: 1,
      style: inputTextStyle,
      inputFormatters: <TextInputFormatter>[
        WhitelistingTextInputFormatter.digitsOnly,
      ],
      keyboardType: TextInputType.phone,
      decoration: InputDecoration(
        labelText: 'Enter 10 digit Mobile Number',
        enabledBorder:
            UnderlineInputBorder(borderSide: BorderSide(color: Colors.grey)),
        focusedBorder: UnderlineInputBorder(
            borderSide: BorderSide(color: Colors.red[400])),
      ),
      validator: validateMobile,
      onChanged: (value) {
        setState(() {
          this._mobile = "+91" + value;
        });
      },
      // onSaved: (value) => _mobile = value,
      //onSubmitted: _phoneNumberValidator,
    );
    final otpNumField = TextFormField(
      obscureText: false,
      maxLines: 1,
      minLines: 1,
      style: inputTextStyle,
      inputFormatters: <TextInputFormatter>[
        WhitelistingTextInputFormatter.digitsOnly,
      ],
      keyboardType: TextInputType.phone,
      decoration: InputDecoration(
        labelText: 'Enter OTP',
        enabledBorder:
            UnderlineInputBorder(borderSide: BorderSide(color: Colors.grey)),
        focusedBorder: UnderlineInputBorder(
            borderSide: BorderSide(color: Colors.red[400])),
      ),
      validator: validateMobile,
      onChanged: (value) {
        setState(() {
          this.smsCode = value;
        });
      },
      // onSaved: (value) => _mobile = value,
      //onSubmitted: _phoneNumberValidator,
    );
    final loginButon = Material(
      elevation: 10.0,
      color: isButtonPressed
          ? Theme.of(context).primaryColor
          : Theme.of(context).accentColor,
      child: MaterialButton(
        minWidth: MediaQuery.of(context).size.width,
        // padding: EdgeInsets.fromLTRB(10.0, 7.5, 10.0, 7.5),
        onPressed: submitForm,
        child: Text(
          "Login with OTP",
          textAlign: TextAlign.center,
          style: buttonTextStyle,
        ),
      ),
    );
    return new Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        SizedBox(
          // height: 155.0,
          child: Image.asset(
            "assets/logo.png",
            fit: BoxFit.contain,
          ),
        ),
        Column(
            //mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[headingText, loginText]),
        SizedBox(height: 30.0),
        phNumField,
        codeSent ? otpNumField : Container(child: Text("")),
        SizedBox(height: 10.0),
        loginButon
      ],
    );
  }

  void submitForm() {
    codeSent
        ? AuthService().signInWithOTP(smsCode, verificationId, context)
        : verifyPhone(_mobile);
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
        print('$authException.message');
      };

      final PhoneCodeSent otpSent = (String verId, [int forceResend]) {
        this.verificationId = verId;
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
      print(e.toString());
    }
  }
}
