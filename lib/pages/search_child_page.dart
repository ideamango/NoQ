import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';
import 'package:noq/db/db_model/address.dart';
import 'package:noq/db/db_model/entity.dart';
import 'package:noq/db/db_model/meta_entity.dart';
import 'package:noq/db/db_model/user_token.dart';
import 'package:noq/db/db_service/entity_service.dart';
import 'package:noq/global_state.dart';
import 'package:noq/pages/showSlotsPage.dart';
import 'package:noq/repository/StoreRepository.dart';
import 'package:noq/services/circular_progress.dart';
import 'package:noq/services/mapService.dart';
import 'package:noq/style.dart';
import 'package:noq/utils.dart';
import 'package:noq/widget/appbar.dart';
import 'package:noq/widget/bottom_nav_bar.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../userHomePage.dart';

class SearchChildrenPage extends StatefulWidget {
  final List<MetaEntity> childList;
  final String parentName;
  SearchChildrenPage({Key key, this.childList, this.parentName})
      : super(key: key);
  @override
  _SearchChildrenPageState createState() => _SearchChildrenPageState();
}

class _SearchChildrenPageState extends State<SearchChildrenPage> {
  bool initCompleted = false;
  bool isFavourited = false;
  DateTime dateTime = DateTime.now();
  final dtFormat = new DateFormat('dd');
  SharedPreferences _prefs;
  GlobalState _globalState;
  List<Entity> _stores = new List<Entity>();
  List<Entity> _pastSearches = new List<Entity>();
  List<Entity> _searchResultstores = new List<Entity>();
  String _entityType;
  String _searchAll;
  bool searchBoxClicked = false;
  bool fetchFromServer = false;
  // bool searchDone = false;
  String title;
  final compareDateFormat = new DateFormat('YYYYMMDD');
  List<DateTime> _dateList = new List<DateTime>();

  Icon actionIcon = new Icon(
    Icons.search,
    color: Colors.white,
  );
  final key = new GlobalKey<ScaffoldState>();
  static final TextEditingController _searchQuery = new TextEditingController();
  List<Entity> _list;
  //"initial, searching,done"
  String _isSearching = "initial";
  String _searchText = "";
  String searchType = "";
  String pageName;
  GlobalState _state;
  bool stateInitFinished = false;
  String emptyPageMsg;
  List<String> searchTypes;

  @override
  void initState() {
    super.initState();
    _isSearching = "initial";
    title = "Search inside " + widget.parentName;
    getGlobalState().whenComplete(() {
      searchTypes = _state.conf.entityTypes;
      getEntitiesList().whenComplete(() {
        setState(() {
          initCompleted = true;
        });
      });
    });
  }

  String getFormattedAddress(Address address) {
    String adr = address.address +
        ', ' +
        address.locality +
        ', ' +
        address.landmark +
        ', ' +
        address.city;
    return adr;
  }

  _SearchChildrenPageState() {
    _searchQuery.addListener(() {
      if (_searchQuery.text.isEmpty && _entityType == null) {
        setState(() {
          _isSearching = "initial";
          _searchText = "";
        });
      } else {
        if (_searchQuery.text.length >= 3) {
          setState(() {
            _isSearching = "searching";
            _searchText = _searchQuery.text;
          });
          _buildSearchList();
        }
      }
    });
  }

  Future<void> getGlobalState() async {
    _state = await GlobalState.getGlobalState();
  }

  Future<void> getEntitiesList() async {
    List<Entity> enList = new List<Entity>();
    if (!Utils.isNullOrEmpty(widget.childList)) {
      for (int i = 0; i < widget.childList.length; i++) {
        Entity value = await getEntity(widget.childList[i].entityId);
        if (value != null) {
          enList.add(value);
        }
      }
    }
    setState(() {
      _stores.addAll(enList);
      _pastSearches.addAll(enList);
    });
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

  bool isFavourite(MetaEntity en) {
    List<MetaEntity> favs = _state.currentUser.favourites;
    if (Utils.isNullOrEmpty(favs)) return false;

    for (int i = 0; i < favs.length; i++) {
      if (favs[i].entityId == en.entityId) {
        return true;
      }
    }
    return false;
  }

  void toggleFavorite(Entity strData) {
//Check if its already User fav
    bool isFav = false;
    MetaEntity en = strData.getMetaEntity();
    isFav = isFavourite(en);
    if (isFav) {
      EntityService().removeEntityFromUserFavourite(en.entityId);
      setState(() {
        _state.removeFavourite(en);
      });
    } else {
      EntityService().addEntityToUserFavourite(en);
      setState(() {
        _state.addFavourite(en);
      });
    }
  }

  Widget _emptySearchPage() {
    String defaultMsg = 'No match found. Try again!!';
    String txtMsg = (emptyPageMsg != null) ? emptyPageMsg : defaultMsg;
    return Center(
        child: Container(
            margin: EdgeInsets.fromLTRB(
                10,
                MediaQuery.of(context).size.width * .5,
                10,
                MediaQuery.of(context).size.width * .5),
            child: Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Text(txtMsg, style: highlightTextStyle),
                  Text(
                      'Add your favourite places to quickly browse through later!! ',
                      style: highlightSubTextStyle),
                ],
              ),
            )));
  }

  Widget _listSearchResults() {
    if (_stores.length == 0)
      return _emptySearchPage();
    else {
      return Expanded(
        child: ListView.builder(
            itemCount: 1,
            itemBuilder: (BuildContext context, int index) {
              return Container(
                margin: EdgeInsets.fromLTRB(10, 10, 10, 10),
                child: new Column(
                  children: showSearchResults(),
                ),
              );
            }),
      );
    }

    //}
  }

  @override
  Widget build(BuildContext context) {
// build widget only after init has completed, till then show progress indicator.
    if (!initCompleted) {
      return MaterialApp(
        theme: ThemeData.light().copyWith(),
        home: Scaffold(
          appBar: CustomAppBar(
            titleTxt: title,
          ),
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                // Padding(padding: EdgeInsets.only(top: 20.0)),
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
          bottomNavigationBar: CustomBottomBar(barIndex: 1),
        ),
      );
    } else {
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
                  _isSearching = "searching";
                  _buildSearchList();
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
                icon: new Icon(Icons.search,
                    size: 20, color: Colors.blueGrey[500]),
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

      print(_searchText);
      print(_entityType);
      if (_isSearching == "initial" &&
          _searchText.isEmpty &&
          _entityType == null)
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
                    (!Utils.isNullOrEmpty(_pastSearches))
                        ? Expanded(
                            child: ListView.builder(
                                itemCount: 1,
                                itemBuilder: (BuildContext context, int index) {
                                  return Container(
                                    margin: EdgeInsets.fromLTRB(10, 10, 10, 10),
                                    child: new Column(
                                      children: showPastSearches(),
                                    ),
                                  );
                                }),
                          )
                        : _emptySearchPage(),
                  ],
                ),
              ),
            ),
            // drawer: CustomDrawer(),
            bottomNavigationBar: CustomBottomBar(barIndex: 1),
            // drawer: CustomDrawer(),
          ),
        );
      else {
        print("Came in isSearching");
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
                child: Expanded(
                  child: Column(
                    children: <Widget>[
                      filterBar,
                      (_isSearching == "done")
                          ? _listSearchResults()
                          : showCircularProgress(),
                    ],
                  ),
                ),
              ),
            ),
            // drawer: CustomDrawer(),
            bottomNavigationBar: CustomBottomBar(barIndex: 1),

            // drawer: CustomDrawer(),
          ),
        );
      }
    }
  }

  Widget _buildItem(Entity str) {
    _prepareDateList();
    //_buildDateGridItems(str.id);
    print('after buildDateGrid called');
    return GestureDetector(
      onTap: () {
        print("Container clicked");
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
                                    onPressed: () {
                                      // callPhone('+919611009823');
                                      //callPhone(str.);
                                    },
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
                                    onPressed: () => launchURL(
                                        str.name,
                                        str.address.toString(),
                                        str.coordinates.geopoint.latitude,
                                        str.coordinates.geopoint.longitude),
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
                                    icon: isFavourite(str.getMetaEntity())
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
                          (str.address != null)
                              ? getFormattedAddress(str.address)
                              : "Address",
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
                                str, str.entityId, str.name, str.closedOn),
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

  void showSlots(Entity store, DateTime dateTime) {
    //_prefs = await SharedPreferences.getInstance();

    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) =>
                ShowSlotsPage(entity: store, dateTime: dateTime)));

    print('After showDialog:');
    // });
  }

  List<Widget> _buildDateGridItems(
      Entity store, String sid, String sname, List<String> daysClosed) {
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

  Widget buildDateItem(Entity store, String sid, String sname, bool isClosed,
      DateTime dt, String dayOfWeek) {
    bool dateBooked = false;
    // UserAppData user = _userProfile;

    for (UserToken obj in (_state.bookings)) {
      if ((compareDateFormat
                  .format(dt)
                  .compareTo(compareDateFormat.format(obj.dateTime)) ==
              0) &&
          (obj.entityId == sid)) {
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
                  showSlots(store, dt);
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

  List<Widget> showPastSearches() {
    return _pastSearches.map(_buildItem).toList();
    // return _stores.map((contact) => new ChildItem(contact.name)).toList();
  }

  List<Widget> showSearchResults() {
    return _stores.map(_buildItem).toList();
    // return _stores.map((contact) => new ChildItem(contact.name)).toList();
  }

  Future<List<Entity>> getSearchEntitiesList() async {
    double lat = 0;
    double lon = 0;
    double radiusOfSearch = 10;
    int pageNumber = 0;
    int pageSize = 0;

    Position pos = await Utils().getCurrLocation();
    lat = pos.latitude;
    lon = pos.longitude;
    //TODO: comment - only for testing
    lat = 12.960632;
    lon = 77.641603;

    //TODO: comment - only for testing
    List<Entity> searchEntityList = await EntityService().search(
        _searchText.toLowerCase(),
        _entityType,
        lat,
        lon,
        radiusOfSearch,
        pageNumber,
        pageSize);
    return searchEntityList;
  }

  Future<void> _buildSearchList() async {
    //Search in _stores list if search criteria matches
    List<Entity> searchList = new List<Entity>();
    for (int i = 0; i < _stores.length; i++) {
      String name = _stores.elementAt(i).name;
      if (name.toLowerCase().contains(_searchText.toLowerCase())) {
        searchList.add(_stores.elementAt(i));
      }
    }
    _stores.clear();
    _stores.addAll(searchList);

    //Write Gstate to file
    _state.updateSearchResults(_stores);
    setState(() {
      //searchDone = true;
      _isSearching = "done";
    });
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

  // void _handleSearchStart() {
  //   setState(() {
  //     _isSearching = true;
  //   });
  // }

  // void _handleSearchEnd() {
  //   setState(() {
  //     _isSearching = false;
  //     _searchQuery.clear();
  //   });
  // }
}

class ChildItem extends StatelessWidget {
  final String name;
  ChildItem(this.name);
  @override
  Widget build(BuildContext context) {
    return new ListTile(title: new Text(this.name));
  }
}
