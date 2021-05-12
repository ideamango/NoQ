import 'package:flutter/material.dart';
import '../constants.dart';

import '../db/db_model/entity_slots.dart';
import '../db/db_model/meta_entity.dart';
import '../db/db_model/slot.dart';
import '../db/db_model/user_token.dart';
import '../db/db_service/token_service.dart';
import '../global_state.dart';
import '../pages/manage_entity_list_page.dart';
import '../repository/slotRepository.dart';
import '../services/circular_progress.dart';
import '../services/timeline_view.dart';

import '../style.dart';
import '../userHomePage.dart';
import '../utils.dart';
import '../widget/appbar.dart';

import '../widget/page_animation.dart';
import '../widget/weekday_selector.dart';

class ManageTokens extends StatefulWidget {
  final MetaEntity metaEntity;
  ManageTokens({Key key, @required this.metaEntity}) : super(key: key);
  @override
  _ManageTokensState createState() => _ManageTokensState();
}

class _ManageTokensState extends State<ManageTokens> {
  final GlobalKey<FormFieldState> phnKey = new GlobalKey<FormFieldState>();

  List<String> attachments = [];

  bool initCompleted = false;
  GlobalState _gs;
  DateTime currentDate = DateTime.now();
  List<Slot> _slotList;
  Map<String, List<UserToken>> _tokensMap = new Map<String, List<UserToken>>();
  bool slotsLoaded = false;
  DateTime dateForLoadingSlots;
  @override
  void initState() {
    super.initState();
    getGlobalState().whenComplete(() {
      dateForLoadingSlots = currentDate.subtract(Duration(days: 1));
      // getSlotsListForEntity(widget.metaEntity, currentDate)
      //     .then((slotList) async {
      //   _slotList = slotList;
      //   for (int i = 0; i <= slotList.length - 1; i++) {
      //     List<UserToken> tokensForThisSlot = await _gs
      //         .getTokenService()
      //         .getAllTokensForSlot(slotList[i].slotId);
      //     if (!Utils.isNullOrEmpty(tokensForThisSlot))
      //       _tokensMap[slotList[i].slotId] = tokensForThisSlot;
      //   }
      if (this.mounted) {
        setState(() {
          initCompleted = true;
        });
      } else
        initCompleted = true;
      // }).catchError((onError) {
      //   switch (onError.code) {
      //     case 'unavailable':
      //       setState(() {
      //         //  errMsg = "No Internet Connection. Please check and try again.";
      //       });
      //       break;

      //     default:
      //       setState(() {
      //         // errMsg =
      //         // 'Oops, something went wrong. Check your internet connection and try again.';
      //       });
      //       break;
      //   }
      // });
    });
  }

  Future<void> getGlobalState() async {
    _gs = await GlobalState.getGlobalState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  buildChildItem(UserToken token) {
    return Container(
      padding: EdgeInsets.all(0),
      child: Card(
          child: Container(
              padding: EdgeInsets.all(10), child: Text(token.parent.userId))),
    );
  }

  Widget buildItem(Slot slot) {
    List<UserToken> tokens = _tokensMap[slot.slotId];
    String fromTime = Utils.formatTime(slot.dateTime.hour.toString()) +
        " : " +
        Utils.formatTime(slot.dateTime.minute.toString());

    String toTime = Utils.formatTime(slot.dateTime
            .add(new Duration(minutes: slot.slotDuration))
            .hour
            .toString()) +
        " : " +
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
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Text(fromTime + " - " + toTime),
                    Text(slot.totalBooked.toString() + " bookings"),
                  ],
                ),
                backgroundColor: Colors.cyan[100],
                children: <Widget>[
                  (!Utils.isNullOrEmpty(tokens))
                      ? new Container(
                          width: MediaQuery.of(context).size.width * .94,
                          decoration: lightCyanContainer,
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
                          child: Text("No bookings")),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget loadSlotsForDate(DateTime date) {
    List<Slot> _slotListForDate;
    getSlotsListForEntity(widget.metaEntity, date).then((slotList) async {
      _slotListForDate = slotList;
      for (int i = 0; i <= _slotListForDate.length - 1; i++) {
        List<UserToken> tokensForThisSlot = await _gs
            .getTokenService()
            .getAllTokensForSlot(_slotListForDate[i].slotId);
        if (!Utils.isNullOrEmpty(tokensForThisSlot))
          _tokensMap[_slotListForDate[i].slotId] = tokensForThisSlot;
      }
      return Container(
        child: Column(
          children: [
            Utils.isNullOrEmpty(_slotListForDate)
                ? Align(
                    alignment: Alignment.topCenter, child: Text('No bookings'))
                : new Expanded(
                    child: Align(
                      alignment: Alignment.topCenter,
                      child: ListView.builder(
                        padding: EdgeInsets.all(
                            MediaQuery.of(context).size.width * .026),
                        //  controller: _childScrollController,

                        shrinkWrap: true,
                        //   itemExtent: itemSize,
                        //scrollDirection: Axis.vertical,
                        itemBuilder: (BuildContext context, int index) {
                          return Container(
                            //  height: MediaQuery.of(context).size.height * .3,
                            child: buildItem(_slotListForDate[index]),
                          );
                        },
                        itemCount: _slotListForDate.length,
                      ),
                    ),
                  ),
          ],
        ),
      );
    }).catchError((onError) {
      switch (onError.code) {
        case 'unavailable':
          setState(() {
            //  errMsg = "No Internet Connection. Please check and try again.";
          });
          break;

        default:
          setState(() {
            // errMsg =
            // 'Oops, something went wrong. Check your internet connection and try again.';
          });
          break;
      }
    });
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.light().copyWith(),
      home: WillPopScope(
        child: Scaffold(
          appBar: CustomAppBarWithBackButton(
            titleTxt: "Manage Bookings",
            backRoute: UserHomePage(),
          ),
          body: Center(
            //child: Text("Loading"),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                showCircularProgress(),
              ],
            ),
          ),
          //drawer: CustomDrawer(),
          //bottomNavigationBar: CustomBottomBar(barIndex: 0),
        ),
        onWillPop: () async {
          Navigator.push(
              context, MaterialPageRoute(builder: (context) => UserHomePage()));
          return false;
        },
      ),
    );
  }

  Widget getCurrentDayBooking() {
    return Container(
      child: Column(
        children: [
          Utils.isNullOrEmpty(_slotList)
              ? Align(
                  alignment: Alignment.topCenter, child: Text('No bookings'))
              : new Expanded(
                  child: Align(
                    alignment: Alignment.topCenter,
                    child: ListView.builder(
                      padding: EdgeInsets.all(
                          MediaQuery.of(context).size.width * .026),
                      //  controller: _childScrollController,

                      shrinkWrap: true,
                      //   itemExtent: itemSize,
                      //scrollDirection: Axis.vertical,
                      itemBuilder: (BuildContext context, int index) {
                        return Container(
                          //  height: MediaQuery.of(context).size.height * .3,
                          child: buildItem(_slotList[index]),
                        );
                      },
                      itemCount: _slotList.length,
                    ),
                  ),
                ),
        ],
      ),
    );
  }

  Future<DateTime> pickDate(BuildContext context) async {
    DateTime date = await showDatePicker(
      context: context,
      firstDate: DateTime.now().subtract(Duration(days: 365 * 100)),
      lastDate: DateTime.now(),
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
    if (!initCompleted) {
      return MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData.light().copyWith(),
        home: WillPopScope(
          child: Scaffold(
            appBar: CustomAppBarWithBackButton(
              titleTxt: "Manage Bookings",
              backRoute: UserHomePage(),
            ),
            body: Center(
              //child: Text("Loading"),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  showCircularProgress(),
                ],
              ),
            ),
            //drawer: CustomDrawer(),
            //bottomNavigationBar: CustomBottomBar(barIndex: 0),
          ),
          onWillPop: () async {
            Navigator.push(context,
                MaterialPageRoute(builder: (context) => UserHomePage()));
            return false;
          },
        ),
      );
    } else {
      return MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData.light().copyWith(),
        home: DefaultTabController(
          length: 2,
          child: Scaffold(
            appBar: AppBar(
              leading: IconButton(
                  icon: Icon(Icons.arrow_back_ios),
                  color: Colors.white,
                  onPressed: () {
                    Navigator.of(context).pop();
                    Navigator.of(context).push(
                        PageAnimation.createRoute(ManageEntityListPage()));
                  }),
              flexibleSpace: Container(
                decoration: gradientBackground,
              ),
              actions: <Widget>[
                IconButton(
                    icon: Icon(Icons.exit_to_app),
                    color: Colors.white,
                    onPressed: () {
                      Utils.logout(context);
                    })
              ],
              title: Text('View Bookings'),
            ),
            body: Column(
              children: [
                Row(
                  children: [
                    Text("Showing tokens for $dateForLoadingSlots"),
                    RaisedButton(
                      child: Text('Select another date'),
                      onPressed: () {
                        pickAnyDate(context).then((value) {
                          if (value != null) {
                            print(value);
                            setState(() {
                              dateForLoadingSlots = value;
                            });
                          }
                        });
                      },
                    ),
                  ],
                ),
                loadSlotsForDate(dateForLoadingSlots),
              ],
            ),
          ),
        ),
      );
    }
  }
}
