// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:noq/services/authService.dart';
// import 'package:noq/style.dart';
// import 'package:noq/widget/widgets.dart';
// import 'package:pinput/pin_put/pin_put.dart';

// class OTPDialog extends StatefulWidget {
//   final String verificationId;
//   final String phoneNo;
//   OTPDialog({Key key, @required this.verificationId, @required this.phoneNo})
//       : super(key: key);
//   @override
//   _OTPDialogState createState() => _OTPDialogState();
// }

// class _OTPDialogState extends State<OTPDialog> {
//   String verId;
//   final TextEditingController _pinPutController = TextEditingController();
//   final FocusNode _pinPutFocusNode = FocusNode();
//   String _pin;
//   String _errorMessage;
//   String _phoneNo;

//   BoxDecoration get _pinPutDecoration {
//     return BoxDecoration(
//       border: Border.all(color: highlightColor),
//       //borderRadius: BorderRadius.circular(15),
//     );
//   }

//   @override
//   void initState() {
//     super.initState();
//     _phoneNo = widget.phoneNo;
//     verId = widget.verificationId;
//   }

//   void resendVerificationCode(String phoneNumber, var token) {
//     final PhoneVerificationCompleted phoneVerified =
//         (AuthCredential authResult) {
//       AuthService().signIn(authResult, context);
//     };

//     final PhoneVerificationFailed verificationFailed =
//         (FirebaseAuthException authException) {};

//     final PhoneCodeSent otpSent = (String verId, [int forceResend]) {
//       this.verId = verId;
//     };

//     final PhoneCodeAutoRetrievalTimeout autoTimeout = (String verId) {
//       this.verId = verId;
//     };

//     FirebaseAuth.instance.verifyPhoneNumber(
//         phoneNumber: _phoneNo,
//         timeout: const Duration(seconds: 60),
//         verificationCompleted: phoneVerified,
//         verificationFailed: verificationFailed,
//         codeSent: otpSent,
//         codeAutoRetrievalTimeout: autoTimeout,
//         forceResendingToken: token);
//   }

//   void _submitPin(String pin, BuildContext context) {
//     _pin = pin;
//     print(_pin);
//     try {
//       User user = FirebaseAuth.instance.currentUser;
//       if (user != null) {
//         Navigator.of(context).pop();
//         Navigator.of(context).pushReplacementNamed('/dashboard');
//       } else {
//         if (_pin == null || _pin == "") {
//           setState(() {
//             _errorMessage = "Enter 6 digit otp sent on your phone.";
//           });
//         } else {
//           AuthCredential authCreds = PhoneAuthProvider.credential(
//               verificationId: verId, smsCode: _pin);
//           FirebaseAuth.instance
//               .signInWithCredential(authCreds)
//               .then((UserCredential authResult) {
//             // AuthService()
//             //     .signInWithOTP(_pin, verificationId, context)
//             // .then(() {
//             print("inside then");
//             Navigator.of(context).pop();
//             Navigator.of(context).pushReplacementNamed('/dashboard');
//           }).catchError((onError) {
//             print("printing Errorrrrrrrrrr in OTP dialog");
//             // print(onError.toString());
//             handleError(onError);
//           });
//         }
//       }
//     } catch (err) {
//       print("$err.toString()");
//       _errorMessage = err.toString();
//     }
//   }

//   handleError(PlatformException error) {
//     print(error);
//     switch (error.code) {
//       case 'ERROR_INVALID_VERIFICATION_CODE':
//         // FocusScope.of(context).requestFocus(new FocusNode());
//         setState(() {
//           _errorMessage = 'Please enter a valid OTP code';
//         });

//         print(_errorMessage);

//         break;
//       case 'firebaseAuth':
//         _errorMessage = 'Please enter a valid Phone number';
//         print(_errorMessage);

//         break;
//       default:
//         _errorMessage = 'Oops, something went wrong. Try again.';
//         print(_errorMessage);

//         break;
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     String last4digits = _phoneNo.substring(_phoneNo.length - 4);
//     // return showDialog(
//     //     context: context,
//     //     barrierDismissible: false,
//     //     builder: (BuildContext context) {
//     return new AlertDialog(
//       // title:
//       backgroundColor: Colors.grey[200],
//       titleTextStyle: inputTextStyle,
//       elevation: 10.0,
//       contentTextStyle: TextStyle(color: primaryDarkColor),
//       content: Container(
//         height: MediaQuery.of(context).size.height * .2,
//         child: Column(
//           mainAxisSize: MainAxisSize.max,
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: <Widget>[
//             // Text('OTP',
//             //     style: TextStyle(
//             //       fontSize: 20,
//             //       color: Colors.blueGrey[600],
//             //     )),
//             verticalSpacer,
//             RichText(
//               text: TextSpan(style: highlightSubTextStyle, children: <TextSpan>[
//                 TextSpan(
//                     text: 'OTP',
//                     style: TextStyle(
//                       fontSize: 14,
//                       fontWeight: FontWeight.w800,
//                       color: Colors.blueGrey[500],
//                     )),
//                 TextSpan(
//                     text:
//                         ' is sent on your phone number ending with $last4digits',
//                     style: TextStyle(
//                       fontSize: 12,
//                       color: Colors.blueGrey[500],
//                     )),
//               ]),
//             ),
//             SizedBox(
//               height: 10,
//             ),
//             Container(
//               //color: Colors.black,
//               //margin: EdgeInsets.all(5),
//               // padding: EdgeInsets.all(0),
//               child: PinPut(
//                 fieldsCount: 6,
//                 onSubmit: (String pin) => _submitPin(pin, context),
//                 focusNode: _pinPutFocusNode,
//                 controller: _pinPutController,
//                 submittedFieldDecoration: _pinPutDecoration.copyWith(
//                     borderRadius: BorderRadius.circular(10)),
//                 selectedFieldDecoration: _pinPutDecoration,
//                 followingFieldDecoration: _pinPutDecoration.copyWith(
//                   borderRadius: BorderRadius.circular(5),
//                   border: Border.all(
//                     color: btnColor,
//                   ),
//                 ),
//               ),
//             ),
//             Divider(
//               color: Colors.blueGrey[400],
//               height: 1,
//               //indent: 40,
//               //endIndent: 30,
//             ),
//             (_errorMessage != null
//                 ? Text(
//                     _errorMessage,
//                     textAlign: TextAlign.left,
//                     style: errorTextStyle,
//                   )
//                 : SizedBox(height: 1)),
//             // SizedBox(height: 10),
//             //Divider(),
//           ],
//         ),
//       ),
//       // titlePadding: EdgeInsets.fromLTRB(5, 10, 0, 0),
//       contentPadding: EdgeInsets.all(8),
//       actionsPadding: EdgeInsets.all(0),
//       actions: <Widget>[
//         SizedBox(
//           height: 30,
//           width: MediaQuery.of(context).size.width * .3,
//           child: FlatButton(
//             color: Colors.transparent,
//             textColor: btnColor,
//             shape: RoundedRectangleBorder(
//                 side: BorderSide(color: btnColor),
//                 borderRadius: BorderRadius.all(Radius.circular(3.0))),
//             child: Text(
//               'Clear All',
//               style: TextStyle(fontSize: 11),
//             ),
//             onPressed: () {
//               setState(() {
//                 _errorMessage = null;
//               });
//               _pinPutController.text = '';
//             },
//           ),
//         ),
//         Container(
//           height: 30,
//           width: MediaQuery.of(context).size.width * .3,
//           alignment: Alignment.center,
//           child: FlatButton(
//             color: Colors.transparent,
//             textColor: btnColor,
//             shape: RoundedRectangleBorder(
//                 side: BorderSide(color: btnColor),
//                 borderRadius: BorderRadius.all(Radius.circular(3.0))),
//             child: Text(
//               'Resend OTP',
//               style: TextStyle(fontSize: 11),
//             ),
//             onPressed: () {
//               //TODO SMITA add code for resend
//               resendVerificationCode(_phoneNo, verId);
//             },
//           ),
//         ),
//         SizedBox(
//           height: MediaQuery.of(context).size.width * .13,
//           width: MediaQuery.of(context).size.width * .3,
//           child: RaisedButton(
//             color: btnColor,
//             textColor: Colors.white,
//             shape: RoundedRectangleBorder(
//                 side: BorderSide(color: btnColor),
//                 borderRadius: BorderRadius.all(Radius.circular(3.0))),
//             child: Text('Submit', style: TextStyle(fontSize: 11)),
//             onPressed: () {
//               print(_pinPutController.text);
//               _submitPin(_pinPutController.text, context);
//             },
//           ),
//         ),
//       ],
//     );
//     // });
//   }
// }
