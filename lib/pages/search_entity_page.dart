import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';
import 'package:noq/constants.dart';
import 'package:noq/db/db_model/address.dart';
import 'package:noq/db/db_model/entity.dart';
import 'package:noq/db/db_model/meta_entity.dart';
import 'package:noq/db/db_model/user_token.dart';
import 'package:noq/db/db_service/entity_service.dart';
import 'package:noq/events/event_bus.dart';
import 'package:noq/events/events.dart';
import 'package:noq/global_state.dart';
import 'package:noq/pages/contact_us.dart';
import 'package:noq/pages/search_child_entity_page.dart';
import 'package:noq/pages/show_slots_page.dart';
import 'package:noq/services/circular_progress.dart';
import 'package:noq/services/url_services.dart';
import 'package:noq/style.dart';
import 'package:noq/utils.dart';
import 'package:noq/widget/appbar.dart';
import 'package:noq/widget/bottom_nav_bar.dart';
import 'package:noq/widget/widgets.dart';
import 'package:share/share.dart';

import '../userHomePage.dart';
import 'package:eventify/eventify.dart' as Eventify;
import 'package:auto_size_text/auto_size_text.dart';

class SearchEntityPage extends StatefulWidget {
  //final String forPage;

  //SearchStoresPage({Key key, @required this.forPage}) : super(key: key);
  @override
  _SearchEntityPageState createState() => _SearchEntityPageState();
}

class _SearchEntityPageState extends State<SearchEntityPage>
    with SingleTickerProviderStateMixin {
  bool initCompleted = false;
  bool isFavourited = false;
  DateTime dateTime = DateTime.now();
  final dtFormat = new DateFormat('dd');
  List<Entity> _stores = new List<Entity>();
  List<Entity> _pastSearches = new List<Entity>();
  String _entityType;
  String _searchInAll = 'Search in All';
  bool searchBoxClicked = false;
  bool fetchFromServer = false;
  PersistentBottomSheetController bottomSheetController;
  PersistentBottomSheetController contactUsSheetController;
  PersistentBottomSheetController placeDetailsSheetController;
  bool showFab = true;
  String categoryType;
  Widget _msgOnboard;
  List<String> searchTypes = new List<String>();
  final compareDateFormat = new DateFormat('YYYYMMDD');
  List<DateTime> _dateList = new List<DateTime>();

  Icon actionIcon = new Icon(
    Icons.search,
    color: Colors.white,
  );
  final key = new GlobalKey<ScaffoldState>();
  TextEditingController _searchTextController;

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
  Eventify.Listener _eventListener;
  ScrollController _selectCategoryBtnController;
  AnimationController controller;
  Animation<Offset> offset;
  double fontSize;
  bool isLoading = false;
  Widget _buildCategoryItem(BuildContext context, int index) {
    String name = searchTypes[index];
    Widget image = Utils.getEntityTypeImage(name, 30);

    return GestureDetector(
        onTap: () {
          categoryType = name;
          bottomSheetController.close();
          bottomSheetController = null;
          //   Navigator.of(context).pop();
          EventBus.fireEvent(SEARCH_CATEGORY_SELECTED, null, categoryType);
        },
        child: Column(
          children: <Widget>[
            Container(
                padding: EdgeInsets.all(0),
                width: MediaQuery.of(context).size.width * .15,
                height: MediaQuery.of(context).size.width * .15,
                child: image),
            Text(
              name,
              textAlign: TextAlign.center,
              style: textBotSheetTextStyle,
            ),
          ],
        ));
  }

  //List<String> searchTypes;
  void showFoatingActionButton(bool value) {
    setState(() {
      showFab = value;
    });
  }

  @override
  void dispose() {
    super.dispose();
    _searchTextController.dispose();
    EventBus.unregisterEvent(_eventListener);
    _selectCategoryBtnController.dispose();
    print("Search page dispose called...");
  }

  @override
  void initState() {
    super.initState();

    _searchTextController = new TextEditingController();
    _isSearching = "initial";
    getGlobalState().whenComplete(() {
      fetchPastSearchesList();
      searchTypes = _state.conf.entityTypes;
      if (this.mounted) {
        setState(() {
          initCompleted = true;
        });
      } else
        initCompleted = true;
    });

    registerCategorySelectEvent();

    controller =
        AnimationController(vsync: this, duration: Duration(milliseconds: 600));

    offset = Tween<Offset>(begin: Offset.zero, end: Offset(0.0, 10.0))
        .animate(controller);

    _selectCategoryBtnController = new ScrollController();
    _selectCategoryBtnController.addListener(() {
      if (_selectCategoryBtnController.position.userScrollDirection ==
          ScrollDirection.reverse) {
        if (_selectCategoryBtnController.position.atEdge) {
          print(_selectCategoryBtnController.position.pixels);
          if (_selectCategoryBtnController.position.pixels != 0) {
            print("ITS AT LAST POSITIUON");
            setState(() {
              controller.forward();
            });
          }
        }
      } else {
        if (_selectCategoryBtnController.position.userScrollDirection ==
            ScrollDirection.forward) {
          print("ITS Going up");
          setState(() {
            controller.reverse();
          });
        }
      }
    });
  }

  void registerCategorySelectEvent() {
    _eventListener =
        EventBus.registerEvent(SEARCH_CATEGORY_SELECTED, null, (event, arg) {
      if (event == null) {
        return;
      }
      String categoryType = event.eventData;
      setState(() {
        _entityType = categoryType;
        _isSearching = "searching";
        print("came in ");
        _buildSearchList();
      });
    });
  }

  void fetchPastSearchesList() {
    //Load details from local files

    if (!Utils.isNullOrEmpty(_state.lastSearchResults)) {
      setState(() {
        _stores = _state.lastSearchResults;
        _searchText = _state.lastSearchName;
        _searchTextController.text = _searchText;
        _entityType = _state.lastSearchType;
        _isSearching = "done";
        //  _stores = _pastSearches;
      });
    } else
      messageTitle = "No previous searches!!";
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
    List<MetaEntity> favs = _state.getCurrentUser().favourites;
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
      _state.removeFavourite(en).then((value) => setState(() {}));
      setState(() {});
    } else {
      _state.addFavourite(en).then((value) => setState(() {}));
      setState(() {});
    }

    print("toggle done");
  }

  Future<void> generateLinkAndShareWithParams(
      String entityId, String entityName) async {
    // var dynamicLink = await Utils.createDynamicLinkWithParams(entityId,
    //     entityShareByUserHeading + entityName, entityShareByUserMessage);
    // print("Dynamic Link: $dynamicLink");

    // _dynamicLink =
    //     Uri.https(dynamicLink.authority, dynamicLink.path).toString();
    // // dynamicLink has been generated. share it with others to use it accordingly.
    // Share.share(entityShareByUserMessage + "\n" + _dynamicLink.toString(),
    //     subject: entityShareByUserHeading + entityName);

    String appShareHeading = entityShareByUserHeading + entityName;
    String appShareMessage = entityShareByUserMessage;
    Utils.generateLinkAndShare(entityId, appShareHeading, appShareMessage);
  }

  Widget _emptySearchPage() {
    return Center(
      child: Container(
        height: MediaQuery.of(context).size.height * .6,
        alignment: Alignment.topCenter,
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              if (messageTitle == "NotFound")
                Column(
                  children: <Widget>[
                    SizedBox(height: MediaQuery.of(context).size.height * .1),
                    Container(
                      height: MediaQuery.of(context).size.height * .2,
                      decoration: BoxDecoration(
                        image: DecorationImage(
                            image: AssetImage("assets/notFound.png"),
                            fit: BoxFit.cover),
                      ),
                    ),
                    verticalSpacer,
                    verticalSpacer,
                    InkWell(
                      child: Container(
                        height: MediaQuery.of(context).size.height * .1,
                        decoration: BoxDecoration(
                          image: DecorationImage(
                              image: AssetImage("assets/notFound1.png"),
                              fit: BoxFit.cover),
                        ),
                      ),
                      onTap: () {
                        _searchTextController.text = "";
                        Utils.generateLinkAndShare(null,
                            appShareWithOwnerHeading, appShareWithOwnerMessage);
                      },
                    ),
                    InkWell(
                      child: Container(
                        height: MediaQuery.of(context).size.height * .1,
                        decoration: BoxDecoration(
                          image: DecorationImage(
                              image: AssetImage("assets/notFound2.png"),
                              fit: BoxFit.cover),
                        ),
                      ),
                      onTap: () {
                        _searchTextController.text = "";

                        showContactUsSheet();
                      },
                    ),
                  ],
                ),
              if (messageTitle != "NotFound")
                Column(children: <Widget>[
                  SizedBox(height: MediaQuery.of(context).size.height * .02),
                  Container(
                      color: Colors.transparent,
                      child: Image(
                        image: AssetImage('assets/search_home.png'),
                      )),
                ]),
            ],
          ),
        ),
      ),
    );
  }

  showPlaceDetailsSheet(Entity str) {
    placeDetailsSheetController = key.currentState.showBottomSheet<Null>(
      (context) => Container(
        color: Colors.cyan[50],
        height: MediaQuery.of(context).size.height * .87,
        child: Column(
          children: <Widget>[
            Container(
              color: Colors.cyan[200],
              child: Row(
                children: <Widget>[
                  Container(
                    padding: EdgeInsets.all(0),
                    width: MediaQuery.of(context).size.width * .1,
                    height: MediaQuery.of(context).size.width * .1,
                    child: IconButton(
                        padding: EdgeInsets.all(0),
                        icon: Icon(
                          Icons.cancel,
                          color: headerBarColor,
                        ),
                        onPressed: () {
                          placeDetailsSheetController.close();
                          placeDetailsSheetController = null;
                          // Navigator.of(context).pop();
                        }),
                  ),
                  Container(
                      alignment: Alignment.center,
                      width: MediaQuery.of(context).size.width * .8,
                      child: Text(
                        str.name,
                        style: TextStyle(
                            color: Colors.blueGrey[800],
                            fontFamily: 'RalewayRegular',
                            fontSize: 19.0),
                      )),
                ],
              ),
            ),
            Divider(
              height: 1,
              color: primaryDarkColor,
            ),
            Expanded(
              child: PlaceDetailsPage(entity: str),
            ),
          ],
        ),
      ),
      elevation: 30,
      clipBehavior: Clip.hardEdge,
      shape: RoundedRectangleBorder(
          side: BorderSide(color: Colors.blueGrey[200]),
          borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20.0), topRight: Radius.circular(20.0))),
    );
    showFoatingActionButton(false);
    placeDetailsSheetController.closed.then((value) {
      showFoatingActionButton(true);
    });

    print(isLoading);
    // });
  }

  showContactUsSheet() {
    contactUsSheetController = key.currentState.showBottomSheet<Null>(
      (context) => Container(
        color: Colors.cyan[50],
        height: MediaQuery.of(context).size.height * .87,
        child: Column(
          children: <Widget>[
            Container(
              color: Colors.cyan[200],
              child: Row(
                children: <Widget>[
                  Container(
                    padding: EdgeInsets.all(0),
                    width: MediaQuery.of(context).size.width * .1,
                    height: MediaQuery.of(context).size.width * .1,
                    child: IconButton(
                        padding: EdgeInsets.all(0),
                        icon: Icon(
                          Icons.cancel,
                          color: headerBarColor,
                        ),
                        onPressed: () {
                          contactUsSheetController.close();
                          contactUsSheetController = null;
                          // Navigator.of(context).pop();
                        }),
                  ),
                  Container(
                      alignment: Alignment.center,
                      width: MediaQuery.of(context).size.width * .8,
                      child: Text(
                        "Contact Us",
                        style: TextStyle(
                            color: Colors.blueGrey[800],
                            fontFamily: 'RalewayRegular',
                            fontSize: 19.0),
                      )),
                ],
              ),
            ),
            Divider(
              height: 1,
              color: primaryDarkColor,
            ),
            Expanded(
              child: ContactUsPage(showAppBar: false),
            ),
          ],
        ),
      ),
      elevation: 30,
      clipBehavior: Clip.hardEdge,
      shape: RoundedRectangleBorder(
          side: BorderSide(color: Colors.blueGrey[200]),
          borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20.0), topRight: Radius.circular(20.0))),
    );
    showFoatingActionButton(false);
    contactUsSheetController.closed.then((value) {
      showFoatingActionButton(true);
    });
  }

  Widget _listSearchResults() {
    if (_stores.length != 0) {
      //Add search results to past searches.
      _state.setPastSearch(_stores, _searchText, _entityType);
      // _state.pastSearches = _stores;
      return Center(
        child: Column(
          children: <Widget>[
            Expanded(
              child: ListView.builder(
                  controller: _selectCategoryBtnController,
                  itemCount: 1,
                  itemBuilder: (BuildContext context, int index) {
                    return Container(
                      margin: EdgeInsets.fromLTRB(
                          10, 0, 10, MediaQuery.of(context).size.height * .15),
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
  }

  @override
  Widget build(BuildContext context) {
    fontSize = MediaQuery.of(context).size.width;
    print("Font size" + fontSize.toString());
// build widget only after init has completed, till then show progress indicator.
    if (!initCompleted) {
      return MaterialApp(
        theme: ThemeData.light().copyWith(),
        home: new WillPopScope(
          child: Scaffold(
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
          onWillPop: willPopCallback,
        ),
      );
    } else {
      // Widget categoryDropDown = Container(
      //     width: MediaQuery.of(context).size.width * .48,
      //     height: MediaQuery.of(context).size.width * .1,
      //     decoration: new BoxDecoration(
      //       shape: BoxShape.rectangle,
      //       color: Colors.white,
      //       // color: Colors.white,
      //       borderRadius: BorderRadius.all(Radius.circular(5.0)),
      //       border: new Border.all(
      //         color: Colors.blueGrey[400],
      //         width: 0.5,
      //       ),
      //     ),
      //     child: DropdownButtonHideUnderline(
      //         child: ButtonTheme(
      //       alignedDropdown: true,
      //       child: new DropdownButton(
      //         iconEnabledColor: Colors.blueGrey[500],
      //         dropdownColor: Colors.white,
      //         itemHeight: kMinInteractiveDimension,
      //         hint: new Text("Select a category"),
      //         style: TextStyle(fontSize: 12, color: Colors.blueGrey[500]),
      //         value: _entityType,
      //         isDense: true,
      //         // icon: Icon(Icons.search),
      //         onChanged: (newValue) {
      //           setState(() {
      //             print('entity type - old value');
      //             print(_entityType);
      //             _entityType = newValue;
      //             print('entity type - new value - $_entityType');
      //             _isSearching = "searching";
      //             _buildSearchList();
      //           });
      //         },
      //         items: searchTypes.map((type) {
      //           return DropdownMenuItem(
      //             value: type,
      //             child: new Text(type.toString(),
      //                 style:
      //                     TextStyle(fontSize: 12, color: Colors.blueGrey[500])),
      //           );
      //         }).toList(),
      //       ),
      //     )));

      Widget searchInputText = Container(
        width: MediaQuery.of(context).size.width * .95,
        height: MediaQuery.of(context).size.width * .12,
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
          //autofocus: true,
          controller: _searchTextController,
          cursorColor: Colors.blueGrey[500],
          cursorWidth: 1,
          textAlignVertical: TextAlignVertical.center,
          style: new TextStyle(fontSize: 15, color: Colors.blueGrey[700]),
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
                    //Clear search text and build new search results
                    searchBoxClicked = false;
                    _searchTextController.clear();
                    _searchText = "";
                    setState(() {
                      messageTitle = "";
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
              hintText: "Search by Name of Business/Place",
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
                  messageTitle = "";
                  _isSearching = "searching";
                  _searchText = _searchTextController.text;
                  _buildSearchList();
                });
              }
            }
          },
        ),
      );
      Widget searchResultText = Container(
        width: MediaQuery.of(context).size.width * .85,
        //height: MediaQuery.of(context).size.height * .03,
        padding: EdgeInsets.all(0),
        child: RichText(
            overflow: TextOverflow.visible,
            maxLines: 2,
            text: TextSpan(
                style: TextStyle(color: Colors.blueGrey, fontSize: 12),
                children: <TextSpan>[
                  Utils.isNotNullOrEmpty(_entityType) ||
                          Utils.isNotNullOrEmpty(_searchText)
                      ? TextSpan(text: searchResultText1)
                      : TextSpan(text: ""),
                  Utils.isNotNullOrEmpty(_entityType)
                      ? TextSpan(
                          text: searchResultText2,
                        )
                      : TextSpan(text: ""),
                  Utils.isNotNullOrEmpty(_entityType)
                      ? TextSpan(
                          text: _entityType,
                          style: TextStyle(color: highlightColor, fontSize: 12))
                      : TextSpan(text: ""),
                  Utils.isNotNullOrEmpty(_entityType)
                      ? TextSpan(
                          text: searchResultText3,
                        )
                      : TextSpan(text: ""),
                  Utils.isNotNullOrEmpty(_searchText)
                      ? (Utils.isNotNullOrEmpty(_entityType))
                          ? TextSpan(text: SYMBOL_AND + searchResultText4)
                          : TextSpan(
                              text: searchResultText4,
                            )
                      : TextSpan(text: ""),
                  Utils.isNotNullOrEmpty(_searchText)
                      ? TextSpan(
                          text: _searchText,
                          style: TextStyle(color: highlightColor, fontSize: 12))
                      : TextSpan(text: ""),
                ])),
      );
      Widget filterBar = Container(
        margin: EdgeInsets.fromLTRB(0, 5, 0, 0),
        //  padding: EdgeInsets.fromLTRB(5, 0, 5, 0),
        //decoration: gradientBackground,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: <Widget>[
            // categoryDropDown,
            searchInputText,
            verticalSpacer,
            Container(
              width: MediaQuery.of(context).size.width * .95,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  (Utils.isNotNullOrEmpty(_searchText) ||
                          Utils.isNotNullOrEmpty(_entityType))
                      ? searchResultText
                      : Container(),
                  (Utils.isNotNullOrEmpty(_searchText) ||
                          Utils.isNotNullOrEmpty(_entityType))
                      ? Container(
                          //  alignment: Alignment.topCenter,
                          width: MediaQuery.of(context).size.width * .09,
                          //height: MediaQuery.of(context).size.height * .05,
                          child: InkWell(
                            child: Text(
                              "Clear",
                              style: errorTextStyleWithUnderLine,
                            ),
                            onTap: () {
                              setState(() {
                                _searchTextController.clear();
                                messageTitle = "";
                                _isSearching = "searching";
                                _searchText = "";
                                _entityType = null;
                                _buildSearchList();
                              });
                            },
                          ),
                        )
                      : Container(),
                ],
              ),
            ),
          ],
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
            '/childSearch': (BuildContext context) => SearchChildEntityPage(),
            '/mainSearch': (BuildContext context) => SearchEntityPage(),
          },
          theme: ThemeData.light().copyWith(),
          home: new WillPopScope(
            child: Scaffold(
                key: key,
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
                                controller: _selectCategoryBtnController,
                                itemCount: 1,
                                itemBuilder: (BuildContext context, int index) {
                                  return Container(
                                    margin: EdgeInsets.fromLTRB(10, 0, 10, 50),
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
                floatingActionButton: showMyFloatingActionButton(),
                floatingActionButtonLocation:
                    FloatingActionButtonLocation.centerFloat,
                bottomNavigationBar: CustomBottomBar(barIndex: 1)

                // drawer: CustomDrawer(),
                ),
            onWillPop: willPopCallback,
          ),
        );
      else {
        print("Came in isSearching");
        return MaterialApp(
          routes: <String, WidgetBuilder>{
            '/childSearch': (BuildContext context) => SearchChildEntityPage(),
            '/mainSearch': (BuildContext context) => SearchEntityPage(),
          },
          theme: ThemeData.light().copyWith(),
          home: new WillPopScope(
            child: Scaffold(
                key: key,
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
                body: Stack(
                  children: <Widget>[
                    Column(
                      children: <Widget>[
                        filterBar,
                        (_isSearching == "done")
                            ? ((_stores.length == 0)
                                ? _emptySearchPage()
                                : Expanded(child: _listSearchResults()))
                            //Else could be one when isSearching is 'searching', show circular progress.
                            : Center(
                                child: Container(
                                  height:
                                      MediaQuery.of(context).size.height * .35,
                                  alignment: Alignment.bottomCenter,
                                  child: SingleChildScrollView(
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      mainAxisSize: MainAxisSize.min,
                                      children: <Widget>[
                                        showCircularProgress(),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                      ],
                    ),
                    // isLoading
                    //     ? Container(
                    //         color: Colors.black.withOpacity(0.5),
                    //         child: Center(
                    //           child: CircularProgressIndicator(),
                    //         ),
                    //       )
                    //     : Container()
                  ],
                ),
                // drawer: CustomDrawer(),
                floatingActionButton: showMyFloatingActionButton(),
                floatingActionButtonLocation:
                    FloatingActionButtonLocation.centerFloat,
                bottomNavigationBar: CustomBottomBar(barIndex: 1)

                // drawer: CustomDrawer(),
                ),
            onWillPop: willPopCallback,
          ),
        );
      }
    }
  }

  Widget showMyFloatingActionButton() {
    return showFab
        ? Container(
            width: MediaQuery.of(context).size.width * .8,
            height: MediaQuery.of(context).size.height * .08,
            padding: EdgeInsets.all(5),
            child: SlideTransition(
              position: offset,
              child: FloatingActionButton(
                heroTag: "bottomSheetBtn",
                elevation: 30,
                backgroundColor: btnColor,
                shape: RoundedRectangleBorder(
                    side: BorderSide(color: Colors.blueGrey[200]),
                    borderRadius: BorderRadius.all(Radius.circular(45.0))),
                child: Container(
                  child: Text(
                    SELECT_TYPE_OF_PLACE,
                    style: TextStyle(color: Colors.white, fontSize: 16),
                    textAlign: TextAlign.center,
                  ),
                ),
                onPressed: () {
                  bottomSheetController =
                      key.currentState.showBottomSheet<Null>(
                    (context) => Container(
                      color: Colors.cyan[50],
                      height: MediaQuery.of(context).size.height * .7,
                      child: Column(
                        children: <Widget>[
                          Container(
                            color: Colors.cyan[200],
                            child: Row(
                              children: <Widget>[
                                Container(
                                  padding: EdgeInsets.all(0),
                                  width: MediaQuery.of(context).size.width * .1,
                                  height:
                                      MediaQuery.of(context).size.width * .1,
                                  child: IconButton(
                                      padding: EdgeInsets.all(0),
                                      icon: Icon(
                                        Icons.cancel,
                                        color: headerBarColor,
                                      ),
                                      onPressed: () {
                                        bottomSheetController.close();
                                        bottomSheetController = null;
                                        // Navigator.of(context).pop();
                                      }),
                                ),
                                Container(
                                    alignment: Alignment.center,
                                    width:
                                        MediaQuery.of(context).size.width * .8,
                                    child: Text(
                                      SELECT_TYPE_OF_PLACE,
                                      style: TextStyle(
                                          color: Colors.blueGrey[800],
                                          fontFamily: 'RalewayRegular',
                                          fontSize: 19.0),
                                    )),
                              ],
                            ),
                          ),
                          Divider(
                            height: 1,
                            color: primaryDarkColor,
                          ),
                          Expanded(
                            child: Container(
                              color: Colors.cyan[50],
                              padding: EdgeInsets.all(0),
                              child: new GridView.builder(
                                padding: EdgeInsets.all(0),
                                scrollDirection: Axis.vertical,
                                shrinkWrap: true,
                                itemCount: searchTypes.length,
                                gridDelegate:
                                    SliverGridDelegateWithFixedCrossAxisCount(
                                        crossAxisCount: 4,
                                        crossAxisSpacing: 10.0,
                                        mainAxisSpacing: 10),
                                itemBuilder: (BuildContext context, int index) {
                                  return new GridTile(
                                    child: Container(
                                      height:
                                          MediaQuery.of(context).size.height *
                                              .25,
                                      padding: EdgeInsets.all(0),
                                      // decoration:
                                      //     BoxDecoration(border: Border.all(color: Colors.black, width: 0.5)),
                                      child: Center(
                                        child:
                                            _buildCategoryItem(context, index),
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    elevation: 30,
                    clipBehavior: Clip.hardEdge,
                    shape: RoundedRectangleBorder(
                        side: BorderSide(color: Colors.blueGrey[200]),
                        borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(20.0),
                            topRight: Radius.circular(20.0))),
                  );
                  showFoatingActionButton(false);
                  bottomSheetController.closed.then((value) {
                    showFoatingActionButton(true);
                  });
                },
              ),
            ),
          )
        : Container();
  }

  Future<bool> willPopCallback() async {
    if (bottomSheetController != null) {
      bottomSheetController.close();
      bottomSheetController = null;
      return false;
    } else if (contactUsSheetController != null) {
      contactUsSheetController.close();
      contactUsSheetController = null;
      return false;
    } else if (placeDetailsSheetController != null) {
      placeDetailsSheetController.close();
      placeDetailsSheetController = null;
      return false;
    } else {
      //Navigator.of(context).pop();
      Navigator.push(
          context, MaterialPageRoute(builder: (context) => UserHomePage()));
      return false;
    }
  }

  Widget entityImageIcon(String type) {
    // String imgName;
    Widget imgWidget;
    //  imgName = Utils.getEntityTypeImage(type);

    imgWidget = Utils.getEntityTypeImage(type, 30);

    return imgWidget;
  }

  Widget _buildItem(Entity str) {
    _prepareDateList();

    //_buildDateGridItems(str.id);
    print('after buildDateGrid called');
    return Card(
      margin: EdgeInsets.fromLTRB(8, 12, 8, 0),
      elevation: 10,
      child: Column(
        children: <Widget>[
          new Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            // mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Container(
                  padding: EdgeInsets.zero,
                  margin: EdgeInsets.zero,
                  alignment: Alignment.center,
                  height: MediaQuery.of(context).size.width * .09,
                  width: MediaQuery.of(context).size.width * .09,
                  child: entityImageIcon(str.type)),
              Container(
                width: MediaQuery.of(context).size.width * .8,
                padding: EdgeInsets.all(2),
                margin: EdgeInsets.zero,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Container(
                      width: MediaQuery.of(context).size.width * .78,
                      padding: EdgeInsets.zero,
                      margin: EdgeInsets.zero,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Container(
                            width: MediaQuery.of(context).size.width * .6,
                            padding: EdgeInsets.all(0),
                            margin: EdgeInsets.zero,
                            child: Row(
                              // mainAxisAlignment: Mai1nAxisAlignment.spaceBetween,
                              // crossAxisAlignment: CrossAxisAlignment.center,
                              children: <Widget>[
                                GestureDetector(
                                  onTap: () {
                                    print("Container clicked");
                                    showPlaceDetailsSheet(str);
                                    // Navigator.push(
                                    //     context,
                                    //     MaterialPageRoute(
                                    //         builder: (context) =>
                                    //             PlaceDetailsPage()));
                                    // showDialogForPlaceDetails(
                                    //     null, str, context);
                                  },
                                  child: Container(
                                    padding: EdgeInsets.zero,
                                    width:
                                        MediaQuery.of(context).size.width * .46,
                                    child: AutoSizeText(
                                      (str.name) ?? str.name.toString(),
                                      style: TextStyle(
                                          fontSize: fontSize * .045,
                                          color: btnColor),
                                      maxLines: 1,
                                      minFontSize: 14,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ),
                                (str.verificationStatus ==
                                        VERIFICATION_VERIFIED)
                                    ? new Container(
                                        width:
                                            MediaQuery.of(context).size.width *
                                                .06,
                                        height:
                                            MediaQuery.of(context).size.height *
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
                                                VERIFICATION_VERIFIED,
                                                "");
                                          },
                                        ),
                                      )
                                    : Container(),
                                (str.isPublic != true)
                                    ? Container(
                                        width:
                                            MediaQuery.of(context).size.width *
                                                .06,
                                        height:
                                            MediaQuery.of(context).size.height *
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
                          if (str.startTimeHour != null)
                            Container(
                              width: MediaQuery.of(context).size.width * .18,
                              padding: EdgeInsets.all(0),
                              margin: EdgeInsets.all(0),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.end,
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
                                          fontSize: fontSize * .022)),
                                  Text(' - ',
                                      style: TextStyle(
                                          color: primaryDarkColor,
                                          fontSize: fontSize * .022)),
                                  Text(
                                      Utils.formatTime(
                                              str.endTimeHour.toString()) +
                                          ':' +
                                          Utils.formatTime(
                                              str.endTimeMinute.toString()),
                                      style: TextStyle(
                                          color: Colors.red[900],
                                          fontFamily: 'Monsterrat',
                                          fontSize: fontSize * .022)),
                                ],
                              ),
                            ),
                          if (str.startTimeHour == null)
                            Container(
                              width: MediaQuery.of(context).size.width * .18,
                              child: Text(""),
                            ),
                        ],
                      ),
                    ),
                    Container(
                      width: MediaQuery.of(context).size.width * .78,
                      padding: EdgeInsets.zero,
                      margin: EdgeInsets.zero,
                      child: Row(
                        children: [
                          Container(
                            padding: EdgeInsets.only(top: 3),
                            margin: EdgeInsets.zero,
                            width: MediaQuery.of(context).size.width * .65,
                            child: AutoSizeText(
                              (Utils.getFormattedAddress(str.address) != "")
                                  ? Utils.getFormattedAddress(str.address)
                                  : "No Address found",
                              maxLines: 1,
                              minFontSize: 12,
                              overflow: TextOverflow.ellipsis,
                              style: labelXSmlTextStyle,
                            ),
                          ),
                          Container(
                              padding: EdgeInsets.only(top: 3),
                              width: MediaQuery.of(context).size.width * .13,
                              child: Text(
                                (str.distance != null)
                                    ? str.distance.toStringAsFixed(1) + ' Km'
                                    : "",
                                textAlign: TextAlign.right,
                                style: TextStyle(
                                  color: btnColor,
                                  fontFamily: 'Monsterrat',
                                  fontSize: 10.0,
                                ),
                              )),
                        ],
                      ),
                    ),
                    SizedBox(height: 5),
                    if (str.isBookable != null && str.isActive != null)
                      if (str.isBookable && str.isActive)
                        Container(
                            width: MediaQuery.of(context).size.width * .78,
                            //padding: EdgeInsets.fromLTRB(0, 5, 5, 5),
                            child: Row(
                              children: _buildDateGridItems(str, str.entityId,
                                  str.name, str.closedOn, str.advanceDays),
                            )),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 3),
          if (Utils.isNotNullOrEmpty(str.offer?.message))
            Container(
              padding: EdgeInsets.all(0),
              margin: EdgeInsets.zero,
              width: MediaQuery.of(context).size.width * .89,
              child: Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(0),
                    width: MediaQuery.of(context).size.width * .05,
                    child: Image.asset(
                      'assets/offers_icon.png',
                    ),
                    //  color: Colors.amber,
                  ),
                  Container(
                      padding: EdgeInsets.only(left: 3),
                      width: MediaQuery.of(context).size.width * .82,
                      child: Text(
                        str.offer.message,
                        maxLines: 1,
                        //  minFontSize: 12,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: Colors.blueGrey[900],
                        ),
                      )),
                ],
              ),
            ),
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
                          borderRadius: BorderRadius.all(Radius.circular(5.0))),
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
                            Utils.showMyFlushbar(context, Icons.error,
                                Duration(seconds: 5), locationNotFound, "");
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
                          borderRadius: BorderRadius.all(Radius.circular(5.0))),
                      color: Colors.white,
                      splashColor: highlightColor,
                      child: Icon(
                        Icons.share,
                        color: primaryDarkColor,
                        size: 25,
                      ),
                      onPressed: () {
                        generateLinkAndShareWithParams(str.entityId, str.name);
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
                    onPressed: () {
                      toggleFavorite(str);
                    },
                    highlightColor: Colors.orange[300],
                    child: isFavourite(str.getMetaEntity())
                        ? Icon(Icons.favorite, color: Colors.red[800], size: 25)
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
                                    builder: (context) => SearchChildEntityPage(
                                        pageName: "ChildSearch",
                                        childList: str.childEntities,
                                        parentName: str.name)));
                          },
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              Container(
                                padding: EdgeInsets.fromLTRB(0, 0, 0, 0),
                                transform: Matrix4.translationValues(8.0, 0, 0),
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
    );
  }

  void showSlots(Entity store, DateTime dateTime) {
    //_prefs = await SharedPreferences.getInstance();

    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => ShowSlotsPage(
                  entity: store.getMetaEntity(),
                  dateTime: dateTime,
                  forPage: 'MainSearch',
                )));

    print('After showDialog:');
    // });
  }

  List<Widget> _buildDateGridItems(Entity store, String sid, String sname,
      List<String> daysClosed, int advanceDays) {
    bool isClosed = false;
    bool isBookingAllowed = false;
    String dayOfWeek;
    int daysCounter = 0;
    var dateWidgets = List<Widget>();
    for (var date in _dateList) {
      daysCounter++;
      if (daysCounter <= advanceDays) {
        isBookingAllowed = true;
      } else
        isBookingAllowed = false;

      for (String str in daysClosed) {
        if (str.toLowerCase() ==
            DateFormat('EEEE').format(date).toLowerCase()) {
          isClosed = true;
          break;
        } else {
          isClosed = false;
        }
      }
      // daysClosed.forEach((element) {
      //   isClosed = (element.toLowerCase() ==
      //           DateFormat('EEEE').format(date).toLowerCase())
      //       ? true
      //       : false;
      // });

      dayOfWeek = Utils.getDayOfWeek(date);
      dateWidgets.add(buildDateItem(store, sid, sname, isClosed,
          isBookingAllowed, advanceDays, date, dayOfWeek));
    }
    return dateWidgets;
  }

  Widget buildDateItem(Entity store, String sid, String sname, bool isClosed,
      bool isBookingAllowed, int advanceDays, DateTime dt, String dayOfWeek) {
    bool dateBooked = false;

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
                ? Colors.grey[300]
                : (!isBookingAllowed
                    ? Colors.grey[300]
                    : (dateBooked
                        ? Colors.greenAccent[700]
                        : Colors.cyan[50])), // button color
            child: InkWell(
              splashColor: (isClosed || !isBookingAllowed)
                  ? null
                  : highlightColor, // splash color
              onTap: () {
                if (isClosed) {
                  Utils.showMyFlushbar(
                    context,
                    Icons.info,
                    Duration(seconds: 5),
                    "This Place is closed on this day.",
                    "Select a different day.",
                  );
                } else if (!isBookingAllowed) {
                  Utils.showMyFlushbar(
                    context,
                    Icons.info,
                    Duration(seconds: 5),
                    "This place only allows advance booking for upto $advanceDays days.",
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
                          fontWeight: FontWeight.bold,
                          color: (isClosed
                              ? Colors.grey[500]
                              : (!isBookingAllowed
                                  ? Colors.grey[500]
                                  : (dateBooked
                                      ? Colors.white
                                      : primaryDarkColor))))),
                  Text(dayOfWeek,
                      style: TextStyle(
                          fontSize: 8,
                          fontWeight: FontWeight.bold,
                          color: (isClosed
                              ? Colors.grey[500]
                              : (!isBookingAllowed
                                  ? Colors.grey[500]
                                  : (dateBooked
                                      ? Colors.white
                                      : primaryDarkColor))))), // text
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
    print("SHOW Dialog called");
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
                    locationPermissionMsg,
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
                    elevation: 5,
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
                SizedBox(
                  height: 24,
                  child: RaisedButton(
                    elevation: 10,
                    color: btnColor,
                    splashColor: highlightColor.withOpacity(.8),
                    textColor: Colors.white,
                    shape: RoundedRectangleBorder(
                        side: BorderSide(color: Colors.orange)),
                    child: Text('Yes'),
                    onPressed: () {
                      Navigator.of(_).pop(true);
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
      Utils.showMyFlushbar(context, Icons.info, Duration(seconds: 3),
          locationAccessDeniedStr, locationAccessDeniedSubStr);
      print(returnVal);
    }
  }

  Future<List<Entity>> getSearchEntitiesList() async {
    double lat = 0;
    double lon = 0;
    int pageNumber = 0;
    int pageSize = 0;

    Position pos;
    try {
      pos = await Utils.getCurrLocation();
    } catch (e) {
      showLocationAccessDialog();
    }
    if (pos == null) {
      throw new Exception("UserLocationOff");
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
        _state.conf.searchRadius,
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
      //Case 1 - Cant search as location not accessible
      if (value == null) {
        _stores.clear();
        setState(() {
          _isSearching = "done";
          messageTitle = cantSearch;
          messageSubTitle = giveLocationPermission;
        });
        return;
      }
      //Case 2 - Zero matching search results.
      if (value.length == 0) {
        if (Utils.isNotNullOrEmpty(_entityType) ||
            Utils.isNotNullOrEmpty(_searchText)) {
          setState(() {
            messageTitle = "NotFound";

            // messageSubTitle = notFoundMsg;
            _msgOnboard = RichText(
                text: TextSpan(
                    style: TextStyle(color: Colors.blueGrey, fontSize: 15),
                    children: <TextSpan>[
                  TextSpan(text: notFoundMsg1, style: TextStyle(fontSize: 18)),
                  TextSpan(
                    text: notFoundMsg4,
                    style: TextStyle(color: Colors.blue),
                    recognizer: new TapGestureRecognizer()
                      ..onTap = () {
                        _searchTextController.text = "";
                        Utils.generateLinkAndShare(null,
                            appShareWithOwnerHeading, appShareWithOwnerMessage);
                      },
                  ),
                  TextSpan(text: notFoundMsg5),
                  TextSpan(text: notFoundMsg3),
                  TextSpan(
                      text: notFoundMsg2,
                      style: TextStyle(color: Colors.blue),
                      recognizer: new TapGestureRecognizer()
                        ..onTap = () {
                          _searchTextController.text = "";
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => ContactUsPage(
                                        showAppBar: false,
                                      )));
                        }),
                ]));
          });
        } else {
          setState(() {
            messageTitle = "";
            messageSubTitle = "";
          });
        }
        _stores.clear();
      } else {
        //Case 3- Show search results.

        _stores.clear();
        //Scrutinize the list returned froms server.
        //1. entities that are bookable, public and active only should be listed
        //2. Parent entities
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
    }).catchError((ex) {
      if (ex.message.toString().contains("UserLocationOff")) {
        _stores.clear();
        setState(() {
          _isSearching = "done";
          messageTitle = "Can't Search!!";
          messageSubTitle = giveLocationPermission;
        });
      }
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
}

class PlaceDetailsPage extends StatefulWidget {
  final Entity entity;
  PlaceDetailsPage({Key key, @required this.entity}) : super(key: key);
  @override
  _PlaceDetailsPageState createState() => _PlaceDetailsPageState();
}

class _PlaceDetailsPageState extends State<PlaceDetailsPage> {
  Entity entity;
  @override
  Widget build(BuildContext context) {
    entity = widget.entity;
    return Container(
        padding: EdgeInsets.all(10),
        height: MediaQuery.of(context).size.height * .7,
        width: MediaQuery.of(context).size.width,
        child: Column(
          children: [
            Card(
              child: Container(
                  height: MediaQuery.of(context).size.height * .08,
                  width: MediaQuery.of(context).size.width,
                  alignment: Alignment.center,
                  child: (Text("Description"))),
            ),
            Card(
              child: Container(
                  height: MediaQuery.of(context).size.height * .08,
                  width: MediaQuery.of(context).size.width,
                  alignment: Alignment.center,
                  child: (Text("Safety Practises we follow"))),
            ),
            Card(
              child: Container(
                  height: MediaQuery.of(context).size.height * .08,
                  width: MediaQuery.of(context).size.width,
                  alignment: Alignment.center,
                  child: (Text("Timings , Map"))),
            ),
            Card(
              child: Container(
                  height: MediaQuery.of(context).size.height * .08,
                  width: MediaQuery.of(context).size.width,
                  alignment: Alignment.center,
                  child: (Text("Offers"))),
            ),
            Card(
              child: Container(
                  height: MediaQuery.of(context).size.height * .08,
                  width: MediaQuery.of(context).size.width,
                  alignment: Alignment.center,
                  child: (Text("Contact details"))),
            ),
          ],
        ));
  }
}
