import 'package:flutter/material.dart';
import 'package:noq/style.dart';

class HelpPage extends StatefulWidget {
  @override
  _HelpPageState createState() => _HelpPageState();
}

class _HelpPageState extends State<HelpPage> {
  Widget _needHelpPage = Center(
      child: Container(
          margin: EdgeInsets.fromLTRB(10, 10, 10, 10),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text("We are working on getting best help to you..",
                  style: highlightTextStyle),
              Text('Be Safe | Save Time.', style: highlightSubTextStyle),
            ],
          )));
  @override
  Widget build(BuildContext context) {
    return _needHelpPage;
  }
}