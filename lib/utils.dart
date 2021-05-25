import 'dart:async';
import 'package:LESSs/db/exceptions/MaxTokenReachedByUserPerSlotException.dart';
import 'package:LESSs/db/exceptions/slot_full_exception.dart';
import 'package:LESSs/db/exceptions/token_already_exists_exception.dart';
import 'package:email_validator/email_validator.dart';
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:another_flushbar/flushbar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import './db/db_model/address.dart';
import './db/db_model/booking_application.dart';
import './db/db_model/meta_entity.dart';
import './enum/entity_type.dart';
import './global_state.dart';
import './pages/favs_list_page.dart';
import './pages/show_slots_page.dart';
import './pages/show_user_application_details.dart';
import './services/auth_service.dart';
import './style.dart';
import './widget/weekday_selector.dart';
import './widget/widgets.dart';
import 'package:share/share.dart';
import 'package:uuid/uuid.dart';

import 'constants.dart';
import 'db/db_model/entity.dart';
import 'db/db_model/entity_slots.dart';
import 'db/db_model/slot.dart';
import 'db/db_model/user_token.dart';
import 'db/exceptions/MaxTokenReachedByUserPerDayException.dart';
import 'pages/qr_code_user_token.dart';

class Utils {
  static String getDayOfWeek(DateTime date) {
    //String day;
    switch (date.weekday) {
      case 1:
        return "Mon";
        break;
      case 2:
        return "Tue";
        break;
      case 3:
        return "Wed";
        break;
      case 4:
        return "Thu";
        break;
      case 5:
        return "Fri";
        break;
      case 6:
        return "Sat";
        break;
      case 7:
        return "Sun";
        break;
      default:
        return "Day";
        break;
    }
  }

  static bool checkIfClosed(DateTime date, List<String> closedOn) {
    for (String dayClosed in closedOn) {
      if (getDayNumber(dayClosed) == date.weekday) {
        return true;
      }
    }

    return false;
  }

  static bool isNullOrEmpty(List<dynamic> list) {
    if (list == null) return true;
    if (list.length == 0) return true;

    return false;
  }

  static bool isNotNullOrEmpty(String str) {
    if (str == null) return false;
    if (str == "") return false;
    if (str.isEmpty) return false;

    return true;
  }

  static bool isStrNullOrEmpty(String str) {
    if (str == null) return true;
    if (str == "") return true;
    if (str.isEmpty) return true;

    return false;
  }

  static String getFormattedAddress(Address address) {
    String adr =
        (Utils.isNotNullOrEmpty(address.address) ? (address.address) : "") +
            (Utils.isNotNullOrEmpty(address.locality)
                ? (', ' + address.locality)
                : "") +
            (Utils.isNotNullOrEmpty(address.landmark)
                ? (', ' + address.landmark)
                : "") +
            (Utils.isNotNullOrEmpty(address.city) ? (', ' + address.city) : "");
    return adr;
  }

  static String validateMobile(String value) {
    if (value == null) return 'Enter a phone number';

    var potentialNumber = int.tryParse(value);

    if (potentialNumber == null) return 'Enter a valid phone number';

    if ((value.length > 10)) {
      return 'Enter a valid phone number';
    } else if ((value.length < 8)) {
      return 'Enter a valid phone number';
    } else
      return null;
  }

  static String validateUpiAddress(String upi) {
    if (Utils.isNotNullOrEmpty(upi)) {
      if (upi.split('@').length == 2) {
        return null;
      } else {
        return "UPI Id is not valid";
      }
    }
    return null;
  }

  static String validateEmail(String valText) {
    return (Utils.isNotNullOrEmpty(valText))
        ? (EmailValidator.validate(valText) ? null : "Email is not valid")
        : null;
  }

  static Future<DateTime> pickDate(
      BuildContext context, DateTime firstDate, DateTime lastDate) async {
    DateTime date = await showDatePicker(
      context: context,
      firstDate: firstDate,
      lastDate: lastDate,
      initialDate: DateTime.now(),
      builder: (BuildContext context, Widget child) {
        return Theme(
          data: ThemeData.dark().copyWith(
            colorScheme: ColorScheme.light(
              primary: Colors.cyan,
            ),
            dialogBackgroundColor: Colors.white,
          ),
          child: child,
        );
      },
    );
    return date;
  }

  static Future<void> showLocationAccessDialog(
      BuildContext bc, String msg) async {
    print("SHOW Dialog called");
    bool returnVal = await showDialog(
        barrierDismissible: false,
        context: bc,
        builder: (_) => AlertDialog(
              titlePadding: EdgeInsets.fromLTRB(5, 10, 0, 0),
              contentPadding: EdgeInsets.all(0),
              actionsPadding: EdgeInsets.all(0),
              //buttonPadding: EdgeInsets.all(0),
              title: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    msg,
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
                    elevation: 5,
                    focusColor: highlightColor,
                    splashColor: highlightColor,
                    color: Colors.white,
                    textColor: Colors.orange,
                    shape: RoundedRectangleBorder(
                        side: BorderSide(color: Colors.orange)),
                    child: Text('No'),
                    onPressed: () {
                      Navigator.of(_).pop(false);
                    },
                  ),
                ),
                SizedBox(
                  height: 24,
                  child: RaisedButton(
                    elevation: 10,
                    color: btnColor,
                    splashColor: highlightColor.withOpacity(.8),
                    textColor: Colors.white,
                    shape: RoundedRectangleBorder(
                        side: BorderSide(color: Colors.orange)),
                    child: Text('Yes'),
                    onPressed: () {
                      Navigator.of(_).pop(true);
                    },
                  ),
                ),
              ],
            ));

    if (returnVal) {
      print("in true, opening app settings");
      Utils.openAppSettings();
    } else {
      print("nothing to do, user denied location access");
      Utils.showMyFlushbar(bc, Icons.info, Duration(seconds: 3),
          locationAccessDeniedStr, locationAccessDeniedSubStr);
      print(returnVal);
    }
  }

  static String validateMobileField(String value) {
    String errMsg = 'Enter a valid Phone number';
    if (value == null || value == "") return null;
    var potentialNumber = int.tryParse(value);
    if (potentialNumber == null) return errMsg;
    if ((value.length > 10)) {
      return errMsg;
    } else if ((value.length < 8)) {
      return errMsg;
    } else
      return null;
  }

  static void showMyFlushbar(BuildContext context, IconData icon,
      Duration duration, String title, String msg,
      [Color barcolor = Colors.orangeAccent,
      Color fontcolor = Colors.white,
      bool showFlushBar = false]) {
    if (barcolor == null) barcolor = Colors.orangeAccent;
    Animation<Color> animationColor =
        AlwaysStoppedAnimation<Color>(Color(0xFF00ACC1));
    Flushbar(
      padding: EdgeInsets.fromLTRB(4, 8, 8, 4),
      margin: EdgeInsets.zero,
      flushbarPosition: FlushbarPosition.BOTTOM,
      flushbarStyle: FlushbarStyle.FLOATING,
      reverseAnimationCurve: Curves.decelerate,
      forwardAnimationCurve: Curves.easeInToLinear,
      backgroundColor: barcolor,
      boxShadows: [
        BoxShadow(
            color: primaryAccentColor,
            offset: Offset(0.0, 2.0),
            blurRadius: 3.0)
      ],
      isDismissible: false,
      duration: duration,
      icon: Icon(
        icon,
        color: fontcolor,
        size: 35,
      ),
      showProgressIndicator: showFlushBar,
      progressIndicatorBackgroundColor: barcolor,
      progressIndicatorValueColor: animationColor,
      routeBlur: 1.0,
      titleText: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          verticalSpacer,
          Text(
            title,
            style: TextStyle(
                //fontWeight: FontWeight.bold,
                fontSize: 15.0,
                color: Colors.white,
                fontFamily: "Roboto"),
          ),
        ],
      ),
      messageText: Text(
        msg,
        style:
            TextStyle(fontSize: 12.0, color: borderColor, fontFamily: "Roboto"),
      ),
    )..show(context);
  }

  static List<days> convertStringsToDays(List<String> stringsList) {
    List<days> daysList = List<days>();
    stringsList.forEach((element) {
      print(element);
      switch (element) {
        case 'monday':
          {
            daysList.add(days.monday);
          }
          break;
        case 'tuesday':
          {
            daysList.add(days.tuesday);
          }
          break;
        case 'wednesday':
          {
            daysList.add(days.wednesday);
          }
          break;

        case 'thursday':
          {
            daysList.add(days.thursday);
          }
          break;
        case 'friday':
          {
            daysList.add(days.friday);
          }
          break;
        case 'saturday':
          {
            daysList.add(days.saturday);
          }
          break;
        case 'sunday':
          {
            daysList.add(days.sunday);
          }
          break;

        default:
          {
            daysList.add(days.sunday);
          }
          break;
      }
    });
    return daysList;
  }

  static int getDayNumber(String day) {
    switch (day) {
      case 'monday':
        {
          return 1;
        }

      case 'tuesday':
        {
          return 2;
        }

      case 'wednesday':
        {
          return 3;
        }

      case 'thursday':
        {
          return 4;
        }

      case 'friday':
        {
          return 5;
        }

      case 'saturday':
        {
          return 6;
        }

      case 'sunday':
        {
          return 7;
        }
    }
  }

  static bool isNumeric(String s) {
    if (s == null) {
      return false;
    }
    bool result;
    (double.tryParse(s) != null) ? result = true : result = false;
    return result;
  }

  static String formatTime(String hr) {
    if (hr.length == 1) {
      hr = '0' + hr;
    }
    return hr;
  }

  static String formatTimeAsStr(String time) {
    List hrMin = time.split(':');
    String hr = hrMin[0];
    String min = hrMin[1];
    if (hr.length == 1) {
      hr = '0' + hr;
    }
    if (min.length == 1) {
      min = '0' + min;
    }

    return hr + ':' + min;
  }

  static void addEntityToFavs(BuildContext context, String id) async {
    Utils.showMyFlushbar(context, Icons.info, Duration(seconds: 3),
        "Adding the Place to your Favourites...", "Hold on!");

    GlobalState gs = await GlobalState.getGlobalState();
    Entity entity;

    gs.getEntity(id).then((value) {
      if (value == null)
        Utils.showMyFlushbar(context, Icons.info, Duration(seconds: 3),
            "The place does not exists!", "");

      entity = value.item1;

      gs.addFavourite(entity.getMetaEntity()).then((value) {
        if (value) {
          Utils.showMyFlushbar(context, Icons.info, Duration(seconds: 3),
              "Added to your favorites.", "");

          Navigator.pushReplacement(
              context, MaterialPageRoute(builder: (context) => FavsListPage()));
        } else {
          Utils.showMyFlushbar(
              context,
              Icons.info,
              Duration(seconds: 3),
              "Oops!! Could not add this place to your favorites.",
              "Try again later!");
        }
      });
    });
  }

  static void showApplicationDetails(
      BuildContext context, String tokenId) async {
    Utils.showMyFlushbar(context, Icons.info, Duration(seconds: 3),
        "Loading the Booking details...", "Hold on!");

    GlobalState gs = await GlobalState.getGlobalState();
    UserTokens userTokenId;
    print(tokenId);
    tokenId = tokenId.replaceAll(' ', '+');
    gs.getTokenService().getUserToken(tokenId).then((value) {
      if (value == null) {
        Utils.showMyFlushbar(context, Icons.info, Duration(seconds: 3),
            "No data found for this token.", "");
      } else {
        userTokenId = value;

        Navigator.pushReplacement(
            context,
            MaterialPageRoute(
                builder: (context) => ShowQrBookingToken(
                      userTokens: userTokenId,
                      isAdmin: true,
                    )));
      }
    });
  }

  static List<Slot> getSlots(
      EntitySlots entitySlots, MetaEntity me, DateTime dateTime) {
    //if EntitySlots is null, this method will return all the slots without merging the booking info from the DB
    DateTime breakStartTime;
    DateTime breakEndTime;
    DateTime dayStartTime;
    DateTime dayEndTime;
    List<Slot> slotList = new List<Slot>();

    dayStartTime = new DateTime(dateTime.year, dateTime.month, dateTime.day,
        me.startTimeHour, me.startTimeMinute);
    dayEndTime = new DateTime(dateTime.year, dateTime.month, dateTime.day,
        me.endTimeHour, me.endTimeMinute);
    if (me.breakEndHour == null || me.breakStartHour == null) {
      breakStartTime = dayStartTime;
      breakEndTime = dayStartTime;
    } else {
      breakStartTime = new DateTime(dateTime.year, dateTime.month, dateTime.day,
          me.breakStartHour, me.breakStartMinute);
      breakEndTime = new DateTime(dateTime.year, dateTime.month, dateTime.day,
          me.breakEndHour, me.breakEndMinute);
    }

    int firstHalfDuration = breakStartTime.difference(dayStartTime).inMinutes;

    int secondHalfDuration = dayEndTime.difference(breakEndTime).inMinutes;

    int numberOfSlotsInFirstHalf = firstHalfDuration ~/ me.slotDuration;

    int numberOfSlotsInSecondHalf = secondHalfDuration ~/ me.slotDuration;

    //no slots are booked for this entity yet on this date
    for (int count = 0; count < numberOfSlotsInFirstHalf; count++) {
      int minutesToAdd = count * me.slotDuration;
      DateTime dt = dayStartTime.add(new Duration(minutes: minutesToAdd));
      Slot sl = checkIfSlotExists(entitySlots, dt);
      if (sl == null) {
        sl = new Slot(
            slotId: "",
            totalBooked: 0,
            maxAllowed: me.maxAllowed,
            dateTime: dt,
            slotDuration: me.slotDuration,
            isFull: false);
      }

      slotList.add(sl);
    }

    for (int count = 0; count < numberOfSlotsInSecondHalf; count++) {
      int minutesToAdd = count * me.slotDuration;
      DateTime dt = breakEndTime.add(new Duration(minutes: minutesToAdd));
      Slot sl = checkIfSlotExists(entitySlots, dt);
      if (sl == null) {
        sl = new Slot(
            slotId: "",
            totalBooked: 0,
            maxAllowed: me.maxAllowed,
            dateTime: dt,
            slotDuration: me.slotDuration,
            isFull: false);
      }

      slotList.add(sl);
    }
    return slotList;
  }

  static Slot checkIfSlotExists(EntitySlots entitySlots, DateTime dt) {
    if (entitySlots == null || entitySlots.slots == null) {
      return null;
    }

    for (Slot sl in entitySlots.slots) {
      if (sl.dateTime.compareTo(dt) == 0) {
        return sl;
      }
    }
    return null;
  }

  static Entity createEntity(EntityType entityType, [String parentId]) {
    var uuid = new Uuid();
    String entityId = uuid.v1();
    var isPublic = true;
    var isBookable = true;
    bool isOnlineAppointment = false;
    bool isWalkInAppointment = true;
    if (entityType == EntityType.PLACE_TYPE_MALL ||
        entityType == EntityType.PLACE_TYPE_HOSPITAL ||
        entityType == EntityType.PLACE_TYPE_PUBLIC_OFFICE) {
      //is Public and Not bookable
      isPublic = true;
      isBookable = false;
    } else if (entityType == EntityType.PLACE_TYPE_APARTMENT ||
        entityType == EntityType.PLACE_TYPE_SCHOOL ||
        entityType == EntityType.PLACE_TYPE_PRIVATE_OFFICE) {
      // is Private and Not bookable
      isPublic = false;
      isBookable = false;
    } else if (entityType == EntityType.PLACE_TYPE_MEDICAL_CLINIC ||
        entityType == EntityType.PLACE_TYPE_SCHOOL ||
        entityType == EntityType.PLACE_TYPE_HOSPITAL) {
      // is Private and Not bookable
      isOnlineAppointment = true;
      isWalkInAppointment = true;
    } else {
      // is public and bookable
      isPublic = true;
      isBookable = true;
    }

    Entity entity = new Entity(
        entityId: entityId,
        name: null,
        address: null,
        advanceDays: 2,
        isPublic: isPublic,
        //geo: geoPoint,
        maxAllowed: null,
        slotDuration: null,
        closedOn: [],
        breakStartHour: null,
        breakStartMinute: null,
        breakEndHour: null,
        breakEndMinute: null,
        startTimeHour: null,
        startTimeMinute: null,
        endTimeHour: null,
        endTimeMinute: null,
        parentId: parentId,
        type: entityType,
        isBookable: isBookable,
        isActive: false,
        coordinates: null,
        offer: null,
        allowOnlineAppointment: isOnlineAppointment,
        allowWalkinAppointment: isWalkInAppointment);

    return entity;
  }

  static String getTokenDisplayName(String entityName, String tokenId) {
    String displayName = "";

    String first3Letters = entityName.substring(0, 4);
    displayName = displayName + first3Letters;

    List<String> tokenParts = tokenId.split('#');
    String date = tokenParts[1];
    String time = tokenParts[2];
    String number = tokenParts[4];

    List<String> dateParts = date.split('~');
    String year = dateParts[0];
    String month = dateParts[1];
    String day = dateParts[2];

    displayName = displayName + "-" + year + month + day;

    List<String> timeParts = time.split('~');
    String hour = timeParts[0];
    String minute = timeParts[1];

    displayName = displayName + "-" + hour + minute + '-' + number;
    return displayName;
  }

  static DateTime getTokenDate(String tokenId) {
    //980c1e20-bb79-11eb-9857-7109440c1073#2021~5~28#15~0#+919876543210#1
    List<String> tokenParts = tokenId.split('#');
    String date = tokenParts[1];
    String time = tokenParts[2];
    String number = tokenParts[4];

    List<String> dateParts = date.split('~');
    String year = dateParts[0];
    String month = dateParts[1];
    String day = dateParts[2];

    List<String> timeParts = time.split('~');
    String hour = timeParts[0];
    String minute = timeParts[1];

    DateTime dt = new DateTime(int.parse(year), int.parse(month),
        int.parse(day), int.parse(hour), int.parse(minute));

    return dt;
  }

  static Future<Position> getCurrLocation() async {
    //TODO SMita = getting lost at this statement
    LocationPermission permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.deniedForever) {
      throw Exception("LocAccessDeniedForever");
    }

    // if (permission == LocationPermission.denied) {
    //   permission = await requestPermission();
    // }

    Position pos;
    try {
      pos = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);
    } catch (e) {
      print(e);
    }
    return pos;
  }

  static Future<void> openAppSettings() async {
    bool locSettingsOpen = await Geolocator.openLocationSettings();
    if (!locSettingsOpen) {
      await openAppSettings();
    }
  }

  static Future<Uri> createDynamicLinkFullWithParams(
      String entityId, String entityName) async {
    String msgTitle = entityName + entityShareByOwnerHeading;
    final DynamicLinkParameters parameters = DynamicLinkParameters(
      // This should match firebase but without the username query param
      uriPrefix: shareURLPrefix,
      // This can be whatever you want for the uri, https://yourapp.com/groupinvite?username=$userName
      link: Uri.parse(shareURLPrefix + '/?entityId=$entityId'),
      androidParameters: AndroidParameters(
          packageName: bundleId,
          minimumVersion: 1,
          fallbackUrl: Uri.parse('https://bigpiq.com/#product')),
      iosParameters: IosParameters(
        bundleId: bundleId,
        minimumVersion: '1',
        appStoreId: appStoreId,
      ),
      socialMetaTagParameters: SocialMetaTagParameters(
        title: msgTitle,
        description: entityShareMessage,
        imageUrl: Uri.parse(
            'https://firebasestorage.googleapis.com/v0/b/sukoon-india.appspot.com/o/ic_launcher-web.png?alt=media&token=d0bb835d-e569-4f38-ad6e-fa0fed822cc7'),
      ),
    );
    final link = await parameters.buildUrl();
    // final ShortDynamicLink shortenedLink = await parameters.buildShortLink();
    // print("short url");
    // print(shortenedLink);
    //return shortenedLink.shortUrl;
    return link;
  }

  static Future<Uri> createQrScreenForUserApplications(
      String tokenID, String entityName) async {
    String msgTitle = entityShareByUserHeading + entityName;
    final DynamicLinkParameters parameters = DynamicLinkParameters(
      // This should match firebase but without the username query param
      uriPrefix: shareURLPrefix,
      // This can be whatever you want for the uri, https://yourapp.com/groupinvite?username=$userName
      link: Uri.parse(shareURLPrefix + '/?tokenIdentifier=$tokenID'),
      androidParameters: AndroidParameters(
          packageName: bundleId,
          minimumVersion: 1,
          fallbackUrl: Uri.parse('https://bigpiq.com/#product')),
      iosParameters: IosParameters(
        bundleId: bundleId,
        minimumVersion: '1',
        appStoreId: appStoreId,
      ),
      socialMetaTagParameters: SocialMetaTagParameters(
        title: msgTitle,
        description: entityShareMessage,
        imageUrl: Uri.parse(
            'https://firebasestorage.googleapis.com/v0/b/sukoon-india.appspot.com/o/lesss_logo_with_name.png?alt=media&token=b54e4576-54f9-4a94-99dd-c3846f712307'),
      ),
    );
    final link = await parameters.buildUrl();
    // final ShortDynamicLink shortenedLink = await parameters.buildShortLink();
    // print("short url");
    // print(shortenedLink);
    //return shortenedLink.shortUrl;
    return link;
  }

  static Future<Uri> createDynamicLinkWithParams(
      String entityId, String msgTitle) async {
    final DynamicLinkParameters parameters = DynamicLinkParameters(
      // This should match firebase but without the username query param
      uriPrefix: shareURLPrefix,
      // This can be whatever you want for the uri, https://yourapp.com/groupinvite?username=$userName

      link: Utils.isNotNullOrEmpty(entityId)
          ? Uri.parse(shareURLPrefix + '/?entityId=$entityId')
          : Uri.parse(shareURLPrefix),
      androidParameters: AndroidParameters(
          packageName: bundleId,
          minimumVersion: 1,
          fallbackUrl: Uri.parse('https://bigpiq.com/#product')),
      iosParameters: IosParameters(
        bundleId: bundleId,
        minimumVersion: '1',
        appStoreId: appStoreId,
      ),
      socialMetaTagParameters: SocialMetaTagParameters(
        title: msgTitle,
        imageUrl: Uri.parse(
            'https://firebasestorage.googleapis.com/v0/b/sukoon-india.appspot.com/o/ic_launcher-web.png?alt=media&token=d0bb835d-e569-4f38-ad6e-fa0fed822cc7'),
      ),
    );
    final link = await parameters.buildUrl();
    final ShortDynamicLink shortenedLink = await parameters.buildShortLink();
    print("short url");
    print(shortenedLink);
    //return shortenedLink.shortUrl;
    return shortenedLink.shortUrl;
  }

  static generateLinkAndShare(
      String entityId, String msgTitle, String msgBody) async {
    var dynamicLink =
        await Utils.createDynamicLinkWithParams(entityId, msgTitle);
    Share.share(
        msgBody +
            "\n" +
            Uri.https(dynamicLink.authority, dynamicLink.path).toString(),
        subject: msgTitle);
  }

  static Widget getEntityTypeImage(EntityType type, double size) {
    Widget entityImageWidget;
    IconData icon;
    String image;

    switch (type) {
      case EntityType.PLACE_TYPE_COVID19_VACCINATION_CENTER:
        icon = Icons.local_hospital;
        break;
      case EntityType.PLACE_TYPE_MALL:
        icon = Icons.business;
        break;
      case EntityType.PLACE_TYPE_SUPERMARKET:
        icon = Icons.local_convenience_store;
        break;
      case EntityType.PLACE_TYPE_APARTMENT:
        icon = Icons.location_city;
        break;
      case EntityType.PLACE_TYPE_MEDICAL_CLINIC:
        icon = Icons.local_hospital;
        break;
      case EntityType.PLACE_TYPE_PHARMACY:
        icon = Icons.local_pharmacy;
        break;
      case EntityType.PLACE_TYPE_RESTAURANT:
        icon = Icons.restaurant_menu;
        break;
      case EntityType.PLACE_TYPE_SALON:
        image = "salon.png";
        break;
      case EntityType.PLACE_TYPE_SHOP:
        icon = Icons.store;
        break;
      case EntityType.PLACE_TYPE_WORSHIP:
        image = "placeOfWorship.png";
        break;
      case EntityType.PLACE_TYPE_SCHOOL:
        icon = Icons.school;
        break;
      case EntityType.PLACE_TYPE_PRIVATE_OFFICE:
        icon = Icons.work;
        break;
      case EntityType.PLACE_TYPE_PUBLIC_OFFICE:
        icon = Icons.work;
        break;
      case EntityType.PLACE_TYPE_GYM:
        image = "gym.png";
        break;
      case EntityType.PLACE_TYPE_SPORTS:
        image = "sportsCenter.png";
        break;
      case EntityType.PLACE_TYPE_POPSHOP:
        icon = Icons.local_offer;
        break;
      case EntityType.PLACE_TYPE_BANK:
        icon = Icons.account_balance;
        break;
      case EntityType.PLACE_TYPE_HOSPITAL:
        icon = Icons.local_hospital;
        break;
      case EntityType.PLACE_TYPE_DIAGNOSTICS:
        icon = Icons.biotech;
        break;
      case EntityType.PLACE_TYPE_REALSTATE:
        icon = Icons.home_filled;
        break;
      case EntityType.PLACE_TYPE_CAR_SERVICE:
        icon = Icons.car_repair;
        break;
      case EntityType.PLACE_TYPE_BIKE_SERVICE:
        icon = Icons.directions_bike;
        break;
      case EntityType.PLACE_TYPE_PHONE_SERVICE:
        icon = Icons.mobile_off;
        break;
      case EntityType.PLACE_TYPE_OTHERS:
        icon = Icons.add_shopping_cart;
        break;
      case EntityType.PLACE_TYPE_LAPTOP_SERVICE:
        icon = Icons.laptop_mac;
        break;
      case EntityType.PLACE_TYPE_OTHERS:
        icon = Icons.add_shopping_cart;
        break;
    }

    if (icon != null)
      entityImageWidget = Icon(
        icon,
        size: size,
        color: borderColor,
      );
    else if (image != null)
      entityImageWidget = ImageIcon(
        AssetImage('assets/$image'),
        size: size,
        color: borderColor,
      );
    else
      entityImageWidget = Icon(
        Icons.shopping_cart,
        size: size,
        color: borderColor,
      );
    return entityImageWidget;
  }

  static String getEntityTypeDisplayName(EntityType type) {
    String displayName;

    switch (type) {
      case EntityType.PLACE_TYPE_COVID19_VACCINATION_CENTER:
        displayName = PLACE_TYPE_COVID19_VACCINATION_CENTER;
        break;
      case EntityType.PLACE_TYPE_MALL:
        displayName = PLACE_TYPE_MALL;
        break;
      case EntityType.PLACE_TYPE_SUPERMARKET:
        displayName = PLACE_TYPE_SUPERMARKET;
        break;
      case EntityType.PLACE_TYPE_APARTMENT:
        displayName = PLACE_TYPE_APARTMENT;
        break;
      case EntityType.PLACE_TYPE_MEDICAL_CLINIC:
        displayName = PLACE_TYPE_MEDICAL_CLINIC;
        break;
      case EntityType.PLACE_TYPE_RESTAURANT:
        displayName = PLACE_TYPE_RESTAURANT;
        break;
      case EntityType.PLACE_TYPE_SALON:
        displayName = PLACE_TYPE_SALON;
        break;
      case EntityType.PLACE_TYPE_SHOP:
        displayName = PLACE_TYPE_SHOP;
        break;
      case EntityType.PLACE_TYPE_WORSHIP:
        displayName = PLACE_TYPE_WORSHIP;
        break;
      case EntityType.PLACE_TYPE_SCHOOL:
        displayName = PLACE_TYPE_SCHOOL;
        break;
      case EntityType.PLACE_TYPE_PUBLIC_OFFICE:
        displayName = PLACE_TYPE_PUBLIC_OFFICE;
        break;
      case EntityType.PLACE_TYPE_PRIVATE_OFFICE:
        displayName = PLACE_TYPE_PRIVATE_OFFICE;
        break;
      case EntityType.PLACE_TYPE_GYM:
        displayName = PLACE_TYPE_GYM;
        break;
      case EntityType.PLACE_TYPE_SPORTS:
        displayName = PLACE_TYPE_SPORTS;
        break;
      case EntityType.PLACE_TYPE_POPSHOP:
        displayName = PLACE_TYPE_POPSHOP;
        break;
      case EntityType.PLACE_TYPE_BANK:
        displayName = PLACE_TYPE_BANK;
        break;
      case EntityType.PLACE_TYPE_HOSPITAL:
        displayName = PLACE_TYPE_HOSPITAL;
        break;
      case EntityType.PLACE_TYPE_PHARMACY:
        displayName = PLACE_TYPE_PHARMACY;
        break;
      case EntityType.PLACE_TYPE_DIAGNOSTICS:
        displayName = PLACE_TYPE_DIAGNOSTICS;
        break;
      case EntityType.PLACE_TYPE_REALSTATE:
        displayName = PLACE_TYPE_REALSTATE;
        break;
      case EntityType.PLACE_TYPE_CAR_SERVICE:
        displayName = PLACE_TYPE_CAR_SERVICE;
        break;
      case EntityType.PLACE_TYPE_BIKE_SERVICE:
        displayName = PLACE_TYPE_BIKE_SERVICE;
        break;
      case EntityType.PLACE_TYPE_PHONE_SERVICE:
        displayName = PLACE_TYPE_PHONE_SERVICE;
        break;
      case EntityType.PLACE_TYPE_LAPTOP_SERVICE:
        displayName = PLACE_TYPE_LAPTOP_SERVICE;
        break;
      case EntityType.PLACE_TYPE_OTHERS:
        displayName = PLACE_TYPE_OTHERS;
        break;
    }
    return displayName;
  }

  static void logout(BuildContext context) {
    showDialog(
        barrierDismissible: false,
        context: context,
        builder: (_) => AlertDialog(
              titlePadding: EdgeInsets.fromLTRB(10, 15, 10, 10),
              contentPadding: EdgeInsets.all(0),
              actionsPadding: EdgeInsets.all(5),
              //buttonPadding: EdgeInsets.all(0),
              title: Container(
                width: MediaQuery.of(context).size.width,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      confirmLogout,
                      style: TextStyle(
                        fontSize: 15,
                        color: Colors.blueGrey[600],
                      ),
                    ),
                    verticalSpacer,
                    // myDivider,
                  ],
                ),
              ),
              content: Container(
                width: MediaQuery.of(context).size.width,
                child: Divider(
                  color: Colors.blueGrey[400],
                  height: 1,
                  //indent: 40,
                  //endIndent: 30,
                ),
              ),

              //content: Text('This is my content'),
              actions: <Widget>[
                SizedBox(
                  height: 24,
                  child: FlatButton(
                    color: Colors.transparent,
                    splashColor: highlightColor.withOpacity(.8),
                    textColor: Colors.orange,
                    shape: RoundedRectangleBorder(
                        side: BorderSide(color: Colors.orange)),
                    child: Text('Yes'),
                    onPressed: () {
                      Utils.showMyFlushbar(
                          context,
                          Icons.info_outline,
                          Duration(
                            seconds: 3,
                          ),
                          "Logging off.. ",
                          "Hope to see you soon!!");
                      Navigator.of(context, rootNavigator: true).pop();
                      Future.delayed(Duration(seconds: 2)).then((value) {
                        GlobalState.getGlobalState().then((value) {
                          value.getAuthService().signOut(context);
                          GlobalState.clearGlobalState();
                        });
                      });
                    },
                  ),
                ),
                SizedBox(
                  height: 24,
                  child: FlatButton(
                    // elevation: 20,
                    autofocus: true,
                    focusColor: highlightColor,
                    splashColor: highlightColor,
                    color: Colors.white,
                    textColor: Colors.orange,
                    shape: RoundedRectangleBorder(
                        side: BorderSide(color: Colors.orange)),
                    child: Text('No'),
                    onPressed: () {
                      Navigator.of(context, rootNavigator: true).pop();
                      // Navigator.of(context, rootNavigator: true).pop('dialog');
                    },
                  ),
                ),
              ],
            ));
  }

  static void handleUpdateApplicationStatus(
      dynamic error, BuildContext context) {
    switch (error.runtimeType) {
      case MaxTokenReachedByUserPerDayException:
        print("max token reached");
        Utils.showMyFlushbar(context, Icons.error, Duration(seconds: 6),
            maxTokenInDayUserAdmin, maxTokenInDayUserSubAdmin);
        break;
      case MaxTokenReachedByUserPerSlotException:
        Utils.showMyFlushbar(context, Icons.error, Duration(seconds: 6),
            maxTokenInSlotUserAdmin, maxTokenInDayUserSubAdmin);
        print("max per slot reached");
        break;
      case TokenAlreadyExistsException:
        Utils.showMyFlushbar(context, Icons.error, Duration(seconds: 6),
            tokenAlreadyExistsAdmin, selectDateSub);
        print("token exists");
        break;
      case SlotFullException:
        Utils.showMyFlushbar(context, Icons.error, Duration(seconds: 6),
            slotsAlreadyBooked, selectDateSub);
        print("slot full ");
        break;
      default:
        Utils.showMyFlushbar(context, Icons.error, Duration(seconds: 5),
            error.toString(), tryAgainToBook);
        break;
    }
  }

  static Future<bool> showConfirmationDialog(
      BuildContext context, String msg) async {
    bool returnVal = await showDialog(
        barrierDismissible: false,
        context: context,
        builder: (_) => AlertDialog(
              titlePadding: EdgeInsets.fromLTRB(10, 15, 10, 10),
              contentPadding: EdgeInsets.all(0),
              actionsPadding: EdgeInsets.all(5),
              //buttonPadding: EdgeInsets.all(0),
              title: Container(
                width: MediaQuery.of(context).size.width,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      msg,
                      style: TextStyle(
                        fontSize: 15,
                        color: Colors.blueGrey[600],
                      ),
                    ),
                    verticalSpacer,
                    // myDivider,
                  ],
                ),
              ),
              content: Container(
                width: MediaQuery.of(context).size.width,
                child: Divider(
                  color: Colors.blueGrey[400],
                  height: 1,
                  //indent: 40,
                  //endIndent: 30,
                ),
              ),

              actions: <Widget>[
                SizedBox(
                  height: 24,
                  child: FlatButton(
                    color: Colors.transparent,
                    splashColor: highlightColor.withOpacity(.8),
                    textColor: Colors.orange,
                    shape: RoundedRectangleBorder(
                        side: BorderSide(color: Colors.orange)),
                    child: Text('Yes'),
                    onPressed: () {
                      Navigator.of(_).pop(true);
                    },
                  ),
                ),
                SizedBox(
                  height: 24,
                  child: FlatButton(
                    // elevation: 20,
                    autofocus: true,
                    focusColor: highlightColor,
                    splashColor: highlightColor,
                    color: Colors.white,
                    textColor: Colors.orange,
                    shape: RoundedRectangleBorder(
                        side: BorderSide(color: Colors.orange)),
                    child: Text('No'),
                    onPressed: () {
                      Navigator.of(_).pop(false);
                    },
                  ),
                ),
              ],
            ));
    return returnVal;
  }

  static Future<bool> showImagePopUp(BuildContext context, Image image) async {
    bool returnVal = await showDialog(
        barrierDismissible: false,
        context: context,
        builder: (_) => AlertDialog(
              titlePadding: EdgeInsets.fromLTRB(10, 15, 10, 10),
              contentPadding: EdgeInsets.all(0),
              actionsPadding: EdgeInsets.all(5),
              //buttonPadding: EdgeInsets.all(0),

              content: Container(
                padding: EdgeInsets.all(10),
                color: Colors.white,
                width: MediaQuery.of(context).size.width,
                child: Stack(
                  alignment: Alignment.topRight,
                  children: [
                    image,
                    IconButton(
                      alignment: Alignment.topRight,
                      padding: EdgeInsets.zero,
                      icon: Icon(Icons.cancel_outlined,
                          color: Colors.red, size: 30),
                      onPressed: () => Navigator.of(_).pop(true),
                    ),
                  ],
                ),
              ),
            ));
    return returnVal;
  }

  static stringToPascalCase(String str) {
    String newStr = str
        .replaceAll(RegExp(' +'), ' ')
        .split(" ")
        .map((str) => inCaps(str))
        .join(" ");

    return newStr;
  }

  static String inCaps(String str) {
    return str.length > 0 ? '${str[0].toUpperCase()}${str.substring(1)}' : '';
  }
}
