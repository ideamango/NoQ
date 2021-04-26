import 'dart:async';
import 'package:flutter/material.dart';
import '../global_state.dart';
import '../services/auth_service.dart';
import '../services/circular_progress.dart';
import '../style.dart';
import '../widget/widgets.dart';

class SplashScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => SplashState();
}

class SplashState extends State<SplashScreen> {
  GlobalState _state;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    GlobalState.getGlobalState().then((value) {
      _state = value;
      startTime();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: initScreen(context),
    );
  }

  startTime() async {
    var duration = new Duration(seconds: 0);
    return new Timer(duration, route);
  }

  route() {
    Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => (_state.getAuthService()).handleAuth(),
        ));
  }

  initScreen(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Container(
          decoration: BoxDecoration(
              color: Colors.grey[800],
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
                  child: Image.asset(
                    "assets/less_name.png",
                    fit: BoxFit.contain,
                  ),
                  // child: Text(
                  //   "Sukoon",
                  //   style: TextStyle(
                  //       fontFamily: "AnandaNamaste",
                  //       fontSize: 90,
                  //       color: primaryAccentColor),
                  // ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    SizedBox(
                        height: MediaQuery.of(context).size.height * .07,
                        width: MediaQuery.of(context).size.width * .7,
                        child: Image.asset(
                          "assets/sukoon_subheading.png",
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
