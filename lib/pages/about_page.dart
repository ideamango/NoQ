import 'package:flutter/material.dart';
import 'package:noq/style.dart';
import 'package:noq/userHomePage.dart';
import 'package:noq/widget/appbar.dart';
import 'package:noq/widget/bottom_nav_bar.dart';
import 'package:noq/widget/header.dart';

class AboutUsPage extends StatefulWidget {
  @override
  _AboutUsPageState createState() => _AboutUsPageState();
}

class _AboutUsPageState extends State<AboutUsPage> {
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
    String title = "About Us";
    return MaterialApp(
      theme: ThemeData.light().copyWith(),
      home: Scaffold(
        drawer: CustomDrawer(),
        appBar: CustomAppBar(
          titleTxt: title,
        ),
        body: Center(
            child: Column(
          children: <Widget>[
            Text(
              "Our Story..",
              style: highlightTextStyle,
            ),
            Text("Our Mission..!!"),
            RaisedButton(
              child: Text("Back"),
              onPressed: () => Navigator.push(context,
                  MaterialPageRoute(builder: (context) => UserHomePage())),
            ),
          ],
        )),
        bottomNavigationBar: CustomBottomBar(
          barIndex: 3,
        ),
      ),
    );
  }
}
