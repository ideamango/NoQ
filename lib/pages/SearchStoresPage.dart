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
import 'package:noq/widget/widgets.dart';
import 'package:share/share.dart';
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
  String messageTitle;
  String messageSubTitle;
  String _dynamicLink;

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
      messageTitle = "No previous searches!!";
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

  generateLinkAndShareWithParams(String entityId) async {
    var dynamicLink =
        await Utils.createDynamicLinkWithParams(entityId: entityId);
    print("Dynamic Link: $dynamicLink");

    _dynamicLink =
        Uri.https(dynamicLink.authority, dynamicLink.path).toString();
    // dynamicLink has been generated. share it with others to use it accordingly.
    Share.share(_dynamicLink.toString());
  }

  String getFormattedAddress(Address address) {
    String adr = (address.address != null ? (address.address + ', ') : "") +
        (address.locality != null ? (address.locality + ', ') : "") +
        (address.landmark != null ? (address.landmark + ', ') : "") +
        (address.city != null ? (address.city) : "");
    return adr;
  }

  Widget _emptySearchPage() {
    String defaultMsg = 'No places found!! ';
    String defaultSubMsg = 'Try again with different Name or Category.  ';
    String txtMsg = (messageTitle != null) ? messageTitle : defaultMsg;
    String txtSubMsg =
        (messageSubTitle != null) ? messageSubTitle : defaultSubMsg;
    return Center(
      child: Container(
        height: MediaQuery.of(context).size.height * .6,
        alignment: Alignment.center,
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              // SizedBox(
              //   height: MediaQuery.of(context).size.height * .25,
              // ),
              Text(
                txtMsg,
                style: highlightTextStyle,
                textAlign: TextAlign.center,
              ),
              Text(
                txtSubMsg,
                style: highlightSubTextStyle,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _listSearchResults() {
    if (_stores.length == 0)
      return _emptySearchPage();
    else {
      //Add search results to past searches.
      _state.pastSearches = _stores;
      return Center(
        child: Column(
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
        ),
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
        alignment: Alignment.center,
        child: new TextField(
          // autofocus: true,
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
              resizeToAvoidBottomInset: false,
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
              body: Column(
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
                        pageName: "Search",
                        childList: str.childEntities,
                        parentName: str.name,
                        parentId: str.entityId,
                      )));
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
                  width: MediaQuery.of(context).size.width * .8,
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
                                // mainAxisAlignment: Mai1nAxisAlignment.spaceBetween,
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
                                          fontSize: 13.0)),
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
                                          fontSize: 13.0)),
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
                              (str.address != null)
                                  ? getFormattedAddress(str.address)
                                  : "Address",
                              overflow: TextOverflow.ellipsis,
                              style: labelSmlTextStyle,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 5),
                      if (str.isBookable && str.isActive)
                        Container(
                            width: MediaQuery.of(context).size.width * .78,
                            //padding: EdgeInsets.fromLTRB(0, 5, 5, 5),
                            child: Row(
                              children: <Widget>[
                                Row(
                                  children: _buildDateGridItems(str,
                                      str.entityId, str.name, str.closedOn),
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
                          borderRadius: BorderRadius.all(Radius.circular(5.0))),
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
                                message: whatsappMessage, phone: str.whatsapp);
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
                          borderRadius: BorderRadius.all(Radius.circular(5.0))),
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
                            launchURL(
                                str.name,
                                getFormattedAddress(str.address),
                                str.coordinates.geopoint.latitude,
                                str.coordinates.geopoint.longitude);
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
                          borderRadius: BorderRadius.all(Radius.circular(5.0))),
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
                            // shape: RoundedRectangleBorder(
                            //     side: BorderSide(
                            //         color: Colors.blueGrey[200]),
                            //     borderRadius: BorderRadius.all(
                            //         Radius.circular(2.0))),
                            onPressed: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => SearchChildrenPage(
                                          pageName: "Search",
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
      print("Check:${DateFormat('EEEE').format(date)}");
      daysClosed.forEach((element) {
        isClosed = (element.toLowerCase() ==
                DateFormat('EEEE').format(date).toLowerCase())
            ? true
            : false;
      });
      // isClosed =
      //     (daysClosed.contains(DateFormat('EEEE').format(date))) ? true : false;
      print(isClosed);
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
          (obj.entityId == sid && obj.number != -1)) {
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
                  Utils.showMyFlushbar(
                    context,
                    Icons.info,
                    Duration(seconds: 5),
                    "This premise is closed on this day.",
                    "Select a different date.",
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

  Future<void> showLocationAccessDialog() async {
    bool returnVal = await showDialog(
        barrierDismissible: false,
        context: context,
        builder: (_) => AlertDialog(
              titlePadding: EdgeInsets.fromLTRB(5, 10, 0, 0),
              contentPadding: EdgeInsets.all(0),
              actionsPadding: EdgeInsets.all(0),
              //buttonPadding: EdgeInsets.all(0),
              title: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    'To find nearby places we need access to your current location. Open settings and give permission to access your location.',
                    style: TextStyle(
                      fontSize: 15,
                      color: Colors.blueGrey[600],
                    ),
                  ),
                  verticalSpacer,
                  // myDivider,
                ],
              ),
              content: Divider(
                color: Colors.blueGrey[400],
                height: 1,
                //indent: 40,
                //endIndent: 30,
              ),

              //content: Text('This is my content'),
              actions: <Widget>[
                SizedBox(
                  height: 24,
                  child: RaisedButton(
                    elevation: 0,
                    color: Colors.transparent,
                    splashColor: highlightColor.withOpacity(.8),
                    textColor: Colors.orange,
                    shape: RoundedRectangleBorder(
                        side: BorderSide(color: Colors.orange)),
                    child: Text('Yes'),
                    onPressed: () {
                      Navigator.of(_).pop(true);
                    },
                  ),
                ),
                SizedBox(
                  height: 24,
                  child: RaisedButton(
                    elevation: 20,
                    autofocus: true,
                    focusColor: highlightColor,
                    splashColor: highlightColor,
                    color: Colors.white,
                    textColor: Colors.orange,
                    shape: RoundedRectangleBorder(
                        side: BorderSide(color: Colors.orange)),
                    child: Text('No'),
                    onPressed: () {
                      Navigator.of(_).pop(false);
                    },
                  ),
                ),
              ],
            ));

    if (returnVal) {
      print("in true, opening app settings");
      Utils.openAppSettings();
    } else {
      print("nothing to do, user denied location access");
      print(returnVal);
    }
  }

  Future<List<Entity>> getSearchEntitiesList() async {
    double lat = 0;
    double lon = 0;
    double radiusOfSearch = 10;
    int pageNumber = 0;
    int pageSize = 0;

    Position pos = await Utils.getCurrLocation();
    if (pos == null) {
      showLocationAccessDialog();
      return null;
    }

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
    getSearchEntitiesList().then((value) {
      if (value == null) {
        _stores.clear();
        setState(() {
          _isSearching = "done";
          messageTitle = "Oops.. Can't Search!!";
          messageSubTitle =
              "Open location settings and give permissions to access current location.";
        });
        return;
      }
      if (value.length == 0) {
        _stores.clear();
      } else {
        //Scrutinize the list returned froms server.
        //1. entities that are bookable, public and active only should be listed
        //2. Parent entities
        _stores.clear();
        for (int i = 0; i < value.length; i++) {
          if (value[i].isActive) _stores.add(value[i]);
        }
      }
      //Write Gstate to file
      _state.updateSearchResults(_stores);
      setState(() {
        //searchDone = true;
        _isSearching = "done";
      });
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
