import 'package:flutter/material.dart';

class UserAccountPage extends StatefulWidget {
  @override
  _UserAccountPageState createState() => _UserAccountPageState();
}

class _UserAccountPageState extends State<UserAccountPage> {
  @override
  Widget build(BuildContext context) {
    return Container(
        child: RaisedButton(
      child: Text("Back"),
      onPressed: () => Navigator.of(context).pop(),
    ));
  }
}
