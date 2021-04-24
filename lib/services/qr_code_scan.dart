import 'dart:async';
import 'package:barcode_scan_fix/barcode_scan.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:noq/constants.dart';
import 'package:noq/utils.dart';

class QrCodeScanner {
  static Future scan(BuildContext context) async {
    String scanResult = "";
    try {
      scanResult = await BarcodeScanner.scan();

      if (scanResult.contains('entityId')) {
        List<String> url = scanResult.split('entityId');
        String entityId;
        String afterEntityId = url[1];
        int amperIndex = afterEntityId.indexOf('&');
        if (amperIndex > -1) {
          //         //this is to cover the Full QR code link generated on IOS
          entityId = afterEntityId.substring(3, amperIndex);
        } else {
          //         //this condition is for the QR code link generated from the Android
          entityId = afterEntityId.substring(3);
        }

        Utils.addEntityToFavs(context, entityId);
      } else if (scanResult.contains('tokenIdentifier')) {
        List<String> url = scanResult.split('tokenIdentifier');
        String applicationID;
        String afterapplicationID = url[1];
        //  List<String> url = afterapplicationID.split('%3A');
        afterapplicationID = afterapplicationID.replaceAll('%3A', '#');
        afterapplicationID = afterapplicationID.replaceAll('%2B', '+');

        //         //this condition is for the QR code link generated from the Android
        applicationID = afterapplicationID.substring(3);

        Utils.showApplicationDetails(context, applicationID);
      } else {
        Utils.showMyFlushbar(context, Icons.info, Duration(seconds: 3),
            invalidQRCode, correctQRCode);
      }
    } on PlatformException catch (e) {
      if (e.code == BarcodeScanner.CameraAccessDenied) {
        Utils.showMyFlushbar(context, Icons.info, Duration(seconds: 5),
            cameraAccess, openCameraAccessSetting);
        Utils.showLocationAccessDialog(context, openCameraAccessSetting);
        // print('The user did not grant the camera permission!');
        // setState(() {
        //   this.barcode = 'The user did not grant the camera permission!';
        // });
      } else {
        // setState(() => this.barcode = 'Unknown error: $e');
        print('Unknown error: $e');
        scanResult = 'Unknown error: $e';
      }
    } on FormatException {
      Utils.showMyFlushbar(context, Icons.info, Duration(seconds: 3),
          "QR scan is cancelled by you..", "Try again!!");
      // setState(() => this.barcode = 'null (User returned using the "back"-button before scanning anything. Result)');
      // print('null (User returned using the "back"-button before scanning anything. Result)');
    } catch (e) {
      Utils.showMyFlushbar(context, Icons.info, Duration(seconds: 5),
          "Something went wrong..", "Unable to process");
    }
  }
}
