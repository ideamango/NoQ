import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flushbar/flushbar_route.dart';
import 'package:flutter/material.dart';
import 'package:geoflutterfire/geoflutterfire.dart';
import 'package:noq/constants.dart';
import 'package:noq/db/db_model/address.dart';
import 'package:noq/db/db_model/my_geo_fire_point.dart';
import 'package:noq/db/db_service/db_main.dart';
import 'package:noq/db/db_service/entity_service.dart';
import 'package:noq/db/db_service/token_service.dart';
import 'package:noq/db/db_service/user_service.dart';
import 'package:noq/global_state.dart';
import 'package:noq/pages/SearchStoresPage.dart';
import 'package:noq/pages/db_test.dart';
import 'package:noq/pages/shopping_list.dart';
import 'package:noq/repository/local_db_repository.dart';
import 'package:noq/repository/slotRepository.dart';
import 'package:noq/services/circular_progress.dart';
import 'package:noq/services/mapService.dart';
import 'package:noq/services/qr_code_generate.dart';
import 'package:noq/services/qrcode_scan.dart';
import 'package:noq/style.dart';
import 'package:intl/intl.dart';
import 'package:noq/utils.dart';
import 'package:noq/widget/appbar.dart';
import 'package:noq/widget/bottom_nav_bar.dart';
import 'package:noq/widget/carousel.dart';
import 'package:noq/widget/header.dart';
import 'package:noq/widget/widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:barcode_scan/barcode_scan.dart';
import 'package:flutter/services.dart';

import 'db/db_model/configurations.dart';
import 'db/db_model/entity.dart';
import 'db/db_model/entity_private.dart';
import 'db/db_model/entity_slots.dart';
import 'db/db_model/meta_entity.dart';
import 'db/db_model/meta_user.dart';
import 'db/db_model/slot.dart';
import 'db/db_model/app_user.dart';
import 'db/db_model/user_token.dart';
import 'db/db_service/configurations_service.dart';
import 'package:carousel_slider/carousel_slider.dart';
//import 'path';

class UserHomePage extends StatefulWidget {
  @override
  _UserHomePageState createState() => _UserHomePageState();
}

class _UserHomePageState extends State<UserHomePage> {
  int i;
  List<UserToken> _pastBookingsList;
  List<UserToken> _newBookingsList;
  String _upcomingBkgStatus;
  String _pastBkgStatus;
  // UserAppData _userProfile;
  DateTime now = DateTime.now();
  final dtFormat = new DateFormat(dateDisplayFormat);
  bool isUpcomingSet = false;
  bool isPastSet = false;
//Qr code scan result
  ScanResult scanResult;
  GlobalState _state;
  bool _initCompleted = false;

  @override
  void initState() {
    super.initState();
    setState(() {
      _upcomingBkgStatus = 'Loading';
      _pastBkgStatus = 'Loading';
    });
    getGlobalState().whenComplete(() {
      setState(() {
        _initCompleted = true;
      });
      _loadBookings();
    });

    //  this.initDynamicLinks();
  }

  Future<void> getGlobalState() async {
    _state = await GlobalState.getGlobalState();
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

  void fetchDataFromGlobalState() {
    if (!Utils.isNullOrEmpty(_state.bookings)) {
      if (_state.bookings.length != 0) {
        _pastBookingsList = _state.getPastBookings();

        _newBookingsList = _state.getUpcomingBookings();

        if (_pastBookingsList.length != 0) {
          _pastBkgStatus = 'Success';
        } else
          _pastBkgStatus = 'NoBookings';
        if (_newBookingsList.length != 0) {
          _upcomingBkgStatus = 'Success';
        } else
          _upcomingBkgStatus = 'NoBookings';
      }
    } else {
      _upcomingBkgStatus = 'NoBookings';
      _pastBkgStatus = 'NoBookings';
    }
  }

  void _loadBookings() async {
    //Fetch details from server

    //loadDataFromPrefs();
    fetchDataFromGlobalState();
  }

  int _currentIndex = 0;
  List cardList = [
    Item1(),
    Item2(),
    Item3(),
    Item4(),
    Item5(),
    Item6(),
    Item7()
  ];
  List<T> map<T>(List list, Function handler) {
    List<T> result = [];
    for (var i = 0; i < list.length; i++) {
      result.add(handler(i, list[i]));
    }
    return result;
  }

  @override
  Widget build(BuildContext context) {
    if (_initCompleted) {
      String title = "Home Page";
      return MaterialApp(
          theme: ThemeData.light().copyWith(),
          home: Scaffold(
            appBar: CustomAppBar(
              titleTxt: title,
            ),
            body: Scrollbar(
              child: SingleChildScrollView(
                child: Column(
                  children: <Widget>[
                    Card(
                      elevation: 20,
                      child: Container(
                        padding: EdgeInsets.all(5),
                        child: Column(
                          children: <Widget>[
                            Column(
                              children: <Widget>[
                                CarouselSlider(
                                  options: CarouselOptions(
                                    height: 150.0,
                                    autoPlay: true,
                                    autoPlayInterval: Duration(seconds: 3),
                                    autoPlayAnimationDuration:
                                        Duration(milliseconds: 800),
                                    autoPlayCurve: Curves.easeIn,
                                    pauseAutoPlayOnTouch: true,
                                    aspectRatio: 2.0,
                                    onPageChanged:
                                        (index, carouselPageChangedReason) {
                                      setState(() {
                                        _currentIndex = index;
                                      });
                                    },
                                  ),
                                  items: cardList.map((card) {
                                    return Builder(
                                        builder: (BuildContext context) {
                                      return Container(
                                        height:
                                            MediaQuery.of(context).size.height *
                                                0.40,
                                        width:
                                            MediaQuery.of(context).size.width,
                                        child: Card(
                                          color: primaryAccentColor,
                                          child: card,
                                        ),
                                      );
                                    });
                                  }).toList(),
                                ),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: <Widget>[
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children:
                                          map<Widget>(cardList, (index, url) {
                                        return Container(
                                          width: 7.0,
                                          height: 7.0,
                                          margin: EdgeInsets.symmetric(
                                              vertical: 2.0, horizontal: 2.0),
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            color: _currentIndex == index
                                                ? highlightColor
                                                : Colors.grey,
                                          ),
                                        );
                                      }),
                                    ),
                                  ],
                                )
                              ],
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                Column(
                                  children: <Widget>[
                                    Text(homeScreenMsgTxt2,
                                        style: homeMsgStyle2),
                                    Text(
                                      homeScreenMsgTxt3,
                                      style: homeMsgStyle3,
                                    ),
                                  ],
                                ),
                                // QrCodeScanner().build(context),
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
                            style: TextStyle(
                                color: Colors.blueGrey[700], fontSize: 17),
                          ),
                          backgroundColor: Colors.white,
                          leading: Icon(
                            Icons.date_range,
                            color: primaryIcon,
                          ),
                          children: <Widget>[
                            if (_upcomingBkgStatus == 'Success')
                              ConstrainedBox(
                                constraints: new BoxConstraints(
                                  maxHeight:
                                      MediaQuery.of(context).size.height * .4,
                                ),
                                child: Scrollbar(
                                  child: ListView.builder(
                                    shrinkWrap: true,
                                    //scrollDirection: Axis.vertical,
                                    itemBuilder:
                                        (BuildContext context, int index) {
                                      return Container(
                                        padding: EdgeInsets.symmetric(
                                          horizontal: 8,
                                        ),
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
                              ),
                            if (_upcomingBkgStatus == 'NoBookings')
                              _emptyStorePage("No bookings yet.. ",
                                  "Book now to save time later!! "),
                            if (_upcomingBkgStatus == 'Loading')
                              showCircularProgress(),
                          ],
                        ),
                      ),
                    ),
                    if (_state.currentUser.ph == '+919999999999')
                      Container(
                        height: 30,
                        width: 60,
                        child: RaisedButton(
                          color: btnColor,
                          onPressed: () {
                            print("testing");
                            DBTest().dbCall();
                            print("testing updated");
                          },
                          child: Text("Run test"),
                        ),
                      ),
                  ],
                ),
              ),
            ),
            floatingActionButton: SizedBox(
              height: 45,
              child: new FloatingActionButton(
                  splashColor: highlightColor,
                  elevation: 30.0,
                  child: ImageIcon(
                    AssetImage('assets/qrcode.png'),
                    size: 25,
                    color: primaryIcon,
                  ),
                  backgroundColor: primaryAccentColor,
                  onPressed: () {
                    QrCodeScanner.scan(context);
                  }),
            ),
            floatingActionButtonLocation:
                FloatingActionButtonLocation.centerDocked,
            drawer: CustomDrawer(),
            bottomNavigationBar: CustomBottomBar(
              barIndex: 0,
            ),
          ),
          routes: <String, WidgetBuilder>{
            '/DLink': (BuildContext context) => new SearchStoresPage(),
          });
    } else {
      return MaterialApp(
        theme: ThemeData.light().copyWith(),
        home: Scaffold(
            appBar: CustomAppBar(
              titleTxt: "Home Page",
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
            bottomNavigationBar: CustomBottomBar(barIndex: 0)),
      );
    }
  }

  String getEntityAddress(String entityId) {
    //TODO SMITA Add implementation
    return 'Gachibowli, Hyderabad';
  }

  void showShoppingList(UserToken booking) {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => ShoppingList(
                  token: booking,
                )));
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

  Widget _buildItem(UserToken booking) {
    String address = getEntityAddress(booking.entityId);
    return Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.width * .7 / 2.6,
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/ticket.jpg'),
            fit: BoxFit.fill,
          ),
        ),
        child: Stack(
          children: <Widget>[
            new Row(mainAxisAlignment: MainAxisAlignment.center, children: <
                Widget>[
              Container(
                width: MediaQuery.of(context).size.width * .7,
                height: MediaQuery.of(context).size.width * .7 / 3.5,
                child: Column(
                  //mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: <Widget>[
                    Container(
                      padding: EdgeInsets.fromLTRB(
                          MediaQuery.of(context).size.height * .008, 0, 0, 0),
                      alignment: Alignment.centerLeft,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            booking.getDisplayName(),
                            style: tokenTextStyle,
                            textAlign: TextAlign.left,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    Divider(
                      indent: MediaQuery.of(context).size.height * .008,

                      // thickness: 1,
                      height: 1,
                      color: Colors.blueGrey[300],
                    ),
                    Column(
                      // mainAxisAlignment: MainAxisAlignment.end,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Container(
                          margin: EdgeInsets.fromLTRB(
                              MediaQuery.of(context).size.height * .008,
                              0,
                              0,
                              0),
                          padding: EdgeInsets.fromLTRB(
                              MediaQuery.of(context).size.height * .008,
                              0,
                              0,
                              0),
                          child: Text(
                            booking.entityName + ', ' + address,
                            overflow: TextOverflow.ellipsis,
                            style: tokenDataTextStyle,
                          ),
                        ),
                        SizedBox(
                          height: MediaQuery.of(context).size.height * .008,
                        ),
                        Container(
                          // alignment: Alignment.centerLeft,
                          height: MediaQuery.of(context).size.width * .06,
                          //Text('Where: ', style: tokenHeadingTextStyle),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: <Widget>[
                              Container(
                                width: MediaQuery.of(context).size.width * .08,
                                height: MediaQuery.of(context).size.width * .07,
                                child: IconButton(
                                    padding: EdgeInsets.all(0),
                                    alignment: Alignment.center,
                                    highlightColor: Colors.orange[300],
                                    icon: Icon(
                                      Icons.phone,
                                      color: lightIcon,
                                      size: 20,
                                    ),
                                    onPressed: () {
// TODO Smita - Get public contact and update booking.entityId

                                      if (booking.phone != null) {
                                        try {
                                          callPhone(booking.phone);
                                        } catch (error) {
                                          Utils.showMyFlushbar(
                                              context,
                                              Icons.error,
                                              Duration(seconds: 5),
                                              "Could not connect call to the number ${booking.phone} !!",
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
                                    }),
                              ),
                              Container(
                                width: MediaQuery.of(context).size.width * .08,
                                height: MediaQuery.of(context).size.width * .07,
                                // width: 20.0,
                                child: IconButton(
                                  padding: EdgeInsets.all(0),
                                  alignment: Alignment.center,
                                  highlightColor: Colors.orange[300],
                                  icon: Icon(
                                    Icons.cancel,
                                    color: lightIcon,
                                    size: 22,
                                  ),
                                  onPressed: () {
                                    if (booking.number == -1)
                                      return null;
                                    else
                                      showCancelBooking(booking);
                                  },
                                ),
                              ),
                              Container(
                                width: MediaQuery.of(context).size.width * .08,
                                height: MediaQuery.of(context).size.width * .07,
                                // width: 20.0,
                                child: IconButton(
                                    padding: EdgeInsets.all(0),
                                    alignment: Alignment.center,
                                    highlightColor: Colors.orange[300],
                                    icon: Icon(
                                      Icons.location_on,
                                      color: lightIcon,
                                      size: 21,
                                    ),
                                    onPressed: () {
                                      try {
                                        launchURL(booking.entityName, address,
                                            booking.lat, booking.lon);
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
                                width: MediaQuery.of(context).size.width * .08,
                                height: MediaQuery.of(context).size.width * .07,
                                child: IconButton(
                                  padding: EdgeInsets.all(0),
                                  alignment: Alignment.center,
                                  highlightColor: Colors.orange[300],
                                  icon: ImageIcon(
                                    AssetImage('assets/whatsapp.png'),
                                    size: 18,
                                    color: Colors.white,
                                  ),
                                  onPressed: () {
                                    String phoneNo = booking.entityWhatsApp;
                                    if (phoneNo != null && phoneNo != "") {
                                      try {
                                        launchWhatsApp(
                                            message: whatsappMessage,
                                            phone: phoneNo);
                                      } catch (error) {
                                        Utils.showMyFlushbar(
                                            context,
                                            Icons.error,
                                            Duration(seconds: 5),
                                            "Could not connect to the Whatsapp number $phoneNo !!",
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
                              ),
                              Container(
                                width: MediaQuery.of(context).size.width * .08,
                                height: MediaQuery.of(context).size.width * .07,
                                // width: 20.0,
                                child: IconButton(
                                  padding: EdgeInsets.all(0),
                                  alignment: Alignment.center,
                                  highlightColor: Colors.orange[300],
                                  icon: Icon(
                                    Icons.list,
                                    color: lightIcon,
                                    size: 22,
                                  ),
                                  onPressed: () => showShoppingList(booking),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              VerticalDivider(
                indent: 5,
                endIndent: 5,
                // thickness: 1,
                width: 1,
                color: Colors.blueGrey[300],
              ),
              Container(
                width: MediaQuery.of(context).size.width * .2,
                // padding: EdgeInsets.fromLTRB(5, 5, 0, 0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    //verticalSpacer,
                    Text(
                      dtFormat.format(booking.dateTime),
                      style: tokenDataTextStyle,
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
                          Utils.formatTime(booking.dateTime.hour.toString()) +
                              ':' +
                              Utils.formatTime(
                                  booking.dateTime.minute.toString()),
                          style: tokenDateTextStyle,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ]),
            if (booking.number == -1)
              new Positioned(
                left: MediaQuery.of(context).size.width * .5,
                bottom: MediaQuery.of(context).size.width * .14,
                child: new Container(
                  //color: Colors.red,
                  height: MediaQuery.of(context).size.width * .1,
                  width: MediaQuery.of(context).size.width * .4,
                  child: Image.asset('assets/cancelled_2.png'),
                ),
              ),
          ],
        ));
  }

  void showCancelBooking(UserToken booking) {
    showDialog(
        barrierDismissible: false,
        context: context,
        builder: (_) => AlertDialog(
              titlePadding: EdgeInsets.fromLTRB(10, 15, 10, 10),
              contentPadding: EdgeInsets.all(0),
              actionsPadding: EdgeInsets.all(5),
              //buttonPadding: EdgeInsets.all(0),
              title: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    'Are you sure you want to cancel this booking?',
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
                      print("Cancel booking");
                      bool cancelDone = false;
                      cancelToken(booking).then((value) {
                        setState(() {
                          booking.number = -1;
                        });

                        cancelDone = value;
                        if (!cancelDone) {
                          Utils.showMyFlushbar(
                              context,
                              Icons.info_outline,
                              Duration(
                                seconds: 5,
                              ),
                              "Couldn't cancel your booking for some reason. ",
                              "Please try again later.");
                        }
                      }).catchError((e) {
                        print(e);
                      });
                      Navigator.of(context, rootNavigator: true).pop();
                      Utils.showMyFlushbar(
                          context,
                          Icons.cancel,
                          Duration(
                            seconds: 3,
                          ),
                          "Cancelling your booking",
                          "Please wait..");
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
                      print("Do nothing");
                      Navigator.of(context, rootNavigator: true).pop();
                      // Navigator.of(context, rootNavigator: true).pop('dialog');
                    },
                  ),
                ),
              ],
            ));
  }
}
