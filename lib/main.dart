import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:noq/dashboard.dart';
import 'package:noq/login_page.dart';
import 'package:noq/services/init_screen.dart';

//import 'services/authService.dart';

//void main() => runApp(MyApp());
void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp])
      .then((_) {
    runApp(new MyApp());
  });
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.

  void initState() {
    //super.initState();
    //  new FirebaseNotifications().setUpFirebase();
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
        unselectedWidgetColor: Colors.teal,

        // Define the default font family..
        fontFamily: 'Monsterrat',
        // Define the default TextTheme. Use this to specify the default
        // text styling for headlines, titles, bodies of text, and more.
        textTheme: TextTheme(
          headline1: TextStyle(fontSize: 72.0, fontWeight: FontWeight.bold),
          subtitle1: TextStyle(
              color: Colors.indigo,
              fontSize: 36.0,
              fontStyle: FontStyle.italic),
          bodyText1: TextStyle(
              color: Colors.indigo, fontSize: 14.0, fontFamily: 'Monsterrat'),
        ),
      ),
      home: SplashScreen(),
      // home: AuthService().handleAuth(),
    );
  }
}
