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

  String getFormattedAddress(Address address) {
    String adr = (address.address != null ? (address.address + ', ') : "") +
        (address.locality != null ? (address.locality + ', ') : "") +
        (address.landmark != null ? (address.landmark + ', ') : "") +
        (address.city != null ? (address.city + ', ') : "");
    return adr;
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

  Widget _emptyFavsPage() {
    String txtMsg = (emptyPageMsg != null) ? emptyPageMsg : noFavMsg;
    return Expanded(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Text(txtMsg, style: highlightTextStyle),
          Text('Add places to favourites, and quickly browse through later. ',
              style: highlightSubTextStyle),
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
                  builder: (context) =>
                      SearchChildrenPage(childList: str.childEntities)));
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
                                      icon: Icon(Icons.share),
                                      iconSize: 20,
                                      onPressed: () {
                                        generateLinkAndShareWithParams(
                                            str.entityId);
                                      },
                                    )),
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
                                      onPressed: () {
                                        try {
                                          launchURL(
                                              str.name,
                                              getFormattedAddress(str.address),
                                              str.coordinates.geopoint.latitude,
                                              str.coordinates.geopoint
                                                  .longitude);
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
                                        parentName: str.name)));
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
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => ShowSlotsPage(
                  entity: store,
                  dateTime: dateTime,
                  forPage: 'FavSearch',
                )));
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

class ChildItem extends StatelessWidget {
  final String name;
  ChildItem(this.name);
  @override
  Widget build(BuildContext context) {
    return new ListTile(title: new Text(this.name));
  }
}
