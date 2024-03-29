import 'package:LESSs/db/db_model/entity_slots.dart';
import 'package:LESSs/db/db_model/user_token.dart';
import 'package:LESSs/db/exceptions/MaxTokenReachedByUserPerDayException.dart';
import 'package:LESSs/db/exceptions/MaxTokenReachedByUserPerSlotException.dart';
import 'package:LESSs/triplet.dart';
import 'package:LESSs/tuple.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:another_flushbar/flushbar.dart';

import 'package:flutter/material.dart';
import '../db/db_model/entity.dart';
import '../db/db_model/meta_entity.dart';

import '../db/db_model/slot.dart';
import '../db/exceptions/slot_full_exception.dart';
import '../db/exceptions/token_already_exists_exception.dart';
import '../global_state.dart';

import '../pages/booking_form_selection_page.dart';

import '../pages/search_child_entity_page.dart';
import '../pages/search_entity_page.dart';
import '../pages/favs_list_page.dart';

import '../pages/token_alert.dart';
import '../repository/slotRepository.dart';
import '../services/circular_progress.dart';
import '../style.dart';
import '../utils.dart';
import '../widget/appbar.dart';
import '../widget/header.dart';
import '../widget/page_animation.dart';
import '../widget/widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import '../constants.dart';

class ShowSlotsPage extends StatefulWidget {
  final MetaEntity? metaEntity;
  final DateTime dateTime;
  final String forPage;

  ShowSlotsPage(
      {Key? key,
      required this.metaEntity,
      required this.dateTime,
      required this.forPage})
      : super(key: key);

  @override
  _ShowSlotsPageState createState() => _ShowSlotsPageState();
}

class _ShowSlotsPageState extends State<ShowSlotsPage> {
  bool _initCompleted = false;
  String? errMsg;
  String? _storeId;
  String? _token;
  String? _errorMessage;
  late DateTime _date;
  late String _dateFormatted;
  String? dt;
  List<Slot>? _slotList;
  final dateFormat = new DateFormat('dd');
  Slot? selectedSlot;
  Slot? bookedSlot;
  String? _storeName;
  String? _userId;
  String? _strDateForSlot;

  String title = "Book Slot";
  GlobalState? _gs;
  MetaEntity? metaEntity;
  Entity? parentEntity;
  DateTime currDateTime = DateTime.now();
  bool enableVideoChat = false;
  bool? entitySupportsVideo = false;
  bool? entitySupportsOffline = false;
  int numOfTokensByUser = 0;
  List<String> bookedSlots = [];
  EntitySlots? entitySlot;
  TokenCounter? tokenCounter;
  Map<String?, int> _tokensMap = new Map<String?, int>();
  int? maxAllowedTokensForUser;

  @override
  void initState() {
    metaEntity = widget.metaEntity;
    _date = widget.dateTime;
    _storeId = metaEntity!.entityId;
    _storeName = metaEntity!.name;

    super.initState();

    getGlobalState().whenComplete(() {
      _loadSlots();
      entitySupportsVideo = (metaEntity!.allowOnlineAppointment == null)
          ? false
          : metaEntity!.allowOnlineAppointment;
      entitySupportsOffline = (metaEntity!.allowWalkinAppointment == null)
          ? false
          : metaEntity!.allowWalkinAppointment;
      enableVideoChat =
          (entitySupportsVideo! && !entitySupportsOffline!) ? true : false;
      if (metaEntity!.parentId != null) {
        getEntityDetails(metaEntity!.parentId)
            .then((value) => parentEntity = value);
      }
    });
  }

  Future<void> _loadSlots() async {
    //Format date to display in UI
    final dtFormat = new DateFormat(dateDisplayFormat);
    _dateFormatted = dtFormat.format(_date);

    //Fetch details from server
    getSlotsListForEntity(metaEntity!, _date).then((slotListTuple) {
      _slotList = slotListTuple.item2;
      entitySlot = slotListTuple.item1;

      maxAllowedTokensForUser = (entitySlot != null)
          ? entitySlot!.maxTokensByUserInDay
          : metaEntity!.maxTokensByUserInDay;
      _gs!
          .getTokenService()!
          .getTokenCounterForEntity(
              widget.metaEntity!.entityId!, widget.dateTime.year.toString())
          .then((value) {
        slotsStatusUpdate(value, null, null);
        setState(() {
          _initCompleted = true;
        });
      });
    }).catchError((onError) {
      switch (onError.code) {
        case 'unavailable':
          setState(() {
            _initCompleted = true;
            errMsg = "No Internet Connection. Please check and try again.";
          });
          break;

        default:
          setState(() {
            _initCompleted = true;
            errMsg =
                'Oops, something went wrong. Check your internet connection and try again.';
          });
          break;
      }
    });
  }

  Future<void> getGlobalState() async {
    _gs = await GlobalState.getGlobalState();
  }

  Widget _noSlotsPage(String? msg) {
    return WillPopScope(
      child: Scaffold(
        drawer: CustomDrawer(
          phone: _gs!.getCurrentUser()!.ph,
        ),
        appBar: CustomAppBar(
          titleTxt: title,
        ),
        body: Center(
            child: Center(
                child: Container(
          margin: EdgeInsets.fromLTRB(10, 10, 10, 10),
          child: (msg != null) ? Text(msg) : Text(allSlotsBookedForDate),
        ))),
        // bottomNavigationBar: CustomBottomBar(
        //   barIndex: 3,
        // ),
      ),
      onWillPop: () async {
        return true;
      },
    );
  }

  Future<Entity?> getEntityDetails(String? id) async {
    var tup = await _gs!.getEntity(id);
    if (tup != null) {
      return tup.item1;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    if (_initCompleted) {
      if (Utils.isNullOrEmpty(_slotList)) {
        errMsg =
            "Time-Slot information not found for this place. Please contact admin of this place.";
        return _noSlotsPage(errMsg);
      } else {
        Widget pageHeader = Text(
          _storeName!,
          style: TextStyle(
            fontSize: 23,
            color: Colors.black,
          ),
        );
        String? bookingDate;
        String? bookingTime;
        if (selectedSlot != null) {
          bookingDate =
              DateFormat.yMMMEd().format(selectedSlot!.dateTime!).toString();
          bookingTime =
              DateFormat.Hm().format(selectedSlot!.dateTime!).toString();
        }

        dynamic backRoute;
        if (widget.forPage == 'MainSearch') backRoute = SearchEntityPage();
        if (widget.forPage == 'ChildSearch')
          backRoute = SearchChildEntityPage(
            pageName: "Search",
            parentName: parentEntity!.name,
            childList: parentEntity!.childEntities,
            parentId: parentEntity!.entityId,
          );
        if (widget.forPage == 'FavsSearch')
          backRoute = SearchChildEntityPage(
            pageName: "FavsSearch",
            parentName: parentEntity!.name,
            childList: parentEntity!.childEntities,
            parentId: parentEntity!.entityId,
          );
        if (widget.forPage == 'FavsList') backRoute = FavsListPage();

        return WillPopScope(
          child: Scaffold(
            drawer: CustomDrawer(
                phone: _gs!.getCurrentUser() != null
                    ? _gs!.getCurrentUser()!.ph
                    : ""),
            appBar: CustomAppBarWithBackButton(
                titleTxt: _storeName, backRoute: backRoute),
            body: Padding(
              padding: const EdgeInsets.fromLTRB(6, 6, 6, 6),
              child: Container(
                child: Column(
                  children: <Widget>[
                    if (entitySupportsVideo!)
                      Container(
                        width: MediaQuery.of(context).size.width * .95,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  "Opt for Video Consultation",
                                  style: TextStyle(
                                      color: Colors.blueGrey[800],
                                      fontSize: 19),
                                ),
                                SizedBox(
                                  height:
                                      MediaQuery.of(context).size.height * .08,
                                  width:
                                      MediaQuery.of(context).size.width * .22,
                                  child: Transform.scale(
                                    scale: .9,
                                    alignment: Alignment.centerRight,
                                    child: Switch(
                                      materialTapTargetSize:
                                          MaterialTapTargetSize.shrinkWrap,

                                      value: enableVideoChat,
                                      onChanged: (value) {
                                        setState(() {
                                          enableVideoChat = value;
                                        });
                                      },
                                      // activeTrackColor: Colors.green,
                                      activeColor: Colors.green,
                                      inactiveThumbColor: Colors.grey[300],
                                    ),
                                  ),
                                )
                              ],
                            ),
                            if (entitySupportsVideo! && !entitySupportsOffline!)
                              Text(
                                INFORMATION_ONLY_ONLINE_CONSULTATION + '\n',
                                style: TextStyle(
                                    fontSize: 11, color: Colors.indigo),
                              ),
                            if (entitySupportsVideo! && entitySupportsOffline!)
                              Text(
                                INFORMATION_RECOMMEND_ONLINE_CONSULTATION +
                                    '\n',
                                style: TextStyle(
                                    fontSize: 11, color: Colors.deepPurple),
                              ),
                          ],
                        ),
                      ),
                    if (maxAllowedTokensForUser != null)
                      Container(
                        margin: EdgeInsets.only(top: 5),
                        alignment: Alignment.centerLeft,
                        child: Text(
                          '* ' +
                              INFORMATION_MAX_ALLOWED_BOOKING_BY_USER_PER_DAY_1 +
                              maxAllowedTokensForUser.toString() +
                              INFORMATION_MAX_ALLOWED_BOOKING_BY_USER_PER_DAY_2 +
                              '\n',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 14, color: Colors.teal),
                        ),
                      ),
                    Card(
                      child: Container(
                        height: MediaQuery.of(context).size.width * .11,
                        padding: EdgeInsets.fromLTRB(6, 0, 0, 0),
                        decoration: darkContainer,
                        child: Row(
                          children: <Widget>[
                            SizedBox(
                              width: MediaQuery.of(context).size.width * .1,
                              child: Icon(
                                Icons.check_circle,
                                size: 35,
                                color: Colors.white,
                              ),
                            ),
                            //  SizedBox(width: 12),
                            SizedBox(
                              width: MediaQuery.of(context).size.width * .8,
                              height: MediaQuery.of(context).size.width * .11,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: <Widget>[
                                  (selectedSlot == null)
                                      ? AutoSizeText(
                                          "Select from available slots on " +
                                              _dateFormatted +
                                              ".",
                                          minFontSize: 8,
                                          style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 13),
                                        )
                                      : (isBooked(selectedSlot!.dateTime,
                                              metaEntity!.entityId))
                                          ? AutoSizeText(
                                              'You already have a booking at $bookingTime on $bookingDate',
                                              minFontSize: 8,
                                              style: TextStyle(
                                                  color: primaryAccentColor,
                                                  fontSize: 13),
                                            )
                                          : AutoSizeText(
                                              'You selected a slot at $bookingTime on $bookingDate',
                                              minFontSize: 8,
                                              maxFontSize: 13,
                                              style: TextStyle(
                                                color: highlightColor,
                                              ),
                                            ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Expanded(
                      child: Container(
                        child: new GridView.builder(
                          padding: EdgeInsets.symmetric(horizontal: 5),
                          scrollDirection: Axis.vertical,
                          shrinkWrap: true,
                          itemCount: _slotList!.length,
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 4,
                                  crossAxisSpacing: 2.0,
                                  mainAxisSpacing: 0.5),
                          itemBuilder: (BuildContext context, int index) {
                            return new GridTile(
                              child: Container(
                                padding: EdgeInsets.all(2),
                                // decoration:
                                //     BoxDecoration(border: Border.all(color: Colors.black, width: 0.5)),
                                child: Center(
                                  child: _buildGridItem(context, index),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                    Container(
                      height: MediaQuery.of(context).size.height * .12,
                      padding: EdgeInsets.all(4),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: <Widget>[
                          //TODO Smita - This is for taking no. of users accompanying in one booking.
                          //DONT DELETE
                          // Row(
                          //   mainAxisAlignment: MainAxisAlignment.center,
                          //   crossAxisAlignment: CrossAxisAlignment.center,
                          //   children: <Widget>[
                          //     SizedBox(
                          //       width:
                          //           MediaQuery.of(context).size.width * .06,
                          //       height:
                          //           MediaQuery.of(context).size.width * .06,
                          //       child: IconButton(
                          //           padding: EdgeInsets.zero,
                          //           icon: Icon(Icons.add),
                          //           alignment: Alignment.center,
                          //           onPressed: null),
                          //     ),
                          //     SizedBox(
                          //       width:
                          //           MediaQuery.of(context).size.width * .68,
                          //       height:
                          //           MediaQuery.of(context).size.width * .06,
                          //       child: RaisedButton(
                          //         // elevation: 10.0,
                          //         color: Colors.white,
                          //         splashColor: Colors.orangeAccent[700],
                          //         textColor: Colors.white,
                          //         child: Text(
                          //           'Kitne aadmi hai Sambha!!',
                          //           style: TextStyle(fontSize: 20),
                          //         ),
                          //         onPressed: () {},
                          //       ),
                          //     ),
                          //     SizedBox(
                          //       width:
                          //           MediaQuery.of(context).size.width * .06,
                          //       height:
                          //           MediaQuery.of(context).size.width * .06,
                          //       child: IconButton(
                          //           padding: EdgeInsets.zero,
                          //           icon: Icon(Icons.remove),
                          //           alignment: Alignment.center,
                          //           onPressed: null),
                          //     ),
                          //   ],
                          // ),
                          // SizedBox(
                          //   height: 10,
                          // ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              SizedBox(
                                width: MediaQuery.of(context).size.width * .8,
                                height:
                                    MediaQuery.of(context).size.height * .06,
                                child: RaisedButton(
                                  elevation: 10.0,
                                  color: btnColor,
                                  splashColor: Colors.orangeAccent[700],
                                  textColor: Colors.white,
                                  child: Text(
                                    'Book Slot',
                                    style: buttonMedTextStyle,
                                  ),
                                  onPressed: () {
                                    if (selectedSlot != null) {
                                      bookSlot();
                                    } else {
                                      Utils.showMyFlushbar(
                                          context,
                                          Icons.error,
                                          Duration(seconds: 4),
                                          forgotTimeSlot,
                                          "");
                                    }
                                  },
                                ),
                              ),
                              (_errorMessage != null
                                  ? Text(
                                      _errorMessage!,
                                      style: TextStyle(color: Colors.red),
                                    )
                                  : Container()),
                            ],
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: <Widget>[
                              Row(
                                children: <Widget>[
                                  Icon(Icons.label,
                                      color: highlightColor, size: 15),
                                  Text(" Currently Selected",
                                      style: TextStyle(
                                        color: Colors.blueGrey[900],
                                        // fontWeight: FontWeight.w800,
                                        fontFamily: 'Monsterrat',
                                        letterSpacing: 0.5,
                                        fontSize: 9.0,
                                        //height: 2,
                                      )),
                                ],
                              ),
                              horizontalSpacer,
                              Row(children: <Widget>[
                                Icon(Icons.label, color: greenColor, size: 15),
                                Text(" Existing Booking",
                                    style: TextStyle(
                                      color: Colors.blueGrey[900],
                                      // fontWeight: FontWeight.w800,
                                      fontFamily: 'Roboto',
                                      letterSpacing: 0.5,
                                      fontSize: 9.0,
                                      //height: 2,
                                    )),
                              ]),
                              horizontalSpacer,
                              Row(children: <Widget>[
                                Icon(Icons.label,
                                    color: Colors.blueGrey[400], size: 15),
                                Text(" Not available",
                                    style: TextStyle(
                                      color: Colors.blueGrey[900],
                                      // fontWeight: FontWeight.w800,
                                      fontFamily: 'Monsterrat',
                                      letterSpacing: 0.5,
                                      fontSize: 9.0,
                                      //height: 2,
                                    )),
                              ]),
                            ],
                          )
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          onWillPop: () async {
            return true;
          },
        );
      }
    } else {
      return WillPopScope(
        child: Scaffold(
          appBar: CustomAppBar(
            titleTxt: "Search",
          ),
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                // Padding(padding: EdgeInsets.only(top: 20.0)),
                showCircularProgress()
              ],
            ),
          ),
          //drawer: CustomDrawer(),
          //  bottomNavigationBar: CustomBottomBar(barIndex: 1)
        ),
        onWillPop: () async {
          return true;
        },
      );
    }
  }

  bool isSelected(DateTime? dateTime) {
    if (selectedSlot != null) {
      if (dateTime!.compareTo(selectedSlot!.dateTime!) == 0) return true;
    }
    return false;
  }

  bool isBooked(DateTime? dateTime, String? entityId) {
    int bookedTokens = 0;
    int cancelledTokens = 0;
    if (entitySlot != null) {
      for (Slot sl in entitySlot!.slots!) {
        if (sl.dateTime!.hour == dateTime!.hour &&
            sl.dateTime!.minute == dateTime.minute) {
          for (UserTokens? uts in sl.tokens!) {
            if (uts!.userId == _gs!.getCurrentUser()!.ph) {
              bookedTokens++;
            }
            for (UserToken ut in uts.tokens!) {
              if (ut.number == -1) {
                cancelledTokens++;
              }
            }
          }
        }
      }
      if (bookedTokens - cancelledTokens > 0)
        return true;
      else
        return false;
    } else
      return false;
  }

  bool isDisabled(DateTime dateTime) {
    bool isDisabled = dateTime.isBefore(currDateTime);
    return isDisabled;
  }

  slotsStatusUpdate(
      TokenCounter? counter, Slot? bookedSlot, EntitySlots? entitySlots) {
    if (counter != null) {
      int? updatedIndex;
      for (int i = 0; i <= _slotList!.length - 1; i++) {
//Update SlotList with new Slot details.
        if (bookedSlot != null) {
          if (_slotList![i]
                  .dateTime!
                  .difference(bookedSlot.dateTime!)
                  .inSeconds ==
              0) {
            updatedIndex = i;
            break;
            // _slotList[i].isFull = bookedSlot.isFull;
            // _slotList[i].slotId = bookedSlot.slotId;
            // _slotList[i].tokens = bookedSlot.tokens;
            // _slotList[i].totalBooked = bookedSlot.totalBooked;
            // _slotList[i].totalCancelled = bookedSlot.totalCancelled;
          }
        }
      }
      if (updatedIndex != null) {
        for (Slot sl in entitySlots!.slots!) {
          if (sl.dateTime!.compareTo(bookedSlot!.dateTime!) == 0) {
            _slotList![updatedIndex] = sl;
            break;
          }
        }
      }

      for (int i = 0; i <= _slotList!.length - 1; i++) {
        List<String> slotIdVals = [];
        if (Utils.isNotNullOrEmpty(_slotList![i].slotId)) {
          slotIdVals = _slotList![i].slotId!.split('#');

          String slotId = slotIdVals[1] + '#' + slotIdVals[2];
          if (counter.slotWiseStats!.containsKey(slotId)) {
            TokenStats slotStats = counter.slotWiseStats![slotId]!;

            int numberOfBookingsLeft = (entitySlot != null
                    ? entitySlot!.maxAllowed
                    : widget.metaEntity!.maxAllowed)! -
                (slotStats.numberOfTokensCreated! -
                    slotStats.numberOfTokensCancelled!);
            //   if (_tokensMap.containsKey(_slotList[i].slotId)) {
            _tokensMap[_slotList![i].slotId] = numberOfBookingsLeft;
            //  }
          }
        }
      }
    }
  }

  Widget _buildGridItem(BuildContext context, int index) {
    Slot sl = _slotList![index];
    String hrs = Utils.formatTime(sl.dateTime!.hour.toString());
    String mnts = Utils.formatTime(sl.dateTime!.minute.toString());
    bool isBookedFlg = isBooked(sl.dateTime, metaEntity!.entityId);
    return Column(
      children: <Widget>[
        Container(
          child: MaterialButton(
            elevation: (isDisabled(sl.dateTime!))
                ? 0
                : ((isSelected(sl.dateTime) == true) ? 0.0 : 3.0),
            padding: EdgeInsets.all(2),
            child: Text(
              hrs + ':' + mnts,
              style: TextStyle(
                fontSize: 12,
                color: isDisabled(sl.dateTime!)
                    ? Colors.grey[500]
                    : (isBookedFlg ? Colors.white : primaryDarkColor),
                // textDirection: TextDirection.ltr,
                // textAlign: TextAlign.center,
              ),
            ),
            autofocus: false,
            color: (isDisabled(sl.dateTime!))
                ? disabledColor
                : ((isBookedFlg)
                    ? Colors.greenAccent[700]
                    : ((sl.isFull != true && isSelected(sl.dateTime) == true)
                        ? highlightColor
                        : (sl.isFull == false)
                            ? Colors.cyan[50]
                            : btnDisabledolor)),
            disabledColor: Colors.grey[200],
            splashColor: (sl.isFull == true) ? highlightColor : null,
            shape: (isSelected(sl.dateTime) == true)
                ? RoundedRectangleBorder(
                    borderRadius: new BorderRadius.circular(5.0),
                    // side: BorderSide(color: highlightColor),
                  )
                : RoundedRectangleBorder(
                    borderRadius: new BorderRadius.circular(5.0),
                    // side: BorderSide(color: Colors.white),
                  ),
            onPressed: () {
              if (!isDisabled(sl.dateTime!)) {
                if (isBooked(sl.dateTime, metaEntity!.entityId)) {
                  Utils.showMyFlushbar(
                      context,
                      Icons.info_outline,
                      Duration(seconds: 6),
                      alreadyHaveBooking,
                      wantToBookAnotherSlot);
                  return null;
                }
                if (sl.isFull == false) {
                  setState(() {
                    //unselect previously selected slot
                    selectedSlot = sl;
                  });
                } else
                  return null;
              } else
                return null;
            },
          ),
        ),
        Container(
          width: MediaQuery.of(context).size.width * .17,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AutoSizeText(
                  (_tokensMap.containsKey(sl.slotId)
                          ? _tokensMap[sl.slotId]
                          : (entitySlot != null
                              ? entitySlot!.maxAllowed
                              : metaEntity!.maxAllowed))
                      .toString(),
                  // (sl.totalBooked -
                  //         (sl.totalCancelled != null ? sl.totalCancelled : 0))
                  //     .toString(),
                  minFontSize: 9,
                  maxFontSize: 11,
                  style: TextStyle(
                    color: Colors.black,
                    fontFamily: 'Roboto',
                    letterSpacing: 0.5,
                  )),
              AutoSizeText(' left',
                  minFontSize: 8,
                  maxFontSize: 10,
                  style: TextStyle(
                      color: Colors.black,
                      fontFamily: 'Roboto',
                      letterSpacing: 0.5,
                      fontSize: 10)),
            ],
          ),
        ),
      ],
    );
  }

  void bookSlot() {
    _gs!.initializeNotification();

    if (maxAllowedTokensForUser! <= bookedSlots.length) {
      //Max tokens already booked, then user cant book further slots.
      Utils.showMyFlushbar(context, Icons.error, Duration(seconds: 5),
          maxTokenLimitReached, maxTokenLimitReachedSub);
      selectedSlot = null;
      setState(() {});
      return;
    }
    bool showForm = false;
    if (!Utils.isNullOrEmpty(metaEntity!.forms)) {
      if (metaEntity!.forms!.length >= 1) {
        // Check if forms are not in deleted state

        for (var form in metaEntity!.forms!) {
          if (form.isActive!) {
            showForm = true;
          }
        }
        if (showForm) {
          //Show Booking request form SELECTION page
          Navigator.of(context).push(new MaterialPageRoute(
              builder: (BuildContext context) => BookingFormSelection(
                  entityId: metaEntity!.entityId,
                  entity: null,
                  preferredSlotTime: selectedSlot!.dateTime,
                  isFullAccess: false,
                  forUser: true,
                  backRoute: SearchEntityPage(),
                  isOnlineToken: enableVideoChat)));
        }
      }
    }
    if (!showForm) {
      Utils.showMyFlushbar(
          context,
          Icons.info_outline,
          Duration(
            seconds: 3,
          ),
          slotBooking,
          takingMoment);
      _gs!.addBooking(metaEntity, selectedSlot!, enableVideoChat).then((value) {
        if (value == null) {
          showFlushBar();
          selectedSlot = null;
          setState(() {});
          return;
        } else {
          UserTokens? tokens;
          Triplet<UserTokens, TokenCounter, EntitySlots> tuple = value;
          tokens = tuple.item1;
          tokenCounter = tuple.item2;
          entitySlot = tuple.item3;
          //selectedSlot.tokens.add(tokens);
          //selectedSlot.totalBooked++;
          //selectedSlot.slotId  = entitySlot.e
          slotsStatusUpdate(tokenCounter, selectedSlot, entitySlot);

          _gs!.getNotificationService()!.registerTokenNotification(tokens!);

          //update in global State
          selectedSlot!.totalBooked = selectedSlot!.totalBooked! + 1;

          _token = tokens.tokens!.last.getDisplayName();
          final dtFormat = new DateFormat(dateDisplayFormat);
          String _dateFormatted = dtFormat.format(selectedSlot!.dateTime!);

          String slotTiming =
              Utils.formatTime(selectedSlot!.dateTime!.hour.toString()) +
                  ':' +
                  Utils.formatTime(selectedSlot!.dateTime!.minute.toString());

          String msg = enableVideoChat ? tokenTextH2Online : tokenTextH2Walkin;

          setState(() {});
          showTokenAlert(
                  context, msg, _token, _storeName, _dateFormatted, slotTiming)
              .then((value) {
            _returnValues(value);
            setState(() {
              bookedSlot = selectedSlot;
              selectedSlot = null;
            });
            //Ask user if he wants to receive the notifications

            //End of notification permission

//Update local file with new booking.

            String returnVal = value + '-' + slotTiming;
            // Navigator.of(context).pop(returnVal);
            // print(value);
          });
        }
      }).catchError((error, stackTrace) {
        print("Error in token booking" + error.toString());
        if (error is MaxTokenReachedByUserPerSlotException) {
          Utils.showMyFlushbar(context, Icons.error, Duration(seconds: 5),
              couldNotBookToken, error.cause);
        } else if (error is MaxTokenReachedByUserPerDayException) {
          Utils.showMyFlushbar(context, Icons.error, Duration(seconds: 5),
              couldNotBookToken, error.cause);
        } else if (error is SlotFullException) {
          Utils.showMyFlushbar(context, Icons.error, Duration(seconds: 5),
              couldNotBookToken, slotsAlreadyBooked);
        } else if (error is TokenAlreadyExistsException) {
          Utils.showMyFlushbar(context, Icons.error, Duration(seconds: 5),
              couldNotBookToken, tokenAlreadyExists);
        } else {
          Utils.showMyFlushbar(context, Icons.error, Duration(seconds: 5),
              couldNotBookToken, tryAgainToBook);
        }
      });
    }
  }

  void showFlushBar() {
    Flushbar(
      //padding: EdgeInsets.zero,
      margin: EdgeInsets.zero,
      flushbarPosition: FlushbarPosition.BOTTOM,
      flushbarStyle: FlushbarStyle.FLOATING,
      reverseAnimationCurve: Curves.decelerate,
      forwardAnimationCurve: Curves.easeInToLinear,
      backgroundColor: Colors.blueGrey[500]!,
      boxShadows: [
        BoxShadow(
            color: primaryAccentColor,
            offset: Offset(0.0, 2.0),
            blurRadius: 3.0)
      ],
      isDismissible: false,
      duration: Duration(seconds: 6),
      icon: Icon(
        Icons.error,
        color: Colors.blueGrey[50],
      ),
      showProgressIndicator: false,
      progressIndicatorBackgroundColor: Colors.blueGrey[800],
      routeBlur: 10.0,
      titleText: Text(
        couldNotBookToken,
        style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16.0,
            color: primaryAccentColor,
            fontFamily: "ShadowsIntoLightTwo"),
      ),
      messageText: Text(
        tokenAlreadyExists,
        style: TextStyle(
            fontSize: 12.0,
            color: Colors.blueGrey[50],
            fontFamily: "ShadowsIntoLightTwo"),
      ),
    )..show(context);
  }

  void _returnValues(String value) async {
    //Load details from local files
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('tokenNum', value);
  }
}
