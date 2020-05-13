import 'package:flutter/material.dart';
import 'package:noq/dashboard.dart';
import 'package:noq/login_page.dart';
import 'package:noq/push_notifications.dart';
import 'package:noq/view/init_screen.dart';

//import 'services/authService.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.

  void initState() {
    //super.initState();
    new FirebaseNotifications().setUpFirebase();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      routes: <String, WidgetBuilder>{
        '/landingPage': (BuildContext context) => LandingPage(),
        '/loginpage': (BuildContext context) => LoginPage(),
      },
      theme: ThemeData(
        brightness: Brightness.light,
        primaryColor: Colors.teal[900],
        accentColor: Colors.indigoAccent,

        // Define the default font family..
        fontFamily: 'Monsterrat',
        // Define the default TextTheme. Use this to specify the default
        // text styling for headlines, titles, bodies of text, and more.
        textTheme: TextTheme(
          headline: TextStyle(fontSize: 72.0, fontWeight: FontWeight.bold),
          title: TextStyle(
              color: Colors.indigo,
              fontSize: 36.0,
              fontStyle: FontStyle.italic),
          body1: TextStyle(
              color: Colors.indigo, fontSize: 14.0, fontFamily: 'Monsterrat'),
        ),
      ),
      home: SplashScreen(),
      // home: AuthService().handleAuth(),
    );
  }
}
