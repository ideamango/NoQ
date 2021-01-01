import 'package:flutter/material.dart';
import 'package:noq/constants.dart';
import 'package:noq/db/db_model/entity_slots.dart';
import 'package:noq/db/db_model/meta_entity.dart';
import 'package:noq/db/db_model/slot.dart';
import 'package:noq/db/db_model/user_token.dart';
import 'package:noq/db/db_service/token_service.dart';
import 'package:noq/global_state.dart';
import 'package:noq/pages/manage_entity_list_page.dart';
import 'package:noq/repository/slotRepository.dart';
import 'package:noq/services/timeline_view.dart';
import 'package:noq/services/url_services.dart';
import 'package:noq/style.dart';
import 'package:noq/userHomePage.dart';
import 'package:noq/utils.dart';
import 'package:noq/widget/appbar.dart';
import 'package:noq/widget/custom_expansion_tile.dart';
import 'package:noq/widget/header.dart';
import 'package:noq/widget/page_animation.dart';
import 'package:noq/widget/widgets.dart';
import 'package:url_launcher/url_launcher.dart';

class ManageBookings extends StatefulWidget {
  final MetaEntity metaEntity;
  ManageBookings({Key key, @required this.metaEntity}) : super(key: key);
  @override
  _ManageBookingsState createState() => _ManageBookingsState();
}

class _ManageBookingsState extends State<ManageBookings> {
  TextEditingController _mailController = new TextEditingController();
  TextEditingController _nameController = new TextEditingController();
  TextEditingController _phController = new TextEditingController();
  final GlobalKey<FormFieldState> phnKey = new GlobalKey<FormFieldState>();
  TextEditingController _msgController = new TextEditingController();
  String _reasonType;
  List<String> attachments = [];
  String _mailBody;
  String _altPh;
  String _mailFirstline;
  String _mailSecLine;
  bool _validate = false;
  String _errMsg;
  bool initCompleted = false;
  GlobalState _state;
  DateTime currentDate = DateTime.now();
  List<Slot> _slotList;
  Map<String, List<UserToken>> _tokensMap = new Map<String, List<UserToken>>();

  @override
  void initState() {
    super.initState();
    getGlobalState().whenComplete(() {
      getTokenService();
      getBookingData(currentDate);

      if (this.mounted) {
        setState(() {
          initCompleted = true;
        });
      } else
        initCompleted = true;
    });
  }

  Future<void> getGlobalState() async {
    _state = await GlobalState.getGlobalState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  TokenService getTokenService() {
    return _state.getTokenService();
  }

  getBookingData(DateTime dateTime) {
    getSlotsListForEntity(widget.metaEntity, dateTime).then((slotList) async {
      _slotList = slotList;
      for (int i = 0; i <= slotList.length - 1; i++) {
        List<UserToken> tokensForThisSlot =
            await getTokenService().getAllTokensForSlot(slotList[i].slotId);
        if (Utils.isNullOrEmpty(tokensForThisSlot))
          _tokensMap[slotList[i].slotId] = tokensForThisSlot;
      }
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
  }

  Future<List<String>> getData(DateTime dateTime) async {
    getBookingData(dateTime);

    EntitySlots entitySlots = await getTokenService()
        .getEntitySlots(widget.metaEntity.entityId, currentDate);
    if (entitySlots != null) {
      List<UserToken> listOfTokens;
      for (int i = 0; i < entitySlots.slots.length; i++) {
        listOfTokens = await getTokenService()
            .getAllTokensForSlot(entitySlots.slots[i].slotId);
      }
      return List<String>();
    } else {
      Utils.showMyFlushbar(context, Icons.info, Duration(seconds: 4),
          "No Bookings found for this time-slot", "");
    }
  }

  buildChildItem(UserToken token) {
    return Container(
      child: Text(token.userId),
    );
  }

  Widget buildItem(Slot slot) {
    List<UserToken> tokens = _tokensMap[slot.slotId];
    String fromTime =
        slot.dateTime.hour.toString() + " : " + slot.dateTime.minute.toString();

    String toTime = slot.dateTime
            .add(new Duration(minutes: slot.slotDuration))
            .hour
            .toString() +
        " : " +
        slot.dateTime
            .add(new Duration(minutes: slot.slotDuration))
            .minute
            .toString();

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
                    Text(slot.currentNumber.toString() + " bookings"),
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
                                    MediaQuery.of(context).size.width * .026),
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
                      : Container(child: Text("No bookings")),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget getCurrentDayBooking() {
    //  getData(currentDate);
    return Container(
      child: Column(
        children: [
          // Timeline(
          //   children: <Widget>[
          //     Container(
          //       color: Colors.cyan[100],
          //       child: Column(
          //         children: [
          //           Theme(
          //             data: ThemeData(
          //               unselectedWidgetColor: Colors.grey[600],
          //               accentColor: btnColor,
          //             ),
          //             child: Expanded(
          //               child: ExpansionTile(
          //                 initiallyExpanded: false,
          //                 title: Row(
          //                   children: <Widget>[
          //                     Text(
          //                       "Basic Details",
          //                       style: TextStyle(
          //                           color: Colors.black, fontSize: 15),
          //                     ),
          //                     SizedBox(width: 5),
          //                   ],
          //                 ),
          //                 backgroundColor: Colors.cyan[100],
          //                 children: <Widget>[
          //                   new Container(
          //                     width: MediaQuery.of(context).size.width * .94,
          //                     decoration: lightCyanContainer,
          //                     padding: EdgeInsets.all(2.0),
          //                     child: Expanded(
          //                       child: Column(
          //                         children: [
          //                           Text(basicInfoStr,
          //                               style: buttonXSmlTextStyle),
          //                           Text(basicInfoStr,
          //                               style: buttonXSmlTextStyle),
          //                           Text(basicInfoStr,
          //                               style: buttonXSmlTextStyle),
          //                           Text(basicInfoStr,
          //                               style: buttonXSmlTextStyle),
          //                         ],
          //                       ),
          //                     ),
          //                   ),
          //                 ],
          //               ),
          //             ),
          //           ),
          //         ],
          //       ),
          //     ),
          //     Container(height: 50, color: Colors.amber[100]),
          //     Container(height: 50, color: Colors.cyan[100]),
          //     Container(height: 50, color: Colors.amber[100]),
          //   ],
          //   indicators: <Widget>[
          //     Icon(Icons.access_alarm),
          //     Icon(Icons.backup),
          //     Icon(Icons.accessibility_new),
          //     Icon(Icons.access_alarm),
          //   ],
          // ),

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

  Widget getUpcomingBookings() {
    print(_state.getConfigurations().bookingDataFromDays);
    DateTime selectedDate;
   
    return Container(child: Text('Date time slots and Up bookings'));
  }

  Widget getPastBookings() {
    return Container(child: Text('Date time slots and Past bookings'));
  }

  Future<void> showDatePickerDialog() async {
    DateTime retDate = await showDatePicker(
      context: context,
      firstDate: DateTime.now().subtract(
          Duration(days: _state.getConfigurations().bookingDataFromDays)),
      lastDate: DateTime.now()
          .add(Duration(days: _state.getConfigurations().bookingDataToDays)),
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
    print(retDate);
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
              child: Text("Loading"),
              // child: Column(
              //   mainAxisAlignment: MainAxisAlignment.center,
              //   children: <Widget>[
              //     showCircularProgress(),
              //   ],
              // ),
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
              bottom: TabBar(
                tabs: [
                  //  Tab(icon: Icon(Icons.arrow_back_ios), child: Text("Prev")),
                  Tab(
                      icon: Icon(Icons.date_range),
                      iconMargin: EdgeInsets.zero,
                      child: Text("Today")),
                  Tab(
                      icon: Icon(Icons.select_all),
                      iconMargin: EdgeInsets.zero,
                      child: Text("Pick date")),
                ],
              ),
              title: Text('View Bookings'),
            ),
            body: TabBarView(
              children: [
                getCurrentDayBooking(),
                getUpcomingBookings(),
              ],
            ),
          ),
        ),
      );
    }
  }

  showCircularProgress() {}
}
