import 'package:flutter/material.dart';
import 'package:noq/style.dart';

class ShareAppPage extends StatefulWidget {
  @override
  _ShareAppPageState createState() => _ShareAppPageState();
}

class _ShareAppPageState extends State<ShareAppPage> {
  Widget _shareAppPage = Center(
      child: Container(
          margin: EdgeInsets.fromLTRB(10, 10, 10, 10),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text("Share and spread happiness!!", style: highlightTextStyle),
              Text('Be Safe | Save Time.', style: highlightSubTextStyle),
            ],
          )));

  @override
  Widget build(BuildContext context) {
    return _shareAppPage;
  }
}
