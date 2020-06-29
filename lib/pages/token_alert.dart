import 'package:flutter/material.dart';
import 'package:noq/constants.dart';
import 'package:noq/widget/widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../style.dart';

class ShowTokenAlert extends StatefulWidget {
  @override
  _ShowTokenAlertState createState() => _ShowTokenAlertState();
}

class _ShowTokenAlertState extends State<ShowTokenAlert> {
  @override
  Widget build(BuildContext context) {
    return new SimpleDialog(
      title: Text('Token',
          style: TextStyle(
            fontSize: 20,
            color: Colors.grey,
          )),
      backgroundColor: Colors.grey[200],
      elevation: 10.0,
      children: <Widget>[
        Container(
          child: Text("Token number"),
        ),
        FlatButton(
          color: Colors.orange,
          textColor: Colors.white,
          child: Text('Ok'),
          onPressed: () {
            Navigator.of(context).pop();
            //Navigator.of(context).pushReplacement(DashBoar());
          },
        ),
      ],
    );
  }
}

Future<String> showTokenAlert(
    BuildContext context, String tokenNo, String storeName, String time) {
  return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
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
                        fontSize: 17.0),
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
                      color: primaryAccentColor,
                    ),
                    child: Text(tokenNo, style: whiteBoldTextStyle1),
                  ),
                  Text(tokenTextH2 + " $storeName at $time.",
                      style: highlightSubTextStyle),
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
                  Navigator.of(context).pop(tokenNo);
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
