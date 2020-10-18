import 'package:barcode_scan/barcode_scan.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:noq/constants.dart';
import 'package:noq/db/db_model/user_token.dart';
import 'package:noq/global_state.dart';
import 'package:noq/pages/dynamic_links.dart';
import 'package:noq/pages/notifications_page.dart';
import 'package:noq/pages/shopping_list.dart';
import 'package:noq/repository/slotRepository.dart';
import 'package:noq/services/circular_progress.dart';
import 'package:noq/services/mapService.dart';
import 'package:noq/services/qr_code_generate.dart';
import 'package:noq/style.dart';

import 'package:noq/userHomePage.dart';
import 'package:noq/utils.dart';
import 'package:noq/widget/appbar.dart';
import 'package:noq/widget/bottom_nav_bar.dart';
import 'package:noq/widget/carousel.dart';
import 'package:noq/widget/custom_expansion_tile.dart';
import 'package:noq/widget/header.dart';
import 'package:noq/widget/widgets.dart';
import 'package:share/share.dart';
import 'package:package_info/package_info.dart';
import 'package:url_launcher/url_launcher.dart';

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
  String _upcomingBkgStatus;
  String _pastBkgStatus;
  // UserAppData _userProfile;
  DateTime now = DateTime.now();
  final dtFormat = new DateFormat(dateDisplayFormat);
  bool isUpcomingSet = false;
  bool isPastSet = false;
//Qr code scan result
  ScanResult scanResult;
  GlobalState _state;
  String _dynamicLink;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: 8);
    setState(() {
      _upcomingBkgStatus = 'Loading';
      _pastBkgStatus = 'Loading';
    });
    getGlobalState().whenComplete(() => _loadBookings());
  }

  Future<void> getGlobalState() async {
    _state = await GlobalState.getGlobalState();
  }

  Future scan() async {
    try {
      var result = await BarcodeScanner.scan();

      setState(() => scanResult = result);
    } on PlatformException catch (e) {
      var result = ScanResult(
        type: ResultType.Error,
        format: BarcodeFormat.unknown,
      );

      if (e.code == BarcodeScanner.cameraAccessDenied) {
        setState(() {
          result.rawContent = 'The user did not grant the camera permission!';
        });
      } else {
        result.rawContent = 'Unknown error: $e';
      }
      setState(() {
        scanResult = result;
        print(scanResult);
      });
    }
  }

  void fetchDataFromGlobalState() {
    if (!Utils.isNullOrEmpty(_state.bookings)) {
      if (_state.bookings.length != 0) {
        setState(() {
          _pastBookingsList = _state.getPastBookings();

          _newBookingsList = _state.getUpcomingBookings();

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

  void _loadBookings() async {
    //Fetch details from server

    //loadDataFromPrefs();
    fetchDataFromGlobalState();
  }

  int _currentIndex = 0;
  List cardList = [Item1(), Item2(), Item3(), Item4(), Item5(), Item6()];
  List<T> map<T>(List list, Function handler) {
    List<T> result = [];
    for (var i = 0; i < list.length; i++) {
      result.add(handler(i, list[i]));
    }
    return result;
  }

  @override
  String getEntityAddress(String entityId) {
    //TODO SMITA Add implementation
    return 'Gachibowli, Hyderabad';
  }

  void showShoppingList(UserToken booking) {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => ShoppingList(
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
    String address = getEntityAddress(booking.entityId);
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
                width: MediaQuery.of(context).size.width * .68,
                height: MediaQuery.of(context).size.width * .7 / 3.5,
                child: Column(
                  //mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: <Widget>[
                    Container(
                      padding: EdgeInsets.fromLTRB(5, 0, 0, 0),
                      alignment: Alignment.centerLeft,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          // Text(
                          //   'TOKEN No. -',
                          //   style: tokenTextStyle,
                          //   textAlign: TextAlign.left,
                          // ),
                          Text(
                            booking.getDisplayName(),
                            style: tokenTextStyle,
                            textAlign: TextAlign.left,
                          ),
                        ],
                      ),
                    ),
                    Divider(
                      indent: 5,

                      // thickness: 1,
                      height: 1,
                      color: Colors.blueGrey[300],
                    ),
                    Column(
                      // mainAxisAlignment: MainAxisAlignment.end,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Container(
                          padding: EdgeInsets.fromLTRB(5, 0, 0, 0),
                          child: Text(
                            booking.entityName + ', ' + address,
                            overflow: TextOverflow.ellipsis,
                            style: tokenDataTextStyle,
                          ),
                        ),
                        SizedBox(
                          height: 2,
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
                                        launchURL(booking.entityName, address,
                                            booking.lat, booking.lon);
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
                                            message: whatsappMessage,
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
                          booking.dateTime.hour.toString() +
                              ':' +
                              booking.dateTime.minute.toString(),
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

    launchPlayStore(packageName: packageName);

    // launch("https://play.google.com/store/apps/details?id=" + packageName);
    Utils.showMyFlushbar(
        context,
        Icons.help_outline,
        Duration(seconds: 3),
        "Opening play store!!",
        "It will really help us and shouldn't take more than a minute.");
  }

  // openFeedbackPage() async {
  //   print("To be done next....hold on!!!");
  //   Utils.showMyFlushbar(
  //       context,
  //       Icons.help_outline,
  //       Duration(seconds: 3),
  //       "It seems you might have to wait a little longer!!",
  //       "...work in progress");
  // }

  generateLinkAndShare() async {
    var dynamicLink = await Utils.createDynamicLink();
    print("Dynamic Link: $dynamicLink");
    // _dynamicLink =
    //     Uri.https(dynamicLink.authority, dynamicLink.path).toString();
    // dynamicLink has been generated. share it with others to use it accordingly.
    Share.share(Uri.https(dynamicLink.authority, dynamicLink.path).toString());
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
    return MaterialApp(
      theme: ThemeData.light().copyWith(),
      home: Scaffold(
        drawer: CustomDrawer(),
        appBar: CustomAppBar(
          titleTxt: title,
        ),
        body: Scrollbar(
          child: SingleChildScrollView(
            padding: EdgeInsets.all(5),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Card(
                  margin: EdgeInsets.zero,
                  child: Container(
                      width: MediaQuery.of(context).size.width,
                      decoration: BoxDecoration(
                          border: Border.all(color: containerColor),
                          color: Colors.grey[50],
                          shape: BoxShape.rectangle,
                          borderRadius: BorderRadius.all(Radius.circular(5.0))),
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Container(
                              decoration: darkContainer,
                              padding: EdgeInsets.all(3),
                              child: Row(
                                  mainAxisSize: MainAxisSize.max,
                                  children: <Widget>[
                                    Text(
                                      " ...what more to do!!",
                                      style: TextStyle(
                                          color: Colors.white, fontSize: 15),
                                    ),
                                  ]),
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: <Widget>[
                                Container(
                                  width: MediaQuery.of(context).size.width * .3,
                                  child: RaisedButton(
                                      color: btnColor,
                                      textColor: Colors.white,
                                      splashColor: highlightColor,
                                      onPressed: () {
                                        openPlayStoreAndRate();
                                      },
                                      child: const Text(
                                        'Rate the app',
                                        textAlign: TextAlign.center,
                                      )),
                                ),
                                Container(
                                  width: MediaQuery.of(context).size.width * .3,
                                  child: RaisedButton(
                                      color: btnColor,
                                      textColor: Colors.white,
                                      splashColor: highlightColor,
                                      onPressed: () {
                                        // openFeedbackPage();
                                      },
                                      child: const Text(
                                        'Give Feedback',
                                        textAlign: TextAlign.center,
                                      )),
                                ),
                                Container(
                                  width: MediaQuery.of(context).size.width * .3,
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

                                              generateLinkAndShare();
                                            },
                                      child: const Text(
                                        'Invite friends',
                                        textAlign: TextAlign.center,
                                      )),
                                ),
                              ],
                            ),
                          ])),
                ),
                verticalSpacer,
                Container(
                  decoration: BoxDecoration(
                      border: Border.all(color: containerColor),
                      color: Colors.grey[50],
                      shape: BoxShape.rectangle,
                      borderRadius: BorderRadius.all(Radius.circular(5.0))),
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Container(
                          decoration: darkContainer,
                          padding: EdgeInsets.all(3),
                          child: Row(
                              mainAxisSize: MainAxisSize.max,
                              children: <Widget>[
                                Text(
                                  " My Bookings",
                                  style: TextStyle(
                                      color: Colors.white, fontSize: 15),
                                ),
                              ]),
                        ),
                        Card(
                          margin: EdgeInsets.zero,
                          elevation: 20,
                          child: Theme(
                            data: ThemeData(
                              unselectedWidgetColor: Colors.grey[600],
                              accentColor: Colors.teal,
                            ),
                            child: ExpansionTile(
                              //key: PageStorageKey(this.widget.headerTitle),
                              initiallyExpanded: true,
                              title: Text(
                                "Upcoming Bookings",
                                style: TextStyle(
                                    color: Colors.blueGrey[700], fontSize: 17),
                              ),
                              backgroundColor: Colors.white,
                              leading: Icon(
                                Icons.date_range,
                                color: primaryIcon,
                              ),
                              children: <Widget>[
                                if (_upcomingBkgStatus == 'Success')
                                  ConstrainedBox(
                                    constraints: new BoxConstraints(
                                      maxHeight:
                                          MediaQuery.of(context).size.height *
                                              .4,
                                      maxWidth:
                                          MediaQuery.of(context).size.width,
                                    ),

                                    // decoration: BoxDecoration(
                                    //     shape: BoxShape.rectangle,
                                    //     borderRadius: BorderRadius.all(Radius.circular(8.0))),
                                    // height: MediaQuery.of(context).size.height * .6,
                                    // margin: EdgeInsets.fromLTRB(10, 10, 10, 10),
                                    child: Scrollbar(
                                      child: ListView.builder(
                                        shrinkWrap: true,
                                        //scrollDirection: Axis.vertical,
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
                                  ),
                                if (_upcomingBkgStatus == 'NoBookings')
                                  _emptyStorePage("No bookings yet.. ",
                                      "Book now to save time later!! "),
                                if (_upcomingBkgStatus == 'Loading')
                                  showCircularProgress(),
                              ],
                            ),
                          ),
                        ),
                        verticalSpacer,
                        Card(
                          margin: EdgeInsets.zero,
                          elevation: 20,
                          child: Theme(
                            data: ThemeData(
                              unselectedWidgetColor: Colors.grey[600],
                              accentColor: Colors.teal,
                            ),
                            child: ExpansionTile(
                              title: Text(
                                "Past Bookings",
                                style: TextStyle(
                                    color: Colors.blueGrey[700], fontSize: 17),
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
                                      ConstrainedBox(
                                        constraints: new BoxConstraints(
                                          maxHeight: MediaQuery.of(context)
                                                  .size
                                                  .height *
                                              .4,
                                        ),
                                        child: Scrollbar(
                                          child: ListView.builder(
                                            shrinkWrap: true,
                                            scrollDirection: Axis.vertical,
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
                                        ),
                                      ),
                                    if (_pastBkgStatus == 'NoBookings')
                                      _emptyStorePage("No bookings in past..",
                                          "Book now to save time later!! "),
                                    if (_pastBkgStatus == 'Loading')
                                      showCircularProgress(),
                                  ],
                                )
                              ],
                            ),
                          ),
                        ),
                      ]),
                ),
                verticalSpacer,
                Container(
                  color: primaryDarkColor,
                  child: Column(
                    children: <Widget>[
                      CarouselSlider(
                        options: CarouselOptions(
                          height: MediaQuery.of(context).size.height * .9,
                          autoPlay: true,
                          autoPlayInterval: Duration(seconds: 3),
                          autoPlayAnimationDuration:
                              Duration(milliseconds: 800),
                          autoPlayCurve: Curves.easeInCubic,
                          pauseAutoPlayOnTouch: true,
                          aspectRatio: 2.0,
                          onPageChanged: (index, carouselPageChangedReason) {
                            setState(() {
                              _currentIndex = index;
                            });
                          },
                        ),
                        items: cardList.map((card) {
                          return Builder(builder: (BuildContext context) {
                            return Container(
                              height: MediaQuery.of(context).size.height * 0.40,
                              width: MediaQuery.of(context).size.width,
                              child: Card(
                                color: primaryDarkColor,
                                child: card,
                              ),
                            );
                          });
                        }).toList(),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: map<Widget>(cardList, (index, url) {
                              return Container(
                                width: 7.0,
                                height: 7.0,
                                margin: EdgeInsets.symmetric(
                                    vertical: 2.0, horizontal: 2.0),
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: _currentIndex == index
                                      ? highlightColor
                                      : Colors.grey,
                                ),
                              );
                            }),
                          ),
                        ],
                      )
                    ],
                  ),
                ),
                verticalSpacer,
                //This is start of boxed container.
                Container(
                  decoration: BoxDecoration(
                      border: Border.all(color: containerColor),
                      color: Colors.grey[50],
                      shape: BoxShape.rectangle,
                      borderRadius: BorderRadius.all(Radius.circular(5.0))),
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Container(
                          decoration: darkContainer,
                          padding: EdgeInsets.all(3),
                          child: Row(
                              mainAxisSize: MainAxisSize.max,
                              children: <Widget>[
                                Text(
                                  " Notifications",
                                  style: TextStyle(
                                      color: Colors.white, fontSize: 15),
                                ),
                              ]),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: <Widget>[
                            Text("Add more actions here.."),
                          ],
                        )
                      ]),
                ),
                //This is end of boxed container.
                verticalSpacer,
                //This is start of boxed container.
                Container(
                  decoration: BoxDecoration(
                      border: Border.all(color: containerColor),
                      color: Colors.grey[50],
                      shape: BoxShape.rectangle,
                      borderRadius: BorderRadius.all(Radius.circular(5.0))),
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Container(
                          decoration: darkContainer,
                          padding: EdgeInsets.all(3),
                          child: Row(
                              mainAxisSize: MainAxisSize.max,
                              children: <Widget>[
                                Text(
                                  " Settings",
                                  style: TextStyle(
                                      color: Colors.white, fontSize: 15),
                                ),
                              ]),
                        ),
                        Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: <Widget>[
                              Text("Need a change.. Right at your service!!"),
                            ]),
                      ]),
                ),
                //This is end of boxed container.
              ],
            ),
          ),
        ),
        bottomNavigationBar: CustomBottomBar(
          barIndex: 3,
        ),
      ),
    );
  }
}
