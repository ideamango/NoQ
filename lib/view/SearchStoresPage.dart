import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:noq/models/localDB.dart';
import 'package:noq/repository/StoreRepository.dart';
import 'package:noq/style.dart';
import 'package:noq/utils.dart';

class SearchStoresPage extends StatefulWidget {
  @override
  _SearchStoresPageState createState() => _SearchStoresPageState();
}

class _SearchStoresPageState extends State<SearchStoresPage> {
  bool isFavourited = false;
  DateTime dateTime = DateTime.now();
  final dtFormat = new DateFormat('dd');

  List<DateTime> _dateList = new List<DateTime>();

  void _prepareDateList() {
    _dateList.clear();
    _dateList.add(dateTime);
    DateTime dt = DateTime.now();
    for (int i = 1; i <= 4; i++) {
      print(i);
      _dateList.add(dt.add(Duration(days: i)));
      print('dateLIst is $_dateList');
    }
  }

  void modifyStoreList(StoreAppData strData) {}
  void toggleFavorite(StoreAppData strData) {
    setState(() {
      isFavourited = !isFavourited;
      if (strData.isFavourite == true) {
        // (_userProfile as UserAppData).favStores.add(strData);
      }
      // widget.onFavoriteChanged(isFavourited);
    });
    modifyStoreList(strData);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      builder: (BuildContext context, AsyncSnapshot snapshot) {
        List<Widget> childrenView;
        if (snapshot.hasData) {
          List<StoreAppData> _stores = snapshot.data;
          childrenView = <Widget>[
            Container(
              margin: EdgeInsets.fromLTRB(10, 10, 10, 10),
              // child: Text("Store List $_stores"),
              child: ListView.builder(
                  itemCount: _stores.length,
                  itemBuilder: (BuildContext context, int index) {
                    return Container(
                      child: new Column(
                          children: _stores.map(_buildItem).toList()),
                      //children: <Widget>[firstRow, secondRow],
                    );
                  }),
            )
          ];
        } else if (snapshot.hasError) {
          childrenView = <Widget>[
            Text('Got error!!'),
          ];
        } else {
          childrenView = <Widget>[
            SizedBox(
              child: CircularProgressIndicator(
                backgroundColor: Colors.blue,
              ),
              width: 60,
              height: 60,
            ),
            const Padding(
              padding: EdgeInsets.only(top: 16),
              child: Text('Awaiting result...'),
            )
          ];
        }
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: childrenView,
          ),
        );
      },
      future: getStoreDetails(),
    );
  }

  Future getStoreDetails() async {
    List<StoreAppData> _stores = getDummyList();
    return _stores;
  }

  Widget _buildItem(StoreAppData str) {
    //_buildDateGridItems(str.id);
    print('after buildDateGrid called');
    return Container(child: Text("Store List $str.name"));
    // return Card(
    //     elevation: 10,
    //     child: new Row(
    //       crossAxisAlignment: CrossAxisAlignment.start,
    //       mainAxisAlignment: MainAxisAlignment.spaceBetween,
    //       children: <Widget>[
    //         Column(
    //           children: <Widget>[
    //             new Container(
    //               margin: EdgeInsets.fromLTRB(10, 10, 5, 5),
    //               padding: EdgeInsets.all(5),
    //               alignment: Alignment.topCenter,
    //               decoration: ShapeDecoration(
    //                 shape: CircleBorder(),
    //                 color: darkIcon,
    //               ),
    //               child: Icon(
    //                 Icons.shopping_cart,
    //                 color: Colors.white,
    //                 size: 20,
    //               ),
    //             )
    //           ],
    //         ),
    //         Column(children: <Widget>[
    //           Row(
    //               crossAxisAlignment: CrossAxisAlignment.start,
    //               mainAxisAlignment: MainAxisAlignment.start,
    //               children: [
    //                 new Container(
    //                   padding: EdgeInsets.fromLTRB(10.0, 5.0, 0, 0),
    //                   child: Column(
    //                     crossAxisAlignment: CrossAxisAlignment.start,
    //                     mainAxisAlignment: MainAxisAlignment.spaceEvenly,
    //                     children: [
    //                       Container(
    //                         padding: EdgeInsets.fromLTRB(0, 5, 5, 5),
    //                         child: Column(
    //                             crossAxisAlignment: CrossAxisAlignment.start,
    //                             mainAxisAlignment: MainAxisAlignment.start,
    //                             children: [
    //                               Row(
    //                                 mainAxisAlignment:
    //                                     MainAxisAlignment.spaceBetween,
    //                                 // crossAxisAlignment: CrossAxisAlignment.center,
    //                                 children: <Widget>[
    //                                   Text(
    //                                     str.name.toString(),
    //                                   ),
    //                                 ],
    //                               ),
    //                               Row(
    //                                 mainAxisAlignment: MainAxisAlignment.end,
    //                                 crossAxisAlignment:
    //                                     CrossAxisAlignment.start,
    //                                 children: <Widget>[
    //                                   Text(
    //                                     str.adrs,
    //                                   ),
    //                                 ],
    //                               )
    //                             ]),
    //                       ),
    //                       Container(
    //                         width: MediaQuery.of(context).size.width * .5,
    //                         //padding: EdgeInsets.fromLTRB(0, 5, 5, 5),
    //                         child: Row(
    //                           children: _buildDateGridItems(
    //                               str.id, str.name, str.daysClosed),
    //                         ),
    //                       ),
    //                       Row(
    //                           mainAxisAlignment: MainAxisAlignment.center,
    //                           crossAxisAlignment: CrossAxisAlignment.start,
    //                           children: [
    //                             Row(
    //                               //mainAxisAlignment: MainAxisAlignment.spaceEvenly,
    //                               children: [
    //                                 //Icon(Icons.play_circle_filled, color: Colors.blueGrey[300]),
    //                                 Text('Opens at:', style: labelTextStyle),
    //                                 Text(str.opensAt, style: lightSubTextStyle),
    //                               ],
    //                             ),
    //                             Container(child: Text('   ')),
    //                             Row(
    //                               children: [
    //                                 //Icon(Icons.pause_circle_filled, color: Colors.blueGrey[300]),
    //                                 Text('Closes at:', style: labelTextStyle),
    //                                 Text(str.closesAt,
    //                                     style: lightSubTextStyle),
    //                               ],
    //                             ),
    //                           ]),
    //                     ],
    //                   ),
    //                 ),
    //               ]),
    //         ]),
    //         Column(
    //             mainAxisAlignment: MainAxisAlignment.spaceBetween,
    //             children: <Widget>[
    //               Container(
    //                 margin: EdgeInsets.fromLTRB(0, 0, 10, 0),
    //                 height: 22,
    //                 width: 20,
    //                 child: IconButton(
    //                   alignment: Alignment.topRight,
    //                   //padding: EdgeInsets.all(2),
    //                   onPressed: () => toggleFavorite(str),
    //                   highlightColor: Colors.orange[300],
    //                   iconSize: 16,
    //                   icon: !isFavourited
    //                       ? Icon(
    //                           Icons.star,
    //                           color: darkIcon,
    //                         )
    //                       : Icon(
    //                           Icons.star_border,
    //                           color: darkIcon,
    //                         ),
    //                 ),
    //               ),
    //               Container(
    //                 //margin: EdgeInsets.fromLTRB(20, 10, 5, 5),

    //                 height: 22.0,
    //                 width: 20.0,

    //                 child: IconButton(
    //                     // padding: EdgeInsets.all(2),
    //                     //iconSize: 14,
    //                     alignment: Alignment.centerRight,
    //                     highlightColor: Colors.orange[300],
    //                     icon: Icon(
    //                       Icons.location_on,
    //                       color: darkIcon,
    //                       size: 20,
    //                     ),
    //                     onPressed: () => {}
    //                     //   launchURL(str.name, str.adrs, str.lat, str.long),
    //                     ),
    //               ),
    //             ]),
    //       ],
    //     ));
  }

  void showSlots(String storeId, String storeName, DateTime dateTime) {
    //_prefs = await SharedPreferences.getInstance();
    String dateForSlot = dateTime.toString();

    // _prefs.setString("storeName", storeName);
    // _prefs.setString("storeIdForSlots", storeId);
    // _prefs.setString("dateForSlot", dateForSlot);
    // getSlotsForStore(storeId, dateTime).then((slotsList) {
    //   showSlotsDialog(context, slotsList, dateTime);
    // });
  }

  List<Widget> _buildDateGridItems(
      String sid, String sname, List<String> daysClosed) {
    bool isClosed = false;
    String dayOfWeek;

    var dateWidgets = List<Widget>();
    for (var date in _dateList) {
      isClosed = (daysClosed.contains(date.weekday.toString())) ? true : false;
      dayOfWeek = Utils.getDayOfWeek(date);
      dateWidgets.add(buildDateItem(sid, sname, isClosed, date, dayOfWeek));
      print('Widget build from datelist  called');
    }
    return dateWidgets;
  }

  Widget buildDateItem(
      String sid, String sname, bool isClosed, DateTime dt, String dayOfWeek) {
    Widget dtItem = Container(
      margin: EdgeInsets.all(2),
      child: SizedBox.fromSize(
        size: Size(34, 34), // button width and height
        child: ClipOval(
          child: Material(
            color: isClosed ? Colors.grey : Colors.lightGreen, // button color
            child: InkWell(
              splashColor: isClosed ? null : highlightColor, // splash color
              onTap: () {
                if (isClosed) {
                  return null;
                } else {
                  print("tapped");
                  showSlots(sid, sname, dt);
                }
              }, // button pressed
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Text(dtFormat.format(dt),
                      style: TextStyle(fontSize: 15, color: Colors.white)),
                  Text(dayOfWeek,
                      style:
                          TextStyle(fontSize: 8, color: Colors.white)), // text
                ],
              ),
            ),
          ),
        ),
      ),
    );
    return dtItem;
  }
}
