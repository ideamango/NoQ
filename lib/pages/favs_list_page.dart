import 'package:auto_size_text/auto_size_text.dart';
import 'package:enum_to_string/enum_to_string.dart';
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';
import '../constants.dart';
import '../db/db_model/address.dart';
import '../db/db_model/entity.dart';
import '../db/db_model/meta_entity.dart';
import '../db/db_model/user_token.dart';
import '../db/db_service/entity_service.dart';
import '../enum/entity_type.dart';
import '../global_state.dart';
import '../pages/place_details_page.dart';
import '../pages/search_child_entity_page.dart';

import '../pages/show_slots_page.dart';
import '../repository/local_db_repository.dart';
import '../repository/slotRepository.dart';
import '../services/circular_progress.dart';
import '../services/url_services.dart';
import '../style.dart';
import '../utils.dart';
import '../widget/appbar.dart';
import '../widget/bottom_nav_bar.dart';
import '../widget/page_animation.dart';
import '../widget/widgets.dart';
import 'package:share/share.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../userHomePage.dart';

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
  PersistentBottomSheetController placeDetailsSheetController;

  List<MetaEntity> _stores = new List<MetaEntity>();

  String _entityType;

  bool fetchFromServer = false;

  final compareDateFormat = new DateFormat('YYYYMMDD');
  List<DateTime> _dateList = new List<DateTime>();

  Icon actionIcon = new Icon(
    Icons.search,
    color: Colors.white,
  );
  final key = new GlobalKey<ScaffoldState>();

  List<MetaEntity> _list;

  String pageName;
  GlobalState _state;
  bool stateInitFinished = false;
  String emptyPageMsg;
  double fontSize;

  var sideInfoGrp = new AutoSizeGroup();
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
    //List<MetaEntity> newList = new List<MetaEntity>();
    Entity e;
    //if (initCompleted) {
    print(_state.getCurrentUser().favourites);
    _stores.clear();
    if (!Utils.isNullOrEmpty(_state.getCurrentUser().favourites)) {
      for (MetaEntity fs in _state.getCurrentUser().favourites) {
        //e = await EntityService().getEntity(fs.entityId);
        _stores.add(fs);
      }
      setState(() {});
    }
    // }
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
    if (_state.getCurrentUser() == null) {
      return false;
    }

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

  void toggleFavorite(MetaEntity strData) {
//Removes favorite from User-Favorites and update favs list being displayed.
//If nothing in list then displays message.
    MetaEntity metaEn = strData;
    _state.removeFavourite(metaEn).then((value) {
      _stores?.remove(strData);
      setState(() {});
    });
    setState(() {});
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
  }

  generateLinkAndShareWithParams(String entityId, String name) async {
    String msgTitle = entityShareByUserHeading + name;
    String msgBody = entityShareByUserMessage;

    Utils.generateLinkAndShare(entityId, msgTitle, msgBody);
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

  Future<bool> willPopCallback() async {
    if (placeDetailsSheetController != null) {
      placeDetailsSheetController.close();
      placeDetailsSheetController = null;
      return false;
    } else {
      //Navigator.of(context).pop();
      Navigator.of(context).push(PageAnimation.createRoute(UserHomePage()));
      return false;
    }
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
        home: WillPopScope(
          child: Scaffold(
            key: key,
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
          onWillPop: willPopCallback,
        ),
      );
    } else {
      String title = "My Favourites";
      return MaterialApp(
        debugShowCheckedModeBanner: false,
        home: WillPopScope(
          child: Scaffold(
            key: key,
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
                      //  Navigator.of(context).pop();
                      Navigator.of(context)
                          .push(PageAnimation.createRoute(UserHomePage()));
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
            Navigator.of(context)
                .push(PageAnimation.createRoute(UserHomePage()));
            return false;
          },
        ),
      );
    }
  }

  Widget entityImageIcon(EntityType type) {
    // String imgName;
    Widget imgWidget;
    //  imgName = Utils.getEntityTypeImage(type);

    imgWidget = Utils.getEntityTypeImage(type, 30);

    return imgWidget;
  }

  Widget _buildItem(MetaEntity str) {
    _prepareDateList();
    print('after buildDateGrid called');
    return Card(
      margin: EdgeInsets.fromLTRB(8, 12, 8, 0),
      elevation: 10,
      child: Column(
        children: <Widget>[
          new Row(
            crossAxisAlignment: CrossAxisAlignment.start,
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
                              children: <Widget>[
                                GestureDetector(
                                  onTap: () {
                                    print("Container clicked");
                                    _state.getEntity(str.entityId).then(
                                        (value) => {
                                              showPlaceDetailsSheet(value.item1)
                                            });
                                  },
                                  child: Container(
                                    padding: EdgeInsets.zero,
                                    width:
                                        MediaQuery.of(context).size.width * .7,
                                    child: AutoSizeText(
                                      (str.name) ?? str.name.toString(),
                                      style: TextStyle(
                                          fontSize: fontSize, color: btnColor),
                                      maxLines: 1,
                                      minFontSize: 18,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ),
                                (str.enableVideoChat)
                                    ? Container(
                                        width:
                                            MediaQuery.of(context).size.width *
                                                .08,
                                        height:
                                            MediaQuery.of(context).size.height *
                                                .04,
                                        child: IconButton(
                                          icon: Icon(
                                            Icons.videocam,
                                            color: primaryIcon,
                                            size: 25,
                                          ),
                                          onPressed: () {
                                            if (str.whatsapp != null &&
                                                str.whatsapp != "") {
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
                                          },
                                        ),
                                      )
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
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      width: MediaQuery.of(context).size.width *
                                          .48,
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
                                  ],
                                ),
                                if (str.startTimeHour != null)
                                  Container(
                                    width:
                                        MediaQuery.of(context).size.width * .18,
                                    padding: EdgeInsets.all(0),
                                    margin: EdgeInsets.all(0),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: <Widget>[
                                        AutoSizeText(
                                            Utils.formatTime(str.startTimeHour
                                                    .toString()) +
                                                ':' +
                                                Utils.formatTime(str
                                                    .startTimeMinute
                                                    .toString()),
                                            group: sideInfoGrp,
                                            minFontSize: 9,
                                            maxFontSize: 11,
                                            style: TextStyle(
                                              color: Colors.green[600],
                                              fontFamily: 'Monsterrat',
                                            )),
                                        Text(' - ',
                                            style: TextStyle(
                                                color: primaryDarkColor,
                                                fontSize: 10)),
                                        AutoSizeText(
                                            Utils.formatTime(str.endTimeHour
                                                    .toString()) +
                                                ':' +
                                                Utils.formatTime(str
                                                    .endTimeMinute
                                                    .toString()),
                                            group: sideInfoGrp,
                                            minFontSize: 9,
                                            maxFontSize: 11,
                                            style: TextStyle(
                                              color: Colors.red[900],
                                              fontFamily: 'Monsterrat',
                                            )),
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
                              (Utils.isNotNullOrEmpty(str.address))
                                  ? str.address
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
                              child: AutoSizeText(
                                (str.distance != null)
                                    ? str.distance.toStringAsFixed(1) + ' Km'
                                    : "",
                                group: sideInfoGrp,
                                minFontSize: 9,
                                maxFontSize: 11,
                                textAlign: TextAlign.right,
                                style: TextStyle(
                                  color: btnColor,
                                  fontFamily: 'Monsterrat',
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
                            if (str.lat != null)
                              launchURL(
                                  str.name, str.address, str.lat, str.lon);
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
                          borderRadius: BorderRadius.all(Radius.circular(5.0))),
                      color: Colors.white,
                      splashColor: highlightColor,
                      onPressed: () => toggleFavorite(str),
                      highlightColor: Colors.orange[300],
                      child: isFavourite(str)
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
                        if (str.hasChildren)
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
                                //Load child page.

                                _state.getEntity(str.entityId).then((value) {
                                  if (value != null) {
                                    dynamic route = SearchChildEntityPage(
                                        pageName: "FavsSearch",
                                        childList: value.item1.childEntities,
                                        parentName: str.name);
                                    Navigator.of(context)
                                        .push(PageAnimation.createRoute(route));
                                  } else {
                                    Utils.showMyFlushbar(
                                        context,
                                        Icons.info,
                                        Duration(seconds: 4),
                                        "Oops! Could not load the details of this place",
                                        "Please try again later.");
                                  }
                                });
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
                        if (!str.hasChildren)
                          Container(
                            width: 40,
                            height: 40,
                          ),
                      ]),
                ]),
          ),
        ],
      ),
    );
  }

  void showSlots(MetaEntity store, DateTime dateTime) {
    //Check INTERNET connection first.

    Navigator.of(context).push(PageAnimation.createRoute(ShowSlotsPage(
      metaEntity: store,
      dateTime: dateTime,
      forPage: 'FavsList',
    )));
  }

  List<Widget> _buildDateGridItems(MetaEntity store, String sid, String sname,
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

  Widget buildDateItem(
      MetaEntity store,
      String sid,
      String sname,
      bool isClosed,
      bool isBookingAllowed,
      int advanceDays,
      DateTime dt,
      String dayOfWeek) {
    bool dateBooked = false;
    // UserAppData user = _userProfile;

    if (_state.bookings != null) {
      for (UserToken obj in (_state.bookings)) {
        if ((compareDateFormat
                    .format(dt)
                    .compareTo(compareDateFormat.format(obj.parent.dateTime)) ==
                0) &&
            (obj.parent.entityId == sid && obj.number != -1)) {
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

  List<Widget> showFavourites() {
    return _stores.map(_buildItem).toList();
  }
}
