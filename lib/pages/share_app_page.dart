import 'package:flutter/material.dart';
import 'package:noq/style.dart';
import 'package:noq/widget/appbar.dart';
import 'package:noq/widget/bottom_nav_bar.dart';
import 'package:noq/widget/header.dart';

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
              Text('Sharing is Caring.', style: highlightSubTextStyle),
            ],
          )));

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    String title = "Share our App";
    return MaterialApp(
      theme: ThemeData.light().copyWith(),
      home: Scaffold(
        drawer: CustomDrawer(),
        appBar: CustomAppBar(
          titleTxt: title,
        ),
        body: _shareAppPage,
        bottomNavigationBar: CustomBottomBar(
          barIndex: 3,
        ),
      ),
    );
  }
}
