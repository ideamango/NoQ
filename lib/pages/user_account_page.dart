//import 'package:barcode_scan/barcode_scan.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:noq/constants.dart';
import 'package:noq/db/db_model/booking_application.dart';
import 'package:noq/db/db_model/user_token.dart';
import 'package:noq/global_state.dart';
import 'package:noq/pages/notifications_page.dart';
import 'package:noq/pages/shopping_list.dart';
import 'package:noq/pages/user_applications_list.dart';
import 'package:noq/repository/slotRepository.dart';
import 'package:noq/services/circular_progress.dart';
import 'package:noq/services/url_services.dart';
import 'package:noq/style.dart';
import 'package:noq/userHomePage.dart';
import 'package:noq/utils.dart';
import 'package:noq/widget/appbar.dart';
import 'package:noq/widget/bottom_nav_bar.dart';
import 'package:noq/widget/carousel_home_page.dart';
import 'package:noq/widget/header.dart';
import 'package:noq/widget/page_animation.dart';
import 'package:noq/widget/widgets.dart';
import 'package:share/share.dart';
import 'package:package_info/package_info.dart';

import 'dart:io' show Platform;
import 'package:flutter/foundation.dart';
import 'package:app_review/app_review.dart';

class UserAccountPage extends StatefulWidget {
  @override
  _UserAccountPageState createState() => _UserAccountPageState();
}

class _UserAccountPageState extends State<UserAccountPage> {
  int _page = 0;
  PageController _pageController;
  int i;
  List<UserToken> _pastBookingsList;
  List<UserToken> _newBookingsList;
  List<BookingApplication> _listOfApplications;
  String _upcomingBkgStatus;
  String _pastBkgStatus;
  // UserAppData _userProfile;
  DateTime now = DateTime.now();
  final dtFormat = new DateFormat(dateDisplayFormat);
  bool isUpcomingSet = false;
  bool isPastSet = false;
//Qr code scan result
  //ScanResult scanResult;
  GlobalState _gs;
  String _dynamicLink;
  String appID = "";
  String output = "";
  bool _initCompleted = false;

  //ScrollController _scrollController;
  // bool _expansionClick = false;

  @override
  void initState() {
    super.initState();
    if (!kIsWeb) _setTargetPlatformForDesktop();
    _pageController = PageController(initialPage: 8);

    _upcomingBkgStatus = 'Loading';
    _pastBkgStatus = 'Loading';

    getGlobalState().whenComplete(() {
      AppReview.getAppID.then((onValue) {
        setState(() {
          appID = onValue;
        });
        print("App ID" + appID);
      });
      _loadBookings().then((value) {
        _gs
            .getTokenApplicationService()
            .getApplications(null, null, null, _gs.getCurrentUser().ph, null,
                null, null, null, null, null, null)
            .then((value) {
          _listOfApplications = value;
          setState(() {
            _initCompleted = true;
          });
        });
      });
    });
  }

  void _setTargetPlatformForDesktop() {
    TargetPlatform targetPlatform;
    if (Platform.isMacOS) {
      targetPlatform = TargetPlatform.iOS;
    } else if (Platform.isLinux || Platform.isWindows) {
      targetPlatform = TargetPlatform.android;
    }
    if (targetPlatform != null) {
      debugDefaultTargetPlatformOverride = targetPlatform;
    }
  }

  Future<void> getGlobalState() async {
    _gs = await GlobalState.getGlobalState();
  }

  Future scan() async {
    // try {
    //   var result = await BarcodeScanner.scan();

    //   setState(() => scanResult = result);
    // } on PlatformException catch (e) {
    //   var result = ScanResult(
    //     type: ResultType.Error,
    //     format: BarcodeFormat.unknown,
    //   );

    //   if (e.code == BarcodeScanner.cameraAccessDenied) {
    //     setState(() {
    //       result.rawContent = 'The user did not grant the camera permission!';
    //     });
    //   } else {
    //     result.rawContent = 'Unknown error: $e';
    //   }
    //   setState(() {
    //     scanResult = result;
    //     print(scanResult);
    //   });
    // }
  }

  void fetchDataFromGlobalState() {
    if (!Utils.isNullOrEmpty(_gs.bookings)) {
      if (_gs.bookings.length != 0) {
        setState(() {
          _pastBookingsList = _gs.getPastBookings();

          _newBookingsList = _gs.getUpcomingBookings();

          if (_pastBookingsList.length != 0) {
            _pastBkgStatus = 'Success';
          } else
            _pastBkgStatus = 'NoBookings';
          if (_newBookingsList.length != 0) {
            _upcomingBkgStatus = 'Success';
          } else
            _upcomingBkgStatus = 'NoBookings';
        });
      }
    } else {
      setState(() {
        _upcomingBkgStatus = 'NoBookings';
        _pastBkgStatus = 'NoBookings';
      });
    }
  }

  Future<void> _loadBookings() async {
    //Fetch details from server

    //loadDataFromPrefs();
    fetchDataFromGlobalState();
  }

  List cardList = [Item1(), Item2(), Item3(), Item4(), Item5(), Item6()];
  List<T> map<T>(List list, Function handler) {
    List<T> result = [];
    for (var i = 0; i < list.length; i++) {
      result.add(handler(i, list[i]));
    }
    return result;
  }

  void showShoppingList(UserToken booking) {
    Navigator.of(context).push(PageNoAnimation.createRoute(ShoppingList(
      token: booking,
    )));
  }

  Widget _emptyStorePage(String msg1, String msg2) {
    return Center(
        child: Column(children: <Widget>[
      myDivider,
      Container(
          margin: EdgeInsets.fromLTRB(10, 10, 10, 10),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text(msg1, style: highlightTextStyle),
              Text(msg2, style: highlightSubTextStyle),
            ],
          ))
    ]));
  }

  Widget _buildItem(UserToken booking) {
    return Container(
        width: MediaQuery.of(context).size.width * .95,
        height: MediaQuery.of(context).size.width * .7 / 2.7,
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/ticket.jpg'),
            fit: BoxFit.fill,
          ),
        ),
        child: Stack(
          children: <Widget>[
            new Row(mainAxisAlignment: MainAxisAlignment.center, children: <
                Widget>[
              Container(
                width: MediaQuery.of(context).size.width * .7,
                height: MediaQuery.of(context).size.width * .7 / 3.5,
                child: Column(
                  //mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: <Widget>[
                    Container(
                      padding: EdgeInsets.fromLTRB(
                          MediaQuery.of(context).size.height * .008, 0, 0, 0),
                      alignment: Alignment.centerLeft,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            booking.getDisplayName(),
                            style: tokenTextStyle,
                            textAlign: TextAlign.left,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    Divider(
                      indent: MediaQuery.of(context).size.height * .008,
                      height: 1,
                      color: Colors.blueGrey[300],
                    ),
                    Column(
                      // mainAxisAlignment: MainAxisAlignment.end,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Container(
                          margin: EdgeInsets.fromLTRB(
                              MediaQuery.of(context).size.height * .008,
                              0,
                              0,
                              0),
                          padding: EdgeInsets.fromLTRB(
                              MediaQuery.of(context).size.height * .008,
                              0,
                              0,
                              0),
                          child: Text(
                            booking.entityName +
                                (booking.address != null
                                    ? (', ' + booking.address)
                                    : ''),
                            overflow: TextOverflow.ellipsis,
                            style: tokenDataTextStyle,
                          ),
                        ),
                        SizedBox(
                          height: MediaQuery.of(context).size.height * .008,
                        ),
                        Container(
                          // alignment: Alignment.centerLeft,
                          height: MediaQuery.of(context).size.width * .06,
                          //Text('Where: ', style: tokenHeadingTextStyle),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: <Widget>[
                              Container(
                                width: MediaQuery.of(context).size.width * .08,
                                height: MediaQuery.of(context).size.width * .07,
                                child: IconButton(
                                    padding: EdgeInsets.all(0),
                                    alignment: Alignment.center,
                                    highlightColor: Colors.orange[300],
                                    icon: Icon(
                                      Icons.phone,
                                      color: lightIcon,
                                      size: 20,
                                    ),
                                    onPressed: () {
                                      if (booking.phone != null) {
                                        try {
                                          callPhone(booking.phone);
                                        } catch (error) {
                                          Utils.showMyFlushbar(
                                              context,
                                              Icons.error,
                                              Duration(seconds: 5),
                                              "Could not connect call to the number ${booking.phone} !!",
                                              "Try again later.");
                                        }
                                      } else {
                                        Utils.showMyFlushbar(
                                            context,
                                            Icons.info,
                                            Duration(seconds: 5),
                                            "Contact information not found!!",
                                            "");
                                      }
                                    }),
                              ),
                              Container(
                                width: MediaQuery.of(context).size.width * .08,
                                height: MediaQuery.of(context).size.width * .07,
                                // width: 20.0,
                                child: IconButton(
                                  padding: EdgeInsets.all(0),
                                  alignment: Alignment.center,
                                  highlightColor: Colors.orange[300],
                                  icon: Icon(
                                    Icons.cancel,
                                    color: lightIcon,
                                    size: 22,
                                  ),
                                  onPressed: () {
                                    //If booking is past booking then no sense of cancelling , show msg to user
                                    if (booking.dateTime
                                        .isBefore(DateTime.now()))
                                      Utils.showMyFlushbar(
                                          context,
                                          Icons.info,
                                          Duration(seconds: 5),
                                          bookingExpired,
                                          "");
                                    //booking number is -1 means its already been cancelled, Do Nothing
                                    if (booking.number == -1)
                                      return null;
                                    else
                                      showCancelBooking(booking);
                                  },
                                ),
                              ),
                              Container(
                                width: MediaQuery.of(context).size.width * .08,
                                height: MediaQuery.of(context).size.width * .07,
                                // width: 20.0,
                                child: IconButton(
                                    padding: EdgeInsets.all(0),
                                    alignment: Alignment.center,
                                    highlightColor: Colors.orange[300],
                                    icon: Icon(
                                      Icons.location_on,
                                      color: lightIcon,
                                      size: 21,
                                    ),
                                    onPressed: () {
                                      try {
                                        launchURL(
                                            booking.entityName,
                                            booking.address,
                                            booking.lat,
                                            booking.lon);
                                      } catch (error) {
                                        Utils.showMyFlushbar(
                                            context,
                                            Icons.error,
                                            Duration(seconds: 5),
                                            "Could not open Maps!!",
                                            "Try again later.");
                                      }
                                    }),
                              ),
                              Container(
                                width: MediaQuery.of(context).size.width * .08,
                                height: MediaQuery.of(context).size.width * .07,
                                child: IconButton(
                                  padding: EdgeInsets.all(0),
                                  alignment: Alignment.center,
                                  highlightColor: Colors.orange[300],
                                  icon: ImageIcon(
                                    AssetImage('assets/whatsapp.png'),
                                    size: 18,
                                    color: Colors.white,
                                  ),
                                  onPressed: () {
                                    String phoneNo = booking.entityWhatsApp;
                                    if (phoneNo != null && phoneNo != "") {
                                      try {
                                        launchWhatsApp(
                                            message: whatsappMessageToPlaceOwner +
                                                booking.getDisplayName() +
                                                "\n\n<Type your message here..>",
                                            phone: phoneNo);
                                      } catch (error) {
                                        Utils.showMyFlushbar(
                                            context,
                                            Icons.error,
                                            Duration(seconds: 5),
                                            "Could not connect to the Whatsapp number $phoneNo !!",
                                            "Try again later");
                                      }
                                    } else {
                                      Utils.showMyFlushbar(
                                          context,
                                          Icons.info,
                                          Duration(seconds: 5),
                                          "Whatsapp contact information not found!!",
                                          "");
                                    }
                                  },
                                ),
                              ),
                              Container(
                                width: MediaQuery.of(context).size.width * .08,
                                height: MediaQuery.of(context).size.width * .07,
                                // width: 20.0,
                                child: IconButton(
                                  padding: EdgeInsets.all(0),
                                  alignment: Alignment.center,
                                  highlightColor: Colors.orange[300],
                                  icon: Icon(
                                    Icons.list,
                                    color: lightIcon,
                                    size: 22,
                                  ),
                                  onPressed: () => showShoppingList(booking),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              VerticalDivider(
                indent: 5,
                endIndent: 5,
                // thickness: 1,
                width: 1,
                color: Colors.blueGrey[300],
              ),
              Container(
                width: MediaQuery.of(context).size.width * .21,
                // padding: EdgeInsets.fromLTRB(5, 5, 0, 0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    //verticalSpacer,
                    Text(
                      dtFormat.format(booking.dateTime),
                      style: tokenDataTextStyle,
                    ),
                    Container(
                      height: 5,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: <Widget>[
                        // Text('Time: ', style: tokenHeadingTextStyle),
                        Text(
                          Utils.formatTime(booking.dateTime.hour.toString()) +
                              ':' +
                              Utils.formatTime(
                                  booking.dateTime.minute.toString()),
                          style: tokenDateTextStyle,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ]),
            if (booking.number == -1)
              new Positioned(
                left: MediaQuery.of(context).size.width * .5,
                bottom: MediaQuery.of(context).size.width * .14,
                child: new Container(
                  //color: Colors.red,
                  height: MediaQuery.of(context).size.width * .1,
                  width: MediaQuery.of(context).size.width * .4,
                  child: Image.asset('assets/cancelled_2.png'),
                ),
              ),
          ],
        ));
  }

  void showCancelBooking(UserToken booking) {
    showDialog(
        barrierDismissible: false,
        context: context,
        builder: (_) => AlertDialog(
              titlePadding: EdgeInsets.fromLTRB(10, 15, 10, 10),
              contentPadding: EdgeInsets.all(0),
              actionsPadding: EdgeInsets.all(5),
              //buttonPadding: EdgeInsets.all(0),
              title: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    'Are you sure you want to cancel this booking?',
                    style: TextStyle(
                      fontSize: 15,
                      color: Colors.blueGrey[600],
                    ),
                  ),
                  verticalSpacer,
                  // myDivider,
                ],
              ),
              content: Divider(
                color: Colors.blueGrey[400],
                height: 1,
                //indent: 40,
                //endIndent: 30,
              ),

              //content: Text('This is my content'),
              actions: <Widget>[
                SizedBox(
                  height: 24,
                  child: RaisedButton(
                    elevation: 0,
                    color: Colors.transparent,
                    splashColor: highlightColor.withOpacity(.8),
                    textColor: Colors.orange,
                    shape: RoundedRectangleBorder(
                        side: BorderSide(color: Colors.orange)),
                    child: Text('Yes'),
                    onPressed: () {
                      print("Cancel booking");
                      bool cancelDone = false;
                      cancelToken(booking).then((value) {
                        setState(() {
                          booking.number = -1;
                        });

                        cancelDone = value;
                        if (!cancelDone) {
                          Utils.showMyFlushbar(
                              context,
                              Icons.info_outline,
                              Duration(
                                seconds: 5,
                              ),
                              "Couldn't cancel your booking for some reason. ",
                              "Please try again later.");
                        }
                      }).catchError((e) {
                        print(e);
                      });
                      Navigator.of(context, rootNavigator: true).pop();
                      Utils.showMyFlushbar(
                          context,
                          Icons.cancel,
                          Duration(
                            seconds: 3,
                          ),
                          "Cancelling your booking",
                          "Please wait..");
                    },
                  ),
                ),
                SizedBox(
                  height: 24,
                  child: RaisedButton(
                    elevation: 20,
                    autofocus: true,
                    focusColor: highlightColor,
                    splashColor: highlightColor,
                    color: Colors.white,
                    textColor: Colors.orange,
                    shape: RoundedRectangleBorder(
                        side: BorderSide(color: Colors.orange)),
                    child: Text('No'),
                    onPressed: () {
                      print("Do nothing");
                      Navigator.of(context, rootNavigator: true).pop();
                      // Navigator.of(context, rootNavigator: true).pop('dialog');
                    },
                  ),
                ),
              ],
            ));
  }

  List drawerItems = [
    {
      "icon": Icons.account_circle,
      "name": "My Account",
      "pageRoute": UserAccountPage(),
    },
    {
      "icon": Icons.notifications,
      "name": "Notifications",
      "pageRoute": UserNotificationsPage(),
    },
  ];

  void onPageChanged(int page) {
    setState(() {
      _page = page;
    });
  }

  void navigationTapped(int page) {
    _pageController.jumpToPage(page);
  }

  openPlayStoreAndRate() async {
    PackageInfo info = await PackageInfo.fromPlatform();
    String packageName = info.packageName;

    // AppReview.writeReview.then((onValue) {
    //   setState(() {
    //     output = onValue;
    //   });
    //   print(onValue);
    // });

    //  openRateReviewForIos();
    launchPlayStore(packageName: packageName);

    // launch("https://play.google.com/store/apps/details?id=" + packageName);
  }

  @override
  void dispose() {
    super.dispose();
    _pageController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    String message = 'Hey,' +
        appName +
        ' app is simple and fast way that\n'
            'I use to book time-slots for the\n'
            'places I wish to go. It helps to \n'
            'avoid waiting in queue. Check it out yourself.';
    String link = "www.playstore.com";
    String inviteText = message + link;
    String inviteSubject = "Invite friends via..";
    String title = "My Account";
    if (_initCompleted) {
      return MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData.light().copyWith(),
        home: WillPopScope(
          child: Scaffold(
            appBar: CustomAppBarWithBackButton(
              backRoute: UserHomePage(),
              titleTxt: title,
            ),
            body: Column(
              children: <Widget>[
                Container(
                  height: MediaQuery.of(context).size.height * .7,
                  child: Scrollbar(
                    child: SingleChildScrollView(
                      padding: EdgeInsets.all(
                          MediaQuery.of(context).size.width * .036),
                      child: Column(
                        //  mainAxisSize: MainAxisSize.max,
                        // mainAxisAlignment: MainAxisAlignment.start,
                        children: <Widget>[
                          //verticalSpacer,
                          Card(
                            margin: EdgeInsets.zero,
                            elevation: 20,
                            child: Container(
                              color: Colors.transparent,
                              height: MediaQuery.of(context).size.height * .15,
                              width: MediaQuery.of(context).size.width * .95,
                              child: Row(
                                children: <Widget>[
                                  Container(
                                    height: MediaQuery.of(context).size.height *
                                        .13,
                                    width:
                                        MediaQuery.of(context).size.width * .35,
                                    child: Image(
                                      image:
                                          AssetImage('assets/user_account.png'),
                                    ),
                                  ),
                                  RichText(
                                      text: TextSpan(
                                          style: userAccountHeadingTextStyle,
                                          children: <TextSpan>[
                                        TextSpan(text: userAccountHeadingTxt),
                                        TextSpan(text: "\n"),
                                        TextSpan(
                                          text: _gs.getCurrentUser() != null
                                              ? _gs.getCurrentUser().ph
                                              : "",
                                        )
                                      ])),
                                ],
                              ),
                            ),
                          ),
                          SizedBox(
                            height: MediaQuery.of(context).size.height * .03,
                          ),
                          Card(
                            margin: EdgeInsets.zero,
                            elevation: 20,
                            child: Container(
                                padding: EdgeInsets.all(5),
                                width: MediaQuery.of(context).size.width * .95,
                                decoration: BoxDecoration(
                                    // border: Border.all(color: containerColor),
                                    color: Colors.grey[50],
                                    shape: BoxShape.rectangle,
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(5.0))),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  children: <Widget>[
                                    Container(
                                      width: MediaQuery.of(context).size.width *
                                          .43,
                                      child: RaisedButton(
                                          color: btnColor,
                                          textColor: Colors.white,
                                          splashColor: highlightColor,
                                          onPressed: () {
                                            openPlayStoreAndRate();
                                            Utils.showMyFlushbar(
                                                context,
                                                Icons.help_outline,
                                                Duration(seconds: 3),
                                                "Thanks!!",
                                                ratingMsg);
                                          },
                                          child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: <Widget>[
                                                Icon(Icons.star),
                                                Text(
                                                  ' Rate the app',
                                                  style:
                                                      TextStyle(fontSize: 12),
                                                  textAlign: TextAlign.center,
                                                ),
                                              ])),
                                    ),
                                    horizontalSpacer,
                                    Container(
                                      width: MediaQuery.of(context).size.width *
                                          .43,
                                      child: RaisedButton(
                                        color: btnColor,
                                        textColor: Colors.white,
                                        splashColor: highlightColor,
                                        onPressed: inviteText.isEmpty
                                            ? null
                                            : () {
                                                // A builder is used to retrieve the context immediately
                                                // surrounding the RaisedButton.
                                                //
                                                // The context's `findRenderObject` returns the first
                                                // RenderObject in its descendent tree when it's not
                                                // a RenderObjectWidget. The RaisedButton's RenderObject
                                                // has its position and size after it's built.
                                                final RenderBox box =
                                                    context.findRenderObject();

                                                Utils.generateLinkAndShare(
                                                    null,
                                                    appShareHeading,
                                                    appShareMessage);
                                              },
                                        child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: <Widget>[
                                              Icon(Icons.share),
                                              Text(
                                                'Invite friends',
                                                style: TextStyle(fontSize: 12),
                                                textAlign: TextAlign.center,
                                              ),
                                            ]),
                                      ),
                                    ),
                                  ],
                                )),
                          ),
                          SizedBox(
                            height: MediaQuery.of(context).size.height * .03,
                          ),
                          Card(
                            margin: EdgeInsets.zero,
                            elevation: 20,
                            child: Theme(
                              data: ThemeData(
                                unselectedWidgetColor: Colors.grey[600],
                                accentColor: btnColor,
                              ),
                              child: ExpansionTile(
                                //key: PageStorageKey(this.widget.headerTitle),

                                title: Text(
                                  "My Applications",
                                  style: TextStyle(
                                      color: Colors.blueGrey[700],
                                      fontSize: 17),
                                ),
                                backgroundColor: Colors.white,
                                leading: Icon(
                                  Icons.app_registration,
                                  color: primaryIcon,
                                ),
                                children: <Widget>[
                                  if (!Utils.isNullOrEmpty(_listOfApplications))
                                    Scrollbar(
                                      child: ListView.builder(
                                        padding: EdgeInsets.all(
                                            MediaQuery.of(context).size.width *
                                                .026),

                                        reverse: true,
                                        shrinkWrap: true,
                                        //itemExtent: itemSize,
                                        itemBuilder:
                                            (BuildContext context, int index) {
                                          return Container(
                                            margin: EdgeInsets.only(bottom: 5),
                                            child: UserApplicationsList(
                                              ba: _listOfApplications[index],
                                            ),
                                          );
                                        },
                                        itemCount: _listOfApplications.length,
                                      ),
                                    ),
                                  if (Utils.isNullOrEmpty(_listOfApplications))
                                    _emptyStorePage(
                                        "No Applications yet.. ", bookNowMsg),
                                ],
                              ),
                            ),
                          ),
                          SizedBox(
                            height: MediaQuery.of(context).size.height * .03,
                          ),
                          Card(
                            margin: EdgeInsets.zero,
                            elevation: 20,
                            child: Theme(
                              data: ThemeData(
                                unselectedWidgetColor: Colors.grey[600],
                                accentColor: btnColor,
                              ),
                              child: ExpansionTile(
                                //key: PageStorageKey(this.widget.headerTitle),

                                title: Text(
                                  "Upcoming Bookings",
                                  style: TextStyle(
                                      color: Colors.blueGrey[700],
                                      fontSize: 17),
                                ),
                                backgroundColor: Colors.white,
                                leading: Icon(
                                  Icons.date_range,
                                  color: primaryIcon,
                                ),
                                children: <Widget>[
                                  if (_upcomingBkgStatus == 'Success')
                                    Scrollbar(
                                      child: ListView.builder(
                                        shrinkWrap: true,
                                        scrollDirection: Axis.vertical,
                                        physics: ClampingScrollPhysics(),
                                        itemBuilder:
                                            (BuildContext context, int index) {
                                          return Container(
                                            child: new Column(
                                                children: _newBookingsList
                                                    .map(_buildItem)
                                                    .toList()),
                                            //children: <Widget>[firstRow, secondRow],
                                          );
                                        },
                                        itemCount: 1,
                                      ),
                                    ),
                                  if (_upcomingBkgStatus == 'NoBookings')
                                    _emptyStorePage(
                                        "No bookings yet.. ", bookNowMsg),
                                  if (_upcomingBkgStatus == 'Loading')
                                    showCircularProgress(),
                                ],
                              ),
                            ),
                          ),
                          SizedBox(
                            height: MediaQuery.of(context).size.height * .03,
                          ),
                          Card(
                            margin: EdgeInsets.zero,
                            elevation: 20,
                            child: Theme(
                              data: ThemeData(
                                unselectedWidgetColor: Colors.grey[600],
                                accentColor: btnColor,
                              ),
                              child: ExpansionTile(
                                initiallyExpanded: true,
                                title: Text(
                                  "Past Bookings",
                                  style: TextStyle(
                                      color: Colors.blueGrey[700],
                                      fontSize: 17),
                                ),
                                backgroundColor: Colors.white,
                                leading: Icon(
                                  Icons.access_time,
                                  color: primaryIcon,
                                ),
                                children: <Widget>[
                                  Column(
                                    children: <Widget>[
                                      if (_pastBkgStatus == "Success")
                                        ListView.builder(
                                          shrinkWrap: true,
                                          scrollDirection: Axis.vertical,
                                          physics: ClampingScrollPhysics(),
                                          itemBuilder: (BuildContext context,
                                              int index) {
                                            return Container(
                                              child: new Column(
                                                  children: _pastBookingsList
                                                      .map(_buildItem)
                                                      .toList()),
                                              //children: <Widget>[firstRow, secondRow],
                                            );
                                          },
                                          itemCount: 1,
                                        ),
                                      if (_pastBkgStatus == 'NoBookings')
                                        _emptyStorePage("No bookings in past..",
                                            bookNowMsg),
                                      if (_pastBkgStatus == 'Loading')
                                        showCircularProgress(),
                                    ],
                                  )
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Container(
                  height: MediaQuery.of(context).size.height * .06,
                  width: MediaQuery.of(context).size.width,
                  child: RaisedButton(
                      color: btnColor,
                      textColor: Colors.white,
                      splashColor: highlightColor,
                      onPressed: () {
                        Utils.logout(context);
                      },
                      child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Icon(Icons.exit_to_app),
                            Text(
                              '  Logout',
                              textAlign: TextAlign.center,
                            ),
                          ])),
                ),
              ],
            ),
            bottomNavigationBar: CustomBottomBar(
              barIndex: 3,
            ),
          ),
          onWillPop: () async {
            Navigator.of(context)
                .push(PageAnimation.createRoute(UserHomePage()));
            return false;
          },
        ),
      );
    } else {
      return MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData.light().copyWith(),
        home: WillPopScope(
          child: Scaffold(
            appBar: CustomAppBarWithBackButton(
              backRoute: UserHomePage(),
              titleTxt: title,
            ),
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  showCircularProgress(),
                ],
              ),
            ),
            bottomNavigationBar: CustomBottomBar(
              barIndex: 3,
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
