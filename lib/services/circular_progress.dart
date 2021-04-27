import 'package:flutter/material.dart';
import '../style.dart';
import '../widget/widgets.dart';

Widget showCircularProgress() {
  return Center(
    child: Padding(
      padding: EdgeInsets.only(top: 10.0, bottom: 10),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          //Padding(padding: EdgeInsets.only(top: 20.0)),
          Text(
            "Fetching data, please wait..",
            style: TextStyle(fontSize: 15.0, color: Colors.blueGrey[700]),
          ),
          verticalSpacer,
          //Padding(padding: EdgeInsets.only(top: 20.0)),
          CircularProgressIndicator(
            backgroundColor: Colors.blueGrey[600],
            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            strokeWidth: 2,
          )
        ],
      ),
    ),
  );
}
