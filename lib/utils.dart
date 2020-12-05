import 'dart:async';
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:flushbar/flushbar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:noq/db/db_model/address.dart';
import 'package:noq/enum/EntityTypes.dart';
import 'package:noq/global_state.dart';
import 'package:noq/pages/favs_list_page.dart';
import 'package:noq/services/auth_service.dart';
import 'package:noq/style.dart';
import 'package:noq/widget/weekday_selector.dart';
import 'package:noq/widget/widgets.dart';
import 'package:share/share.dart';
import 'package:uuid/uuid.dart';

import 'constants.dart';
import 'db/db_model/entity.dart';

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
      [Color color = Colors.white, bool showFlushBar = false]) {
    Animation<Color> animationColor =
        AlwaysStoppedAnimation<Color>(Color(0xFF00ACC1));
    Flushbar(
      padding: EdgeInsets.fromLTRB(4, 8, 8, 4),
      margin: EdgeInsets.zero,
      flushbarPosition: FlushbarPosition.BOTTOM,
      flushbarStyle: FlushbarStyle.FLOATING,
      reverseAnimationCurve: Curves.decelerate,
      forwardAnimationCurve: Curves.easeInToLinear,
      backgroundColor: highlightColor,
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
        color: color,
        size: 35,
      ),
      showProgressIndicator: showFlushBar,
      progressIndicatorBackgroundColor: highlightColor,
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

  static Entity createEntity(String entityType, [String parentId]) {
    var uuid = new Uuid();
    String entityId = uuid.v1();
    var isPublic = true;
    var isBookable = true;
    if (entityType == EntityTypes.Mall) {
      //is Public and Not bookable
      isPublic = true;
      isBookable = false;
    } else if (entityType == EntityTypes.Apartment ||
        entityType == EntityTypes.School ||
        entityType == EntityTypes.Office) {
      // is Private and Not bookable
      isPublic = false;
      isBookable = false;
    } else {
      // is public and bookable
      isPublic = true;
      isBookable = true;
    }

    Entity entity = new Entity(
        entityId: entityId,
        name: null,
        address: null,
        advanceDays: null,
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
        offer: null);

    return entity;
  }

  static Future<Position> getCurrLocation() async {
    //TODO SMita = getting lost at this statement
    LocationPermission permission = await checkPermission();

    if (permission == LocationPermission.deniedForever) {
      throw Exception("LocAccessDeniedForever");
    }

    // if (permission == LocationPermission.denied) {
    //   permission = await requestPermission();
    // }

    Position pos;
    try {
      pos = await getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
    } catch (e) {
      print(e);
    }
    return pos;
  }

  static Future<void> openAppSettings() async {
    bool locSettingsOpen = await openLocationSettings();
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
          fallbackUrl: Uri.parse('https://watcharoundyou.wordpress.com/')),
      iosParameters: IosParameters(
        bundleId: bundleId,
        minimumVersion: '1',
        appStoreId: appStoreId,
      ),
      socialMetaTagParameters: SocialMetaTagParameters(
        title: msgTitle,
        description: entityShareMessage,
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
          fallbackUrl: Uri.parse('https://watcharoundyou.wordpress.com/')),
      iosParameters: IosParameters(
        bundleId: bundleId,
        minimumVersion: '1',
        appStoreId: appStoreId,
      ),
      socialMetaTagParameters: SocialMetaTagParameters(
        title: msgTitle,
        imageUrl: Uri.parse(
            "https://firebasestorage.googleapis.com/v0/b/awesomenoq.appspot.com/o/logo_icon.png?alt=media&token=d0bb835d-e569-4f38-ad6e-fa0fed822cc7"),
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

  static Widget getEntityTypeImage(String type, double size) {
    Widget entityImageWidget;
    IconData icon;
    String image;

    switch (type) {
      case PLACE_TYPE_MALL:
        icon = Icons.business;
        break;
      case PLACE_TYPE_SUPERMARKET:
        icon = Icons.local_convenience_store;
        break;
      case PLACE_TYPE_APARTMENT:
        icon = Icons.location_city;
        break;
      case PLACE_TYPE_MEDICAL:
        icon = Icons.local_pharmacy;
        break;
      case PLACE_TYPE_RESTAURANT:
        icon = Icons.restaurant_menu;
        break;
      case PLACE_TYPE_SALON:
        image = "salon.png";
        break;
      case PLACE_TYPE_SHOP:
        icon = Icons.store;
        break;
      case PLACE_TYPE_WORSHIP:
        image = "placeOfWorship.png";
        break;
      case PLACE_TYPE_SCHOOL:
        icon = Icons.school;
        break;
      case PLACE_TYPE_OFFICE:
        icon = Icons.work;
        break;
      case PLACE_TYPE_GYM:
        image = "gym.png";
        break;
      case PLACE_TYPE_SPORTS:
        image = "sportsCenter.png";
        break;
      case PLACE_TYPE_POPSHOP:
        icon = Icons.local_offer;
        break;
      case PLACE_TYPE_BANK:
        icon = Icons.account_balance;
        break;
      case PLACE_TYPE_HOSPITAL:
        icon = Icons.local_hospital;
        break;
      case PLACE_TYPE_OTHERS:
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
                        AuthService().signOut(context);
                        GlobalState.clearGlobalState();
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
}
