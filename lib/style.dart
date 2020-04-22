import 'package:flutter/material.dart';

final buttonTextStyle = TextStyle(
  color: Colors.white,
  //fontWeight: FontWeight.w800,
  fontFamily: 'Montserrat-Regular',
  letterSpacing: 0.5,
  fontSize: 20,
  //height: 2,
);
final buttonStyle = Material(
  elevation: 5.0,
  //borderRadius: BorderRadius.circular(30.0),
  color: Colors.orange,
  child: MaterialButton(
    padding: EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
    onPressed: () {},
  ),
);
final descTextStyle = TextStyle(
  color: Colors.blueGrey[300],
  fontWeight: FontWeight.w800,
  fontFamily: 'Montserrat-Regular',
  letterSpacing: 0.5,
  fontSize: 18,
  height: 2,
);
final inputTextStyle = TextStyle(
  color: Colors.blueGrey[300],
  //fontWeight: FontWeight.w800,
  fontFamily: 'Montserrat',
  letterSpacing: 0.5,
  fontSize: 18,
  height: 2,
);
final labelTextStyle = TextStyle(
    color: Colors.black,
    letterSpacing: 0.5,
    fontFamily: 'Montserrat',
    fontSize: 10.0);

// final labelTextStyle = TextStyle(
//   color: Colors.black,
//   //fontWeight: FontWeight.w800,
//   fontFamily: 'Monsterrat',

//   fontSize: 10,
//   //height: 2,
// );

final lightSubTextStyle = TextStyle(
  color: Colors.blueGrey,
  // fontWeight: FontWeight.w800,
  fontFamily: 'Monsterrat',
  letterSpacing: 0.5,
  fontSize: 10,
  //height: 2,
);
final hintTextStyle = TextStyle(
    color: Colors.blueGrey[300], fontFamily: 'Montserrat', fontSize: 20.0);

final subLabelTextStyle = TextStyle(
    color: Colors.blueGrey[300], fontFamily: 'Montserrat', fontSize: 14.0);

final headingStyle = TextStyle();
final subHeadingStyle = TextStyle();
