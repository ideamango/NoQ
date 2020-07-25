import 'package:flutter/material.dart';
import 'package:noq/db/db_service/token_service.dart';
import 'package:noq/global_state.dart';
import 'package:noq/userHomePage.dart';
import 'db/db_model/user_token.dart';
import 'package:noq/repository/local_db_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LandingPage extends StatefulWidget {
  @override
  _LandingPageState createState() => _LandingPageState();
}

class _LandingPageState extends State<LandingPage> {
  SharedPreferences _prefs;
  int i;
  var _userProfile;
  var fUserProfile;

  String _userId;
  String _phone;
  GlobalState _state;

  _initializeUserProfile() async {
    //Fetch bookings for current user
    DateTime fromDate = DateTime.now().subtract(new Duration(days: 10));
    DateTime toDate = DateTime.now().add(new Duration(days: 10));
    List<UserToken> bookings =
        await TokenService().getAllTokensForCurrentUser(fromDate, toDate);
    //Set bookings, conf for current user
    _state = await GlobalState.getGlobalState();
    _state.bookings = bookings;

    //getFromPrefs();
  }

  @override
  void initState() {
    super.initState();
    _initializeUserProfile();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return UserHomePage();
  }
}
