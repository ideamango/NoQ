import 'package:flutter/material.dart';
import 'package:map_launcher/map_launcher.dart';
import 'package:noq/repository/StoreRepository.dart';
import 'style.dart';
import 'models/Store.dart';
import 'view/allPagesWidgets.dart';

class LandingPage extends StatefulWidget {
  @override
  _LandingPageState createState() => _LandingPageState();
}

class _LandingPageState extends State<LandingPage> {
  PageController _pageController;
  int _page = 0;

  List drawerItems = [
    {
      "icon": Icons.account_circle,
      "name": "My Account",
    },
    {
      "icon": Icons.date_range,
      "name": "My Bookings",
    },
    {
      "icon": Icons.favorite,
      "name": "My favourite stores",
    },
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

  List<Store> _stores = getDummyList();
  int i;
  TextStyle optionStyle = TextStyle(fontSize: 30, fontWeight: FontWeight.bold);

  int _index = 0;
  int _botBarIndex = 0;
  int _pageIndex = 0;
  void navigationTapped(int page) {
    _pageController.jumpToPage(page);
  }

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: 7);
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
    return MaterialApp(
      title: 'My Dashboard',
      //theme: ThemeData.light().copyWith(),
      home: Scaffold(
          appBar: AppBar(title: Text(''), backgroundColor: Colors.indigo,
              //Theme.of(context).primaryColor,
              actions: <Widget>[]),
          body: Center(
            child: PageView(
              physics: NeverScrollableScrollPhysics(),
              controller: _pageController,
              onPageChanged: onPageChanged,
              children: <Widget>[
                _userAccount(),
                _userBookingPage(),
                _userFavStores(),
                _userNotifications(),
                _rateApp(),
                _needHelp(),
                _shareApp(),
                _userHomePage(),
                _storesListPage(),
                _userAccount(),
              ],
            ),
          ),
          drawer: Drawer(
            child: ListView(
              children: <Widget>[
                DrawerHeader(
                  child: Image.asset('logo.png'),
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor,
                  ),
                ),
                ListView.builder(
                  physics: NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  itemCount: drawerItems.length,
                  itemBuilder: (BuildContext context, int index) {
                    Map item = drawerItems[index];
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
                  },
                ),
              ],
            ),
          ),
          bottomNavigationBar: buildBottomItems()),
    );
  }

  BottomNavigationBar buildBottomItems() {
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
      _pageIndex = (drawerItems.length) + index;
      _botBarIndex = index;
    });
    _pageController.animateToPage(
      _pageIndex,
      duration: Duration(
        milliseconds: 200,
      ),
      curve: Curves.easeIn,
    );
  }

  Widget _userHomePage() {
    return userHomePage(context);
  }

  Widget _userBookingPage() {
    return userBookingPage(context);
  }

  Widget _userFavStores() {
    return userFavStoresPage(context);
  }

  Widget _userNotifications() {
    return userNotifications(context);
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

  Widget _storesListPage() {
    return Center(
      child: Container(
        margin: EdgeInsets.fromLTRB(10, 10, 10, 10),
        child: ListView.builder(
            itemCount: _stores.length,
            itemBuilder: (BuildContext context, int index) {
              return Container(
                child: new Column(children: _stores.map(_buildItem).toList()),
                //children: <Widget>[firstRow, secondRow],
              );
            }),
      ),
    );
  }

  Widget _buildItem(Store str) {
    return Card(
        elevation: 10,
        child: new Row(
          children: <Widget>[
            Column(
              children: <Widget>[
                new Container(
                  margin: EdgeInsets.fromLTRB(10, 10, 5, 5),
                  padding: EdgeInsets.all(5),
                  alignment: Alignment.center,
                  decoration: ShapeDecoration(
                    shape: CircleBorder(),
                    color: Theme.of(context).primaryColor,
                  ),
                  child: Icon(
                    Icons.shopping_cart,
                    color: Colors.white,
                    size: 20,
                  ),
                )
              ],
            ),
            Column(children: <Widget>[
              Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    new Container(
                      padding: EdgeInsets.fromLTRB(10.0, 5.0, 0, 0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Container(
                            padding: EdgeInsets.fromLTRB(0, 5, 5, 5),
                            child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    // crossAxisAlignment: CrossAxisAlignment.center,
                                    children: <Widget>[
                                      Text(
                                        str.name.toString(),
                                      ),
                                    ],
                                  ),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: <Widget>[
                                      Text(
                                        str.adrs,
                                      ),
                                    ],
                                  )
                                ]),
                          ),
                          Row(
                            children: <Widget>[
                              Text('Stores opens on days: ',
                                  style: lightSubTextStyle),
                              DefaultTextStyle.merge(
                                child: Container(
                                    child: Row(children: [
                                  Icon(Icons.remove_circle,
                                      size: 18.0, color: Colors.blueGrey[300]),
                                  Icon(Icons.add_circle,
                                      size: 18.0, color: Colors.orange),
                                  Icon(Icons.remove_circle,
                                      size: 18.0, color: Colors.blueGrey[300]),
                                  Icon(Icons.remove_circle,
                                      size: 18.0, color: Colors.blueGrey[300]),
                                  Icon(Icons.remove_circle,
                                      size: 18.0, color: Colors.blueGrey[300]),
                                ])),
                              ),
                            ],
                          ),
                          Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  //mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                  children: [
                                    //Icon(Icons.play_circle_filled, color: Colors.blueGrey[300]),
                                    Text('Opens at:', style: labelTextStyle),
                                    Text(str.opensAt, style: lightSubTextStyle),
                                  ],
                                ),
                                Container(child: Text('   ')),
                                Row(
                                  children: [
                                    //Icon(Icons.pause_circle_filled, color: Colors.blueGrey[300]),
                                    Text('Closes at:', style: labelTextStyle),
                                    Text(str.closesAt,
                                        style: lightSubTextStyle),
                                  ],
                                ),
                              ]),
                        ],
                      ),
                    ),
                  ]),
            ]),
            Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Container(
                    height: 22,
                    width: 20,
                    // margin: EdgeInsets.fromLTRB(10, 10, 5, 5),
                    alignment: Alignment.center,
                    decoration: ShapeDecoration(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.all(Radius.circular(6)),
                          side: BorderSide.none),
                      color: Theme.of(context).primaryColor,
                    ),
                    child: IconButton(
                      //alignment: Alignment.center,
                      padding: EdgeInsets.all(2),
                      onPressed: () => {},
                      highlightColor: Colors.orange[300],
                      iconSize: 14,
                      icon: Icon(
                        Icons.favorite,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  Container(
                    //margin: EdgeInsets.fromLTRB(20, 10, 5, 5),
                    width: 20.0,
                    height: 20.0,
                    alignment: Alignment.center,
                    decoration: ShapeDecoration(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.all(Radius.circular(4)),
                          side: BorderSide.none),
                      color: Theme.of(context).primaryColor,
                    ),
                    child: IconButton(
                      padding: EdgeInsets.all(2),
                      iconSize: 14,
                      //alignment: Alignment.center,
                      highlightColor: Colors.orange[300],
                      icon: Icon(
                        Icons.location_on,
                        color: Colors.white,
                        //size: 17,
                      ),
                      onPressed: () =>
                          launchURL(str.name, str.adrs, str.lat, str.long),
                    ),
                  ),
                  Container(
                    width: 20.0,
                    height: 20.0,
                    alignment: Alignment.center,
                    decoration: ShapeDecoration(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.all(Radius.circular(2)),
                          side: BorderSide.none),
                      color: Theme.of(context).primaryColor,
                    ),
                    child: IconButton(
                      //alignment: Alignment.center,
                      padding: EdgeInsets.all(2),
                      iconSize: 14,
                      highlightColor: Colors.orange[300],
                      icon: Icon(
                        Icons.check,
                        color: Colors.white,
                      ),
                      onPressed: () => {},
                    ),
                  )
                ]),
          ],
        ));
  }

  launchURL(String tit, String addr, double lat, double long) async {
    final title = tit;
    final description = addr;
    final coords = Coords(lat, long);
    if (await MapLauncher.isMapAvailable(MapType.google)) {
      await MapLauncher.launchMap(
        mapType: MapType.google,
        coords: coords,
        title: title,
        description: description,
      );
    }
  }
}
