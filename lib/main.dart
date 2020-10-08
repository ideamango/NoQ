import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:noq/dashboard.dart';
import 'package:noq/db/db_model/entity.dart';
import 'package:noq/db/db_service/entity_service.dart';
import 'package:noq/global_state.dart';
import 'package:noq/login_page.dart';
import 'package:noq/pages/SearchStoresPage.dart';
import 'package:noq/pages/favs_list_page.dart';
import 'package:noq/repository/StoreRepository.dart';
import 'package:noq/services/init_screen.dart';
import 'package:noq/userHomePage.dart';
import 'package:noq/utils.dart';

//import 'services/authService.dart';

//void main() => runApp(MyApp());
void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp])
      .then((_) {
    runApp(new MyHome());
  });
}

class MyHome extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    Firebase.initializeApp();
    return MaterialApp(home: MyApp());
  }
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
        Navigator.push(
            context, MaterialPageRoute(builder: (context) => FavsListPage()));
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

            // GlobalState gs = await GlobalState.getGlobalState();
            String entityId = deepLink.queryParameters['entityId'];
            // Entity entity =
            //     await getEntity(deepLink.queryParameters['entityId']);
            // //get global state
            // // add entity to favuorites and show favs list.
            // bool entityContains = false;
            // for (int i = 0; i < gs.currentUser.favourites.length; i++) {
            //   if (gs.currentUser.favourites[i].entityId == entityId) {
            //     entityContains = true;
            //     break;
            //   } else
            //     continue;
            // }
            // if (!entityContains) {
            //   Utils.showMyFlushbar(context, Icons.info, Duration(seconds: 3),
            //       "Processing...", "");
            //   EntityService()
            //       .addEntityToUserFavourite(entity.getMetaEntity())
            //       .then((value) {
            //     if (value) {
            //       gs.currentUser.favourites.add(entity.getMetaEntity());
            //     } else
            //       print("Entity can't be added to Favorites");
            //   }).catchError((onError) {
            //     Utils.showMyFlushbar(context, Icons.info, Duration(seconds: 3),
            //         "Oops error...", "");
            //   });
            // } else {
            //   Utils.showMyFlushbar(context, Icons.info, Duration(seconds: 3),
            //       "Entity is already present in your Favourites!!", "");
            // }
            // Navigator.pushReplacement(context,
            //     MaterialPageRoute(builder: (context) => FavsListPage()));
            addEntityToFavs(context, entityId);
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

  void addEntityToFavs(BuildContext context, String id) async {
    Entity entity = await getEntity(id);
    GlobalState gs = await GlobalState.getGlobalState();

    bool entityContains = false;
    for (int i = 0; i < gs.currentUser.favourites.length; i++) {
      if (gs.currentUser.favourites[i].entityId == id) {
        entityContains = true;
        break;
      } else
        continue;
    }
    if (!entityContains) {
      Utils.showMyFlushbar(context, Icons.info, Duration(seconds: 3),
          "Processing...", "Hold on.");
      bool result = await EntityService()
          .addEntityToUserFavourite(entity.getMetaEntity());

      if (result) {
        gs.currentUser.favourites.add(entity.getMetaEntity());
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (context) => FavsListPage()));
      } else {
        print("Oops.. Entity can't be added to Favorites");

        Utils.showMyFlushbar(
            context,
            Icons.info,
            Duration(seconds: 3),
            "Oops!! Error in adding this entity to your favorites!!",
            "Try again later.");
      }
    } else {
      Utils.showMyFlushbar(context, Icons.info, Duration(seconds: 3),
          "Entity is already present in your Favourites!!", "");
    }
  }
}
