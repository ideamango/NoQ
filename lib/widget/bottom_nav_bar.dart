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
import 'package:noq/userHomePage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';

class CustomBottomBar extends StatefulWidget {
  final int barIndex;
  CustomBottomBar({Key key, @required this.barIndex}) : super(key: key);
  @override
  _CustomBottomBarState createState() => _CustomBottomBarState();
}

class _CustomBottomBarState extends State<CustomBottomBar> {
  int _botBarIndex = 0;

  @override
  void initState() {
    super.initState();
    _botBarIndex = widget.barIndex;
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      onTap: _onBottomBarItemTapped,
      currentIndex: _botBarIndex,
      type: BottomNavigationBarType.fixed,
      items: const <BottomNavigationBarItem>[
        BottomNavigationBarItem(
          icon: Icon(Icons.home),
          title: Text('Home'),
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.search),
          title: Text('Search'),
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.favorite),
          title: Text('My Favourites'),
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.account_circle),
          title: Text('My Account'),
        ),
      ],
      unselectedItemColor: unselectedColor,
      selectedItemColor: highlightColor,
    );
  }

  void _onBottomBarItemTapped(int index) {
    setState(() {
      _botBarIndex = index;
    });
    Navigator.pop(context);
    switch (index) {
      case 0:
        {
          Navigator.push(
              context, MaterialPageRoute(builder: (context) => UserHomePage()));
        }
        break;

      case 1:
        {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => SearchStoresPage(forPage: 'Search')));
        }
        break;
      case 2:
        {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) =>
                      SearchStoresPage(forPage: 'Favourite')));
        }
        break;
      case 3:
        {
          Navigator.push(context,
              MaterialPageRoute(builder: (context) => UserAccountPage()));
        }
        break;

      default:
        {
          Navigator.push(
              context, MaterialPageRoute(builder: (context) => UserHomePage()));
        }
        break;
    }
    //Navigator.pop(context);
    // Navigator.push(
    //     context, MaterialPageRoute(builder: (context) => UserHomePage()));
    // _pageController.animateToPage(
    //   _pageIndex,
    //   duration: Duration(
    //     milliseconds: 200,
    //   ),
    //   curve: Curves.easeIn,
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
