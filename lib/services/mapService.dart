import 'dart:io';

import 'package:flutter/material.dart';
import 'package:map_launcher/map_launcher.dart';
import 'package:noq/utils.dart';
import 'package:url_launcher/url_launcher.dart' as UrlLauncher;
import 'package:url_launcher/url_launcher.dart';

launchURL(String tit, String addr, double lat, double long) async {
  final title = tit;
  final description = addr;
  final coords = Coords(lat, long);
  final availableMaps = await MapLauncher.installedMaps;
  print(availableMaps);

  if (Platform.isIOS) {
    if (await MapLauncher.isMapAvailable(MapType.google)) {
      await MapLauncher.launchMap(
        mapType: MapType.google,
        coords: coords,
        title: "",
        description:
            "", //in Iphone not opening with lat,lon but instead with the name
      );
    } else if (await MapLauncher.isMapAvailable(MapType.apple)) {
      await MapLauncher.launchMap(
        mapType: MapType.apple,
        coords: coords,
        title: title,
        description: description,
      );
    } else if (await MapLauncher.isMapAvailable(MapType.amap)) {
      await MapLauncher.launchMap(
        mapType: MapType.apple,
        coords: coords,
        title: title,
        description: description,
      );
    }
  } else if (await MapLauncher.isMapAvailable(MapType.google)) {
    await MapLauncher.launchMap(
      mapType: MapType.google,
      coords: coords,
      title: title,
      description: description,
    );
  } else {
    await availableMaps.first.showMarker(
      coords: coords,
      title: title,
      description: description,
    );
  }
  print("Maps launched");
}

callPhone(String phone) async {
  String phoneStr = "tel://$phone";
  if (await UrlLauncher.canLaunch(phoneStr)) {
    await UrlLauncher.launch(phoneStr);
  } else {
    throw 'Could not launch $phoneStr';
  }
}

void launchGPay() async {
  print("inside gpay");
  //tn: Message
  //pa: UPI Payee addr
  //pn: payee name
  //cu: currency
  String url() {
    String url =
        'upi://pay?pa=sumant.srivastava@okicici&pn=PayeeName&tn=PaymentFromSukoon&cu=INR';
    return url;
  }

  if (await canLaunch(url())) {
    await launch(url());
  } else {
    throw 'Could not launch ${url()}';
  }
}

void launchWhatsApp({
  @required String phone,
  @required String message,
}) async {
  String url() {
    if (Platform.isIOS) {
      return "whatsapp://wa.me/$phone/?text=${Uri.parse(message)}";
    } else {
      return "whatsapp://send?phone=$phone&text=${Uri.parse(message)}";
    }
  }

  if (await canLaunch(url())) {
    await launch(url());
  } else {
    throw 'Could not launch ${url()}';
  }
}
// static Future<String> getIosAppId({
//     String countryCode,
//     String bundleId,
//   }) async {
//     // If bundle name is not provided
//     // then fetch and return the app ID from cache (if available)
//     if (bundleId == null) {
//       _appId ??= await getIosAppId(
//         bundleId: await getBundleName(),
//         countryCode: countryCode,
//       );

//       return _appId;
//     }

//     // Else fetch from AppStore
//     final String id = bundleId ?? (await getBundleName());
//     final String country = countryCode ?? _appCountry ?? '';
//     String appId;

//     if (id.isNotEmpty) {
//       try {
//         final result = await http
//             .get('http://itunes.apple.com/$country/lookup?bundleId=$id')
//             .timeout(const Duration(seconds: 5));
//         final Map json = jsonDecode(result.body ?? '');
//         appId = json['results'][0]['trackId']?.toString();
//       } finally {
//         if (appId?.isNotEmpty == true) {
//           print('Track ID: $appId');
//         } else {
//           print('Application with bundle $id is not found on App Store');
//         }
//       }
//     }

//     return appId ?? '';
//   }
Future<String> openRateReviewForIos({
  String appId,
  bool compose = false,
}) async {
  // final id = appId ?? (await getIosAppId()) ?? '';
  //TODO change bundle /app id
  final appId = 'com.bigbasket.mobileapp';
  final reviewUrl = 'itunes.apple.com/app/id$appId?mt=8&action=write-review';

  if (await canLaunch('itms-apps://$reviewUrl')) {
    print('launching store page');
    launch('itms-apps://$reviewUrl');
    return 'Launched App Store Directly: $reviewUrl';
  }

  launch('https://$reviewUrl');
  return 'Launched App Store: $reviewUrl';

  // try {
  //   return _channel.invokeMethod<String>('requestReview');
  // } finally {}
}

Future<String> openGooglePlay({String fallbackUrl}) async {
  //TODO change bundle /app id
  final bundle = 'com.bigbasket.mobileapp';
  //TODO  End
  final markerUrl = 'market://details?id=$bundle';

  if (await canLaunch(markerUrl)) {
    print('launching store page');
    launch(markerUrl);
    return 'Launched Google Play Directly: $bundle';
  }

  if (fallbackUrl != null) {
    launch(fallbackUrl);
    return 'Launched Google Play via $fallbackUrl';
  }

  launch('https://play.google.com/store/apps/details?id=$bundle');
  return 'Launched Google Play: $bundle';
}

void launchPlayStore({
  @required String packageName,
}) async {
  //TODO change bundle /app id
  packageName = "com.bigbasket.mobileapp";
  //TODO  End
  // final appId =  getIosAppId() ?? '';
  if (Platform.isIOS) {
    openRateReviewForIos();
    //return "https://itunes.apple.com/app/id$appId";
    //return "https://itunes.apple.com/us/app/appName/id$packageName?mt=8&action=write-review";
  } else {
    openGooglePlay();
    // return "https://play.google.com/store/apps/details?id=" + packageName;
  }

  // if (await canLaunch(url())) {
  //   await launch(url());
  // } else {
  //   throw 'Could not launch ${url()}';
  // }
}

void launchUri(String url) async {
  if (await UrlLauncher.canLaunch(url)) {
    await UrlLauncher.launch(url);
  } else {
    throw 'Could not launch $url';
  }
}
