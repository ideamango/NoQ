import 'package:flutter/material.dart';
import 'package:noq/db/db_model/entity.dart';
import 'package:noq/db/db_model/meta_entity.dart';
import 'package:noq/db/db_model/slot.dart';
import 'package:noq/db/db_model/user_token.dart';
import 'package:noq/db/db_service/entity_service.dart';
import 'package:noq/global_state.dart';
import 'package:noq/pages/token_alert.dart';
import 'package:noq/repository/slotRepository.dart';
import 'package:noq/style.dart';
import 'package:noq/utils.dart';
import 'package:noq/widget/appbar.dart';
import 'package:noq/widget/bottom_nav_bar.dart';
import 'package:noq/widget/header.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import 'package:progress_dialog/progress_dialog.dart';

import '../constants.dart';

class ShowSlotsPage extends StatefulWidget {
  final Entity entity;
  final DateTime dateTime;
  ShowSlotsPage({Key key, @required this.entity, @required this.dateTime})
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
  ProgressDialog pr;
  String title = "Book Slot";
  GlobalState _state;
  bool _gStateInitFinished = false;
  MetaEntity metaEn;
  Entity entity;

  @override
  void initState() {
    //dt = dateFormat.format(DateTime.now());
    super.initState();
    getGlobalState().whenComplete(() => _loadSlots().whenComplete(() {
          setState(() {
            _initCompleted = true;
          });
        }));
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

        return MaterialApp(
          theme: ThemeData.light().copyWith(),
          home: Scaffold(
            drawer: CustomDrawer(),
            appBar: CustomAppBar(
              titleTxt: _storeName,
            ),
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
                            Icons.business,
                            size: 35,
                            color: Colors.white,
                          ),
                          SizedBox(width: 12),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Text(
                                _storeName,
                                style: TextStyle(
                                    color: Colors.white, fontSize: 15),
                              ),
                              Text(
                                _dateFormatted,
                                style: TextStyle(
                                  fontSize: 10,
                                  color: Colors.white,
                                ),
                              )
                            ],
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
                      height: MediaQuery.of(context).size.width * .1,
                      padding: EdgeInsets.all(4),
                      // decoration: new BoxDecoration(
                      //   border: Border.all(color: Colors.teal[200]),
                      //   shape: BoxShape.rectangle,
                      // color: Colors.cyan[100],
                      // borderRadius: BorderRadius.only(
                      //     topLeft: Radius.circular(4.0),
                      //     topRight: Radius.circular(4.0))
                      //),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          SizedBox(
                            width: MediaQuery.of(context).size.width * .5,
                            height: MediaQuery.of(context).size.width * .15,
                            child: RaisedButton(
                              elevation: (selectedSlot != null) ? 12.0 : 0.0,
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

    return RaisedButton(
      elevation: (isSelected(sl.dateTime) == true) ? 0.0 : 10.0,
      padding: EdgeInsets.all(2),
      child: Text(
        hrs + ':' + mnts,
        style: TextStyle(fontSize: 10, color: Colors.white),
        // textDirection: TextDirection.ltr,
        // textAlign: TextAlign.center,
      ),

      autofocus: false,
      color: (isBooked(sl.dateTime, entity.entityId) == true)
          ? Colors.green[200]
          : ((sl.isFull == true && isSelected(sl.dateTime) == true)
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
        if (sl.isFull == false) {
          setState(() {
            //unselect previously selected slot
            selectedSlot = sl;
          });
        } else
          return null;
      },
    );
  }

  void bookSlot() {
    setState(() {
      _showProgressInd = true;
    });

    //pr.show();

    // Future.delayed(Duration(seconds: 1)).then((value) {
    //   pr.hide().whenComplete(() {

    bookSlotForStore(metaEn, selectedSlot, _date).then((value) {
      _token = value.number.toString();
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
    });
  }

  void _returnValues(String value) async {
    //Load details from local files
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('tokenNum', value);
  }
}
