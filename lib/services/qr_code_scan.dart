import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:noq/constants.dart';

import 'package:noq/style.dart';

//import 'package:barcode_scan/barcode_scan.dart';
import 'package:noq/utils.dart';

class QrCodeScanner {
  String _scanBarcode = 'Unknown';
  static Future<void> scan(BuildContext context) async {
    String scanResult;

    // Platform messages may fail, so we use a try/catch PlatformException.
    try {
      scanResult = await FlutterBarcodeScanner.scanBarcode(
          "#ff6666", "Cancel", true, ScanMode.QR);
      print("scan Result " + scanResult);

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
      } else if (scanResult == '-1') {
        Utils.showMyFlushbar(context, Icons.info, Duration(seconds: 3),
            "QR scan is cancelled by you..", "Try again!!");
      } else {
        Utils.showMyFlushbar(context, Icons.info, Duration(seconds: 3),
            invalidQRCode, correctQRCode);
      }
    } on Exception catch (e) {
      Utils.showMyFlushbar(context, Icons.info, Duration(seconds: 5),
          "Something went wrong..", "Unable to process");
    }
  }

  // If the widget was removed from the tree while the asynchronous platform
  // message was in flight, we want to discard the reply rather than calling
  // setState to update our non-existent appearance.
  // if (!mounted) return;

  // setState(() {
  //   _scanBarcode = barcodeScanRes;
  // });
}
// static Future scan(BuildContext context) async {
//   String scanResult = "";
//   try {
//     scanResult = await BarcodeScanner.scan();

//     if (scanResult.contains('entityId')) {
//       List<String> url = scanResult.split('entityId');
//       String entityId;
//       String afterEntityId = url[1];
//       int amperIndex = afterEntityId.indexOf('&');
//       if (amperIndex > -1) {
//         //         //this is to cover the Full QR code link generated on IOS
//         entityId = afterEntityId.substring(3, amperIndex);
//       } else {
//         //         //this condition is for the QR code link generated from the Android
//         entityId = afterEntityId.substring(3);
//       }

//       Utils.addEntityToFavs(context, entityId);
//     } else {
//       Utils.showMyFlushbar(context, Icons.info, Duration(seconds: 3),
//           invalidQRCode, correctQRCode);
//     }
//   } on PlatformException catch (e) {
//     if (e.code == BarcodeScanner.CameraAccessDenied) {
//       Utils.showMyFlushbar(context, Icons.info, Duration(seconds: 5),
//           cameraAccess, openCameraAccessSetting);
//       Utils.showLocationAccessDialog(context, openCameraAccessSetting);
//       // print('The user did not grant the camera permission!');
//       // setState(() {
//       //   this.barcode = 'The user did not grant the camera permission!';
//       // });
//     } else {
//       // setState(() => this.barcode = 'Unknown error: $e');
//       print('Unknown error: $e');
//       scanResult = 'Unknown error: $e';
//     }
//   } on FormatException {
//     Utils.showMyFlushbar(context, Icons.info, Duration(seconds: 3),
//         "QR scan is cancelled by you..", "Try again!!");
//     // setState(() => this.barcode = 'null (User returned using the "back"-button before scanning anything. Result)');
//     // print('null (User returned using the "back"-button before scanning anything. Result)');
//   } catch (e) {
//     Utils.showMyFlushbar(context, Icons.info, Duration(seconds: 5),
//         "Something went wrong..", "Unable to process");
//   }
// }
// }

Widget build(BuildContext context) {
  return GestureDetector(
    child: ImageIcon(
      AssetImage('assets/qrcode.png'),
      size: 25,
      color: primaryIcon,
    ),
    onTap: () {
      // scan(context);
    },
  );
}
