import 'package:flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import 'package:noq/db/db_model/entity.dart';
import 'package:noq/db/db_model/meta_entity.dart';
import 'package:noq/db/db_model/slot.dart';
import 'package:noq/db/db_model/user_token.dart';
import 'package:noq/db/db_service/entity_service.dart';
import 'package:noq/global_state.dart';
import 'package:noq/pages/SearchStoresPage.dart';
import 'package:noq/pages/favs_list_page.dart';
import 'package:noq/pages/search_child_page.dart';
import 'package:noq/pages/token_alert.dart';
import 'package:noq/repository/slotRepository.dart';
import 'package:noq/style.dart';
import 'package:noq/utils.dart';
import 'package:noq/widget/appbar.dart';
import 'package:noq/widget/bottom_nav_bar.dart';
import 'package:noq/widget/header.dart';
import 'package:noq/widget/widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';

import '../constants.dart';

class ShowSlotsPage extends StatefulWidget {
  final Entity entity;
  final DateTime dateTime;
  final String forPage;

  ShowSlotsPage(
      {Key key,
      @required this.entity,
      @required this.dateTime,
      @required this.forPage})
      : super(key: key);

  @override
  _ShowSlotsPageState createState() => _ShowSlotsPageState();
}

class _ShowSlotsPageState extends State<ShowSlotsPage> {
  bool _initCompleted = false;
  String _storeId;
  String _token;
  String _errorMessage;
  DateTime _date;
  String _dateFormatted;
  String dt;
  List<Slot> _slotList;
  final dateFormat = new DateFormat('dd');
  Slot selectedSlot;
  Slot bookedSlot;
  String _storeName;
  String _userId;
  String _strDateForSlot;
  bool _showProgressInd = false;

  String title = "Book Slot";
  GlobalState _state;
  bool _gStateInitFinished = false;
  MetaEntity metaEn;
  Entity entity;

  @override
  void initState() {
    //dt = dateFormat.format(DateTime.now());
    super.initState();
    getGlobalState().whenComplete(() => _loadSlots());
  }

  Future<void> _loadSlots() async {
    entity = widget.entity;
    _date = widget.dateTime;
    _storeId = entity.entityId;
    _storeName = entity.name;
    //Format date to display in UI
    final dtFormat = new DateFormat(dateDisplayFormat);
    _dateFormatted = dtFormat.format(_date);

    //Fetch details from server
    getSlotsListForStore(entity, _date).then((slotList) {
      setState(() {
        _slotList = slotList;

        _initCompleted = true;
      });
    });
  }

  Future<void> getGlobalState() async {
    _state = await GlobalState.getGlobalState();
    _gStateInitFinished = true;
  }

  Widget _noSlotsPage() {
    return MaterialApp(
      theme: ThemeData.light().copyWith(),
      home: Scaffold(
        drawer: CustomDrawer(),
        appBar: CustomAppBar(
          titleTxt: title,
        ),
        body: Center(
            child: Center(
                child: Container(
          margin: EdgeInsets.fromLTRB(10, 10, 10, 10),
          child: Text('All slots booked for this date!!'),
        ))),
        bottomNavigationBar: CustomBottomBar(
          barIndex: 3,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // pr = new ProgressDialog(context);
    // pr.style(
    //   message: 'Please wait...',
    //   backgroundColor: Colors.amber[50],
    //   elevation: 10.0,
    // );
    if (_initCompleted) {
      if (Utils.isNullOrEmpty(_slotList))
        return _noSlotsPage();
      else {
        Widget pageHeader = Text(
          _storeName,
          style: TextStyle(
            fontSize: 23,
            color: Colors.black,
          ),
        );
        String bookingDate;
        String bookingTime;
        if (selectedSlot != null) {
          bookingDate =
              DateFormat.yMMMEd().format(selectedSlot.dateTime).toString();
          bookingTime =
              DateFormat.Hm().format(selectedSlot.dateTime).toString();
        }
        dynamic backRoute;
        if (widget.forPage == 'MainSearch') backRoute = SearchStoresPage();
        if (widget.forPage == 'ChildSearch') backRoute = SearchStoresPage();
        if (widget.forPage == 'FavSearch') backRoute = FavsListPage();

        return MaterialApp(
          theme: ThemeData.light().copyWith(),
          home: Scaffold(
            drawer: CustomDrawer(),
            appBar: CustomAppBarWithBackButton(
                titleTxt: _storeName, backRoute: backRoute),
            body: Padding(
              padding: const EdgeInsets.fromLTRB(6, 6, 6, 6),
              child: Container(
                decoration: BoxDecoration(
                    border: Border.all(color: borderColor),
                    color: Colors.white,
                    shape: BoxShape.rectangle,
                    borderRadius: BorderRadius.all(Radius.circular(5.0))),
                child: Column(
                  children: <Widget>[
                    Container(
                      height: MediaQuery.of(context).size.width * .1,
                      padding: EdgeInsets.fromLTRB(6, 0, 0, 0),
                      decoration: darkContainer,
                      child: Row(
                        children: <Widget>[
                          Icon(
                            Icons.check_circle,
                            size: 35,
                            color: Colors.white,
                          ),
                          SizedBox(width: 12),
                          Flexible(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                (selectedSlot == null)
                                    ? Text(
                                        "Select from available slots on " +
                                            _dateFormatted +
                                            ".",
                                        style: TextStyle(
                                            color: Colors.white, fontSize: 13),
                                      )
                                    : (isBooked(selectedSlot.dateTime,
                                            entity.entityId))
                                        ? Text(
                                            'You already have a booking at $bookingTime on $bookingDate',
                                            style: TextStyle(
                                                color: primaryAccentColor,
                                                fontSize: 13),
                                          )
                                        : Text(
                                            'You selected a slot at $bookingTime on $bookingDate',
                                            style: TextStyle(
                                                color: highlightColor,
                                                fontSize: 13),
                                          ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Container(
                        child: new GridView.builder(
                          padding: EdgeInsets.symmetric(horizontal: 5),
                          scrollDirection: Axis.vertical,
                          shrinkWrap: true,
                          itemCount: _slotList.length,
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 5,
                                  crossAxisSpacing: 2.0,
                                  mainAxisSpacing: 0.5),
                          itemBuilder: (BuildContext context, int index) {
                            return new GridTile(
                              child: Container(
                                padding: EdgeInsets.all(2),
                                // decoration:
                                //     BoxDecoration(border: Border.all(color: Colors.black, width: 0.5)),
                                child: Center(
                                  child: _buildGridItem(context, index),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                    Container(
                      height: MediaQuery.of(context).size.width * .19,
                      padding: EdgeInsets.all(4),
                      // decoration: new BoxDecoration(
                      //   border: Border.all(color: Colors.teal[200]),
                      //   shape: BoxShape.rectangle,
                      // color: Colors.cyan[100],
                      // borderRadius: BorderRadius.only(
                      //     topLeft: Radius.circular(4.0),
                      //     topRight: Radius.circular(4.0))
                      //),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: <Widget>[
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              SizedBox(
                                width: MediaQuery.of(context).size.width * .5,
                                height: MediaQuery.of(context).size.width * .08,
                                child: RaisedButton(
                                  elevation:
                                      (selectedSlot != null) ? 12.0 : 0.0,
                                  color: (selectedSlot != null)
                                      ? highlightColor
                                      : disabledColor,
                                  textColor: Colors.white,
                                  child: Text('Book Slot'),
                                  onPressed: bookSlot,
                                ),
                              ),
                              (_errorMessage != null
                                  ? Text(
                                      _errorMessage,
                                      style: TextStyle(color: Colors.red),
                                    )
                                  : Container()),
                            ],
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: <Widget>[
                              Row(
                                children: <Widget>[
                                  Icon(Icons.label,
                                      color: highlightColor, size: 15),
                                  Text(" Currently Selected",
                                      style: TextStyle(
                                        color: Colors.blueGrey[900],
                                        // fontWeight: FontWeight.w800,
                                        fontFamily: 'Monsterrat',
                                        letterSpacing: 0.5,
                                        fontSize: 9.0,
                                        //height: 2,
                                      )),
                                ],
                              ),
                              horizontalSpacer,
                              Row(children: <Widget>[
                                Icon(Icons.label,
                                    color: Colors.cyan[300], size: 15),
                                Text(" Existing Booking",
                                    style: TextStyle(
                                      color: Colors.blueGrey[900],
                                      // fontWeight: FontWeight.w800,
                                      fontFamily: 'Monsterrat',
                                      letterSpacing: 0.5,
                                      fontSize: 9.0,
                                      //height: 2,
                                    )),
                              ]),
                              horizontalSpacer,
                              Row(children: <Widget>[
                                Icon(Icons.label,
                                    color: Colors.blueGrey[400], size: 15),
                                Text(" Not available",
                                    style: TextStyle(
                                      color: Colors.blueGrey[900],
                                      // fontWeight: FontWeight.w800,
                                      fontFamily: 'Monsterrat',
                                      letterSpacing: 0.5,
                                      fontSize: 9.0,
                                      //height: 2,
                                    )),
                              ]),
                            ],
                          )
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Row(
            //   children: <Widget>[
            //     RaisedButton(
            //       elevation: 12.0,
            //       color: (selectedSlot != null) ? Colors.orange : Colors.grey,
            //       textColor: Colors.white,
            //       child: Text('Book Slot'),
            //       onPressed: bookSlot,
            //     ),
            //     (_errorMessage != null
            //         ? Text(
            //             _errorMessage,
            //             style: TextStyle(color: Colors.red),
            //           )
            //         : Container()),
            //   ],
            // )

            bottomNavigationBar: CustomBottomBar(
              barIndex: 3,
            ),
          ),
        );
      }
    } else {
      return MaterialApp(
        theme: ThemeData.light().copyWith(),
        home: Scaffold(
            appBar: CustomAppBar(
              titleTxt: "Search",
            ),
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  // Padding(padding: EdgeInsets.only(top: 20.0)),
                  Text(
                    "Loading..",
                    style: TextStyle(fontSize: 20.0, color: borderColor),
                  ),
                  Padding(padding: EdgeInsets.only(top: 20.0)),
                  CircularProgressIndicator(
                    backgroundColor: primaryAccentColor,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.amber),
                    strokeWidth: 3,
                  )
                ],
              ),
            ),
            //drawer: CustomDrawer(),
            bottomNavigationBar: CustomBottomBar(barIndex: 1)),
      );
    }
  }

  bool isSelected(DateTime dateTime) {
    if (selectedSlot != null) {
      if (dateTime.compareTo(selectedSlot.dateTime) == 0) return true;
    }
    return false;
  }

  bool isBooked(DateTime dateTime, String entityId) {
    for (int i = 0; i < _state.bookings.length; i++) {
      if (_state.bookings[i].entityId == entityId &&
          _state.bookings[i].dateTime == dateTime) {
        return true;
      }
    }
    return false;
  }

  Widget _buildGridItem(BuildContext context, int index) {
    //TODO: Check what information coming from server, then process and use it.
    Slot sl = _slotList[index];
    String hrs = sl.dateTime.hour.toString();
    String mnts = sl.dateTime.minute.toString();

    return Column(
      children: <Widget>[
        RaisedButton(
          elevation: (isSelected(sl.dateTime) == true) ? 0.0 : 10.0,
          padding: EdgeInsets.all(2),
          child: Text(
            hrs + ':' + mnts,
            style: TextStyle(fontSize: 12, color: Colors.white),
            // textDirection: TextDirection.ltr,
            // textAlign: TextAlign.center,
          ),

          autofocus: false,
          color: (isBooked(sl.dateTime, entity.entityId) == true)
              ? Colors.cyan[300]
              : ((sl.isFull != true && isSelected(sl.dateTime) == true)
                  ? highlightColor
                  : (sl.isFull == false) ? btnDisabledolor : btnColor),

          disabledColor: Colors.grey[400],
          //textTheme: ButtonTextTheme.normal,
          //highlightColor: Colors.green,
          // highlightElevation: 10.0,
          splashColor: (sl.isFull == true) ? highlightColor : null,
          shape: (isSelected(sl.dateTime) == true)
              ? RoundedRectangleBorder(
                  borderRadius: new BorderRadius.circular(5.0),
                  // side: BorderSide(color: highlightColor),
                )
              : RoundedRectangleBorder(
                  borderRadius: new BorderRadius.circular(5.0),
                  // side: BorderSide(color: Colors.white),
                ),
          onPressed: () {
            if (isBooked(sl.dateTime, entity.entityId)) {
              print("Slot already booked");
            }
            if (sl.isFull == false) {
              setState(() {
                //unselect previously selected slot
                selectedSlot = sl;
              });
            } else
              return null;
          },
        ),
        Text(sl.currentNumber.toString() + ' booked',
            style: TextStyle(
              color: Colors.black,
              // fontWeight: FontWeight.w800,
              //fontFamily: 'Roboto',
              letterSpacing: 0.5,
              fontSize: 9.0,
              //height: 2,
            )),
      ],
    );
  }

  void bookSlot() {
    setState(() {
      _showProgressInd = true;
    });

    print(selectedSlot.dateTime);
    if (isBooked(selectedSlot.dateTime, entity.entityId)) {
      print("alreaddyyyyyyy booked, go back");
    }
    //pr.show();

    // Future.delayed(Duration(seconds: 1)).then((value) {
    //   pr.hide().whenComplete(() {
//Test - Smita
    MetaEntity meta = entity.getMetaEntity();
    bookSlotForStore(meta, selectedSlot).then((value) {
      if (value == null) {
        showFlushBar();
        print("nuuuuuuuuuuuuull token");
        return;
      } else {
        //update in global State
        _state.addBooking(value);
      }
      _token = value.getDisplayName();

      String slotTiming = selectedSlot.dateTime.hour.toString() +
          ':' +
          selectedSlot.dateTime.minute.toString();
      _state.bookings.add(value);

      showTokenAlert(context, _token, _storeName, slotTiming).then((value) {
        _returnValues(value);

        setState(() {
          bookedSlot = selectedSlot;
        });

//Update local file with new booking.

        String returnVal = value + '-' + slotTiming;
        Navigator.of(context).pop(returnVal);
        // print(value);
      });
    }).catchError((error, stackTrace) {
      print("Error in token booking" + error.toString());
      showFlushBar();
    });
  }

  void showFlushBar() {
    Flushbar(
      //padding: EdgeInsets.zero,
      margin: EdgeInsets.zero,
      flushbarPosition: FlushbarPosition.BOTTOM,
      flushbarStyle: FlushbarStyle.FLOATING,
      reverseAnimationCurve: Curves.decelerate,
      forwardAnimationCurve: Curves.easeInToLinear,
      backgroundColor: Colors.blueGrey[500],
      boxShadows: [
        BoxShadow(
            color: primaryAccentColor,
            offset: Offset(0.0, 2.0),
            blurRadius: 3.0)
      ],
      isDismissible: false,
      duration: Duration(seconds: 6),
      icon: Icon(
        Icons.error,
        color: Colors.blueGrey[50],
      ),
      showProgressIndicator: false,
      progressIndicatorBackgroundColor: Colors.blueGrey[800],
      routeBlur: 10.0,
      titleText: Text(
        "Oops! Couldn't book the token.",
        style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16.0,
            color: primaryAccentColor,
            fontFamily: "ShadowsIntoLightTwo"),
      ),
      messageText: Text(
        " This could be because you already have an active booking for same time.",
        style: TextStyle(
            fontSize: 12.0,
            color: Colors.blueGrey[50],
            fontFamily: "ShadowsIntoLightTwo"),
      ),
    )..show(context);
  }

  void _returnValues(String value) async {
    //Load details from local files
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('tokenNum', value);
  }
}
