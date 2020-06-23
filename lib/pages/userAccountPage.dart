import 'package:flutter/material.dart';
import 'package:noq/pages/notifications_page.dart';
import 'package:noq/style.dart';
import 'package:noq/widget/bottom_nav_bar.dart';

class UserAccountPage extends StatefulWidget {
  @override
  _UserAccountPageState createState() => _UserAccountPageState();
}

class _UserAccountPageState extends State<UserAccountPage> {
  int _page = 0;
  PageController _pageController;
  List drawerItems = [
    {
      "icon": Icons.account_circle,
      "name": "My Account",
      "pageRoute": UserAccountPage(),
    },
    {
      "icon": Icons.notifications,
      "name": "Notifications",
      "pageRoute": UserNotificationsPage(),
    },
  ];

  void onPageChanged(int page) {
    setState(() {
      _page = page;
    });
  }

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

  @override
  Widget build(BuildContext context) {
    String title = "My Account";
    return MaterialApp(
      theme: ThemeData.light().copyWith(),
      home: Scaffold(
        endDrawer: Drawer(
          child: ListView(
            children: <Widget>[
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
                            // int pageIndex = drawerItems.length - 1 + i;
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
        ),
        appBar: AppBar(
          actions: [
            Builder(
              builder: (context) => IconButton(
                icon: Icon(Icons.filter),
                onPressed: () => Scaffold.of(context).openEndDrawer(),
                tooltip: MaterialLocalizations.of(context).openAppDrawerTooltip,
              ),
            ),
          ],
        ),
        body: Center(
          child: RaisedButton(
            child: Text("Back"),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
        bottomNavigationBar: CustomBottomBar(
          barIndex: 3,
        ),
      ),
    );
  }
}
