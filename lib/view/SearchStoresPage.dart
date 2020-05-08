import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:noq/models/localDB.dart';
import 'package:noq/repository/StoreRepository.dart';
import 'package:noq/repository/local_db_repository.dart';
import 'package:noq/repository/slotRepository.dart';
import 'package:noq/services/mapService.dart';
import 'package:noq/style.dart';
import 'package:noq/utils.dart';
import 'package:noq/view/showSlotsPage.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SearchStoresPage extends StatefulWidget {
  final String forPage;
  SearchStoresPage({Key key, @required this.forPage}) : super(key: key);
  @override
  _SearchStoresPageState createState() => _SearchStoresPageState();
}

class _SearchStoresPageState extends State<SearchStoresPage> {
  bool isFavourited = false;
  DateTime dateTime = DateTime.now();
  final dtFormat = new DateFormat('dd');
  SharedPreferences _prefs;
  UserAppData _userProfile;
  List<StoreAppData> _stores;

  final compareDateFormat = new DateFormat('YYYYMMDD');

  List<DateTime> _dateList = new List<DateTime>();

  @override
  void initState() {
    super.initState();
    // _getUserData();
    getPrefInstance();
    getList();
  }

  void getPrefInstance() async {
    _prefs = await SharedPreferences.getInstance();
  }

  void getList() {
    String pageName = widget.forPage;
    if (pageName == "Search") {
      getStoresList();
    } else if (pageName == "Favourite") {
      getFavStoresList();
    }
  }

  void getStoresList() async {
    await readData().then((fUser) {
      _userProfile = fUser;
    });
    _stores = getDummyList();
  }

  void getFavStoresList() async {
    List<StoreAppData> list;
    await readData().then((fUser) {
      _userProfile = fUser;
    });
//Load details from local files
    if (_userProfile != null) {
      if (_userProfile.favStores != null) {
        list = _userProfile.favStores;
        setState(() {
          _stores = list;
        });
      }
    }
  }

  // Future<void> _getUserData() async {
  //   await readData().then((fUser) {
  //     _userProfile = fUser;
  //   });
  // }

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

  // void updateFavStores(StoreAppData strData) {
  //   UserAppData userProf = _userProfile;
  //   for (StoreAppData store in userProf.favStores) {
  //     if (store.id == strData.id) {
  //       userProf.favStores.remove(store);
  //     } else {
  //       userProf.favStores.add(store);
  //     }
  //   }
  //   writeData(userProf);
  //   if (userProf.favStores.length == 0) {
  //     setState(() {
  //       _stores = null;
  //     });
  //   }
  // }

  void toggleFavorite(StoreAppData strData) {
    setState(() {
      strData.isFavourite = !strData.isFavourite;
      if (strData.isFavourite == true) {
        for (StoreAppData store in _userProfile.favStores) {
          if (store.id == strData.id) return;
        }
        _userProfile.favStores.add(strData);
      } else {
        _userProfile.favStores.remove(strData);
      }
    });
    writeData(_userProfile);
    if ((_userProfile.favStores.length == 0) &&
        (widget.forPage == "Favourite")) {
      setState(() {
        _stores = null;
      });
    }
  }

  Widget _emptyStorePage() {
    return Center(
        child: Center(
            child: Container(
                margin: EdgeInsets.fromLTRB(10, 10, 10, 10),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Text('No favourite stores yet!! ',
                        style: highlightTextStyle),
                    Text('Add your favourite places to quickly browse later!! ',
                        style: highlightSubTextStyle),
                  ],
                ))));
  }

  @override
  Widget build(BuildContext context) {
    if (_stores == null) {
      return _emptyStorePage();
    } else {
      return Center(
        child: Container(
          margin: EdgeInsets.fromLTRB(10, 10, 10, 10),
          child: ListView.builder(
              itemCount: 1,
              itemBuilder: (BuildContext context, int index) {
                return Container(
                  child: new Column(children: _stores.map(_buildItem).toList()),
                  //children: <Widget>[firstRow, secondRow],
                );
              }),
        ),
      );
    }
  }

  Widget _buildItem(StoreAppData str) {
    _prepareDateList();
    //_buildDateGridItems(str.id);
    print('after buildDateGrid called');
    return Card(
        elevation: 10,
        child: new Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          // mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Container(
              width: MediaQuery.of(context).size.width * .1,
              child: Column(
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
            ),
            Container(
              width: MediaQuery.of(context).size.width * .7,
              child: Column(children: <Widget>[
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
                                          style: lightSubTextStyle,
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
                                      Text(str.opensAt,
                                          style: lightSubTextStyle),
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
            ),
            Container(
              width: MediaQuery.of(context).size.width * .1,
              child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  // crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Container(
                      margin: EdgeInsets.fromLTRB(0, 0, 10, 0),
                      height: 22,
                      width: 20,
                      child: IconButton(
                        alignment: Alignment.topRight,
                        onPressed: () => toggleFavorite(str),
                        highlightColor: Colors.orange[300],
                        iconSize: 16,
                        icon: str.isFavourite
                            ? Icon(
                                Icons.favorite,
                                color: Colors.red[800],
                              )
                            : Icon(
                                Icons.favorite_border,
                                color: Colors.red[800],
                              ),
                      ),
                    ),
                    Container(
                      width: 20,
                      height: 40,
                    ),
                    Container(
                      margin: EdgeInsets.fromLTRB(0, 0, 15, 0),
                      height: 22.0,
                      width: 20.0,
                      child: IconButton(
                        alignment: Alignment.bottomRight,
                        highlightColor: Colors.orange[300],
                        icon: Icon(
                          Icons.location_on,
                          color: darkIcon,
                          size: 25,
                        ),
                        onPressed: () =>
                            launchURL(str.name, str.adrs, str.lat, str.long),
                      ),
                    ),
                  ]),
            )
          ],
        ));
  }

  void showSlots(String storeId, String storeName, DateTime dateTime) {
    //_prefs = await SharedPreferences.getInstance();
    String dateForSlot = dateTime.toString();

    _prefs.setString("storeName", storeName);
    _prefs.setString("storeIdForSlots", storeId);
    _prefs.setString("dateForSlot", dateForSlot);
    getSlotsForStore(storeId, dateTime).then((slotsList) async {
      // Navigator.push(
      //   context,
      //   MaterialPageRoute(builder: (context) => showSlotsDialog(context, slotsList, dateTime)),
      // );

      // showSlotsDialog(context, slotsList, dateTime);
      //return
      String val = await showDialog(
          context: context,
          barrierDismissible: true,
          builder: (BuildContext context) {
            return StatefulBuilder(builder: (context, setState) {
              return ShowSlotsPage();
            });
          });
      if (val != null) {
        //Add Slot booking in user data, Save locally
        print('Upcoming bookings');
        List<String> s = val.split("-");
        BookingAppData upcomingBooking =
            new BookingAppData(storeId, storeName, dateTime, s[1], s[0], "New");
        setState(() {
          _userProfile.upcomingBookings.add(upcomingBooking);
        });
        writeData(_userProfile);
      }
      print('After showDialog: $val');
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
    bool dateBooked = false;
    UserAppData user = _userProfile;
    for (BookingAppData obj in (user.upcomingBookings)) {
      if ((compareDateFormat
                  .format(dt)
                  .compareTo(compareDateFormat.format(obj.bookingDate)) ==
              0) &&
          (obj.storeId == sid)) {
        dateBooked = true;
      }
    }
    Widget dtItem = Container(
      margin: EdgeInsets.all(2),
      child: SizedBox.fromSize(
        size: Size(34, 34), // button width and height
        child: ClipOval(
          child: Material(
            color: isClosed
                ? Colors.grey
                : (dateBooked
                    ? highlightColor
                    : Colors.lightGreen), // button color
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
