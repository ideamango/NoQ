import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'dart:async';
import 'package:path_provider/path_provider.dart';
import 'package:noq/models/localDB.dart';

Future<String> get localPath async {
  final directory = await getApplicationDocumentsDirectory();
  return directory.path;
}

Future<File> get localFile async {
  final path = await localPath;
  return File('$path/noq_db.txt');
}

String generateJson(UserAppData user) {
  String json = jsonEncode(user);
  return json;
}

void writeData(UserAppData user) async {
  // json = jsonEncode(dummyUser);
  final file = await localFile;
  String fileData = generateJson(user);
  print('Writing in file $file , data: $fileData');
  file.writeAsString("$fileData");
}

Future<UserAppData> readData() async {
  try {
    final file = await localFile;
    String body = await file.readAsString();
    print('Reading data: $body');
    Map<String, dynamic> json = jsonDecode(body);
    UserAppData user = UserAppData.fromJson(json);
    return user;
  } catch (e) {
    print("Couldn't read file");
    return null;
  }
}

// Future<List<StoreAppData>> getFavStoresList() async {
//   await readData().then((fUserProfile) {
//     if (fUserProfile.favStores != null) {
//       if (fUserProfile.favStores.length != 0) {
//         List<StoreAppData> _stores = fUserProfile.favStores;
//         return _stores;
//       }
//     } else
//       return null;
//   });
//   return null;
// }
