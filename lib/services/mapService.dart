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

  if (await MapLauncher.isMapAvailable(MapType.google)) {
    await MapLauncher.launchMap(
      mapType: MapType.google,
      coords: coords,
      title: title,
      description: description,
    );
  } else if (Platform.isIOS) {
    //if (await MapLauncher.isMapAvailable(MapType.amap)) {
    await MapLauncher.launchMap(
      mapType: MapType.apple,
      coords: coords,
      title: title,
      description: description,
    );
    //}
  }
  //else {
  await availableMaps.first.showMarker(
    coords: coords,
    title: title,
    description: description,
  );
//}
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
