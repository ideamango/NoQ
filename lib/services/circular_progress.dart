import 'package:flutter/material.dart';
import 'package:noq/widget/widgets.dart';

Widget showCircularProgress() {
  return Center(
    child: Padding(
      padding: EdgeInsets.only(top: 10.0, bottom: 10),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          //Padding(padding: EdgeInsets.only(top: 20.0)),
          Text(
            "Loading..",
            style: TextStyle(fontSize: 15.0, color: Colors.teal),
          ),
          verticalSpacer,
          //Padding(padding: EdgeInsets.only(top: 20.0)),
          CircularProgressIndicator(
            backgroundColor: Colors.indigo,
            valueColor: AlwaysStoppedAnimation<Color>(Colors.amber),
            strokeWidth: 3,
          )
        ],
      ),
    ),
  );
}
