import 'dart:async';

import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:noq/dashboard.dart';
import 'package:noq/login_page.dart';
import 'package:noq/pages/SearchStoresPage.dart';
import 'package:noq/pages/favs_list_page.dart';
import 'package:noq/services/init_screen.dart';
import 'package:noq/userHomePage.dart';

//import 'services/authService.dart';

//void main() => runApp(MyApp());
void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp])
      .then((_) {
    runApp(new MyApp());
  });
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
  final DynamicLinkService _dynamicLinkService = DynamicLinkService();
  Timer _timerLink;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _timerLink = new Timer(
        const Duration(milliseconds: 1000),
        () {
          _dynamicLinkService.retrieveDynamicLink(context);
        },
      );
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    if (_timerLink != null) {
      _timerLink.cancel();
    }
    super.dispose();
  }

  initDynamicLinks(BuildContext context) async {
    await Future.delayed(Duration(seconds: 3));
    var data = await FirebaseDynamicLinks.instance.getInitialLink();
    var deepLink = data?.link;
    Map queryParams;
    if (deepLink != null) {
      queryParams = deepLink.queryParameters;
      if (queryParams.length > 0) {
        var entityId = queryParams['entityId'];
        print("entityId from dynamic link -- $entityId");
        print(entityId);
        if (entityId != null) {
          Navigator.push(
              context, MaterialPageRoute(builder: (context) => FavsListPage()));
        } else {
          Navigator.push(
              context, MaterialPageRoute(builder: (context) => LoginPage()));
        }
      }
    } else {
      Navigator.push(
          context, MaterialPageRoute(builder: (context) => LoginPage()));
    }

    FirebaseDynamicLinks.instance.onLink(onSuccess: (dynamicLink) async {
      var deepLink = dynamicLink?.link;
      debugPrint('DynamicLinks onLink $deepLink');
      if (queryParams.length > 0) {
        Navigator.push(
            context, MaterialPageRoute(builder: (context) => FavsListPage()));
      } else {
        Navigator.push(
            context, MaterialPageRoute(builder: (context) => LoginPage()));
      }
    }, onError: (e) async {
      debugPrint('DynamicLinks onError $e');
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      routes: <String, WidgetBuilder>{
        '/landingPage': (BuildContext context) => UserHomePage(),
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

class DynamicLinkService {
  Future<void> retrieveDynamicLink(BuildContext context) async {
    try {
      // showDialog(context: context, child: Text('Yay!!!'));
      final PendingDynamicLinkData data =
          await FirebaseDynamicLinks.instance.getInitialLink();
      final Uri deepLink = data?.link;
      print(deepLink.queryParameters);
      
      if (deepLink != null) {
        Navigator.pushNamed(context, deepLink.path);
      }

      FirebaseDynamicLinks.instance.onLink(
          onSuccess: (PendingDynamicLinkData dynamicLink) async {
        Navigator.pushNamed(context, deepLink.path);
      });
    } catch (e) {
      print(e.toString());
    }
  }
}
