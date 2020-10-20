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
import 'package:noq/pages/SearchStoresPage.dart';
import 'package:noq/pages/favs_list_page.dart';
import 'package:noq/pages/showSlotsPage.dart';
import 'package:noq/repository/StoreRepository.dart';
import 'package:noq/services/circular_progress.dart';
import 'package:noq/services/mapService.dart';
import 'package:noq/style.dart';
import 'package:noq/utils.dart';
import 'package:noq/widget/appbar.dart';
import 'package:noq/widget/bottom_nav_bar.dart';
import 'package:noq/widget/widgets.dart';
import 'package:share/share.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../userHomePage.dart';

class SearchChildrenPage extends StatefulWidget {
  final String pageName;
  final List<MetaEntity> childList;
  final String parentName;
  final String parentId;
  SearchChildrenPage(
      {Key key, this.pageName, this.childList, this.parentName, this.parentId})
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

  String _fromPage;

  String _searchAll;
  bool searchBoxClicked = false;
  bool fetchFromServer = false;
  // bool searchDone = false;
  String title;
  final compareDateFormat = new DateFormat('YYYYMMDD');
  List<DateTime> _dateList = new List<DateTime>();
  String _dynamicLink;
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
  String _entityType;
  String searchType = "";
  String pageName;
  GlobalState _state;
  bool stateInitFinished = false;
  String emptyPageMsg;
  List<String> searchTypes;
  String _searchInAll = 'Search in All';

  @override
  void initState() {
    super.initState();
    _fromPage = widget.pageName;
    _isSearching = "initial";
    title = "Places inside " + widget.parentName;
    getGlobalState().whenComplete(() {
      searchTypes = _state.conf.entityTypes;
      if (!searchTypes.contains(_searchInAll))
        searchTypes.insert(0, _searchInAll);
      getEntitiesList().whenComplete(() {
        setState(() {
          initCompleted = true;
        });
      });
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  generateLinkAndShareWithParams(String entityId) async {
    var dynamicLink =
        await Utils.createDynamicLinkWithParams(entityId: entityId);
    print("Dynamic Link: $dynamicLink");

    _dynamicLink =
        Uri.https(dynamicLink.authority, dynamicLink.path).toString();
    // dynamicLink has been generated. share it with others to use it accordingly.
    Share.share(dynamicLink.toString());
  }

  _SearchChildrenPageState() {
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
          _buildSearchList(_entityType, _searchText);
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
    for (int i = 1; i <= 6; i++) {
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
    String defaultMsg = 'No places found!!';
    String txtMsg = (emptyPageMsg != null) ? emptyPageMsg : defaultMsg;
    return Expanded(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Text(txtMsg, style: highlightTextStyle),
          Text('Try again with different Name or Category. ',
              style: highlightSubTextStyle),
        ],
      ),
    );
  }

  Widget _listSearchResults() {
    if (_stores.length == 0)
      return _emptySearchPage();
    else {
      // _state.pastSearches = _stores;
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
                  valueColor: AlwaysStoppedAnimation<Color>(highlightColor),
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
              hint: new Text("Filter by Category"),
              style: TextStyle(fontSize: 12, color: Colors.blueGrey[500]),
              value: _entityType,
              isDense: true,
              // icon: Icon(Icons.search),
              onChanged: (newValue) {
                setState(() {
                  _entityType = newValue;
                  _isSearching = "searching";
                  _buildSearchList(_entityType, _searchText);
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
        alignment: Alignment.center,
        child: new TextField(
          autofocus: true,
          controller: _searchTextController,
          cursorColor: Colors.blueGrey[500],
          cursorWidth: 1,
          textAlignVertical: TextAlignVertical.center,
          style: new TextStyle(fontSize: 12, color: Colors.blueGrey[700]),
          decoration: new InputDecoration(
              contentPadding: EdgeInsets.all(2),
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
                    size: 17, color: Colors.blueGrey[500]),
                alignment: Alignment.center,
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
                    _buildSearchList(_entityType, _searchText);
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
              hintText: "Filter by Name",
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
                _buildSearchList(_entityType, _searchText);
              }
            } else {
              if (_searchTextController.text.length >= 3) {
                setState(() {
                  _isSearching = "searching";
                  _searchText = _searchTextController.text;
                });
                _buildSearchList(_entityType, _searchText);
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
                      if (_fromPage == "Favs")
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => FavsListPage()));
                      else if (_fromPage == "Search")
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => SearchStoresPage()));
                      // else if (_fromPage == "ShowSlots")
                      //   Navigator.push(
                      //       context,
                      //       MaterialPageRoute(
                      //           builder: (context) => SearchStoresPage()));
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
                              builder: (context) => SearchStoresPage()));
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
        if (str.childEntities.length != 0) {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => SearchChildrenPage(
                        pageName: "SearchChild",
                        childList: str.childEntities,
                        parentName: str.name,
                        parentId: str.entityId,
                      )));
        }
      },
      child: Card(
        elevation: 10,
        child: Column(
          children: <Widget>[
            new Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              // mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Container(
                  width: MediaQuery.of(context).size.width * .1,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      new Container(
                        margin: EdgeInsets.fromLTRB(
                            MediaQuery.of(context).size.width * .01,
                            MediaQuery.of(context).size.width * .01,
                            MediaQuery.of(context).size.width * .005,
                            MediaQuery.of(context).size.width * .005),
                        padding: EdgeInsets.all(
                            MediaQuery.of(context).size.width * .01),
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
                      ),
                      verticalSpacer,
                    ],
                  ),
                ),
                Container(
                  width: MediaQuery.of(context).size.width * .82,
                  padding: EdgeInsets.all(2),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Container(
                        width: MediaQuery.of(context).size.width * .78,
                        padding: EdgeInsets.all(0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            Container(
                              width: MediaQuery.of(context).size.width * .5,
                              padding: EdgeInsets.all(0),
                              child: Row(
                                // mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                // crossAxisAlignment: CrossAxisAlignment.center,
                                children: <Widget>[
                                  Text(
                                    (str.name) ?? str.name.toString(),
                                    style: TextStyle(fontSize: 17),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  (str.verificationStatus == "Verified")
                                      ? new Container(
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              .06,
                                          height: MediaQuery.of(context)
                                                  .size
                                                  .height *
                                              .03,
                                          child: IconButton(
                                            padding:
                                                EdgeInsets.fromLTRB(1, 1, 0, 2),
                                            icon: Icon(
                                              Icons.verified_user,
                                              color: Colors.green,
                                              size: 15,
                                            ),
                                            onPressed: () {
                                              Utils.showMyFlushbar(
                                                  context,
                                                  Icons.info,
                                                  Duration(seconds: 5),
                                                  "Verified",
                                                  "");
                                            },
                                          ),
                                        )
                                      : Container(),
                                  (str.isPublic != true)
                                      ? Container(
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              .06,
                                          height: MediaQuery.of(context)
                                                  .size
                                                  .height *
                                              .03,
                                          child: IconButton(
                                            padding:
                                                EdgeInsets.fromLTRB(1, 1, 1, 2),
                                            icon: Icon(
                                              Icons.lock,
                                              color: primaryIcon,
                                              size: 15,
                                            ),
                                            onPressed: () {
                                              Utils.showMyFlushbar(
                                                  context,
                                                  Icons.info,
                                                  Duration(seconds: 5),
                                                  "Access to this place is restricted to its residents or employees.",
                                                  "");
                                            },
                                          ),
                                        )
                                      : Container(),
                                ],
                              ),
                            ),
                            Container(
                              width: MediaQuery.of(context).size.width * .2,
                              padding: EdgeInsets.all(0),
                              child: Row(
                                children: <Widget>[
                                  Text(
                                      Utils.formatTime(
                                              str.startTimeHour.toString()) +
                                          ':' +
                                          Utils.formatTime(
                                              str.startTimeMinute.toString()),
                                      style: TextStyle(
                                          color: Colors.green[600],
                                          fontFamily: 'Monsterrat',
                                          letterSpacing: 0.5,
                                          fontSize: 10.0)),
                                  Text(' - '),
                                  Text(
                                      Utils.formatTime(
                                              str.endTimeHour.toString()) +
                                          ':' +
                                          Utils.formatTime(
                                              str.endTimeMinute.toString()),
                                      style: TextStyle(
                                          color: Colors.red[900],
                                          fontFamily: 'Monsterrat',
                                          letterSpacing: 0.5,
                                          fontSize: 10.0)),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          Container(
                            width: MediaQuery.of(context).size.width * .78,
                            child: Text(
                              (Utils.getFormattedAddress(str.address) != "")
                                  ? Utils.getFormattedAddress(str.address)
                                  : "No Address found",
                              overflow: TextOverflow.ellipsis,
                              style: labelSmlTextStyle,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 5),
                      if (str.isBookable != null && str.isActive != null)
                        if (str.isBookable && str.isActive)
                          Container(
                              width: MediaQuery.of(context).size.width * .78,
                              //padding: EdgeInsets.fromLTRB(0, 5, 5, 5),
                              child: Row(
                                children: <Widget>[
                                  Row(
                                    children: _buildDateGridItems(
                                        str,
                                        str.entityId,
                                        str.name,
                                        str.closedOn,
                                        str.advanceDays),
                                  ),
                                ],
                              )),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 3),
            new Divider(
              color: Colors.blueGrey[500],
              height: 2,
              indent: 0,
              endIndent: 0,
            ),
            Container(
              padding: EdgeInsets.all(4),
              //color: Colors.grey[200],
              child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    SizedBox(width: 5),
                    Container(
                      padding: EdgeInsets.all(0),
                      margin: EdgeInsets.all(0),
                      height: 35.0,
                      width: 45.0,
                      child: RaisedButton(
                        elevation: 5,
                        padding: EdgeInsets.all(5),
                        // alignment: Alignment.center,
                        shape: RoundedRectangleBorder(
                            side: BorderSide(color: Colors.blueGrey[200]),
                            borderRadius:
                                BorderRadius.all(Radius.circular(5.0))),
                        color: Colors.white,
                        splashColor: highlightColor,
                        child: ImageIcon(
                          AssetImage('assets/whatsapp.png'),
                          size: 30,
                          color: primaryDarkColor,
                        ),
                        onPressed: () {
                          if (str.whatsapp != null && str.whatsapp != "") {
                            try {
                              launchWhatsApp(
                                  message: whatsappMessage,
                                  phone: str.whatsapp);
                            } catch (error) {
                              Utils.showMyFlushbar(
                                  context,
                                  Icons.error,
                                  Duration(seconds: 5),
                                  "Could not connect to the Whatsapp number ${str.whatsapp} !!",
                                  "Try again later");
                            }
                          } else {
                            Utils.showMyFlushbar(
                                context,
                                Icons.info,
                                Duration(seconds: 5),
                                "Whatsapp contact information not found!!",
                                "");
                          }
                          // callPhone('+919611009823');
                          //callPhone(str.);
                        },
                      ),
                    ),
                    // SizedBox(width: 1),
                    Container(
                      padding: EdgeInsets.all(0),
                      margin: EdgeInsets.all(0),
                      height: 35.0,
                      width: 45.0,
                      child: RaisedButton(
                        elevation: 5,
                        padding: EdgeInsets.fromLTRB(2, 3, 2, 3),
                        shape: RoundedRectangleBorder(
                            side: BorderSide(color: Colors.blueGrey[200]),
                            borderRadius:
                                BorderRadius.all(Radius.circular(5.0))),
                        color: Colors.white,
                        splashColor: highlightColor,
                        child: Icon(
                          Icons.phone,
                          color: primaryDarkColor,
                          size: 25,
                        ),
                        onPressed: () {
                          // callPhone('+919611009823');
                          //TODO: Change this phone number later

                          if (str.phone != null) {
                            try {
                              callPhone(str.phone);
                            } catch (error) {
                              Utils.showMyFlushbar(
                                  context,
                                  Icons.error,
                                  Duration(seconds: 5),
                                  "Could not connect call to the number ${str.phone} !!",
                                  "Try again later.");
                            }
                          } else {
                            Utils.showMyFlushbar(
                                context,
                                Icons.info,
                                Duration(seconds: 5),
                                "Contact information not found!!",
                                "");
                          }
                        },
                      ),
                    ),

                    Container(
                      padding: EdgeInsets.all(0),
                      margin: EdgeInsets.all(0),
                      height: 35.0,
                      width: 45.0,
                      child: RaisedButton(
                          elevation: 5,
                          padding: EdgeInsets.fromLTRB(2, 3, 2, 3),
                          shape: RoundedRectangleBorder(
                              side: BorderSide(color: Colors.blueGrey[200]),
                              borderRadius:
                                  BorderRadius.all(Radius.circular(5.0))),
                          color: Colors.white,
                          splashColor: highlightColor,
                          child: Icon(
                            Icons.location_on,
                            color: primaryDarkColor,
                            size: 25,
                          ),
                          onPressed: () {
                            try {
                              if (str.coordinates.geopoint.latitude != null)
                                launchURL(
                                    str.name,
                                    Utils.getFormattedAddress(str.address),
                                    str.coordinates.geopoint.latitude,
                                    str.coordinates.geopoint.longitude);
                              else {
                                Utils.showMyFlushbar(
                                    context,
                                    Icons.error,
                                    Duration(seconds: 5),
                                    "Oops..No GPS location found for this premise!!",
                                    "");
                              }
                            } catch (error) {
                              Utils.showMyFlushbar(
                                  context,
                                  Icons.error,
                                  Duration(seconds: 5),
                                  "Could not open Maps!!",
                                  "Try again later.");
                            }
                          }),
                    ),

                    Container(
                        padding: EdgeInsets.all(0),
                        margin: EdgeInsets.all(0),
                        height: 35.0,
                        width: 45.0,
                        child: RaisedButton(
                          elevation: 5,
                          padding: EdgeInsets.fromLTRB(2, 3, 2, 3),
                          shape: RoundedRectangleBorder(
                              side: BorderSide(color: Colors.blueGrey[200]),
                              borderRadius:
                                  BorderRadius.all(Radius.circular(5.0))),
                          color: Colors.white,
                          splashColor: highlightColor,
                          child: Icon(
                            Icons.share,
                            color: primaryDarkColor,
                            size: 25,
                          ),
                          onPressed: () {
                            generateLinkAndShareWithParams(str.entityId);
                          },
                        )),
                    Container(
                      padding: EdgeInsets.all(0),
                      margin: EdgeInsets.all(0),
                      height: 35.0,
                      width: 45.0,
                      child: RaisedButton(
                        elevation: 5,
                        padding: EdgeInsets.fromLTRB(2, 3, 2, 3),
                        shape: RoundedRectangleBorder(
                            side: BorderSide(color: Colors.blueGrey[200]),
                            borderRadius:
                                BorderRadius.all(Radius.circular(5.0))),
                        color: Colors.white,
                        splashColor: highlightColor,
                        onPressed: () => toggleFavorite(str),
                        highlightColor: Colors.orange[300],
                        child: isFavourite(str.getMetaEntity())
                            ? Icon(Icons.favorite,
                                color: Colors.red[800], size: 25)
                            : Icon(
                                Icons.favorite_border,
                                color: primaryIcon,
                              ),
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        if (str.childEntities.length != 0)
                          Container(
                            padding: EdgeInsets.all(0),
                            margin: EdgeInsets.all(0),
                            width: 50,
                            height: 40,
                            child: FlatButton(
                              padding: EdgeInsets.all(0),
                              color: Colors.white,
                              splashColor: highlightColor.withOpacity(.8),
                              onPressed: () {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            SearchChildrenPage(
                                                pageName: "Favs",
                                                childList: str.childEntities,
                                                parentName: str.name)));
                              },
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: <Widget>[
                                  Container(
                                    padding: EdgeInsets.fromLTRB(0, 0, 0, 0),
                                    transform:
                                        Matrix4.translationValues(8.0, 0, 0),
                                    child: Icon(
                                      Icons.arrow_forward_ios,
                                      color: Colors.cyan[400],
                                      size: 25,
                                      // color: Colors.white38,
                                    ),
                                  ),
                                  // Container(
                                  //   transform: Matrix4.translationValues(
                                  //       5.0, 0, 0),
                                  //   child: Icon(
                                  //     Icons.arrow_forward_ios,
                                  //     color: Colors.cyan[600],
                                  //     size: 10,
                                  //     // color: Colors.white70,
                                  //   ),
                                  // ),
                                  Container(
                                    padding: EdgeInsets.fromLTRB(0, 0, 0, 0),
                                    transform:
                                        Matrix4.translationValues(-8.0, 0, 0),
                                    child: Icon(
                                      Icons.arrow_forward_ios,
                                      color: primaryDarkColor,
                                      size: 25,
                                      // color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        if (str.childEntities.length == 0)
                          Container(
                            width: 40,
                            height: 40,
                          ),
                      ],
                    ),
                  ]),
            ),
          ],
        ),
      ),
    );
  }

  void showSlots(Entity store, DateTime dateTime) {
    //_prefs = await SharedPreferences.getInstance();
    if (_fromPage == 'Favs')
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => ShowSlotsPage(
                    entity: store,
                    dateTime: dateTime,
                    forPage: 'FavChild',
                  )));
    else if (_fromPage == 'Search')
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => ShowSlotsPage(
                    entity: store,
                    dateTime: dateTime,
                    forPage: 'ChildSearch',
                  )));

    print('After showDialog:');
    // });
  }

  List<Widget> _buildDateGridItems(Entity store, String sid, String sname,
      List<String> daysClosed, int advanceDays) {
    bool isClosed = false;
    bool isBookingAllowed = false;
    int daysCounter = 0;
    String dayOfWeek;
    var dateWidgets = List<Widget>();
    for (var date in _dateList) {
      daysCounter++;
      if (daysCounter <= advanceDays) {
        isBookingAllowed = true;
      } else
        isBookingAllowed = false;
      print("booking not allowed beyond $advanceDays");
      print("Check:${DateFormat('EEEE').format(date)}");
      for (String str in daysClosed) {
        if (str.toLowerCase() ==
            DateFormat('EEEE').format(date).toLowerCase()) {
          isClosed = true;
          break;
        } else {
          isClosed = false;
        }
      }
      dayOfWeek = Utils.getDayOfWeek(date);
      dateWidgets.add(buildDateItem(store, sid, sname, isClosed,
          isBookingAllowed, advanceDays, date, dayOfWeek));
      print('Widget build from datelist  called');
    }
    return dateWidgets;
  }

  Widget buildDateItem(Entity store, String sid, String sname, bool isClosed,
      bool isBookingAllowed, int advanceDays, DateTime dt, String dayOfWeek) {
    bool dateBooked = false;
    // UserAppData user = _userProfile;

    for (UserToken obj in (_state.bookings)) {
      if ((compareDateFormat
                  .format(dt)
                  .compareTo(compareDateFormat.format(obj.dateTime)) ==
              0) &&
          (obj.entityId == sid) &&
          obj.number != -1) {
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
                ? disabledColor
                : (!isBookingAllowed
                    ? disabledColor
                    : (dateBooked
                        ? primaryAccentColor
                        : primaryDarkColor)), // button color
            child: InkWell(
              splashColor:
                  (isClosed || !isBookingAllowed) ? null : highlightColor,
              onTap: () {
                if (isClosed) {
                  Utils.showMyFlushbar(
                    context,
                    Icons.info,
                    Duration(seconds: 5),
                    "This premise is closed on this day.",
                    "Select a different date.",
                  );
                } else if (!isBookingAllowed) {
                  Utils.showMyFlushbar(
                    context,
                    Icons.info,
                    Duration(seconds: 5),
                    "This premise allows advance booking for upto $advanceDays days ",
                    "Please select an earlier date.",
                  );
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
                      style: TextStyle(
                          fontSize: 15,
                          color: (isClosed
                              ? Colors.red
                              : (!isBookingAllowed
                                  ? Colors.grey[200]
                                  : Colors.white)))),
                  Text(dayOfWeek,
                      style: TextStyle(
                          fontSize: 8,
                          color: (isClosed
                              ? Colors.red
                              : (!isBookingAllowed
                                  ? Colors.grey[200]
                                  : Colors.white)))), // text
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

  // Future<List<Entity>> getSearchEntitiesList() async {
  //   double lat = 0;
  //   double lon = 0;
  //   double radiusOfSearch = 10;
  //   int pageNumber = 0;
  //   int pageSize = 0;

  //   Position pos = await Utils().getCurrLocation();
  //   lat = pos.latitude;
  //   lon = pos.longitude;
  //   //TODO: comment - only for testing
  //   lat = 12.960632;
  //   lon = 77.641603;

  //   //TODO: comment - only for testing
  //   List<Entity> searchEntityList = await EntityService().search(
  //       _searchText.toLowerCase(),
  //       _entityType,
  //       lat,
  //       lon,
  //       radiusOfSearch,
  //       pageNumber,
  //       pageSize);
  //   return searchEntityList;
  // }

  Future<void> _buildSearchList(String type, String name) async {
    //Search in _stores list if search criteria matches
    List<Entity> searchList = new List<Entity>();
    for (int i = 0; i < _stores.length; i++) {
      Entity en = _stores.elementAt(i);

      if (type != null) {
        if (en.type != type) {
          continue;
        }
        if (name != null && name != "") {
          if (name.toLowerCase().contains(_searchText.toLowerCase())) {
            searchList.add(en);
          }
        } else {
          searchList.add(en);
        }
      }
    }
    _stores.clear();
    _stores.addAll(searchList);

    //Write Gstate to file
    //_state.updateSearchResults(_stores);
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
