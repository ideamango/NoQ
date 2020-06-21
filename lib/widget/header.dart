import 'package:flutter/material.dart';
import 'package:noq/constants.dart';

import 'package:noq/pages/SearchStoresPage.dart';
import 'package:noq/pages/allPagesWidgets.dart';

import 'package:noq/style.dart';
import 'package:noq/widget/appbar.dart';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';

class Header extends StatefulWidget {
  @override
  _HeaderState createState() => _HeaderState();
}

class _HeaderState extends State<Header> {
  final GlobalKey _scaffoldKey = new GlobalKey();
  SharedPreferences _prefs;
  PageController _pageController;
  int _page = 0;

  List drawerItems = [
    {
      "icon": Icons.account_circle,
      "name": "My Account",
    },

    {"icon": Icons.home, "name": "Manage Apartment"},
    {"icon": Icons.store, "name": "Manage Commercial Space"},
    {"icon": Icons.business, "name": "Manage Office"},

    {
      "icon": Icons.notifications,
      "name": "Notifications",
    },
    {
      "icon": Icons.grade,
      "name": "Rate our app",
    },
    {
      "icon": Icons.help_outline,
      "name": "Need Help?",
    },
    {
      "icon": Icons.share,
      "name": "Share our app",
    },
    // {
    //   "icon": Icons.exit_to_app,
    //   "name": "Logout",
    // },
  ];
  //Getting dummy list of stores from store class and storing in local variable
  //List<StoreAppData> _stores = getLocalStoreList();
  int i;

  var fUserProfile;
  TextStyle optionStyle = TextStyle(fontSize: 30, fontWeight: FontWeight.bold);
  String _phone;
  int _index = 0;
  int _botBarIndex = 0;
  int _pageIndex = 0;
  String _userName;
  String _userId;
  String _userAdrs;
  String _appBarTitle;

  DateTime dateTime = DateTime.now();
  final dtFormat = new DateFormat('dd');
  final compareDateFormat = new DateFormat('YYYYMMDD');

  List<DateTime> _dateList = new List<DateTime>();

  void navigationTapped(int page) {
    _pageController.jumpToPage(page);
  }

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: 8);
    // _initializeUserProfile();
  }

  @override
  void dispose() {
    super.dispose();
    _pageController.dispose();
  }

  void onPageChanged(int page) {
    setState(() {
      _page = page;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: CustomAppBar(),
      body: Center(
        child: PageView(
          physics: NeverScrollableScrollPhysics(),
          controller: _pageController,
          onPageChanged: onPageChanged,
          children: <Widget>[
            // _userAccount(),
            // _manageApartmentPage(),
            // _manageCommSpacePage(),
            // _manageOffSpacePage(),
            // _userNotifications(),
            // _rateApp(),
            // _needHelp(),
            // _shareApp(),
            _userHomePage(),
            SearchStoresPage(forPage: 'Search'),
            SearchStoresPage(forPage: 'Favourite'),
            _userAccount(),
          ],
        ),
      ),
      drawer: Drawer(
        child: ListView(
          children: <Widget>[
            DrawerHeader(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  RichText(
                    text: TextSpan(
                        style: whiteBoldTextStyle1,
                        children: <TextSpan>[
                          TextSpan(text: drawerHeaderTxt11),
                          TextSpan(
                              text: drawerHeaderTxt12,
                              style: highlightBoldTextStyle),
                          TextSpan(text: drawerHeaderTxt21),
                          TextSpan(
                              text: drawerHeaderTxt22,
                              style: highlightBoldTextStyle),
                          TextSpan(
                            text: drawerHeaderTxt31,
                          ),
                          TextSpan(
                            text: drawerHeaderTxt32,
                          ),
                          TextSpan(
                              text: drawerHeaderTxt41,
                              style: highlightBoldTextStyle),
                        ]),
                  ),
                ],
              ),
              // child: Text('Hello $_userName !!', style: inputTextStyle),
              decoration: BoxDecoration(
                color: Colors.teal,
              ),
            ),
            ListView.builder(
              physics: NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              itemCount: drawerItems.length,
              itemBuilder: (BuildContext context, int index) {
                Map item = drawerItems[index];
                if (item['children'] != null) {
                  return ExpansionTile(
                    leading: Icon(
                      item['icon'],
                      color: _page == index
                          ? highlightColor
                          : Theme.of(context).textTheme.title.color,
                    ),
                    title: Text(
                      item['name'],
                      style: TextStyle(
                        color: _page == index
                            ? highlightColor
                            : Theme.of(context).textTheme.title.color,
                      ),
                    ),
                    children: <Widget>[
                      ListView.builder(
                        physics: NeverScrollableScrollPhysics(),
                        shrinkWrap: true,
                        itemCount: item['children'].length,
                        itemBuilder: (BuildContext context, int i) {
                          int pageIndex = drawerItems.length - 1 + i;
                          Map subItem = item['children'][i];
                          print('........' + i.toString());
                          return ListTile(
                            leading: Icon(
                              subItem['icon'],
                              color: _page == index
                                  ? highlightColor
                                  : Theme.of(context).textTheme.title.color,
                            ),
                            title: Text(
                              subItem['name'],
                              style: TextStyle(
                                color: _page == index
                                    ? highlightColor
                                    : Theme.of(context).textTheme.title.color,
                              ),
                            ),
                            onTap: () {
                              _pageController.jumpToPage(pageIndex);
                              Navigator.pop(context);
                            },
                          );
                        },
                      ),
                    ],
                  );
                } else {
                  return ListTile(
                    leading: Icon(
                      item['icon'],
                      color: _page == index
                          ? highlightColor
                          : Theme.of(context).textTheme.title.color,
                    ),
                    title: Text(
                      item['name'],
                      style: TextStyle(
                        color: _page == index
                            ? highlightColor
                            : Theme.of(context).textTheme.title.color,
                      ),
                    ),
                    onTap: () {
                      _pageController.jumpToPage(index);
                      Navigator.pop(context);
                    },
                  );
                }
              },
            ),
          ],
        ),
      ),
      //   bottomNavigationBar: buildBottomItems(),
    );
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
  //     _pageIndex = (drawerItems.length) + index;
  //     _botBarIndex = index;
  //   });
  //   _pageController.animateToPage(
  //     _pageIndex,
  //     duration: Duration(
  //       milliseconds: 200,
  //     ),
  //     curve: Curves.easeIn,
  //   );
  // }

  Widget _userHomePage() {
    return userHomePage(context);
  }

  Widget _manageApartmentPage() {
    return manageApartmentPages(context);
  }

  Widget _manageCommSpacePage() {
    return Container(
      child: Center(
        child: Text("Add new Comm"),
      ),
    );
  }

  Widget _manageOffSpacePage() {
    return Container(
      child: Center(
        child: Text("Add new Office"),
      ),
    );
  }

  Widget _rateApp() {
    return rateAppPage(context);
  }

  Widget _needHelp() {
    return needHelpPage(context);
  }

  Widget _shareApp() {
    return shareAppPage(context);
  }

  Widget _userAccount() {
    return userAccountPage(context);
  }
}
