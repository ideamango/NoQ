import 'package:flutter/material.dart';
import '../pages/search_entity_page.dart';
import '../pages/favs_list_page.dart';
import '../pages/user_account_page.dart';
import '../style.dart';
import '../userHomePage.dart';
import '../widget/page_animation.dart';

class CustomBottomBar extends StatefulWidget {
  final int barIndex;
  CustomBottomBar({Key? key, required this.barIndex}) : super(key: key);
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
          label: 'Home',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.search),
          label: 'Search',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.favorite),
          label: 'Favourites',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.account_circle),
          label: 'My Account',
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
            Navigator.of(context)
                .push(PageNoAnimation.createRoute(UserHomePage()));
          }
          break;
        case 1:
          {
            // Navigator.push(context,
            //  MaterialPageRoute(builder: (context) => UserHomePage()));
            Navigator.of(context)
                .push(PageNoAnimation.createRoute(SearchEntityPage()));
          }
          break;
        case 2:
          {
            //  Navigator.push(context,
            //   MaterialPageRoute(builder: (context) => UserHomePage()));
            Navigator.of(context)
                .push(PageNoAnimation.createRoute(FavsListPage()));
          }
          break;
        case 3:
          {
            // Navigator.push(context,
            //   MaterialPageRoute(builder: (context) => UserHomePage()));
            Navigator.of(context)
                .push(PageNoAnimation.createRoute(UserAccountPage()));
          }
          break;

          // default:
          //   {
          //     Navigator.push(context,
          //         MaterialPageRoute(builder: (context) => UserHomePage()));
          //   }
          break;
      }
    }
  }
}
