import 'package:flutter/material.dart';
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
          title: Text(
            'Yay!! Your booking confirmed.',
            style: highlightTextStyle,
          ),
          backgroundColor: Colors.grey[200],
          titleTextStyle: inputTextStyle,
          elevation: 10.0,
          content: Container(
              width: double.infinity,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Text("Booked peace of mind.No more long waiting in queues!",
                      style: highlightSubTextStyle),
                  Container(
                    alignment: Alignment.center,
                    margin: EdgeInsets.fromLTRB(10, 20, 10, 10),
                    width: MediaQuery.of(context).size.width * .7,
                    height: MediaQuery.of(context).size.width * .12,
                    decoration: new BoxDecoration(
                      color: highlightColor,
                    ),
                    child: Text(tokenNo, style: whiteBoldTextStyle1),
                  ),
                  Text("Show up on time to $storeName at $time.",
                      style: highlightSubTextStyle),
                ],
              )),
          contentPadding: EdgeInsets.all(10),
          actions: <Widget>[
            Container(
              margin: EdgeInsets.fromLTRB(0, 0, 10, 0),
              child: RaisedButton(
                elevation: 15.0,
                color: Colors.indigo,
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
