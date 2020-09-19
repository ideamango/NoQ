import 'dart:async';
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:flushbar/flushbar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:noq/style.dart';
import 'package:noq/widget/weekday_selector.dart';
import 'package:noq/widget/widgets.dart';

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
      Duration duration, String title, String msg) {
    Flushbar(
      padding: EdgeInsets.fromLTRB(4, 4, 4, 4),
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
        color: Colors.white,
        size: 35,
      ),
      showProgressIndicator: false,
      // progressIndicatorBackgroundColor: Colors.blueGrey[800],
      routeBlur: 1.0,
      titleText: Text(
        title,
        style: TextStyle(
            //fontWeight: FontWeight.bold,
            fontSize: 15.0,
            color: Colors.white,
            fontFamily: "Roboto"),
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

  static Future<Position> getCurrLocation() async {
    //TODO SMita = getting lost at this statement
    LocationPermission permission = await checkPermission();

    if (permission == LocationPermission.deniedForever) {
      return null;
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

  static Future<Uri> createDynamicLinkWithParams(
      {@required String entityId}) async {
    final DynamicLinkParameters parameters = DynamicLinkParameters(
      // This should match firebase but without the username query param
      uriPrefix: 'https://sukoontest2.page.link',
      // This can be whatever you want for the uri, https://yourapp.com/groupinvite?username=$userName
      link: Uri.parse('https://sukoontest2.page.link/?entityId=$entityId'),
      androidParameters: AndroidParameters(
        packageName: 'com.example.noq',
        minimumVersion: 1,
      ),
      iosParameters: IosParameters(
        bundleId: 'com.example.noq',
        minimumVersion: '1',
        appStoreId: '',
      ),
      socialMetaTagParameters: SocialMetaTagParameters(
        title: 'Check out this amazing app',
        description: 'It saves time and keeps you at safe-distance!',
      ),
    );
    final link = await parameters.buildUrl();
    final ShortDynamicLink shortenedLink = await parameters.buildShortLink();
    return shortenedLink.shortUrl;
  }

  static Future<Uri> createDynamicLink() async {
    final DynamicLinkParameters parameters = DynamicLinkParameters(
      // This should match firebase but without the username query param
      uriPrefix: 'https://sukoontest2.page.link',
      // This can be whatever you want for the uri, https://yourapp.com/groupinvite?username=$userName
      link: Uri.parse('https://sukoontest2.page.link'),
      androidParameters: AndroidParameters(
        packageName: 'com.example.noq',
        minimumVersion: 1,
      ),
      iosParameters: IosParameters(
        bundleId: 'com.example.noq',
        minimumVersion: '1',
        appStoreId: '',
      ),
      socialMetaTagParameters: SocialMetaTagParameters(
        title: 'Check out this amazing app',
        description: 'It saves time and keeps you at safe-distance!',
      ),
    );
    final link = await parameters.buildUrl();
    // final ShortDynamicLink shortenedLink = await parameters.buildShortLink();
    return link;
  }
}
