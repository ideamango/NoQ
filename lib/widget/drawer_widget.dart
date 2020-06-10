import 'package:flutter/material.dart';
import 'package:noq/style.dart';

class DrawerWidget extends StatefulWidget {
  @override
  _DrawerWidgetState createState() => _DrawerWidgetState();
}

class _DrawerWidgetState extends State<DrawerWidget> {
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
  @override
  Widget build(BuildContext context) {
    return Drawer(
        child: ListView(
      children: <Widget>[
        DrawerHeader(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              Text('Stay safe !!', style: whiteBoldTextStyle1),
              Text('Avoid rush hours !!', style: whiteBoldTextStyle1),
              Text('Save time !!', style: whiteBoldTextStyle1),
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
                      : Theme.of(context).textTheme.subtitle1.color,
                ),
                title: Text(
                  item['name'],
                  style: TextStyle(
                    color: _page == index
                        ? highlightColor
                        : Theme.of(context).textTheme.subtitle1.color,
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
                              : Theme.of(context).textTheme.subtitle1.color,
                        ),
                        title: Text(
                          subItem['name'],
                          style: TextStyle(
                            color: _page == index
                                ? highlightColor
                                : Theme.of(context).textTheme.subtitle1.color,
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
                      : Theme.of(context).textTheme.subtitle1.color,
                ),
                title: Text(
                  item['name'],
                  style: TextStyle(
                    color: _page == index
                        ? highlightColor
                        : Theme.of(context).textTheme.subtitle1.color,
                  ),
                ),
                onTap: () {
                  //_pageController.jumpToPage(index);
                  String returnIndex = index.toString();
                  Navigator.of(context).pop(returnIndex);
                },
              );
            }
          },
        ),
      ],
    ));
  }
}
