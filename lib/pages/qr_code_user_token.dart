import 'package:LESSs/db/exceptions/access_denied_exception.dart';
import 'package:LESSs/enum/application_status.dart';
import 'package:LESSs/enum/entity_role.dart';
import 'package:LESSs/pages/show_application_details.dart';
import 'package:LESSs/widget/page_animation.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:enum_to_string/enum_to_string.dart';
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
      {Key? key, required this.userTokens, required this.isAdmin})
      : super(key: key);
  @override
  State<StatefulWidget> createState() => ShowQrBookingTokenState();
}

class ShowQrBookingTokenState extends State<ShowQrBookingToken>
    with SingleTickerProviderStateMixin {
  bool initCompleted = false;
  GlobalState? _gs;
  TextEditingController notesController = new TextEditingController();
  MetaEntity? metaEntity;
  late UserTokens token;
  String? entityName;
  late String dateTime;
  late String time;
  List<UserToken> listOfTokens = [];
  Map<String, BookingApplication> mapOfBa =
      new Map<String, BookingApplication>();
  late AnimationController _animationController;
  late Animation animation;
  String tokenStatus = '';

  @override
  void initState() {
    _animationController = new AnimationController(
        vsync: this, duration: Duration(milliseconds: 1000));
    _animationController.repeat(reverse: true);
    animation = Tween(begin: 0.0, end: 1.0).animate(_animationController);
    super.initState();
    entityName = widget.userTokens.entityName;
    token = widget.userTokens;
    dateTime = DateFormat(dateDisplayFormat).format(token.dateTime!);

    time = token.dateTime!.hour.toString() +
        ': ' +
        token.dateTime!.minute.toString();

    getGlobalState().whenComplete(() {
      fetchTokens().then((value) {
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

  Future<void> fetchTokens() async {
    if (token.tokens!.length != 0) {
      for (int i = 0; i < token.tokens!.length; i++) {
        listOfTokens.add(token.tokens![i]);
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
    DateTime currentTime = DateTime.now();
    late String statusText;
    Color? textColor;
    //BookingApplication ba;

    // if (mapOfBa.containsKey(bookingToken.getID())) {
    //   ba = mapOfBa[bookingToken.getID()];
    // }
    if (currentTime.isAfter(token.dateTime!) &&
        currentTime.isBefore(
            token.dateTime!.add(Duration(minutes: token.slotDuration!)))) {
      statusText = "Current";
      textColor = Colors.green;
    }
    if (currentTime.isAfter(token.dateTime!) &&
        currentTime.isAfter(
            token.dateTime!.add(Duration(minutes: token.slotDuration!)))) {
      statusText = "Expired";
      textColor = Colors.red;
    }
    if (currentTime.isBefore(token.dateTime!) &&
        currentTime.isBefore(
            token.dateTime!.add(Duration(minutes: token.slotDuration!)))) {
      statusText = "Upcoming";
      textColor = Colors.blue;
    }
    if (bookingToken.number == -1) {
      statusText = "Cancelled";
      textColor = Colors.red;
    }

    return Card(
      margin: EdgeInsets.all(8),
      child: Container(
        margin: EdgeInsets.only(left: 8, bottom: 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Container(
                  padding: EdgeInsets.all(6),
                  margin: EdgeInsets.all(0),
                  alignment: Alignment.topCenter,
                  decoration: BoxDecoration(
                      color: (bookingToken.number == -1
                          ? Colors.red
                          : Colors.green),
                      shape: BoxShape.rectangle,
                      borderRadius:
                          BorderRadius.only(bottomLeft: Radius.circular(5.0))),
                  child: SizedBox(
                    child: Center(
                      child: AutoSizeText(
                          bookingToken.number == -1 ? 'Invalid' : 'Valid',
                          textAlign: TextAlign.center,
                          minFontSize: 9,
                          maxFontSize: 10,
                          style: TextStyle(
                              //fontSize: 9,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1,
                              color: Colors.white,
                              fontFamily: 'RalewayRegular')),
                    ),
                  ),
                ),
              ],
            ),
            nameValueText('User', bookingToken.parent!.userId!),
            nameValueText('Place', Utils.stringToPascalCase(entityName!)),
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
                  opacity: animation as Animation<double>,
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
            nameValueText('Token', bookingToken.getDisplayName()),
            if (Utils.isNotNullOrEmpty(bookingToken.applicationId))
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  MaterialButton(
                    visualDensity: VisualDensity.compact,
                    child: Text(
                      '. . view application details',
                      style: TextStyle(
                          fontSize: 14,
                          fontFamily: 'RalewayRegular',
                          color: Colors.blue,
                          fontWeight: FontWeight.bold),
                    ),
                    onPressed: () {
                      print('tapped');
                      bool isReadOnly = true;

                      _gs!
                          .getApplicationService()!
                          .getApplication(token.tokens![0].applicationId)
                          .then((newBaFromGS) {
//Check if the person scanning the token is exec, mgr, or admin
                        tokenStatus =
                            EnumToString.convertToString(newBaFromGS!.status);
                        if (_gs!
                            .getCurrentUser()!
                            .entityVsRole!
                            .containsKey(bookingToken.parent!.entityId)) {
                          if (_gs!.getCurrentUser()!.entityVsRole![
                                  bookingToken.parent!.entityId] !=
                              EntityRole.Executive) {
                            isReadOnly = false;
                          }
                        }

                        if (newBaFromGS != null) {
                          mapOfBa[token.tokens![0].getID()] = newBaFromGS;
                          _gs!
                              .getEntityService()!
                              .getEntity(bookingToken.parent!.entityId!)
                              .then((entity) {
                            Navigator.of(context)
                                .push(new MaterialPageRoute(
                                    builder: (BuildContext context) =>
                                        ShowApplicationDetails(
                                          bookingApplication: newBaFromGS,
                                          showReject: false,
                                          metaEntity: entity!.getMetaEntity(),
                                          newBookingDate: null,
                                          isReadOnly: isReadOnly,
                                          isAvailable: true,
                                          tokenCounter: null,
                                          backRoute: null,
                                        )))
                                .then((updatedBaTuple) {
                              if (updatedBaTuple != null) {
                                if (updatedBaTuple.item1.status ==
                                        ApplicationStatus.ONHOLD ||
                                    updatedBaTuple.item1.status ==
                                        ApplicationStatus.REJECTED) {
                                  tokenStatus = EnumToString.convertToString(
                                      newBaFromGS.status);
                                  bookingToken.number = -1;
                                  //bookingToken.numberBeforeCancellation
                                }
                                setState(() {
                                  print(
                                      'Updated returned TokenCounter and BA from details page');
                                });
                              }
                            });
                          });
                        } else {
                          Utils.showMyFlushbar(
                              context,
                              Icons.info,
                              Duration(seconds: 5),
                              'Oho! Could not fetch the Application details.',
                              'Please try again later.');
                        }
                      }).onError((dynamic error, stackTrace) {
                        if (error is AccessDeniedException) {
                          Utils.showMyFlushbar(
                              context,
                              Icons.error,
                              Duration(seconds: 8),
                              (error).cause,
                              contactAdminIfIssue);
                        } else {
                          Utils.showMyFlushbar(
                              context,
                              Icons.info,
                              Duration(seconds: 5),
                              'Oho! Could not fetch the Application details.',
                              'Please try again later.');
                        }
                      });
                    },
                  ),
                ],
              )
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (initCompleted) {
      // notesController.text = widget.bookingApplication.notes;
      return WillPopScope(
        child: Scaffold(
          appBar: CustomAppBarWithBackButton(
            titleTxt: "Booking Token Details",
            backRoute: UserHomePage(),
          ),
          body: Center(
            child: Container(
              // decoration: BoxDecoration(
              //     border: Border.all(color: borderColor, width: 1),
              //     color: Colors.white,
              //     shape: BoxShape.rectangle,
              //     borderRadius: BorderRadius.all(Radius.circular(5.0))),
              margin: EdgeInsets.all(8),
              padding: EdgeInsets.all(0),
              //  color: Colors.cyan[100],
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  (listOfTokens.length != 0)
                      ? ListView.builder(
                          padding: EdgeInsets.fromLTRB(0, 0, 0, 0),
                          scrollDirection: Axis.vertical,
                          physics: ClampingScrollPhysics(),
                          reverse: true,
                          shrinkWrap: true,
                          itemBuilder: (BuildContext context, int index) {
                            return Column(
                              children: [
                                buildTokenCard(listOfTokens[index]),
                              ],
                            );
                          },
                          itemCount: listOfTokens.length,
                        )
                      : Container(height: 0),
                ],
              ),
            ),
          ),
        ),
        onWillPop: () async {
          return true;
        },
      );
    } else {
      return new WillPopScope(
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
      );
    }
  }
}
