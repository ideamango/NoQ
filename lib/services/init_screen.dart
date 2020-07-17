import 'dart:async';
import 'package:flutter/material.dart';
import 'package:noq/services/authService.dart';
import 'package:noq/style.dart';
import 'package:noq/widget/widgets.dart';

class SplashScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => SplashState();
}

class SplashState extends State<SplashScreen> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    startTime();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: initScreen(context),
    );
  }

  startTime() async {
    var duration = new Duration(seconds: 3);
    return new Timer(duration, route);
  }

  route() {
    Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => AuthService().handleAuth(),
        ));
  }

  initScreen(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Container(
          decoration: BoxDecoration(
              image: DecorationImage(
                  image: AssetImage("assets/background.png"),
                  fit: BoxFit.cover)),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Container(
                height: MediaQuery.of(context).size.width,
                child: Image.asset(
                  "assets/logo.png",
                  fit: BoxFit.fitWidth,
                ),
              ),
              Text(
                "Loading",
                style: TextStyle(fontSize: 20.0, color: Colors.blueGrey[50]),
              ),
              verticalSpacer,
              CircularProgressIndicator(
                backgroundColor: primaryAccentColor,
                valueColor: AlwaysStoppedAnimation<Color>(highlightColor),
                strokeWidth: 3,
              )
            ],
          ),
        ),
      ),
    );
  }
}
