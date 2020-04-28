import 'package:flutter/material.dart';
import 'package:noq/models/localDB.dart';
import 'package:noq/repository/local_db_repository.dart';
import 'package:noq/style.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserBookingPage extends StatefulWidget {
  @override
  _UserBookingPageState createState() => _UserBookingPageState();
}

class _UserBookingPageState extends State<UserBookingPage> {
  int i;
  List<BookingAppData> _bookings;
  String _upcomingBkgStatus;
  UserAppData fUserProfile;

  @override
  void initState() {
    super.initState();
    _loadUpcomingBookings();
  }

  void _loadUpcomingBookings() async {
    //Load details from local files
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int userId = prefs.getInt('userId');
    //Fetch details from server

    await readData().then((fUser) {
      fUserProfile = fUser;
      if (fUserProfile.upcomingBookings.length != 0) {
        setState(() {
          _upcomingBkgStatus = 'Success';
          _bookings = fUserProfile.upcomingBookings;
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
            itemCount: _bookings.length,
            itemBuilder: (BuildContext context, int index) {
              return Container(
                child: new Column(children: _bookings.map(_buildItem).toList()),
                //children: <Widget>[firstRow, secondRow],
              );
            }),
      ),
    );
  }

  Widget _buildItem(BookingAppData str) {
    return Card(
        elevation: 10,
        child: new Column(children: <Widget>[
          Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                new Container(
                  padding: EdgeInsets.fromLTRB(10.0, 5.0, 0, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Container(
                        padding: EdgeInsets.fromLTRB(0, 5, 5, 5),
                        child:
                            Column(crossAxisAlignment: CrossAxisAlignment.start,
                                // mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                              Text(
                                str.storeName.toString(),
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Text(
                                    str.timing,
                                  ),
                                  Container(
                                    width: 20.0,
                                    height: 20.0,
                                    child: IconButton(
                                      alignment: Alignment.center,
                                      padding: EdgeInsets.all(0),
                                      onPressed: () => {
                                        // launchURL(str.name, str.adrs, str.lat,
                                        //     str.long),
                                      },
                                      highlightColor: Colors.orange[300],
                                      icon: Icon(
                                        Icons.location_on,
                                        color: Colors.blueGrey,
                                      ),
                                    ),
                                  ),
                                ],
                              )
                            ]),
                      ),
                    ],
                  ),
                ),
              ]),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Row(
                children: <Widget>[],
              ),
              Row(
                children: <Widget>[
                  new Container(
                    width: 40.0,
                    height: 20.0,
                    child: MaterialButton(
                      color: Colors.orange,
                      child: Text(
                        "Book Slot",
                        style: new TextStyle(
                            fontFamily: 'Montserrat',
                            letterSpacing: 0.5,
                            color: Colors.white,
                            fontSize: 10),
                      ),
                      onPressed: () => {
                        //onPressed_bookSlotBtn();
                      },
                      highlightColor: Colors.orange[300],
                    ),
                  )
                ],
              ),
            ],
          )
        ]));
  }
}
