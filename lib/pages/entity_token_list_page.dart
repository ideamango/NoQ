import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:noq/constants.dart';
import 'package:noq/db/db_model/meta_entity.dart';
import 'package:noq/db/db_model/slot.dart';
import 'package:noq/db/db_model/user_token.dart';
import 'package:noq/global_state.dart';
import 'package:noq/pages/bar_chart.dart';
import 'package:noq/pages/manage_entity_list_page.dart';
import 'package:noq/pages/overview_page.dart';
import 'package:noq/repository/slotRepository.dart';
import 'package:noq/services/circular_progress.dart';
import 'package:noq/services/month_picker_dialog.dart';
import 'package:noq/style.dart';
import 'package:noq/userHomePage.dart';
import 'package:noq/utils.dart';
import 'package:noq/widget/appbar.dart';
import 'package:noq/widget/page_animation.dart';
import 'package:noq/widget/widgets.dart';

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
  bool loadingData = false;
  GlobalState _gs;
  List<Slot> list;
  String formattedDateStr;
  DateTime dateForShowingList;
  DateTime yearForShowingList;
  DateTime monthForShowingList;
  String weekForShowingList;
  Map<String, List<UserToken>> _tokensMap = new Map<String, List<UserToken>>();
  Map<String, int> dataMap = new Map<String, int>();
  SelectedView selectedView = SelectedView.list;

  @override
  void initState() {
    super.initState();
    getGlobalState().whenComplete(() {
      dateForShowingList = DateTime.now();
      setShowDate(DateTime.now(), DateDisplayFormat.date);
      getListOfData(dateForShowingList).whenComplete(() {
        if (this.mounted) {
          setState(() {
            initCompleted = true;
          });
        } else
          initCompleted = true;
      });
    });
  }

  Future<void> getGlobalState() async {
    _gs = await GlobalState.getGlobalState();
  }

  Future<void> getListOfData(DateTime date) async {
    list = await getSlotsListForEntity(widget.metaEntity, date);
    for (int i = 0; i <= list.length - 1; i++) {
      List<UserToken> tokensForThisSlot =
          await _gs.getTokenService().getAllTokensForSlot(list[i].slotId);
      if (!Utils.isNullOrEmpty(tokensForThisSlot))
        _tokensMap[list[i].slotId] = tokensForThisSlot;
      dataMap[Utils.formatTime(list[i].dateTime.hour.toString()) +
              ":" +
              Utils.formatTime(list[i].dateTime.minute.toString())] =
          tokensForThisSlot.length;
    }
    setState(() {
      loadingData = false;
    });

    return list;
  }

  Future<void> getListOfDataForMonth(DateTime date) async {
    list = await getSlotsListForEntity(widget.metaEntity, date);
    for (int i = 0; i <= list.length - 1; i++) {
      List<UserToken> tokensForThisSlot =
          await _gs.getTokenService().getAllTokensForSlot(list[i].slotId);
      if (!Utils.isNullOrEmpty(tokensForThisSlot))
        _tokensMap[list[i].slotId] = tokensForThisSlot;
      dataMap[Utils.formatTime(list[i].dateTime.hour.toString()) +
              ":" +
              Utils.formatTime(list[i].dateTime.minute.toString())] =
          tokensForThisSlot.length;
    }
    setState(() {
      loadingData = false;
    });

    return list;
  }

  Future<void> getListOfDataForYear(DateTime year) async {
    //TODO Smita: Get time-slots vs booked tokens for the entire year.

    //Dummy data for testing- start

    list = await getSlotsListForEntity(widget.metaEntity, dateForShowingList);
    for (int i = 0; i <= list.length - 1; i++) {
      List<UserToken> tokensForThisSlot =
          await _gs.getTokenService().getAllTokensForSlot(list[i].slotId);
      if (!Utils.isNullOrEmpty(tokensForThisSlot))
        _tokensMap[list[i].slotId] = tokensForThisSlot;
      dataMap[Utils.formatTime(list[i].dateTime.hour.toString()) +
              ":" +
              Utils.formatTime(list[i].dateTime.minute.toString())] =
          tokensForThisSlot.length;
    }

    // dataMap[Utils.formatTime() + ":" + Utils.formatTime()] =
    //     tokensForThisSlot.length;
    //Dummy data for testing- end

    setState(() {
      loadingData = false;
    });

    //return list;
  }

  void setShowDate(DateTime date, DateDisplayFormat format) {
    String formattedDate;
    switch (format) {
      case DateDisplayFormat.date:
        formattedDate = DateFormat(dateDisplayFormat).format(date);
        break;
      case DateDisplayFormat.month:
        formattedDate = DateFormat.MMMM().format(date).substring(0, 3) +
            ", " +
            date.year.toString();
        break;
      case DateDisplayFormat.year:
        formattedDate = date.year.toString();
        break;
      default:
        break;
    }
    setState(() {
      formattedDateStr = formattedDate;
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
                  child: Text("No Tokens. Try with another date!"),
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

  List<Widget> showListOfData() {
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

    return list.map(buildItem).toList();
  }

  refreshDataView() {}

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

  Widget buildItem(Slot slot) {
    List<UserToken> tokens = _tokensMap[slot.slotId];
    String fromTime = Utils.formatTime(slot.dateTime.hour.toString()) +
        ":" +
        Utils.formatTime(slot.dateTime.minute.toString());

    String toTime = Utils.formatTime(slot.dateTime
            .add(new Duration(minutes: slot.slotDuration))
            .hour
            .toString()) +
        ":" +
        Utils.formatTime(slot.dateTime
            .add(new Duration(minutes: slot.slotDuration))
            .minute
            .toString());

    return Container(
      child: Card(
        child: Theme(
          data: ThemeData(
            unselectedWidgetColor: Colors.grey[600],
            accentColor: btnColor,
          ),
          child: Column(
            children: [
              ExpansionTile(
                initiallyExpanded: false,
                title: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      fromTime + "  -  " + toTime,
                      style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                    ),
                    Text(
                      slot.currentNumber.toString() + " tokens",
                      style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                    ),
                  ],
                ),
                // backgroundColor: Colors.grey[300],
                children: <Widget>[
                  (!Utils.isNullOrEmpty(tokens))
                      ? new Container(
                          width: MediaQuery.of(context).size.width * .94,
                          decoration: new BoxDecoration(
                              border: Border.all(color: Colors.grey[300]),
                              shape: BoxShape.rectangle,
                              color: Colors.grey[300],
                              borderRadius: BorderRadius.only(
                                  topLeft: Radius.circular(4.0),
                                  topRight: Radius.circular(4.0))),
                          padding: EdgeInsets.all(2.0),
                          child: new Expanded(
                            child: Align(
                              alignment: Alignment.topCenter,
                              //child: Text("Hello"),
                              child: ListView.builder(
                                padding: EdgeInsets.all(
                                    MediaQuery.of(context).size.width * .006),
                                //  controller: _childScrollController,
                                reverse: true,
                                shrinkWrap: true,
                                //   itemExtent: itemSize,
                                //scrollDirection: Axis.vertical,
                                itemBuilder: (BuildContext context, int index) {
                                  return Container(
                                    //  height: MediaQuery.of(context).size.height * .3,
                                    child: buildChildItem(tokens[index]),
                                  );
                                },
                                itemCount: tokens.length,
                              ),
                            ),
                          ),
                        )
                      : Container(
                          padding: EdgeInsets.all(12),
                          child: Text("No tokens",
                              style: TextStyle(
                                  fontSize: 13, color: Colors.grey[600]))),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
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
          body: Center(
            child: Container(
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
                            icon: Icon(Icons.bar_chart),
                            onPressed: () {
                              setState(() {
                                selectedView = SelectedView.bar;
                              });
                              // Navigator.of(context)
                              //     .push(PageAnimation.createRoute(
                              //   BarChart(
                              //     dataMap: dataMap,
                              //     metaEn: widget.metaEntity,
                              //   ),
                              // ));
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
                              color: Colors.transparent,
                              textColor: btnColor,
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
                                    setShowDate(value, DateDisplayFormat.date);
                                    setState(() {
                                      loadingData = true;
                                    });
                                    getListOfData(value);
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
                              color: Colors.transparent,
                              textColor: btnColor,
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
                                        firstDate: DateTime(
                                            DateTime.now().year - 2, 12),
                                        lastDate: DateTime(
                                            DateTime.now().year + 1, 12),
                                        initialDate: dateForShowingList)
                                    .then((date) => setState(() {
                                          print(date);
                                          if (date != null) {
                                            setShowDate(
                                                date, DateDisplayFormat.month);
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
                              color: Colors.transparent,
                              textColor: btnColor,
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
                                    setShowDate(value, DateDisplayFormat.year);
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
                  (!Utils.isNullOrEmpty(list))
                      ? ((selectedView == SelectedView.list)
                          ? Expanded(
                              child: ListView.builder(
                                  itemCount: 1,
                                  itemBuilder:
                                      (BuildContext context, int index) {
                                    return Container(
                                      margin:
                                          EdgeInsets.fromLTRB(10, 0, 10, 50),
                                      child: new Column(
                                        children: list.map(buildItem).toList(),
                                      ),
                                    );
                                  }),
                            )
                          : Container(
                              height: MediaQuery.of(context).size.height * .7,
                              width: MediaQuery.of(context).size.width * .95,
                              child: ListView(children: <Widget>[
                                BarChart(
                                  dataMap: dataMap,
                                  metaEn: widget.metaEntity,
                                ),
                              ]),
                            ))
                      : _emptyPage(),
                ],
              ),
            ),
          ),
        ),
      );
    } else if (!initCompleted || loadingData) {
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
