import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:noq/constants.dart';
import 'package:noq/db/db_model/address.dart';
import 'package:noq/db/db_model/my_geo_fire_point.dart';
import 'package:noq/db/db_service/db_main.dart';
import 'package:noq/db/db_service/entity_service.dart';
import 'package:noq/db/db_service/token_service.dart';
import 'package:noq/db/db_service/user_service.dart';
import 'package:noq/models/localDB.dart';
import 'package:noq/repository/local_db_repository.dart';
import 'package:noq/services/circular_progress.dart';
import 'package:noq/services/mapService.dart';
import 'package:noq/services/qr_code_generate.dart';
import 'package:noq/services/qrcode_scan.dart';
import 'package:noq/style.dart';
import 'package:intl/intl.dart';
import 'package:noq/widget/widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:barcode_scan/barcode_scan.dart';
import 'package:flutter/services.dart';

import 'db/db_model/entity.dart';
import 'db/db_model/entity_slots.dart';
import 'db/db_model/user.dart';
import 'db/db_model/user_token.dart';
//import 'path';

class UserHomePage extends StatefulWidget {
  @override
  _UserHomePageState createState() => _UserHomePageState();
}

class _UserHomePageState extends State<UserHomePage> {
  int i;
  List<BookingListItem> _pastBookingsList;
  List<BookingListItem> _newBookingsList;
  String _upcomingBkgStatus;
  String _pastBkgStatus;
  UserAppData _userProfile;
  DateTime now = DateTime.now();
  final dtFormat = new DateFormat(dateDisplayFormat);
  bool isUpcomingSet = false;
  bool isPastSet = false;
//Qr code scan result
  ScanResult scanResult;

  @override
  void initState() {
    super.initState();
    _loadBookings();
  }

  Future scan() async {
    try {
      var result = await BarcodeScanner.scan();

      setState(() => scanResult = result);
    } on PlatformException catch (e) {
      var result = ScanResult(
        type: ResultType.Error,
        format: BarcodeFormat.unknown,
      );

      if (e.code == BarcodeScanner.cameraAccessDenied) {
        setState(() {
          result.rawContent = 'The user did not grant the camera permission!';
        });
      } else {
        result.rawContent = 'Unknown error: $e';
      }
      setState(() {
        scanResult = result;
        print(scanResult);
      });
    }
  }

  void createEntity() async {
    Address adrs = new Address(
        city: "Hyderbad",
        state: "Telangana",
        country: "India",
        address: "Shop 10, Gachibowli");

    MyGeoFirePoint geoPoint = new MyGeoFirePoint(68, 78);
    Entity entity = new Entity(
        entityId: "Entity101",
        name: "VijethaModified",
        address: adrs,
        advanceDays: 3,
        isPublic: true,
        geo: geoPoint,
        maxAllowed: 60,
        slotDuration: 60,
        closedOn: ["Saturday", "Sunday"],
        breakStartHour: 13,
        breakStartMinute: 30,
        breakEndHour: 14,
        breakEndMinute: 30,
        startTimeHour: 10,
        startTimeMinute: 30,
        endTimeHour: 21,
        endTimeMinute: 0,
        parentId: null,
        type: "Mall",
        isBookable: false,
        isActive: true,
        coordinates: geoPoint);

    try {
      await EntityService().upsertEntity(entity);
    } catch (e) {
      print("Exception occured " + e);
    }
  }

  void updateEntity() async {
    Address adrs = new Address(
        city: "Hyderbad",
        state: "Telangana",
        country: "India",
        address: "Shop 10, Gachibowli");

    MyGeoFirePoint geoPoint = new MyGeoFirePoint(68, 78);
    Entity entity = new Entity(
        entityId: "Entity101",
        name: "VijethaModified" +
            adrs.hashCode.toString(), //just some random number
        address: adrs,
        advanceDays: 3,
        isPublic: true,
        geo: geoPoint,
        maxAllowed: 60,
        slotDuration: 60,
        closedOn: ["Saturday", "Sunday"],
        breakStartHour: 13,
        breakStartMinute: 30,
        breakEndHour: 14,
        breakEndMinute: 30,
        startTimeHour: 10,
        startTimeMinute: 30,
        endTimeHour: 21,
        endTimeMinute: 0,
        parentId: null,
        type: "Mall",
        isBookable: false,
        isActive: true,
        coordinates: geoPoint);

    try {
      await EntityService().upsertEntity(entity);
    } catch (e) {
      print("Exception occured " + e);
    }
  }

  void createChildEntityAndAddToParent(String id, String name) async {
    Address adrs = new Address(
        city: "Hyderbad",
        state: "Telangana",
        country: "India",
        address: "Shop 10, Gachibowli");

    MyGeoFirePoint geoPoint = new MyGeoFirePoint(68, 78);

    Entity child1 = new Entity(
        entityId: id,
        name: name + adrs.hashCode.toString(), //just some random number,
        address: adrs,
        advanceDays: 5,
        isPublic: true,
        geo: geoPoint,
        maxAllowed: 50,
        slotDuration: 30,
        closedOn: ["Saturday", "Sunday"],
        breakStartHour: 13,
        breakStartMinute: 15,
        breakEndHour: 14,
        breakEndMinute: 30,
        startTimeHour: 10,
        startTimeMinute: 30,
        endTimeHour: 21,
        endTimeMinute: 0,
        parentId: null,
        type: "Shop",
        isBookable: true,
        isActive: true,
        coordinates: geoPoint);

    bool added =
        await EntityService().upsertChildEntityToParent(child1, 'Entity101');
  }

  void updateChildEntity(String id, String name) {
    Address adrs = new Address(
        city: "Hyderbad",
        state: "Telangana",
        country: "India",
        address: "Shop 10, Gachibowli");

    MyGeoFirePoint geoPoint = new MyGeoFirePoint(68, 78);

    Entity child1 = new Entity(
        entityId: id,
        name: name + adrs.hashCode.toString(),
        address: adrs,
        advanceDays: 5,
        isPublic: true,
        geo: geoPoint,
        maxAllowed: 50,
        slotDuration: 30,
        closedOn: ["Saturday", "Sunday"],
        breakStartHour: 13,
        breakStartMinute: 15,
        breakEndHour: 14,
        breakEndMinute: 30,
        startTimeHour: 10,
        startTimeMinute: 30,
        endTimeHour: 21,
        endTimeMinute: 0,
        parentId: null,
        type: "Shop",
        isBookable: true,
        isActive: true,
        coordinates: geoPoint);
  }

  void clearAll() async {
    //delete childEntity
    await EntityService().deleteEntity("Child101-1");

    //delete parentEntity, which should also delete child entities
    await EntityService().deleteEntity("Entity101");

    try {
      await EntityService().deleteEntity("Child101-3");

      await EntityService().deleteEntity("Child101-2");
    } catch (e) {}

    //delete user
    await UserService().deleteCurrentUser();
  }

  void dbCall() async {
    //final FirebaseUser user = await FirebaseAuth.instance.currentUser();
    //  User u = await UserService().getCurrentUser();

    // DBLayer.addRecord();
    // UserToken tok = await TokenService()
    //     .generateToken("entityId001", new DateTime(2020, 6, 6, 10, 30, 0, 0));

    // EntitySlots es = await TokenService()
    //     .getEntitySlots('entityId001', new DateTime(2020, 6, 6));

    // int i = 0;

    // await TokenService()
    //     .cancelToken("entityId001#2020~6~6#10~30#93hKw20HwFaVdHRsujOlpjaouoL2");

    //await createChildEntityAndAddToParent(
    //    'Child101-1', "Bata"); //should fail as entity does not exists

    User usr = await UserService().getCurrentUser();

    await createEntity();

    await createChildEntityAndAddToParent('Child101-1', "Bata");

    await createChildEntityAndAddToParent('Child101-2', "Habinaro");

    await updateEntity();

    await createChildEntityAndAddToParent('Child101-3', "Raymonds");

    await updateEntity();

    await createChildEntityAndAddToParent('Child101-1', "Bata");

    Entity ent = await EntityService().getEntity('Entity101');

    Entity Child1 = await EntityService().getEntity('Child101-1');

    Entity Child2 = await EntityService().getEntity('Child101-2');

    Entity Child3 = await EntityService().getEntity('Child101-3');

    // bool isDeleted = await EntityService().deleteEntity('Entity101');

    await clearAll();

    int i = 0;
  }

  void _loadBookings() async {
    //Load details from local files
    SharedPreferences prefs = await SharedPreferences.getInstance();
    //int userId = prefs.getInt('userId');
    //Fetch details from server
    _upcomingBkgStatus = 'Loading';
    _pastBkgStatus = 'Loading';
    await readData().then((fUser) {
      _userProfile = fUser;
      if (_userProfile != null) {
        if (_userProfile.upcomingBookings.length != 0) {
          var bookings = _userProfile.upcomingBookings;
          List<BookingListItem> newBookings = new List<BookingListItem>();
          List<BookingListItem> pastBookings = new List<BookingListItem>();

          setState(() {
            for (BookingAppData bk in bookings) {
              for (EntityAppData str in _userProfile.storesAccessed) {
                if (str.id == bk.storeId) {
                  if (bk.bookingDate.isBefore(now))
                    pastBookings.add(new BookingListItem(str, bk));
                  else
                    newBookings.add(new BookingListItem(str, bk));
                }
              }
            }
            _pastBookingsList = pastBookings;
            _newBookingsList = newBookings;
            if (_pastBookingsList.length != 0) {
              _pastBkgStatus = 'Success';
            } else
              _pastBkgStatus = 'NoBookings';
            if (_newBookingsList.length != 0) {
              _upcomingBkgStatus = 'Success';
            }
          });
        } else {
          setState(() {
            _upcomingBkgStatus = 'NoBookings';
            _pastBkgStatus = 'NoBookings';
          });
        }
      } else {
        setState(() {
          _pastBkgStatus = 'NoBookings';
          _upcomingBkgStatus = 'NoBookings';
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    //if (_upcomingBkgStatus == 'Success') {
    return ListView(
      children: <Widget>[
        Column(
          children: <Widget>[
            Card(
              elevation: 20,
              child: Container(
                padding: EdgeInsets.all(5),
                child: Column(
                  children: <Widget>[
                    Container(
                      color: Colors.teal,
                      padding: EdgeInsets.all(3),
                      child: Image.asset(
                        'assets/noq_home_bookPremises.png',
                        width: MediaQuery.of(context).size.width * .95,
                      ),
                    ),
                    // Text(homeScreenMsgTxt, style: homeMsgStyle),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Column(
                          children: <Widget>[
                            Text(homeScreenMsgTxt2, style: homeMsgStyle2),
                            Text(
                              homeScreenMsgTxt3,
                              style: homeMsgStyle3,
                            ),
                          ],
                        ),
                        QrCodeScanner().build(context),

                        //GenerateScreen(),
                        // RaisedButton(
                        //   padding: EdgeInsets.all(1),
                        //   autofocus: false,
                        //   clipBehavior: Clip.none,
                        //   elevation: 20,
                        //   color: highlightColor,
                        //   child: Row(
                        //     children: <Widget>[
                        //       Text('Scan QR', style: buttonSmlTextStyle),
                        //       SizedBox(width: 5),
                        //       Icon(
                        //         Icons.camera,
                        //         color: tealIcon,
                        //         size: 26,
                        //       ),
                        //     ],
                        //   ),
                        //   onPressed: scan,
                        // )
                      ],
                    )
                  ],
                ),
              ),
              //child: Image.asset('assets/noq_home.png'),
            ),
            Card(
              elevation: 20,
              child: Theme(
                data: ThemeData(
                  unselectedWidgetColor: Colors.grey[600],
                  accentColor: Colors.teal,
                ),
                child: ExpansionTile(
                  //key: PageStorageKey(this.widget.headerTitle),
                  initiallyExpanded: true,
                  title: Text(
                    "Upcoming Bookings",
                    style: TextStyle(color: Colors.blueGrey[700], fontSize: 17),
                  ),
                  backgroundColor: Colors.white,
                  leading: Icon(
                    Icons.date_range,
                    color: tealIcon,
                  ),
                  children: <Widget>[
                    if (_upcomingBkgStatus == 'Success')
                      ConstrainedBox(
                        constraints: new BoxConstraints(
                          maxHeight: MediaQuery.of(context).size.height * .6,
                        ),

                        // decoration: BoxDecoration(
                        //     shape: BoxShape.rectangle,
                        //     borderRadius: BorderRadius.all(Radius.circular(8.0))),
                        // height: MediaQuery.of(context).size.height * .6,
                        // margin: EdgeInsets.fromLTRB(10, 10, 10, 10),
                        child: ListView.builder(
                          shrinkWrap: true,
                          //scrollDirection: Axis.vertical,
                          itemBuilder: (BuildContext context, int index) {
                            return Container(
                              child: new Column(
                                  children: _newBookingsList
                                      .map(_buildItem)
                                      .toList()),
                              //children: <Widget>[firstRow, secondRow],
                            );
                          },
                          itemCount: 1,
                        ),
                      ),
                    if (_upcomingBkgStatus == 'NoBookings')
                      _emptyStorePage("No bookings yet.. ",
                          "Book now to save time later!! "),
                    if (_upcomingBkgStatus == 'Loading') showCircularProgress(),
                  ],
                ),
              ),
            ),
            Card(
              elevation: 20,
              child: Theme(
                data: ThemeData(
                  unselectedWidgetColor: Colors.grey[600],
                  accentColor: Colors.teal,
                ),
                child: ExpansionTile(
                  title: Text(
                    "Past Bookings",
                    style: TextStyle(color: Colors.blueGrey[700], fontSize: 17),
                  ),
                  backgroundColor: Colors.white,
                  leading: Icon(
                    Icons.access_time,
                    color: tealIcon,
                  ),
                  children: <Widget>[
                    Column(
                      children: <Widget>[
                        if (_pastBkgStatus == "Success")
                          Container(
                            //height: MediaQuery.of(context).size.width * .5,
                            child: ListView.builder(
                              shrinkWrap: true,
                              scrollDirection: Axis.vertical,
                              itemBuilder: (BuildContext context, int index) {
                                return Container(
                                  child: new Column(
                                      children: _pastBookingsList
                                          .map(_buildItem)
                                          .toList()),
                                  //children: <Widget>[firstRow, secondRow],
                                );
                              },
                              itemCount: 1,
                            ),
                          ),
                        if (_pastBkgStatus == 'NoBookings')
                          _emptyStorePage("No bookings in past..",
                              "Book now to save time later!! "),
                        if (_pastBkgStatus == 'Loading') showCircularProgress(),
                      ],
                    )
                  ],
                ),
              ),
            ),
            RaisedButton(
              color: Colors.blue,
              onPressed: dbCall,
              child: Icon(Icons.add),
            ),
          ],
        ),
      ],
    );
    //} else
    // if (_upcomingBkgStatus == 'NoBookings') {
    //   return _emptyStorePage();
    // } else {
    //   return showCircularProgress();
    // }
  }

  Widget _emptyStorePage(String msg1, String msg2) {
    return Center(
        child: Column(children: <Widget>[
      myDivider,
      Container(
          margin: EdgeInsets.fromLTRB(10, 10, 10, 10),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text(msg1, style: highlightTextStyle),
              Text(msg2, style: highlightSubTextStyle),
            ],
          ))
    ]));
  }

  Widget _buildItem(BookingListItem booking) {
    return Card(
      //  margin: EdgeInsets.all(10.0),

      color: Colors.white,
      elevation: 10,
      child: Container(
        decoration: BoxDecoration(
            shape: BoxShape.rectangle,
            borderRadius: BorderRadius.all(Radius.circular(5.0)),
            border: Border.all(color: Colors.teal)),
        child: new Row(
            //crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.end,
            children: <Widget>[
              Container(
                width: MediaQuery.of(context).size.width * .65,
                height: MediaQuery.of(context).size.width * .7 / 4,
                child: Column(
                  //mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: <Widget>[
                    Row(
                      children: <Widget>[],
                    ),
                    Container(
                      alignment: Alignment.centerLeft,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: <Widget>[
                          Text(
                            'T-1030-14',
                            // booking.bookingInfo.tokenNum,
                            style: tokenTextStyle, textAlign: TextAlign.left,
                          ),
                        ],
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Container(
                          alignment: Alignment.centerLeft,
                          width: MediaQuery.of(context).size.width * .2,
                          //Text('Where: ', style: tokenHeadingTextStyle),
                          child: Text(
                            booking.storeInfo.name,
                            overflow: TextOverflow.ellipsis,
                            style: tokenDataTextStyle,
                          ),
                        ),
                        Container(
                          alignment: Alignment.centerLeft,
                          width: MediaQuery.of(context).size.width * .4,
                          //Text('Where: ', style: tokenHeadingTextStyle),
                          child: Row(
                            children: <Widget>[
                              Container(
                                // margin: EdgeInsets.fromLTRB(
                                //     0,
                                //     0,
                                //     MediaQuery.of(context).size.width * .02,
                                //     MediaQuery.of(context).size.width * .05),
                                height: MediaQuery.of(context).size.width * .07,
                                // width: 20.0,
                                child: IconButton(
                                    padding: EdgeInsets.all(0),
                                    alignment: Alignment.centerRight,
                                    highlightColor: Colors.orange[300],
                                    icon: Icon(
                                      Icons.phone,
                                      color: tealIcon,
                                      size: 20,
                                    ),
                                    onPressed: () => {}
                                    //callStore(booking.storeInfo.phone),
                                    ),
                              ),
                              Container(
                                // margin: EdgeInsets.fromLTRB(
                                //     0,
                                //     0,
                                //     MediaQuery.of(context).size.width * .02,
                                //     MediaQuery.of(context).size.width * .05),
                                height: MediaQuery.of(context).size.width * .07,
                                // width: 20.0,
                                child: IconButton(
                                  padding: EdgeInsets.all(0),
                                  alignment: Alignment.center,
                                  highlightColor: Colors.orange[300],
                                  icon: Icon(
                                    Icons.location_on,
                                    color: tealIcon,
                                    size: 22,
                                  ),
                                  onPressed: () => launchURL(
                                      booking.storeInfo.name,
                                      booking.storeInfo.adrs.toString(),
                                      booking.storeInfo.lat,
                                      booking.storeInfo.long),
                                ),
                              ),
                              // Container(
                              //   // margin: EdgeInsets.fromLTRB(
                              //   //     0, 0, MediaQuery.of(context).size.width * .01, 0),
                              //   height: MediaQuery.of(context).size.width * .06,
                              //   // width: 20,
                              //   child: IconButton(
                              //     padding: EdgeInsets.all(0),
                              //     alignment: Alignment.centerLeft,
                              //     onPressed: () => {},
                              //     //toggleFavorite(booking.storeInfo),
                              //     highlightColor: Colors.orange[300],
                              //     iconSize: 20,
                              //     icon: booking.storeInfo.isFavourite
                              //         ? Icon(
                              //             Icons.favorite,
                              //             color: Colors.red[800],
                              //           )
                              //         : Icon(
                              //             Icons.favorite_border,
                              //             color: Colors.red[800],
                              //           ),
                              //   ),
                              // ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Container(
                //alignment: Alignment.centerRight,
                width: MediaQuery.of(context).size.width * .25,
                padding: EdgeInsets.fromLTRB(0, 5, 0, 0),
                child: Column(
                  //mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  //crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        // Text('Date: ', style: tokenHeadingTextStyle),
                        Text(
                          dtFormat.format(booking.bookingInfo.bookingDate),
                          style: tokenDataTextStyle,
                        ),
                      ],
                    ),
                    Container(
                      height: 5,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: <Widget>[
                        // Text('Time: ', style: tokenHeadingTextStyle),
                        Text(
                          booking.bookingInfo.timing,
                          style: tokenDateTextStyle,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ]),
      ),
    );
  }
}
