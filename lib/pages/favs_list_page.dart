import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
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
import 'package:noq/repository/local_db_repository.dart';
import 'package:noq/repository/slotRepository.dart';
import 'package:noq/services/circular_progress.dart';
import 'package:noq/services/mapService.dart';
import 'package:noq/style.dart';
import 'package:noq/utils.dart';
import 'package:noq/widget/appbar.dart';
import 'package:noq/widget/bottom_nav_bar.dart';
import 'package:noq/widget/widgets.dart';
import 'package:share/share.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:noq/userHomePage.dart';

class FavsListPage extends StatefulWidget {
  @override
  _FavsListPageState createState() => _FavsListPageState();
}

class _FavsListPageState extends State<FavsListPage> {
  bool initCompleted = false;
  bool isFavourited = false;
  DateTime dateTime = DateTime.now();
  final dtFormat = new DateFormat('dd');
  SharedPreferences _prefs;

  List<Entity> _stores = new List<Entity>();

  String _entityType;

  bool fetchFromServer = false;

  final compareDateFormat = new DateFormat('YYYYMMDD');
  List<DateTime> _dateList = new List<DateTime>();
  String _dynamicLink;

  Icon actionIcon = new Icon(
    Icons.search,
    color: Colors.white,
  );
  final key = new GlobalKey<ScaffoldState>();

  List<Entity> _list;

  String pageName;
  GlobalState _state;
  bool stateInitFinished = false;
  String emptyPageMsg;

  @override
  void initState() {
    super.initState();

    getGlobalState().whenComplete(() {
      fetchFavStoresList().then((value) => setState(() {
            initCompleted = true;
          }));
    });
  }

  Future<void> getGlobalState() async {
    _state = await GlobalState.getGlobalState();
  }

  Future<void> fetchFavStoresList() async {
    List<Entity> newList = new List<Entity>();
    Entity e;
    //if (initCompleted) {
    print(_state.currentUser.favourites);

    if (!Utils.isNullOrEmpty(_state.currentUser.favourites)) {
      for (MetaEntity fs in _state.currentUser.favourites) {
        e = await EntityService().getEntity(fs.entityId);
        newList.add(e);
      }
      setState(() {
        _stores = newList;
      });
    }
    // }
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
    for (int i = 0; i < favs.length; i++) {
      if (favs[i].entityId == en.entityId) {
        return true;
      }
    }
    return false;
  }

  bool updateFavourite(MetaEntity en) {
    bool isFav = false;
    isFav = isFavourite(en);
    if (isFav) {
      setState(() {
        _state.removeFavourite(en);
      });

      return true;
    } else {
      setState(() {
        _state.addFavourite(en);
      });

      return false;
    }
  }

  void toggleFavorite(Entity strData) {
//Check if its already User fav
    bool isFav = false;
    MetaEntity metaEn = strData.getMetaEntity();

    if (updateFavourite(metaEn)) {
      isFav = true;
      EntityService().removeEntityFromUserFavourite(strData.entityId);
    } else {
      EntityService().addEntityToUserFavourite(metaEn);
    }

    setState(() {
      // strData.isFavourite = !strData.isFavourite;

      _stores.remove(strData);
    });

    if ((_stores.length == 0)) {
      setState(() {
        _stores = null;
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

  Widget _emptyFavsPage() {
    String txtMsg = (emptyPageMsg != null) ? emptyPageMsg : noFavMsg;
    return Expanded(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Text(txtMsg, style: highlightTextStyle),
          Text(defaultSearchSubMsg, style: highlightSubTextStyle),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
// build widget only after init has completed, till then show progress indicator.
    if (!initCompleted) {
      return MaterialApp(
        theme: ThemeData.light().copyWith(),
        home: Scaffold(
          appBar: CustomAppBar(
            titleTxt: "My Favourites",
          ),
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                showCircularProgress(),
              ],
            ),
          ),
          //drawer: CustomDrawer(),
          bottomNavigationBar: CustomBottomBar(barIndex: 2),
        ),
      );
    } else {
      String title = "My Favourites";

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
                  (!Utils.isNullOrEmpty(_stores))
                      ? Expanded(
                          child: ListView.builder(
                              itemCount: 1,
                              itemBuilder: (BuildContext context, int index) {
                                return Container(
                                  margin: EdgeInsets.fromLTRB(10, 10, 10, 10),
                                  child: new Column(
                                    children: showFavourites(),
                                  ),
                                );
                              }),
                        )
                      : _emptyFavsPage(),
                ],
              ),
            ),
          ),
          // drawer: CustomDrawer(),
          bottomNavigationBar: CustomBottomBar(barIndex: 2),
          // drawer: CustomDrawer(),
        ),
      );
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
                      pageName: "Favs",
                      childList: str.childEntities,
                      parentName: str.name)));
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
                                                  accessRestricted,
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
                                Utils.showMyFlushbar(context, Icons.error,
                                    Duration(seconds: 5), locationNotFound, "");
                              }
                            } catch (error) {
                              Utils.showMyFlushbar(context, Icons.error,
                                  Duration(seconds: 5), cantOpenMaps, tryLater);
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
                        ]),
                  ]),
            ),
          ],
        ),
      ),
    );
  }

  void showSlots(Entity store, DateTime dateTime) {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => ShowSlotsPage(
                  entity: store,
                  dateTime: dateTime,
                  forPage: 'FavSearch',
                )));
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
                    "This place is closed on the selected day.",
                    "Please Select a different day.",
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

  List<Widget> showFavourites() {
    return _stores.map(_buildItem).toList();
    // return _stores.map((contact) => new ChildItem(contact.name)).toList();
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
