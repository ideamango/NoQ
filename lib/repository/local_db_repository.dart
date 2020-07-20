import 'dart:convert';
import 'dart:io';
import 'package:noq/global_state.dart';
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

String generateJson(GlobalState state) {
  //TODO: SMIta - null exception thrown , check
  //String json = jsonEncode(state);
  Map<String, dynamic> json = state.toJson();
  String jsonStr = jsonEncode(json);
  return jsonStr;
}

void writeData(GlobalState state) async {
  // json = jsonEncode(dummyUser);
  final file = await localFile;
  String fileData = generateJson(state);
  //print('Writing in file $file , data: $fileData');
  await file.writeAsString("$fileData");
}

Future<GlobalState> readData() async {
  try {
    final file = await localFile;
    //TODO: Exception here
    String body = await file.readAsString();
    print('Reading data: $body');
    Map<String, dynamic> json = jsonDecode(body);
    GlobalState state = GlobalState.fromJson(json);
    return state;
  } catch (e) {
    print("Couldn't read the file");
    return null;
  }
}

Future<String> deleteServiceFromDb(ChildEntityAppData str) async {
//Read current data in file
//   await readData().then((fUser) {
//     if (!Utils.isNullOrEmpty(fUser.managedEntities)) {
// //if exists then delete

//       for (int i = 0; i < fUser.managedEntities.length; i++) {
//         if (fUser.managedEntities[i].id == str.parentEntityId) {
//           fUser.managedEntities[i].childCollection.remove(str);
//         }
//       }
// //Update info in local DB
//       writeData(fUser);

//       //TODO: Update on server
//       //EntityService().upsertEntity(str);
//     }
//     return "Success";
//   });
//   return "";
}

Future<String> deleteEntityFromDb(EntityAppData str) async {
//Read current data in file
//   await readData().then((fUser) {
//     if (!Utils.isNullOrEmpty(fUser.managedEntities)) {
// //if exists then delete
//       EntityAppData delEntity;
//       fUser.managedEntities.forEach((element) {
//         if (element.id == str.id) {
//           delEntity = element;
//         }
//       });
//       fUser.managedEntities.remove(delEntity);
//       //todo: remove this line , added for testing
//       // fUser.storesAccessed.clear();
//       //todo: remove this line , added for testing
// //Update info in local DB
//       writeData(fUser);

//       //TODO: Update on server
//       //EntityService().upsertEntity(str);
//     }
//     return "Success";
//   });
//   return "";
}
