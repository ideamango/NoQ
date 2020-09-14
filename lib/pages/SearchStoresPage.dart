import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';
import 'package:noq/constants.dart';
import 'package:noq/db/db_model/address.dart';
import 'package:noq/db/db_model/entity.dart';
import 'package:noq/db/db_model/meta_entity.dart';
import 'package:noq/db/db_model/user_token.dart';
import 'package:noq/db/db_service/entity_service.dart';
import 'package:noq/global_state.dart';
import 'package:noq/pages/search_child_page.dart';
import 'package:noq/pages/showSlotsPage.dart';
import 'package:noq/services/circular_progress.dart';
import 'package:noq/services/mapService.dart';
import 'package:noq/style.dart';
import 'package:noq/utils.dart';
import 'package:noq/widget/appbar.dart';
import 'package:noq/widget/bottom_nav_bar.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../userHomePage.dart';

class SearchStoresPage extends StatefulWidget {
  //final String forPage;

  //SearchStoresPage({Key key, @required this.forPage}) : super(key: key);
  @override
  _SearchStoresPageState createState() => _SearchStoresPageState();
}

class _SearchStoresPageState extends State<SearchStoresPage> {
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
  String _searchInAll = 'Search in All';
  bool searchBoxClicked = false;
  bool fetchFromServer = false;
  // bool searchDone = false;

  final compareDateFormat = new DateFormat('YYYYMMDD');
  List<DateTime> _dateList = new List<DateTime>();

  Icon actionIcon = new Icon(
    Icons.search,
    color: Colors.white,
  );
  final key = new GlobalKey<ScaffoldState>();
  static final TextEditingController _searchTextController =
      new TextEditingController();
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
    getGlobalState().whenComplete(() {
      fetchPastSearchesList();
      searchTypes = _state.conf.entityTypes;
      //insert only if 'All' option not there
      if (!searchTypes.contains(_searchInAll))
        searchTypes.insert(0, _searchInAll);
      setState(() {
        initCompleted = true;
      });
    });
  }

  void fetchPastSearchesList() {
    //Load details from local files
    // if (initCompleted) {
    if (!Utils.isNullOrEmpty(_state.pastSearches)) {
      setState(() {
        _pastSearches = _state.pastSearches;
      });

      // }
    } else if (_state.pastSearches != null && _state.pastSearches.length == 0)
      emptyPageMsg = "No previous searches. Start Exploring now!!";
    //  _list = _stores;
  }

  _SearchStoresPageState() {
    _searchTextController.addListener(() {
      if (_searchTextController.text.isEmpty && _entityType == null) {
        setState(() {
          _isSearching = "initial";
          _searchText = "";
        });
      } else {
        if (_searchTextController.text.length >= 3) {
          setState(() {
            _isSearching = "searching";
            _searchText = _searchTextController.text;
          });
          _buildSearchList();
        }
      }
    });
  }

  Future<void> getPrefInstance() async {
    _prefs = await SharedPreferences.getInstance();
  }

  Future<void> getGlobalState() async {
    _state = await GlobalState.getGlobalState();
  }

  void getChildStoresList() async {
    _list = _stores;
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

  String getFormattedAddress(Address address) {
    String adr = (address.address != null ? (address.address + ', ') : "") +
        (address.locality != null ? (address.locality + ', ') : "") +
        (address.landmark != null ? (address.landmark + ', ') : "") +
        (address.city != null ? (address.city + ', ') : "");
    return adr;
  }

  Widget _emptySearchPage() {
    String defaultMsg = 'No matching results.Try again. ';
    String txtMsg = (emptyPageMsg != null) ? emptyPageMsg : defaultMsg;
    return Center(
        child: Container(
      margin: EdgeInsets.fromLTRB(10, MediaQuery.of(context).size.width * .45,
          10, MediaQuery.of(context).size.width * .45),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Text(txtMsg, style: highlightTextStyle),
          Text('Add your favourite places to quickly browse through later!! ',
              style: highlightSubTextStyle),
        ],
      ),
    ));
  }

  Widget _listSearchResults() {
    if (_stores.length == 0)
      return _emptySearchPage();
    else {
      //Add search results to past searches.
      _state.pastSearches = _stores;
      return Column(
        children: <Widget>[
          Expanded(
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
          ),
        ],
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
              titleTxt: "Search",
            ),
            body: Center(
              child: Container(
                margin: EdgeInsets.fromLTRB(
                    10,
                    MediaQuery.of(context).size.width * .5,
                    10,
                    MediaQuery.of(context).size.width * .5),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    showCircularProgress(),
                  ],
                ),
              ),
            ),
            //drawer: CustomDrawer(),
            bottomNavigationBar: CustomBottomBar(barIndex: 1)),
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
      Widget searchInputText = Container(
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
          controller: _searchTextController,
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
                    _searchTextController.clear();
                    _searchText = "";
                    setState(() {
                      _isSearching = "searching";
                    });
                    _buildSearchList();
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
          onChanged: (value) {
            if (_searchTextController.text.isEmpty) {
              if (_entityType == null)
                setState(() {
                  _isSearching = "initial";
                  _searchText = "";
                });
              else {
                _searchText = _searchTextController.text;
                _buildSearchList();
              }
            } else {
              if (_searchTextController.text.length >= 3) {
                setState(() {
                  _isSearching = "searching";
                  _searchText = _searchTextController.text;
                });
                _buildSearchList();
              }
            }
          },
        ),
      );
      Widget filterBar = Container(
        margin: EdgeInsets.fromLTRB(0, 5, 0, 0),
        //  padding: EdgeInsets.fromLTRB(5, 0, 5, 0),
        //decoration: gradientBackground,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: <Widget>[categoryDropDown, searchInputText],
        ),
      );
      String title = "Search";
      print(_searchText);
      print(_entityType);
      if (_isSearching == "initial" &&
          _searchText.isEmpty &&
          _entityType == null)
        return MaterialApp(
          routes: <String, WidgetBuilder>{
            '/childSearch': (BuildContext context) => SearchChildrenPage(),
            '/mainSearch': (BuildContext context) => SearchStoresPage(),
          },
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
              // drawer: CustomDrawer(),
              bottomNavigationBar: CustomBottomBar(barIndex: 1)

              // drawer: CustomDrawer(),
              ),
        );
      else {
        print("Came in isSearching");
        return MaterialApp(
          routes: <String, WidgetBuilder>{
            '/childSearch': (BuildContext context) => SearchChildrenPage(),
            '/mainSearch': (BuildContext context) => SearchStoresPage(),
          },
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
                child: Column(
                  children: <Widget>[
                    filterBar,
                    Expanded(
                      child: (_isSearching == "done")
                          ? _listSearchResults()
                          //Else could be one when isSearching is 'searching', show circular progress.
                          : Center(
                              child: Container(
                                margin: EdgeInsets.fromLTRB(
                                    10,
                                    MediaQuery.of(context).size.width * .45,
                                    10,
                                    MediaQuery.of(context).size.width * .45),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: <Widget>[
                                    showCircularProgress(),
                                  ],
                                ),
                              ),
                            ),
                    ),
                  ],
                ),
              ),
              // drawer: CustomDrawer(),
              bottomNavigationBar: CustomBottomBar(barIndex: 1)

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
        //TODO: If entity has child then fecth them from server show in next screen
        if (str.childEntities.length != 0) {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => SearchChildrenPage(
                      childList: str.childEntities, parentName: str.name)));
        }

        // if (child.length != 0) {
        //   Navigator.push(
        //       context,
        //       MaterialPageRoute(
        //           builder: (context) => SearchStoresPage(forPage: "Child")));

        //   // Navigator.push(
        //   //     context,
        //   //     MaterialPageRoute(
        //   //         builder: (context) => EntityServicesListPage(entity: str)));
        // }
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
                                  height: 25.0,
                                  width: 28.0,
                                  child: IconButton(
                                    padding: EdgeInsets.fromLTRB(0, 0, 0, 0),
                                    alignment: Alignment.center,
                                    highlightColor: Colors.orange[300],
                                    icon: ImageIcon(
                                      AssetImage('assets/whatsapp.png'),
                                      size: 20,
                                      color: primaryIcon,
                                    ),
                                    onPressed: () {
                                      launchWhatsApp(
                                          message: whatsappMessage,
                                          phone: '+919611009823');
                                      // callPhone('+919611009823');
                                      //callPhone(str.);
                                    },
                                  ),
                                ),
                                Container(
                                  padding: EdgeInsets.fromLTRB(0, 0, 0, 0),
                                  margin: EdgeInsets.fromLTRB(0, 0, 0, 0),
                                  height: 25.0,
                                  width: 28.0,
                                  child: IconButton(
                                    padding: EdgeInsets.fromLTRB(0, 0, 0, 0),
                                    alignment: Alignment.center,
                                    highlightColor: Colors.orange[300],
                                    icon: Icon(
                                      Icons.phone,
                                      color: primaryIcon,
                                      size: 20,
                                    ),
                                    onPressed: () {
                                      // callPhone('+919611009823');
//TODO : SMita Edit this to pick phone number of public contact person.
                                      callPhone(str.managers[0].ph);
                                    },
                                  ),
                                ),
                                Container(
                                  padding: EdgeInsets.fromLTRB(0, 0, 0, 0),
                                  margin: EdgeInsets.fromLTRB(0, 0, 0, 0),
                                  height: 25.0,
                                  width: 28.0,
                                  child: IconButton(
                                    padding: EdgeInsets.fromLTRB(0, 0, 0, 0),
                                    alignment: Alignment.center,
                                    highlightColor: Colors.orange[300],
                                    icon: Icon(
                                      Icons.location_on,
                                      color: primaryIcon,
                                      size: 20,
                                    ),
                                    onPressed: () => launchURL(
                                        str.name,
                                        getFormattedAddress(str.address),
                                        str.coordinates.geopoint.latitude,
                                        str.coordinates.geopoint.longitude),
                                  ),
                                ),
                                Container(
                                  padding: EdgeInsets.fromLTRB(0, 0, 0, 0),
                                  margin: EdgeInsets.fromLTRB(0, 0, 0, 0),
                                  height: 25,
                                  width: 25,
                                  child: IconButton(
                                    padding: EdgeInsets.fromLTRB(0, 0, 0, 0),
                                    alignment: Alignment.center,
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
                        width: MediaQuery.of(context).size.width * .78,
                        child: Text(
                          (str.address != null)
                              ? getFormattedAddress(str.address)
                              : "Address",
                          overflow: TextOverflow.ellipsis,
                          style: labelSmlTextStyle,
                        ),
                      ),
                    ],
                  ),
                  Container(
                      width: MediaQuery.of(context).size.width * .68,
                      //padding: EdgeInsets.fromLTRB(0, 5, 5, 5),
                      child: Row(
                        children: <Widget>[
                          if (str.isBookable && str.isActive)
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
                            Text(
                                Utils.formatTime(str.startTimeHour.toString()) +
                                    ':' +
                                    Utils.formatTime(
                                        str.startTimeMinute.toString()),
                                style: labelSmlTextStyle),
                          ],
                        ),
                        Container(
                            width: MediaQuery.of(context).size.width * .02,
                            child: Text('')),
                        Row(
                          children: [
                            //Icon(Icons.pause_circle_filled, color: Colors.blueGrey[300]),
                            Text('Closes at:', style: labelTextStyle),
                            Text(
                                Utils.formatTime(str.endTimeHour.toString()) +
                                    ':' +
                                    Utils.formatTime(
                                        str.endTimeMinute.toString()),
                                style: labelSmlTextStyle),
                          ],
                        ),
                      ]),
                  if (!str.isBookable && str.isActive)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: <Widget>[
                        RaisedButton(
                          color: btnColor,
                          onPressed: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => SearchChildrenPage(
                                        childList: str.childEntities,
                                        parentName: str.name,
                                        parentId: str.entityId)));
                          },
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              Text(
                                'Explore amenities   ',
                                style: TextStyle(color: Colors.white),
                              ),
                              Container(
                                transform:
                                    Matrix4.translationValues(28.0, 0, 0),
                                child: Icon(
                                  Icons.arrow_forward_ios,
                                  color: Colors.white38,
                                ),
                              ),
                              Container(
                                transform:
                                    Matrix4.translationValues(14.0, 0, 0),
                                child: Icon(
                                  Icons.arrow_forward_ios,
                                  color: Colors.white70,
                                ),
                              ),
                              Icon(
                                Icons.arrow_forward_ios,
                                color: Colors.white,
                              )
                            ],
                          ),
                        )
                      ],
                    )
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
            builder: (context) => ShowSlotsPage(
                  entity: store,
                  dateTime: dateTime,
                  forPage: 'MainSearch',
                )));

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
    //lat = 12.960632;
    //lon = 77.641603;

    //TODO: comment - only for testing
    String entityTypeForSearch;
    entityTypeForSearch = (_entityType == _searchInAll) ? null : _entityType;

    List<Entity> searchEntityList = await EntityService().search(
        _searchText.toLowerCase(),
        entityTypeForSearch,
        lat,
        lon,
        radiusOfSearch,
        pageNumber,
        pageSize);
    return searchEntityList;
  }

  Future<void> _buildSearchList() async {
    // if (_searchText.isEmpty && _entityType.isEmpty) {
    //   return _stores.map(_buildItem).toList();
    //   //return _stores.map((contact) => new ChildItem(contact.name)).toList();
    // } else {
    await getSearchEntitiesList().then((value) {
      //Scrutinize the list returned froms server.

      //1. entities that are bookable, public and active only should be listed
      //2. Parent entities
      _stores.clear();
      for (int i = 0; i < value.length; i++) {
        if (value[i].isActive) _stores.add(value[i]);
      }

      //Write Gstate to file
      _state.updateSearchResults(_stores);
      setState(() {
        //searchDone = true;
        _isSearching = "done";
      });
    });

    // for (int i = 0; i < _stores.length; i++) {
    //   String name = _stores.elementAt(i).name;
    //   if (name.toLowerCase().contains(_searchText.toLowerCase())) {
    //     _searchList.add(_stores.elementAt(i));
    //   }
    // }
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
