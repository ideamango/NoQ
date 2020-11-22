import 'dart:async';
import 'dart:io' show Platform;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:noq/constants.dart';
import 'package:noq/db/db_model/entity.dart';
import 'package:noq/db/db_service/entity_service.dart';
import 'package:noq/global_state.dart';
import 'package:noq/pages/favs_list_page.dart';
import 'package:noq/repository/StoreRepository.dart';
import 'package:permission_handler/permission_handler.dart';

import 'package:noq/style.dart';

import 'package:barcode_scan/barcode_scan.dart';
import 'package:noq/utils.dart';

class QrCodeScanner {
  ScanResult scanResult;
  static Future scan(BuildContext context) async {
    ScanResult scanResult;
    try {
      scanResult = await BarcodeScanner.scan();

      if (scanResult.rawContent.contains('entityId')) {
        List<String> url = scanResult.rawContent.split('entityId');
        String entityId;
        String afterEntityId = url[1];
        int amperIndex = afterEntityId.indexOf('&');
        if (amperIndex > -1) {
          //this is to cover the Full QR code link generated on IOS
          entityId = afterEntityId.substring(3, amperIndex);
        } else {
          //this condition is for the QR code link generated from the Android
          entityId = afterEntityId.substring(3);
        }

        Utils.addEntityToFavs(context, entityId);
      } else if (scanResult.type == ResultType.Cancelled) {
        Utils.showMyFlushbar(context, Icons.info, Duration(seconds: 3),
            "QR scan is cancelled by you..", "Try again!!");
      } else {
        Utils.showMyFlushbar(context, Icons.info, Duration(seconds: 3),
            invalidQRCode, correctQRCode);
      }
    } on PlatformException catch (e) {
      var result = ScanResult(
        type: ResultType.Error,
        format: BarcodeFormat.unknown,
      );

      if (e.code == BarcodeScanner.cameraAccessDenied) {
        Utils.showMyFlushbar(context, Icons.info, Duration(seconds: 5),
            cameraAccess, openCameraAccessSetting);
        openAppSettings();
      } else {
        result.rawContent = 'Unknown error: $e';
      }

      scanResult = result;
    } catch (e) {
      Utils.showMyFlushbar(context, Icons.info, Duration(seconds: 5),
          "Something went wrong..", "Unable to process");
    }
  }

  Widget build(BuildContext context) {
    return GestureDetector(
      child: ImageIcon(
        AssetImage('assets/qrcode.png'),
        size: 25,
        color: primaryIcon,
      ),
      onTap: () {
        scan(context);
      },
    );
  }
}
