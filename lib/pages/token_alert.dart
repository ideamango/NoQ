import 'package:LESSs/utils.dart';
import 'package:flutter/material.dart';
import '../constants.dart';
import '../widget/widgets.dart';
import '../style.dart';

Future<String> showTokenAlert(BuildContext context, String msg, String tokenNo,
    String storeName, String date, String time) {
  return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) {
        return new AlertDialog(
          //  title:
          backgroundColor: Colors.grey[200],
          titleTextStyle: inputTextStyle,
          elevation: 10.0,
          content: Container(
              width: double.infinity,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Text(
                    tokenHeading,
                    style: TextStyle(
                        color: primaryDarkColor,
                        fontFamily: 'Monsterrat',
                        fontSize: 18.0),
                  ),
                  Divider(color: Colors.blueGrey[400], height: 1),
                  verticalSpacer,
                  Text(tokenTextH1, style: highlightSubTextStyle),
                  Container(
                    alignment: Alignment.center,
                    margin: EdgeInsets.all(5),
                    width: MediaQuery.of(context).size.width * .78,
                    height: MediaQuery.of(context).size.width * .12,
                    decoration: new BoxDecoration(
                      color: primaryIcon,
                    ),
                    child: Text(tokenNo, style: homeMsgStyle3),
                  ),
                  RichText(
                      text: TextSpan(
                          style: highlightSubTextStyle,
                          children: <TextSpan>[
                        TextSpan(text: msg),
                        TextSpan(
                            text: " $storeName",
                            style: TextStyle(
                                color: Colors.amber[800], fontSize: 16)),
                        TextSpan(
                          text: " on ",
                        ),
                        TextSpan(
                            text: "$date",
                            style: TextStyle(
                                color: Colors.greenAccent[700], fontSize: 16)),
                        TextSpan(
                          text: " at ",
                        ),
                        TextSpan(
                            text: "$time.",
                            style: TextStyle(
                                color: Colors.greenAccent[700], fontSize: 16)),
                      ])),
                  verticalSpacer,
                  Divider(color: Colors.blueGrey[400], height: 1),
                ],
              )),
          contentPadding: EdgeInsets.all(10),
          actions: <Widget>[
            Container(
              margin: EdgeInsets.fromLTRB(0, 0, 10, 0),
              child: RaisedButton(
                elevation: 15.0,
                color: highlightColor,
                textColor: Colors.white,
                child: Text('Ok'),
                onPressed: () {
                  //Navigator.of(context).pushReplacement(StoreLiPage());
                  Navigator.of(_).pop(tokenNo);
                },
              ),
            ),
          ],
        );
      }).then((val) {
    print(val);
    return val;
  });
}

Future<String> showMessageDialog(
    BuildContext context, String headerMsg, String mainMsg, String btnText) {
  return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) {
        return new AlertDialog(
          //  title:
          backgroundColor: Colors.grey[200],
          titleTextStyle: inputTextStyle,
          elevation: 10.0,
          content: Container(
              width: double.infinity,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Text(
                    headerMsg,
                    style: TextStyle(
                        color: primaryDarkColor,
                        fontFamily: 'Monsterrat',
                        fontSize: 18.0),
                  ),
                  Divider(color: Colors.blueGrey[400], height: 1),
                  verticalSpacer,
                  RichText(
                      text: TextSpan(
                          style: msgDialogTextStyle,
                          children: <TextSpan>[
                        TextSpan(text: mainMsg),
                        TextSpan(
                          text:
                              '\nYou can check the status of your Application in ',
                        ),
                        TextSpan(
                            text: 'My Account',
                            style: TextStyle(color: Colors.cyan, fontSize: 15)),
                        TextSpan(
                          text: ' page.',
                        ),
                      ])),
                  verticalSpacer,
                  Divider(color: Colors.blueGrey[400], height: 1),
                ],
              )),
          contentPadding: EdgeInsets.all(10),
          actions: <Widget>[
            Container(
              margin: EdgeInsets.fromLTRB(0, 0, 10, 0),
              child: MaterialButton(
                elevation: 15.0,
                color: highlightColor,
                textColor: Colors.white,
                child: Text(btnText),
                onPressed: () {
                  Navigator.of(_).pop();
                },
              ),
            ),
          ],
        );
      }).then((val) {
    print(val);
    return val;
  });
}

Future<String> showApplicationStatusDialog(BuildContext context,
    String headerMsg, String mainMsg, String subMsg, String btnText) async {
  TextEditingController rmksController = new TextEditingController();
  final remarksKey = GlobalKey<FormFieldState>();
  String remarksVal = await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) {
        return new AlertDialog(
          //  title:
          backgroundColor: Colors.grey[200],
          titleTextStyle: inputTextStyle,
          elevation: 10.0,
          contentPadding: EdgeInsets.all(10),
          content: Container(
              width: double.infinity,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Text(
                    headerMsg.toUpperCase(),
                    style: TextStyle(
                        color: Colors.black,
                        fontFamily: 'Monsterrat',
                        fontSize: 20.0),
                  ),
                  Divider(color: Colors.blueGrey[400], height: 1.3),
                  verticalSpacer,
                  RichText(
                      text: TextSpan(
                          style: msgDialogTextStyle,
                          children: <TextSpan>[
                        TextSpan(
                          text: '$subMsg',
                          style: TextStyle(
                              color: Colors.blueGrey[800], fontSize: 13),
                        ),
                        TextSpan(text: '\n$mainMsg'),
                      ])),
                  verticalSpacer,
                  Form(
                    child: TextFormField(
                      controller: rmksController,
                      key: remarksKey,
                      style: textInputTextStyle,
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      decoration: InputDecoration(
                        labelText: 'Remarks',
                        labelStyle: textInputTextStyle,
                        enabledBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: Colors.grey)),
                        focusedBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: Colors.orange)),
                      ),
                      keyboardType: TextInputType.multiline,
                      maxLength: null,
                      maxLines: 2,
                      validator: (value) {
                        if (Utils.isNotNullOrEmpty(value))
                          return null;
                        else
                          return 'Field is empty, Please enter remarks.';
                      },
                    ),
                  ),
                  //   Divider(color: Colors.blueGrey[400], height: 1),
                ],
              )),

          actions: <Widget>[
            Container(
              width: MediaQuery.of(context).size.width * .3,
              margin: EdgeInsets.all(0),
              child: MaterialButton(
                elevation: 0.0,
                color: Colors.white,
                splashColor: highlightColor,
                padding: EdgeInsets.fromLTRB(10, 8, 10, 8),
                shape: RoundedRectangleBorder(
                    side: BorderSide(color: disabledColor),
                    borderRadius: BorderRadius.all(Radius.circular(5.0))),
                child: Text(
                  'Back',
                  style: TextStyle(color: btnColor),
                ),
                onPressed: () {
                  Navigator.of(_).pop(null);
                },
              ),
            ),
            Container(
              width: MediaQuery.of(context).size.width * .41,
              margin: EdgeInsets.all(0),
              // alignment: Alignment.center,
              child: MaterialButton(
                elevation: 15.0,
                color: btnColor,
                splashColor: highlightColor,
                padding: EdgeInsets.fromLTRB(10, 8, 10, 8),
                shape: RoundedRectangleBorder(
                    //  side: BorderSide(color: btnColor),
                    borderRadius: BorderRadius.all(Radius.circular(5.0))),
                textColor: Colors.white,
                child: Text(
                  btnText,
                  textAlign: TextAlign.center,
                ),
                onPressed: () {
                  if (remarksKey.currentState.validate())
                    Navigator.of(_).pop(rmksController.text);
                  return;
                },
              ),
            ),
          ],
        );
      });
  return remarksVal;
}
