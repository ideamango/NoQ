import 'package:flutter/material.dart';
import 'package:noq/constants.dart';

import 'package:noq/pages/SearchStoresPage.dart';
import 'package:noq/pages/allPagesWidgets.dart';
import 'package:noq/pages/help_page.dart';
import 'package:noq/pages/manage_apartment_list_page.dart';
import 'package:noq/pages/notifications_page.dart';
import 'package:noq/pages/rate_app.dart';
import 'package:noq/pages/share_app_page.dart';
import 'package:noq/pages/userAccountPage.dart';

import 'package:noq/style.dart';
import 'package:noq/widget/appbar.dart';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';

class CustomDrawer extends StatefulWidget {
  @override
  _CustomDrawerState createState() => _CustomDrawerState();
}

class _CustomDrawerState extends State<CustomDrawer> {
  final GlobalKey _scaffoldKey = new GlobalKey();
  SharedPreferences _prefs;
  PageController _pageController;
  int _page = 0;

  List drawerItems = [
    {
      "icon": Icons.account_circle,
      "name": "My Account",
      "pageRoute": UserAccountPage(),
    },

    {
      "icon": Icons.home,
      "name": "Manage Apartment",
      "pageRoute": ManageApartmentsListPage(),
    },
    {
      "icon": Icons.store,
      "name": "Manage Commercial Space",
      "pageRoute": ManageApartmentsListPage(),
    },
    {
      "icon": Icons.business,
      "name": "Manage Office",
      "pageRoute": ManageApartmentsListPage(),
    },

    {
      "icon": Icons.notifications,
      "name": "Notifications",
      "pageRoute": UserNotificationsPage(),
    },
    {
      "icon": Icons.grade,
      "name": "Rate our app",
      "pageRoute": RateAppPage(),
    },
    {
      "icon": Icons.help_outline,
      "name": "Need Help?",
      "pageRoute": HelpPage(),
    },
    {
      "icon": Icons.share,
      "name": "Share our app",
      "pageRoute": ShareAppPage(),
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
    return Drawer(
      child: ListView(
        children: <Widget>[
          Container(
            height: 130,
            child: DrawerHeader(
              margin: EdgeInsets.all(0.0),
              padding: EdgeInsets.fromLTRB(8, 0, 8, 0),
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
                              style: highlightBoldTextStyle),
                          TextSpan(
                            text: drawerHeaderTxt33,
                          ),
                          TextSpan(
                            text: drawerHeaderTxt41,
                          ),
                          TextSpan(
                              text: drawerHeaderTxt42,
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
                            //_pageController.jumpToPage(pageIndex);
                            // Navigator.pop(context);
                            Navigator.pushReplacementNamed(
                                context, subItem['pageRoute']);
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
                    // _pageController.jumpToPage(index);
                    //Navigator.pop(context);
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => item['pageRoute']));
                  },
                );
              }
            },
          ),
        ],
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

}
