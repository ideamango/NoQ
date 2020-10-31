import 'package:flutter/material.dart';
import 'package:noq/constants.dart';
import 'package:noq/widget/widgets.dart';
import 'package:noq/style.dart';

Future<String> showTokenAlert(
    BuildContext context, String tokenNo, String storeName, String time) {
  return showDialog(
      context: context,
      barrierDismissible: true,
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
                    width: MediaQuery.of(context).size.width * .72,
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
                        TextSpan(text: tokenTextH2),
                        TextSpan(
                            text: " $storeName at $time.",
                            style:
                                TextStyle(color: highlightColor, fontSize: 12)),
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
