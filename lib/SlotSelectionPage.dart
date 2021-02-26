import 'package:auto_size_text/auto_size_text.dart';
import 'package:flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import 'package:noq/db/db_model/entity.dart';
import 'package:noq/db/db_model/meta_entity.dart';
import 'package:noq/db/db_model/slot.dart';
import 'package:noq/db/exceptions/slot_full_exception.dart';
import 'package:noq/db/exceptions/token_already_exists_exception.dart';
import 'package:noq/global_state.dart';
import 'package:noq/pages/applications_list.dart';
import 'package:noq/pages/covid_token_booking_form.dart';
import 'package:noq/pages/search_child_entity_page.dart';
import 'package:noq/pages/search_entity_page.dart';
import 'package:noq/pages/favs_list_page.dart';

import 'package:noq/pages/token_alert.dart';
import 'package:noq/repository/slotRepository.dart';
import 'package:noq/style.dart';
import 'package:noq/utils.dart';
import 'package:noq/widget/appbar.dart';
import 'package:noq/widget/header.dart';
import 'package:noq/widget/weekday_selector.dart';
import 'package:noq/widget/widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import 'package:noq/constants.dart';

class SlotSelectionPage extends StatefulWidget {
  final MetaEntity metaEntity;
  final DateTime dateTime;
  final String forPage;

  SlotSelectionPage(
      {Key key,
      @required this.metaEntity,
      @required this.dateTime,
      @required this.forPage})
      : super(key: key);

  @override
  _SlotSelectionPageState createState() => _SlotSelectionPageState();
}

class _SlotSelectionPageState extends State<SlotSelectionPage> {
  bool _initCompleted = false;
  String errMsg;
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
  GlobalState _gs;
  bool _gsInitFinished = false;
  MetaEntity metaEn;
  MetaEntity entity;
  Entity parentEntity;
  DateTime currDateTime = DateTime.now();
  DateTime slotSelectionDate;

  @override
  void initState() {
    entity = widget.metaEntity;
    _date = widget.dateTime;
    _storeId = entity.entityId;
    _storeName = entity.name;

    slotSelectionDate = _date;

    super.initState();
    if (entity.parentId != null) {
      getEntityDetails(entity.parentId).then((value) => parentEntity = value);
    }
    getGlobalState().whenComplete(() => _loadSlots(_date));
  }

  Future<void> _loadSlots(DateTime datetime) async {
    //Format date to display in UI
    final dtFormat = new DateFormat(dateDisplayFormat);
    _dateFormatted = dtFormat.format(datetime);

    //Fetch details from server
    getSlotsListForEntity(entity, datetime).then((slotList) {
      setState(() {
        _slotList = slotList;
        _initCompleted = true;
      });
    }).catchError((onError) {
      switch (onError.code) {
        case 'unavailable':
          setState(() {
            _initCompleted = true;
            errMsg = "No Internet Connection. Please check and try again.";
          });
          break;

        default:
          setState(() {
            _initCompleted = true;
            errMsg =
                'Oops, something went wrong. Check your internet connection and try again.';
          });
          break;
      }
    });
  }

  Future<void> getGlobalState() async {
    _gs = await GlobalState.getGlobalState();
    _gsInitFinished = true;
  }

  Widget _noSlotsPage(String msg) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.light().copyWith(),
      home: WillPopScope(
        child: Scaffold(
          drawer: CustomDrawer(
            phone: _gs.getCurrentUser().ph,
          ),
          appBar: CustomAppBar(
            titleTxt: title,
          ),
          body: Center(
              child: Center(
                  child: Container(
            margin: EdgeInsets.fromLTRB(10, 10, 10, 10),
            child: (msg != null) ? Text(msg) : Text(allSlotsBookedForDate),
          ))),
          // bottomNavigationBar: CustomBottomBar(
          //   barIndex: 3,
          // ),
        ),
        onWillPop: () async {
          return true;
        },
      ),
    );
  }

  Future<Entity> getEntityDetails(String id) async {
    var tup = await _gs.getEntity(id);
    if (tup != null) {
      return tup.item1;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    if (_initCompleted) {
      if (Utils.isNullOrEmpty(_slotList))
        return _noSlotsPage(errMsg);
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

        return MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: ThemeData.light().copyWith(),
          home: WillPopScope(
            child: Scaffold(
              drawer: CustomDrawer(
                phone: _gs.getCurrentUser().ph,
              ),
              body: Padding(
                padding: const EdgeInsets.fromLTRB(6, 26, 6, 6),
                child: Container(
                  decoration: BoxDecoration(
                      border: Border.all(color: borderColor),
                      color: Colors.white,
                      shape: BoxShape.rectangle,
                      borderRadius: BorderRadius.all(Radius.circular(5.0))),
                  child: Column(
                    children: <Widget>[
                      Container(
                        height: MediaQuery.of(context).size.width * .15,
                        padding: EdgeInsets.fromLTRB(6, 0, 0, 0),
                        decoration: darkContainer,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            //verticalSpacer,

                            Container(
                              width: MediaQuery.of(context).size.width * .16,
                              child: FlatButton(
                                padding: EdgeInsets.all(0),
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.arrow_back_ios,
                                      size: 20,
                                      color: (slotSelectionDate
                                                  .compareTo(currDateTime) >=
                                              0)
                                          ? Colors.white
                                          : Colors.blueGrey[300],
                                    ),
                                    Text("Prev",
                                        style: TextStyle(
                                            color: (slotSelectionDate.compareTo(
                                                        currDateTime) >=
                                                    0)
                                                ? Colors.white
                                                : Colors.blueGrey[300])),
                                  ],
                                ),
                                onPressed: () {
                                  print(slotSelectionDate
                                      .compareTo(currDateTime));
                                  if (slotSelectionDate
                                          .compareTo(currDateTime) >=
                                      0) {
                                    slotSelectionDate = slotSelectionDate
                                        .subtract(Duration(days: 1));
                                    _loadSlots(slotSelectionDate);
                                  } else {
                                    Utils.showMyFlushbar(
                                        context,
                                        Icons.info,
                                        Duration(seconds: 4),
                                        "You cannot book for past date!",
                                        "");
                                  }

                                  //Navigator.pop(context);
                                },
                              ),
                            ),
                            //  SizedBox(width: 10),
                            Wrap(
                              children: [
                                SizedBox(
                                  width:
                                      MediaQuery.of(context).size.width * .52,
                                  // height: MediaQuery.of(context).size.width * .11,
                                  child: (selectedSlot == null)
                                      ? AutoSizeText(
                                          "Select from available slots on " +
                                              _dateFormatted +
                                              ".",
                                          minFontSize: 8,
                                          style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 13),
                                        )
                                      : (isBooked(selectedSlot.dateTime,
                                              entity.entityId))
                                          ? AutoSizeText(
                                              'You already have a booking at $bookingTime on $bookingDate',
                                              minFontSize: 8,
                                              style: TextStyle(
                                                  color: primaryAccentColor,
                                                  fontSize: 13),
                                            )
                                          : AutoSizeText(
                                              'You selected a slot at $bookingTime on $bookingDate',
                                              minFontSize: 8,
                                              maxFontSize: 13,
                                              style: TextStyle(
                                                color: highlightColor,
                                              ),
                                            ),
                                ),
                              ],
                            ),

                            Container(
                              width: MediaQuery.of(context).size.width * .16,
                              alignment: Alignment.centerRight,
                              child: FlatButton(
                                padding: EdgeInsets.all(0),
                                child: Row(
                                  children: [
                                    Text("Next",
                                        style: TextStyle(
                                          color: (slotSelectionDate
                                                      .add(Duration(days: 1))
                                                      .compareTo(currDateTime
                                                          .add(Duration(
                                                              days: entity
                                                                  .advanceDays))) >=
                                                  0)
                                              ? Colors.blueGrey[300]
                                              : Colors.white,
                                        )),
                                    Icon(
                                      Icons.arrow_forward_ios,
                                      size: 20,
                                      color: (slotSelectionDate
                                                  .add(Duration(days: 1))
                                                  .compareTo(currDateTime.add(
                                                      Duration(
                                                          days: entity
                                                              .advanceDays))) >=
                                              0)
                                          ? Colors.blueGrey[300]
                                          : Colors.white,
                                    ),
                                  ],
                                ),
                                onPressed: () {
                                  print("Printn nextttt");
                                  print(currDateTime);
                                  print(entity.advanceDays);
                                  if (slotSelectionDate
                                          .add(Duration(days: 1))
                                          .compareTo(currDateTime.add(Duration(
                                              days: entity.advanceDays))) >=
                                      0) {
                                    Utils.showMyFlushbar(
                                        context,
                                        Icons.info,
                                        Duration(seconds: 4),
                                        "You cannot book beyond allowed advance days!",
                                        "");

                                    print("Gretaer than 0");
                                  } else {
                                    slotSelectionDate = slotSelectionDate
                                        .add(Duration(days: 1));
                                    _loadSlots(slotSelectionDate);
                                  }

                                  // print(slotSelectionDate
                                  //     .add(Duration(days: metaEn.advanceDays))
                                  //     .toString());
                                  // print((currDateTime
                                  //         .add(Duration(
                                  //             days: metaEn.advanceDays))
                                  //         .compareTo(slotSelectionDate) <=
                                  //     0));

                                  print(slotSelectionDate);
                                  //Navigator.pop(context);
                                },
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
                        height: MediaQuery.of(context).size.height * .17,
                        padding: EdgeInsets.all(4),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: <Widget>[
                            //TODO Smita - This is for taking no. of users accompanying in one booking.
                            //DONT DELETE
                            // Row(
                            //   mainAxisAlignment: MainAxisAlignment.center,
                            //   crossAxisAlignment: CrossAxisAlignment.center,
                            //   children: <Widget>[
                            //     SizedBox(
                            //       width:
                            //           MediaQuery.of(context).size.width * .06,
                            //       height:
                            //           MediaQuery.of(context).size.width * .06,
                            //       child: IconButton(
                            //           padding: EdgeInsets.zero,
                            //           icon: Icon(Icons.add),
                            //           alignment: Alignment.center,
                            //           onPressed: null),
                            //     ),
                            //     SizedBox(
                            //       width:
                            //           MediaQuery.of(context).size.width * .68,
                            //       height:
                            //           MediaQuery.of(context).size.width * .06,
                            //       child: RaisedButton(
                            //         // elevation: 10.0,
                            //         color: Colors.white,
                            //         splashColor: Colors.orangeAccent[700],
                            //         textColor: Colors.white,
                            //         child: Text(
                            //           'Kitne aadmi hai Sambha!!',
                            //           style: TextStyle(fontSize: 20),
                            //         ),
                            //         onPressed: () {},
                            //       ),
                            //     ),
                            //     SizedBox(
                            //       width:
                            //           MediaQuery.of(context).size.width * .06,
                            //       height:
                            //           MediaQuery.of(context).size.width * .06,
                            //       child: IconButton(
                            //           padding: EdgeInsets.zero,
                            //           icon: Icon(Icons.remove),
                            //           alignment: Alignment.center,
                            //           onPressed: null),
                            //     ),
                            //   ],
                            // ),
                            // SizedBox(
                            //   height: 10,
                            // ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: <Widget>[
                                SizedBox(
                                  width: MediaQuery.of(context).size.width * .3,
                                  // height:
                                  //     MediaQuery.of(context).size.height * .06,
                                  child: RaisedButton(
                                    elevation: 0.0,
                                    color: Colors.white,
                                    shape: RoundedRectangleBorder(
                                        side: BorderSide(
                                            color: Colors.blueGrey[500]),
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(5.0))),
                                    splashColor: highlightColor,
                                    child: Text(
                                      'Cancel',
                                      style: TextStyle(
                                        color: btnColor,
                                        fontWeight: FontWeight.w700,
                                        fontFamily: 'Montserrat',

                                        fontSize: 15,
                                        //height: 2,
                                      ),
                                    ),
                                    onPressed: () {
                                      Navigator.of(context).pop();
                                    },
                                  ),
                                ),
                                SizedBox(
                                  width: 10,
                                ),
                                SizedBox(
                                  width: MediaQuery.of(context).size.width * .3,
                                  // height:
                                  //     MediaQuery.of(context).size.height * .06,
                                  child: RaisedButton(
                                    elevation: 10.0,
                                    color: btnColor,
                                    splashColor: highlightColor,
                                    shape: RoundedRectangleBorder(
                                        side: BorderSide(
                                            color: Colors.blueGrey[500]),
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(5.0))),
                                    child: Text(
                                      'Ok',
                                      style: buttonMedTextStyle,
                                    ),
                                    onPressed: () {
                                      Navigator.of(context)
                                          .pop(slotSelectionDate);
                                    },
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
                                      color: greenColor, size: 15),
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
            ),
            onWillPop: () async {
              return true;
            },
          ),
        );
      }
    } else {
      return MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData.light().copyWith(),
        home: WillPopScope(
          child: Scaffold(
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
                    valueColor: AlwaysStoppedAnimation<Color>(highlightColor),
                    strokeWidth: 3,
                  )
                ],
              ),
            ),
            //drawer: CustomDrawer(),
            //  bottomNavigationBar: CustomBottomBar(barIndex: 1)
          ),
          onWillPop: () async {
            return true;
          },
        ),
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
    if (_gs.bookings == null) {
      return false;
    }

    for (int i = 0; i < _gs.bookings.length; i++) {
      if (_gs.bookings[i].parent.entityId == entityId &&
          _gs.bookings[i].parent.dateTime == dateTime) {
        if (_gs.bookings[i].number != -1) return true;
      }
    }
    return false;
  }

  bool isDisabled(DateTime dateTime) {
    bool isDisabled = dateTime.isBefore(currDateTime);
    return isDisabled;
  }

  Widget _buildGridItem(BuildContext context, int index) {
    //TODO: Check what information coming from server, then process and use it.
    Slot sl = _slotList[index];
    String hrs = Utils.formatTime(sl.dateTime.hour.toString());
    String mnts = Utils.formatTime(sl.dateTime.minute.toString());
    bool isBookedFlg = isBooked(sl.dateTime, entity.entityId);
    return Column(
      children: <Widget>[
        Container(
          child: RaisedButton(
            elevation: (isDisabled(sl.dateTime))
                ? 0
                : ((isSelected(sl.dateTime) == true) ? 0.0 : 10.0),
            padding: EdgeInsets.all(2),
            child: Text(
              hrs + ':' + mnts,
              style: TextStyle(
                fontSize: 12,
                color: isDisabled(sl.dateTime)
                    ? Colors.grey[500]
                    : (isBookedFlg ? Colors.white : primaryDarkColor),
                // textDirection: TextDirection.ltr,
                // textAlign: TextAlign.center,
              ),
            ),

            autofocus: false,
            color: (isDisabled(sl.dateTime))
                ? disabledColor
                : ((isBookedFlg)
                    ? Colors.greenAccent[700]
                    : ((sl.isFull != true && isSelected(sl.dateTime) == true)
                        ? highlightColor
                        : (sl.isFull == false)
                            ? Colors.cyan[50]
                            : btnDisabledolor)),

            disabledColor: Colors.grey[200],
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
              if (!isDisabled(sl.dateTime)) {
//Check if booking form is required then take request else show form.
                // if (Utils.isNotNullOrEmpty(entity.forms)) {
                //   //Show Booking request form
                //   Navigator.push(
                //       context,
                //       MaterialPageRoute(
                //           builder: (context) => CovidTokenBookingFormPage(
                //                 metaEntity: entity,
                //                 bookingFormId: entity.bookingFormId,
                //                 preferredSlotTime: sl.dateTime,
                //               )));
                // } else
                {
                  if (isBooked(sl.dateTime, entity.entityId)) {
                    Utils.showMyFlushbar(
                        context,
                        Icons.info_outline,
                        Duration(seconds: 6),
                        alreadyHaveBooking,
                        wantToBookAnotherSlot);
                    return null;
                  }
                  if (sl.isFull == false) {
                    setState(() {
                      //unselect previously selected slot
                      selectedSlot = sl;
                    });
                  } else
                    return null;
                }
              } else
                return null;
            },
          ),
        ),
        Container(
          child: Text(sl.currentNumber.toString() + ' Booked',
              style: TextStyle(
                color: Colors.black,
                // fontWeight: FontWeight.w800,
                //fontFamily: 'Roboto',
                letterSpacing: 0.5,
                fontSize: 7.0,
                //height: 2,
              )),
        ),
      ],
    );
  }

  void bookSlot() {
    _gs.initializeNotification();

    Utils.showMyFlushbar(
        context,
        Icons.info_outline,
        Duration(
          seconds: 3,
        ),
        slotBooking,
        takingMoment);

    print(selectedSlot.dateTime);
    if (isBooked(selectedSlot.dateTime, entity.entityId)) {
      print("alreaddyyyyyyy booked, go back");
    }

    MetaEntity meta = entity;

    bookSlotForStore(meta, selectedSlot).then((value) {
      if (value == null) {
        showFlushBar();
        return;
      } else {
        //update in global State
        selectedSlot.currentNumber++;
      }
      _token = value.getDisplayName();

      String slotTiming =
          Utils.formatTime(selectedSlot.dateTime.hour.toString()) +
              ':' +
              Utils.formatTime(selectedSlot.dateTime.minute.toString());

      showTokenAlert(context, _token, _storeName, slotTiming).then((value) {
        _returnValues(value);

        setState(() {
          bookedSlot = selectedSlot;
          selectedSlot = null;
        });
        //Ask user if he wants to receive the notifications

        //End of notification permission

//Update local file with new booking.

        String returnVal = value + '-' + slotTiming;
        // Navigator.of(context).pop(returnVal);
        // print(value);
      });
    }).catchError((error, stackTrace) {
      print("Error in token booking" + error.toString());

      //TODO Smita - Not going in any of if bcoz exception is wrapped in type platform exception.
      if (error is SlotFullException) {
        Utils.showMyFlushbar(context, Icons.error, Duration(seconds: 5),
            couldNotBookToken, slotsAlreadyBooked);
      } else if (error is TokenAlreadyExistsException) {
        Utils.showMyFlushbar(context, Icons.error, Duration(seconds: 5),
            couldNotBookToken, tokenAlreadyExists);
      } else {
        Utils.showMyFlushbar(context, Icons.error, Duration(seconds: 5),
            couldNotBookToken, tryAgainToBook);
      }
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
        couldNotBookToken,
        style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16.0,
            color: primaryAccentColor,
            fontFamily: "ShadowsIntoLightTwo"),
      ),
      messageText: Text(
        tokenAlreadyExists,
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
