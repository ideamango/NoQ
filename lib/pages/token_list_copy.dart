import 'dart:collection';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../constants.dart';
import '../db/db_model/meta_entity.dart';
import '../db/db_model/slot.dart';
import '../db/db_model/user_token.dart';
import '../db/db_service/token_service.dart';
import '../global_state.dart';
import '../pages/bar_chart_graph.dart';
import '../pages/bar_chart_tokens.dart';
import '../pages/manage_entity_list_page.dart';
import '../pages/overview_page.dart';
import '../repository/slotRepository.dart';
import '../services/circular_progress.dart';
import '../services/month_picker_dialog.dart';
import '../style.dart';
import '../userHomePage.dart';
import '../utils.dart';
import '../widget/appbar.dart';
import '../widget/page_animation.dart';

enum SelectedView { list, bar, pie, line }
enum DateDisplayFormat { date, month, year }

class EntityTokenListPage extends StatefulWidget {
  final MetaEntity metaEntity;
  final dynamic backRoute;
  EntityTokenListPage(
      {Key key, @required this.metaEntity, @required this.backRoute})
      : super(key: key);
  @override
  _EntityTokenListPageState createState() => _EntityTokenListPageState();
}

class _EntityTokenListPageState extends State<EntityTokenListPage> {
  bool initCompleted = false;
  bool loadingData = true;
  GlobalState _gs;
  List<Slot> list = List<Slot>();
  Map<String, TokenStats> dataForDay = new Map<String, TokenStats>();
  Map<String, TokenStats> dataForMonth = Map<String, TokenStats>();
  Map<String, TokenStats> dataForYear = new Map<String, TokenStats>();
  String formattedDateStr;
  DateTime dateForShowingList;
  DateTime yearForShowingList;
  DateTime monthForShowingList;
  String weekForShowingList;
  Map<String, List<UserToken>> _tokensMap = new Map<String, List<UserToken>>();
  Map<String, TokenStats> dataMap = new Map<String, TokenStats>();
  DateDisplayFormat selectedDateFormat = DateDisplayFormat.date;
  SelectedView selectedView = SelectedView.list;
  Widget listWidget;
  Widget barChartWidget;
  DateTime defaultDate;
  //final _key = GlobalKey();

  TokenCounter tokenCounterForYear;
  @override
  void initState() {
    super.initState();
    defaultDate = DateTime.now();

    getGlobalState().whenComplete(() {
      dateForShowingList = defaultDate;
      getListOfData(dateForShowingList).then((value) {
        _gs
            .getTokenService()
            .getTokenCounterForEntity(
                widget.metaEntity.entityId, defaultDate.year.toString())
            .then((value) {
          tokenCounterForYear = value;
          prepareData(DateTime.now(), DateDisplayFormat.date);
          if (this.mounted) {
            setState(() {
              initCompleted = true;
            });
          } else
            initCompleted = true;
        });
      });
    });
  }

  Future<void> getGlobalState() async {
    _gs = await GlobalState.getGlobalState();
  }

  Future<void> loadEntireYearData(String forYear) async {
    _gs
        .getTokenService()
        .getTokenCounterForEntity(widget.metaEntity.entityId, forYear)
        .then((value) {
      tokenCounterForYear = value;
    });
  }

  // Future<void> getListOfData(DateTime date, DateDisplayFormat format) async {
  //   switch (format) {
  //     case DateDisplayFormat.date:
  //       list = await getSlotsListForEntity(widget.metaEntity, date);
  //       for (int i = 0; i <= list.length - 1; i++) {
  //         List<UserToken> tokensForThisSlot =
  //             await _gs.getTokenService().getAllTokensForSlot(list[i].slotId);
  //         if (!Utils.isNullOrEmpty(tokensForThisSlot))
  //           _tokensMap[list[i].slotId] = tokensForThisSlot;
  //         dataMap[Utils.formatTime(list[i].dateTime.hour.toString()) +
  //                 ":" +
  //                 Utils.formatTime(list[i].dateTime.minute.toString())] =
  //             tokensForThisSlot.length;
  //       }

  //       break;
  //     case DateDisplayFormat.month:
  //       dataForMonth = tokenCounterForYear.getTokenStatsDayWiseForMonth(date.month);
  //       print(dataForMonth.length);
  //       break;
  //     case DateDisplayFormat.year:
  //       loadEntireYearData(date.year.toString()).then((value) {});
  //       break;
  //     default:
  //       break;
  //   }

  // Future<void> getListOfDataForMonth(DateTime date) async {
  //   list = await getSlotsListForEntity(widget.metaEntity, date);
  //   for (int i = 0; i <= list.length - 1; i++) {
  //     List<UserToken> tokensForThisSlot =
  //         await _gs.getTokenService().getAllTokensForSlot(list[i].slotId);
  //     if (!Utils.isNullOrEmpty(tokensForThisSlot))
  //       _tokensMap[list[i].slotId] = tokensForThisSlot;
  //     // dataMap[Utils.formatTime(list[i].dateTime.hour.toString()) +
  //     //         ":" +
  //     //         Utils.formatTime(list[i].dateTime.minute.toString())] =
  //     //     tokensForThisSlot.length;
  //   }
  //   setState(() {
  //     loadingData = false;
  //   });

  //   return list;
  // }

  // Future<void> getListOfDataForYear(DateTime year) async {
  //   //TODO Smita: Get time-slots vs booked tokens for the entire year.

  //   //Dummy data for testing- start

  //   list = await getSlotsListForEntity(widget.metaEntity, dateForShowingList);
  //   for (int i = 0; i <= list.length - 1; i++) {
  //     List<UserToken> tokensForThisSlot =
  //         await _gs.getTokenService().getAllTokensForSlot(list[i].slotId);
  //     if (!Utils.isNullOrEmpty(tokensForThisSlot))
  //       _tokensMap[list[i].slotId] = tokensForThisSlot;
  //     // dataMap[Utils.formatTime(list[i].dateTime.hour.toString()) +
  //     //         ":" +
  //     //         Utils.formatTime(list[i].dateTime.minute.toString())] =
  //     //     tokensForThisSlot.length;
  //   }

  //   // dataMap[Utils.formatTime() + ":" + Utils.formatTime()] =
  //   //     tokensForThisSlot.length;
  //   //Dummy data for testing- end

  //   setState(() {
  //     loadingData = false;
  //   });

  //   //return list;
  // }

  void prepareData(DateTime date, DateDisplayFormat format) {
    String formattedDate;
    dataMap.clear();
    dataForDay.clear();
    dataForMonth.clear();
    dataForYear.clear();
    barChartWidget = _emptyPage();
    setState(() {});

    switch (format) {
      case DateDisplayFormat.date:
        //Set display Date
        formattedDate = DateFormat(dateDisplayFormat).format(date);
        //Fetch data of a day - which will be sorted based on time-slots
        if (tokenCounterForYear != null) {
          if (tokenCounterForYear.year != date.year.toString()) {
            _gs
                .getTokenService()
                .getTokenCounterForEntity(
                    widget.metaEntity.entityId, date.year.toString())
                .then((value) {
              tokenCounterForYear = value;
              if (tokenCounterForYear == null) {
                //show empty page
                listWidget = _emptyPage();
                barChartWidget = _emptyPage();
                setState(() {
                  formattedDateStr = formattedDate;
                  loadingData = false;
                });
                return;
              } else {
                dataForDay =
                    tokenCounterForYear.getTokenStatsSlotWiseForDay(date);

                dataForDay.forEach((k, v) {
                  dataMap[k.replaceAll('~', ':')] = v;
                });

                // SplayTreeMap<String, dynamic> sortedMap =
                //     new SplayTreeMap<String, dynamic>.from(
                //         dataMap,
                //         (a, b) => DateTime.parse(a).millisecondsSinceEpoch >
                //                 DateTime.parse(b).millisecondsSinceEpoch
                //             ? -1
                //             : 1);
                // print(sortedMap);
              }
            });
          } else {
            dataForDay = tokenCounterForYear.getTokenStatsSlotWiseForDay(date);
            dataForDay.forEach((k, v) {
              dataMap[k.replaceAll('~', ':')] = v;
            });
          }
        } else {
          _gs
              .getTokenService()
              .getTokenCounterForEntity(
                  widget.metaEntity.entityId, date.year.toString())
              .then((value) {
            tokenCounterForYear = value;
            if (tokenCounterForYear == null) {
              //show empty page
              listWidget = _emptyPage();
              barChartWidget = _emptyPage();
              setState(() {
                formattedDateStr = formattedDate;
                loadingData = false;
              });
              return;
            } else {
              dataForDay =
                  tokenCounterForYear.getTokenStatsSlotWiseForDay(date);

              dataForDay.forEach((k, v) {
                dataMap[k.replaceAll('~', ':')] = v;
              });
            }
          });
        }

        listWidget = (dataMap != null)
            ? ((dataMap.length != 0)
                ? Column(
                    children: [
                      Expanded(
                        child: ListView.builder(
                            itemCount: dataMap.length,
                            itemBuilder: (BuildContext context, int index) {
                              String key = dataMap.keys.elementAt(index);
                              return Container(
                                margin: EdgeInsets.fromLTRB(10, 0, 10, 10),
                                child: new Column(children: [
                                  buildTimeSlotRow(
                                      key, dataMap[key], date, format)
                                  // Text("hehe")
                                  // TokenExpansionTile(
                                  //     slotKey: key,
                                  //     stats: dataMap[key],
                                  //     date: date,
                                  //     format: format,
                                  //     metaEntity: widget.metaEntity)
                                ]),
                              );
                            }),
                      ),
                    ],
                  )
                : _emptyPage())
            : _emptyPage();

        barChartWidget = (dataMap.length != 0)
            ? Container(
                height: MediaQuery.of(context).size.height * .7,
                width: MediaQuery.of(context).size.width * .95,
                child: ListView(children: <Widget>[
                  BarChartGraph(
                    //key: _key,
                    dataMap: dataMap,
                    metaEn: widget.metaEntity,
                  ),
                ]),
              )
            : _emptyPage();

        break;
      case DateDisplayFormat.month:
        //Set display Date
        formattedDate = DateFormat.MMMM().format(date).substring(0, 3) +
            ", " +
            date.year.toString();
        //Fetch data of month - which will be sorted based on days
        if (tokenCounterForYear != null) {
          if (tokenCounterForYear.year != date.year.toString()) {
            _gs
                .getTokenService()
                .getTokenCounterForEntity(
                    widget.metaEntity.entityId, date.year.toString())
                .then((value) {
              tokenCounterForYear = value;
              if (tokenCounterForYear == null) {
                listWidget = _emptyPage();
                barChartWidget = _emptyPage();
                setState(() {
                  formattedDateStr = formattedDate;
                  loadingData = false;
                });
                return;
              } else {
                dataForMonth = tokenCounterForYear
                    .getTokenStatsDayWiseForMonth(date.month);
                dataForMonth.forEach((k, v) {
                  dataMap[k.replaceAll('~', ':')] = v;
                });
              }
            });
          } else {
            dataForMonth =
                tokenCounterForYear.getTokenStatsDayWiseForMonth(date.month);
            print(dataForMonth.length);
            dataForMonth.forEach((k, v) {
              dataMap[k.replaceAll('~', ':')] = v;
            });
          }
        } else {
          _gs
              .getTokenService()
              .getTokenCounterForEntity(
                  widget.metaEntity.entityId, date.year.toString())
              .then((value) {
            tokenCounterForYear = value;
            if (tokenCounterForYear == null) {
              listWidget = _emptyPage();
              barChartWidget = _emptyPage();
              setState(() {
                formattedDateStr = formattedDate;
                loadingData = false;
              });
              return;
            } else {
              dataForMonth =
                  tokenCounterForYear.getTokenStatsDayWiseForMonth(date.month);
              dataForMonth.forEach((k, v) {
                dataMap[k.replaceAll('~', ':')] = v;
              });
            }
          });
        }

        listWidget = (dataForMonth != null)
            ? (dataForMonth.length != 0
                ? Column(
                    children: [
                      Expanded(
                        child: ListView.builder(
                            itemCount: 1,
                            itemBuilder: (BuildContext context, int index) {
                              String key = dataForMonth.keys.elementAt(index);
                              return Container(
                                margin: EdgeInsets.fromLTRB(10, 0, 10, 50),
                                child: new Column(children: [
                                  buildTimeSlotRow(
                                      key, dataForMonth[key], date, format)
                                ]),
                              );
                            }),
                      ),
                    ],
                  )
                : _emptyPage())
            : _emptyPage();
        barChartWidget = (dataMap.length != 0)
            ? Container(
                height: MediaQuery.of(context).size.height * .7,
                width: MediaQuery.of(context).size.width * .95,
                child: ListView(children: <Widget>[
                  BarChartGraph(
                    //key: _key,
                    dataMap: dataMap,
                    metaEn: widget.metaEntity,
                  ),
                ]),
              )
            : _emptyPage();
        break;
      case DateDisplayFormat.year:
        formattedDate = date.year.toString();
        if (tokenCounterForYear != null) {
          if (tokenCounterForYear.year != date.year.toString()) {
            //fetch data
            _gs
                .getTokenService()
                .getTokenCounterForEntity(
                    widget.metaEntity.entityId, date.year.toString())
                .then((value) {
              tokenCounterForYear = value;
              if (tokenCounterForYear == null) {
                //show empty page
                listWidget = _emptyPage();
                barChartWidget = _emptyPage();
                setState(() {
                  formattedDateStr = formattedDate;
                  loadingData = false;
                });
                return;
              } else {
                dataForYear =
                    tokenCounterForYear.getTokenStatsMonthWiseForYear();
                dataForYear.forEach((k, v) {
                  dataMap[k.replaceAll('~', ':')] = v;
                });
              }
            });
          } else {
            dataForYear = tokenCounterForYear.getTokenStatsMonthWiseForYear();
            dataForYear.forEach((k, v) {
              dataMap[k.replaceAll('~', ':')] = v;
            });
          }
        } else {
          _gs
              .getTokenService()
              .getTokenCounterForEntity(
                  widget.metaEntity.entityId, date.year.toString())
              .then((value) {
            tokenCounterForYear = value;
            if (tokenCounterForYear == null) {
              //show empty page
              listWidget = _emptyPage();
              barChartWidget = _emptyPage();
              setState(() {
                formattedDateStr = formattedDate;
                loadingData = false;
              });
              return;
            } else {
              dataForYear = tokenCounterForYear.getTokenStatsMonthWiseForYear();
              dataForYear.forEach((k, v) {
                dataMap[k.replaceAll('~', ':')] = v;
              });
            }
          });
        }
        listWidget = dataForYear != null
            ? ((dataForYear.length != 0)
                ? Column(
                    children: [
                      Expanded(
                        child: ListView.builder(
                            itemCount: 1,
                            itemBuilder: (BuildContext context, int index) {
                              String key = dataForYear.keys.elementAt(index);
                              return Container(
                                margin: EdgeInsets.fromLTRB(10, 0, 10, 50),
                                child: new Column(children: [
                                  buildTimeSlotRow(
                                      key, dataForMonth[key], date, format)
                                ]),
                              );
                            }),
                      ),
                    ],
                  )
                : _emptyPage())
            : _emptyPage();

        barChartWidget = (dataMap.length != 0)
            ? Container(
                height: MediaQuery.of(context).size.height * .7,
                width: MediaQuery.of(context).size.width * .95,
                child: ListView(children: <Widget>[
                  BarChartGraph(
                    // key: _key,
                    dataMap: dataMap,
                    metaEn: widget.metaEntity,
                  ),
                ]),
              )
            : _emptyPage();
        break;
      default:
        break;
    }
    if (tokenCounterForYear == null) {
      barChartWidget = _emptyPage();
      listWidget = _emptyPage();
    }
    setState(() {
      formattedDateStr = formattedDate;
      loadingData = false;
      // _key.currentState.refresh();
    });
  }

  Widget _emptyPage() {
    return Center(
      child: Container(
        height: MediaQuery.of(context).size.height * .6,
        alignment: Alignment.center,
        child: SingleChildScrollView(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                SizedBox(height: MediaQuery.of(context).size.height * .02),
                Container(
                  color: Colors.transparent,
                  child: Text("No Tokens Booked for selected Date(s)."),
                  // child: Image(
                  //image: AssetImage('assets/search_home.png'),
                  // )
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // List<Widget> showListOfData() {
  // if (selectedView == selected_view.list)
  //   return Expanded(
  //     child: ListView.builder(
  //         itemCount: 1,
  //         itemBuilder: (BuildContext context, int index) {
  //           return Container(
  //             margin: EdgeInsets.fromLTRB(10, 0, 10, 50),
  //             child: new Column(
  //               children: list.map(buildItem).toList(),
  //             ),
  //           );
  //         }),
  //   );

  // if (selectedView == selected_view.bar)
  //   return BarChart(
  //     dataMap: dataMap,
  //     metaEn: widget.metaEntity,
  //   );
  // return Expanded(
  //   child: ListView.builder(
  //       itemCount: 1,
  //       itemBuilder: (BuildContext context, int index) {
  //         return Container(
  //           margin: EdgeInsets.fromLTRB(10, 0, 10, 50),
  //           child: new Column(
  //             children: list.map(buildItem).toList(),
  //           ),
  //         );
  //       }),
  // );

  //   return list.map(buildItem).toList();
  // }

  buildChildItem(UserToken token) {
    return Container(
      padding: EdgeInsets.all(0),
      child: Card(
          child: Row(
        children: [
          Container(
              width: MediaQuery.of(context).size.width * .4,
              padding: EdgeInsets.all(8),
              child: Text(token.parent.userId,
                  style: TextStyle(
                      //fontFamily: "RalewayRegular",
                      color: Colors.blueGrey[800],
                      fontSize: 13))),
          if (token.bookingFormName != null)
            Container(
                width: MediaQuery.of(context).size.width * .4,
                padding: EdgeInsets.all(8),
                child: Text(token.bookingFormName,
                    style: TextStyle(
                        //fontFamily: "RalewayRegular",
                        color: Colors.blueGrey[800],
                        fontSize: 13))),
        ],
      )),
    );
  }

  // Widget buildListItem(Slot slot) {
  //   List<UserToken> tokens = _tokensMap[slot.slotId];
  //   String fromTime = Utils.formatTime(slot.dateTime.hour.toString()) +
  //       ":" +
  //       Utils.formatTime(slot.dateTime.minute.toString());

  //   String toTime = Utils.formatTime(slot.dateTime
  //           .add(new Duration(minutes: slot.slotDuration))
  //           .hour
  //           .toString()) +
  //       ":" +
  //       Utils.formatTime(slot.dateTime
  //           .add(new Duration(minutes: slot.slotDuration))
  //           .minute
  //           .toString());

  //   return Container(
  //     child: Card(
  //       child: Theme(
  //         data: ThemeData(
  //           unselectedWidgetColor: Colors.grey[600],
  //           accentColor: btnColor,
  //         ),
  //         child: Column(
  //           children: [
  //             ExpansionTile(
  //               initiallyExpanded: false,
  //               title: Row(
  //                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //                 children: [
  //                   Text(
  //                     fromTime + "  -  " + toTime,
  //                     style: TextStyle(fontSize: 13, color: Colors.grey[600]),
  //                   ),
  //                   Text(
  //                     slot.currentNumber.toString() + " tokens",
  //                     style: TextStyle(fontSize: 13, color: Colors.grey[600]),
  //                   ),
  //                 ],
  //               ),
  //               // backgroundColor: Colors.grey[300],
  //               children: <Widget>[
  //                 (!Utils.isNullOrEmpty(tokens))
  //                     ? new Container(
  //                         width: MediaQuery.of(context).size.width * .94,
  //                         decoration: new BoxDecoration(
  //                             border: Border.all(color: Colors.grey[300]),
  //                             shape: BoxShape.rectangle,
  //                             color: Colors.grey[300],
  //                             borderRadius: BorderRadius.only(
  //                                 topLeft: Radius.circular(4.0),
  //                                 topRight: Radius.circular(4.0))),
  //                         padding: EdgeInsets.all(2.0),
  //                         child: new Expanded(
  //                           child: Align(
  //                             alignment: Alignment.topCenter,
  //                             //child: Text("Hello"),
  //                             child: ListView.builder(
  //                               padding: EdgeInsets.all(
  //                                   MediaQuery.of(context).size.width * .006),
  //                               //  controller: _childScrollController,
  //                               // reverse: true,
  //                               shrinkWrap: true,
  //                               //   itemExtent: itemSize,
  //                               //scrollDirection: Axis.vertical,
  //                               itemBuilder: (BuildContext context, int index) {
  //                                 return Container(
  //                                   //  height: MediaQuery.of(context).size.height * .3,
  //                                   child: buildChildItem(tokens[index]),
  //                                 );
  //                               },
  //                               itemCount: tokens.length,
  //                             ),
  //                           ),
  //                         ),
  //                       )
  //                     : Container(
  //                         padding: EdgeInsets.all(12),
  //                         child: Text("No tokens",
  //                             style: TextStyle(
  //                                 fontSize: 13, color: Colors.grey[600]))),
  //               ],
  //             ),
  //           ],
  //         ),
  //       ),
  //     ),
  //   );
  // }

  Widget buildItem(String key, TokenStats stats) {
    // String fromTime = Utils.formatTime(slot.dateTime.hour.toString()) +
    //     ":" +
    //     Utils.formatTime(slot.dateTime.minute.toString());

    // String toTime = Utils.formatTime(slot.dateTime
    //         .add(new Duration(minutes: slot.slotDuration))
    //         .hour
    //         .toString()) +
    //     ":" +
    //     Utils.formatTime(slot.dateTime
    //         .add(new Duration(minutes: slot.slotDuration))
    //         .minute
    //         .toString());

    return Container(
      child: Card(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              key,
              style: TextStyle(fontSize: 13, color: Colors.grey[600]),
            ),
            Column(
              children: [
                Text("Tokens Cancelled" +
                    stats.numberOfTokensCancelled.toString()),
                Text("Tokens Created" + stats.numberOfTokensCreated.toString()),
              ],
            )
          ],
        ),
        // backgroundColor: Colors.grey[300],
      ),
    );
  }

  Widget getEmptyTokenListWidget() {
    return Container(
        padding: EdgeInsets.all(12),
        child: Text("No tokens",
            style: TextStyle(fontSize: 13, color: Colors.grey[600])));
  }

  Future<List<UserToken>> getTokenList(
      String slot, DateTime date, DateDisplayFormat format) async {
    String slotId;
    String dateTime = date.year.toString() +
        '~' +
        date.month.toString() +
        '~' +
        date.day.toString() +
        '#' +
        slot.replaceAll(':', '~');
    print(dateTime);
    //Build slotId using info we have entityID#YYYY~MM~DD#HH~MM

    slotId = widget.metaEntity.entityId + "#" + dateTime;
    //6b8af7a0-9ce7-11eb-b97b-2beeb21da0d7#15~4~2021#11~20

    return await _gs.getTokenService().getAllTokensForSlot(slotId);
  }

//   void buildExpansionTileChild(
//       String slot, DateTime date, DateDisplayFormat format) {
// //Fetch tokens for this slot
//     // _key.currentState.build(context);
//     List<UserToken> tokens;
//     String slotId;
//     String dateTime = date.year.toString() +
//         '~' +
//         date.month.toString() +
//         '~' +
//         date.day.toString() +
//         '#' +
//         slot.replaceAll(':', '~');
//     print(dateTime);
//     //Build slotId using info we have entityID#YYYY~MM~DD#HH~MM

//     slotId = widget.metaEntity.entityId + "#" + dateTime;
//     //6b8af7a0-9ce7-11eb-b97b-2beeb21da0d7#15~4~2021#11~20

//     _gs.getTokenService().getAllTokensForSlot(slotId).then((value) {
//       tokens = value;
//       setState(() {
//         tokenListWidget = !Utils.isNullOrEmpty(tokens)
//             ? Container(
//                 width: MediaQuery.of(context).size.width * .94,
//                 decoration: new BoxDecoration(
//                     border: Border.all(color: Colors.grey[300]),
//                     shape: BoxShape.rectangle,
//                     color: Colors.grey[300],
//                     borderRadius: BorderRadius.only(
//                         topLeft: Radius.circular(4.0),
//                         topRight: Radius.circular(4.0))),
//                 padding: EdgeInsets.all(2.0),
//                 child: new Expanded(
//                   child: Align(
//                     alignment: Alignment.topCenter,
//                     //child: Text("Hello"),
//                     child: ListView.builder(
//                       padding: EdgeInsets.all(
//                           MediaQuery.of(context).size.width * .006),
//                       //  controller: _childScrollController,
//                       reverse: true,
//                       shrinkWrap: true,
//                       //   itemExtent: itemSize,
//                       //scrollDirection: Axis.vertical,
//                       itemBuilder: (BuildContext context, int index) {
//                         return Container(
//                           //  height: MediaQuery.of(context).size.height * .3,
//                           child: buildChildItem(tokens[index]),
//                         );
//                       },
//                       itemCount: tokens.length,
//                     ),
//                   ),
//                 ),
//               )
//             : getEmptyTokenListWidget;
//       });
//       print("exitinnnnng");
//     });
//   }

  Widget buildTimeSlotRow(
      String key, TokenStats stats, DateTime date, DateDisplayFormat format) {
    String timeSlot = key.replaceAll('~', ':');

    return Card(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            timeSlot,
            style: TextStyle(fontSize: 13, color: Colors.grey[600]),
          ),
          Row(
            children: [
              AutoSizeText(
                "Booked - " + stats.numberOfTokensCreated.toString() + ", ",
                minFontSize: 8,
                maxFontSize: 13,
                style: TextStyle(color: Colors.grey[600]),
              ),
              AutoSizeText(
                "Cancelled - " + stats.numberOfTokensCancelled.toString(),
                minFontSize: 8,
                maxFontSize: 13,
                style: TextStyle(color: Colors.grey[600]),
              ),
            ],
          ),
          IconButton(
            icon: Icon(Icons.view_agenda),
            onPressed: () {
              // Navigator.of(context)
              //     .push(PageAnimation.createRoute(TokenExpansionTile(
              //       slotKey: key,
              //   stats: stats,
              //   date: date,
              //   format: DateDisplayFormat.date,
              //   metaEntity: widget.metaEntity,

              // )));
              // getTokenList(key, date, format).then((value) {
              print("DONEJHCFGJHSDCSDCH");
              // });
            },
          )
        ],
      ),
    );
  }

  Future<DateTime> pickAnyDate(BuildContext context) async {
    DateTime date = await showDatePicker(
      context: context,
      firstDate: DateTime.now().subtract(Duration(days: 365)),
      lastDate: DateTime.now().add(Duration(days: 60)),
      initialDate: DateTime.now(),
      builder: (BuildContext context, Widget child) {
        return Theme(
          data: ThemeData.dark().copyWith(
            colorScheme: ColorScheme.light(
              primary: Colors.cyan,
            ),
            dialogBackgroundColor: Colors.white,
          ),
          child: child,
        );
      },
    );
    return date;
  }

  Future<void> getListOfData(DateTime date) async {
    list.clear();
    // dataMapZeroValues = true;
    list = await getSlotsListForEntity(widget.metaEntity, date);
    for (int i = 0; i <= list.length - 1; i++) {
      List<UserToken> tokensForThisSlot =
          await _gs.getTokenService().getAllTokensForSlot(list[i].slotId);
      if (!Utils.isNullOrEmpty(tokensForThisSlot))
        _tokensMap[list[i].slotId] = tokensForThisSlot;
      // dataMap[Utils.formatTime(list[i].dateTime.hour.toString()) +
      //         ":" +
      //         Utils.formatTime(list[i].dateTime.minute.toString())] =
      //     tokensForThisSlot.length;
      // if (tokensForThisSlot.length != 0) dataMapZeroValues = false;
    }
    setState(() {
      loadingData = false;
    });

    return list;
  }

  Future<DateTime> pickAnyYear(BuildContext context, DateTime date) async {
    DateTime returnVal = await showDialog(
        context: context,
        builder: (BuildContext context) {
          DateTime selectedYear = date;
          String yearStr;
          return StatefulBuilder(builder: (context, setState) {
            return AlertDialog(
              titlePadding: EdgeInsets.zero,
              contentPadding: EdgeInsets.fromLTRB(5, 30, 5, 30),
              title: Container(
                height: MediaQuery.of(context).size.height * .08,
                padding: EdgeInsets.fromLTRB(15, 15, 15, 10),
                color: Colors.cyan,
                child: Text("Year ${selectedYear.year.toString()}",
                    style: TextStyle(
                        color: Colors.white, fontWeight: FontWeight.normal)),
              ),
              content: Container(
                  child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    height: 47,
                    child: FlatButton(
                      visualDensity: VisualDensity.compact,
                      padding: EdgeInsets.zero,
                      color: (selectedYear.year == date.year - 1)
                          ? Colors.cyan
                          : Colors.transparent,
                      textColor: (selectedYear.year == date.year - 1)
                          ? Colors.white
                          : Colors.blueGrey[600],
                      shape: CircleBorder(
                        side: BorderSide(
                            color: (selectedYear.year == date.year - 1)
                                ? Colors.white
                                : Colors.transparent),
                      ),
                      child: Text(
                        (date.year - 1).toString(),
                        style: TextStyle(
                            fontSize: 15, fontWeight: FontWeight.normal),
                      ),
                      onPressed: () {
                        setState(() {
                          yearStr = (date.year - 1).toString();
                          selectedYear =
                              DateTime(date.year - 1, date.month, date.day);
                        });
                      },
                    ),
                  ),
                  SizedBox(
                    height: 47,
                    child: FlatButton(
                      visualDensity: VisualDensity.compact,
                      padding: EdgeInsets.zero,
                      color: (selectedYear.year == date.year)
                          ? Colors.cyan
                          : Colors.transparent,
                      textColor: (selectedYear.year == date.year)
                          ? Colors.white
                          : Colors.blueGrey[600],
                      shape: CircleBorder(
                        side: BorderSide(
                            color: (selectedYear.year == date.year - 1)
                                ? Colors.white
                                : Colors.transparent),
                      ),
                      child: Text(
                        (date.year).toString(),
                        style: TextStyle(
                            fontSize: 15, fontWeight: FontWeight.normal),
                      ),
                      onPressed: () {
                        setState(() {
                          yearStr = (date.year).toString();
                          selectedYear = date;
                        });
                      },
                    ),
                  ),
                  SizedBox(
                    height: 47,
                    child: FlatButton(
                      visualDensity: VisualDensity.compact,
                      padding: EdgeInsets.zero,
                      color: (selectedYear.year == date.year + 1)
                          ? Colors.cyan
                          : Colors.transparent,
                      textColor: (selectedYear.year == date.year + 1)
                          ? Colors.white
                          : Colors.blueGrey[600],
                      shape: CircleBorder(
                        side: BorderSide(
                            color: (selectedYear.year == date.year - 1)
                                ? Colors.white
                                : Colors.transparent),
                      ),
                      child: Text(
                        (date.year + 1).toString(),
                        style: TextStyle(
                            fontSize: 15, fontWeight: FontWeight.normal),
                      ),
                      onPressed: () {
                        setState(() {
                          yearStr = (date.year + 1).toString();
                          selectedYear =
                              DateTime(date.year + 1, date.month, date.day);
                        });
                      },
                    ),
                  ),
                ],
              )),
              actions: <Widget>[
                SizedBox(
                  height: 30,
                  child: FlatButton(
                    color: Colors.transparent,
                    textColor: btnColor,
                    // shape: RoundedRectangleBorder(
                    //     side: BorderSide(color: btnColor),
                    //     borderRadius: BorderRadius.all(Radius.circular(3.0))),
                    child: Text(
                      'CANCEL',
                      style: TextStyle(fontSize: 14),
                    ),
                    onPressed: () {
                      Navigator.of(context).pop(date);
                    },
                  ),
                ),
                SizedBox(
                  height: 30,
                  child: FlatButton(
                    color: Colors.transparent,
                    textColor: btnColor,
                    // shape: RoundedRectangleBorder(
                    //     side: BorderSide(color: btnColor),
                    //     borderRadius: BorderRadius.all(Radius.circular(3.0))),
                    child: Text(
                      'OK',
                      style: TextStyle(fontSize: 14),
                    ),
                    onPressed: () {
                      Navigator.of(context).pop(selectedYear);
                    },
                  ),
                ),
              ],
            );
          });
        });

    return returnVal;
  }

  @override
  Widget build(BuildContext context) {
    if (initCompleted && !loadingData) {
      return MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData.light().copyWith(),
        home: Scaffold(
          appBar: CustomAppBarWithBackButton(
            backRoute: widget.backRoute,
            titleTxt: "Booking Tokens Overview ",
          ),
          body: Container(
            // decoration: verticalBackground,
            //margin: EdgeInsets.fromLTRB(10, 0, 10, 5),
            //color: Colors.grey[50],
            child: Column(
              children: <Widget>[
                Container(
                    child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    GestureDetector(
                      onTap: () {
                        // pickAnyDate(context).then((value) {
                        //   if (value != null) {
                        //     print(value);
                        //     dateForShowingList = value;
                        //     setState(() {
                        //       loadingData = true;
                        //     });
                        //     getListOfData(value);
                        //   }
                        // });
                      },
                      child: Container(
                        padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
                        width: MediaQuery.of(context).size.width * .38,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Icon(Icons.date_range),
                            SizedBox(width: 5),
                            RichText(
                              text: TextSpan(
                                  // text: 'Showing tokens for ',
                                  style: TextStyle(
                                      color: Colors.blueGrey[700],
                                      fontSize: 13),
                                  children: <TextSpan>[
                                    TextSpan(
                                      text: formattedDateStr,
                                      style: TextStyle(
                                          color: btnColor, fontSize: 14),
                                      // recognizer: TapGestureRecognizer()
                                      //   ..onTap = () {
                                      //     // navigate to desired screen
                                      //   }
                                    )
                                  ]),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        IconButton(
                          icon: Icon(
                            Icons.bar_chart,
                            color: disabledColor,
                          ),
                          onPressed: () {
                            return null;
                            //TODO Phase2
                            // setState(() {
                            //   selectedView = SelectedView.bar;
                            // });
                          },
                        ),
                        IconButton(
                          icon: Icon(Icons.list),
                          onPressed: () {
                            setState(() {
                              selectedView = SelectedView.list;
                            });
                          },
                        ),
                      ],
                    ),
                  ],
                )),
                Container(
                    padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        SizedBox(
                          //width: MediaQuery.of(context).size.width * .18,
                          height: MediaQuery.of(context).size.width * .08,
                          child: FlatButton(
                            visualDensity: VisualDensity.compact,
                            color:
                                (selectedDateFormat == DateDisplayFormat.date)
                                    ? btnColor
                                    : Colors.transparent,
                            textColor:
                                (selectedDateFormat == DateDisplayFormat.date)
                                    ? Colors.white
                                    : btnColor,
                            shape: RoundedRectangleBorder(
                                side: BorderSide(color: btnColor),
                                borderRadius:
                                    BorderRadius.all(Radius.circular(100.0))),
                            child: Text(
                              'Day',
                              style: TextStyle(fontSize: 11),
                            ),
                            onPressed: () {
                              //TODO SMITA - fetch data for showdatafordate
                              pickAnyDate(context).then((value) {
                                if (value != null) {
                                  print(value);
                                  setState(() {
                                    loadingData = true;
                                  });
                                  getListOfData(value).then((retVal) {
                                    selectedDateFormat = DateDisplayFormat.date;
                                    prepareData(value, selectedDateFormat);
                                  });
                                }
                              });
                            },
                          ),
                        ),
                        SizedBox(
                          // width: MediaQuery.of(context).size.width * .18,
                          height: MediaQuery.of(context).size.width * .08,
                          child: FlatButton(
                            visualDensity: VisualDensity.compact,
                            color:
                                (selectedDateFormat == DateDisplayFormat.month)
                                    ? btnColor
                                    : Colors.transparent,
                            textColor:
                                (selectedDateFormat == DateDisplayFormat.month)
                                    ? Colors.white
                                    : btnColor,
                            shape: RoundedRectangleBorder(
                                side: BorderSide(color: btnColor),
                                borderRadius:
                                    BorderRadius.all(Radius.circular(100.0))),
                            child: Text(
                              'Month',
                              style: TextStyle(fontSize: 11),
                            ),
                            onPressed: () {
                              showMonthPicker(
                                      context: context,
                                      firstDate:
                                          DateTime(DateTime.now().year - 2, 12),
                                      lastDate:
                                          DateTime(DateTime.now().year + 1, 12),
                                      initialDate: dateForShowingList)
                                  .then((value) => setState(() {
                                        print(value);
                                        if (value != null) {
                                          setState(() {
                                            loadingData = true;
                                          });
                                          selectedDateFormat =
                                              DateDisplayFormat.month;
                                          prepareData(
                                              value, selectedDateFormat);

                                          //fetch data for the month (check getListOfData)
                                        }
                                        // selectedDate = date;
                                      }));
                            },
                          ),
                        ),
                        SizedBox(
                          // width: MediaQuery.of(context).size.width * .18,
                          height: MediaQuery.of(context).size.width * .08,
                          child: FlatButton(
                            visualDensity: VisualDensity.compact,
                            padding: EdgeInsets.zero,
                            color:
                                (selectedDateFormat == DateDisplayFormat.year)
                                    ? btnColor
                                    : Colors.transparent,
                            textColor:
                                (selectedDateFormat == DateDisplayFormat.year)
                                    ? Colors.white
                                    : btnColor,
                            shape: RoundedRectangleBorder(
                                side: BorderSide(color: btnColor),
                                borderRadius:
                                    BorderRadius.all(Radius.circular(100.0))),
                            child: Text(
                              'Year',
                              style: TextStyle(fontSize: 11),
                            ),
                            onPressed: () {
                              //TODO SMITA - fetch data for year showdatafordate
                              pickAnyYear(context, dateForShowingList)
                                  .then((value) {
                                if (value != null) {
                                  print(value);
                                  setState(() {
                                    loadingData = true;
                                  });
                                  selectedDateFormat = DateDisplayFormat.year;
                                  prepareData(value, selectedDateFormat);
                                }
                              });
                            },
                          ),
                        ),
                      ],
                    )),
                SizedBox(
                  height: 10,
                ),
                //(!Utils.isNullOrEmpty(list)) ? showListOfData : _emptyPage(),

                (selectedView == SelectedView.list)
                    ?
                    // (!Utils.isNullOrEmpty(list)
                    //     ? Container(
                    //         height: MediaQuery.of(context).size.height * .8,
                    //         child: Column(
                    //           mainAxisSize: MainAxisSize.min,
                    //           children: [
                    //             Expanded(
                    //               child: ListView.builder(
                    //                   itemCount: list.length,
                    //                   shrinkWrap: true,
                    //                   itemBuilder: (BuildContext context,
                    //                       int index) {
                    //                     return Container(
                    //                       margin: EdgeInsets.fromLTRB(
                    //                           10, 0, 10, 5),
                    //                       child: new Column(
                    //                           mainAxisSize:
                    //                               MainAxisSize.min,
                    //                           children: <Widget>[
                    //                             //   Text(
                    //                             //       "${list[index].currentNumber}"),
                    //                             // ]

                    //                             buildListItem(list[index])
                    //                           ]),
                    //                     );
                    //                   }),
                    //             ),
                    //           ],
                    //         ),
                    //       )
                    //     : _emptyPage())
                    listWidget
                    : barChartWidget,
              ],
            ),
          ),
        ),
      );
    } else
    //if (!initCompleted || loadingData)
    {
      return MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData.light().copyWith(),
        home: new WillPopScope(
          child: Scaffold(
            appBar: CustomAppBarWithBackButton(
              backRoute: UserHomePage(),
              titleTxt: "Booking Tokens Overview ",
            ),
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  showCircularProgress(),
                ],
              ),
            ),
          ),
          onWillPop: () async {
            return true;
          },
        ),
      );
    }
  }
}
