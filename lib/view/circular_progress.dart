import 'package:flutter/material.dart';

Widget showCircularProgress() {
  return Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Padding(padding: EdgeInsets.only(top: 20.0)),
        Text(
          "Loading..",
          style: TextStyle(fontSize: 20.0, color: Colors.indigo),
        ),
        Padding(padding: EdgeInsets.only(top: 20.0)),
        CircularProgressIndicator(
          backgroundColor: Colors.indigo,
          valueColor: AlwaysStoppedAnimation<Color>(Colors.amber),
          strokeWidth: 3,
        )
      ],
    ),
  );
}
