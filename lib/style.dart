import 'package:flutter/material.dart';

final buttonStyle = Material(
  elevation: 5.0,
  //borderRadius: BorderRadius.circular(30.0),
  color: Colors.blueGrey[800],
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
  fontFamily: 'Montserrat',
  letterSpacing: 0.5,
  fontSize: 20,
  //height: 2,
);
final whiteBoldTextStyle1 = TextStyle(
  color: Colors.grey[200],
  // fontWeight: FontWeight.w800,
  fontFamily: 'Roboto',
  letterSpacing: 0.5,
  fontSize: 20,
);

final drawerdefaultTextStyle = TextStyle(
  color: Colors.grey[100],
  //fontWeight: FontWeight.w800,
  fontFamily: 'Montserrat',
  // letterSpacing: 0.6,
  fontSize: 15,
  //height: 2,
);

final highlightBoldTextStyle = TextStyle(
  color: highlightColor,
  fontWeight: FontWeight.w800,
  fontFamily: 'Roboto',
  letterSpacing: 0.5,
  fontSize: 25,
  //height: 2,
);
final highlightMedBoldTextStyle = TextStyle(
  color: highlightColor,
  fontWeight: FontWeight.w800,
  fontFamily: 'Montserrat',
  letterSpacing: 0.5,
  fontSize: 18,
  //height: 2,
);

final faqTabTextStyle = TextStyle(
  color: Colors.grey[100],
  fontFamily: 'Roboto',
  fontSize: 16,
);
final buttonMedTextStyle = TextStyle(
  color: Colors.white,
  fontWeight: FontWeight.w500,
  fontFamily: 'Montserrat',
  letterSpacing: 1.3,

  fontSize: 17,
  //height: 2,
);
final buttonSmlTextStyle = TextStyle(
  color: Colors.white,
  fontWeight: FontWeight.w700,
  fontFamily: 'Montserrat',

  fontSize: 12,
  //height: 2,
);
final buttonXSmlTextStyle = TextStyle(
  color: Colors.white,
  //fontWeight: FontWeight.w800,
  fontFamily: 'Montserrat',

  fontSize: 10,
  //height: 2,
);
final lightInputTextStyle = TextStyle(
  color: Colors.blueGrey[50],
  //fontWeight: FontWeight.w800,
  fontFamily: 'Montserrat',
  letterSpacing: 0.5,
  fontSize: 16,
  height: 2,
);

final inputTextStyle = TextStyle(
  color: Colors.blueGrey[400],
  //fontWeight: FontWeight.w800,
  fontFamily: 'Montserrat',
  letterSpacing: 0.5,
  fontSize: 16,
  height: 2,
);
final fieldLabelTextStyle = TextStyle(
  color: Colors.grey[700],
  fontSize: 16,
);
final lightLabelTextStyle = TextStyle(
    color: Colors.blueGrey[50],
    letterSpacing: 0.5,
    fontFamily: 'Roboto-Bold',
    fontSize: 15.0);

final labelTextStyle = TextStyle(
    color: Colors.blueGrey,
    letterSpacing: 0.5,
    fontFamily: 'Roboto-Bold',
    fontSize: 11.0);

final errorTextStyle = TextStyle(
    color: Colors.red[400],
    letterSpacing: 0.5,
    //fontWeight: FontWeight.w500,
    fontFamily: 'Monsterrat',
    fontSize: 11);
final errorTextStyleWithUnderLine = TextStyle(
    color: Colors.red[400],
    letterSpacing: 0.5,
    //fontWeight: FontWeight.w500,
    fontFamily: 'Monsterrat',
    decoration: TextDecoration.underline,
    fontSize: 11);

final offerClearTextStyleWithUnderLine = TextStyle(
    color: Colors.white,
    letterSpacing: 0.5,
    //fontWeight: FontWeight.w500,
    fontFamily: 'Monsterrat',
    decoration: TextDecoration.underline,
    fontSize: 14);

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
final textBotSheetTextStyle = TextStyle(
  color: Colors.blueGrey[700],
  // fontWeight: FontWeight.w800,
  fontFamily: 'Monsterrat',
  letterSpacing: 0.5,
  fontSize: 10.0,
  //height: 2,
);
final textLabelTextStyle = TextStyle(
  color: Colors.blueGrey[900],
  // fontWeight: FontWeight.w800,
  fontFamily: 'RalewayRegular',
  letterSpacing: 0.5,
  fontSize: 15.0,
  //height: 2,
);
final labelSmlTextStyle = TextStyle(
  color: Colors.blueGrey[800],
  // fontWeight: FontWeight.w800,
  fontFamily: 'Monsterrat',
  letterSpacing: 0.5,
  fontSize: 13.0,
  //height: 2,
);
final labelXSmlTextStyle = TextStyle(
  color: Colors.blueGrey[700],
  // fontWeight: FontWeight.w800,
  fontFamily: 'Monsterrat',
  fontSize: 11.0,
  //height: 2,
);
final labelMedTextStyle = TextStyle(
  color: Colors.grey[700],
  fontFamily: 'Monsterrat',
  letterSpacing: 0.5,
  fontSize: 15.0,
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
    color: Colors.blueGrey[50], fontFamily: 'Montserrat', fontSize: 12.0);
final btnTextStyle =
    TextStyle(color: Colors.white, fontFamily: 'Montserrat', fontSize: 17.0);
final logoSubTextStyle = TextStyle(
    color: primaryAccentColor, fontFamily: 'Montserrat', fontSize: 30.0);

final headingTextStyle = TextStyle(
    color: Colors.blueGrey[800],
    letterSpacing: 0.5,
    fontFamily: 'Montserrat',
    fontSize: 15.0);
final Color primaryIcon = Colors.blueGrey[800];
final Color lightIcon = Colors.white;

final Color btnColor = Colors.cyan[600];

final Color borderColor = Colors.blueGrey[800];

final Color primaryAccentColor = Colors.cyanAccent;
final Color primaryDoneColor = Colors.green[300];
final Color primaryDarkColor = Colors.cyan[800];
final Color whiteBtnTextColor = Colors.black;

final Color gradientDarkColor = Colors.blueGrey[600];

final Color headerBarColor = Colors.blueGrey[400];

final Color categoryIconColor = Colors.orangeAccent[400];
final Color highlightColor = Colors.orangeAccent;
final Color greenColor = Colors.greenAccent[700];
final Color unselectedColor = Colors.blueGrey[700];
final Color disabledColor = Colors.grey[400];
final Color btnDisabledolor = Colors.blueGrey[200];

final Color highlightText = Colors.blueGrey[800];
final highlightSubTextStyle = TextStyle(
    color: Colors.black87,
    fontFamily: 'RalewayRegular',
    fontSize: 12.0,
    height: 1.5);
final userAccountHeadingTextStyle = TextStyle(
    color: Colors.black87,
    fontFamily: 'Montserrat',
    fontSize: 15.0,
    height: 1.5);
final shareAppTextStyle = TextStyle(
    color: Colors.blueGrey[900], fontFamily: 'Roboto', fontSize: 14.0);
final placeDetailsHeadingTextStyle = TextStyle(
    color: primaryDarkColor, fontFamily: 'Montserrat', fontSize: 14.0);
final placeDetailsHeadingSml = TextStyle(
    color: primaryDarkColor, fontFamily: 'Montserrat', fontSize: 11.0);
final lightTextStyle =
    TextStyle(color: Colors.white, fontFamily: 'Montserrat', fontSize: 12.0);
final linkTextStyle = TextStyle(
    color: Colors.blue[700], fontFamily: 'Montserrat', fontSize: 12.0);

final tokenTextStyle = TextStyle(
    color: highlightColor,
    //fontWeight: FontWeight.w600,
    fontFamily: 'Montserrat',
    letterSpacing: 3,
    // decoration: TextDecoration.underline,
    fontSize: 15.0);

final tokenDataTextStyle = TextStyle(
    fontFamily: 'RalewayRegular', fontSize: 12, color: primaryAccentColor);
final tokenDateTextStyle = TextStyle(
    color: Colors.white,
    // fontWeight: FontWeight.w500,
    fontFamily: 'Montserrat',
    fontSize: 15.0);
final appBarTextStyle = TextStyle(
    color: Colors.blueGrey[800], fontFamily: 'Montserrat', fontSize: 25.0);
final homeMsgStyle = TextStyle(
    color: Colors.blueGrey[800], fontFamily: 'Montserrat', fontSize: 11.0);
final homeMsgStyle2 = TextStyle(
    color: Colors.blueGrey[800], fontFamily: 'Roboto', fontSize: 18.0);
final homeMsgStyle3 =
    TextStyle(color: highlightColor, fontFamily: 'Montserrat', fontSize: 20.0);

final highlightTextStyle = TextStyle(
    color: Colors.blueGrey[800], fontFamily: 'Montserrat', fontSize: 19.0);

final BoxDecoration darkContainer = new BoxDecoration(
    border: Border.all(color: Colors.blueGrey[300]),
    shape: BoxShape.rectangle,
    color: Colors.blueGrey[500],
    borderRadius: BorderRadius.only(
        topLeft: Radius.circular(4.0), topRight: Radius.circular(4.0)));

final BoxDecoration whiteContainer = new BoxDecoration(
    border: Border.all(color: Colors.black),
    shape: BoxShape.rectangle,
    color: Colors.grey[100],
    borderRadius: BorderRadius.only(
        topLeft: Radius.circular(4.0), topRight: Radius.circular(4.0)));
final Color containerColor = Colors.blueGrey[500];
final BoxDecoration soildLightContainer = new BoxDecoration(
    border: Border.all(color: Colors.teal[200]),
    shape: BoxShape.rectangle,
    color: Colors.teal[200],
    borderRadius: BorderRadius.only(
        topLeft: Radius.circular(4.0), topRight: Radius.circular(4.0)));
final BoxDecoration lightCyanContainer = new BoxDecoration(
    border: Border.all(color: Colors.cyan[50]),
    shape: BoxShape.rectangle,
    color: Colors.cyan[100],
    borderRadius: BorderRadius.only(
        topLeft: Radius.circular(4.0), topRight: Radius.circular(4.0)));
final BoxDecoration lightAmberContainer = new BoxDecoration(
    border: Border.all(color: Colors.amber[200]),
    shape: BoxShape.rectangle,
    color: Colors.amber[200],
    borderRadius: BorderRadius.only(
        topLeft: Radius.circular(4.0), topRight: Radius.circular(4.0)));
final BoxDecoration btnColorContainer = new BoxDecoration(
    border: Border.all(color: btnColor),
    shape: BoxShape.rectangle,
    color: btnColor,
    borderRadius: BorderRadius.only(
        topLeft: Radius.circular(4.0), topRight: Radius.circular(4.0)));

final BoxDecoration rectLightContainer = new BoxDecoration(
  border: Border.all(color: btnColor),
  shape: BoxShape.rectangle,
  color: btnColor,
);
final gradientBackground = new BoxDecoration(
  gradient: new LinearGradient(
      colors: [Colors.blueGrey[800], Colors.blueGrey[800]],
      begin: const FractionalOffset(0.0, 0.0),
      end: const FractionalOffset(1.0, 0.0),
      stops: [0.0, 1.0],
      tileMode: TileMode.clamp),
);

final buttonBackground = new BoxDecoration(
    gradient: new LinearGradient(
        colors: [Colors.cyan[400], Colors.cyan[700]],
        begin: const FractionalOffset(0.0, 0.0),
        end: const FractionalOffset(1.0, 0.0),
        stops: [0.0, 1.0],
        tileMode: TileMode.clamp),
    // border: Border.all(
    //   color: Colors.cyan[600],
    // ),
    borderRadius: BorderRadius.all(Radius.circular(20)));

final verticalBackground = new BoxDecoration(
  gradient: new LinearGradient(
    colors: [
      Colors.white,
      Colors.black87,
    ],
    begin: const FractionalOffset(0.0, 0.0),
    end: const FractionalOffset(0.0, 1.0),
    stops: [0.5, 1.0],
    //  tileMode: TileMode.clamp
  ),
);

class CommonStyle {
  static InputDecoration textFieldStyle(
      {String labelTextStr = "",
      String hintTextStr = "",
      String prefixText = ""}) {
    return InputDecoration(
      //contentPadding: EdgeInsets.all(12),
      labelText: labelTextStr,
      hintText: hintTextStr,
      prefixText: prefixText,
      enabledBorder:
          UnderlineInputBorder(borderSide: BorderSide(color: Colors.grey)),
      focusedBorder:
          UnderlineInputBorder(borderSide: BorderSide(color: Colors.orange)),
    );
  }
}
