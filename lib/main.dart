import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:noq/db/db_model/entity.dart';
import 'package:noq/db/db_service/entity_service.dart';
import 'package:noq/events/event_bus.dart';
import 'package:noq/events/local_notification_data.dart';
import 'package:noq/global_state.dart';
import 'package:noq/login_page.dart';
import 'package:noq/pages/search_entity_page.dart';
import 'package:noq/pages/favs_list_page.dart';
import 'package:noq/repository/StoreRepository.dart';
import 'package:noq/services/init_screen.dart';
import 'package:noq/userHomePage.dart';
import 'package:noq/utils.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:flutter_native_timezone/flutter_native_timezone.dart';

import 'events/events.dart';

//import 'services/authService.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  Firebase.initializeApp().then((value) {
    FirebaseCrashlytics.instance
        .setCrashlyticsCollectionEnabled(true)
        .then((value) {
      FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterError;
    });

    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp])
        .then((_) {
      runApp(new MyHome());
    });
  });
}

class MyHome extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    //Firebase.initializeApp();
    return MaterialApp(debugShowCheckedModeBanner: false, home: MyApp());
  }
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
  //final NavigationService _navigationService = locator<NavigationService>();
  final DynamicLinkService _dynamicLinkService = DynamicLinkService();
  Timer _timerLink;
  //FlutterLocalNotificationsPlugin localNotification;

  @override
  void initState() {
    super.initState();
    _configureLocalTimeZone();
    WidgetsBinding.instance.addObserver(this);
  }

  Future<void> _configureLocalTimeZone() async {
    try {
      tz.initializeTimeZones();
    } catch (e) {
      print("Initializing of Timezone DB failed: " + e.toString());
    }

    String timeZoneName = "UTC";

    try {
      timeZoneName = await FlutterNativeTimezone.getLocalTimezone();

      if (timeZoneName == "Asia/Calcutta") {
        timeZoneName = "Asia/Kolkota";
      }
    } catch (e) {
      print("Reading of Local Timezone failed: " + e.toString());
    }

    try {
      tz.Location l = tz.getLocation(timeZoneName);
      tz.setLocalLocation(l);
    } catch (e) {
      print("Setting up location failed: " + e.toString());
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _timerLink = new Timer(
        const Duration(milliseconds: 800),
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

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      routes: <String, WidgetBuilder>{
        '/dashboard': (BuildContext context) => UserHomePage(),
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
  void retrieveDynamicLink(BuildContext context) async {
    try {
      // showDialog(context: context, child: Text('Yay!!!'));
      final PendingDynamicLinkData data =
          await FirebaseDynamicLinks.instance.getInitialLink();
      final Uri deepLink = data?.link;

      if (deepLink != null) {
        print(deepLink.queryParameters);
        //  Navigator.pushNamed(context, deepLink.path);
        // Navigator.push(
        //     context, MaterialPageRoute(builder: (context) => FavsListPage()));
      }

      FirebaseDynamicLinks.instance.onLink(onSuccess: (dynamicLink) async {
        final Uri deepLink = dynamicLink?.link;
        print(deepLink.queryParameters);
        print("Deep link path ");
        print(deepLink.path);
        if (deepLink.queryParameters.containsKey("entityId")) {
          print("there are query params");
          //check if user authenticated
          if (FirebaseAuth.instance.currentUser != null) {
            // signed in
            print("current user already logged in");
            // Call method to add entity to favs list, if not already present,
            // else just load favs page.
            String entityId = deepLink.queryParameters['entityId'];
            Utils.addEntityToFavs(context, entityId);
          }
        } else
          Navigator.pushReplacement(
              context, MaterialPageRoute(builder: (context) => UserHomePage()));
        // Navigator.pushNamed(context, deepLink.path);
      });
    } catch (e) {
      print(e.toString());
      print(e.message);
    }
  }
}
