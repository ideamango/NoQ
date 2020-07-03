import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:noq/constants.dart';
import 'package:noq/models/localDB.dart';
import 'package:noq/pages/entity_services_list_page.dart';
import 'package:noq/pages/showSlotsPage.dart';
import 'package:noq/repository/StoreRepository.dart';
import 'package:noq/repository/local_db_repository.dart';
import 'package:noq/repository/slotRepository.dart';
import 'package:noq/services/mapService.dart';
import 'package:noq/style.dart';
import 'package:noq/utils.dart';
import 'package:noq/widget/appbar.dart';
import 'package:noq/widget/bottom_nav_bar.dart';
import 'package:noq/widget/header.dart';
import 'package:noq/widget/widgets.dart';

import 'package:shared_preferences/shared_preferences.dart';

import '../userHomePage.dart';

class SearchStoresPage extends StatefulWidget {
  final String forPage;
  final List<EntityAppData> childList;
  SearchStoresPage({Key key, @required this.forPage, this.childList})
      : super(key: key);
  @override
  _SearchStoresPageState createState() => _SearchStoresPageState();
}

class _SearchStoresPageState extends State<SearchStoresPage> {
  bool initCompleted = false;
  bool isFavourited = false;
  DateTime dateTime = DateTime.now();
  final dtFormat = new DateFormat('dd');
  SharedPreferences _prefs;
  UserAppData _userProfile;
  List<EntityAppData> _stores = new List<EntityAppData>();
  List<EntityAppData> _searchResultstores = new List<EntityAppData>();
  String _entityType;
  String _searchAll = searchTypes[0];
  bool searchBoxClicked = false;

  bool fetchFromServer = false;

  final compareDateFormat = new DateFormat('YYYYMMDD');

  List<DateTime> _dateList = new List<DateTime>();

  Icon actionIcon = new Icon(
    Icons.search,
    color: Colors.white,
  );
  final key = new GlobalKey<ScaffoldState>();
  static final TextEditingController _searchQuery = new TextEditingController();
  List<EntityAppData> _list;
  bool _isSearching;
  String _searchText = "";
  String searchType = "";

  _SearchStoresPageState() {
    _searchQuery.addListener(() {
      if (_searchQuery.text.isEmpty) {
        setState(() {
          _isSearching = false;
          _searchText = "";
        });
      } else {
        setState(() {
          _isSearching = true;
          _searchText = _searchQuery.text;
        });
      }
    });
  }

  updateSearchList() {
//Send request to server for fetching entities with given type.
    setState(() {
      fetchFromServer = true;
    });
//_stores = Request();
    List<EntityAppData> newList;
    if (_entityType.toLowerCase() == _searchAll.toLowerCase()) {
      newList = getStoreListServer();
    } else {
      newList = getTypedEntities(_entityType);
    }
    // Compare and add new stores fetched to _stores list

    setState(() {
      _stores = newList;
    });

    _userProfile.storesAccessed = _stores;

    _list = _stores;

    writeData(_userProfile);

    // _userProfile.storesAccessed = _stores;

    // _list = _stores;

    // writeData(_userProfile);

//TODO: Remove this block after testing
    // List<EntityAppData> _searchList = List();
    // for (int i = 0; i < _stores.length; i++) {
    //   String eType = _stores.elementAt(i).eType;
    //   if (eType.toLowerCase() == _entityType.toLowerCase()) {
    //     _searchList.add(_stores.elementAt(i));
    //   }
    // }
    // setState(() {
    //   _stores = _searchList;
    // });
  }

  @override
  void initState() {
    super.initState();
    // _getUserData();
    _isSearching = false;
    getPrefInstance().then((action) {
      getList();
      setState(() {
        initCompleted = true;
      });
    });
  }

  Future<void> getPrefInstance() async {
    _prefs = await SharedPreferences.getInstance();
  }

  void getList() {
    String pageName = widget.forPage;
    if (pageName == "Search") {
      getStoresList();
    } else if (pageName == "Favourite") {
      getFavStoresList();
    } else if (pageName == "Child") {
      getChildStoresList();
    }
  }

  void getChildStoresList() async {
    setState(() {
      if (!Utils.isNullOrEmpty(widget.childList)) {
        _stores.addAll(widget.childList);
      }
    });
    //TODO: Userprofile coming as null.(In search page)
    _userProfile.storesAccessed = _stores;

    _list = _stores;

    //writeData(_userProfile);
  }

  void getStoresList() async {
    await readData().then((fUser) {
      _userProfile = fUser;
    });

    //Load details from local files
    if (_userProfile != null) {
      if (_userProfile.storesAccessed != null) {
        _stores = _userProfile.storesAccessed;
      }
    }
    List<EntityAppData> newList;
    if (fetchFromServer || Utils.isNullOrEmpty(_userProfile.storesAccessed)) {
      //API call to fecth stores from server
      newList = getStoreListServer();
      // Compare and add new stores fetched to _stores list
      if (_stores.length != 0) {
        for (EntityAppData newStore in newList) {
          for (EntityAppData localStore in _stores) {
            if (newStore.id == localStore.id)
              return;
            else
              newList.add(newStore);
          }
        }
      }
    }
    setState(() {
      if (!Utils.isNullOrEmpty(newList)) {
        _stores.addAll(newList);
      }
    });
    _userProfile.storesAccessed = _stores;

    _list = _stores;

    writeData(_userProfile);
  }

  void getFavStoresList() async {
    List<EntityAppData> list = new List<EntityAppData>();
    await readData().then((fUser) {
      _userProfile = fUser;
    });
//Load details from local files
    if (_userProfile != null) {
      if ((_userProfile.storesAccessed != null) &&
          (_userProfile.storesAccessed.length != 0)) {
        list = _userProfile.storesAccessed
            .where((item) => item.isFavourite == true)
            .toList();
      }
      setState(() {
        if (list.length == 0)
          _stores = null;
        else
          _stores = list;
      });
    }
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

  void toggleFavorite(EntityAppData strData) {
    setState(() {
      strData.isFavourite = !strData.isFavourite;
      if (!strData.isFavourite && widget.forPage == 'Favourite') {
        _stores.remove(strData);
      }
    });
    writeData(_userProfile);
    if ((_stores.length == 0) && (widget.forPage == 'Favourite')) {
      setState(() {
        _stores = null;
      });
    }
  }

  Widget _emptySearchPage() {
    return Center(
        child: Container(
            margin: EdgeInsets.fromLTRB(
                10,
                MediaQuery.of(context).size.width * .5,
                10,
                MediaQuery.of(context).size.width * .5),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text('No match found. Try again!! ', style: highlightTextStyle),
                Text(
                    'Add your favourite places to quickly browse through later!! ',
                    style: highlightSubTextStyle),
              ],
            )));
  }

  Widget _listSearchResults() {
    return Expanded(
      child: ListView.builder(
          itemCount: 1,
          itemBuilder: (BuildContext context, int index) {
            return Container(
              margin: EdgeInsets.fromLTRB(10, 10, 10, 10),
              child: new Column(
                children: _isSearching ? _buildSearchList() : _buildList(),
                // ? _searchResultstores
                //     .map(_buildItem)
                //     .toList()
                // : _stores.map(_buildItem).toList()
                // ),
                //children: <Widget>[firstRow, secondRow],
              ),
            );
          }),
    );
  }

  @override
  Widget build(BuildContext context) {
    Widget categoryDropDown = Container(
        width: MediaQuery.of(context).size.width * .48,
        height: MediaQuery.of(context).size.width * .1,
        decoration: new BoxDecoration(
          shape: BoxShape.rectangle,
          color: Colors.white,
          // color: Colors.white,
          borderRadius: BorderRadius.all(Radius.circular(5.0)),
          border: new Border.all(
            color: Colors.blueGrey[400],
            width: 0.5,
          ),
        ),
        child: DropdownButtonHideUnderline(
            child: ButtonTheme(
          alignedDropdown: true,
          child: new DropdownButton(
            iconEnabledColor: Colors.blueGrey[500],
            dropdownColor: Colors.white,
            itemHeight: kMinInteractiveDimension,
            hint: new Text("Select a category"),
            style: TextStyle(fontSize: 12, color: Colors.blueGrey[500]),
            value: _entityType,
            isDense: true,
            // icon: Icon(Icons.search),
            onChanged: (newValue) {
              setState(() {
                _entityType = newValue;
                updateSearchList();
                // state.didChange(newValue);
              });
            },
            items: searchTypes.map((type) {
              return DropdownMenuItem(
                value: type,
                child: new Text(type.toString(),
                    style:
                        TextStyle(fontSize: 12, color: Colors.blueGrey[500])),
              );
            }).toList(),
          ),
        )));
    Widget appBarTitle = Container(
      width: MediaQuery.of(context).size.width * .48,
      height: MediaQuery.of(context).size.width * .1,
      decoration: new BoxDecoration(
        shape: BoxShape.rectangle,
        color: Colors.white,
        // color: Colors.white,
        borderRadius: BorderRadius.all(Radius.circular(5.0)),
        border: new Border.all(
          color: Colors.blueGrey[400],
          width: 0.5,
        ),
      ),
      child: new TextField(
        // autofocus: true,
        controller: _searchQuery,
        cursorColor: Colors.blueGrey[500],
        cursorWidth: 1,

        style: new TextStyle(
          // backgroundColor: Colors.white,
          color: Colors.blueGrey[500],
        ),
        decoration: new InputDecoration(
            contentPadding: EdgeInsets.fromLTRB(20, 7, 5, 7),
            isDense: true,
            prefixIconConstraints: BoxConstraints(
              maxWidth: 25,
              maxHeight: 22,
            ),
            suffixIconConstraints: BoxConstraints(
              maxWidth: 25,
              maxHeight: 22,
            ),
            //contentPadding: EdgeInsets.all(0),
            focusedBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: Colors.transparent)),
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.transparent, width: 0.5),
            ),
            prefixIcon: IconButton(
              // transform: Matrix4.translationValues(-10.0, 0, 0),
              icon:
                  new Icon(Icons.search, size: 20, color: Colors.blueGrey[500]),
              alignment: Alignment.centerRight,
              padding: EdgeInsets.all(0),
              onPressed: () {},
            ),
            suffixIcon: new IconButton(
                //constraints: BoxConstraints.tight(Size(15, 15)),
                alignment: Alignment.centerLeft,
                padding: EdgeInsets.all(0),
                icon: new Icon(
                  Icons.close,
                  size: 17,
                  color: Colors.blueGrey[500],
                ),
                onPressed: () {
                  //TODO: correct search end
                  searchBoxClicked = false;
                  _searchQuery.clear();
                }),

            // Container(
            //   // transform: Matrix4.translationValues(3.0, 3, 0),
            //   padding: EdgeInsets.all(0),
            //   margin: ,
            //   child:
            // ),
            // suffixIconConstraints: BoxConstraints(
            //   maxWidth: 25,
            //   maxHeight: 22,
            // ),
            hintText: "Search by Name",
            hintStyle:
                new TextStyle(fontSize: 12, color: Colors.blueGrey[500])),
      ),
    );

    Widget filterBar = Container(
      margin: EdgeInsets.fromLTRB(0, 5, 0, 0),
      //  padding: EdgeInsets.fromLTRB(5, 0, 5, 0),
      //decoration: gradientBackground,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: <Widget>[categoryDropDown, appBarTitle],
      ),
    );

// build widget only after init has completed, till then show progress indicator.
    String title = "Search";
    if (!initCompleted) {
      return MaterialApp(
        theme: ThemeData.light().copyWith(),
        home: Scaffold(
          appBar: CustomAppBar(
            titleTxt: "Search",
          ),
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Padding(padding: EdgeInsets.only(top: 20.0)),
                Text(
                  "Loading..",
                  style: TextStyle(fontSize: 20.0, color: borderColor),
                ),
                Padding(padding: EdgeInsets.only(top: 20.0)),
                CircularProgressIndicator(
                  backgroundColor: primaryAccentColor,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.amber),
                  strokeWidth: 3,
                )
              ],
            ),
          ),
          //drawer: CustomDrawer(),
          bottomNavigationBar: (widget.forPage == "Search")
              ? CustomBottomBar(barIndex: 1)
              : CustomBottomBar(barIndex: 2),
        ),
      );
    } else {
      return MaterialApp(
        theme: ThemeData.light().copyWith(),
        home: Scaffold(
          appBar: AppBar(
              actions: <Widget>[],
              flexibleSpace: Container(
                decoration: gradientBackground,
              ),
              leading: IconButton(
                  padding: EdgeInsets.all(0),
                  alignment: Alignment.center,
                  highlightColor: Colors.orange[300],
                  icon: Icon(Icons.arrow_back),
                  color: Colors.white,
                  onPressed: () {
                    Navigator.of(context).pop();
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => UserHomePage()));
                  }),
              title: Text(
                title,
                style: TextStyle(color: Colors.white, fontSize: 16),
                overflow: TextOverflow.ellipsis,
              )),
          body: Center(
            child: Container(
              //
              child: Column(
                children: <Widget>[
                  filterBar,
                  (Utils.isNullOrEmpty(_stores))
                      ? _emptySearchPage()
                      : _listSearchResults(),
                ],
              ),
            ),
          ),
          // drawer: CustomDrawer(),
          bottomNavigationBar: (widget.forPage == "Search")
              ? CustomBottomBar(barIndex: 1)
              : CustomBottomBar(barIndex: 2),
          // drawer: CustomDrawer(),
        ),
      );
    }
  }

  Widget _buildItem(EntityAppData str) {
    _prepareDateList();
    //_buildDateGridItems(str.id);
    print('after buildDateGrid called');
    return GestureDetector(
      onTap: () {
        print("Container clicked");
        print(str.childCollection.length);
        if (str.childCollection.length != 0) {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => SearchStoresPage(forPage: "Child")));

          // Navigator.push(
          //     context,
          //     MaterialPageRoute(
          //         builder: (context) => EntityServicesListPage(entity: str)));
        }
      },
      child: Card(
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
                    margin: EdgeInsets.fromLTRB(
                        MediaQuery.of(context).size.width * .01,
                        MediaQuery.of(context).size.width * .01,
                        MediaQuery.of(context).size.width * .005,
                        MediaQuery.of(context).size.width * .005),
                    padding:
                        EdgeInsets.all(MediaQuery.of(context).size.width * .01),
                    alignment: Alignment.topCenter,
                    decoration: ShapeDecoration(
                      shape: CircleBorder(),
                      color: primaryIcon,
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
              width: MediaQuery.of(context).size.width * .8,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Container(
                    width: MediaQuery.of(context).size.width * .8,
                    // padding: EdgeInsets.fromLTRB(0, 5, 5, 5),
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(0, 5, 0, 3),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        // crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          Text(
                            (str.name) ?? str.name.toString(),
                          ),
                          Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              // crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Container(
                                  padding: EdgeInsets.fromLTRB(0, 0, 0, 0),
                                  margin: EdgeInsets.fromLTRB(0, 0, 0, 0),
                                  height: 22.0,
                                  width: 28.0,
                                  child: IconButton(
                                    alignment: Alignment.topCenter,
                                    highlightColor: Colors.orange[300],
                                    icon: Icon(
                                      Icons.phone,
                                      color: primaryIcon,
                                      size: 20,
                                    ),
                                    onPressed: () => callPhone('+919611009823'),
                                  ),
                                ),
                                Container(
                                  padding: EdgeInsets.fromLTRB(0, 0, 5, 5),
                                  margin: EdgeInsets.fromLTRB(0, 0, 0, 0),
                                  height: 22.0,
                                  width: 28.0,
                                  child: IconButton(
                                    alignment: Alignment.topCenter,
                                    highlightColor: Colors.orange[300],
                                    icon: Icon(
                                      Icons.location_on,
                                      color: primaryIcon,
                                      size: 20,
                                    ),
                                    onPressed: () => launchURL(str.name,
                                        str.adrs.toString(), str.lat, str.long),
                                  ),
                                ),
                                Container(
                                  padding: EdgeInsets.fromLTRB(0, 0, 0, 0),
                                  margin: EdgeInsets.fromLTRB(0, 0, 0, 0),
                                  height: 22,
                                  width: 25,
                                  child: IconButton(
                                    alignment: Alignment.topRight,
                                    onPressed: () => toggleFavorite(str),
                                    highlightColor: Colors.orange[300],
                                    iconSize: 20,
                                    icon: str.isFavourite
                                        ? Icon(
                                            Icons.favorite,
                                            color: Colors.red[800],
                                          )
                                        : Icon(
                                            Icons.favorite_border,
                                            color: primaryIcon,
                                          ),
                                  ),
                                ),
                              ])
                        ],
                      ),
                    ),
                  ),
                  // SizedBox(
                  //   width: MediaQuery.of(context).size.width * .4,
                  //   child: Divider(
                  //     thickness: 1.0,
                  //     color: Colors.teal,
                  //     height: 5,
                  //   ),
                  // ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      Container(
                        width: MediaQuery.of(context).size.width * .67,
                        child: Text(
                          (str.adrs != null) ? str.adrs.toString() : "Address",
                          overflow: TextOverflow.ellipsis,
                          style: textInputTextStyle,
                        ),
                      ),
                    ],
                  ),
                  Container(
                      width: MediaQuery.of(context).size.width * .68,
                      //padding: EdgeInsets.fromLTRB(0, 5, 5, 5),
                      child: Row(
                        children: <Widget>[
                          Text(
                            '',
                            style: highlightSubTextStyle,
                          ),
                          Row(
                            children: _buildDateGridItems(
                                str, str.id, str.name, str.daysClosed),
                          ),
                        ],
                      )),
                  Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Row(
                          //mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            //Icon(Icons.play_circle_filled, color: Colors.blueGrey[300]),
                            Text('Opens at:', style: labelTextStyle),
                            //Text(str.opensAt, style: textInputTextStyle),
                          ],
                        ),
                        Container(
                            width: MediaQuery.of(context).size.width * .02,
                            child: Text('')),
                        Row(
                          children: [
                            //Icon(Icons.pause_circle_filled, color: Colors.blueGrey[300]),
                            Text('Closes at:', style: labelTextStyle),
                            // Text(str.closesAt, style: textInputTextStyle),
                          ],
                        ),
                      ]),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void showSlots(EntityAppData store, String storeId, String storeName,
      DateTime dateTime) {
    //_prefs = await SharedPreferences.getInstance();
    String dateForSlot = dateTime.toString();

    _prefs.setString("storeName", storeName);
    _prefs.setString("storeIdForSlots", storeId);
    _prefs.setString("dateForSlot", dateForSlot);
    getSlotsForStore(storeId, dateTime).then((slotsList) async {
      //Added below code which shows slots in a page
      final result = await Navigator.push(
          context, MaterialPageRoute(builder: (context) => ShowSlotsPage()));

      print(result);
//Commented below code which shows slots in a dialog

      // String val = await showDialog(
      //     context: context,
      //     barrierDismissible: true,
      //     builder: (BuildContext context) {
      //       return StatefulBuilder(builder: (context, setState) {
      //         return ShowSlotsPage();
      //       });
      //     });

      if (result != null) {
        //Add Slot booking in user data, Save locally
        print('Upcoming bookings');
        List<String> s = result.split("-");
        BookingAppData upcomingBooking =
            new BookingAppData(store.id, dateTime, s[1], s[0], "New");
        setState(() {
          _userProfile.upcomingBookings.add(upcomingBooking);
        });
        writeData(_userProfile);
      }
      print('After showDialog:');
    });
  }

  List<Widget> _buildDateGridItems(
      EntityAppData store, String sid, String sname, List<String> daysClosed) {
    bool isClosed = false;
    String dayOfWeek;

    var dateWidgets = List<Widget>();
    for (var date in _dateList) {
      isClosed = (daysClosed.contains(date.weekday.toString())) ? true : false;
      dayOfWeek = Utils.getDayOfWeek(date);
      dateWidgets
          .add(buildDateItem(store, sid, sname, isClosed, date, dayOfWeek));
      print('Widget build from datelist  called');
    }
    return dateWidgets;
  }

  Widget buildDateItem(EntityAppData store, String sid, String sname,
      bool isClosed, DateTime dt, String dayOfWeek) {
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
                    : primaryDarkColor), // button color
            child: InkWell(
              splashColor: isClosed ? null : highlightColor, // splash color
              onTap: () {
                if (isClosed) {
                  return null;
                } else {
                  print("tapped");

                  // Navigator.push(context,
                  //     MaterialPageRoute(builder: (context) => ShowSlotsPage()));
                  showSlots(store, sid, sname, dt);
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

  List<Widget> _buildList() {
    return _stores.map(_buildItem).toList();
    // return _stores.map((contact) => new ChildItem(contact.name)).toList();
  }

  List<Widget> _buildSearchList() {
    if (_searchText.isEmpty) {
      return _stores.map(_buildItem).toList();
      //return _stores.map((contact) => new ChildItem(contact.name)).toList();
    } else {
      List<EntityAppData> _searchList = List();
      for (int i = 0; i < _stores.length; i++) {
        String name = _stores.elementAt(i).name;
        if (name.toLowerCase().contains(_searchText.toLowerCase())) {
          _searchList.add(_stores.elementAt(i));
        }
      }
      return _searchList.map(_buildItem).toList();
    }
  }

  void addFilterCriteria() {}
  String filterVar = "0";
  Widget buildBar(BuildContext context, Widget appBarTitle) {
    return new AppBar(
      titleSpacing: 5,
      flexibleSpace: Container(
        decoration: gradientBackground,
      ),
      centerTitle: true,
      title: appBarTitle,
      backgroundColor: Colors.teal,
      actions: <Widget>[
        // new IconButton(
        //     padding: EdgeInsets.all(0),
        //     // constraints: BoxConstraints(maxHeight: 25, maxWidth: 27),
        //     icon: new Icon(
        //       Icons.close,
        //       size: 20,
        //       color: Colors.white,
        //     ),
        //     onPressed: () {
        //       _handleSearchEnd();
        //     }),
      ],
    );
  }

  void _handleSearchStart() {
    setState(() {
      _isSearching = true;
    });
  }

  void _handleSearchEnd() {
    setState(() {
      _isSearching = false;
      _searchQuery.clear();
    });
  }
}

class ChildItem extends StatelessWidget {
  final String name;
  ChildItem(this.name);
  @override
  Widget build(BuildContext context) {
    return new ListTile(title: new Text(this.name));
  }
}
