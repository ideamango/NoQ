import 'package:flutter/material.dart';
import 'package:noq/db/db_service/token_service.dart';
import 'package:noq/global_state.dart';
import 'package:noq/userHomePage.dart';
import 'db/db_model/user_token.dart';
import 'package:noq/models/localDB.dart';
import 'package:noq/repository/local_db_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LandingPage extends StatefulWidget {
  @override
  _LandingPageState createState() => _LandingPageState();
}

class _LandingPageState extends State<LandingPage> {
  // final GlobalKey _scaffoldKey = new GlobalKey();

  // PageController _pageController;
  //int _page = 0;

  // List drawerItems = [
  //   {
  //     "icon": Icons.account_circle,
  //     "name": "My Account",
  //     "pageRoute": UserAccountPage(),
  //   },
  //   {
  //     "icon": Icons.home,
  //     "name": "Manage Apartment",
  //     "pageRoute": ManageApartmentsListPage(),
  //   },
  //   {
  //     "icon": Icons.store,
  //     "name": "Manage Commercial Space",
  //     "pageRoute": ManageApartmentsListPage(),
  //   },
  //   {
  //     "icon": Icons.business,
  //     "name": "Manage Office",
  //     "pageRoute": ManageApartmentsListPage(),
  //   },
  //   {
  //     "icon": Icons.notifications,
  //     "name": "Notifications",
  //     "pageRoute": UserNotificationsPage(),
  //   },
  //   {
  //     "icon": Icons.grade,
  //     "name": "Rate our app",
  //     "pageRoute": RateAppPage(),
  //   },
  //   {
  //     "icon": Icons.help_outline,
  //     "name": "Need Help?",
  //     "pageRoute": HelpPage(),
  //   },
  //   {
  //     "icon": Icons.share,
  //     "name": "Share our app",
  //     "pageRoute": ShareAppPage(),
  //   },
  //   {
  //     "icon": Icons.info,
  //     "name": "About",
  //     "pageRoute": AboutUsPage(),
  //   },
  // ];
  //Getting dummy list of stores from store class and storing in local variable
  //List<StoreAppData> _stores = getLocalStoreList();
  SharedPreferences _prefs;
  int i;
  var _userProfile;
  var fUserProfile;

  String _userId;
  String _phone;
  GlobalState _state;
  //TextStyle optionStyle = TextStyle(fontSize: 30, fontWeight: FontWeight.bold);

  // int _index = 0;
  // int _botBarIndex = 0;

  // DateTime dateTime = DateTime.now();
  // final dtFormat = new DateFormat('dd');
  // final compareDateFormat = new DateFormat('YYYYMMDD');

  //List<DateTime> _dateList = new List<DateTime>();

  // void navigationTapped(int page) {
  //   _pageController.jumpToPage(page);
  // }
  void getFromPrefs() async {
    var userProfile;
//Read data from global variables
    _prefs = await SharedPreferences.getInstance();
    _phone = _prefs.getString("phone");
    // _userName = _prefs.getString("userName");
    // _userId = _prefs.getString("userId");
    //_userAdrs = _prefs.getString("userAdrs");

//Fetch data from file and then validate phone number - if same,load all other details
    await readData().then((fUser) {
      fUserProfile = fUser;
    });

    if (fUserProfile != null) {
      userProfile = fUserProfile;
    } else {
      //If not on server then create new user object.
//Start - Save User profile in file

      List<BookingAppData> upcomingBookings = new List();

      List<EntityAppData> localSavedStores = new List<EntityAppData>();

      List<EntityAppData> managedStores = new List<EntityAppData>();

      //REMOVE default values
      _userId = "ForTesting123";

      userProfile = new UserAppData(
          _userId,
          _phone,
          upcomingBookings,
          localSavedStores,
          managedStores,
          new SettingsAppData(notificationOn: true));
    }
    setState(() {
      _userProfile = userProfile;
    });
    //write userProfile to file
    writeData(_userProfile);

    setState(() {
      //_userName = (_userProfile != null) ? _userProfile.name : 'User';
      //_userId = (_userProfile != null) ? _userProfile.id : '0';
    });
    // _prefs.setString("userName", _userName);
    _prefs.setString("userId", _userId);

    print('UserProfile in file $_userProfile');

//End - Save User profile in file
  }

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
