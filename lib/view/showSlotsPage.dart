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
  String _storeId;
  DateTime _date;
  List<Slot> _slots;
  @override
  void initState() {
    super.initState();
    _loadSlots();
  }

  void _loadSlots() async {
    //Load details from local files
    SharedPreferences prefs = await SharedPreferences.getInstance();
    _storeId = prefs.getString('storeIdForSlots');
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
    return Center(
      child: Container(
        margin: EdgeInsets.fromLTRB(10, 10, 10, 10),
        child: ListView.builder(
            itemCount: _slots.length,
            itemBuilder: (BuildContext context, int index) {
              return Container(
                child: new Column(children: _slots.map(_buildItem).toList()),
                //children: <Widget>[firstRow, secondRow],
              );
            }),
      ),
    );
  }

  Widget _buildItem(Slot str) {
    return Card(
        elevation: 10,
        child: new Row(
          children: <Widget>[],
        ));
  }
}
