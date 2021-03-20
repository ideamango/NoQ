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
import 'package:noq/style.dart';
import 'package:noq/userHomePage.dart';
import 'package:noq/utils.dart';
import 'package:noq/widget/appbar.dart';
import 'package:noq/widget/page_animation.dart';

class EntityTokenListPage extends StatefulWidget {
  final MetaEntity metaEntity;
  EntityTokenListPage({Key key, @required this.metaEntity}) : super(key: key);
  @override
  _EntityTokenListPageState createState() => _EntityTokenListPageState();
}

class _EntityTokenListPageState extends State<EntityTokenListPage> {
  bool initCompleted = false;
  GlobalState _gs;
  List<Slot> list;
  DateTime dateForShowingList;
  Map<String, List<UserToken>> _tokensMap = new Map<String, List<UserToken>>();
  Map<String, int> dataMap = new Map<String, int>();

  @override
  void initState() {
    super.initState();
    getGlobalState().whenComplete(() {
      dateForShowingList = DateTime.now();
      getListOfData(dateForShowingList);
      if (this.mounted) {
        setState(() {
          initCompleted = true;
        });
      } else
        initCompleted = true;
    });
  }

  Future<void> getGlobalState() async {
    _gs = await GlobalState.getGlobalState();
  }

  getListOfData(DateTime date) {
    getSlotsListForEntity(widget.metaEntity, date).then((slotList) async {
      list = slotList;
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
        initCompleted = true;
      });
    });
    return list;
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
    return list.map(buildItem).toList();
    // return _stores.map((contact) => new ChildItem(contact.name)).toList();
  }

  refreshListOfData() {}

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
                      style: TextStyle(fontSize: 13),
                    ),
                    Text(
                      slot.currentNumber.toString() + " tokens",
                      style: TextStyle(fontSize: 13),
                    ),
                  ],
                ),
                backgroundColor: Colors.grey[300],
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
                          child: Text("No tokens")),
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

  @override
  Widget build(BuildContext context) {
    if (initCompleted) {
      return MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData.light().copyWith(),
        home: Scaffold(
          appBar: CustomAppBarWithBackButton(
            backRoute: ManageEntityListPage(),
            titleTxt: "Approved Requests",
          ),
          body: Center(
            child: Container(
              decoration: verticalBackground,
              //margin: EdgeInsets.fromLTRB(10, 0, 10, 5),
              //color: Colors.grey[50],
              child: Column(
                children: <Widget>[
                  Container(
                      child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      SizedBox(
                        width: MediaQuery.of(context).size.width * .38,
                        child: RaisedButton(
                          //padding: EdgeInsets.zero,
                          elevation: 0.0,
                          color: Colors.white,
                          // shape: RoundedRectangleBorder(
                          //     side: BorderSide(color: Colors.blueGrey[500]),
                          //     borderRadius:
                          //         BorderRadius.all(Radius.circular(5.0))),
                          splashColor: highlightColor,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Icon(Icons.date_range),
                              RichText(
                                text: TextSpan(
                                    // text: 'Showing tokens for ',
                                    style: TextStyle(
                                        color: Colors.blueGrey[700],
                                        fontSize: 13),
                                    children: <TextSpan>[
                                      TextSpan(
                                        text:
                                            "${DateFormat(dateDisplayFormat).format(dateForShowingList)}",
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
                          onPressed: () {
                            pickAnyDate(context).then((value) {
                              if (value != null) {
                                print(value);
                                dateForShowingList = value;
                                setState(() {
                                  initCompleted = false;
                                });
                                getListOfData(value);
                              }
                            });
                          },
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          IconButton(
                            icon: Icon(Icons.bar_chart),
                            onPressed: () {
                              Navigator.of(context)
                                  .push(PageAnimation.createRoute(
                                BarChart(
                                  dataMap: dataMap,
                                  metaEn: widget.metaEntity,
                                ),
                              ));
                            },
                          ),
                          IconButton(
                            icon: Icon(Icons.list),
                            onPressed: () {
                              Navigator.of(context)
                                  .push(PageAnimation.createRoute(
                                BarChart(
                                  dataMap: dataMap,
                                  metaEn: widget.metaEntity,
                                ),
                              ));
                            },
                          ),
                        ],
                      ),
                    ],
                  )),
                  Container(
                      child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      SizedBox(
                        width: MediaQuery.of(context).size.width * .18,
                        height: MediaQuery.of(context).size.width * .08,
                        child: FlatButton(
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
                            Navigator.of(context)
                                .push(PageAnimation.createRoute(
                              BarChart(
                                dataMap: dataMap,
                                metaEn: widget.metaEntity,
                              ),
                            ));
                          },
                        ),
                      ),
                      SizedBox(
                        width: MediaQuery.of(context).size.width * .18,
                        height: MediaQuery.of(context).size.width * .08,
                        child: FlatButton(
                          color: Colors.transparent,
                          textColor: btnColor,
                          shape: RoundedRectangleBorder(
                              side: BorderSide(color: btnColor),
                              borderRadius:
                                  BorderRadius.all(Radius.circular(100.0))),
                          child: Text(
                            'Week',
                            style: TextStyle(fontSize: 11),
                          ),
                          onPressed: () {
                            Navigator.of(context)
                                .push(PageAnimation.createRoute(
                              BarChart(
                                dataMap: dataMap,
                                metaEn: widget.metaEntity,
                              ),
                            ));
                          },
                        ),
                      ),
                      SizedBox(
                        width: MediaQuery.of(context).size.width * .18,
                        height: MediaQuery.of(context).size.width * .08,
                        child: FlatButton(
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
                            Navigator.of(context)
                                .push(PageAnimation.createRoute(
                              BarChart(
                                dataMap: dataMap,
                                metaEn: widget.metaEntity,
                              ),
                            ));
                          },
                        ),
                      ),
                      SizedBox(
                        width: MediaQuery.of(context).size.width * .18,
                        height: MediaQuery.of(context).size.width * .08,
                        child: FlatButton(
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
                            Navigator.of(context)
                                .push(PageAnimation.createRoute(
                              BarChart(
                                dataMap: dataMap,
                                metaEn: widget.metaEntity,
                              ),
                            ));
                          },
                        ),
                      ),
                    ],
                  )),
                  SizedBox(
                    height: 10,
                  ),
                  (!Utils.isNullOrEmpty(list))
                      ? Expanded(
                          child: ListView.builder(
                              itemCount: 1,
                              itemBuilder: (BuildContext context, int index) {
                                return Container(
                                  margin: EdgeInsets.fromLTRB(10, 0, 10, 50),
                                  child: new Column(
                                    children: showListOfData(),
                                  ),
                                );
                              }),
                        )
                      : _emptyPage(),
                ],
              ),
            ),
          ),
        ),
      );
    } else {
      return MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData.light().copyWith(),
        home: new WillPopScope(
          child: Scaffold(
            appBar: CustomAppBarWithBackButton(
              backRoute: UserHomePage(),
              titleTxt: "Approved Requests",
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
