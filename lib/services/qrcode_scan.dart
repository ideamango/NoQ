import 'dart:async';
import 'dart:io' show Platform;

import 'package:barcode_scan/barcode_scan.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:noq/style.dart';

class QrCodeScanner {
  ScanResult scanResult;

  Widget build(BuildContext context) {
    return RaisedButton(
      padding: EdgeInsets.all(1),
      autofocus: false,
      clipBehavior: Clip.none,
      elevation: 20,
      color: highlightColor,
      child: Row(
        children: <Widget>[
          Text('Scan QR', style: buttonSmlTextStyle),
          SizedBox(width: 5),
          Icon(
            Icons.camera,
            color: primaryIcon,
            size: 26,
          ),
        ],
      ),
      onPressed: scan,
    );
  }

  Future scan() async {
    try {
      scanResult = await BarcodeScanner.scan();
    } on PlatformException catch (e) {
      var result = ScanResult(
        type: ResultType.Error,
        format: BarcodeFormat.unknown,
      );

      if (e.code == BarcodeScanner.cameraAccessDenied) {
        result.rawContent = 'The user did not grant the camera permission!';
      } else {
        result.rawContent = 'Unknown error: $e';
      }

      scanResult = result;
    }
  }
}
