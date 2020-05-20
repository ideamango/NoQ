import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

final buttonStyle = Material(
  elevation: 5.0,
  //borderRadius: BorderRadius.circular(30.0),
  color: Colors.teal,
  child: MaterialButton(
    padding: EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
    onPressed: () {},
  ),
);
final transBtnshape =
    RoundedRectangleBorder(side: BorderSide(color: Colors.orange));
final transBtnColor = Colors.transparent;

final buttonTextStyle = TextStyle(
  color: Colors.white,
  //fontWeight: FontWeight.w800,
  fontFamily: 'Montserrat-Regular',
  letterSpacing: 0.5,
  fontSize: 20,
  //height: 2,
);
final whiteBoldTextStyle = TextStyle(
  color: Colors.grey[200],
  // fontWeight: FontWeight.w800,
  fontFamily: 'Montserrat',
  letterSpacing: 0.5,
  fontSize: 20,
  //height: 2,
);
final buttonSmlTextStyle = TextStyle(
  color: Colors.white,
  //fontWeight: FontWeight.w800,
  fontFamily: 'Montserrat',

  fontSize: 12,
  //height: 2,
);

final inputTextStyle = TextStyle(
  color: Colors.blueGrey[400],
  //fontWeight: FontWeight.w800,
  fontFamily: 'Montserrat',
  letterSpacing: 0.5,
  fontSize: 16,
  height: 2,
);

final labelTextStyle = TextStyle(
    color: Colors.blueGrey,
    letterSpacing: 0.5,
    fontFamily: 'Roboto-Bold',
    fontSize: 11.0);

final errorTextStyle = TextStyle(
    color: Colors.red,
    letterSpacing: 0.5,
    //fontWeight: FontWeight.w500,
    fontFamily: 'Roboto',
    fontSize: 12);

final lightSubTextStyle = TextStyle(
  color: Colors.blueGrey[700],
  // fontWeight: FontWeight.w800,
  fontFamily: 'Monsterrat',
  letterSpacing: 0.5,
  fontSize: 11.0,
  //height: 2,
);
final textInputTextStyle = TextStyle(
  color: Colors.blueGrey[700],
  // fontWeight: FontWeight.w800,
  fontFamily: 'Monsterrat',
  letterSpacing: 0.5,
  fontSize: 15.0,
  //height: 2,
);
final infoTextStyle = TextStyle(
  color: Colors.blueGrey[700],
  // fontWeight: FontWeight.w800,
  fontFamily: 'Roboto',
  letterSpacing: 0.5,
  fontSize: 8.0,
  //height: 2,
);
final hintTextStyle = TextStyle(
    color: Colors.blueGrey[300], fontFamily: 'Montserrat', fontSize: 20.0);

final subHeadingTextStyle = TextStyle(
    color: Colors.blueGrey[300], fontFamily: 'Montserrat', fontSize: 12.0);

final headingTextStyle = TextStyle(
    color: Colors.blueGrey[800],
    letterSpacing: 0.5,
    fontFamily: 'Montserrat',
    fontSize: 15.0);
final Color tealIcon = Colors.teal;

final Color lightIcon = Colors.indigo;
final Color highlightText = Colors.teal;
final highlightSubTextStyle = TextStyle(
    color: Colors.blueGrey[800], fontFamily: 'Montserrat', fontSize: 12.0);

final tokenTextStyle = TextStyle(
    color: Colors.black,
    fontWeight: FontWeight.w600,
    fontFamily: 'Montserrat',
    letterSpacing: 3,
    // decoration: TextDecoration.underline,
    fontSize: 25.0);

final tokenDataTextStyle = TextStyle(
    color: Colors.blueGrey[300],
    //fontWeight: FontWeight.w500,
    fontFamily: 'Montserrat',
    fontSize: 14.0);
final tokenDateTextStyle = TextStyle(
    color: Colors.blueGrey[300],
    fontWeight: FontWeight.w500,
    fontFamily: 'Montserrat',
    fontSize: 18.0);
final homeMsgStyle = TextStyle(
    color: Colors.blueGrey[800], fontFamily: 'Montserrat', fontSize: 11.0);
final homeMsgStyle2 =
    TextStyle(color: Colors.teal, fontFamily: 'Roboto', fontSize: 18.0);
final homeMsgStyle3 =
    TextStyle(color: highlightColor, fontFamily: 'Montserrat', fontSize: 20.0);

final highlightTextStyle =
    TextStyle(color: Colors.teal, fontFamily: 'Montserrat', fontSize: 20.0);

final Color highlightColor = Colors.amber[600];
final Color unselectedColor = Colors.blueGrey[700];

class CommonStyle {
  static InputDecoration textFieldStyle(
      {String labelTextStr = "", String hintTextStr = ""}) {
    return InputDecoration(
      //contentPadding: EdgeInsets.all(12),
      labelText: labelTextStr,
      hintText: hintTextStr,
      enabledBorder:
          UnderlineInputBorder(borderSide: BorderSide(color: Colors.grey)),
      focusedBorder:
          UnderlineInputBorder(borderSide: BorderSide(color: Colors.orange)),
    );
  }
}
