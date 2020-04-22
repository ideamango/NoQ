import 'package:flutter/material.dart';
import 'package:noq/dashboard.dart';
import 'package:noq/login_page.dart';

import 'services/authService.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      routes: <String, WidgetBuilder>{
        '/landingPage': (BuildContext context) => LandingPage(),
        '/loginpage': (BuildContext context) => LoginPage(),
      },
      home: AuthService().handleAuth(),
    );
  }
}
