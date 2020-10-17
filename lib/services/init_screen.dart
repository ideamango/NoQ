import 'dart:async';
import 'package:flutter/material.dart';
import 'package:noq/global_state.dart';
import 'package:noq/services/authService.dart';
import 'package:noq/services/circular_progress.dart';
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
    var duration = new Duration(seconds: 1);
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
          child: SafeArea(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                SizedBox(height: MediaQuery.of(context).size.height * .1),
                SizedBox(
                  height: MediaQuery.of(context).size.height * .15,
                  child: Text(
                    "Sukoon",
                    style: TextStyle(
                        fontFamily: "AnandaNamaste",
                        fontSize: 90,
                        color: primaryAccentColor),
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    SizedBox(
                        height: MediaQuery.of(context).size.height * .07,
                        width: MediaQuery.of(context).size.width * .7,
                        child: Image.asset(
                          "assets/login_subheading.png",
                          fit: BoxFit.contain,
                        )),
                  ],
                ),
                SizedBox(height: MediaQuery.of(context).size.height * .1),
                //showCircularProgress(),
                // Text(
                //   "Loading",
                //   style: TextStyle(fontSize: 20.0, color: Colors.blueGrey[50]),
                // ),
                // verticalSpacer,
                CircularProgressIndicator(
                  backgroundColor: primaryAccentColor,
                  valueColor: AlwaysStoppedAnimation<Color>(borderColor),
                  strokeWidth: 2,
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
