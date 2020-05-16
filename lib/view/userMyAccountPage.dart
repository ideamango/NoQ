import 'dart:io';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:noq/services/authService.dart';
import 'package:noq/services/qr_code_generate.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/foundation.dart';

class UserMyAccountPage extends StatefulWidget {
  @override
  _UserMyAccountPageState createState() => _UserMyAccountPageState();
}

class _UserMyAccountPageState extends State<UserMyAccountPage> {
  String state;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        child: Column(children: <Widget>[
      Card(
          child:
              Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
        Text('Logout'),
        Container(
          width: 40.0,
          height: 20.0,
          child: IconButton(
            //alignment: Alignment.center,
            padding: EdgeInsets.all(0),
            onPressed: () {
              AuthService().signOut(context);
            },
            highlightColor: Colors.orange[300],
            icon: Icon(
              Icons.exit_to_app,
              color: Colors.blueGrey,
            ),
          ),
        ),
      ])),
      GenerateScreen(),
    ]));
  }
}
