import 'package:flutter/material.dart';

final buttonStyle = Material(
  elevation: 5.0,
  //borderRadius: BorderRadius.circular(30.0),
  color: Colors.indigo,
  child: MaterialButton(
    padding: EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
    onPressed: () {},
  ),
);
final buttonTextStyle = TextStyle(
  color: Colors.white,
  //fontWeight: FontWeight.w800,
  fontFamily: 'Montserrat-Regular',
  letterSpacing: 0.5,
  fontSize: 20,
  //height: 2,
);
final buttonSmlTextStyle = TextStyle(
  color: Colors.white,
  //fontWeight: FontWeight.w800,
  fontFamily: 'Montserrat-Regular',

  fontSize: 10,
  //height: 2,
);

final inputTextStyle = TextStyle(
  color: Colors.blueGrey[400],
  //fontWeight: FontWeight.w800,
  fontFamily: 'Montserrat',
  letterSpacing: 0.5,
  fontSize: 18,
  height: 2,
);

final labelTextStyle = TextStyle(
    color: Colors.blueGrey[800],
    letterSpacing: 0.5,
    fontFamily: 'Montserrat',
    fontSize: 10.0);

final errorTextStyle = TextStyle(
    color: Colors.red,
    letterSpacing: 0.5,
    //fontWeight: FontWeight.w500,
    fontFamily: 'Monsterrat',
    fontSize: 15);

final lightSubTextStyle = TextStyle(
  color: Colors.blueGrey,
  // fontWeight: FontWeight.w800,
  fontFamily: 'Monsterrat',
  letterSpacing: 0.5,
  fontSize: 10.0,
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
final Color darkIcon = Colors.indigo;
final Color lightIcon = Colors.indigo;

final Color highlightColor = Colors.amber[600];
final Color unselectedColor = Colors.blueGrey[700];
