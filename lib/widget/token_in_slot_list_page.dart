import 'dart:ffi';

import 'package:LESSs/db/exceptions/no_token_found_exception.dart';
import 'package:LESSs/db/exceptions/token_already_cancelled_exception.dart';
import 'package:LESSs/enum/application_status.dart';
import 'package:LESSs/pages/shopping_list.dart';
import 'package:LESSs/pages/show_application_details.dart';
import 'package:LESSs/repository/slotRepository.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:intl/intl.dart';
import '../pages/shopping_list.dart';
import '../constants.dart';
import '../db/db_model/meta_entity.dart';
import '../db/db_model/user_token.dart';
import '../global_state.dart';
import '../pages/entity_token_list_page.dart';
import '../services/circular_progress.dart';
import '../services/qr_code_user_application.dart';
import '../services/url_services.dart';
import '../style.dart';
import '../utils.dart';
import '../widget/appbar.dart';
import '../widget/page_animation.dart';
import 'widgets.dart';

class TokensInSlot extends StatefulWidget {
  final String slotKey;
  final TokenStats stats;
  final DateTime date;
  final DateDisplayFormat format;
  final MetaEntity metaEntity;
  final bool isReadOnly;
  final dynamic backRoute;
  TokensInSlot(
      {Key key,
      @required this.slotKey,
      @required this.stats,
      @required this.date,
      @required this.format,
      @required this.metaEntity,
      @required this.isReadOnly,
      @required this.backRoute})
      : super(key: key);
  @override
  _TokensInSlotState createState() => _TokensInSlotState();
}

class _TokensInSlotState extends State<TokensInSlot>
    with TickerProviderStateMixin {
  GlobalState _gs;
  bool initCompleted = false;
  List<UserToken> listOfTokens = new List<UserToken>();
  String timeSlot;
  String slotId;
  String dateTime;
  final dtFormat = new DateFormat(dateDisplayFormat);
  AnimationController _animationController;
  Animation animation;
  @override
  void initState() {
    super.initState();

    _animationController = new AnimationController(
        vsync: this, duration: Duration(milliseconds: 1500));
    _animationController.repeat(reverse: true);
    animation = Tween(begin: 0.5, end: 1.0).animate(_animationController);
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

  void handleErrorsForTokenCancellation(dynamic error) {
    switch (error.runtimeType) {
      case TokenAlreadyCancelledException:
        Utils.showMyFlushbar(
            context,
            Icons.error,
            Duration(seconds: 6),
            "Could not Cancel the Token.",
            "Token number is Already Cancelled.",
            Colors.red);
        break;
      case NoTokenFoundException:
        Utils.showMyFlushbar(
            context,
            Icons.error,
            Duration(seconds: 6),
            "Could not Cancel the Token.",
            "The Token number is either Incorrect or Cancelled",
            Colors.red);
        break;

      default:
        Utils.showMyFlushbar(context, Icons.error, Duration(seconds: 5),
            "Could not Cancel the Token.", error.toString(), Colors.red);
        break;
    }
  }

  void showCancelBooking(UserToken booking, int index) {
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
                    Utils.isNotNullOrEmpty(booking.applicationId)
                        ? 'There is an Application Request for this Token, You will have to cancel the Application first. Proceed with cancelling the Application?'
                        : 'Are you sure you want to cancel this Token?',
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
                  height: 26,
                  child: MaterialButton(
                    elevation: 0,
                    color: Colors.transparent,
                    splashColor: highlightColor,
                    textColor: btnColor,
                    shape: RoundedRectangleBorder(
                        side: BorderSide(color: btnColor)),
                    child: Text('Yes'),
                    onPressed: () {
//Fetch application associated with the token
                      if (Utils.isNotNullOrEmpty(booking.applicationId)) {
                        _gs
                            .getApplicationService()
                            .getApplication(booking.applicationId)
                            .then((bookingApplication) {
                          if (bookingApplication != null) {
                            Navigator.of(_).pop();
                            Navigator.of(context)
                                .push(new MaterialPageRoute(
                                    builder: (BuildContext context) =>
                                        ShowApplicationDetails(
                                          bookingApplication:
                                              bookingApplication,
                                          showReject: true,
                                          metaEntity: widget.metaEntity,
                                          newBookingDate: null,
                                          isReadOnly: widget.isReadOnly,
                                          isAvailable: null,
                                          tokenCounter: null,
                                          backRoute: TokensInSlot(
                                            slotKey: widget.slotKey,
                                            stats: widget.stats,
                                            date: widget.date,
                                            format: widget.format,
                                            metaEntity: widget.metaEntity,
                                            backRoute: widget.backRoute,
                                            isReadOnly: widget.isReadOnly,
                                          ),
                                        )))
                                .then((value) {
                              print(
                                  "Rejecting the application, Now refresh this page.");
                              if (value != null) {
                                bookingApplication.status =
                                    ApplicationStatus.REJECTED;
                                bookingApplication.tokenId =
                                    value.item1.tokenId;
                                bookingApplication.rejectedBy =
                                    value.item1.rejectedBy;
                                bookingApplication.notesOnRejection =
                                    value.item1.notesOnRejection;
                                bookingApplication.timeOfRejection =
                                    value.item1.timeOfRejection;
                                for (int i = 0; i < listOfTokens.length; i++) {
                                  if (listOfTokens[i].applicationId ==
                                      value.item1.id) {
                                    listOfTokens[i].numberBeforeCancellation =
                                        listOfTokens[i].number;
                                    listOfTokens[i].number = -1;
                                  }
                                }
                                // booking.number = -1;
                                setState(() {});
                              }
                            });
                          } else {
                            Utils.showMyFlushbar(
                                context,
                                Icons.info,
                                Duration(
                                  seconds: 5,
                                ),
                                "Token & Application could not be Cancelled.",
                                "Please try again later.");
                          }
                        }).catchError((error) {
                          handleErrorsForTokenCancellation(error);
                        });
                      } else {
                        print("Cancel booking");

                        Navigator.of(context, rootNavigator: true).pop();
                        Utils.showMyFlushbar(
                            context,
                            Icons.cancel,
                            Duration(
                              seconds: 3,
                            ),
                            "Cancelling Token ${booking.getDisplayName()}",
                            "Please wait..");

                        _gs
                            .getTokenService()
                            .cancelToken(
                                booking.parent.getTokenId(), booking.number)
                            .then((value) {
                          if (value == null) {
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
                              //TODO Smita - return value UserToken should be assigned.
                              listOfTokens[index] = value.item1;
                            });
                          }
                        }).catchError((e) {
                          print(e);
                        });
                      }
                    },
                  ),
                ),
                SizedBox(
                  height: 26,
                  child: MaterialButton(
                    elevation: 20,
                    autofocus: true,
                    focusColor: highlightColor,
                    splashColor: highlightColor,
                    color: btnColor,
                    textColor: btnColor,
                    shape: RoundedRectangleBorder(
                        side: BorderSide(color: btnColor)),
                    child: Text('No', style: TextStyle(color: Colors.white)),
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

  Widget _buildItem(UserToken booking, int index) {
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
                            booking.parent.userId,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                                fontFamily: 'Roboto',
                                fontSize: 12,
                                letterSpacing: 1.2,
                                color: primaryAccentColor),
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
                                            "Could not connect to the WhatsApp number $phoneNo !!",
                                            "Try again later");
                                      }
                                    } else {
                                      Utils.showMyFlushbar(
                                          context,
                                          Icons.info,
                                          Duration(seconds: 5),
                                          "WhatsApp contact information not found!!",
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
                                    if (!widget.isReadOnly) {
                                      //If booking is past booking then no sense of cancelling , show msg to user
                                      // if (booking.parent.dateTime
                                      //     .isBefore(DateTime.now())) {
                                      //   Utils.showMyFlushbar(
                                      //       context,
                                      //       Icons.info,
                                      //       Duration(seconds: 5),
                                      //       "The Booking token has already expired!",
                                      //       "");
                                      // }
                                      //booking number is -1 means its already been cancelled, Do Nothing

                                      if (booking.number == -1) {
                                        Utils.showMyFlushbar(
                                            context,
                                            Icons.info,
                                            Duration(seconds: 5),
                                            "The Booking Token is already Cancelled!",
                                            "");
                                        return;
                                      } else {
                                        showCancelBooking(booking, index);
                                      }
                                    } else {
                                      Utils.showMyFlushbar(
                                          context,
                                          Icons.info,
                                          Duration(seconds: 3),
                                          "$noEditPermission the Booking Tokens.",
                                          "Please contact Admin of this place.");
                                      return;
                                    }
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
                        if (Utils.isNotNullOrEmpty(booking.applicationId))
                          GestureDetector(
                            onTap: () {
                              _gs
                                  .getApplicationService()
                                  .getApplication(booking.applicationId)
                                  .then((bookingApplication) {
                                if (bookingApplication != null) {
                                  Navigator.of(context)
                                      .push(new MaterialPageRoute(
                                          builder: (BuildContext context) =>
                                              ShowApplicationDetails(
                                                bookingApplication:
                                                    bookingApplication,
                                                showReject: false,
                                                metaEntity: widget.metaEntity,
                                                newBookingDate: null,
                                                isReadOnly: widget.isReadOnly,
                                                isAvailable: null,
                                                tokenCounter: null,
                                                backRoute: null,
                                              )))
                                      .then((value) {
                                    if (value != null) {
                                      bookingApplication.status =
                                          ApplicationStatus.REJECTED;
                                      bookingApplication.tokenId =
                                          value.item1.tokenId;
                                      bookingApplication.rejectedBy =
                                          value.item1.rejectedBy;
                                      bookingApplication.notesOnRejection =
                                          value.item1.notesOnRejection;
                                      bookingApplication.timeOfRejection =
                                          value.item1.timeOfRejection;
                                      for (int i = 0;
                                          i < listOfTokens.length;
                                          i++) {
                                        if (listOfTokens[i].applicationId ==
                                            value.item1.id) {
                                          listOfTokens[i]
                                                  .numberBeforeCancellation =
                                              listOfTokens[i].number;
                                          listOfTokens[i].number = -1;
                                        }
                                      }
                                      // booking.number = -1;
                                      setState(() {});
                                    }
                                  });
                                } else {
                                  Utils.showMyFlushbar(
                                      context,
                                      Icons.info,
                                      Duration(
                                        seconds: 5,
                                      ),
                                      "Could not fetch Application details at the moment.",
                                      "Please try again later.");
                                }
                              });
                            },
                            child: Container(
                              margin: EdgeInsets.only(top: 4),
                              width: MediaQuery.of(context).size.width * .68,
                              alignment: Alignment.centerRight,
                              child: Text("..view details",
                                  style: TextStyle(
                                      color: highlightColor, fontSize: 12)),
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
                    // if (booking.applicationId != null)
                    //   Container(
                    //     padding: EdgeInsets.zero,
                    //     margin: EdgeInsets.zero,
                    //     height: ticketwidth * .1,
                    //     width: ticketwidth * .1,
                    //     child: IconButton(
                    //         padding: EdgeInsets.fromLTRB(0, 0, 0, 0),
                    //         alignment: Alignment.center,
                    //         highlightColor: Colors.orange[300],
                    //         mouseCursor: SystemMouseCursors.click,
                    //         icon: ImageIcon(
                    //           AssetImage('assets/qrcode.png'),
                    //           size: 30,
                    //           color: Colors.white,
                    //         ),
                    //         onPressed: () {
                    //           print(booking.applicationId);
                    //           if (Utils.isNotNullOrEmpty(
                    //               booking.applicationId)) {
                    //             Navigator.of(context).push(
                    //                 PageAnimation.createRoute(
                    //                     GenerateQrUserApplication(
                    //               entityName: "QR Code Result Page",
                    //               backRoute: "UserAppsList",
                    //               uniqueTokenIdentifier: booking.applicationId,
                    //             )));
                    //           } else {
                    //             return;
                    //           }
                    //           //else {
                    //           //   //if application id is null then show token details page.
                    //           //   Navigator.of(context).push(
                    //           //       PageAnimation.createRoute(
                    //           //           GenerateQrBookingToken(
                    //           //     entityName: "Application QR code",
                    //           //     backRoute: "UserAppsList",
                    //           //     applicationId: booking.applicationId,
                    //           //   )));
                    //           // }
                    //         }),
                    //   ),
                    if (booking.parent.isOnlineAppointment)
                      FadeTransition(
                        opacity: animation,
                        child: GestureDetector(
                          onTap: () {
                            if (booking.parent.dateTime != null) {
                              Duration timeDiff = DateTime.now()
                                  .difference(booking.parent.dateTime);
                              if (timeDiff.inMinutes <= -1) {
                                print("Diff more");
                                Utils.showMyFlushbar(
                                    context,
                                    Icons.info,
                                    Duration(seconds: 5),
                                    yourTurnUserMessage1,
                                    yourTurnUserMessage2);
                              } else if (booking.parent.dateTime
                                  .isBefore(DateTime.now())) {
                                Utils.showMyFlushbar(
                                    context,
                                    Icons.error,
                                    Duration(seconds: 6),
                                    "Could not start WhatsApp call as this Booking has already expired.",
                                    "Please contact Owner/Manager of this Place");
                              } else {
                                String phoneNo = booking.parent.userId;
                                if (phoneNo != null && phoneNo != "") {
                                  try {
                                    launchWhatsApp(
                                        message: whatsappVideoToUser_1 +
                                            booking.getDisplayName() +
                                            whatsappVideoToUser_2,
                                        phone: phoneNo);
                                  } catch (error) {
                                    Utils.showMyFlushbar(
                                        context,
                                        Icons.error,
                                        Duration(seconds: 5),
                                        "Could not connect to the WhatsApp number $phoneNo !!",
                                        "Try again later");
                                  }
                                } else {
                                  Utils.showMyFlushbar(
                                      context,
                                      Icons.info,
                                      Duration(seconds: 5),
                                      "WhatsApp contact information not found!!",
                                      "");
                                }
                              }
                            } else {
                              Utils.showMyFlushbar(
                                  context,
                                  Icons.info,
                                  Duration(seconds: 5),
                                  yourTurnUserMessageWhenTokenIsNotAlloted,
                                  '');
                            }
                          },
                          child: Container(
                            padding: EdgeInsets.zero,
                            margin: EdgeInsets.zero,
                            width: MediaQuery.of(context).size.width * .08,
                            height: MediaQuery.of(context).size.height * .04,
                            child: Icon(
                              Icons.videocam,
                              color: Colors.orange[600],
                              size: 30,
                            ),
                          ),
                        ),
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
    return Scaffold(
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
                  height: MediaQuery.of(context).size.height * .85,
                  child: Scrollbar(
                      child: SingleChildScrollView(
                    child: Column(
                      children: [
                        (listOfTokens.length != 0)
                            ? ListView.builder(
                                shrinkWrap: true,
                                scrollDirection: Axis.vertical,
                                physics: ClampingScrollPhysics(),
                                itemBuilder: (BuildContext context, int index) {
                                  return Container(
                                    padding: EdgeInsets.all(10),
                                    child: Card(
                                        child: _buildItem(
                                            listOfTokens[index], index)),
                                    //children: <Widget>[firstRow, secondRow],
                                  );
                                },
                                itemCount: listOfTokens.length,
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
    );
  }
}
