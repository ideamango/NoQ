import 'package:LESSs/db/db_model/entity_slots.dart';
import 'package:LESSs/tuple.dart';
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
import '../widget/token_in_slot_list_page.dart';
import '../widget/widgets.dart';

enum SelectedView { list, bar, pie, line }
enum DateDisplayFormat { date, month, year }

class EntityTokenListPage extends StatefulWidget {
  final MetaEntity? metaEntity;
  final DateTime? defaultDate;
  final bool isReadOnly;
  final dynamic backRoute;
  EntityTokenListPage(
      {Key? key,
      required this.metaEntity,
      required this.defaultDate,
      required this.isReadOnly,
      required this.backRoute})
      : super(key: key);
  @override
  _EntityTokenListPageState createState() => _EntityTokenListPageState();
}

class _EntityTokenListPageState extends State<EntityTokenListPage>
    with SingleTickerProviderStateMixin {
  bool initCompleted = false;
  bool loadingData = true;
  GlobalState? _gs;
  List<Slot>? list;
  late Map<String, TokenStats> dataForDay;
  Map<String, TokenStats>? dataForMonth;
  Map<String, TokenStats>? dataForYear;
  String? formattedDateStr;
  DateTime? dateForShowingList;
  DateTime? yearForShowingList;
  DateTime? monthForShowingList;
  String? weekForShowingList;
  Map<String?, List<UserToken>?> _tokensMap = new Map<String?, List<UserToken>?>();
  Map<String, TokenStats> dataMap = new Map<String, TokenStats>();
  DateDisplayFormat selectedDateFormat = DateDisplayFormat.date;
  SelectedView selectedView = SelectedView.list;
  late Widget listWidget;
  late Widget barChartWidget;
  DateTime? selectedDate;
  List<Slot>? allSlotsList = [];
  TokenStats? emptyToken;
  TokenCounter? tokenCounterForYear;
  EntitySlots? entitySlotsForDay;
  late AnimationController _animationController;
  late Animation animation;

  @override
  void initState() {
    _animationController = new AnimationController(
        vsync: this, duration: Duration(milliseconds: 2000));
    _animationController.repeat(reverse: true);
    animation = Tween(begin: 0.5, end: 1.0).animate(_animationController);
    super.initState();
    emptyToken = TokenStats();
    emptyToken!.numberOfTokensCancelled = 0;
    emptyToken!.numberOfTokensCreated = 0;

    if (widget.defaultDate != null)
      selectedDate = widget.defaultDate;
    else
      selectedDate = DateTime.now();

    getGlobalState().whenComplete(() {
      dateForShowingList = selectedDate;

      getSlotsListForEntity(widget.metaEntity!, selectedDate!).then((value) {
        Tuple<EntitySlots, List<Slot>> slotTuple = value;
        entitySlotsForDay = slotTuple.item1;
        allSlotsList = slotTuple.item2;
        _gs!
            .getTokenService()!
            .getTokenCounterForEntity(
                widget.metaEntity!.entityId!, selectedDate!.year.toString())
            .then((value) {
          tokenCounterForYear = value;
          prepareData(selectedDate, DateDisplayFormat.date).then((value) {
            if (this.mounted) {
              setState(() {
                initCompleted = true;
              });
            } else
              initCompleted = true;
          });
        });
      });
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> getGlobalState() async {
    _gs = await GlobalState.getGlobalState();
  }

  Future<void> loadEntireYearData(String forYear) async {
    _gs!
        .getTokenService()!
        .getTokenCounterForEntity(widget.metaEntity!.entityId!, forYear)
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

  Future<void> getListOfDataForMonth(DateTime date) async {
    Tuple<EntitySlots, List<Slot>> slotTuple =
        await getSlotsListForEntity(widget.metaEntity!, date);
    list = slotTuple.item2;
    for (int i = 0; i <= list!.length - 1; i++) {
      List<UserToken>? tokensForThisSlot =
          await _gs!.getTokenService()!.getAllTokensForSlot(list![i].slotId);
      if (!Utils.isNullOrEmpty(tokensForThisSlot))
        _tokensMap[list![i].slotId] = tokensForThisSlot;
      // dataMap[Utils.formatTime(list[i].dateTime.hour.toString()) +
      //         ":" +
      //         Utils.formatTime(list[i].dateTime.minute.toString())] =
      //     tokensForThisSlot.length;
    }
    setState(() {
      loadingData = false;
    });

    return list;
  }

  Future<void> getListOfDataForYear(DateTime year) async {
    //TODO Smita: Get time-slots vs booked tokens for the entire year.

    //Dummy data for testing- start

    Tuple<EntitySlots, List<Slot>> slotTuple =
        await getSlotsListForEntity(widget.metaEntity!, dateForShowingList!);
    list = slotTuple.item2;
    for (int i = 0; i <= list!.length - 1; i++) {
      List<UserToken>? tokensForThisSlot =
          await _gs!.getTokenService()!.getAllTokensForSlot(list![i].slotId);
      if (!Utils.isNullOrEmpty(tokensForThisSlot))
        _tokensMap[list![i].slotId] = tokensForThisSlot;
      // dataMap[Utils.formatTime(list[i].dateTime.hour.toString()) +
      //         ":" +
      //         Utils.formatTime(list[i].dateTime.minute.toString())] =
      //     tokensForThisSlot.length;
    }

    // dataMap[Utils.formatTime() + ":" + Utils.formatTime()] =
    //     tokensForThisSlot.length;
    //Dummy data for testing- end

    setState(() {
      loadingData = false;
    });

    //return list;
  }

  void addEmptySlots(Map<String, TokenStats?> dataMap) {
    allSlotsList!.forEach((slot) {
      String time =
          slot.dateTime!.hour.toString() + ':' + slot.dateTime!.minute.toString();
      print(time);
      print(dataMap);
      if (!dataMap.containsKey(time)) {
        print('doesnt contain');
        dataMap[time] = emptyToken;
      }
    });
  }

  Widget buildAllSlots(Slot slot) {
    bool isHighlighted = false;
    String time =
        slot.dateTime!.hour.toString() + ':' + slot.dateTime!.minute.toString();

    Color? cardColor = Colors.grey[100];
    Color? textColor = highlightText;
    TokenStats? stats;
    DateTime currentTime = DateTime.now();

    if (dataMap.containsKey(time)) {
      stats = dataMap[time];
      cardColor = Colors.cyan[50];
    } else {
      stats = emptyToken;
    }
    if (currentTime.isAfter(slot.dateTime!) &&
        currentTime.isBefore(
            slot.dateTime!.add(Duration(minutes: slot.slotDuration!)))) {
      cardColor = highlightColor;
      isHighlighted = true;
    }

    if (isHighlighted) textColor = Colors.black;
    Widget rowCard = Card(
      color: cardColor,
      child: Container(
        padding: EdgeInsets.fromLTRB(12, 0, 8, 0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              Utils.formatTimeAsStr(time),
              style: TextStyle(
                  fontSize: 13,
                  color: textColor,
                  fontWeight:
                      isHighlighted ? FontWeight.bold : FontWeight.normal),
            ),
            Row(
              children: [
                AutoSizeText(
                  "Booked - " + stats!.numberOfTokensCreated.toString() + ", ",
                  minFontSize: 8,
                  maxFontSize: 13,
                  style: TextStyle(
                      color: textColor,
                      fontWeight:
                          isHighlighted ? FontWeight.bold : FontWeight.normal),
                ),
                AutoSizeText(
                  "Cancelled - " + stats.numberOfTokensCancelled.toString(),
                  minFontSize: 8,
                  maxFontSize: 13,
                  style: TextStyle(
                      color: textColor,
                      fontWeight:
                          isHighlighted ? FontWeight.bold : FontWeight.normal),
                ),
              ],
            ),
            IconButton(
              icon: Icon(
                Icons.open_in_new,
                color: textColor,
              ),
              onPressed: () {
                //getTokens in this slot.
                List<UserToken> tokenList = [];
                List<UserTokens?>? tokensList = [];
                for (var eSlot in entitySlotsForDay!.slots!) {
                  if (eSlot.slotId == slot.slotId) {
                    tokensList = eSlot.tokens;
                  }
                }

                for (UserTokens? uts in tokensList!) {
                  for (UserToken ut in uts!.tokens!) {
                    tokenList.add(ut);
                  }
                }

                Navigator.of(context)
                    .push(PageAnimation.createRoute(TokensInSlot(
                        slotKey: time,
                        stats: stats,
                        tokensList: tokenList,
                        date: selectedDate,
                        format: DateDisplayFormat.date,
                        metaEntity: widget.metaEntity,
                        isReadOnly: widget.isReadOnly,
                        backRoute: EntityTokenListPage(
                          metaEntity: widget.metaEntity,
                          backRoute: widget.backRoute,
                          defaultDate: selectedDate,
                          isReadOnly: widget.isReadOnly,
                        ))));
                // getTokenList(key, date, format).then((value) {
                print("DONEJHCFGJHSDCSDCH");
                // });
              },
            )
          ],
        ),
      ),
    );
    return (isHighlighted)
        ? FadeTransition(opacity: animation as Animation<double>, child: rowCard)
        : rowCard;
  }

  Future<void> prepareData(DateTime? date, DateDisplayFormat format) async {
    String? formattedDate;
    dataMap.clear();

    setState(() {
      barChartWidget = _emptyPage();
    });

    Tuple<EntitySlots, List<Slot>> slotTuple =
        await getSlotsListForEntity(widget.metaEntity!, selectedDate!);

    allSlotsList = slotTuple.item2;
    entitySlotsForDay = slotTuple.item1;

    switch (format) {
      case DateDisplayFormat.date:
        //Set display Date
        formattedDate = DateFormat(dateDisplayFormat).format(date!);
        //Fetch data of a day - which will be sorted based on time-slots
        if (tokenCounterForYear != null) {
          if (tokenCounterForYear!.year != date.year.toString()) {
            _gs!
                .getTokenService()!
                .getTokenCounterForEntity(
                    widget.metaEntity!.entityId!, date.year.toString())
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
                    tokenCounterForYear!.getTokenStatsSlotWiseForDay(date);

                dataForDay.forEach((k, v) {
                  dataMap[k.replaceAll('~', ':')] = v;
                });
              }
            });
          } else {
            dataForDay = tokenCounterForYear!.getTokenStatsSlotWiseForDay(date);

            if (dataForDay.length == 0) {
              listWidget = _emptyPage();
              barChartWidget = _emptyPage();
              setState(() {
                formattedDateStr = formattedDate;
                loadingData = false;
              });
              return;
            }
            dataForDay.forEach((k, v) {
              dataMap[k.replaceAll('~', ':')] = v;
            });
            //addEmptySlots(dataMap);
          }
        } else {
          _gs!
              .getTokenService()!
              .getTokenCounterForEntity(
                  widget.metaEntity!.entityId!, date.year.toString())
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
                  tokenCounterForYear!.getTokenStatsSlotWiseForDay(date);
              dataForDay.forEach((k, v) {
                dataMap[k.replaceAll('~', ':')] = v;
              });
            }
          });
        }
        listWidget = Expanded(
          child: ListView.builder(
              itemCount: allSlotsList!.length,
              itemBuilder: (BuildContext context, int index) {
                return Container(
                  margin: EdgeInsets.fromLTRB(10, 0, 10, 5),
                  child: new Column(children: [
                    buildAllSlots(allSlotsList![index]),
                  ]),
                );
              }),
        );
        // listWidget = (dataMap != null)
        //     ? ((dataMap.length != 0)
        //         ? Expanded(
        //             child: ListView.builder(
        //                 itemCount: dataMap.length,
        //                 itemBuilder: (BuildContext context, int index) {
        //                   String key = dataMap.keys.elementAt(index);
        //                   return Container(
        //                     margin: EdgeInsets.fromLTRB(10, 0, 10, 50),
        //                     child: new Column(children: [
        //                       buildItem(key, dataMap[key], date, format)
        //                     ]),
        //                   );
        //                 }),
        //           )
        //         : _emptyPage())
        //     : _emptyPage();
        barChartWidget = (dataMap.length != 0)
            ? Container(
                height: MediaQuery.of(context).size.height * .7,
                width: MediaQuery.of(context).size.width * .95,
                child: ListView(children: <Widget>[
                  BarChartGraph(
                    dataMap: dataMap,
                    metaEn: widget.metaEntity,
                  ),
                ]),
              )
            : _emptyPage();

        break;
      case DateDisplayFormat.month:
        //Set display Date
        formattedDate = DateFormat.MMMM().format(date!).substring(0, 3) +
            ", " +
            date.year.toString();
        //Fetch data of month - which will be sorted based on days
        if (tokenCounterForYear != null) {
          if (tokenCounterForYear!.year != date.year.toString()) {
            _gs!
                .getTokenService()!
                .getTokenCounterForEntity(
                    widget.metaEntity!.entityId!, date.year.toString())
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
                dataForMonth = tokenCounterForYear!
                    .getTokenStatsDayWiseForMonth(date.month);
                dataForMonth!.forEach((k, v) {
                  dataMap[k.replaceAll('~', ':')] = v;
                });
              }
            });
          } else {
            dataForMonth =
                tokenCounterForYear!.getTokenStatsDayWiseForMonth(date.month);
            print(dataForMonth!.length);
            dataForMonth!.forEach((k, v) {
              dataMap[k.replaceAll('~', ':')] = v;
            });
          }
        } else {
          _gs!
              .getTokenService()!
              .getTokenCounterForEntity(
                  widget.metaEntity!.entityId!, date.year.toString())
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
                  tokenCounterForYear!.getTokenStatsDayWiseForMonth(date.month);
              dataForMonth!.forEach((k, v) {
                dataMap[k.replaceAll('~', ':')] = v;
              });
            }
          });
        }

        listWidget = (dataForMonth != null)
            ? (dataForMonth!.length != 0
                ? Expanded(
                    child: ListView.builder(
                        itemCount: dataForMonth!.length,
                        itemBuilder: (BuildContext context, int index) {
                          String key = dataForMonth!.keys.elementAt(index);
                          return Container(
                            margin: EdgeInsets.fromLTRB(10, 0, 10, 50),
                            child: new Column(children: [
                              buildItem(key, dataForMonth![key]!, date, format)
                            ]),
                          );
                        }),
                  )
                : _emptyPage())
            : _emptyPage();
        barChartWidget = (dataMap.length != 0)
            ? Container(
                height: MediaQuery.of(context).size.height * .7,
                width: MediaQuery.of(context).size.width * .95,
                child: ListView(children: <Widget>[
                  BarChartGraph(
                    dataMap: dataMap,
                    metaEn: widget.metaEntity,
                  ),
                ]),
              )
            : _emptyPage();
        break;
      case DateDisplayFormat.year:
        formattedDate = date!.year.toString();
        if (tokenCounterForYear != null) {
          if (tokenCounterForYear!.year != date.year.toString()) {
            //fetch data
            _gs!
                .getTokenService()!
                .getTokenCounterForEntity(
                    widget.metaEntity!.entityId!, date.year.toString())
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
                    tokenCounterForYear!.getTokenStatsMonthWiseForYear();
                dataForYear!.forEach((k, v) {
                  dataMap[k.replaceAll('~', ':')] = v;
                });
              }
            });
          } else {
            dataForYear = tokenCounterForYear!.getTokenStatsMonthWiseForYear();
            dataForYear!.forEach((k, v) {
              dataMap[k.replaceAll('~', ':')] = v;
            });
          }
        } else {
          _gs!
              .getTokenService()!
              .getTokenCounterForEntity(
                  widget.metaEntity!.entityId!, date.year.toString())
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
              dataForYear = tokenCounterForYear!.getTokenStatsMonthWiseForYear();
              dataForYear!.forEach((k, v) {
                dataMap[k.replaceAll('~', ':')] = v;
              });
            }
          });
        }
        listWidget = dataForYear != null
            ? ((dataForYear!.length != 0)
                ? Expanded(
                    child: ListView.builder(
                        itemCount: dataForYear!.length,
                        itemBuilder: (BuildContext context, int index) {
                          String key = dataForYear!.keys.elementAt(index);
                          return Container(
                            margin: EdgeInsets.fromLTRB(10, 0, 10, 50),
                            child: new Column(children: [
                              buildItem(key, dataForYear![key]!, date, format)
                            ]),
                          );
                        }),
                  )
                : _emptyPage())
            : _emptyPage();

        barChartWidget = (dataMap.length != 0)
            ? Container(
                height: MediaQuery.of(context).size.height * .7,
                width: MediaQuery.of(context).size.width * .95,
                child: ListView(children: <Widget>[
                  BarChartGraph(
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

  Widget buildItem(
      String key, TokenStats stats, DateTime? date, DateDisplayFormat format) {
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
            icon: Icon(Icons.details),
            onPressed: () {
              Navigator.of(context).push(new MaterialPageRoute(
                  builder: (BuildContext context) => TokensInSlot(
                      slotKey: key,
                      stats: stats,
                      date: date,
                      format: DateDisplayFormat.date,
                      metaEntity: widget.metaEntity,
                      isReadOnly: widget.isReadOnly,
                      backRoute: EntityTokenListPage(
                        metaEntity: widget.metaEntity,
                        backRoute: widget.backRoute,
                        defaultDate: selectedDate,
                        isReadOnly: widget.isReadOnly,
                      ))));
              // getTokenList(key, date, format).then((value) {
              print("DONEJHCFGJHSDCSDCH");
              // });
            },
          )
        ],
      ),
    );
  }

  Future<DateTime?> pickAnyDate(BuildContext context) async {
    DateTime? date = await showDatePicker(
      context: context,
      firstDate: DateTime.now().subtract(Duration(days: 365)),
      lastDate: DateTime.now().add(Duration(days: 60)),
      initialDate: selectedDate!,
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

  Future<DateTime?> pickAnyYear(BuildContext context, DateTime date) async {
    DateTime? returnVal = await showDialog(
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
      return Scaffold(
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
                        width: MediaQuery.of(context).size.width * .45,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Icon(Icons.date_range),
                            SizedBox(width: 5),
                            Container(
                              width: MediaQuery.of(context).size.width * .25,
                              child: AutoSizeText(
                                formattedDateStr!,
                                minFontSize: 10,
                                maxFontSize: 17,
                                maxLines: 2,
                                style: TextStyle(
                                    color: btnColor,
                                    fontWeight: FontWeight.bold,
                                    fontFamily: 'RalewayRegular'),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Container(
                      width: MediaQuery.of(context).size.width * .4,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          IconButton(
                            icon: Icon(Icons.bar_chart, color: disabledColor),
                            onPressed: () {
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
                    ),
                  ],
                )),
                Container(
                    padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Container(
                          decoration: buttonBackground,
                          //width: MediaQuery.of(context).size.width * .18,
                          height: MediaQuery.of(context).size.width * .08,
                          child: FlatButton(
                            visualDensity: VisualDensity.compact,
                            color: Colors.transparent,
                            textColor: Colors.white,
                            shape: RoundedRectangleBorder(
                                side: BorderSide(color: btnColor!),
                                borderRadius:
                                    BorderRadius.all(Radius.circular(100.0))),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.arrow_back_ios,
                                  size: 15,
                                ),
                                Text(
                                  ' Prev',
                                  style: TextStyle(fontSize: 15),
                                ),
                              ],
                            ),
                            onPressed: () {
                              selectedDate =
                                  selectedDate!.subtract(Duration(days: 1));
                              formattedDateStr = DateFormat(dateDisplayFormat)
                                  .format(selectedDate!);
                              setState(() {
                                loadingData = true;
                              });
                              selectedDateFormat = DateDisplayFormat.date;
                              prepareData(selectedDate, selectedDateFormat);
                            },
                          ),
                        ),

                        Container(
                          decoration: buttonBackground,
                          width: MediaQuery.of(context).size.width * .35,
                          height: MediaQuery.of(context).size.width * .08,
                          child: FlatButton(
                            visualDensity: VisualDensity.compact,
                            color: Colors.transparent,
                            textColor: Colors.white,
                            // shape: RoundedRectangleBorder(
                            //     side: BorderSide(color: btnColor),
                            //     borderRadius:
                            //         BorderRadius.all(Radius.circular(100.0))),
                            child: Text(
                              'Select Date',
                              style: TextStyle(fontSize: 15),
                            ),
                            onPressed: () {
                              //TODO SMITA - fetch data for showdatafordate
                              pickAnyDate(context).then((value) {
                                if (value != null) {
                                  print(value);
                                  setState(() {
                                    loadingData = true;
                                    selectedDate = value;
                                  });
                                  selectedDateFormat = DateDisplayFormat.date;
                                  prepareData(value, selectedDateFormat);
                                }
                              });
                            },
                          ),
                        ),

                        Container(
                          decoration: buttonBackground,
                          //width: MediaQuery.of(context).size.width * .18,
                          height: MediaQuery.of(context).size.width * .08,
                          child: FlatButton(
                              visualDensity: VisualDensity.compact,
                              // color: (selectedDateFormat ==
                              //         DateDisplayFormat.date)
                              //     ? btnColor
                              //     : Colors.transparent,
                              color: Colors.transparent,
                              textColor:
                                  (selectedDateFormat == DateDisplayFormat.date)
                                      ? Colors.white
                                      : btnColor,
                              // shape: RoundedRectangleBorder(
                              //     borderRadius: BorderRadius.all(
                              //         Radius.circular(100.0))),
                              child: Row(
                                children: [
                                  Text(
                                    'Next ',
                                    style: TextStyle(fontSize: 15),
                                  ),
                                  Icon(
                                    Icons.arrow_forward_ios,
                                    size: 15,
                                  )
                                ],
                              ),
                              onPressed: () {
                                //TODO SMITA - fetch data for showdatafordate
                                // pickAnyDate(context).then((value) {
                                //   if (value != null) {
                                //     print(value);
                                selectedDate =
                                    selectedDate!.add(Duration(days: 1));
                                formattedDateStr = DateFormat(dateDisplayFormat)
                                    .format(selectedDate!);
                                setState(() {
                                  loadingData = true;
                                });
                                selectedDateFormat = DateDisplayFormat.date;
                                prepareData(selectedDate, selectedDateFormat);
                              }
                              // });
                              // },
                              ),
                        ),

                        //TODO Phase2 - Show data for month and year

                        // SizedBox(
                        //   // width: MediaQuery.of(context).size.width * .18,
                        //   height: MediaQuery.of(context).size.width * .08,
                        //   child: FlatButton(
                        //     visualDensity: VisualDensity.compact,
                        //     color: (selectedDateFormat ==
                        //             DateDisplayFormat.month)
                        //         ? btnColor
                        //         : Colors.transparent,
                        //     textColor: (selectedDateFormat ==
                        //             DateDisplayFormat.month)
                        //         ? Colors.white
                        //         : btnColor,
                        //     shape: RoundedRectangleBorder(
                        //         side: BorderSide(color: btnColor),
                        //         borderRadius:
                        //             BorderRadius.all(Radius.circular(100.0))),
                        //     child: Text(
                        //       'Month',
                        //       style: TextStyle(fontSize: 11),
                        //     ),
                        //     onPressed: () {
                        //       showMonthPicker(
                        //               context: context,
                        //               firstDate: DateTime(
                        //                   DateTime.now().year - 2, 12),
                        //               lastDate: DateTime(
                        //                   DateTime.now().year + 1, 12),
                        //               initialDate: dateForShowingList)
                        //           .then((value) => setState(() {
                        //                 print(value);
                        //                 if (value != null) {
                        //                   setState(() {
                        //                     loadingData = true;
                        //                   });
                        //                   selectedDateFormat =
                        //                       DateDisplayFormat.month;
                        //                   prepareData(
                        //                       value, selectedDateFormat);

                        //                   //fetch data for the month (check getListOfData)
                        //                 }
                        //                 // selectedDate = date;
                        //               }));
                        //     },
                        //   ),
                        // ),
                        // SizedBox(
                        //   // width: MediaQuery.of(context).size.width * .18,
                        //   height: MediaQuery.of(context).size.width * .08,
                        //   child: FlatButton(
                        //     visualDensity: VisualDensity.compact,
                        //     padding: EdgeInsets.zero,
                        //     color:
                        //         (selectedDateFormat == DateDisplayFormat.year)
                        //             ? btnColor
                        //             : Colors.transparent,
                        //     textColor:
                        //         (selectedDateFormat == DateDisplayFormat.year)
                        //             ? Colors.white
                        //             : btnColor,
                        //     shape: RoundedRectangleBorder(
                        //         side: BorderSide(color: btnColor),
                        //         borderRadius:
                        //             BorderRadius.all(Radius.circular(100.0))),
                        //     child: Text(
                        //       'Year',
                        //       style: TextStyle(fontSize: 11),
                        //     ),
                        //     onPressed: () {
                        //       //TODO SMITA - fetch data for year showdatafordate
                        //       pickAnyYear(context, dateForShowingList)
                        //           .then((value) {
                        //         if (value != null) {
                        //           print(value);
                        //           setState(() {
                        //             loadingData = true;
                        //           });
                        //           selectedDateFormat = DateDisplayFormat.year;
                        //           prepareData(value, selectedDateFormat);
                        //         }
                        //       });
                        //     },
                        //   ),
                        // ),
                      ],
                    )),
                SizedBox(
                  height: 10,
                ),
                //(!Utils.isNullOrEmpty(list)) ? showListOfData : _emptyPage(),

                (selectedView == SelectedView.list)
                    ? listWidget
                    : barChartWidget,
              ],
            ),
          ),
        ),
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
