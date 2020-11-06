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

import 'package:noq/style.dart';

import 'package:barcode_scan/barcode_scan.dart';
import 'package:noq/utils.dart';

class QrCodeScanner {
  ScanResult scanResult;
  static Future scan(BuildContext context) async {
    ScanResult scanResult;
    try {
      scanResult = await BarcodeScanner.scan();
      print("PRINTING scan result");
      print(scanResult.rawContent);
      if (scanResult.rawContent.contains('entityId')) {
        List<String> url = scanResult.rawContent.split('entityId');
        String entityId = url[1];

        addEntityToFavs(context, entityId.substring(3));
      }

      Utils.showMyFlushbar(context, Icons.info, Duration(seconds: 3),
          invalidQRCode, correctQRCode);

      // launchUri(scanResult.rawContent);

      // final UriData uriDatalink = UriData.fromString(scanResult.rawContent);
      // print(uriDatalink.parameters);
      // print("Deep link path ");
      // print(uriDatalink.parameters.containsKey("entityId"));
      //   print(deepLink.path);
      // if (deepLink.queryParameters.containsKey("entityId")) {
      //   print("QueryParams ${deepLink.queryParameters}");
      // }
      // List<String> url = scanResult.rawContent.split('/');
      // String entityId = url[3];
      // addEntityToFavs(context, entityId);
    } on PlatformException catch (e) {
      var result = ScanResult(
        type: ResultType.Error,
        format: BarcodeFormat.unknown,
      );

      if (e.code == BarcodeScanner.cameraAccessDenied) {
        Utils.showMyFlushbar(context, Icons.info, Duration(seconds: 5),
            cameraAccess, openCameraAccessSetting);
      } else {
        result.rawContent = 'Unknown error: $e';
      }

      scanResult = result;
    }
    print("EXITING");
  }

  static void addEntityToFavs(BuildContext context, String id) async {
    Entity entity = await getEntity(id);
    if (entity != null) {
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
            Navigator.pushReplacement(context,
                MaterialPageRoute(builder: (context) => FavsListPage()));
          } else
            print("Entity can't be added to Favorites");
        }).catchError((onError) {
          Utils.showMyFlushbar(
              context, Icons.info, Duration(seconds: 3), "Oops error...", "");
        });
      } else {
        Utils.showMyFlushbar(
            context, Icons.info, Duration(seconds: 3), entityAlreadyInFav, "");
      }
    } else {
      Utils.showMyFlushbar(
          context, Icons.info, Duration(seconds: 3), "Oops error...", "");
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
