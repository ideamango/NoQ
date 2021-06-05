import 'package:LESSs/enum/application_status.dart';
import 'package:LESSs/pages/show_application_details.dart';
import 'package:LESSs/widget/page_animation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../constants.dart';
import '../db/db_model/booking_application.dart';
import '../db/db_model/meta_entity.dart';
import '../db/db_model/user_token.dart';
import '../global_state.dart';
import '../pages/manage_child_entity_list_page.dart';
import '../pages/manage_entity_list_page.dart';
import '../pages/manage_entity_details_page.dart';
import '../pages/user_account_page.dart';
import '../services/circular_progress.dart';
import '../style.dart';
import '../userHomePage.dart';
import '../utils.dart';
import '../widget/appbar.dart';
import '../widget/bottom_nav_bar.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:flutter/services.dart';
import 'dart:async';
import 'dart:typed_data';
import 'dart:ui';
import 'dart:io';
import 'package:flutter/rendering.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share/share.dart';

class ShowQrBookingToken extends StatefulWidget {
  final UserTokens userTokens;
  final bool isAdmin;
  ShowQrBookingToken(
      {Key key, @required this.userTokens, @required this.isAdmin})
      : super(key: key);
  @override
  State<StatefulWidget> createState() => ShowQrBookingTokenState();
}

class ShowQrBookingTokenState extends State<ShowQrBookingToken>
    with SingleTickerProviderStateMixin {
  bool initCompleted = false;
  GlobalState _gs;
  TextEditingController notesController = new TextEditingController();
  MetaEntity metaEntity;
  UserTokens token;
  String entityName;
  String dateTime;
  String time;
  List<UserToken> listOfTokens = new List<UserToken>();
  AnimationController _animationController;
  Animation animation;
  @override
  void initState() {
    _animationController = new AnimationController(
        vsync: this, duration: Duration(milliseconds: 1000));
    _animationController.repeat(reverse: true);
    animation = Tween(begin: 0.0, end: 1.0).animate(_animationController);
    super.initState();
    entityName = widget.userTokens.entityName;
    token = widget.userTokens;
    dateTime = DateFormat(dateDisplayFormat).format(token.dateTime);

    time = token.dateTime.hour.toString() +
        ': ' +
        token.dateTime.minute.toString();

    getGlobalState().whenComplete(() {
      fetchTokens();
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
                  child: Text("No Approved Requests!"),
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

  @override
  void dispose() {
    _animationController.dispose();

    super.dispose();
  }

  void fetchTokens() {
    if (token.tokens.length != 0) {
      for (int i = 0; i < token.tokens.length; i++) {
        listOfTokens.add(token.tokens[i]);
      }
    }
    setState(() {});
  }

  Widget nameValueText(String name, String value) {
    return Container(
      padding: EdgeInsets.fromLTRB(0, 3, 0, 3),
      child: Row(
        children: [
          Container(
            width: MediaQuery.of(context).size.width * .2,
            child: Text(
              name,
              style: TextStyle(
                  color: Colors.black,
                  fontSize: 16,
                  fontFamily: 'RalewayRegular'),
            ),
          ),
          Container(
            width: MediaQuery.of(context).size.width * .61,
            child: Text(
              value,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                  color: Colors.blueGrey[800], fontSize: 18, letterSpacing: 1
                  //  fontWeight: FontWeight.bold
                  ),
            ),
          )
        ],
      ),
    );
  }

  Widget buildTokenCard(UserToken bookingToken) {
    //BookingApplication application;

    DateTime currentTime = DateTime.now();
    String statusText;
    Color textColor;
    //  DateTime slotTime = new DateTime(slot.dateTime.year,slot.dateTime.month, slot.dateTime.day, );

    if (currentTime.isAfter(token.dateTime) &&
        currentTime.isBefore(
            token.dateTime.add(Duration(minutes: token.slotDuration)))) {
      statusText = "Current";
      textColor = Colors.green;
    }
    if (currentTime.isAfter(token.dateTime) &&
        currentTime.isAfter(
            token.dateTime.add(Duration(minutes: token.slotDuration)))) {
      statusText = "Expired";
      textColor = Colors.red;
    }
    if (currentTime.isBefore(token.dateTime) &&
        currentTime.isBefore(
            token.dateTime.add(Duration(minutes: token.slotDuration)))) {
      statusText = "Upcoming";
      textColor = Colors.blue;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        nameValueText('User', bookingToken.parent.userId),
        nameValueText('Place', Utils.stringToPascalCase(entityName)),
        nameValueText('Date', dateTime),
        Row(
          children: [
            Container(
              //  padding: EdgeInsets.all(5),
              child: Row(
                children: [
                  Container(
                    width: MediaQuery.of(context).size.width * .2,
                    child: Text(
                      'Time',
                      style: TextStyle(
                          color: Colors.black,
                          fontSize: 16,
                          fontFamily: 'RalewayRegular'),
                    ),
                  ),
                  Container(
                    width: MediaQuery.of(context).size.width * .2,
                    child: Text(
                      time,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                          color: Colors.blueGrey[800],
                          fontSize: 18,
                          fontWeight: FontWeight.bold),
                    ),
                  )
                ],
              ),
            ),
            FadeTransition(
              opacity: animation,
              child: Text(
                statusText,
                style: TextStyle(
                    fontSize: 18,
                    fontFamily: 'RalewayRegular',
                    color: textColor,
                    fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
        //TODO Phase2 Uncomment it
        // Utils.isNotNullOrEmpty(token.applicationId)
        //     ? FlatButton(
        //         color: Colors.transparent,
        //         textColor: btnColor,
        //         shape: RoundedRectangleBorder(
        //             side: BorderSide(color: btnColor),
        //             borderRadius: BorderRadius.all(Radius.circular(3.0))),
        //         onPressed: () {
        //           //TODO view Applications
        //           _gs
        //               .getApplicationService()
        //               .getApplication(token.applicationId)
        //               .then((applicationVal) {
        //             application = applicationVal;
        //           });
        //           setState(() {});
        //         },
        //         child: Text(
        //           'View Application Details',
        //         ))
        //     : Container(
        //         height: 0,
        //         width: 0,
        //       ),
        // (application != null)
        //     ? Container(
        //         child: Text("Got application"),
        //       )
        //     : Container(
        //         height: 0,
        //         width: 0,
        //       ),
        //TODO Phase2 Uncomment it
        nameValueText('Token', bookingToken.getDisplayName()),
        if (Utils.isNotNullOrEmpty(bookingToken.applicationId))
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              GestureDetector(
                onTap: () {
                  print('tapped');
                  _gs
                      .getApplicationService()
                      .getApplication(bookingToken.applicationId)
                      .then((bookingApplication) {
                    if (bookingApplication != null) {
                      _gs
                          .getEntityService()
                          .getEntity(bookingToken.parent.entityId)
                          .then((entity) {
                        Navigator.of(context)
                            .push(PageAnimation.createRoute(
                                ShowApplicationDetails(
                          bookingApplication: bookingApplication,
                          showReject: false,
                          metaEntity: entity.getMetaEntity(),
                          newBookingDate: null,
                          isReadOnly: false,
                          isAvailable: true,
                          tokenCounter: null,
                          backRoute: null,
                          forInfo: false,
                        )))
                            .then((updatedBa) {
                          if (updatedBa.status == ApplicationStatus.ONHOLD ||
                              updatedBa.status == ApplicationStatus.REJECTED) {
                            bookingToken.number = -1;
                          }
                          setState(() {
                            print(
                                'Updated returned TokenCounter and BA from details page');
                          });
                        });
                      });
                    } else {}
                  });
                },
                child: Container(
                  child: Text(
                    '..view application details',
                    style: TextStyle(
                        fontSize: 16,
                        fontFamily: 'RalewayRegular',
                        color: Colors.blue,
                        fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          )
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    if (initCompleted) {
      // notesController.text = widget.bookingApplication.notes;
      return MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData.light().copyWith(),
        home: WillPopScope(
          child: Scaffold(
            appBar: CustomAppBarWithBackButton(
              titleTxt: "Booking Token Details",
              backRoute: UserHomePage(),
            ),
            body: Center(
              child: Card(
                margin: EdgeInsets.all(2),
                elevation: 30,
                child: Container(
                  decoration: BoxDecoration(
                      border: Border.all(color: borderColor, width: 2),
                      color: Colors.white,
                      shape: BoxShape.rectangle,
                      borderRadius: BorderRadius.all(Radius.circular(5.0))),
                  // margin: EdgeInsets.all(12),
                  padding: EdgeInsets.all(8),
                  //  color: Colors.cyan[100],
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      (listOfTokens.length != 0)
                          ? ListView.builder(
                              padding: EdgeInsets.all(
                                  MediaQuery.of(context).size.width * .026),
                              scrollDirection: Axis.vertical,
                              physics: ClampingScrollPhysics(),
                              reverse: true,
                              shrinkWrap: true,
                              itemBuilder: (BuildContext context, int index) {
                                return Container(
                                    margin: EdgeInsets.all(0),
                                    child: Column(
                                      children: [
                                        buildTokenCard(listOfTokens[index]),
                                      ],
                                    ));
                              },
                              itemCount: listOfTokens.length,
                            )
                          : Container(height: 0),
                    ],
                  ),
                ),
              ),
            ),
          ),
          onWillPop: () async {
            return true;
          },
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
              titleTxt: "Applicant Details",
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
