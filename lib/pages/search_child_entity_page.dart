import 'package:auto_size_text/auto_size_text.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:enum_to_string/enum_to_string.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:intl/intl.dart';
import '../constants.dart';
import '../db/db_model/entity.dart';
import '../db/db_model/meta_entity.dart';
import '../db/db_model/user_token.dart';
import '../enum/entity_type.dart';
import '../events/event_bus.dart';
import '../events/events.dart';
import '../global_state.dart';
import '../pages/contact_us.dart';
import '../pages/favs_list_page.dart';
import '../pages/place_details_page.dart';
import '../pages/search_entity_page.dart';
import '../pages/show_slots_page.dart';
import '../services/circular_progress.dart';
import '../services/url_services.dart';
import '../style.dart';
import '../tuple.dart';
import '../utils.dart';
import '../widget/appbar.dart';
import '../widget/bottom_nav_bar.dart';
import '../widget/widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../userHomePage.dart';
import 'package:eventify/eventify.dart' as Eventify;

class SearchChildEntityPage extends StatefulWidget {
  final String pageName;
  final List<MetaEntity> childList;
  final String parentName;
  final String parentId;
  final EntityType parentType;
  SearchChildEntityPage(
      {Key key,
      this.pageName,
      this.childList,
      this.parentName,
      this.parentId,
      this.parentType})
      : super(key: key);
  @override
  _SearchChildEntityPageState createState() => _SearchChildEntityPageState();
}

class _SearchChildEntityPageState extends State<SearchChildEntityPage>
    with TickerProviderStateMixin {
  bool initCompleted = false;
  bool isFavourited = false;
  DateTime dateTime = DateTime.now();
  final dtFormat = new DateFormat('dd');
  SharedPreferences _prefs;
  GlobalState _globalState;
  List<Entity> _stores = new List<Entity>();
  //List<Entity> _pastSearches = new List<Entity>();
  List<Entity> _searchResultstores = new List<Entity>();
  String _entityType;
  String _searchInAll = 'Search in All';
  bool searchBoxClicked = false;
  bool fetchFromServer = false;
  PersistentBottomSheetController childBottomSheetController;
  PersistentBottomSheetController childContactUsSheetController;
  PersistentBottomSheetController childPlaceDetailsSheetController;

  bool showFab = true;
  String categoryType;
  // Map<String, String> categoryList = new Map<String, String>();
  double fontSize;
  var sideInfoGrp = new AutoSizeGroup();
  List<String> searchTypes = new List<String>();

  final compareDateFormat = new DateFormat('YYYYMMDD');
  List<DateTime> _dateList = new List<DateTime>();

  Icon actionIcon = new Icon(
    Icons.search,
    color: Colors.white,
  );
  final keyChildSearch = new GlobalKey<ScaffoldState>();
  TextEditingController _searchTextController;
  List<Entity> _list;
  //"initial, searching,done"
  String _isSearching = "initial";
  String _searchText = "";
  String searchType = "";
  String pageName;
  GlobalState _gs;
  bool stateInitFinished = false;
  String messageTitle;
  String messageSubTitle;
  String _dynamicLink;
  String title;
  String _fromPage;
  List<Entity> enList = new List<Entity>();
  ScrollController _selectCategoryBtnController;
  Widget _msgOnboard;
  AnimationController controller;
  Animation<Offset> offset;
  Eventify.Listener _eventListener;
  AnimationController _animationController;
  Animation animation;

  //List<String> searchTypes;

  @override
  void initState() {
    super.initState();
    _animationController = new AnimationController(
        vsync: this, duration: Duration(milliseconds: 1500));
    _animationController.repeat(reverse: true);
    animation = Tween(begin: 0.5, end: 1.0).animate(_animationController);

    _searchTextController = new TextEditingController();
    _isSearching = "initial";
    _fromPage = widget.pageName;

    title = "Places inside " + widget.parentName;
    getGlobalState().whenComplete(() {
      searchTypes = _gs.getConfigurations().entityTypes;
      getEntitiesList().whenComplete(() {
        if (this.mounted) {
          setState(() {
            initCompleted = true;
          });
        } else
          initCompleted = true;
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

  @override
  void dispose() {
    _animationController.dispose();
    _selectCategoryBtnController.dispose();
    EventBus.unregisterEvent(_eventListener);
    print("Search page dispose called...");
    super.dispose();
  }

  void showFoatingActionButton(bool value) {
    setState(() {
      showFab = value;
    });
  }

  Widget _buildCategoryItem(BuildContext context, EntityType type) {
    String name = Utils.getEntityTypeDisplayName(type);
    Widget image = Utils.getEntityTypeImage(type, 30);

    return GestureDetector(
        onTap: () {
          categoryType = name;
          if (childBottomSheetController != null) {
            childBottomSheetController.close();
            childBottomSheetController = null;
          }
          EventBus.fireEvent(
              SEARCH_CHILD_CATEGORY_SELECTED, null, categoryType);
        },
        child: Column(
          children: <Widget>[
            Container(
                padding: EdgeInsets.zero,
                margin: EdgeInsets.zero,
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

  Future<void> getEntitiesList() async {
    if (!Utils.isNullOrEmpty(widget.childList)) {
      for (int i = 0; i < widget.childList.length; i++) {
        Tuple<Entity, bool> value =
            await _gs.getEntity(widget.childList[i].entityId);
        if (value == null) {
          continue;
        }

        Entity entity = value.item1;

        if (value != null) {
          if (entity.isActive != null) if (entity.isActive) enList.add(entity);
        }
      }
    }
    setState(() {
      _stores.addAll(enList);
      // _pastSearches.addAll(enList);
    });
  }

  void registerCategorySelectEvent() {
    _eventListener = EventBus.registerEvent(
        SEARCH_CHILD_CATEGORY_SELECTED, null, (event, arg) {
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

  Future<void> getGlobalState() async {
    _gs = await GlobalState.getGlobalState();
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
    List<MetaEntity> favs = _gs.getCurrentUser().favourites;
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
      _gs.removeFavourite(en).then((value) => setState(() {}));
      setState(() {});
    } else {
      _gs.addFavourite(en).then((value) => setState(() {}));
      setState(() {});
    }

    print("toggle done");
  }

  generateLinkAndShareWithParams(String entityId, String name) async {
    String msgTitle = entityShareByUserHeading + name;
    String msgBody = entityShareByUserMessage;
    Utils.generateLinkAndShare(entityId, msgTitle, msgBody,
        _gs.getConfigurations().packageName, _gs.getConfigurations().iOSAppId);
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
              Column(
                children: <Widget>[
                  //  SizedBox(height: MediaQuery.of(context).size.height * .1),
                  Container(
                    height: MediaQuery.of(context).size.height * .2,
                    margin: EdgeInsets.symmetric(
                        vertical: MediaQuery.of(context).size.height * .1),
                    decoration: BoxDecoration(
                      image: DecorationImage(
                          image: AssetImage("assets/notFound.png"),
                          fit: BoxFit.contain),
                    ),
                  ),
                  Column(children: [
                    InkWell(
                      child: Container(
                        height: MediaQuery.of(context).size.height * .1,
                        decoration: BoxDecoration(
                          image: DecorationImage(
                              image: AssetImage("assets/notFound1.png"),
                              fit: BoxFit.contain),
                        ),
                      ),
                      onTap: () {
                        _searchTextController.text = "";
                        Utils.generateLinkAndShare(
                            null,
                            appShareWithOwnerHeading,
                            appShareWithOwnerMessage,
                            _gs.getConfigurations().packageName,
                            _gs.getConfigurations().iOSAppId);
                      },
                    ),
                    InkWell(
                      child: Container(
                        height: MediaQuery.of(context).size.height * .1,
                        decoration: BoxDecoration(
                          image: DecorationImage(
                              image: AssetImage("assets/notFound2.png"),
                              fit: BoxFit.contain),
                        ),
                      ),
                      onTap: () {
                        _searchTextController.text = "";

                        showContactUsSheet();
                      },
                    ),
                  ]),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  showPlaceDetailsSheet(Entity str) {
    childPlaceDetailsSheetController =
        keyChildSearch.currentState.showBottomSheet<Null>(
      (context) => Container(
        color: Colors.cyan[50],
        height: MediaQuery.of(context).size.height * .6,
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
                          childPlaceDetailsSheetController.close();
                          childPlaceDetailsSheetController = null;
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
                            fontSize: 18.0),
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
    childPlaceDetailsSheetController.closed.then((value) {
      showFoatingActionButton(true);
    });

    // });
  }

  showContactUsSheet() {
    childContactUsSheetController =
        keyChildSearch.currentState.showBottomSheet<Null>(
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
                          childContactUsSheetController.close();
                          childContactUsSheetController = null;
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
    childContactUsSheetController.closed.then((value) {
      showFoatingActionButton(true);
    });
  }

  Widget _listSearchResults() {
    if (_stores.length != 0) {
      //Add search results to past searches.
      // _state.setPastSearch(_stores, _searchText, _entityType);
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

    //}
  }

  @override
  Widget build(BuildContext context) {
    fontSize = MediaQuery.of(context).size.width * .045;
    print("Font size" + fontSize.toString());
// build widget only after init has completed, till then show progress indicator.
    if (!initCompleted) {
      return MaterialApp(
        debugShowCheckedModeBanner: false,
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
        margin: EdgeInsets.only(top: 8),
        decoration: new BoxDecoration(
          shape: BoxShape.rectangle,
          color: Colors.white,
          // color: Colors.white,
          borderRadius: BorderRadius.all(Radius.circular(5.0)),
          border: new Border.all(
            color: highlightColor,
            width: 1,
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
            (_fromPage != 'FavsSearch')
                ? searchInputText
                : Container(
                    height: 0,
                  ),
            //verticalSpacer,
            Container(
              padding: EdgeInsets.only(top: 8, bottom: 8),
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

      print("Came in isSearching");
      return MaterialApp(
        debugShowCheckedModeBanner: false,
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
                        print(_fromPage);
                        if (_fromPage == 'Search')
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => SearchEntityPage()));
                        else if (_fromPage == 'FavsSearch')
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => FavsListPage()));
                        else
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
                  (_isSearching == "done" || _isSearching == "initial")
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
              floatingActionButtonLocation:
                  FloatingActionButtonLocation.centerFloat,
              bottomNavigationBar: CustomBottomBar(barIndex: 1)

              // drawer: CustomDrawer(),
              ),
          onWillPop: willPopCallback,
        ),
      );
      //}
    }
  }

  showMyFloatingActionButton() {
    return showFab
        ? (_fromPage != 'FavsSearch')
            ? Container(
                width: MediaQuery.of(context).size.width * .92,
                height: MediaQuery.of(context).size.height * .07,
                padding: EdgeInsets.all(5),
                child: SlideTransition(
                  position: offset,
                  child: FloatingActionButton(
                    heroTag: "bottomSheetChildBtn",
                    elevation: 30,
                    backgroundColor: btnColor,
                    shape: RoundedRectangleBorder(
                        side: BorderSide(color: Colors.blueGrey[200]),
                        borderRadius: BorderRadius.all(Radius.circular(5.0))),
                    child: Container(
                      child: Text(
                        SEARCH_TYPE_OF_PLACE,
                        style: TextStyle(color: Colors.white, fontSize: 16),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    onPressed: () {
                      childBottomSheetController =
                          keyChildSearch.currentState.showBottomSheet<Null>(
                        (context) => Container(
                          color: Colors.cyan[50],
                          height: MediaQuery.of(context).size.height * .5,
                          child: Column(
                            children: <Widget>[
                              Container(
                                color: Colors.cyan[200],
                                child: Row(
                                  children: <Widget>[
                                    Container(
                                      padding: EdgeInsets.all(0),
                                      width: MediaQuery.of(context).size.width *
                                          .1,
                                      height:
                                          MediaQuery.of(context).size.width *
                                              .1,
                                      child: IconButton(
                                          padding: EdgeInsets.all(0),
                                          icon: Icon(
                                            Icons.cancel,
                                            color: headerBarColor,
                                          ),
                                          onPressed: () {
                                            childBottomSheetController.close();
                                            childBottomSheetController = null;
                                            //Navigator.of(context).pop();
                                          }),
                                    ),
                                    Container(
                                        alignment: Alignment.center,
                                        width:
                                            MediaQuery.of(context).size.width *
                                                .8,
                                        child: Text(
                                          SEARCH_TYPE_OF_PLACE,
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
                                  padding: EdgeInsets.all(0),
                                  child: new GridView.builder(
                                    padding: EdgeInsets.all(0),
                                    scrollDirection: Axis.vertical,
                                    shrinkWrap: true,
                                    itemCount: _gs
                                        .getActiveChildEntityTypes(
                                            widget.parentType)
                                        .length,
                                    gridDelegate:
                                        SliverGridDelegateWithFixedCrossAxisCount(
                                            crossAxisCount: 4,
                                            crossAxisSpacing: 10.0,
                                            mainAxisSpacing: 10),
                                    itemBuilder:
                                        (BuildContext context, int index) {
                                      return new GridTile(
                                        child: Container(
                                          height: MediaQuery.of(context)
                                                  .size
                                                  .height *
                                              .25,
                                          padding: EdgeInsets.all(0),
                                          // decoration:
                                          //     BoxDecoration(border: Border.all(color: Colors.black, width: 0.5)),
                                          child: Center(
                                            child: _buildCategoryItem(
                                                context,
                                                _gs.getActiveChildEntityTypes(
                                                    widget.parentType)[index]),
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
            : Container()
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
    } else if (childContactUsSheetController != null) {
      childContactUsSheetController.close();
      childContactUsSheetController = null;
      return false;
    } else if (childPlaceDetailsSheetController != null) {
      childPlaceDetailsSheetController.close();
      childPlaceDetailsSheetController = null;
      return false;
    } else {
      //Navigator.of(context).pop();
      Navigator.push(
          context, MaterialPageRoute(builder: (context) => SearchEntityPage()));
      return false;
    }
  }

  Widget _buildItem(Entity str) {
    _prepareDateList();
    print('after buildDateGrid called');
    return Card(
      margin: EdgeInsets.fromLTRB(8, 0, 8, 12),
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
                  child: Utils.getEntityTypeImage(str.type, 30)),
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
                            width: MediaQuery.of(context).size.width * .78,
                            padding: EdgeInsets.all(0),
                            margin: EdgeInsets.zero,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                                        MediaQuery.of(context).size.width * .7,
                                    child: AutoSizeText(
                                      (str.name) ?? str.name.toString(),
                                      style: TextStyle(
                                          fontSize: fontSize * .045,
                                          color: btnColor),
                                      maxLines: 1,
                                      minFontSize: 18,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ),
                                (str.allowOnlineAppointment != null)
                                    ? (str.allowOnlineAppointment
                                        ? FadeTransition(
                                            opacity: animation,
                                            child: GestureDetector(
                                              onTap: () {
                                                Utils.showMyFlushbar(
                                                    context,
                                                    Icons.info,
                                                    Duration(seconds: 5),
                                                    "This place provides Online Consultation on WhatsApp number ${str.whatsapp} !!",
                                                    "Help in reducing crowd at places.");
                                              },
                                              child: Container(
                                                padding: EdgeInsets.zero,
                                                margin: EdgeInsets.zero,
                                                width: MediaQuery.of(context)
                                                        .size
                                                        .width *
                                                    .08,
                                                height: MediaQuery.of(context)
                                                        .size
                                                        .height *
                                                    .04,
                                                child: Icon(
                                                  Icons.videocam,
                                                  color: Colors.orange[700],
                                                  size: 30,
                                                ),
                                              ),
                                            ),
                                          )
                                        : Container(width: 0))
                                    : Container(width: 0),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      width: MediaQuery.of(context).size.width * .78,
                      padding: EdgeInsets.zero,
                      margin: EdgeInsets.zero,
                      child: Column(
                        // direction: Axis.horizontal,
                        children: [
                          Container(
                            padding: EdgeInsets.all(0),
                            margin: EdgeInsets.zero,
                            //width: MediaQuery.of(context).size.width * .3,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Container(
                                  width:
                                      MediaQuery.of(context).size.width * .46,
                                  child: Text(
                                    Utils.isNotNullOrEmpty(
                                            EnumToString.convertToString(
                                                str.type))
                                        ? Utils.getEntityTypeDisplayName(
                                            str.type)
                                        : "",
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                        color: Colors.black,
                                        letterSpacing: 0.5,
                                        fontFamily: 'Roboto',
                                        fontSize: 12.0),
                                  ),
                                ),
                                Container(
                                  width:
                                      MediaQuery.of(context).size.width * .12,
                                  child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        (str.verificationStatus ==
                                                VERIFICATION_VERIFIED)
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
                                                  padding: EdgeInsets.fromLTRB(
                                                      1, 1, 0, 2),
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
                                                width: MediaQuery.of(context)
                                                        .size
                                                        .width *
                                                    .06,
                                                height: MediaQuery.of(context)
                                                        .size
                                                        .height *
                                                    .03,
                                                child: IconButton(
                                                  padding: EdgeInsets.fromLTRB(
                                                      1, 1, 1, 2),
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
                                      ]),
                                ),
                                if (str.startTimeHour != null)
                                  Container(
                                    width:
                                        MediaQuery.of(context).size.width * .2,
                                    padding: EdgeInsets.all(0),
                                    margin: EdgeInsets.all(0),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: <Widget>[
                                        SizedBox(
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              .09,
                                          child: AutoSizeText(
                                              Utils.formatTime(str.startTimeHour
                                                      .toString()) +
                                                  ':' +
                                                  Utils.formatTime(str
                                                      .startTimeMinute
                                                      .toString()),
                                              group: sideInfoGrp,
                                              minFontSize: 8,
                                              maxFontSize: 11,
                                              style: TextStyle(
                                                color: Colors.green[600],
                                                fontFamily: 'Monsterrat',
                                              )),
                                        ),
                                        Text('~',
                                            style: TextStyle(
                                                color: Colors.black,
                                                fontSize: 8)),
                                        SizedBox(
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              .09,
                                          child: AutoSizeText(
                                              Utils.formatTime(str.endTimeHour
                                                      .toString()) +
                                                  ':' +
                                                  Utils.formatTime(str
                                                      .endTimeMinute
                                                      .toString()),
                                              group: sideInfoGrp,
                                              textAlign: TextAlign.right,
                                              minFontSize: 8,
                                              maxFontSize: 11,
                                              style: TextStyle(
                                                color: Colors.red[900],
                                                fontFamily: 'Monsterrat',
                                              )),
                                        ),
                                      ],
                                    ),
                                  ),
                                if (str.startTimeHour == null)
                                  Container(
                                    width:
                                        MediaQuery.of(context).size.width * .18,
                                    child: Text(""),
                                  ),
                              ],
                            ),
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
                              "Could not connect to the WhatsApp number ${str.whatsapp} !!",
                              "Try again later");
                        }
                      } else {
                        Utils.showMyFlushbar(
                            context,
                            Icons.info,
                            Duration(seconds: 5),
                            "WhatsApp contact information not found!!",
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
                    onPressed: () => toggleFavorite(str),
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
                    if (str.getMetaEntity().hasChildren)
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
                    if (str.childEntities?.length == 0)
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
    print(_fromPage);
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => ShowSlotsPage(
                  metaEntity: store.getMetaEntity(),
                  dateTime: dateTime,
                  forPage: "ChildSearch",
                )));

    print('After showDialog:');
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

    if (_gs.bookings != null) {
      for (Tuple<UserToken, DocumentSnapshot> obj in (_gs.bookings)) {
        if ((compareDateFormat.format(dt).compareTo(
                    compareDateFormat.format(obj.item1.parent.dateTime)) ==
                0) &&
            (obj.item1.parent.entityId == sid && obj.item1.number != -1)) {
          dateBooked = true;
        }
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
                    : (dateBooked ? Colors.greenAccent[700] : Colors.cyan[50])),

            /// button color
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

  List<Widget> showSearchResults() {
    return _stores.map(_buildItem).toList();
  }

  // Future<void> showLocationAccessDialog() async {
  //   print("SHOW Dialog called");
  //   bool returnVal = await showDialog(
  //       barrierDismissible: false,
  //       context: context,
  //       builder: (_) => AlertDialog(
  //             titlePadding: EdgeInsets.fromLTRB(5, 10, 0, 0),
  //             contentPadding: EdgeInsets.all(0),
  //             actionsPadding: EdgeInsets.all(0),
  //             //buttonPadding: EdgeInsets.all(0),
  //             title: Column(
  //               crossAxisAlignment: CrossAxisAlignment.start,
  //               children: <Widget>[
  //                 Text(
  //                   locationPermissionMsg,
  //                   style: TextStyle(
  //                     fontSize: 15,
  //                     color: Colors.blueGrey[600],
  //                   ),
  //                 ),
  //                 verticalSpacer,
  //                 // myDivider,
  //               ],
  //             ),
  //             content: Divider(
  //               color: Colors.blueGrey[400],
  //               height: 1,
  //               //indent: 40,
  //               //endIndent: 30,
  //             ),

  //             //content: Text('This is my content'),
  //             actions: <Widget>[
  //               SizedBox(
  //                 height: 24,
  //                 child: RaisedButton(
  //                   elevation: 5,
  //                   focusColor: highlightColor,
  //                   splashColor: highlightColor,
  //                   color: Colors.white,
  //                   textColor: Colors.orange,
  //                   shape: RoundedRectangleBorder(
  //                       side: BorderSide(color: Colors.orange)),
  //                   child: Text('No'),
  //                   onPressed: () {
  //                     Navigator.of(_).pop(false);
  //                   },
  //                 ),
  //               ),
  //               SizedBox(
  //                 height: 24,
  //                 child: RaisedButton(
  //                   elevation: 10,
  //                   color: btnColor,
  //                   splashColor: highlightColor.withOpacity(.8),
  //                   textColor: Colors.white,
  //                   shape: RoundedRectangleBorder(
  //                       side: BorderSide(color: Colors.orange)),
  //                   child: Text('Yes'),
  //                   onPressed: () {
  //                     Navigator.of(_).pop(true);
  //                   },
  //                 ),
  //               ),
  //             ],
  //           ));

  //   if (returnVal) {
  //     print("in true, opening app settings");
  //     Utils.openAppSettings();
  //   } else {
  //     print("nothing to do, user denied location access");
  //     Utils.showMyFlushbar(context, Icons.info, Duration(seconds: 3),
  //         locationAccessDeniedStr, locationAccessDeniedSubStr);
  //     print(returnVal);
  //   }
  // }

  // Future<List<Entity>> getSearchEntitiesList() async {
  //   double lat = 0;
  //   double lon = 0;
  //   int pageNumber = 0;
  //   int pageSize = 0;

  //   Position pos;
  //   try {
  //     pos = await Utils.getCurrLocation();
  //   } catch (e) {
  //     showLocationAccessDialog();
  //   }
  //   if (pos == null) {
  //     throw new Exception("UserLocationOff");
  //   }
  //   lat = pos.latitude;
  //   lon = pos.longitude;
  //   //TODO: comment - only for testing
  //   //lat = 12.960632;
  //   //lon = 77.641603;

  //   //TODO: comment - only for testing
  //   String entityTypeForSearch;
  //   entityTypeForSearch = (_entityType == _searchInAll) ? null : _entityType;

  //   List<Entity> searchEntityList = await EntityService().search(
  //       _searchText.toLowerCase(),
  //       entityTypeForSearch,
  //       lat,
  //       lon,
  //       _state.getConfigurations().searchRadius,
  //       pageNumber,
  //       pageSize);

  //   return searchEntityList;
  // }

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
    } else {
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
          if (Utils.getEntityTypeDisplayName(en.type) == _entityType) {
            searchList.add(en);
          }
        }
      }
      if (searchList.length == 0) {
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
                      Utils.generateLinkAndShare(
                          null,
                          appShareWithOwnerHeading,
                          appShareWithOwnerMessage,
                          _gs.getConfigurations().packageName,
                          _gs.getConfigurations().iOSAppId);
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

Route _createRoute(dynamic route) {
  return PageRouteBuilder(
    pageBuilder: (context, animation, secondaryAnimation) => route,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      var begin = Offset(1.0, 0.0);
      var end = Offset.zero;
      var curve = Curves.ease;

      var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));

      return SlideTransition(
        position: animation.drive(tween),
        child: child,
      );
    },
  );
}
