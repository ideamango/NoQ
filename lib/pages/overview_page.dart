import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:noq/db/db_model/booking_application.dart';
import 'package:noq/enum/application_status.dart';
import 'package:noq/global_state.dart';
import 'package:noq/pages/manage_entity_list_page.dart';
import 'package:noq/pages/show_application_details.dart';
import 'package:noq/pages/applications_list.dart';
import 'package:noq/services/circular_progress.dart';
import 'package:noq/style.dart';
import 'package:noq/userHomePage.dart';
import 'package:noq/widget/animated_counter.dart';
import 'package:noq/widget/appbar.dart';
import 'package:noq/widget/page_animation.dart';
import 'package:noq/widget/widgets.dart';

class OverviewPage extends StatefulWidget {
  final String entityId;
  final String bookingFormId;
  OverviewPage({Key key, @required this.entityId, @required this.bookingFormId})
      : super(key: key);
  @override
  _OverviewPageState createState() => _OverviewPageState();
}

class _OverviewPageState extends State<OverviewPage> {
  bool initCompleted = false;
  GlobalState _gs;
  int _completedCount = 0;
  int _totalReceivedCount = 0;
  BookingApplicationsOverview _bookingApplicationsOverview;

  @override
  void initState() {
    super.initState();
    getGlobalState().whenComplete(() {
      _gs
          .getTokenApplicationService()
          .getBookingApplicationOverview(widget.bookingFormId, widget.entityId)
          .then((value) {
        _bookingApplicationsOverview = value;
        //TODO : Start - Dummy Data remove later
        _bookingApplicationsOverview = new BookingApplicationsOverview();
        _bookingApplicationsOverview.totalApplications = 3534565;
        _bookingApplicationsOverview.numberOfNew = 5500;
        _bookingApplicationsOverview.numberOfInProcess = 8500;
        _bookingApplicationsOverview.numberOfRejected = 330;
        _bookingApplicationsOverview.numberOfCancelled = 5900;
        _bookingApplicationsOverview.numberOfPutOnHold = 66560;
        _bookingApplicationsOverview.numberOfApproved = 500201;
        _bookingApplicationsOverview.numberOfCompleted = 1830500;
//TODO : End - Dummy Data remove later

        if (this.mounted) {
          setState(() {
            initCompleted = true;
          });
        } else
          initCompleted = true;
      });
    });
    Future.delayed(Duration(seconds: 1)).then((value) {
      setState(() {
        _completedCount = _bookingApplicationsOverview.numberOfCompleted;
        _totalReceivedCount = _bookingApplicationsOverview.totalApplications;
      });
    });
  }

  Future<void> getGlobalState() async {
    _gs = await GlobalState.getGlobalState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    String pageTitle = "Overview";
    if (initCompleted) {
      return MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData.light().copyWith(),
        home: Scaffold(
          appBar: CustomAppBarWithBackButton(
            backRoute: ManageEntityListPage(),
            titleTxt: pageTitle,
          ),
          body: Center(
            child: Container(
              //color: Colors.blueGrey[800],
              padding: EdgeInsets.all(10),
              child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    verticalSpacer,
                    Card(
                      elevation: 20,
                      color: Colors.blueGrey[500],
                      child: Container(
                          width: MediaQuery.of(context).size.width * .9,
                          child: Stack(
                            alignment: Alignment.topRight,
                            children: [
                              Container(
                                width: MediaQuery.of(context).size.width * .9,
                                padding: EdgeInsets.all(10),
                                child: Column(
                                  children: [
                                    new AnimatedCount(
                                      count: _totalReceivedCount,
                                      duration: Duration(seconds: 2),
                                      textStyle: TextStyle(
                                        color: primaryAccentColor,
                                        fontWeight: FontWeight.w600,
                                        fontSize: 30,
                                        fontFamily: 'Roboto',
                                      ),
                                    ),
                                    AutoSizeText(
                                      'Total Requests Received',
                                      maxLines: 1,
                                      minFontSize: 12,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        color: primaryAccentColor,
                                        fontSize: 17,
                                        fontFamily: 'RalewayRegular',
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Icon(
                                Icons.new_releases,
                                color: primaryAccentColor,
                                size: 25,
                              )
                            ],
                          )),
                    ),
                    SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Card(
                          elevation: 20,
                          color: Colors.blue[300],
                          child: GestureDetector(
                            onTap: () {
                              //User clicked on show how, lets show them.
                              print("Showing how to book time-slot");
                              Navigator.of(context).push(
                                  PageAnimation.createRoute(ApplicationsList(
                                entityId: widget.entityId,
                                bookingFormId: widget.bookingFormId,
                                status: ApplicationStatus.NEW,
                                titleText: "New Applications",
                              )));
                            },
                            child: Container(
                                width: MediaQuery.of(context).size.width * .34,
                                child: Stack(
                                  alignment: Alignment.topRight,
                                  children: [
                                    Container(
                                      width: MediaQuery.of(context).size.width *
                                          .34,
                                      padding: EdgeInsets.all(10),
                                      child: Column(
                                        children: [
                                          AutoSizeText(
                                            _bookingApplicationsOverview
                                                .numberOfNew
                                                .toString(),
                                            maxLines: 1,
                                            minFontSize: 8,
                                            overflow: TextOverflow.ellipsis,
                                            style: TextStyle(
                                              fontWeight: FontWeight.w600,
                                              color: Colors.white,
                                              fontSize: 30,
                                              fontFamily: 'Roboto',
                                            ),
                                          ),
                                          AutoSizeText(
                                            'New Requests',
                                            maxLines: 1,
                                            minFontSize: 12,
                                            overflow: TextOverflow.ellipsis,
                                            style: TextStyle(
                                              fontWeight: FontWeight.w600,
                                              fontSize: 15,
                                              color: Colors.white,
                                              fontFamily: 'RalewayRegular',
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Container(
                                      padding: EdgeInsets.all(2),
                                      child: Icon(
                                        Icons.new_releases_rounded,
                                        color: Colors.yellowAccent,
                                        size: 25,
                                      ),
                                    )
                                  ],
                                )),
                          ),
                        ),
                        Card(
                          elevation: 20,
                          color: Colors.amberAccent.withOpacity(0.7),
                          child: GestureDetector(
                            onTap: () {
                              //User clicked on show how, lets show them.
                              print("Showing how to book time-slot");
                              Navigator.of(context).push(
                                  PageAnimation.createRoute(ApplicationsList(
                                entityId: widget.entityId,
                                bookingFormId: widget.bookingFormId,
                                status: ApplicationStatus.INPROCESS,
                                titleText: "In-Process Applications",
                              )));
                            },
                            child: Container(
                                width: MediaQuery.of(context).size.width * .42,
                                // height: MediaQuery.of(context).size.width * .22,
                                child: Stack(
                                  alignment: Alignment.topRight,
                                  children: [
                                    Container(
                                      width: MediaQuery.of(context).size.width *
                                          .42,
                                      padding: EdgeInsets.all(10),
                                      child: Column(
                                        children: [
                                          AutoSizeText(
                                            _bookingApplicationsOverview
                                                .numberOfInProcess
                                                .toString(),
                                            maxLines: 1,
                                            minFontSize: 8,
                                            overflow: TextOverflow.ellipsis,
                                            style: TextStyle(
                                              fontSize: 30,
                                              fontWeight: FontWeight.w600,
                                              color: Colors.blueGrey[800],
                                              fontFamily: 'Roboto',
                                            ),
                                          ),
                                          AutoSizeText(
                                            'In-Process',
                                            maxLines: 1,
                                            minFontSize: 12,
                                            overflow: TextOverflow.ellipsis,
                                            style: TextStyle(
                                              fontSize: 15,
                                              fontWeight: FontWeight.w600,
                                              color: Colors.blueGrey[800],
                                              fontFamily: 'RalewayRegular',
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Container(
                                        padding: EdgeInsets.all(2),
                                        child: Icon(
                                          Icons.hourglass_bottom,
                                          color: Colors.green,
                                          size: 25,
                                        )),
                                  ],
                                )),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Card(
                          elevation: 20,
                          color: Colors.orangeAccent.withOpacity(0.7),
                          child: GestureDetector(
                            onTap: () {
                              //User clicked on show how, lets show them.
                              print("Showing how to book time-slot");
                              Navigator.of(context).push(
                                  PageAnimation.createRoute(ApplicationsList(
                                entityId: widget.entityId,
                                bookingFormId: widget.bookingFormId,
                                status: ApplicationStatus.REJECTED,
                                titleText: "Rejected Applications",
                              )));
                            },
                            child: Container(
                                width: MediaQuery.of(context).size.width * .45,
                                // height:
                                //    MediaQuery.of(context).size.height * .15,
                                child: Stack(
                                  alignment: Alignment.topRight,
                                  children: [
                                    Container(
                                      width: MediaQuery.of(context).size.width *
                                          .45,
                                      height:
                                          MediaQuery.of(context).size.height *
                                              .15,
                                      padding: EdgeInsets.all(10),
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          AutoSizeText(
                                            _bookingApplicationsOverview
                                                .numberOfRejected
                                                .toString(),
                                            maxLines: 1,
                                            minFontSize: 8,
                                            overflow: TextOverflow.ellipsis,
                                            style: TextStyle(
                                              fontWeight: FontWeight.w600,
                                              color: Colors.blueGrey[800],
                                              fontSize: 30,
                                              fontFamily: 'Roboto',
                                            ),
                                          ),
                                          AutoSizeText(
                                            'Rejected',
                                            maxLines: 1,
                                            minFontSize: 12,
                                            overflow: TextOverflow.ellipsis,
                                            style: TextStyle(
                                              fontWeight: FontWeight.w600,
                                              color: Colors.blueGrey[800],
                                              fontSize: 15,
                                              fontFamily: 'RalewayRegular',
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Container(
                                        padding: EdgeInsets.all(2),
                                        child: Icon(
                                          Icons.cancel,
                                          color: Colors.red,
                                          size: 25,
                                        )),
                                  ],
                                )),
                          ),
                        ),
                        Card(
                          elevation: 20,
                          color: Colors.pink[200],
                          child: GestureDetector(
                            onTap: () {
                              //User clicked on show how, lets show them.
                              print("Showing how to book time-slot");
                              Navigator.of(context).push(
                                  PageAnimation.createRoute(ApplicationsList(
                                entityId: widget.entityId,
                                bookingFormId: widget.bookingFormId,
                                status: ApplicationStatus.CANCELLED,
                                titleText: "Cancelled Applications",
                              )));
                            },
                            child: Container(
                                width: MediaQuery.of(context).size.width * .3,
                                child: Stack(
                                  alignment: Alignment.topRight,
                                  children: [
                                    Container(
                                      width: MediaQuery.of(context).size.width *
                                          .3,
                                      padding: EdgeInsets.all(10),
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          AutoSizeText(
                                            _bookingApplicationsOverview
                                                .numberOfCancelled
                                                .toString(),
                                            maxLines: 1,
                                            minFontSize: 8,
                                            overflow: TextOverflow.ellipsis,
                                            style: TextStyle(
                                              fontWeight: FontWeight.w600,
                                              color: Colors.white,
                                              fontSize: 30,
                                              fontFamily: 'Roboto',
                                            ),
                                          ),
                                          AutoSizeText(
                                            'Cancelled',
                                            maxLines: 1,
                                            minFontSize: 12,
                                            overflow: TextOverflow.ellipsis,
                                            style: TextStyle(
                                              fontWeight: FontWeight.w600,
                                              color: Colors.white,
                                              fontSize: 15,
                                              fontFamily: 'RalewayRegular',
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Container(
                                        padding: EdgeInsets.all(2),
                                        child: Icon(
                                          Icons.block_rounded,
                                          color: Colors.purple,
                                          size: 25,
                                        )),
                                  ],
                                )),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Card(
                          elevation: 20,
                          color: Colors.greenAccent,
                          child: GestureDetector(
                            onTap: () {
                              //User clicked on show how, lets show them.
                              print("Showing how to book time-slot");
                              Navigator.of(context).push(
                                  PageAnimation.createRoute(ApplicationsList(
                                entityId: widget.entityId,
                                bookingFormId: widget.bookingFormId,
                                status: ApplicationStatus.ONHOLD,
                                titleText: "On-Hold Applications",
                              )));
                            },
                            child: Container(
                                width: MediaQuery.of(context).size.width * .35,
                                //   height: MediaQuery.of(context).size.width * .25,
                                child: Stack(
                                  alignment: Alignment.topRight,
                                  children: [
                                    Container(
                                      width: MediaQuery.of(context).size.width *
                                          .35,
                                      padding: EdgeInsets.all(10),
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          AutoSizeText(
                                            _bookingApplicationsOverview
                                                .numberOfPutOnHold
                                                .toString(),
                                            maxLines: 1,
                                            minFontSize: 8,
                                            overflow: TextOverflow.ellipsis,
                                            style: TextStyle(
                                              fontWeight: FontWeight.w600,
                                              color: Colors.blueGrey[800],
                                              fontSize: 30,
                                              fontFamily: 'Roboto',
                                            ),
                                          ),
                                          AutoSizeText(
                                            'On-Hold',
                                            maxLines: 1,
                                            minFontSize: 12,
                                            overflow: TextOverflow.ellipsis,
                                            style: TextStyle(
                                              fontSize: 15,
                                              fontWeight: FontWeight.w600,
                                              color: Colors.blueGrey[800],
                                              fontFamily: 'RalewayRegular',
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Container(
                                        padding: EdgeInsets.all(2),
                                        child: Icon(
                                          Icons.pan_tool_rounded,
                                          color: Colors.indigo[900],
                                          size: 20,
                                        )),
                                  ],
                                )),
                          ),
                        ),
                        Card(
                          elevation: 20,
                          color: Colors.blueAccent,
                          child: GestureDetector(
                            onTap: () {
                              //User clicked on show how, lets show them.
                              print("Showing how to book time-slot");
                              Navigator.of(context).push(
                                  PageAnimation.createRoute(ApplicationsList(
                                entityId: widget.entityId,
                                bookingFormId: widget.bookingFormId,
                                status: ApplicationStatus.APPROVED,
                                titleText: "Approved Applications",
                              )));
                            },
                            child: Container(
                                width: MediaQuery.of(context).size.width * .45,
                                height: MediaQuery.of(context).size.width * .3,
                                child: Stack(
                                  alignment: Alignment.topRight,
                                  children: [
                                    Container(
                                      width: MediaQuery.of(context).size.width *
                                          .4,
                                      padding: EdgeInsets.all(10),
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          AutoSizeText(
                                            _bookingApplicationsOverview
                                                .numberOfApproved
                                                .toString(),
                                            maxLines: 1,
                                            minFontSize: 8,
                                            overflow: TextOverflow.ellipsis,
                                            style: TextStyle(
                                              fontWeight: FontWeight.w600,
                                              color: Colors.white,
                                              fontSize: 30,
                                              fontFamily: 'Roboto',
                                            ),
                                          ),
                                          AutoSizeText(
                                            'Approved',
                                            maxLines: 1,
                                            minFontSize: 12,
                                            overflow: TextOverflow.ellipsis,
                                            style: TextStyle(
                                              fontSize: 15,
                                              fontWeight: FontWeight.w600,
                                              color: Colors.white,
                                              fontFamily: 'RalewayRegular',
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Container(
                                        padding: EdgeInsets.all(2),
                                        child: Icon(
                                          Icons.check_circle,
                                          color: Colors.yellow[600],
                                          size: 30,
                                        )),
                                  ],
                                )),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 12),
                    Card(
                      elevation: 20,
                      color: Colors.greenAccent[700],
                      child: GestureDetector(
                        onTap: () {
                          //User clicked on show how, lets show them.
                          print("Showing how to book time-slot");
                        },
                        child: Container(
                            width: MediaQuery.of(context).size.width * .9,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                    // width: MediaQuery.of(context).size.width * .2,
                                    padding: EdgeInsets.all(2),
                                    child: Icon(
                                      Icons.thumb_up,
                                      color: Colors.yellowAccent,
                                      size: 50,
                                    )),
                                Container(
                                  //  width: MediaQuery.of(context).size.width * .,
                                  padding: EdgeInsets.all(10),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      new AnimatedCount(
                                        count: _completedCount,
                                        duration: Duration(seconds: 2),
                                        textStyle: TextStyle(
                                          color: Colors.yellowAccent[700],
                                          fontWeight: FontWeight.w600,
                                          fontSize: 30,
                                          fontFamily: 'Roboto',
                                        ),
                                      ),
                                      AutoSizeText(
                                        'Total Completed ',
                                        maxLines: 1,
                                        minFontSize: 12,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                          fontWeight: FontWeight.w600,
                                          color: Colors.yellowAccent,
                                          fontSize: 17,
                                          fontFamily: 'RalewayRegular',
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            )),
                      ),
                    ),
                    verticalSpacer,
                  ]),
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
              titleTxt: pageTitle,
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
