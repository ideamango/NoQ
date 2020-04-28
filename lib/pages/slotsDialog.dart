import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:noq/models/slot.dart';
import 'package:pinput/pin_put/pin_put.dart';
import 'package:noq/style.dart';
import 'package:noq/services/authService.dart';

final TextEditingController _pinPutController = TextEditingController();
final FocusNode _pinPutFocusNode = FocusNode();
String _pin;
String status;
String _errorMessage;
List slots = new List();

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

Future<bool> showSlotsDialog(
    BuildContext context, int storeId, DateTime dateTime) {
  dateTime = DateTime.fromMicrosecondsSinceEpoch(10000);
  slots.add('9:00am');
  slots.add('9:30am');
  slots.add('10:00am');
  slots.add('10:30am');
  slots.add('11:00am');
  slots.add('11:30am');
  slots.add('12:00pm');
  slots.add('12:30pm');
  slots.add('1:00pm');

  return showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return new AlertDialog(
          title: Text('Slots for date $dateTime',
              style: TextStyle(
                fontSize: 20,
                color: Colors.grey,
              )),
          backgroundColor: Colors.grey[200],
          titleTextStyle: inputTextStyle,
          elevation: 10.0,
          content: new Container(
            // Specify some width
            width: MediaQuery.of(context).size.width * .7,
            child: GridView.builder(
              itemCount: slots.length,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 4,
                  crossAxisSpacing: 4.0,
                  mainAxisSpacing: 4.0),
              itemBuilder: (BuildContext context, int index) {
                return Text('$slots[index]');
              },
            ),
          ),

          // SizedBox(height: 10),

          actions: <Widget>[
            FlatButton(
              color: Colors.orange,
              textColor: Colors.white,
              child: Text('Clear All'),
              onPressed: () => status = 'OnPress',
            ),
            FlatButton(
              color: Colors.orange,
              textColor: Colors.white,
              child: Text('Submit'),
              onPressed: () {
                // print("OTP Submitted");
                // //  print('$_pinPutController.text');
                // try {
                //   FirebaseAuth.instance.currentUser().then((user) {
                //     if (user != null) {
                //       Navigator.of(context).pop();
                //       Navigator.of(context).pushReplacementNamed('/dashboard');
                //     } else {
                //       AuthService()
                //           .signInWithOTP(_pin, verificationId, context)
                //           .then(() {
                //         //Navigator.of(context).pop();
                //         Navigator.of(context)
                //             .pushReplacementNamed('/landingPage');
                //       });
                //     }
                //   });
                // } catch (err) {
                //   print("$err.toString()");
                //   _errorMessage = err.toString();
                // }

                // //     : verifyPhone(_mobile);
                // //if success proceed to next screen
                // // Navigator.of(context).pop();
                // // Navigator.of(context).pushReplacementNamed('/landingPage');
                // //else go back to signin page
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
