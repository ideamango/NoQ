import 'package:LESSs/db/db_model/entity_slots.dart';
import 'package:LESSs/tuple.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../constants.dart';
import '../db/db_model/booking_application.dart';
import '../db/db_model/meta_entity.dart';
import '../db/db_model/slot.dart';
import '../db/db_model/user_token.dart';
import '../global_state.dart';
import '../pages/bar_chart_applications.dart';
import '../pages/manage_entity_list_page.dart';
import '../pages/overview_page.dart';
import '../pages/pie_chart.dart';
import '../repository/slotRepository.dart';
import '../services/circular_progress.dart';
import '../services/month_picker_dialog.dart';
import '../style.dart';
import '../userHomePage.dart';
import '../utils.dart';
import '../widget/appbar.dart';
import '../widget/page_animation.dart';
import '../widget/widgets.dart';

enum SelectedView { list, bar, pie, line }
enum DateDisplayFormat { date, month, year }

class EntityApplicationListPage extends StatefulWidget {
  final String? bookingFormId;
  final String? bookingFormName;
  final MetaEntity? metaEntity;
  final bool isReadOnly;
  EntityApplicationListPage(
      {Key? key,
      required this.bookingFormId,
      required this.bookingFormName,
      required this.metaEntity,
      required this.isReadOnly})
      : super(key: key);
  @override
  _EntityApplicationListPageState createState() =>
      _EntityApplicationListPageState();
}

class _EntityApplicationListPageState extends State<EntityApplicationListPage> {
  bool initCompleted = false;
  bool loadingData = false;
  GlobalState? _gs;
  List<Slot>? list;
  String? formattedDateStr;
  DateTime? dateForShowingList;
  DateTime? yearForShowingList;
  DateTime? monthForShowingList;
  String? weekForShowingList;
  Map<String?, List<UserToken>> _tokensMap = new Map<String?, List<UserToken>>();
  Map<String, int> dataMap = new Map<String, int>();
  SelectedView selectedView = SelectedView.bar;
  BookingApplicationCounter? _bookingApplicationsOverview;
  Map<String, double> pieChartDataMap = new Map<String, double>();
  String? dailyStatsKey;
  bool dataMapZeroValues = true;
  @override
  void initState() {
    super.initState();
    getGlobalState().whenComplete(() {
      dateForShowingList = DateTime.now();
      getListOfData(dateForShowingList!);
      setShowDate(DateTime.now(), DateDisplayFormat.date);
      dailyStatsKey = DateTime.now().year.toString() +
          "~" +
          DateTime.now().month.toString() +
          "~" +
          DateTime.now().day.toString();

      _gs!
          .getApplicationService()!
          .getApplicationsOverview(widget.bookingFormId,
              widget.metaEntity!.entityId, DateTime.now().year)
          .then((value) {
        _bookingApplicationsOverview = value;

        //Before accessing check if there are any request for today.
        if (_bookingApplicationsOverview!.dailyStats!
            .containsKey(dailyStatsKey)) {
          pieChartDataMap["New"] = _bookingApplicationsOverview!
              .dailyStats![dailyStatsKey!]!.numberOfNew!
              .toDouble();

          pieChartDataMap["On-Hold"] = _bookingApplicationsOverview!
              .dailyStats![dailyStatsKey!]!.numberOfPutOnHold!
              .toDouble();
          pieChartDataMap["Rejected"] = _bookingApplicationsOverview!
              .dailyStats![dailyStatsKey!]!.numberOfRejected!
              .toDouble();

          pieChartDataMap["Approved"] = _bookingApplicationsOverview!
              .dailyStats![dailyStatsKey!]!.numberOfApproved!
              .toDouble();

          pieChartDataMap["Completed"] = _bookingApplicationsOverview!
              .dailyStats![dailyStatsKey!]!.numberOfCompleted!
              .toDouble();
        } else {
          print("No Data");
        }

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
    dataMapZeroValues = true;
    Tuple<EntitySlots, List<Slot>> slotTuple =
        await getSlotsListForEntity(widget.metaEntity!, date);
    list = slotTuple.item2;
    for (int i = 0; i <= list!.length - 1; i++) {
      List<UserToken> tokensForThisSlot =
          await (_gs!.getTokenService()!.getAllTokensForSlot(list![i].slotId) as FutureOr<List<UserToken>>);
      if (!Utils.isNullOrEmpty(tokensForThisSlot))
        _tokensMap[list![i].slotId] = tokensForThisSlot;
      dataMap[Utils.formatTime(list![i].dateTime!.hour.toString()) +
              ":" +
              Utils.formatTime(list![i].dateTime!.minute.toString())] =
          tokensForThisSlot.length;
      if (tokensForThisSlot.length != 0) dataMapZeroValues = false;
    }
    setState(() {
      loadingData = false;
    });

    return list;
  }

  Future<void> getListOfDataForMonth(DateTime date) async {
    dataMapZeroValues = true;
    Tuple<EntitySlots, List<Slot>> slotTuple =
        await getSlotsListForEntity(widget.metaEntity!, date);
    list = slotTuple.item2;
    for (int i = 0; i <= list!.length - 1; i++) {
      List<UserToken> tokensForThisSlot =
          await (_gs!.getTokenService()!.getAllTokensForSlot(list![i].slotId) as FutureOr<List<UserToken>>);
      if (!Utils.isNullOrEmpty(tokensForThisSlot))
        _tokensMap[list![i].slotId] = tokensForThisSlot;
      dataMap[Utils.formatTime(list![i].dateTime!.hour.toString()) +
              ":" +
              Utils.formatTime(list![i].dateTime!.minute.toString())] =
          tokensForThisSlot.length;
      if (tokensForThisSlot.length != 0) dataMapZeroValues = false;
    }
    setState(() {
      loadingData = false;
    });

    return list;
  }

  Future<void> getListOfDataForYear(DateTime year) async {
    dataMapZeroValues = true;
    //TODO Smita: Get time-slots vs booked tokens for the entire year.

    //Dummy data for testing- start

    Tuple<EntitySlots, List<Slot>> slotTuple =
        await getSlotsListForEntity(widget.metaEntity!, dateForShowingList!);
    list = slotTuple.item2;
    for (int i = 0; i <= list!.length - 1; i++) {
      List<UserToken> tokensForThisSlot =
          await (_gs!.getTokenService()!.getAllTokensForSlot(list![i].slotId) as FutureOr<List<UserToken>>);
      if (!Utils.isNullOrEmpty(tokensForThisSlot))
        _tokensMap[list![i].slotId] = tokensForThisSlot;
      dataMap[Utils.formatTime(list![i].dateTime!.hour.toString()) +
              ":" +
              Utils.formatTime(list![i].dateTime!.minute.toString())] =
          tokensForThisSlot.length;
      if (tokensForThisSlot.length != 0) dataMapZeroValues = false;
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
    String? formattedDate;
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
                  child: Column(
                    children: [
                      Text("No Applications Found.",
                          style: TextStyle(
                            color: Colors.blueGrey[900],
                            // fontWeight: FontWeight.w800,
                            fontFamily: 'RalewayRegular',
                            letterSpacing: 0.8,
                            fontSize: 18.0,
                            //height: 2,
                          )),
                      Text("Try with another date!",
                          style: TextStyle(
                            color: Colors.blueGrey[900],
                            // fontWeight: FontWeight.w800,
                            fontFamily: 'RalewayRegular',
                            letterSpacing: 0.8,
                            fontSize: 14.0,
                            height: 1.5,
                          )),
                    ],
                  ),
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

    return list!.map(buildItem).toList();
  }

  refreshDataView(DateTime date, DateDisplayFormat format) {
    // String formattedDate;
    bool statsPresent = false;
    switch (format) {
      case DateDisplayFormat.date:
        _gs!
            .getApplicationService()!
            .getApplicationsOverview(
                widget.bookingFormId, widget.metaEntity!.entityId, date.year)
            .then((value) {
          _bookingApplicationsOverview = value;
          dailyStatsKey = date.year.toString() +
              "~" +
              date.month.toString() +
              "~" +
              date.day.toString();
          statsPresent = (_bookingApplicationsOverview!.dailyStats!
                  .containsKey(dailyStatsKey))
              ? true
              : false;

          pieChartDataMap["New"] = statsPresent
              ? _bookingApplicationsOverview!
                  .dailyStats![dailyStatsKey!]!.numberOfNew!
                  .toDouble()
              : 0;
          pieChartDataMap["On-Hold"] = statsPresent
              ? _bookingApplicationsOverview!
                  .dailyStats![dailyStatsKey!]!.numberOfPutOnHold!
                  .toDouble()
              : 0;
          pieChartDataMap["Rejected"] = statsPresent
              ? _bookingApplicationsOverview!
                  .dailyStats![dailyStatsKey!]!.numberOfRejected!
                  .toDouble()
              : 0;
          pieChartDataMap["Approved"] = statsPresent
              ? _bookingApplicationsOverview!
                  .dailyStats![dailyStatsKey!]!.numberOfApproved!
                  .toDouble()
              : 0;
          pieChartDataMap["Completed"] = statsPresent
              ? _bookingApplicationsOverview!
                  .dailyStats![dailyStatsKey!]!.numberOfCompleted!
                  .toDouble()
              : 0;
          setState(() {});
        });
        break;
      case DateDisplayFormat.month:
        _gs!
            .getApplicationService()!
            .getApplicationsOverview(
                widget.bookingFormId, widget.metaEntity!.entityId, date.year)
            .then((value) {
          _bookingApplicationsOverview = value;
          dailyStatsKey = date.year.toString() + "~" + date.month.toString();

          int numberOfNew = 0;
          int numberOfPutOnHold = 0;
          int numberOfRejected = 0;
          int numberOfApproved = 0;
          int numberOfCompleted = 0;

          for (var key in _bookingApplicationsOverview!.dailyStats!.keys) {
            if (key.contains(dailyStatsKey!)) {
              numberOfNew = numberOfNew +
                  _bookingApplicationsOverview!.dailyStats![key]!.numberOfNew!;
              numberOfPutOnHold = numberOfPutOnHold +
                  _bookingApplicationsOverview!
                      .dailyStats![key]!.numberOfPutOnHold!;
              numberOfRejected = numberOfRejected +
                  _bookingApplicationsOverview!.dailyStats![key]!.numberOfRejected!;
              numberOfApproved = numberOfApproved +
                  _bookingApplicationsOverview!.dailyStats![key]!.numberOfApproved!;
              numberOfCompleted = numberOfCompleted +
                  _bookingApplicationsOverview!
                      .dailyStats![key]!.numberOfCompleted!;
            }
          }

          pieChartDataMap["New"] = numberOfNew.toDouble();
          pieChartDataMap["On-Hold"] = numberOfPutOnHold.toDouble();
          pieChartDataMap["Rejected"] = numberOfRejected.toDouble();
          pieChartDataMap["Approved"] = numberOfApproved.toDouble();
          pieChartDataMap["Completed"] = numberOfCompleted.toDouble();
          setState(() {});
        });
        break;
      case DateDisplayFormat.year:
        _gs!
            .getApplicationService()!
            .getApplicationsOverview(
                widget.bookingFormId, widget.metaEntity!.entityId, date.year)
            .then((value) {
          _bookingApplicationsOverview = value;
          statsPresent = _bookingApplicationsOverview != null ? true : false;
          pieChartDataMap["New"] = statsPresent
              ? _bookingApplicationsOverview!.numberOfNew!.toDouble()
              : 0;
          pieChartDataMap["On-Hold"] = statsPresent
              ? _bookingApplicationsOverview!.numberOfPutOnHold!.toDouble()
              : 0;
          pieChartDataMap["Rejected"] = statsPresent
              ? _bookingApplicationsOverview!.numberOfRejected!.toDouble()
              : 0;
          pieChartDataMap["Approved"] = statsPresent
              ? _bookingApplicationsOverview!.numberOfApproved!.toDouble()
              : 0;
          pieChartDataMap["Completed"] = statsPresent
              ? _bookingApplicationsOverview!.numberOfCompleted!.toDouble()
              : 0;
          setState(() {});
        });
        //formattedDate = date.year.toString();
        break;
      default:
        break;
    }
  }

  buildChildItem(UserToken token) {
    return Container(
      padding: EdgeInsets.all(0),
      child: Card(
          child: Row(
        children: [
          Container(
              width: MediaQuery.of(context).size.width * .4,
              padding: EdgeInsets.all(8),
              child: Text(token.parent!.userId!,
                  style: TextStyle(
                      //fontFamily: "RalewayRegular",
                      color: Colors.blueGrey[800],
                      fontSize: 13))),
          if (token.bookingFormName != null)
            Container(
                width: MediaQuery.of(context).size.width * .4,
                padding: EdgeInsets.all(8),
                child: Text(token.bookingFormName!,
                    style: TextStyle(
                        //fontFamily: "RalewayRegular",
                        color: Colors.blueGrey[800],
                        fontSize: 13))),
        ],
      )),
    );
  }

  Widget buildItem(Slot slot) {
    List<UserToken>? tokens = _tokensMap[slot.slotId];
    String fromTime = Utils.formatTime(slot.dateTime!.hour.toString()) +
        ":" +
        Utils.formatTime(slot.dateTime!.minute.toString());

    String toTime = Utils.formatTime(slot.dateTime!
            .add(new Duration(minutes: slot.slotDuration!))
            .hour
            .toString()) +
        ":" +
        Utils.formatTime(slot.dateTime!
            .add(new Duration(minutes: slot.slotDuration!))
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
                      slot.totalBooked.toString() + " tokens",
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
                              border: Border.all(color: Colors.grey[300]!),
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
                                    child: buildChildItem(tokens![index]),
                                  );
                                },
                                itemCount: tokens!.length,
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

  Future<DateTime?> pickAnyDate(BuildContext context) async {
    DateTime? date = await showDatePicker(
      context: context,
      firstDate: DateTime.now().subtract(Duration(days: 365)),
      lastDate: DateTime.now().add(Duration(days: 60)),
      initialDate: DateTime.now(),
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: ThemeData.dark().copyWith(
            colorScheme: ColorScheme.light(
              primary: Colors.cyan,
            ),
            dialogBackgroundColor: Colors.white,
          ),
          child: child!,
        );
      },
    );
    return date;
  }

  Future<DateTime?> pickAnyYear(BuildContext context, DateTime? date) async {
    DateTime? returnVal = await showDialog(
        context: context,
        builder: (BuildContext context) {
          DateTime? selectedYear = date;
          String yearStr;
          return StatefulBuilder(builder: (context, setState) {
            return AlertDialog(
              titlePadding: EdgeInsets.zero,
              contentPadding: EdgeInsets.fromLTRB(5, 30, 5, 30),
              title: Container(
                height: MediaQuery.of(context).size.height * .08,
                padding: EdgeInsets.fromLTRB(15, 15, 15, 15),
                color: Colors.cyan,
                child: Text("Year ${selectedYear!.year.toString()}",
                    style: TextStyle(
                        color: Colors.white, fontWeight: FontWeight.normal)),
              ),
              content: Container(
                  child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    height: 45,
                    child: FlatButton(
                      visualDensity: VisualDensity.compact,
                      padding: EdgeInsets.zero,
                      color: (selectedYear!.year == date!.year - 1)
                          ? Colors.cyan
                          : Colors.transparent,
                      textColor: (selectedYear!.year == date.year - 1)
                          ? Colors.white
                          : Colors.cyan,
                      shape: CircleBorder(
                        side: BorderSide(
                            color: (selectedYear!.year == date.year - 1)
                                ? btnColor!
                                : Colors.transparent),
                      ),
                      child: Text(
                        (date.year - 1).toString(),
                        style: TextStyle(
                            fontSize: 15,
                            color: (selectedYear!.year == date.year - 1)
                                ? Colors.white
                                : Colors.blueGrey[600],
                            fontWeight: FontWeight.normal),
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
                    height: 45,
                    child: FlatButton(
                      visualDensity: VisualDensity.compact,
                      padding: EdgeInsets.zero,
                      color: (selectedYear!.year == date.year)
                          ? Colors.cyan
                          : Colors.transparent,
                      textColor: (selectedYear!.year == date.year)
                          ? Colors.white
                          : Colors.blueGrey[700],
                      shape: CircleBorder(
                        side: BorderSide(
                            color: (selectedYear!.year == date.year)
                                ? btnColor!
                                : Colors.transparent),
                      ),
                      child: Text(
                        (date.year).toString(),
                        style: TextStyle(
                            fontSize: 15,
                            color: (selectedYear!.year == date.year)
                                ? Colors.white
                                : Colors.blueGrey[600],
                            fontWeight: FontWeight.normal),
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
                    height: 45,
                    child: FlatButton(
                      visualDensity: VisualDensity.compact,
                      padding: EdgeInsets.zero,
                      color: (selectedYear!.year == date.year + 1)
                          ? Colors.cyan
                          : Colors.transparent,
                      textColor: (selectedYear!.year == date.year + 1)
                          ? Colors.white
                          : Colors.cyan,
                      shape: CircleBorder(
                        side: BorderSide(
                            color: (selectedYear!.year == date.year + 1)
                                ? btnColor!
                                : Colors.transparent),
                      ),
                      child: Text(
                        (date.year + 1).toString(),
                        style: TextStyle(
                            fontSize: 15,
                            color: (selectedYear!.year == date.year + 1)
                                ? Colors.white
                                : Colors.blueGrey[600],
                            fontWeight: FontWeight.normal),
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
      return new WillPopScope(
        child: Scaffold(
          appBar: CustomAppBarWithBackButton(
            backRoute: ManageEntityListPage(),
            titleTxt: "Application Requests Overview ",
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
                              Icon(Icons.date_range,
                                  color: Colors.blueGrey[600]),
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
                                            color: Colors.blueGrey[600],
                                            fontSize: 14),
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
                              Icons.pie_chart_rounded,
                              color: Colors.blueGrey[600],
                            ),
                            onPressed: () {
                              setState(() {
                                selectedView = SelectedView.pie;
                              });
                            },
                          ),
                          IconButton(
                            icon: Icon(Icons.bar_chart,
                                color: Colors.blueGrey[600]),
                            onPressed: () {
                              setState(() {
                                selectedView = SelectedView.bar;
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
                            height: MediaQuery.of(context).size.width * .08,
                            child: FlatButton(
                              visualDensity: VisualDensity.compact,
                              color: Colors.transparent,
                              textColor: btnColor,
                              shape: RoundedRectangleBorder(
                                  side: BorderSide(color: btnColor!),
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
//Update pie chart
                                    refreshDataView(
                                        value, DateDisplayFormat.date);
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
                                  side: BorderSide(color: btnColor!),
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(100.0))),
                              child: Text(
                                'Month',
                                style: TextStyle(fontSize: 11),
                              ),
                              onPressed: () {
                                //Show data for a month
                                showMonthPicker(
                                        context: context,
                                        firstDate: DateTime(
                                            DateTime.now().year - 2, 12),
                                        lastDate: DateTime(
                                            DateTime.now().year + 1, 12),
                                        initialDate: dateForShowingList!)
                                    .then((date) => setState(() {
                                          print(date);
                                          if (date != null) {
                                            setShowDate(
                                                date, DateDisplayFormat.month);
                                            setState(() {
                                              loadingData = true;
                                            });
                                            getListOfDataForMonth(date);
                                            refreshDataView(
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
                                  side: BorderSide(color: btnColor!),
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
                                    refreshDataView(
                                        value, DateDisplayFormat.year);
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
                  (selectedView == SelectedView.pie)
                      ? pieChartDataMap != null
                          ? ((pieChartDataMap.length == 0)
                              ? Container(
                                  height:
                                      MediaQuery.of(context).size.height * .7,
                                  width:
                                      MediaQuery.of(context).size.width * .95,
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text("No Applications for chosen date!"),
                                      SizedBox(
                                        height: 3,
                                      ),
                                      Text(
                                        "Try another Day, Month or Year",
                                        style: lightSubTextStyle,
                                      ),
                                    ],
                                  ),
                                )
                              : Container(
                                  height:
                                      MediaQuery.of(context).size.height * .7,
                                  width:
                                      MediaQuery.of(context).size.width * .95,
                                  child: EntityPieChart(
                                      pieChartDataMap: pieChartDataMap)))
                          : Container(
                              height: MediaQuery.of(context).size.height * .7,
                              width: MediaQuery.of(context).size.width * .95,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text("No Data"),
                                ],
                              ),
                            )
                      :
                      //(!Utils.isNullOrEmpty(list)) ? showListOfData : _emptyPage(),
                      ((selectedView == SelectedView.bar)
                          ?

                          //If selected view is Bar chart
                          //if datamap has some tokens then show bar chart else empty page
                          (dataMapZeroValues == false
                              ? Container(
                                  height:
                                      MediaQuery.of(context).size.height * .7,
                                  width:
                                      MediaQuery.of(context).size.width * .95,
                                  child: ListView(children: <Widget>[
                                    BarChartApplications(
                                      dataMap: dataMap,
                                      metaEn: widget.metaEntity,
                                    ),
                                  ]),
                                )
                              : _emptyPage())
                          : (!Utils.isNullOrEmpty(list)
                              ? Expanded(
                                  child: ListView.builder(
                                      itemCount: 1,
                                      itemBuilder:
                                          (BuildContext context, int index) {
                                        return Container(
                                          margin: EdgeInsets.fromLTRB(
                                              10, 0, 10, 50),
                                          child: new Column(
                                            children:
                                                list!.map(buildItem).toList(),
                                          ),
                                        );
                                      }),
                                )
                              : _emptyPage())),
                ],
              ),
            ),
          ),
        ),
        onWillPop: () async {
          return true;
        },
      );
    } else if (!initCompleted || loadingData) {
      return new WillPopScope(
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
      );
    }
  }
}
