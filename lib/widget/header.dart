import 'package:flutter/material.dart';
import '../constants.dart';
import '../pages/about_page.dart';
import '../pages/business_info_page.dart';
import '../pages/help_page.dart';
import '../pages/manage_entity_list_page.dart';
import '../pages/notifications_page.dart';
import '../pages/contact_us.dart';
import '../pages/privacy_policy.dart';
import '../pages/share_app_page.dart';
import '../pages/terms_of_use.dart';
import '../pages/user_account_page.dart';
import '../style.dart';
import 'package:intl/intl.dart';
import '../widget/page_animation.dart';

class CustomDrawer extends StatefulWidget {
  final String? phone;
  CustomDrawer({Key? key, required this.phone}) : super(key: key);

  @override
  _CustomDrawerState createState() => _CustomDrawerState();
}

class _CustomDrawerState extends State<CustomDrawer> {
  late PageController _pageController;
  int _page = 0;
  String? _phone;
  late List drawerItems;
  //Getting dummy list of stores from store class and storing in local variable
  //List<StoreAppData> _stores = getLocalStoreList();
  int? i;

  void navigationTapped(int page) {
    _pageController.jumpToPage(page);
  }

  @override
  void initState() {
    super.initState();
    _phone = widget.phone;
    _pageController = PageController(initialPage: 8);
    drawerItems = [
      {
        "icon": Icons.account_circle,
        "name": "My Account",
        "pageRoute": UserAccountPage(),
      },
      {
        "icon": Icons.store,
        "name": "Manage your Business/Place",
        "pageRoute": ManageEntityListPage(),
      },
      // {
      //   "icon": Icons.info_outline,
      //   "name": "View Business Statistics",
      //   "pageRoute": InfoPageForBusinesses(),
      // },

      {
        "icon": Icons.contact_mail,
        "name": "Contact Us",
        "pageRoute": ContactUsPage(
          showAppBar: true,
        ),
      },
      {
        "icon": Icons.share,
        "name": "Share",
        "pageRoute": ShareAppPage(),
      },
      {
        "icon": Icons.description,
        "name": "Privacy Policy",
        "pageRoute": PrivacyPolicyPage(),
      },
      {
        "icon": Icons.description,
        "name": "Terms of use",
        "pageRoute": TermsOfUsePage(),
      },
      {
        "icon": Icons.help_outline,
        "name": "Help",
        "pageRoute": HelpPage(),
      },
      {
        "icon": Icons.info,
        "name": "About Us",
        "pageRoute": AboutUsPage(),
      },
    ];
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
                          style: TextStyle(color: Colors.white, fontSize: 18),
                          children: <TextSpan>[
                            TextSpan(text: drawerHeaderTxt),
                            TextSpan(
                                text: _phone,
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold)),
                            // TextSpan(text: '\n'),

                            // TextSpan(
                            //   text: drawerHeaderTxt12,
                            // ),
                            // TextSpan(text: drawerHeaderTxt21),
                            // TextSpan(
                            //   text: drawerHeaderTxt22,
                            // ),
                            // TextSpan(
                            //   text: drawerHeaderTxt31,
                            // ),
                            // TextSpan(
                            //   text: drawerHeaderTxt32,
                            // ),
                            // TextSpan(
                            //   text: drawerHeaderTxt33,
                            // ),
                            // TextSpan(
                            //   text: drawerHeaderTxt41,
                            // ),
                            // TextSpan(
                            //   text: drawerHeaderTxt42,
                            // ),
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
                        : Theme.of(context).textTheme.headline6!.color,
                  ),
                  title: Text(
                    item['name'],
                    style: TextStyle(
                      color: _page == index
                          ? highlightColor
                          : Theme.of(context).textTheme.headline6!.color,
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
                                : Theme.of(context).textTheme.headline6!.color,
                          ),
                          title: Text(
                            subItem['name'],
                            style: TextStyle(
                              color: _page == index
                                  ? highlightColor
                                  : Theme.of(context)
                                      .textTheme
                                      .headline6!
                                      .color,
                            ),
                          ),
                          onTap: () {
                            //_pageController.jumpToPage(pageIndex);
                            // Navigator.pop(context);
                            Navigator.of(context).push(
                                PageNoAnimation.createRoute(
                                    subItem['pageRoute']));
                            // Navigator.pop(context);
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
                        : Theme.of(context).textTheme.headline6!.color,
                  ),
                  title: Text(
                    item['name'],
                    style: TextStyle(
                      color: _page == index
                          ? highlightColor
                          : Theme.of(context).textTheme.headline6!.color,
                    ),
                  ),
                  onTap: () {
                    // _pageController.jumpToPage(index);
                    //Navigator.pop(context);
                    Navigator.of(context)
                        .push(PageNoAnimation.createRoute(item['pageRoute']));
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
