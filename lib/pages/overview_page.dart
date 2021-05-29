import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import '../db/db_model/booking_application.dart';
import '../db/db_model/meta_entity.dart';
import '../enum/application_status.dart';
import '../global_state.dart';
import '../pages/application_list_covid.dart';
import '../pages/booking_form_selection_page.dart';
import '../pages/manage_entity_list_page.dart';
import '../pages/show_application_details.dart';
import '../pages/applications_list.dart';
import '../services/circular_progress.dart';
import '../style.dart';
import '../userHomePage.dart';
import '../widget/animated_counter.dart';
import '../widget/appbar.dart';
import '../widget/page_animation.dart';
import '../widget/widgets.dart';

class OverviewPage extends StatefulWidget {
  final String bookingFormId;
  final String bookingFormName;
  final MetaEntity metaEntity;
  final bool isReadOnly;

  OverviewPage(
      {Key key,
      @required this.bookingFormId,
      @required this.bookingFormName,
      @required this.metaEntity,
      @required this.isReadOnly})
      : super(key: key);
  @override
  _OverviewPageState createState() => _OverviewPageState();
}

class _OverviewPageState extends State<OverviewPage> {
  bool initCompleted = false;
  GlobalState _gs;
  int _completedCount = 0;
  int _totalReceivedCount = 0;
  BookingApplicationCounter _bookingApplicationsOverview;

  @override
  void initState() {
    super.initState();
    getGlobalState().whenComplete(() {
      _gs
          .getApplicationService()
          .getApplicationsOverview(widget.bookingFormId,
              widget.metaEntity.entityId, DateTime.now().year)
          .then((value) {
        //TODO SMITA - check that applications overview doesn't come null.
        _bookingApplicationsOverview = value;
        if (this.mounted) {
          setState(() {
            initCompleted = true;
          });
        } else
          initCompleted = true;
        Future.delayed(Duration(seconds: 1)).then((value) {
          setState(() {
            _completedCount = _bookingApplicationsOverview.numberOfCompleted;
            _totalReceivedCount =
                _bookingApplicationsOverview.totalApplications;
          });
        });
      });
    });
  }

  refreshData() {
    _gs
        .getApplicationService()
        .getApplicationsOverview(widget.bookingFormId,
            widget.metaEntity.entityId, DateTime.now().year)
        .then((value) {
      _bookingApplicationsOverview = value;
      if (this.mounted) {
        setState(() {
          initCompleted = true;
        });
      } else
        initCompleted = true;
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
    String pageTitle = "Overview of Applications";
    if (initCompleted) {
      refreshData();
      String pageTitle = widget.bookingFormName != null
          ? "Overview of ${widget.bookingFormName}"
          : "Overview of Applications";
      return MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData.light().copyWith(),
        home: Scaffold(
          appBar: CustomAppBarWithBackButton(
            backRoute: BookingFormSelection(
              entityId: widget.metaEntity.entityId,
              entity: null,
              preferredSlotTime: null,
              isFullAccess: !widget.isReadOnly,
              forUser: false,
              isOnlineToken: false,
              backRoute: ManageEntityListPage(),
            ),
            titleTxt: pageTitle,
          ),
          body: Center(
            child: Container(
              //color: Colors.blueGrey[800],
              padding: EdgeInsets.all(10),
              child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    //verticalSpacer,
                    Card(
                      elevation: 20,
                      color: Colors.blueGrey[500],
                      child: Container(
                          width: MediaQuery.of(context).size.width * .9,
                          height: MediaQuery.of(context).size.height * .12,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                  // width: MediaQuery.of(context).size.width * .2,
                                  padding: EdgeInsets.all(2),
                                  child: Icon(
                                    Icons.new_releases,
                                    color: primaryAccentColor,
                                    size: 50,
                                  )),
                              Container(
                                // width: MediaQuery.of(context).size.width * .9,
                                padding: EdgeInsets.all(10),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
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
                                      'Total Received',
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
                            ],
                          )),
                    ),
                    SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        GestureDetector(
                          onTap: () {
                            //User clicked on show how, lets show them.
                            print("Showing how to book time-slot");

                            Navigator.of(context).push(
                                PageAnimation.createRoute(ApplicationsList(
                                    metaEntity: widget.metaEntity,
                                    bookingFormId: widget.bookingFormId,
                                    status: ApplicationStatus.NEW,
                                    titleText: "New Applications",
                                    isReadOnly: widget.isReadOnly)));
                          },
                          child: Card(
                            elevation: 20,
                            color: Colors.blue[300],
                            child: Container(
                                height:
                                    MediaQuery.of(context).size.height * .11,
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
                                            'New',
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
                        GestureDetector(
                          onTap: () {
                            //User clicked on show how, lets show them.
                            print("Showing how to book time-slot");
                            Navigator.of(context).push(
                                PageAnimation.createRoute(ApplicationsList(
                                    metaEntity: widget.metaEntity,
                                    bookingFormId: widget.bookingFormId,
                                    status: ApplicationStatus.INPROCESS,
                                    titleText: "In-Process Applications",
                                    isReadOnly: widget.isReadOnly)));
                          },
                          child: Card(
                            elevation: 20,
                            color: Colors.amberAccent.withOpacity(0.7),
                            child: Container(
                                width: MediaQuery.of(context).size.width * .42,
                                height:
                                    MediaQuery.of(context).size.height * .12,
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
                    SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        GestureDetector(
                          onTap: () {
                            //User clicked on show how, lets show them.
                            print("Showing how to book time-slot");
                            Navigator.of(context).push(
                                PageAnimation.createRoute(ApplicationsList(
                                    metaEntity: widget.metaEntity,
                                    bookingFormId: widget.bookingFormId,
                                    status: ApplicationStatus.REJECTED,
                                    titleText: "Rejected Applications",
                                    isReadOnly: widget.isReadOnly)));
                          },
                          child: Card(
                            elevation: 20,
                            color: Colors.orangeAccent.withOpacity(0.7),
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
                        GestureDetector(
                          onTap: () {
                            //User clicked on show how, lets show them.
                            print("Showing how to book time-slot");
                            Navigator.of(context).push(
                                PageAnimation.createRoute(ApplicationsList(
                                    metaEntity: widget.metaEntity,
                                    bookingFormId: widget.bookingFormId,
                                    status: ApplicationStatus.CANCELLED,
                                    titleText: "Cancelled Applications",
                                    isReadOnly: widget.isReadOnly)));
                          },
                          child: Card(
                            elevation: 20,
                            color: Colors.pink[200],
                            child: Container(
                                width: MediaQuery.of(context).size.width * .3,
                                height:
                                    MediaQuery.of(context).size.height * .11,
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
                    SizedBox(height: 5),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        GestureDetector(
                          onTap: () {
                            //User clicked on show how, lets show them.
                            print("Showing how to book time-slot");
                            Navigator.of(context).push(
                                PageAnimation.createRoute(ApplicationsList(
                                    metaEntity: widget.metaEntity,
                                    bookingFormId: widget.bookingFormId,
                                    status: ApplicationStatus.ONHOLD,
                                    titleText: "On-Hold Applications",
                                    isReadOnly: widget.isReadOnly)));
                          },
                          child: Card(
                            elevation: 20,
                            color: Colors.greenAccent,
                            child: Container(
                                width: MediaQuery.of(context).size.width * .35,
                                height:
                                    MediaQuery.of(context).size.height * .11,
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
                        GestureDetector(
                          onTap: () {
                            //User clicked on show how, lets show them.
                            print("Showing how to book time-slot");
                            Navigator.of(context).push(
                                PageAnimation.createRoute(ApplicationsList(
                                    metaEntity: widget.metaEntity,
                                    bookingFormId: widget.bookingFormId,
                                    status: ApplicationStatus.APPROVED,
                                    titleText: "Approved Applications",
                                    isReadOnly: widget.isReadOnly)));
                          },
                          child: Card(
                            elevation: 20,
                            color: Colors.blueAccent,
                            child: Container(
                                width: MediaQuery.of(context).size.width * .45,
                                height:
                                    MediaQuery.of(context).size.height * .16,
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
                    SizedBox(height: 5),
                    Card(
                      elevation: 20,
                      color: Colors.greenAccent[700],
                      child: GestureDetector(
                        onTap: () {
                          //User clicked on show how, lets show them.
                          print("Showing how to book time-slot");
                          Navigator.of(context).push(PageAnimation.createRoute(
                              ApplicationsList(
                                  metaEntity: widget.metaEntity,
                                  bookingFormId: widget.bookingFormId,
                                  status: ApplicationStatus.COMPLETED,
                                  titleText: "Completed Applications",
                                  isReadOnly: widget.isReadOnly)));
                        },
                        child: Container(
                            width: MediaQuery.of(context).size.width * .9,
                            height: MediaQuery.of(context).size.height * .12,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                    // width: MediaQuery.of(context).size.width * .2,
                                    padding: EdgeInsets.all(2),
                                    child: Icon(
                                      Icons.thumb_up,
                                      color: Colors.yellowAccent,
                                      size: 55,
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

                    // verticalSpacer,
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
