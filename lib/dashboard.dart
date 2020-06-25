import 'package:flutter/material.dart';
import 'package:noq/constants.dart';
import 'package:noq/db/db_service/db_main.dart';
import 'package:noq/db/db_service/token_service.dart';
import 'package:noq/pages/SearchStoresPage.dart';
import 'package:noq/pages/about_page.dart';
import 'package:noq/pages/allPagesWidgets.dart';
import 'package:noq/pages/help_page.dart';
import 'package:noq/pages/manage_apartment_list_page.dart';
import 'package:noq/pages/manage_apartment_page.dart';
import 'package:noq/pages/notifications_page.dart';
import 'package:noq/pages/rate_app.dart';
import 'package:noq/pages/share_app_page.dart';
import 'package:noq/pages/userAccountPage.dart';
import 'package:noq/services/authService.dart';
import 'package:noq/userHomePage.dart';
import 'package:noq/widget/appbar.dart';
import 'package:noq/widget/bottom_nav_bar.dart';
import 'package:noq/widget/header.dart';

import 'db/db_model/entity_slots.dart';
import 'db/db_model/user_token.dart';
import 'style.dart';

import 'package:noq/models/localDB.dart';
import 'package:noq/repository/local_db_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';

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
  String _userName;
  String _userId;
  String _phone;
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

  _initializeUserProfile() async {
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
    }
    //  else {
    //   //TODO:fetch from server

    //Save in local DB objects and file for perusal.
    // writeData(_userProfile);
    //   _prefs.setString("userName", _userName);
    // _prefs.setString("userId", _userId);
    //}

    else {
      //If not on server then create new user object.
//Start - Save User profile in file

      List<BookingAppData> upcomingBookings = new List();

      List<EntityAppData> localSavedStores = new List<EntityAppData>();

      List<EntityAppData> managedStores = new List<EntityAppData>();

      //REMOVE default values
      _userId = "ForTesting123";
      _userName = 'User';

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

  @override
  void initState() {
    super.initState();

    // _pageController = PageController(initialPage: 0);
    _initializeUserProfile();
  }

  @override
  void dispose() {
    super.dispose();
    // _pageController.dispose();
  }

  // void onPageChanged(int page) {
  //   setState(() {
  //     _page = page;
  //   });
  // }

  @override
  Widget build(BuildContext context) {
    return UserHomePage();
    // MaterialApp(
    //   title: 'My Dashboard',
    //   //theme: ThemeData.light().copyWith(),
    //   home: Scaffold(
    //     key: _scaffoldKey,
    //     //  appBar: CustomAppBar(),

    //     body:
    //      Center(
    //       child:
    // PageView(
    //   physics: NeverScrollableScrollPhysics(),
    //   controller: _pageController,
    //   onPageChanged: onPageChanged,
    //   children: <Widget>[
    //     // _userAccount(),
    //     // _manageApartmentPage(),
    //     // _manageCommSpacePage(),
    //     // _manageOffSpacePage(),
    //     // _userNotifications(),
    //     // _rateApp(),
    //     // _needHelp(),
    //     // _shareApp(),
    //     _userHomePage(),
    //     //_storesListPage(),
    //     SearchStoresPage(forPage: 'Search'),
    //     SearchStoresPage(forPage: 'Favourite'),
    //     _userAccount(),
    //   ],
    // ),

    // ),
    // drawer: CustomDrawer(),
    // Drawer(
    //   child: ListView(
    //     children: <Widget>[
    //       DrawerHeader(
    //         child: Column(
    //           mainAxisAlignment: MainAxisAlignment.spaceEvenly,
    //           children: <Widget>[
    //             RichText(
    //               text: TextSpan(
    //                   style: whiteBoldTextStyle1,
    //                   children: <TextSpan>[
    //                     TextSpan(text: drawerHeaderTxt11),
    //                     TextSpan(
    //                         text: drawerHeaderTxt12,
    //                         style: highlightBoldTextStyle),
    //                     TextSpan(text: drawerHeaderTxt21),
    //                     TextSpan(
    //                         text: drawerHeaderTxt22,
    //                         style: highlightBoldTextStyle),
    //                     TextSpan(
    //                       text: drawerHeaderTxt31,
    //                     ),
    //                     TextSpan(
    //                       text: drawerHeaderTxt32,
    //                     ),
    //                     TextSpan(
    //                         text: drawerHeaderTxt41,
    //                         style: highlightBoldTextStyle),
    //                   ]),
    //             ),
    //           ],
    //         ),
    //         // child: Text('Hello $_userName !!', style: inputTextStyle),
    //         decoration: BoxDecoration(
    //           color: Colors.teal,
    //         ),
    //       ),
    //       ListView.builder(
    //         physics: NeverScrollableScrollPhysics(),
    //         shrinkWrap: true,
    //         itemCount: drawerItems.length,
    //         itemBuilder: (BuildContext context, int index) {
    //           Map item = drawerItems[index];
    //           if (item['children'] != null) {
    //             return ExpansionTile(
    //               leading: Icon(
    //                 item['icon'],
    //                 color: _page == index
    //                     ? highlightColor
    //                     : Theme.of(context).textTheme.title.color,
    //               ),
    //               title: Text(
    //                 item['name'],
    //                 style: TextStyle(
    //                   color: _page == index
    //                       ? highlightColor
    //                       : Theme.of(context).textTheme.title.color,
    //                 ),
    //               ),
    //               children: <Widget>[
    //                 ListView.builder(
    //                   physics: NeverScrollableScrollPhysics(),
    //                   shrinkWrap: true,
    //                   itemCount: item['children'].length,
    //                   itemBuilder: (BuildContext context, int i) {
    //                     int pageIndex = drawerItems.length - 1 + i;
    //                     Map subItem = item['children'][i];
    //                     print('........' + i.toString());
    //                     return ListTile(
    //                       leading: Icon(
    //                         subItem['icon'],
    //                         color: _page == index
    //                             ? highlightColor
    //                             : Theme.of(context).textTheme.title.color,
    //                       ),
    //                       title: Text(
    //                         subItem['name'],
    //                         style: TextStyle(
    //                           color: _page == index
    //                               ? highlightColor
    //                               : Theme.of(context).textTheme.title.color,
    //                         ),
    //                       ),
    //                       onTap: () {
    //                         //_pageController.jumpToPage(pageIndex);
    //                         Navigator.pushReplacementNamed(
    //                             context, subItem['pageRoute']);
    //                         Navigator.pop(context);
    //                       },
    //                     );
    //                   },
    //                 ),
    //               ],
    //             );
    //           } else {
    //             return ListTile(
    //               leading: Icon(
    //                 item['icon'],
    //                 color: _page == index
    //                     ? highlightColor
    //                     : Theme.of(context).textTheme.title.color,
    //               ),
    //               title: Text(
    //                 item['name'],
    //                 style: TextStyle(
    //                   color: _page == index
    //                       ? highlightColor
    //                       : Theme.of(context).textTheme.title.color,
    //                 ),
    //               ),
    //               onTap: () {
    //                 //   _pageController.jumpToPage(index);
    //                 Navigator.pop(context);
    //                 Navigator.push(
    //                     context,
    //                     MaterialPageRoute(
    //                         builder: (context) => item['pageRoute']));
    //               },
    //             );
    //           }
    //         },
    //       ),
    //     ],
    //   ),
    // ),
    // bottomNavigationBar: CustomBottomBar(
    //   barIndex: 0,
    // ),
    // floatingActionButton: FloatingActionButton(
    //   onPressed: dbCall,
    //   tooltip: 'Increment',
    //   child: Icon(Icons.add),
    // ),
    //   ),
    // );
  }

  // BottomNavigationBar buildBottomItems() {
  //   return BottomNavigationBar(
  //     onTap: _onBottomBarItemTapped,
  //     currentIndex: _botBarIndex,
  //     type: BottomNavigationBarType.fixed,
  //     items: const <BottomNavigationBarItem>[
  //       BottomNavigationBarItem(
  //         icon: Icon(Icons.home),
  //         title: Text('Home'),
  //       ),
  //       BottomNavigationBarItem(
  //         icon: Icon(Icons.search),
  //         title: Text('Search'),
  //       ),
  //       BottomNavigationBarItem(
  //         icon: Icon(Icons.favorite),
  //         title: Text('My Favourites'),
  //       ),
  //       BottomNavigationBarItem(
  //         icon: Icon(Icons.account_circle),
  //         title: Text('My Account'),
  //       ),
  //     ],
  //     unselectedItemColor: unselectedColor,
  //     selectedItemColor: highlightColor,
  //   );
  // }

  // void _onBottomBarItemTapped(int index) {
  //   setState(() {
  //     //_pageIndex = index;
  //     _botBarIndex = index;
  //   });

  //   switch (index) {
  //     case 0:
  //       {
  //         Navigator.push(
  //             context, MaterialPageRoute(builder: (context) => UserHomePage()));
  //       }
  //       break;

  //     case 1:
  //       {
  //         Navigator.push(
  //             context,
  //             MaterialPageRoute(
  //                 builder: (context) => SearchStoresPage(forPage: 'Search')));
  //       }
  //       break;
  //     case 2:
  //       {
  //         Navigator.push(
  //             context,
  //             MaterialPageRoute(
  //                 builder: (context) =>
  //                     SearchStoresPage(forPage: 'Favourite')));
  //       }
  //       break;
  //     case 3:
  //       {
  //         Navigator.push(context,
  //             MaterialPageRoute(builder: (context) => UserAccountPage()));
  //       }
  //       break;

  //     default:
  //       {
  //         Navigator.push(
  //             context, MaterialPageRoute(builder: (context) => UserHomePage()));
  //       }
  //       break;
  //   }
  //   //Navigator.pop(context);
  //   // Navigator.push(
  //   //     context, MaterialPageRoute(builder: (context) => UserHomePage()));
  //   // _pageController.animateToPage(
  //   //   _pageIndex,
  //   //   duration: Duration(
  //   //     milliseconds: 200,
  //   //   ),
  //   //   curve: Curves.easeIn,
  //   // );
  // }

  // Widget _userHomePage() {
  //   return userHomePage(context);
  // }

  // Widget _userAccount() {
  //   return userAccountPage(context);
  // }
}
