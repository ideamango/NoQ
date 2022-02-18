import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:map_launcher/map_launcher.dart';
import '../utils.dart';
import 'package:package_info/package_info.dart';
import 'package:url_launcher/url_launcher.dart' as UrlLauncher;
import 'package:url_launcher/url_launcher.dart';
import 'package:http/http.dart' as http;

launchURL(String? title, String? addr, double lat, double long) async {
  final description = addr;
  final coords = Coords(lat, long);
  final availableMaps = await MapLauncher.installedMaps;
  print(availableMaps);

  if (Platform.isIOS) {
    if (await (MapLauncher.isMapAvailable(MapType.google) as FutureOr<bool>)) {
      await MapLauncher.launchMap(
        mapType: MapType.google,
        coords: coords,
        title: title!,
        description:
            "", //in Iphone not opening with lat,lon but instead with the name
      );
    } else if (await (MapLauncher.isMapAvailable(MapType.apple) as FutureOr<bool>)) {
      await MapLauncher.launchMap(
        mapType: MapType.apple,
        coords: coords,
        title: title!,
        description: description,
      );
    } else if (await (MapLauncher.isMapAvailable(MapType.amap) as FutureOr<bool>)) {
      await MapLauncher.launchMap(
        mapType: MapType.apple,
        coords: coords,
        title: title!,
        description: description,
      );
    }
  } else if (await (MapLauncher.isMapAvailable(MapType.google) as FutureOr<bool>)) {
    await MapLauncher.launchMap(
      mapType: MapType.google,
      coords: coords,
      title: title!,
      description: description,
    );
  } else {
    await availableMaps.first.showMarker(
      coords: coords,
      title: title!,
      description: description,
    );
  }
  print("Maps launched");
}

Future<bool> launchMail(String? toMailId, String subject, String body) async {
  var url = 'mailto:$toMailId?subject=$subject&body=$body';
  if (await canLaunch(url)) {
    launch(url).then((value) {
      return true;
    });
    print("Mail sent");
  } else {
    //throw 'Could not launch $url';
    return false;
  }
}

callPhone(String? phone) async {
  String phoneStr = "tel://$phone";
  if (await UrlLauncher.canLaunch(phoneStr)) {
    await UrlLauncher.launch(phoneStr);
  } else {
    throw 'Could not launch $phoneStr';
  }
}

void launchWhatsApp({
  required String? phone,
  required String message,
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
Future<String> openRateReviewForIos(String? appId, bool forReview) async {
  String reviewUrl;
  if (forReview)
    reviewUrl = 'itunes.apple.com/app/id$appId?mt=8&action=write-review';
  else {
    reviewUrl = 'itunes.apple.com/app/id$appId';
  }

  if (await canLaunch('itms-apps://$reviewUrl')) {
    print('launching store page');
    launch('itms-apps://$reviewUrl');
    return 'Launched App Store Directly: $reviewUrl';
  }

  launch('https://$reviewUrl');
  return 'Launched App Store: $reviewUrl';

//return "https://itunes.apple.com/app/id$appId";
  //return "https://itunes.apple.com/us/app/appName/id$packageName?mt=8&action=write-review";
  // try {
  //   return _channel.invokeMethod<String>('requestReview');
  // } finally {}
}

PackageInfo? _packageInfo;
String? _appCountry;
String? _appBundle;
String? _appId;
Future<String?> getIosAppId({
  String? countryCode,
  String? bundleId,
}) async {
  // If bundle name is not provided
  // then fetch and return the app ID from cache (if available)
  if (bundleId == null) {
    _appId ??= await getIosAppId(
      bundleId: await getBundleName(),
      countryCode: countryCode,
    );

    return _appId;
  }

  // Else fetch from AppStore
  final String id = bundleId ?? (await (getBundleName() as FutureOr<String>));
  final String country = countryCode ?? _appCountry ?? '';
  String? appId;

  if (id.isNotEmpty) {
    try {
      String strUlr = 'http://itunes.apple.com/$country/lookup?bundleId=$id';
      Uri uri = Uri.parse(strUlr);
      final result = await http.get(uri).timeout(const Duration(seconds: 5));
      final Map json = jsonDecode(result.body ?? '');
      appId = json['results'][0]['trackId']?.toString();
    } finally {
      if (appId?.isNotEmpty == true) {
        print('Track ID: $appId');
      } else {
        print('Application with bundle $id is not found on App Store');
      }
    }
  }

  return appId ?? '';
}

Future<String> openGooglePlay(String? bundle) async {
  final markerUrl = 'market://details?id=$bundle';
  if (await canLaunch(markerUrl)) {
    print('launching store page');
    launch(markerUrl);
    return 'Launched Google Play Directly: $bundle';
  }

  // if (fallbackUrl != null) {
  //   launch(fallbackUrl);
  //   return 'Launched Google Play via $fallbackUrl';
  // }

  launch('https://play.google.com/store/apps/details?id=$bundle');
  return 'Launched Google Play: $bundle';
}

void launchPlayStore(
    {String? packageName, String? iOSAppId, bool? forReview}) async {
  //TODO change bundle /app id
  //packageName = "com.bigbasket.mobileapp";
  //app id for google photos
  //final appId = '962194608';
  //TODO  End
  // final appId =  getIosAppId() ?? '';
  if (Platform.isIOS) {
    openRateReviewForIos(iOSAppId, forReview!);
  } else if (Platform.isAndroid) {
    openGooglePlay(packageName);
    // return "https://play.google.com/store/apps/details?id=" + packageName;
  }

  // if (await canLaunch(url())) {
  //   await launch(url());
  // } else {
  //   throw 'Could not launch ${url()}';
  // }
}

Future<PackageInfo?> getPackageInfo() async {
  _packageInfo ??= await PackageInfo.fromPlatform();

  print('App Name: ${_packageInfo!.appName}\n'
      'Package Name: ${_packageInfo!.packageName}\n'
      'Version: ${_packageInfo!.version}\n'
      'Build Number: ${_packageInfo!.buildNumber}');

  return _packageInfo;
}

/// Get app bundle name

Future<String?> getBundleName() async {
  _appBundle ??= (await getPackageInfo())?.packageName ?? '';
  return _appBundle;
}

void launchUri(String url) async {
  if (await UrlLauncher.canLaunch(url)) {
    await UrlLauncher.launch(url);
  } else {
    throw 'Could not launch $url';
  }
}
