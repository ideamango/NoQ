import 'package:flutter/material.dart';
import 'package:map_launcher/map_launcher.dart';
import 'style.dart';
import 'models/Store.dart';
import 'services/authService.dart';
import 'view/userHomePage.dart';

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

  List<Store> _stores = xstores;
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
      theme: ThemeData.light().copyWith(),
      home: Scaffold(
          appBar: AppBar(title: Text(''), actions: <Widget>[
            IconButton(
              icon: Icon(Icons.search),
              autofocus: false,
              padding: EdgeInsets.all(2),
              iconSize: 20.0,
              onPressed: _onSearch,
            )
          ]),
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
                  child: Text(
                    "DRAWER HEADER..",
                    style: TextStyle(color: Colors.white),
                  ),
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
                            ? Theme.of(context).primaryColor
                            : Theme.of(context).textTheme.title.color,
                      ),
                      title: Text(
                        item['name'],
                        style: TextStyle(
                          color: _page == index
                              ? Theme.of(context).primaryColor
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
      selectedItemColor: Colors.amber[800],
    );
  }

  void _onSearch() {}

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

  Widget _logout() {
    return logoutPage(context);
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
        child: new Column(children: <Widget>[
          Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                new Container(
                  margin: EdgeInsets.fromLTRB(10, 10, 5, 5),
                  alignment: Alignment.center,
                  decoration: ShapeDecoration(
                    shape: CircleBorder(),
                    color: Colors.orange[300],
                  ),
                  child: Icon(
                    Icons.shopping_cart,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
                new Container(
                  padding: EdgeInsets.fromLTRB(10.0, 5.0, 0, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Container(
                        padding: EdgeInsets.fromLTRB(0, 5, 5, 5),
                        child:
                            Column(crossAxisAlignment: CrossAxisAlignment.start,
                                // mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                              Text(
                                str.name.toString(),
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Text(
                                    str.adrs,
                                  ),
                                  Container(
                                    width: 20.0,
                                    height: 20.0,
                                    child: IconButton(
                                      alignment: Alignment.center,
                                      padding: EdgeInsets.all(0),
                                      onPressed: () => {
                                        launchURL(str.name, str.adrs, str.lat,
                                            str.long),
                                      },
                                      highlightColor: Colors.orange[300],
                                      icon: Icon(
                                        Icons.location_on,
                                        color: Colors.blueGrey,
                                      ),
                                    ),
                                  ),
                                ],
                              )
                            ]),
                      ),
                      DefaultTextStyle.merge(
                        child: Container(
                            child: Row(children: [
                          Icon(Icons.remove_circle,
                              color: Colors.blueGrey[300]),
                          Icon(Icons.add_circle, color: Colors.orange),
                          Icon(Icons.remove_circle,
                              color: Colors.blueGrey[300]),
                          Icon(Icons.remove_circle,
                              color: Colors.blueGrey[300]),
                          Icon(Icons.remove_circle,
                              color: Colors.blueGrey[300]),
                        ])),
                      ),
                    ],
                  ),
                ),
              ]),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Row(
                children: <Widget>[],
              ),
              Row(
                //mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  //Icon(Icons.play_circle_filled, color: Colors.blueGrey[300]),
                  Text('Opens at:', style: labelTextStyle),
                  Text(str.opensAt, style: lightSubTextStyle),
                ],
              ),
              Row(
                children: [
                  //Icon(Icons.pause_circle_filled, color: Colors.blueGrey[300]),
                  Text('Closes at:', style: labelTextStyle),
                  Text(str.closesAt, style: lightSubTextStyle),
                ],
              ),
              Row(
                children: <Widget>[
                  new Container(
                    width: 40.0,
                    height: 20.0,
                    child: MaterialButton(
                      color: Colors.orange,
                      child: Text(
                        "Book Slot",
                        style: new TextStyle(
                            fontFamily: 'Montserrat',
                            letterSpacing: 0.5,
                            color: Colors.white,
                            fontSize: 10),
                      ),
                      onPressed: () => {
                        //onPressed_bookSlotBtn();
                      },
                      highlightColor: Colors.orange[300],
                    ),
                  )
                ],
              ),
            ],
          )
        ]));
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
