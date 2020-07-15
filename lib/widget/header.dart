import 'package:flutter/material.dart';
import 'package:noq/constants.dart';
import 'package:noq/pages/about_page.dart';
import 'package:noq/pages/help_page.dart';
import 'package:noq/pages/manage_apartment_list_page.dart';
import 'package:noq/pages/notifications_page.dart';
import 'package:noq/pages/contact_us.dart';
import 'package:noq/pages/share_app_page.dart';
import 'package:noq/pages/userAccountPage.dart';
import 'package:noq/style.dart';
import 'package:intl/intl.dart';

class CustomDrawer extends StatefulWidget {
  @override
  _CustomDrawerState createState() => _CustomDrawerState();
}

class _CustomDrawerState extends State<CustomDrawer> {
  PageController _pageController;
  int _page = 0;

  List drawerItems = [
    {
      "icon": Icons.account_circle,
      "name": "My Account",
      "pageRoute": UserAccountPage(),
    },
    {
      "icon": Icons.store,
      "name": "Manage Premises",
      "pageRoute": ManageApartmentsListPage(),
    },
    // {
    //   "icon": Icons.notifications,
    //   "name": "Notifications",
    //   "pageRoute": UserNotificationsPage(),
    // },
    {
      "icon": Icons.help_outline,
      "name": "FAQs",
      "pageRoute": HelpPage(),
    },
    {
      "icon": Icons.share,
      "name": "Rate & Share",
      "pageRoute": ShareAppPage(),
    },
    {
      "icon": Icons.people,
      "name": "Contact Us",
      "pageRoute": ContactUsPage(),
    },
    {
      "icon": Icons.info,
      "name": "About",
      "pageRoute": AboutUsPage(),
    },
  ];
  //Getting dummy list of stores from store class and storing in local variable
  //List<StoreAppData> _stores = getLocalStoreList();
  int i;

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
                            ),
                            TextSpan(text: drawerHeaderTxt21),
                            TextSpan(
                              text: drawerHeaderTxt22,
                            ),
                            TextSpan(
                              text: drawerHeaderTxt31,
                            ),
                            TextSpan(
                              text: drawerHeaderTxt32,
                            ),
                            TextSpan(
                              text: drawerHeaderTxt33,
                            ),
                            TextSpan(
                              text: drawerHeaderTxt41,
                            ),
                            TextSpan(
                              text: drawerHeaderTxt42,
                            ),
                          ]),
                    ),
                  ],
                ),
                // child: Text('Hello $_userName !!', style: inputTextStyle),
                decoration: gradientBackground),
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
    );
  }
}
