import 'dart:async';

import 'package:flutter/material.dart';
import './constants.dart';

import './global_state.dart';
import './pages/how_to_reg_for_business.dart';
import './pages/how_to_reg_for_users.dart';
import './pages/search_entity_page.dart';
import './pages/db_test.dart';
import './pages/shopping_list.dart';
import './repository/slotRepository.dart';
import './services/circular_progress.dart';
import './services/url_services.dart';
import './services/qr_code_scan.dart';
import './style.dart';
import 'package:intl/intl.dart';
import './utils.dart';
import './widget/appbar.dart';
import './widget/bottom_nav_bar.dart';
import './widget/carousel_home_page.dart';
import './widget/header.dart';
import './widget/page_animation.dart';
import './widget/widgets.dart';

import 'db/db_model/user_token.dart';
import 'package:carousel_slider/carousel_slider.dart';
//import 'path';

class UserHomePage extends StatefulWidget {
  @override
  _UserHomePageState createState() => _UserHomePageState();
}

class _UserHomePageState extends State<UserHomePage> {
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
  //ScanResult scanResult;
  GlobalState _state;
  bool _initCompleted = false;

  @override
  void initState() {
    super.initState();
    getGlobalState().whenComplete(() {
      _loadBookings();
      if (this.mounted) {
        setState(() {
          _initCompleted = true;
        });
      } else
        _initCompleted = true;
    });
  }

  @override
  void dispose() {
    super.dispose();
    _state = null;
  }

  Future<void> getGlobalState() async {
    _state = await GlobalState.getGlobalState();
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
    if (!Utils.isNullOrEmpty(_state.bookings)) {
      if (_state.bookings.length != 0) {
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
      }
    } else {
      _upcomingBkgStatus = 'NoBookings';
      _pastBkgStatus = 'NoBookings';
    }
  }

  void _loadBookings() async {
    //Fetch booking details from server
    fetchDataFromGlobalState();
  }

  int _currentIndex = 0;
  List cardList = [
    Item1(),
    Item2(),
    Item3(),
    Item4(),
    Item5(),
    Item6(),
    //  Item7()
  ];
  List<T> map<T>(List list, Function handler) {
    List<T> result = [];
    for (var i = 0; i < list.length; i++) {
      result.add(handler(i, list[i]));
    }
    return result;
  }

  @override
  Widget build(BuildContext context) {
    if (_initCompleted) {
      String title = "Home Page";
      return MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: ThemeData.light().copyWith(),
          home: WillPopScope(
            child: Scaffold(
              resizeToAvoidBottomInset: false,
              appBar: CustomAppBar(
                titleTxt: title,
              ),
              body: Scrollbar(
                child: SingleChildScrollView(
                  padding:
                      EdgeInsets.all(MediaQuery.of(context).size.width * .036),
                  child: Column(
                    children: <Widget>[
                      Card(
                        margin: EdgeInsets.zero,
                        elevation: 20,
                        child: Container(
                          height: MediaQuery.of(context).size.height * .37,
                          padding: EdgeInsets.all(5),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              Column(
                                children: <Widget>[
                                  CarouselSlider(
                                    options: CarouselOptions(
                                      height:
                                          MediaQuery.of(context).size.height *
                                              .255,
                                      autoPlay: true,
                                      autoPlayInterval: Duration(seconds: 3),
                                      autoPlayAnimationDuration:
                                          Duration(milliseconds: 800),
                                      autoPlayCurve: Curves.easeIn,
                                      pauseAutoPlayOnTouch: true,
                                      aspectRatio: 2.0,
                                      onPageChanged:
                                          (index, carouselPageChangedReason) {
                                        setState(() {
                                          _currentIndex = index;
                                        });
                                      },
                                    ),
                                    items: cardList.map((card) {
                                      return Builder(
                                          builder: (BuildContext context) {
                                        return Container(
                                          height: MediaQuery.of(context)
                                                  .size
                                                  .height *
                                              0.4,
                                          width:
                                              MediaQuery.of(context).size.width,
                                          child: Card(
                                            color: primaryAccentColor,
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
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children:
                                            map<Widget>(cardList, (index, url) {
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
                              Column(
                                children: <Widget>[
                                  Text(homeScreenMsgTxt2, style: homeMsgStyle2),
                                  Text(
                                    homeScreenMsgTxt3,
                                    style: homeMsgStyle3,
                                  ),
                                ],
                              )
                            ],
                          ),
                        ),
                        //child: Image.asset('assets/noq_home.png'),
                      ),
                      verticalSpacer,
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
                                ListView.builder(
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
                                    );
                                  },
                                  itemCount: 1,
                                ),
                              if (_upcomingBkgStatus == 'NoBookings')
                                _emptyStorePage(
                                    "No bookings yet.. ", bookNowMsg),
                            ],
                          ),
                        ),
                      ),

                      verticalSpacer,
                      // Card(
                      //   margin: EdgeInsets.zero,
                      //   elevation: 20,
                      //   child: Container(
                      //     height: MediaQuery.of(context).size.height * .2,
                      //     margin: EdgeInsets.zero,
                      //     padding: EdgeInsets.all(0),
                      //     child: Image(
                      //       image: AssetImage('assets/6.jpg'),
                      //       fit: BoxFit.fitHeight,
                      //     ),
                      //   ),
                      // ),
                      // verticalSpacer,
                      Column(
                        children: [
                          GestureDetector(
                            onTap: () {
                              //User clicked on show how, lets show them.
                              print("Showing how to book time-slot");
                              Navigator.of(context).push(
                                  PageAnimation.createRoute(
                                      HowToRegForBusiness()));
                            },
                            child: Container(
                              width: MediaQuery.of(context).size.width,
                              margin: EdgeInsets.zero,
                              padding: EdgeInsets.all(0),
                              alignment: Alignment.topLeft,
                              child: Image(
                                image: AssetImage(
                                    'assets/how_to_register_business.png'),
                              ),
                            ),
                          ),
                          verticalSpacer,
                          GestureDetector(
                            onTap: () {
                              //User clicked on show how, lets show them.
                              print("Showing how to book time-slot");
                              Navigator.of(context).push(
                                  PageAnimation.createRoute(
                                      HowToRegForUsers()));
                            },
                            child: Container(
                              width: MediaQuery.of(context).size.width,
                              margin: EdgeInsets.zero,
                              padding: EdgeInsets.all(0),
                              alignment: Alignment.topLeft,
                              child: Image(
                                image:
                                    AssetImage('assets/how_to_book_slot.png'),
                              ),
                            ),
                          ),
                          Container(
                            height: MediaQuery.of(context).size.height * .06,
                          ),
                        ],
                      ),
                      if (_state?.getCurrentUser()?.ph == '+919999999999')
                        Container(
                          height: 30,
                          width: 60,
                          child: RaisedButton(
                            color: btnColor,
                            onPressed: () {
                              print("testing");
                              DBTest().dbCall();
                              print("testing updated");
                            },
                            child: Text("Run test"),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              floatingActionButton: SizedBox(
                height: 45,
                child: new FloatingActionButton(
                    splashColor: highlightColor,
                    elevation: 30.0,
                    child: ImageIcon(
                      AssetImage('assets/qrcode.png'),
                      size: 25,
                      color: primaryIcon,
                    ),
                    backgroundColor: primaryAccentColor,
                    onPressed: () {
                      QrCodeScanner.scan(context);
                    }),
              ),
              floatingActionButtonLocation:
                  FloatingActionButtonLocation.centerDocked,
              drawer: CustomDrawer(
                phone: _state?.getCurrentUser()?.ph,
              ),
              bottomNavigationBar: CustomBottomBar(
                barIndex: 0,
              ),
            ),
            onWillPop: () async {
              return true;
            },
          ),
          routes: <String, WidgetBuilder>{
            '/DLink': (BuildContext context) => new SearchEntityPage(),
          });
    } else {
      return MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData.light().copyWith(),
        home: WillPopScope(
          child: Scaffold(
              resizeToAvoidBottomInset: false,
              appBar: CustomAppBar(
                titleTxt: "Home Page",
              ),
              body: Center(
                child: Container(
                  margin: EdgeInsets.fromLTRB(
                      10,
                      MediaQuery.of(context).size.width * .5,
                      10,
                      MediaQuery.of(context).size.width * .5),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      showCircularProgress(),
                    ],
                  ),
                ),
              ),

              //drawer: CustomDrawer(),
              bottomNavigationBar: CustomBottomBar(barIndex: 0)),
          onWillPop: () async {
            return true;
          },
        ),
      );
    }
  }

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

  Widget _buildItem(UserToken token) {
    // String address = Utils.getFormattedAddress(booking.address);

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
                            token.getDisplayName(),
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
                            token.parent.entityName +
                                (token.parent.address != null
                                    ? (', ' + token.parent.address)
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
                                      if (token.parent.phone != null) {
                                        try {
                                          callPhone(token.parent.phone);
                                        } catch (error) {
                                          Utils.showMyFlushbar(
                                              context,
                                              Icons.error,
                                              Duration(seconds: 5),
                                              "Could not connect call to the number ${token.parent.phone} !!",
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
                                    if (token.parent.dateTime
                                        .isBefore(DateTime.now()))
                                      Utils.showMyFlushbar(
                                          context,
                                          Icons.info,
                                          Duration(seconds: 5),
                                          "This booking token has already expired!!",
                                          "");
                                    //booking number is -1 means its already been cancelled, Do Nothing
                                    if (token.number == -1)
                                      return null;
                                    else
                                      showCancelBooking(token);
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
                                            token.parent.entityName,
                                            token.parent.address,
                                            token.parent.lat,
                                            token.parent.lon);
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
                                    String phoneNo =
                                        token.parent.entityWhatsApp;
                                    if (phoneNo != null && phoneNo != "") {
                                      try {
                                        launchWhatsApp(
                                            message: whatsappMessageToPlaceOwner +
                                                token.getDisplayName() +
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
                                  onPressed: () => showShoppingList(token),
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
                      dtFormat.format(token.parent.dateTime),
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
                          Utils.formatTime(
                                  token.parent.dateTime.hour.toString()) +
                              ':' +
                              Utils.formatTime(
                                  token.parent.dateTime.minute.toString()),
                          style: tokenDateTextStyle,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ]),
            if (token.number == -1)
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
}
