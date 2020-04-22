// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// //Custom classes
// import 'userDashboard.dart';
// import 'style.dart';
// import 'constants.dart';
// //FireBase Authentication for phone numbers
// import 'package:firebase_auth/firebase_auth.dart';
// //Country code dropdown
// //import 'package:country_pickers/country_pickers.dart';
// //import 'package:country_pickers/country.dart';
// // import 'package:pin_input_text_field/pin_input_text_field.dart';
// // import 'package:sms_autofill/sms_autofill.dart';

// void main() => runApp(MyApp());

// class MyApp extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return FutureBuilder<FirebaseUser>(
//         future: FirebaseAuth.instance.currentUser(),
//         builder: (BuildContext context, AsyncSnapshot<FirebaseUser> snapshot) {
//     if (snapshot.hasData) {
//       FirebaseUser user = snapshot.data; // this is your user instance
//       /// is because there is user already logged
//       return UserDashboard();
//     }

//     /// other way there is no user logged.
//     return MaterialApp(
//       title: 'Awesome Noqueue',
//       routes: <String, WidgetBuilder>{
//         '/dashboard': (BuildContext context) => UserDashboard(),
//         '/loginpage': (BuildContext context) => MyApp(),
//       },
//       theme: ThemeData(
//         brightness: Brightness.light,
//         primaryColor: Colors.orange,
//         accentColor: Colors.orangeAccent,
//         // Define the default font family..
//         //fontFamily: 'Monsterrat',
//         // Define the default TextTheme. Use this to specify the default
//         // text styling for headlines, titles, bodies of text, and more.
//         textTheme: TextTheme(
//           headline: TextStyle(fontSize: 72.0, fontWeight: FontWeight.bold),
//           title: TextStyle(fontSize: 36.0, fontStyle: FontStyle.italic),
//           body1: TextStyle(fontSize: 14.0, fontFamily: 'Hind'),
//         ),
//       ),
//       home: LoginPage(title: 'No Queue Login Page'),
//     );
//   }

//   // return MaterialApp(
//   //   title: 'Awesome Noqueue',
//   //   routes: <String, WidgetBuilder>{
//   //     '/dashboard': (BuildContext context) => UserDashboard(),
//   //     '/loginpage': (BuildContext context) => MyApp(),
//   //   },
//   //   theme: ThemeData(
//   //     brightness: Brightness.light,
//   //     primaryColor: Colors.orange,
//   //     accentColor: Colors.orangeAccent,
//   //     // Define the default font family..
//   //     //fontFamily: 'Monsterrat',
//   //     // Define the default TextTheme. Use this to specify the default
//   //     // text styling for headlines, titles, bodies of text, and more.
//   //     textTheme: TextTheme(
//   //       headline: TextStyle(fontSize: 72.0, fontWeight: FontWeight.bold),
//   //       title: TextStyle(fontSize: 36.0, fontStyle: FontStyle.italic),
//   //       body1: TextStyle(fontSize: 14.0, fontFamily: 'Hind'),
//   //     ),
//   //   ),
//   //   home: LoginPage(title: 'No Queue Login Page'),
//   // );
// }

// class LoginPage extends StatefulWidget {
//   LoginPage({Key key, this.title}) : super(key: key);
//   final String title;
//   @override
//   _LoginPageState createState() => _LoginPageState();
// }

// class _LoginPageState extends State<LoginPage> {
//   //FIELDS
//   // Country _selectedDialogCountry =
//   //     CountryPickerUtils.getCountryByPhoneCode('91');
//   final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

//   String errorMessage = '';
//   bool isButtonPressed = false;
//   bool _autoValidate = false;
//   String _mobile;

//   AuthCredential _phoneAuthCredential;
//   FirebaseAuth _auth = FirebaseAuth.instance;
//   FirebaseUser _firebaseUser;
//   String _status;
//   String phoneNo;
//   String smsOTP;
//   String verificationId;

//   //METHODS

//   @override
//   void initState() {
//     super.initState();
//     _getFirebaseUser();
//   }

//   Future<void> _getFirebaseUser() async {
//     this._firebaseUser = await FirebaseAuth.instance.currentUser();
//     setState(() {
//       _status =
//           (_firebaseUser == null) ? 'Not Logged In\n' : 'Already LoggedIn\n';
//       print(_status);
//     });
//   }

//   Future<void> verifyPhone() async {
//     final PhoneCodeSent smsOTPSent = (String verId, [int forceCodeResend]) {
//       this.verificationId = verId;
//       smsOTPDialog(context).then((value) {
//         print('sign in');
//       });
//     };
//     try {
//       await _auth.verifyPhoneNumber(
//           phoneNumber: "+91" +
//               // this._selectedDialogCountry.phoneCode +
//               this.phoneNo, // PHONE NUMBER TO SEND OTP
//           codeAutoRetrievalTimeout: (String verId) {
//             //Starts the phone number verification process for the given phone number.
//             //Either sends an SMS with a 6 digit code to the phone number specified, or sign's the user in and [verificationCompleted] is called.
//             this.verificationId = verId;
//           },
//           codeSent:
//               smsOTPSent, // WHEN CODE SENT THEN WE OPEN DIALOG TO ENTER OTP.
//           timeout: const Duration(seconds: 20),
//           verificationCompleted: (AuthCredential phoneAuthCredential) {
//             this._phoneAuthCredential = phoneAuthCredential;
//             setState(() {
//               _status += 'verificationCompleted\n';
//             });
//             Navigator.push(context,
//                 MaterialPageRoute(builder: (context) => UserDashboard()));
//             print(phoneAuthCredential);
//           },
//           verificationFailed: (AuthException exceptio) {
//             print('${exceptio.message}');
//           });
//     } catch (e) {
//       handleError(e);
//     }
//   }

//   Future<bool> smsOTPDialog(BuildContext context) {
//     return showDialog(
//         context: context,
//         barrierDismissible: false,
//         builder: (BuildContext context) {
//           return new AlertDialog(
//             title: Text('Enter OTP'),
//             backgroundColor: Colors.grey[200],
//             titleTextStyle: inputTextStyle,
//             elevation: 10.0,
//             content: Container(
//               height: 65,
//               child: Column(children: [
//                 //Start for SMS
//                 // PinFieldAutoFill(
//                 //     decoration: UnderlineDecoration(
//                 //         textStyle: TextStyle(
//                 //             decorationStyle: TextDecorationStyle.dashed,
//                 //             fontSize: 20,
//                 //             color: Colors.blueGrey),
//                 //         color: Colors.blueGrey,
//                 //         enteredColor: Colors.orange),
//                 //     currentCode: _code),
//                 Spacer(),
//                 // RaisedButton(
//                 //   child: Text('Listen for sms code'),
//                 //   onPressed: () async {
//                 //     await SmsAutoFill().listenForCode;
//                 //   },
//                 // ),
//                 //End for SMS
//                 TextField(
//                   onChanged: (value) {
//                     this.smsOTP = value;
//                   },
//                 ),
//                 (errorMessage != ''
//                     ? Text(
//                         errorMessage,
//                         style: TextStyle(color: Colors.red),
//                       )
//                     : Container())
//               ]),
//             ),
//             contentPadding: EdgeInsets.all(10),
//             actions: <Widget>[
//               FlatButton(
//                 child: Text('Done'),
//                 onPressed: () {
//                   _auth.currentUser().then((user) {
//                     if (user != null) {
//                       Navigator.of(context).pop();
//                       Navigator.of(context).pushReplacementNamed('/dashboard');
//                     } else {
//                       signIn();
//                     }
//                   });
//                 },
//               )
//             ],
//           );
//         });
//   }

//   signIn() async {
//     try {
//       final AuthCredential credential = PhoneAuthProvider.getCredential(
//         verificationId: verificationId,
//         smsCode: smsOTP,
//       );
//       //   final FirebaseUser user =
//       //       await _auth.signInWithCredential(credential);

//       FirebaseUser currentUser = await _auth.currentUser();
//       //   assert(user.uid == currentUser.uid);
//       await FirebaseAuth.instance
//           .signInWithCredential(credential)
//           .then((AuthResult authRes) {
//         currentUser = authRes.user;
//         print(currentUser.toString());
//       });
//       setState(() {
//         _status += 'Signed In\n';
//       });
//       Navigator.of(context).pop();
//       Navigator.of(context).pushReplacementNamed('/dashboard');
//     } catch (e) {
//       setState(() {
//         _status += e.toString() + '\n';
//       });
//       handleError(e);
//     }
//   }

//   handleError(PlatformException error) {
//     print(error);
//     switch (error.code) {
//       case 'ERROR_INVALID_VERIFICATION_CODE':
//         FocusScope.of(context).requestFocus(new FocusNode());
//         setState(() {
//           errorMessage = 'Invalid Code';
//         });
//         Navigator.of(context).pop();
//         smsOTPDialog(context).then((value) {
//           print('sign in');
//         });
//         break;
//       default:
//         setState(() {
//           errorMessage = error.message;
//         });

//         break;
//     }
//   }

//   String validateMobile(String value) {
//     var potentialNumber = int.tryParse(value);
//     if (potentialNumber == null) {
//       return 'Enter a phone number';
//     }
//     //TODO: Add logic for international phone numbers.
//     else if ((value.length > 10)) {
//       return 'Enter a valid phone number';
//     } else if ((value.length < 8)) {
//       return 'Enter a valid phone number';
//     } else
//       return null;

//     //Pattern pattern = "9611009823";
//     //Pattern pattern = "^((\+){1}91){1}[1-9]{1}[0-9]{9}\$";
//     // RegExp regex = new RegExp(pattern);
//     // if (!regex.hasMatch(value))
//     //   return 'Phone number is not valid';
//     // else
//     //   return null;
//   }

//   //UI ELEMENTS
//   final headingText = Text(
//     loginMainTxt,
//     textAlign: TextAlign.left,
//     //textDirection: TextDirection.ltr,
//     //textWidthBasis: TextWidthBasis.longestLine,
//     style: labelTextStyle,
//   );
//   final loginText = Text(
//     loginSubTxt,
//     textAlign: TextAlign.left,
//     style: subLabelTextStyle,
//   );

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: Center(
//         child: Container(
//           color: Colors.white,
//           margin: new EdgeInsets.all(15.0),
//           child: new Form(
//             key: _formKey,
//             autovalidate: _autoValidate,
//             child: formUI(context),
//           ),
//         ),
//       ),
//     );
//   } //widget

//   Widget formUI(BuildContext context) {
//     final phNumField = Row(children: <Widget>[
//       // Container(
//       //   child: CountryPickerDropdown(
//       //     initialValue: 'is',
//       //     itemBuilder: _buildDropdownCountryCode,
//       //     onValuePicked: (Country country) {
//       //       print("${country.name}");
//       //     },
//       //   ),
//       // ),
//       Expanded(
//           child: TextFormField(
//         obscureText: false,
//         maxLines: 1,
//         minLines: 1,
//         style: inputTextStyle,
//         inputFormatters: <TextInputFormatter>[
//           WhitelistingTextInputFormatter.digitsOnly,
//         ],
//         keyboardType: TextInputType.phone,

//         decoration: InputDecoration(
//           labelText: 'Enter Phone Number',
//           enabledBorder:
//               UnderlineInputBorder(borderSide: BorderSide(color: Colors.grey)),
//           focusedBorder: UnderlineInputBorder(
//               borderSide: BorderSide(color: Colors.red[400])),
//           //border: InputBorder.none,
//           //contentPadding: EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
//           //hintStyle: hintTextStyle,
//           //hintText: "Phone Number",
//           //border:OutlineInputBorder(borderRadius: BorderRadius.circular(32.0)
//         ),
//         onChanged: (value) {
//           this.phoneNo = value;
//         },
//         validator: validateMobile,
//         onSaved: (value) => _mobile = value,
//         //onSubmitted: _phoneNumberValidator,
//       ))
//     ]);

//     final loginButon = Material(
//       elevation: 10.0,
//       //borderRadius: BorderRadius.circular(30.0),
//       color: isButtonPressed
//           ? Theme.of(context).primaryColor
//           : Theme.of(context).accentColor,

//       child: MaterialButton(
//         minWidth: MediaQuery.of(context).size.width,
//         // padding: EdgeInsets.fromLTRB(10.0, 7.5, 10.0, 7.5),
//         onPressed: () {
//           // if (this.phoneNo != "9611009823") {
//           verifyPhone();
//           // }
//           if (_formKey.currentState.validate()) {
//             // If the form is valid, display a snackbar. In the real world,
//             // you'd often call a server or save the information in a database.
//             _formKey.currentState.save();
//             // Scaffold.of(context)
//             //     .showSnackBar(SnackBar(content: Text('Processing Data')));
//             // Navigator.push(context,
//             //     MaterialPageRoute(builder: (context) => UserDashboard()));
//           } else {
//             setState(() {
//               _autoValidate = true;
//             });
//           }
//         },
//         child: Text(
//           "Login with OTP",
//           textAlign: TextAlign.center,
//           style: buttonTextStyle,
//         ),
//       ),
//     );

//     return new Column(
//       mainAxisAlignment: MainAxisAlignment.center,
//       children: <Widget>[
//         SizedBox(
//           height: 155.0,
//           child: Image.asset(
//             "assets/logo.png",
//             fit: BoxFit.contain,
//           ),
//         ),
//         Column(
//             //mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: <Widget>[headingText, loginText]),
//         SizedBox(height: 30.0),
//         phNumField,
//         SizedBox(height: 10.0),
//         loginButon
//       ],
//     );
//   }

//   // Widget _buildDropdownCountryCode(Country country) => Container(
//   //       child: Row(
//   //         children: <Widget>[
//   //           CountryPickerUtils.getDefaultFlagImage(country),
//   //           DefaultTextStyle.merge(
//   //               child: Text("(${country.isoCode}) +${country.phoneCode}")),
//   //         ],
//   //       ),
//   //     );

//   void _validateInputs() {
//     if (_formKey.currentState.validate()) {
// //    If all data are correct then save data to out variables
//       _formKey.currentState.save();
//     } else {
// //    If all data are not valid then start auto validation.
//       setState(() {
//         _autoValidate = true;
//       });
//     }
//   }
// }
