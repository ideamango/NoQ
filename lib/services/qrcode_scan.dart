import 'dart:async';
import 'dart:io' show Platform;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:noq/db/db_model/entity.dart';
import 'package:noq/db/db_service/entity_service.dart';
import 'package:noq/global_state.dart';
import 'package:noq/pages/favs_list_page.dart';
import 'package:noq/repository/StoreRepository.dart';

import 'package:noq/style.dart';

import 'package:barcode_scan/barcode_scan.dart';
import 'package:noq/utils.dart';

class QrCodeScanner {
  ScanResult scanResult;
  Future scan(BuildContext context) async {
    try {
      scanResult = await BarcodeScanner.scan();
      print("PRINTING scan result");
      print(scanResult.rawContent);
      List<String> url = scanResult.rawContent.split('/');
      String entityId = url[3];
      addEntityToFavs(context, entityId);
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
    print("EXITING");
  }

  void addEntityToFavs(BuildContext context, String id) async {
    Entity entity = await getEntity(id);
    GlobalState gs = await GlobalState.getGlobalState();

    bool entityContains = false;
    for (int i = 0; i < gs.currentUser.favourites.length; i++) {
      if (gs.currentUser.favourites[i].entityId == id) {
        entityContains = true;
        break;
      } else
        continue;
    }
    if (!entityContains) {
      Utils.showMyFlushbar(
          context, Icons.info, Duration(seconds: 3), "Processing...", "");
      EntityService()
          .addEntityToUserFavourite(entity.getMetaEntity())
          .then((value) {
        if (value) {
          gs.currentUser.favourites.add(entity.getMetaEntity());
        } else
          print("Entity can't be added to Favorites");
      }).catchError((onError) {
        Utils.showMyFlushbar(
            context, Icons.info, Duration(seconds: 3), "Oops error...", "");
      });
    } else {
      Utils.showMyFlushbar(context, Icons.info, Duration(seconds: 3),
          "Entity is already present in your Favourites!!", "");
    }
    Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (context) => FavsListPage()));
  }

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
      onPressed: () {
        scan(context);
      },
    );
  }
}
