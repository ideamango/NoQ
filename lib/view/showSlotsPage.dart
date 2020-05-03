import 'package:flutter/material.dart';
import 'package:noq/models/localDB.dart';
import 'package:noq/models/slot.dart';
import 'package:noq/repository/slotRepository.dart';

import 'package:noq/services/mapService.dart';
import 'package:noq/style.dart';
import 'package:noq/models/store.dart';
import 'package:noq/services/color.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';

class ShowSlotsPage extends StatefulWidget {
  @override
  _ShowSlotsPageState createState() => _ShowSlotsPageState();
}

class _ShowSlotsPageState extends State<ShowSlotsPage> {
  String _storeId;
  String _errorMessage;
  DateTime _date;
  String dt;
  List<Slot> _slotList;
  final dateFormat = new DateFormat('dd');
  Slot selectedSlot;
  String _storeName;
  String _dateFormatted;
  @override
  void initState() {
    //dt = dateFormat.format(DateTime.now());
    super.initState();
    _loadSlots();
  }

  void _loadSlots() async {
    //Load details from local files
    SharedPreferences prefs = await SharedPreferences.getInstance();
    _storeId = prefs.getString('storeIdForSlots');
    _storeName = prefs.getString("storeName");
    _dateFormatted = prefs.getString("dateFormatted");

    //Fetch details from server

    await getSlotsForStore(_storeId, _date).then((slotList) {
      setState(() {
        _slotList = slotList;
      });
    });
  }

  Widget _noSlotsPage() {
    return Center(
        child: Center(
            child: Container(
      margin: EdgeInsets.fromLTRB(10, 10, 10, 10),
      child: Text('All slots booked for this date!!'),
    )));
  }

  @override
  Widget build(BuildContext context) {
    if (_slotList != null) {
      return new AlertDialog(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              _storeName,
              style: TextStyle(
                fontSize: 23,
                color: Colors.black,
              ),
            ),
            Text(
              _dateFormatted,
              style: TextStyle(
                fontSize: 15,
                color: Colors.indigo,
              ),
            )
          ],
        ),
        //backgroundColor: Colors.grey[200],
        titleTextStyle: labelTextStyle,
        elevation: 10.0,
        content: new Container(
          decoration: BoxDecoration(
            border: Border.all(
              color: Colors.indigo[500],
            ),
            borderRadius: BorderRadius.circular(5.0),
          ),
          width: MediaQuery.of(context).size.width * .7,
          child: Container(
              child: new GridView.builder(
            itemCount: _slotList.length,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 6, crossAxisSpacing: 4.0, mainAxisSpacing: 1.0),
            itemBuilder: (BuildContext context, int index) {
              return new GridTile(
                child: Container(
                  padding: EdgeInsets.all(4),
                  // decoration:
                  //     BoxDecoration(border: Border.all(color: Colors.black, width: 0.5)),
                  child: Center(
                    child: _buildGridItem(index),
                  ),
                ),
              );
            },
          )),
        ),

        // SizedBox(height: 10),

        actions: <Widget>[
          // FlatButton(
          //   color: Colors.orange,
          //   textColor: Colors.white,
          //   child: Text('Clear All'),
          //   onPressed: () {
          //     setState(() {
          //       selectedSlot = null;
          //     });
          //   },
          // ),
          RaisedButton(
            elevation: 12.0,
            color: (selectedSlot != null) ? Colors.orange : Colors.grey,
            textColor: Colors.white,
            child: Text('Book Slot'),
            onPressed: bookSlot,
          ),
          (_errorMessage != null
              ? Text(
                  _errorMessage,
                  style: TextStyle(color: Colors.red),
                )
              : Container()),
        ],
      );
    } else {
      return _noSlotsPage();
    }
  }

  Widget _buildGridItem(int index) {
    Slot sl = _slotList[index];

    return RaisedButton(
      elevation: (sl.slotSelected == "true") ? 5.0 : 10.0,
      padding: EdgeInsets.all(2),
      child: Text(
        sl.slotStrTime,
        style: TextStyle(fontSize: 10, color: Colors.white),
        // textDirection: TextDirection.ltr,
        // textAlign: TextAlign.center,
      ),

      autofocus: false,
      color: (sl.slotAvlFlg == "true" && sl.slotSelected == "true")
          ? highlightColor
          : (sl.slotAvlFlg == "false") ? Colors.grey : Colors.indigo,
      textColor: Colors.indigo[800],
      disabledColor: Colors.grey,
      //textTheme: ButtonTextTheme.normal,
      //highlightColor: Colors.green,
      // highlightElevation: 10.0,
      splashColor: (sl.slotAvlFlg == "true") ? highlightColor : null,
      shape: (sl.slotSelected == "true")
          ? RoundedRectangleBorder(
              borderRadius: new BorderRadius.circular(5.0),
              side: BorderSide(color: highlightColor),
            )
          : RoundedRectangleBorder(
              borderRadius: new BorderRadius.circular(5.0),
              side: BorderSide(color: Colors.white),
            ),
      onPressed: () {
        if (sl.slotAvlFlg == "true") {
          setState(() {
            //unselect previously selected slot
            _slotList.forEach((element) => element.slotSelected = "false");

            sl.slotSelected = "true";
            selectedSlot = sl;
          });

          print(sl.slotStrTime);
          print(sl.slotSelected);
        } else
          return null;
      },
    );
  }

  void bookSlot() {
    // final f = new DateFormat('yyyy-MM-dd hh:mm');
    print(selectedSlot.slotStrTime);
    String strDate = new DateFormat.yMMMd().format(new DateTime.now());
    print(strDate);
    DateTime d = DateTime.parse(strDate);
    print(d);
  }
}
