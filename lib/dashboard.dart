import 'package:flutter/material.dart';
import 'package:map_launcher/map_launcher.dart';
import 'package:noq/pages/slotsDialog.dart';
import 'package:noq/repository/StoreRepository.dart';
import 'package:noq/repository/slotRepository.dart';
import 'package:noq/services/mapService.dart';
import 'package:noq/utils.dart';
import 'package:noq/view/SearchStoresPage.dart';
import 'style.dart';
import 'models/store.dart';
import 'view/allPagesWidgets.dart';
import 'package:noq/models/localDB.dart';
import 'package:noq/repository/local_db_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';

class LandingPage extends StatefulWidget {
  @override
  _LandingPageState createState() => _LandingPageState();
}

class _LandingPageState extends State<LandingPage> {
  SharedPreferences _prefs;
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

  List<StoreAppData> _stores = getDummyList();
  int i;
  var _userProfile;
  var fUserProfile;
  TextStyle optionStyle = TextStyle(fontSize: 30, fontWeight: FontWeight.bold);
  String _phone;
  int _index = 0;
  int _botBarIndex = 0;
  int _pageIndex = 0;
  String _userName;
  String _userId;
  String _userAdrs;

  bool isFavourited = false;
  DateTime dateTime = DateTime.now();
  final dtFormat = new DateFormat('dd');

  List<DateTime> _dateList = new List<DateTime>();

  void navigationTapped(int page) {
    _pageController.jumpToPage(page);
  }

  _initializeUserProfile() async {
//Read data from file and then validate phone number - if same,load all other details
    await readData().then((fUser) {
      fUserProfile = fUser;
    });

    var userProfile;
    _prefs = await SharedPreferences.getInstance();
    _phone = _prefs.getString("phone");
    _userName = _prefs.getString("userName");
    _userId = _prefs.getString("userId");
    _userAdrs = _prefs.getString("userAdrs");

    if (fUserProfile != null) {
      userProfile = fUserProfile;
    }
    // else {
    //   //TODO:fetch from server

    //Save in local DB objects and file for perusal.
    // writeData(_userProfile);
    //   _prefs.setString("userName", _userName);
    // _prefs.setString("userId", _userId);
    // }

    else {
      //If not on server then create new user object.
//Start - Save User profile in file
      List<BookingAppData> pastBookings = new List<BookingAppData>();

      List<BookingAppData> upcomingBookings = new List();

      List<StoreAppData> stores = new List<StoreAppData>();
      // pastBookings.add(new BookingAppData(
      //     'IKEA', '12:00am,-12:30am', 'T1-9844969', 'expired'));
      // upcomingBookings.add(
      //     new BookingAppData('Vijetha', '9:00a,-9:30am', 'T0-1231234', 'new'));

      userProfile = new UserAppData(
          _userId,
          _userName,
          _phone,
          _userAdrs,
          upcomingBookings,
          pastBookings,
          stores,
          new SettingsAppData(notificationOn: true));
    }
    setState(() {
      _userProfile = userProfile;
    });
    writeData(_userProfile);

    setState(() {
      _userName = (_userProfile != null) ? _userProfile.name : 'User';
      //_userId = (_userProfile != null) ? _userProfile.id : '0';
    });
    _prefs.setString("userName", _userName);
    _prefs.setString("userId", _userId);

    //write userProfile to file

    print('UserProfile in file $_userProfile');

//End - Save User profile in file
  }

  @override
  void initState() {
    super.initState();

    _pageController = PageController(initialPage: 7);
    _initializeUserProfile();
  }

  void _prepareDateList() {
    _dateList.clear();
    _dateList.add(dateTime);
    DateTime dt = DateTime.now();
    for (int i = 1; i <= 4; i++) {
      print(i);
      _dateList.add(dt.add(Duration(days: i)));
      print('dateLIst is $_dateList');
    }
  }

  void modifyStoreList(StoreAppData strData) {}
  void toggleFavorite(StoreAppData strData) {
    setState(() {
      isFavourited = !isFavourited;
      if (strData.isFavourite == true) {
        (_userProfile as UserAppData).favStores.add(strData);
      }
      // widget.onFavoriteChanged(isFavourited);
    });
    modifyStoreList(strData);
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
                //SearchStoresPage(),
                _userAccount(),
              ],
            ),
          ),
          drawer: Drawer(
            child: ListView(
              children: <Widget>[
                DrawerHeader(
                  child: Text('Hello $_userName !!', style: inputTextStyle),
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
    return userBookingPage(context, _userProfile);
  }

  Widget _userFavStores() {
    return userFavStoresPage(context, _userProfile);
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

  void _initializeStoresList() {
    _prepareDateList();
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

  Widget _buildItem(StoreAppData str) {
    _initializeStoresList();
    //_buildDateGridItems(str.id);
    print('after buildDateGrid called');
    return Card(
        elevation: 10,
        child: new Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Column(
              children: <Widget>[
                new Container(
                  margin: EdgeInsets.fromLTRB(10, 10, 5, 5),
                  padding: EdgeInsets.all(5),
                  alignment: Alignment.topCenter,
                  decoration: ShapeDecoration(
                    shape: CircleBorder(),
                    color: darkIcon,
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
                          Container(
                            width: MediaQuery.of(context).size.width * .5,
                            //padding: EdgeInsets.fromLTRB(0, 5, 5, 5),
                            child: Row(
                              children: _buildDateGridItems(
                                  str.id, str.name, str.daysClosed),
                            ),
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
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Container(
                    margin: EdgeInsets.fromLTRB(0, 0, 10, 0),
                    height: 22,
                    width: 20,
                    // margin: EdgeInsets.fromLTRB(10, 10, 5, 5),
                    // alignment: Alignment.topRight,
                    // decoration: ShapeDecoration(
                    //   shape: RoundedRectangleBorder(
                    //       borderRadius: BorderRadius.all(Radius.circular(6)),
                    //       side: BorderSide.none),
                    //   color: Theme.of(context).primaryColor,
                    // ),
                    child: IconButton(
                      alignment: Alignment.topRight,
                      //padding: EdgeInsets.all(2),
                      onPressed: () => toggleFavorite(str),
                      highlightColor: Colors.orange[300],
                      iconSize: 16,
                      icon: !isFavourited
                          ? Icon(
                              Icons.star,
                              color: darkIcon,
                            )
                          : Icon(
                              Icons.star_border,
                              color: darkIcon,
                            ),
                    ),
                  ),
                  Container(
                    //margin: EdgeInsets.fromLTRB(20, 10, 5, 5),

                    height: 22.0,
                    width: 20.0,
                    //alignment: Alignment.center,
                    // decoration: ShapeDecoration(
                    //   shape: RoundedRectangleBorder(
                    //       borderRadius: BorderRadius.all(Radius.circular(4)),
                    //       side: BorderSide.none),
                    //   color: Theme.of(context).primaryColor,
                    // ),
                    child: IconButton(
                      // padding: EdgeInsets.all(2),
                      //iconSize: 14,
                      alignment: Alignment.centerRight,
                      highlightColor: Colors.orange[300],
                      icon: Icon(
                        Icons.location_on,
                        color: darkIcon,
                        size: 20,
                      ),
                      onPressed: () =>
                          launchURL(str.name, str.adrs, str.lat, str.long),
                    ),
                  ),
                  // Container(
                  //   width: 20.0,
                  //   height: 22.0,
                  //   // alignment: Alignment.center,
                  //   // decoration: ShapeDecoration(
                  //   //   shape: RoundedRectangleBorder(
                  //   //       borderRadius: BorderRadius.all(Radius.circular(2)),
                  //   //       side: BorderSide.none),
                  //   //   color: Theme.of(context).primaryColor,
                  //   // ),
                  //   child: IconButton(
                  //       alignment: Alignment.bottomCenter,
                  //       padding: EdgeInsets.all(2),
                  //       iconSize: 25,
                  //       highlightColor: highlightColor,
                  //       icon: Icon(
                  //         Icons.arrow_forward,
                  //         color: darkIcon,
                  //       ),
                  //       onPressed: () => showSlots(str.id, dateTime)),
                  // ),
                ]),
          ],
        ));
  }

  void showSlots(String storeId, String storeName, DateTime dateTime) {
    //_prefs = await SharedPreferences.getInstance();
    String dateForSlot = dateTime.toString();

    _prefs.setString("storeName", storeName);
    _prefs.setString("storeIdForSlots", storeId);
    _prefs.setString("dateForSlot", dateForSlot);
    getSlotsForStore(storeId, dateTime).then((slotsList) {
      showSlotsDialog(context, slotsList, dateTime);
    });
  }

  List<Widget> _buildDateGridItems(
      String sid, String sname, List<String> daysClosed) {
    bool isClosed = false;
    String dayOfWeek;

    var dateWidgets = List<Widget>();
    for (var date in _dateList) {
      isClosed = (daysClosed.contains(date.weekday.toString())) ? true : false;
      dayOfWeek = Utils.getDayOfWeek(date);
      dateWidgets.add(buildDateItem(sid, sname, isClosed, date, dayOfWeek));
      print('Widget build from datelist  called');
    }
    return dateWidgets;
  }

  Widget buildDateItem(
      String sid, String sname, bool isClosed, DateTime dt, String dayOfWeek) {
    Widget dtItem = Container(
      margin: EdgeInsets.all(2),
      child: SizedBox.fromSize(
        size: Size(34, 34), // button width and height
        child: ClipOval(
          child: Material(
            color: isClosed ? Colors.grey : Colors.lightGreen, // button color
            child: InkWell(
              splashColor: isClosed ? null : highlightColor, // splash color
              onTap: () {
                if (isClosed) {
                  return null;
                } else {
                  print("tapped");
                  showSlots(sid, sname, dt);
                }
              }, // button pressed
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Text(dtFormat.format(dt),
                      style: TextStyle(fontSize: 15, color: Colors.white)),
                  Text(dayOfWeek,
                      style:
                          TextStyle(fontSize: 8, color: Colors.white)), // text
                ],
              ),
            ),
          ),
        ),
      ),
    );
    return dtItem;
  }
}
