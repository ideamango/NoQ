import 'package:flutter/material.dart';
import 'package:noq/constants.dart';
import 'package:noq/models/localDB.dart';
import 'package:noq/repository/local_db_repository.dart';
import 'package:noq/services/mapService.dart';
import 'package:noq/style.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserBookingPage extends StatefulWidget {
  @override
  _UserBookingPageState createState() => _UserBookingPageState();
}

class _UserBookingPageState extends State<UserBookingPage> {
  int i;
  List<BookingListItem> _bookings;
  String _upcomingBkgStatus;
  UserAppData _userProfile;
  final dtFormat = new DateFormat(dateDisplayFormat);

  @override
  void initState() {
    super.initState();
    _loadUpcomingBookings();
  }

  void toggleFavorite(EntityAppData strData) {
    setState(() {
      strData.isFavourite = !strData.isFavourite;
      print("Fav changed ---- booking");
      // if (strData.isFavourite == true) {

      //   for (String favStoreId in _userProfile.favStores) {
      //     if (favStoreId == strData.id) return;
      //   }
      //   _userProfile.favStores.add(strData.id);
      // } else {
      //   _userProfile.favStores.removeWhere((item) => item == strData.id);
      // }
    });
    writeData(_userProfile);
  }

  void _loadUpcomingBookings() async {
    //Load details from local files
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int userId = prefs.getInt('userId');
    //Fetch details from server

    await readData().then((fUser) {
      _userProfile = fUser;
      if (_userProfile.upcomingBookings.length != 0) {
        var bookings = _userProfile.upcomingBookings;
        List<BookingListItem> newList = new List<BookingListItem>();
        setState(() {
          _upcomingBkgStatus = 'Success';
          for (BookingAppData bk in bookings) {
            for (EntityAppData str in _userProfile.storesAccessed) {
              if (str.id == bk.storeId)
                newList.add(new BookingListItem(str, bk));
            }
          }
          _bookings = newList;
        });
      } else {
        setState(() {
          _upcomingBkgStatus = 'NoBookings';
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_upcomingBkgStatus != 'Success') {
      return _emptyBookingPage();
    } else {
      return _buildBkgListPage();
    }
  }

  Widget _emptyBookingPage() {
    return Center(
        child: Center(
            child: Container(
      margin: EdgeInsets.fromLTRB(10, 10, 10, 10),
      child: Text('No Bookings yet!!'),
    )));
  }

  Widget _buildBkgListPage() {
    return Center(
      child: Container(
        margin: EdgeInsets.fromLTRB(10, 10, 10, 10),
        child: ListView.builder(
            itemCount: 1,
            itemBuilder: (BuildContext context, int index) {
              return Container(
                child: new Column(children: _bookings.map(_buildItem).toList()),
                //children: <Widget>[firstRow, secondRow],
              );
            }),
      ),
    );
  }

  void callStore(String phone) {}

  Widget _buildItem(BookingListItem booking) {
    return Card(
      //  margin: EdgeInsets.all(10.0),

      color: Colors.white,
      elevation: 10,
      child: new Row(
          //crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.end,
          children: <Widget>[
            // Container(
            //   width: MediaQuery.of(context).size.width * .1,
            //   child: Column(
            //     children: <Widget>[
            //       new Container(
            //         margin: EdgeInsets.fromLTRB(
            //             MediaQuery.of(context).size.width * .01,
            //             MediaQuery.of(context).size.width * .015,
            //             MediaQuery.of(context).size.width * .005,
            //             MediaQuery.of(context).size.width * .005),
            //         padding:
            //             EdgeInsets.all(MediaQuery.of(context).size.width * .01),
            //         // alignment: Alignment.center,
            //         decoration: ShapeDecoration(
            //           shape: CircleBorder(),
            //           color: darkIcon,
            //         ),
            //         child: Icon(
            //           Icons.shopping_cart,
            //           color: Colors.white,
            //           size: 20,
            //         ),
            //       )
            //     ],
            //   ),
            // ),
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
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: <Widget>[
                        Text('T-1030-14',
                            // booking.bookingInfo.tokenNum,
                            style: tokenTextStyle),
                      ],
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Container(
                        width: MediaQuery.of(context).size.width * .2,
                        //Text('Where: ', style: tokenHeadingTextStyle),
                        child: Text(
                          booking.storeInfo.name,
                          // ' , ' +
                          // booking.storeInfo.adrs,
                          textAlign: TextAlign.right,
                          overflow: TextOverflow.ellipsis,
                          style: tokenDataTextStyle,
                        ),
                      ),
                      Container(
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
                                    color: Colors.black,
                                    size: 21,
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
                                  color: Colors.black,
                                  size: 23,
                                ),
                                onPressed: () => launchURL(
                                    booking.storeInfo.name,
                                    booking.storeInfo.adrs.toString(),
                                    booking.storeInfo.lat,
                                    booking.storeInfo.long),
                              ),
                            ),
                            Container(
                              // margin: EdgeInsets.fromLTRB(
                              //     0, 0, MediaQuery.of(context).size.width * .01, 0),
                              height: MediaQuery.of(context).size.width * .06,
                              // width: 20,
                              child: IconButton(
                                padding: EdgeInsets.all(0),
                                alignment: Alignment.centerLeft,
                                onPressed: () => {},
                                //toggleFavorite(booking.storeInfo),
                                highlightColor: Colors.orange[300],
                                iconSize: 20,
                                icon: booking.storeInfo.isFavourite
                                    ? Icon(
                                        Icons.favorite,
                                        color: Colors.red[800],
                                      )
                                    : Icon(
                                        Icons.favorite_border,
                                        color: Colors.red[800],
                                      ),
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
    );
  }
}
