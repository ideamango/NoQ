import 'package:flutter/material.dart';
import 'package:noq/models/localDB.dart';
import 'package:noq/models/slot.dart';
import 'package:noq/repository/slotRepository.dart';

import 'package:noq/services/mapService.dart';
import 'package:noq/style.dart';
import 'package:noq/models/store.dart';
import 'package:noq/services/color.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ShowSlotsPage extends StatefulWidget {
  @override
  _ShowSlotsPageState createState() => _ShowSlotsPageState();
}

class _ShowSlotsPageState extends State<ShowSlotsPage> {
  int _storeId;
  DateTime _date;
  List<Slot> _slots;
  @override
  void initState() {
    _date = DateTime.now();
    super.initState();
    _loadSlots();
  }

  void _loadSlots() async {
    //Load details from local files
    SharedPreferences prefs = await SharedPreferences.getInstance();
    _storeId = prefs.getInt('storeIdForSlots');
    //Fetch details from server

    await getSlotsForStore(_storeId, _date).then((slotList) {
      _slots = slotList;
      if (_slots != null) {
        _buildSlotsPage();
      } else {
        _noSlotsPage();
      }
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
    if (_slots != null) {
      return _buildSlotsPage();
    } else {
      return _noSlotsPage();
    }
  }

  Widget _buildSlotsPage() {
    return AlertDialog(
      content: Container(
        color: Colors.indigo,
        height: 20.0,
        width: 20.0,
      ),
      actions: <Widget>[
        FlatButton(
          child: Text('Switch'),
          onPressed: () {},
          //  => setState(() {
          //       _c == Colors.redAccent
          //           ? _c = Colors.blueAccent
          //           : _c = Colors.redAccent;
          //     }))
        )
      ],
    );
  }

  Widget _buildItem(Slot str) {
    return Card(
        elevation: 10,
        child: new Row(
          children: <Widget>[Text(_slots[0].id)],
        ));
  }
}
