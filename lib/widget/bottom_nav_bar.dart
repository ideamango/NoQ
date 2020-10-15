import 'package:flutter/material.dart';
import 'package:noq/dashboard.dart';
import 'package:noq/db/db_model/entity.dart';
import 'package:noq/pages/SearchStoresPage.dart';
import 'package:noq/pages/favs_list_page.dart';
import 'package:noq/pages/userAccountPage.dart';
import 'package:noq/style.dart';
import 'package:noq/userHomePage.dart';

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
    if (_botBarIndex != index) {
      setState(() {
        _botBarIndex = index;
      });

      Navigator.pop(context);
      switch (index) {
        case 0:
          {
            Navigator.push(context,
                MaterialPageRoute(builder: (context) => UserHomePage()));
          }
          break;
        case 1:
          {
            Navigator.push(context,
                MaterialPageRoute(builder: (context) => SearchStoresPage()));
          }
          break;
        case 2:
          {
            Navigator.push(context,
                MaterialPageRoute(builder: (context) => FavsListPage()));
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
            Navigator.push(context,
                MaterialPageRoute(builder: (context) => UserHomePage()));
          }
          break;
      }
    }
  }
}
