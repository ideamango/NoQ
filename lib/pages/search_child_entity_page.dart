import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';
import 'package:noq/constants.dart';
import 'package:noq/db/db_model/entity.dart';
import 'package:noq/db/db_model/meta_entity.dart';
import 'package:noq/db/db_model/user_token.dart';
import 'package:noq/db/db_service/entity_service.dart';
import 'package:noq/events/event_bus.dart';
import 'package:noq/events/events.dart';
import 'package:noq/global_state.dart';
import 'package:noq/pages/search_entity_page.dart';
import 'package:noq/pages/show_slots_page.dart';
import 'package:noq/repository/StoreRepository.dart';
import 'package:noq/services/circular_progress.dart';
import 'package:noq/services/url_services.dart';
import 'package:noq/style.dart';
import 'package:noq/utils.dart';
import 'package:noq/widget/appbar.dart';
import 'package:noq/widget/bottom_nav_bar.dart';
import 'package:noq/widget/widgets.dart';
import 'package:share/share.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../userHomePage.dart';
import 'package:eventify/eventify.dart' as Eventify;

class SearchChildEntityPage extends StatefulWidget {
  final String pageName;
  final List<MetaEntity> childList;
  final String parentName;
  final String parentId;
  SearchChildEntityPage(
      {Key key, this.pageName, this.childList, this.parentName, this.parentId})
      : super(key: key);
  @override
  _SearchChildEntityPageState createState() => _SearchChildEntityPageState();
}

class _SearchChildEntityPageState extends State<SearchChildEntityPage>
    with SingleTickerProviderStateMixin {
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
  PersistentBottomSheetController childBottomSheetController;
  bool showFab = true;
  String categoryType;
  // Map<String, String> categoryList = new Map<String, String>();

  List<String> searchTypes = new List<String>();
  // @override
  // void initState() {
  //   super.initState();
  //   GlobalState.getGlobalState().then((value) {
  //     searchTypes = value.conf.entityTypes;
  //     buildCategoryList();
  //   });
  // }

  Widget _buildCategoryItem(BuildContext context, int index) {
    String name = searchTypes[index];
    Widget image = Utils.getEntityTypeImage(name, 30);

    return GestureDetector(
        onTap: () {
          categoryType = name;
          childBottomSheetController.close();
          childBottomSheetController = null;
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

  // bool searchDone = false;

  final compareDateFormat = new DateFormat('YYYYMMDD');
  List<DateTime> _dateList = new List<DateTime>();

  Icon actionIcon = new Icon(
    Icons.search,
    color: Colors.white,
  );
  final keyChildSearch = new GlobalKey<ScaffoldState>();
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
  String title;
  String _fromPage;
  List<Entity> enList = new List<Entity>();
  ScrollController _selectCategoryBtnController;

  AnimationController controller;
  Animation<Offset> offset;
  Eventify.Listener eventListener;

  //List<String> searchTypes;
  void showFoatingActionButton(bool value) {
    setState(() {
      showFab = value;
    });
  }

  @override
  void dispose() {
    super.dispose();
    _selectCategoryBtnController.dispose();
    EventBus.unregisterEvent(eventListener);
    print("Search page dispose called...");
  }

  @override
  void initState() {
    super.initState();
    _isSearching = "initial";
    _fromPage = widget.pageName;
    _isSearching = "initial";

    title = "Places inside " + widget.parentName;
    getGlobalState().whenComplete(() {
      searchTypes = _state.conf.entityTypes;
      getEntitiesList().whenComplete(() {
        setState(() {
          initCompleted = true;
        });
      });

      registerCategorySelectEvent();

      controller = AnimationController(
          vsync: this, duration: Duration(milliseconds: 600));

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
    });
  }

  Future<void> getEntitiesList() async {
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

  void registerCategorySelectEvent() {
    eventListener =
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

    if (!Utils.isNullOrEmpty(_state.pastSearches)) {
      setState(() {
        _pastSearches = _state.pastSearches;
      });
    } else if (_state.pastSearches != null && _state.pastSearches.length == 0)
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
    Share.share(dynamicLink.toString());
  }

  Widget _emptySearchPage() {
    String txtMsg = (Utils.isNotNullOrEmpty(messageTitle)
        ? messageTitle
        : defaultSearchMsg);
    String txtSubMsg = (Utils.isNotNullOrEmpty(messageSubTitle)
        ? messageSubTitle
        : defaultSearchSubMsg);
    return Center(
      child: Container(
        // height: MediaQuery.of(context).size.height * .35,
        alignment: Alignment.bottomCenter,
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              // SizedBox(
              //   height: MediaQuery.of(context).size.height * .25,
              // ),
              if (messageTitle == "NotFound")
                Column(
                  children: <Widget>[
                    SizedBox(height: MediaQuery.of(context).size.height * .1),
                    Container(
                      height: MediaQuery.of(context).size.height * .4,
                      decoration: BoxDecoration(
                        image: DecorationImage(
                            image: AssetImage("assets/notFound.png"),
                            fit: BoxFit.cover),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.all(5),
                      child: Text(
                        txtSubMsg,
                        style: TextStyle(
                          color: primaryDarkColor,
                          fontFamily: 'Montserrat',
                          fontSize: 18,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
              if (messageTitle != "NotFound")
                Column(children: <Widget>[
                  SizedBox(height: MediaQuery.of(context).size.height * .32),
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
                ]),
            ],
          ),
        ),
      ),
    );
  }

  Widget _listSearchResults() {
    if (_stores.length != 0) {
      //Add search results to past searches.
      _state.pastSearches = _stores;
      return Center(
        child: Column(
          children: <Widget>[
            Expanded(
              child: ListView.builder(
                  controller: _selectCategoryBtnController,
                  itemCount: 1,
                  itemBuilder: (BuildContext context, int index) {
                    return Container(
                      margin: EdgeInsets.fromLTRB(10, 10, 10, 25),
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
                    //TODO: correct search end
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
        padding: EdgeInsets.all(0),
        child: RichText(
            overflow: TextOverflow.visible,
            maxLines: 2,
            text: TextSpan(
                style: TextStyle(color: Colors.grey, fontSize: 12),
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
                          // alignment: Alignment.topCenter,
                          width: MediaQuery.of(context).size.width * .09,
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

      print(_searchText);
      print(_entityType);
      if (_isSearching == "initial" &&
          _searchText.isEmpty &&
          _entityType == null)
        return MaterialApp(
          routes: <String, WidgetBuilder>{
            '/childSearch': (BuildContext context) => SearchChildEntityPage(),
            '/mainSearch': (BuildContext context) => SearchChildEntityPage(),
          },
          theme: ThemeData.light().copyWith(),
          home: new WillPopScope(
            child: Scaffold(
                key: keyChildSearch,
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
                                  builder: (context) => SearchEntityPage()));
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
                                    margin: EdgeInsets.fromLTRB(10, 0, 10, 25),
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
            '/mainSearch': (BuildContext context) => SearchChildEntityPage(),
          },
          theme: ThemeData.light().copyWith(),
          home: new WillPopScope(
            child: Scaffold(
                key: keyChildSearch,
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
                    (_isSearching == "done")
                        ? ((_stores.length == 0)
                            ? _emptySearchPage()
                            : Expanded(child: _listSearchResults()))
                        //Else could be one when isSearching is 'searching', show circular progress.
                        : Center(
                            child: Container(
                              height: MediaQuery.of(context).size.height * .35,
                              alignment: Alignment.bottomCenter,
                              child: SingleChildScrollView(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
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
                // drawer: CustomDrawer(),
                floatingActionButton: showMyFloatingActionButton(),
                bottomNavigationBar: CustomBottomBar(barIndex: 1)

                // drawer: CustomDrawer(),
                ),
            onWillPop: willPopCallback,
          ),
        );
      }
    }
  }

  showMyFloatingActionButton() {
    return showFab
        ? Container(
            width: MediaQuery.of(context).size.width * .4,
            height: MediaQuery.of(context).size.height * .08,
            padding: EdgeInsets.all(5),
            child: SlideTransition(
              position: offset,
              child: FloatingActionButton(
                heroTag: "bottomSheetChildBtn",
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
                  childBottomSheetController =
                      keyChildSearch.currentState.showBottomSheet<Null>(
                    (context) => Container(
                      color: Colors.cyan[50],
                      height: MediaQuery.of(context).size.height * .7,
                      child: Column(
                        children: <Widget>[
                          Row(
                            children: <Widget>[
                              Container(
                                padding: EdgeInsets.all(0),
                                width: MediaQuery.of(context).size.width * .1,
                                height: MediaQuery.of(context).size.width * .1,
                                child: IconButton(
                                    padding: EdgeInsets.all(0),
                                    icon: Icon(
                                      Icons.cancel,
                                      color: btnDisabledolor,
                                    ),
                                    onPressed: () {
                                      childBottomSheetController.close();
                                      childBottomSheetController = null;
                                      //Navigator.of(context).pop();
                                    }),
                              ),
                              Container(
                                  alignment: Alignment.center,
                                  width: MediaQuery.of(context).size.width * .8,
                                  child: Text(
                                    SELECT_TYPE_OF_PLACE,
                                    style: textInputTextStyle,
                                  )),
                            ],
                          ),
                          Divider(
                            height: 1,
                            color: primaryDarkColor,
                          ),
                          Expanded(
                            child: Container(
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
                  childBottomSheetController.closed.then((value) {
                    showFoatingActionButton(true);
                  });
                },
              ),
            ),
          )
        : Container();
  }

  Future<bool> willPopCallback() async {
    //  Utils.showMyFlushbar(
    //    context, Icons.info, Duration(seconds: 3), "dsfvsfg", "");
    // ignore: unnecessary_statements
    if (childBottomSheetController != null) {
      childBottomSheetController.close();
      childBottomSheetController = null;
      return false;
    } else {
      //Navigator.of(context).pop();
      Navigator.push(
          context, MaterialPageRoute(builder: (context) => SearchEntityPage()));
      return false;
    }
  }

  Widget entityImageIcon(String type) {
    Widget imgWidget;
    imgWidget = Utils.getEntityTypeImage(type, 20);
    return imgWidget;
  }

  Widget _buildItem(Entity str) {
    _prepareDateList();

    //_buildDateGridItems(str.id);
    print('after buildDateGrid called');
    return GestureDetector(
      onTap: () {},
      child: Card(
        margin: EdgeInsets.only(top: 12),
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
                        height: MediaQuery.of(context).size.width * .095,
                        width: MediaQuery.of(context).size.width * .095,
                        margin: EdgeInsets.fromLTRB(
                            MediaQuery.of(context).size.width * .01,
                            MediaQuery.of(context).size.width * .01,
                            MediaQuery.of(context).size.width * .005,
                            MediaQuery.of(context).size.width * .005),
                        padding: EdgeInsets.all(
                            MediaQuery.of(context).size.width * .02),
                        alignment: Alignment.topCenter,
                        decoration: ShapeDecoration(
                          shape: CircleBorder(),
                          color: primaryIcon,
                        ),
                        child: Container(
                          alignment: Alignment.center,
                          height: MediaQuery.of(context).size.width * .04,
                          width: MediaQuery.of(context).size.width * .04,
                          child: entityImageIcon(str.type),
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
                            onPressed: () {},
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
                ? disabledColor
                : (!isBookingAllowed
                    ? disabledColor
                    : (dateBooked
                        ? primaryAccentColor
                        : primaryDarkColor)), // button color
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
                          color: (isClosed
                              ? Colors.red
                              : (!isBookingAllowed
                                  ? Colors.grey[500]
                                  : Colors.white)))),
                  Text(dayOfWeek,
                      style: TextStyle(
                          fontSize: 8,
                          color: (isClosed
                              ? Colors.red
                              : (!isBookingAllowed
                                  ? Colors.grey[500]
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
    List<Entity> searchList = new List<Entity>();
    if ((!Utils.isNotNullOrEmpty(_entityType) &&
        !Utils.isNotNullOrEmpty(_searchText))) {
      _stores.clear();
      _stores.addAll(enList);
      setState(() {
        _isSearching = "done";
      });
      return;
    }
    for (int i = 0; i < enList.length; i++) {
      Entity en = enList.elementAt(i);

      if ((Utils.isNotNullOrEmpty(_entityType) &&
          Utils.isNotNullOrEmpty(_searchText))) {
        if (en.type == _entityType &&
            en.name.toLowerCase().contains(_searchText.toLowerCase())) {
          searchList.add(en);
        }
      } else if ((!Utils.isNotNullOrEmpty(_entityType) &&
          Utils.isNotNullOrEmpty(_searchText))) {
        if (en.name.toLowerCase().contains(_searchText.toLowerCase())) {
          searchList.add(en);
        }
      } else if ((Utils.isNotNullOrEmpty(_entityType) &&
          !Utils.isNotNullOrEmpty(_searchText))) {
        if (en.type == _entityType) {
          searchList.add(en);
        }
      }
    }

    _stores.clear();
    _stores.addAll(searchList);

    //Write Gstate to file
    //_state.updateSearchResults(_stores);
    setState(() {
      _isSearching = "done";
    });
  }
}

// class MyFloatingActionButton extends StatefulWidget {
//   @override
//   _MyFloatingActionButtonState createState() => _MyFloatingActionButtonState();
// }

// class _MyFloatingActionButtonState extends State<MyFloatingActionButton> {
//   bool showFab = true;
//   String categoryType;
//   Map<String, String> categoryList = new Map<String, String>();

//   List<String> searchTypes = new List<String>();
//   @override
//   void initState() {
//     super.initState();
//     GlobalState.getGlobalState().then((value) {
//       searchTypes = value.conf.entityTypes;
//       buildCategoryList();
//     });
//   }

//   void buildCategoryList() {
//     categoryList["Mall"] = "mall.png";
//     categoryList["Super Market"] = "superMarket.png";
//     categoryList["Apartment"] = "apartment.png";
//     categoryList["Medical Store"] = "medicalStore.png";
//     categoryList["Shop"] = "shop.png";
//     categoryList["Pop Shop"] = "popShop.png";
//     categoryList["Salon"] = "salon.png";
//     categoryList["School"] = "school.png";
//     categoryList["Place of Worship"] = "placeOfWorship.png";
//     categoryList["Restaurant"] = "restaurant.png";
//     categoryList["Sports Center"] = "sportsCenter.png";
//     categoryList["Gym"] = "gym.png";
//     categoryList["Office"] = "office.png";
//     categoryList["Others"] = "others.png";
//   }

//   Widget _buildCategoryItem(BuildContext context, int index) {
//     String name = searchTypes[index];
//     String value = categoryList[name];
//     print("Image path assets/$value");

//     return GestureDetector(
//         onTap: () {
//           categoryType = name;
//           Navigator.of(context).pop();
//           EventBus.fireEvent(SEARCH_CATEGORY_SELECTED, null, categoryType);
//         },
//         child: Column(
//           children: <Widget>[
//             Image(
//               width: MediaQuery.of(context).size.width * .15,
//               image: AssetImage("assets/$value"),
//             ),
//             Text(
//               name,
//               style: textBotSheetTextStyle,
//             ),
//           ],
//         ));
//   }

//   @override
//   Widget build(BuildContext context) {
//     return showFab
//         ? Container(
//             width: MediaQuery.of(context).size.width * .4,
//             height: MediaQuery.of(context).size.height * .1,
//             padding: EdgeInsets.all(5),
//             child: FloatingActionButton(
//               elevation: 30,
//               backgroundColor: btnColor,
//               shape: RoundedRectangleBorder(
//                   side: BorderSide(color: Colors.blueGrey[200]),
//                   borderRadius: BorderRadius.all(Radius.circular(45.0))),
//               child: Container(
//                 child: Text(
//                   "Choose Category",
//                   style: TextStyle(color: Colors.white, fontSize: 16),
//                   textAlign: TextAlign.center,
//                 ),
//               ),
//               onPressed: () {
//                 var bottomSheetController = showBottomSheet(
//                   context: context,
//                   elevation: 30,
//                   shape: RoundedRectangleBorder(
//                       side: BorderSide(color: Colors.blueGrey[200]),
//                       borderRadius: BorderRadius.only(
//                           topLeft: Radius.circular(20.0),
//                           topRight: Radius.circular(20.0))),
//                   builder: (context) => Container(
//                     color: Colors.transparent,
//                     height: MediaQuery.of(context).size.height * .6,
//                     child: Column(
//                       children: <Widget>[
//                         Row(
//                           children: <Widget>[
//                             Container(
//                               padding: EdgeInsets.all(0),
//                               width: MediaQuery.of(context).size.width * .1,
//                               height: MediaQuery.of(context).size.width * .1,
//                               child: IconButton(
//                                   padding: EdgeInsets.all(0),
//                                   icon: Icon(
//                                     Icons.cancel,
//                                     color: btnDisabledolor,
//                                   ),
//                                   onPressed: () {
//                                     Navigator.of(context).pop();
//                                   }),
//                             ),
//                             Container(
//                                 alignment: Alignment.center,
//                                 width: MediaQuery.of(context).size.width * .8,
//                                 child: Text(
//                                   "Select Category",
//                                   style: textInputTextStyle,
//                                 )),
//                           ],
//                         ),
//                         Divider(
//                           height: 1,
//                           color: primaryDarkColor,
//                         ),
//                         Expanded(
//                           child: Container(
//                             padding: EdgeInsets.all(0),
//                             child: new GridView.builder(
//                               padding: EdgeInsets.all(0),
//                               scrollDirection: Axis.vertical,
//                               shrinkWrap: true,
//                               itemCount: categoryList.length,
//                               gridDelegate:
//                                   SliverGridDelegateWithFixedCrossAxisCount(
//                                       crossAxisCount: 4,
//                                       crossAxisSpacing: 10.0,
//                                       mainAxisSpacing: 10),
//                               itemBuilder: (BuildContext context, int index) {
//                                 return new GridTile(
//                                   child: Container(
//                                     height: MediaQuery.of(context).size.height *
//                                         .25,
//                                     padding: EdgeInsets.all(0),
//                                     // decoration:
//                                     //     BoxDecoration(border: Border.all(color: Colors.black, width: 0.5)),
//                                     child: Center(
//                                       child: _buildCategoryItem(context, index),
//                                     ),
//                                   ),
//                                 );
//                               },
//                             ),
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                 );
//                 showFoatingActionButton(false);
//                 bottomSheetController.closed.then((value) {
//                   showFoatingActionButton(true);
//                 });
//               },
//             ),
//           )
//         : Container();
//   }

//   void showFoatingActionButton(bool value) {
//     setState(() {
//       showFab = value;
//     });
//   }
// }
