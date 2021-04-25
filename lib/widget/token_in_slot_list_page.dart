import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:intl/intl.dart';
import 'package:noq/constants.dart';
import 'package:noq/db/db_model/meta_entity.dart';
import 'package:noq/db/db_model/user_token.dart';
import 'package:noq/global_state.dart';
import 'package:noq/pages/entity_token_list_page.dart';
import 'package:noq/pages/shopping_list.dart';
import 'package:noq/repository/slotRepository.dart';
import 'package:noq/services/circular_progress.dart';
import 'package:noq/services/qr_code_user_application.dart';
import 'package:noq/services/url_services.dart';
import 'package:noq/style.dart';
import 'package:noq/utils.dart';
import 'package:noq/widget/appbar.dart';
import 'package:noq/widget/page_animation.dart';
import 'package:noq/widget/widgets.dart';

class TokensInSlot extends StatefulWidget {
  final String slotKey;
  final TokenStats stats;
  final DateTime date;
  final DateDisplayFormat format;
  final MetaEntity metaEntity;
  final dynamic backRoute;
  TokensInSlot(
      {Key key,
      @required this.slotKey,
      @required this.stats,
      @required this.date,
      @required this.format,
      @required this.metaEntity,
      @required this.backRoute})
      : super(key: key);
  @override
  _TokensInSlotState createState() => _TokensInSlotState();
}

class _TokensInSlotState extends State<TokensInSlot> {
  GlobalState _gs;
  bool initCompleted = false;
  List<UserToken> listOfTokens = new List<UserToken>();
  String timeSlot;
  String slotId;
  String dateTime;
  final dtFormat = new DateFormat(dateDisplayFormat);
  @override
  void initState() {
    super.initState();
    timeSlot = widget.slotKey.replaceAll('~', ':');
    dateTime = widget.date.year.toString() +
        '~' +
        widget.date.month.toString() +
        '~' +
        widget.date.day.toString() +
        '#' +
        widget.slotKey.replaceAll(':', '~');
    print(dateTime);
    slotId = widget.metaEntity.entityId + "#" + dateTime;
    getGlobalState().whenComplete(() {
      _gs.getTokenService().getAllTokensForSlot(slotId).then((list) {
        listOfTokens = list;
        if (this.mounted) {
          setState(() {
            initCompleted = true;
          });
        } else
          initCompleted = true;
      });
    });
  }

  Future<void> getGlobalState() async {
    _gs = await GlobalState.getGlobalState();
  }

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

  // Future<void> getTokenList(
  //     String slot, DateTime date, DateDisplayFormat format) async {
  //   String slotId;
  //   String dateTime = date.year.toString() +
  //       '~' +
  //       date.month.toString() +
  //       '~' +
  //       date.day.toString() +
  //       '#' +
  //       slot.replaceAll(':', '~');
  //   print(dateTime);
  //   //Build slotId using info we have entityID#YYYY~MM~DD#HH~MM

  //   slotId = widget.metaEntity.entityId + "#" + dateTime;
  //   //6b8af7a0-9ce7-11eb-b97b-2beeb21da0d7#15~4~2021#11~20

  //   _gs.getTokenService().getAllTokensForSlot(slotId).then((list) {
  //     setState(() {});
  //   });
  // }

  Widget buildExpansionTile() {
    String timeSlot = widget.slotKey.replaceAll('~', ':');

    return Container(
      // height: 500,
      child: Card(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  timeSlot,
                  style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                ),
                Row(
                  children: [
                    AutoSizeText(
                      "Booked - " +
                          widget.stats.numberOfTokensCreated.toString() +
                          ", ",
                      minFontSize: 8,
                      maxFontSize: 13,
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                    AutoSizeText(
                      "Cancelled - " +
                          widget.stats.numberOfTokensCancelled.toString(),
                      minFontSize: 8,
                      maxFontSize: 13,
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                  ],
                ),
              ],
            ),

            (listOfTokens.length != 0)
                ? Expanded(
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: listOfTokens.length,
                      shrinkWrap: true,
                      itemBuilder: (context, index) {
                        return Column(
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            buildChildItem(listOfTokens[index])
                          ],
                        );
                      },
                    ),
                  )
                : Text("No Tokens"),

            //initialData: getDefaultTokenListWidget(),
          ],
        ),
      ),
    );
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
                      Navigator.of(context, rootNavigator: true).pop();
                      Utils.showMyFlushbar(
                          context,
                          Icons.cancel,
                          Duration(
                            seconds: 3,
                          ),
                          "Cancelling Token ${booking.getDisplayName()}",
                          "Please wait..");
                      cancelToken(booking).then((value) {
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

  Widget _buildItem(UserToken booking) {
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
                padding: EdgeInsets.zero,
                margin: EdgeInsets.zero,
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
                            booking.parent.entityName +
                                (booking.parent.address != null
                                    ? (', ' + booking.parent.address)
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
                                      print(booking.parent.userId);
                                      if (booking.parent.userId != null) {
                                        try {
                                          callPhone(booking.parent.userId);
                                        } catch (error) {
                                          Utils.showMyFlushbar(
                                              context,
                                              Icons.error,
                                              Duration(seconds: 5),
                                              "Could not connect call to the number ${booking.parent.userId} !!",
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
                                    print(booking.parent.userId);

                                    String phoneNo = booking.parent.userId;
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
                                    Icons.cancel,
                                    color: lightIcon,
                                    size: 22,
                                  ),
                                  onPressed: () {
                                    //If booking is past booking then no sense of cancelling , show msg to user
                                    if (booking.parent.dateTime
                                        .isBefore(DateTime.now()))
                                      Utils.showMyFlushbar(
                                          context,
                                          Icons.info,
                                          Duration(seconds: 5),
                                          "This booking token has already expired!!",
                                          "");
                                    //booking number is -1 means its already been cancelled, Do Nothing
                                    if (booking.number == -1)
                                      return null;
                                    else
                                      showCancelBooking(booking);
                                  },
                                ),
                              ),
                              // Container(
                              //   width: MediaQuery.of(context).size.width * .08,
                              //   height: MediaQuery.of(context).size.width * .07,
                              //   // width: 20.0,
                              //   child: IconButton(
                              //       padding: EdgeInsets.all(0),
                              //       alignment: Alignment.center,
                              //       highlightColor: Colors.orange[300],
                              //       icon: Icon(
                              //         Icons.location_on,
                              //         color: lightIcon,
                              //         size: 21,
                              //       ),
                              //       onPressed: () {
                              //         try {
                              //           launchURL(
                              //               booking.parent.entityName,
                              //               booking.parent.address,
                              //               booking.parent.lat,
                              //               booking.parent.lon);
                              //         } catch (error) {
                              //           Utils.showMyFlushbar(
                              //               context,
                              //               Icons.error,
                              //               Duration(seconds: 5),
                              //               "Could not open Maps!!",
                              //               "Try again later.");
                              //         }
                              //       }),
                              // ),

                              if (booking.order != null &&
                                  booking.order?.isPublic == true)
                                Container(
                                  width:
                                      MediaQuery.of(context).size.width * .08,
                                  height:
                                      MediaQuery.of(context).size.width * .07,
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
                                    onPressed: () {
                                      Navigator.of(context).push(
                                          PageNoAnimation.createRoute(
                                              ShoppingList(
                                        token: booking,
                                        isAdmin: true,
                                      )));
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
                padding: EdgeInsets.fromLTRB(3, 0, 3, 0),
                margin: EdgeInsets.zero,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    if (booking.applicationId != null)
                      Container(
                        padding: EdgeInsets.zero,
                        margin: EdgeInsets.zero,
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
                              print(booking.applicationId);
                              if (Utils.isNotNullOrEmpty(
                                  booking.applicationId)) {
                                Navigator.of(context).push(
                                    PageAnimation.createRoute(
                                        GenerateQrUserApplication(
                                  entityName: "QR Code Result Page",
                                  backRoute: "UserAppsList",
                                  uniqueTokenIdentifier: booking.applicationId,
                                )));
                              } else {
                                return;
                              }
                              //else {
                              //   //if application id is null then show token details page.
                              //   Navigator.of(context).push(
                              //       PageAnimation.createRoute(
                              //           GenerateQrBookingToken(
                              //     entityName: "Application QR code",
                              //     backRoute: "UserAppsList",
                              //     applicationId: booking.applicationId,
                              //   )));
                              // }
                            }),
                      ),
                    Container(
                      height: 5,
                    ),
                    Text(
                      dtFormat.format(booking.parent.dateTime),
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
                                  booking.parent.dateTime.hour.toString()) +
                              ':' +
                              Utils.formatTime(
                                  booking.parent.dateTime.minute.toString()),
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
                  child: Text("No Tokens Booked for selected Date(s)."),
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
  Widget build(BuildContext context) {
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData.light().copyWith(),
        home: Scaffold(
          appBar: CustomAppBarWithBackButton(
            backRoute: widget.backRoute,
            titleTxt:
                "Tokens in ${Utils.formatTimeAsStr(timeSlot)} Slot on ${dtFormat.format(widget.date)}",
          ),
          body: (initCompleted)
              ? Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      child: Scrollbar(
                          child: SingleChildScrollView(
                        child: Column(
                          children: [
                            (listOfTokens.length != 0)
                                ? ListView.builder(
                                    shrinkWrap: true,
                                    scrollDirection: Axis.vertical,
                                    physics: ClampingScrollPhysics(),
                                    itemBuilder:
                                        (BuildContext context, int index) {
                                      return Container(
                                        padding: EdgeInsets.all(10),
                                        child: Card(
                                          child: new Column(
                                              children: listOfTokens
                                                  .map(_buildItem)
                                                  .toList()),
                                          //children: <Widget>[firstRow, secondRow],
                                        ),
                                      );
                                    },
                                    itemCount: 1,
                                  )
                                : _emptyPage(),

                            // (initCompleted)
                            //     ? buildExpansionTile()
                            //     : showCircularProgress(),
                          ],
                        ),
                      )),
                    ),
                  ],
                )
              : Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      showCircularProgress(),
                    ],
                  ),
                ),
        ));
  }
}
