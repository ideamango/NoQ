import 'package:auto_size_text/auto_size_text.dart';
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

import 'package:noq/pages/show_slots_page.dart';
import 'package:noq/repository/local_db_repository.dart';
import 'package:noq/repository/slotRepository.dart';
import 'package:noq/services/circular_progress.dart';
import 'package:noq/services/url_services.dart';
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
  double fontSize;
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
    print(_state.getCurrentUser().favourites);

    if (!Utils.isNullOrEmpty(_state.getCurrentUser().favourites)) {
      for (MetaEntity fs in _state.getCurrentUser().favourites) {
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
    List<MetaEntity> favs = _state.getCurrentUser().favourites;
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
//Removes favorite from User-Favorites and update favs list being displayed.
//If nothing in list then displays message.
    MetaEntity metaEn = strData.getMetaEntity();
    _state.removeFavourite(metaEn).then((value) {
      _stores?.remove(strData);
      setState(() {});
    });
    setState(() {});
  }

  generateLinkAndShareWithParams(String entityId, String name) async {
    String msgTitle = entityShareByUserHeading + name;
    String msgBody = entityShareMessage;
    var dynamicLink =
        await Utils.createDynamicLinkWithParams(entityId, msgTitle, msgBody);
    print("Dynamic Link: $dynamicLink");
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
          Image.asset(
            'assets/noFavourites.png',
            width: MediaQuery.of(context).size.width * .9,
          ),
          // Text(txtMsg, style: highlightTextStyle),
          // Text(defaultSearchSubMsg, style: highlightSubTextStyle),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    fontSize = MediaQuery.of(context).size.width;
    print("Font size" + fontSize.toString());
// build widget only after init has completed, till then show progress indicator.
    if (!initCompleted) {
      return MaterialApp(
        theme: ThemeData.light().copyWith(),
        home: WillPopScope(
          child: Scaffold(
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
          onWillPop: () async {
            return true;
          },
        ),
      );
    } else {
      String title = "My Favourites";

      return MaterialApp(
        theme: ThemeData.light().copyWith(),
        home: WillPopScope(
          child: Scaffold(
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
          onWillPop: () async {
            return true;
          },
        ),
      );
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
    return GestureDetector(
      onTap: () {
        showDialogForPlaceDetails(str, context);
      },
      child: Card(
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
                                  Container(
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
                      width: MediaQuery.of(context).size.width * .07,
                      child: Image.asset(
                        'assets/offers_icon.png',
                      ),
                      //  color: Colors.amber,
                    ),
                    // if (!Utils.isNotNullOrEmpty(str.offer?.message))
                    //   Container(
                    //     padding: EdgeInsets.all(0),
                    //     width: MediaQuery.of(context).size.width * .07,
                    //     child: Image.asset('assets/offers_icon.png',
                    //         color: disabledColor),
                    //     //  color: Colors.amber,
                    //   ),
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
                      ),
                    ),
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
                            generateLinkAndShareWithParams(
                                str.entityId, str.name);
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
