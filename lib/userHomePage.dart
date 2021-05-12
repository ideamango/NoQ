import 'dart:async';

import 'package:LESSs/pages/upi_payment_page.dart';
import 'package:LESSs/pages/help_page.dart';
import 'package:LESSs/services/qr_code_user_application.dart';
import 'package:LESSs/widget/countdown_timer.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:package_info/package_info.dart';
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
  final bool dontShowUpdate;
  UserHomePage({
    Key key,
    this.dontShowUpdate,
  }) : super(key: key);
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
  String forceUpdateMsg;
  String versionUpdateMsg;
  List<String> versionFactors;
  String upiId;
  String upiQrImgPath;
  String msg;
  bool isDonationEnabled = false;
  bool isForceUpdateRequired = false;

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
  void initState() {
    super.initState();
    getGlobalState().whenComplete(() {
      _loadBookings();
//Start Code for UPI pay -donation
      upiId = _state.getConfigurations().upi;
      upiQrImgPath = "assets/bigpiq_gpay.jpg";
      upiId = upiId;
//End Code for UPI pay -donation
//Start Code for version update dialog
      if (widget.dontShowUpdate != null) {
        if (_state.isEligibleForUpdate()) {
          if (_state.getConfigurations().isForceUpdateRequired()) {
            isForceUpdateRequired = true;
            forceUpdateMsg = _state.getConfigurations().getForceUpdateMessage();
          } else {
            versionUpdateMsg =
                _state.getConfigurations().getVersionUpdateMessage();
          }
          versionFactors = _state.getConfigurations().getVersionUpdateFactors();
          msg = (_state.getConfigurations().isForceUpdateRequired())
              ? forceUpdateMsg
              : (versionUpdateMsg);
        }
      }
//End Code for version update dialog
//Start for dnation enabled
//
//_state.getConfigurations().isDonationEnabled()
//
      isDonationEnabled = _state.getConfigurations().isDonationEnabled();
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

  openPlayStore() async {
    PackageInfo info = await PackageInfo.fromPlatform();
    String packageName = info.packageName;
    launchPlayStore(packageName: packageName);
  }

  @override
  Widget build(BuildContext context) {
    if (_initCompleted) {
      String title = "Home Page";

      if (widget.dontShowUpdate != null && Utils.isNotNullOrEmpty(msg)) {
        return Scaffold(
            // backgroundColor: Colors.cyan[200],
            body: Card(
          elevation: 20,
          child: Container(
            //  color: ,

            alignment: Alignment.center,
            margin: EdgeInsets.all(30),
            //  padding: EdgeInsets.all(30),
            height: MediaQuery.of(context).size.height * .9,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  height: MediaQuery.of(context).size.height * .6,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text(
                        //"There is an important update and includes very critical features. App may not function properly if not updated now.",
                        msg,
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      verticalSpacer,
                      if (versionFactors != null)
                        ListView.builder(
                          padding: EdgeInsets.all(
                              MediaQuery.of(context).size.width * .026),
                          scrollDirection: Axis.vertical,
                          physics: ClampingScrollPhysics(),
                          reverse: true,
                          shrinkWrap: true,
                          //itemExtent: itemSize,
                          itemBuilder: (BuildContext context, int index) {
                            return Container(
                              margin: EdgeInsets.only(bottom: 5),
                              child: Text(
                                "*  " + versionFactors[index],
                                style: TextStyle(height: 1.5, fontSize: 14),
                              ),
                            );
                          },
                          itemCount: versionFactors.length,
                        ),
                    ],
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (!isForceUpdateRequired)
                      Container(
                        padding: EdgeInsets.fromLTRB(0, 10, 5, 0),
                        child: MaterialButton(
                            elevation: 0,
                            color: Colors.white,
                            shape: RoundedRectangleBorder(
                                side: BorderSide(color: Colors.green[600]),
                                borderRadius:
                                    BorderRadius.all(Radius.circular(5.0))),
                            onPressed: () {
//Goto play store and update app.
                              Navigator.of(context).push(
                                  PageAnimation.createRoute(
                                      UserHomePage(dontShowUpdate: null)));
                            },
                            child: Container(
                              width: MediaQuery.of(context).size.width * .3,
                              height: MediaQuery.of(context).size.width * .1,

                              //  margin: EdgeInsets.fromLTRB(20, 40, 20, 40),
                              padding: EdgeInsets.zero,
                              alignment: Alignment.center,
                              child: Text(
                                "Update Later",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    color: Colors.green[600], fontSize: 14),
                              ),
                            )),
                      ),
                    Container(
                      padding: EdgeInsets.fromLTRB(5, 10, 0, 0),
                      child: MaterialButton(
                          elevation: 20,
                          color: Colors.green[600],
                          shape: RoundedRectangleBorder(
                              side: BorderSide(color: Colors.green[600]),
                              borderRadius:
                                  BorderRadius.all(Radius.circular(5.0))),
                          onPressed: () {
//Goto play store and update app.
                            openPlayStore();
                          },
                          child: Container(
                            width: MediaQuery.of(context).size.width * .3,
                            height: MediaQuery.of(context).size.width * .1,
                            //  margin: EdgeInsets.fromLTRB(20, 40, 20, 40),
                            padding: EdgeInsets.zero,
                            alignment: Alignment.center,
                            child: Text(
                              "Update Now",
                              textAlign: TextAlign.center,
                              style:
                                  TextStyle(color: Colors.white, fontSize: 14),
                            ),
                          )),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ));
      } else {
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
                    padding: EdgeInsets.all(
                        MediaQuery.of(context).size.width * .036),
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
                                            width: MediaQuery.of(context)
                                                .size
                                                .width,
                                            child: Card(
                                              color: primaryAccentColor,
                                              child: card,
                                            ),
                                          );
                                        });
                                      }).toList(),
                                    ),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: <Widget>[
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: map<Widget>(cardList,
                                              (index, url) {
                                            return Container(
                                              width: 7.0,
                                              height: 7.0,
                                              margin: EdgeInsets.symmetric(
                                                  vertical: 2.0,
                                                  horizontal: 2.0),
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
                                    Text(homeScreenMsgTxt2,
                                        style: homeMsgStyle2),
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
                        // Card(
                        //     child: Container(
                        //   decoration: BoxDecoration(
                        //       border: Border.all(color: borderColor),
                        //       color: Colors.white,
                        //       shape: BoxShape.rectangle,
                        //       borderRadius:
                        //           BorderRadius.all(Radius.circular(5.0))),
                        //   child: ListView(
                        //     children: [Text("Donation Text")],
                        //   ),
                        // )),
                        // verticalSpacer,
                        if (isDonationEnabled)
                          Container(
                            width: MediaQuery.of(context).size.width,
                            margin: EdgeInsets.fromLTRB(0, 10, 0, 10),
                            padding: EdgeInsets.zero,
                            child: Card(
                              margin: EdgeInsets.zero,
                              elevation: 20,
                              child: GestureDetector(
                                onTap: () {
                                  Navigator.of(context).push(
                                      PageAnimation.createRoute(UPIPaymentPage(
                                          upiId: upiId,
                                          upiQrCodeImgPath: upiQrImgPath,
                                          backRoute: UserHomePage(),
                                          isDonation: true)));
                                },
                                child: Image(
                                  fit: BoxFit.fitWidth,
                                  image: AssetImage('assets/donate.png'),
                                ),
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
//

                        verticalSpacer,

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

//Test Dummy code
//TODO Dummy code for testing
                        // GlobalState.getGlobalState().then((value) {
                        //   value
                        //       .getTokenService()
                        //       .getUserToken(
                        //           "5f0817c0-a263-11eb-98fd-5551d2a7a020#2021~4~24#20~53#+919876543210")
                        //       .then((tokenValue) {
                        //     UserTokens userTokenId = tokenValue;

                        //     Navigator.pushReplacement(
                        //         context,
                        //         MaterialPageRoute(
                        //             builder: (context) => ShowQrBookingToken(
                        //                   userTokens: userTokenId,
                        //                   isAdmin: true,
                        //                 )));
                        //   });
                        // });
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
      }
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

  void showShoppingList(UserToken booking) {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => ShoppingList(
                  token: booking,
                  isAdmin: false,
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
    double ticketwidth = MediaQuery.of(context).size.width * .95;
    double ticketHeight = MediaQuery.of(context).size.width * .8 / 2.7;
    return Container(
        width: ticketwidth,
        height: ticketHeight,
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
                height: MediaQuery.of(context).size.width * .8 / 3.5,
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
                                width: MediaQuery.of(context).size.width * .07,
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
                                width: MediaQuery.of(context).size.width * .07,
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
                                width: MediaQuery.of(context).size.width * .07,
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
                                width: MediaQuery.of(context).size.width * .07,
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
                                width: MediaQuery.of(context).size.width * .07,
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
                              Container(
                                width: MediaQuery.of(context).size.width * .07,
                                height: MediaQuery.of(context).size.width * .07,
                                // width: 20.0,
                                //
                                child: IconButton(
                                  padding: EdgeInsets.all(0),
                                  alignment: Alignment.center,
                                  highlightColor: Colors.orange[300],
                                  icon: Icon(
                                    Icons.attach_money_outlined,
                                    color: (Utils.isNotNullOrEmpty(
                                            token.parent.upiId)
                                        ? lightIcon
                                        : Colors.blueGrey[400]),
                                    size: 22,
                                  ),
                                  onPressed: () {
                                    if (Utils.isNotNullOrEmpty(
                                        token.parent.upiId)) {
                                      Navigator.of(context).push(
                                          PageAnimation.createRoute(
                                              UPIPaymentPage(
                                                  upiId: token.parent.upiId,
                                                  upiQrCodeImgPath: null,
                                                  backRoute: UserHomePage(),
                                                  isDonation: false)));
                                    } else {
                                      Utils.showMyFlushbar(
                                          context,
                                          Icons.info_outline,
                                          Duration(
                                            seconds: 5,
                                          ),
                                          "Couldn't find UPI payment information for this place.",
                                          "");
                                    }
                                  },
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
                width: MediaQuery.of(context).size.width * .2,
                // padding: EdgeInsets.fromLTRB(5, 5, 0, 0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Container(
                      padding: EdgeInsets.fromLTRB(0, 0, 0, 0),
                      margin: EdgeInsets.all(0),
                      height: ticketwidth * .1,
                      width: ticketwidth * .1,
                      child: IconButton(
                          padding: EdgeInsets.fromLTRB(0, 0, 0, 0),
                          alignment: Alignment.center,
                          highlightColor: Colors.orange[300],
                          mouseCursor: SystemMouseCursors.click,
                          icon: ImageIcon(
                            AssetImage('assets/qrcode.png'),
                            size: 30,
                            color: Colors.white,
                          ),
                          onPressed: () {
                            print(token.applicationId);

                            print('Unique identifier for TOKEN -  ' +
                                token.parent.slotId +
                                '%3A' +
                                token.parent.userId);

                            String id =
                                token.parent.slotId.replaceAll('#', ':') +
                                    ':' +
                                    token.parent.userId;

                            Navigator.of(context).push(
                                PageAnimation.createRoute(
                                    GenerateQrUserApplication(
                              entityName: "Application QR code",
                              backRoute: "UserAppsList",
                              uniqueTokenIdentifier: id,
                            )));
                          }),
                    ),
                    Container(
                      height: 5,
                    ),
                    AutoSizeText(
                      dtFormat.format(token.parent.dateTime),
                      minFontSize: 10,
                      maxFontSize: 12,
                      maxLines: 1,
                      style: TextStyle(
                          fontFamily: 'RalewayRegular',
                          color: primaryAccentColor),
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

                      cancelToken(booking).then((value) {
                        Navigator.of(context, rootNavigator: true).pop();
                        Utils.showMyFlushbar(
                            context,
                            Icons.cancel,
                            Duration(
                              seconds: 3,
                            ),
                            "Cancelling Token ${booking.getDisplayName()}",
                            "Please wait..");

                        if (!value) {
                          Utils.showMyFlushbar(
                              context,
                              Icons.info_outline,
                              Duration(
                                seconds: 5,
                              ),
                              "Couldn't cancel your booking for some reason. ",
                              "Please try again later.");
                        } else {
                          setState(() {
                            booking.number = -1;
                          });
                        }
                      }).catchError((e) {
                        print(e);
                      });
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
