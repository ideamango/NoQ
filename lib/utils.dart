import 'dart:async';
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:flushbar/flushbar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:noq/db/db_model/address.dart';
import 'package:noq/style.dart';
import 'package:noq/widget/weekday_selector.dart';
import 'package:noq/widget/widgets.dart';
import 'package:share/share.dart';

import 'constants.dart';

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
      {@required String entityId}) async {
    final DynamicLinkParameters parameters = DynamicLinkParameters(
      // This should match firebase but without the username query param
      uriPrefix: 'https://sukoontest2.page.link',
      // This can be whatever you want for the uri, https://yourapp.com/groupinvite?username=$userName
      link: Uri.parse('https://sukoontest2.page.link/?entityId=$entityId'),
      androidParameters: AndroidParameters(
          packageName: 'mobi.sukoon',
          minimumVersion: 1,
          fallbackUrl: Uri.parse('https://watcharoundyou.wordpress.com/')),
      iosParameters: IosParameters(
        bundleId: 'mobi.sukoon',
        minimumVersion: '1',
        appStoreId: '962194608',
      ),
      socialMetaTagParameters: SocialMetaTagParameters(
        title: 'Check out this amazing app',
        description: 'It saves time and helps you maintain safe-distance!',
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
      {@required String entityId}) async {
    final DynamicLinkParameters parameters = DynamicLinkParameters(
      // This should match firebase but without the username query param
      uriPrefix: 'https://sukoontest2.page.link',
      // This can be whatever you want for the uri, https://yourapp.com/groupinvite?username=$userName
      link: Uri.parse('https://sukoontest2.page.link/?entityId=$entityId'),
      androidParameters: AndroidParameters(
          packageName: 'mobi.sukoon',
          minimumVersion: 1,
          fallbackUrl: Uri.parse('https://watcharoundyou.wordpress.com/')),
      iosParameters: IosParameters(
        bundleId: 'mobi.sukoon',
        minimumVersion: '1',
        // appStoreId: '962194608',
      ),
      socialMetaTagParameters: SocialMetaTagParameters(
        title: 'Check out this amazing app',
        description: 'It saves time and helps you maintain safe-distance!',
      ),
    );
    final link = await parameters.buildUrl();
    final ShortDynamicLink shortenedLink = await parameters.buildShortLink();
    print("short url");
    print(shortenedLink);
    //return shortenedLink.shortUrl;
    return shortenedLink.shortUrl;
  }

  static Future<Uri> createDynamicLink() async {
    final DynamicLinkParameters parameters = DynamicLinkParameters(
        // This should match firebase but without the username query param
        uriPrefix: 'https://sukoontest2.page.link',
        // This can be whatever you want for the uri, https://yourapp.com/groupinvite?username=$userName
        link: Uri.parse('https://sukoontest2.page.link'),
        androidParameters: AndroidParameters(
          packageName: 'mobi.sukoon',
          minimumVersion: 1,
        ),
        iosParameters: IosParameters(
          //TODO: For testing - Smita

          bundleId: 'mobi.sukoon',
          minimumVersion: '1',
          appStoreId: '962194608',
        ),
        socialMetaTagParameters: SocialMetaTagParameters(
          title: 'Check out this amazing app',
          description: 'It saves time and keeps you at safe-distance!',
        ));
    final link = await parameters.buildUrl();
    final ShortDynamicLink shortenedLink = await parameters.buildShortLink();
    print(shortenedLink.shortUrl);
    print(link.authority);
    return shortenedLink.shortUrl;
  }

  // static Map<String, String> buildCategoryList() {
  //   Map<String, String> categoryList = new Map<String, String>();
  //   categoryList["Mall"] = "mall.png";
  //   categoryList["Super Market"] = "superMarket.png";
  //   categoryList["Apartment"] = "apartment.png";
  //   categoryList["Medical Store"] = "medicalStore.png";
  //   categoryList["Shop"] = "shop.png";
  //   categoryList["Pop Shop"] = "popShop.png";
  //   categoryList["Salon"] = "salon.png";
  //   categoryList["School"] = "school.png";
  //   categoryList["Place of Worship"] = "placeOfWorship.png";
  //   categoryList["Restaurant"] = "restaurant.png";
  //   categoryList["Sports Center"] = "sportsCenter.png";
  //   categoryList["Gym"] = "gym.png";
  //   categoryList["Office"] = "office.png";
  //   categoryList["Others"] = "others.png";
  //   categoryList["Bank"] = "bank.png";
  //   categoryList["Hospital"] = "hospital.png";
  //   return categoryList;
  // }

  static generateLinkAndShare() async {
    var dynamicLink = await Utils.createDynamicLink();
    print("Dynamic Link: $dynamicLink");
    // _dynamicLink =
    //     Uri.https(dynamicLink.authority, dynamicLink.path).toString();
    // dynamicLink has been generated. share it with others to use it accordingly.
    Share.share(Uri.https(dynamicLink.authority, dynamicLink.path).toString());
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
        color: btnColor,
      );
    else if (image != null)
      entityImageWidget = ImageIcon(
        AssetImage('assets/$image'),
        size: size,
        color: btnColor,
      );
    else
      entityImageWidget = Icon(
        Icons.shopping_cart,
        size: size,
        color: btnColor,
      );
    return entityImageWidget;
  }
}
