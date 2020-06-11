import 'package:flutter/material.dart';
import 'package:noq/style.dart';

class RateAppPage extends StatefulWidget {
  @override
  _RateAppPageState createState() => _RateAppPageState();
}

class _RateAppPageState extends State<RateAppPage> {
  Widget _rateAppPage = Center(
      child: Container(
          margin: EdgeInsets.fromLTRB(10, 10, 10, 10),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text("Rate our app if it bought happiness!!",
                  style: highlightTextStyle),
              Text('Be Safe | Save Time.', style: highlightSubTextStyle),
            ],
          )));
  @override
  Widget build(BuildContext context) {
    return _rateAppPage;
  }
}
