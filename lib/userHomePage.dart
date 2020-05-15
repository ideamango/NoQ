import 'package:flutter/material.dart';
import 'package:noq/constants.dart';
import 'package:noq/models/localDB.dart';
import 'package:noq/repository/local_db_repository.dart';
import 'package:noq/services/mapService.dart';
import 'package:noq/style.dart';
import 'package:intl/intl.dart';
import 'package:noq/view/circular_progress.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:barcode_scan/barcode_scan.dart';
import 'package:flutter/services.dart';
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
  UserAppData _userProfile;
  DateTime now = DateTime.now();
  final dtFormat = new DateFormat(dateDisplayFormat);
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

  void _loadBookings() async {
    //Load details from local files
    SharedPreferences prefs = await SharedPreferences.getInstance();
    //int userId = prefs.getInt('userId');
    //Fetch details from server

    await readData().then((fUser) {
      _userProfile = fUser;
      if (_userProfile != null) {
        if (_userProfile.upcomingBookings.length != 0) {
          var bookings = _userProfile.upcomingBookings;
          List<BookingListItem> newBookings = new List<BookingListItem>();
          List<BookingListItem> pastBookings = new List<BookingListItem>();

          setState(() {
            for (BookingAppData bk in bookings) {
              for (StoreAppData str in _userProfile.storesAccessed) {
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
            _upcomingBkgStatus = 'Success';
          });
        } else {
          setState(() {
            _upcomingBkgStatus = 'NoBookings';
          });
        }
      } else {
        setState(() {
          _upcomingBkgStatus = 'NoBookings';
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_upcomingBkgStatus == 'Success') {
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
                          RaisedButton(
                            padding: EdgeInsets.all(1),
                            autofocus: false,
                            clipBehavior: Clip.none,
                            elevation: 20,
                            color: highlightColor,
                            child: Row(
                              children: <Widget>[
                                Text('Scan QR', style: buttonSmlTextStyle),
                                SizedBox(width: 5),
                                Icon(
                                  Icons.camera,
                                  color: tealIcon,
                                  size: 26,
                                ),
                              ],
                            ),
                            onPressed: scan,
                          )
                        ],
                      )
                    ],
                  ),
                ),
                //child: Image.asset('assets/noq_home.png'),
              ),
              Card(
                elevation: 20,
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
                    ConstrainedBox(
                      constraints: new BoxConstraints(
                        maxHeight: MediaQuery.of(context).size.height * .6,
                      ),
                      child:
                          // decoration: BoxDecoration(
                          //     shape: BoxShape.rectangle,
                          //     borderRadius: BorderRadius.all(Radius.circular(8.0))),
                          // height: MediaQuery.of(context).size.height * .6,
                          // margin: EdgeInsets.fromLTRB(10, 10, 10, 10),
                          ListView.builder(
                        shrinkWrap: true,
                        //scrollDirection: Axis.vertical,
                        itemBuilder: (BuildContext context, int index) {
                          return Container(
                            child: new Column(
                                children:
                                    _newBookingsList.map(_buildItem).toList()),
                            //children: <Widget>[firstRow, secondRow],
                          );
                        },
                        itemCount: 1,
                      ),
                    ),
                  ],
                ),
              ),
              Card(
                elevation: 20,
                child: ExpansionTile(
                  title: Text(
                    "Past Bookings",
                    style: TextStyle(color: Colors.blueGrey[700], fontSize: 17),
                  ),
                  backgroundColor: Colors.white,
                  leading: Icon(
                    Icons.access_time,
                    color: lightIcon,
                  ),
                  children: <Widget>[
                    Column(
                      children: <Widget>[
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
                      ],
                    )
                  ],
                ),
              ),
            ],
          ),
        ],
      );
    } else if (_upcomingBkgStatus == 'NoBookings') {
      return _emptyStorePage();
    } else {
      return showCircularProgress();
    }
  }

  Widget _emptyStorePage() {
    return Center(
        child: Center(
            child: Container(
                margin: EdgeInsets.fromLTRB(10, 10, 10, 10),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Text('No favourites yet!! ', style: highlightTextStyle),
                    Text('Add your favourite places to quickly browse later!! ',
                        style: highlightSubTextStyle),
                  ],
                ))));
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
                                      booking.storeInfo.adrs,
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
