import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:noq/db/db_service/entity_service.dart';
import 'package:noq/utils.dart';
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
  //print('Writing in file $file , data: $fileData');
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

saveChildEntity(ChildEntityAppData serviceEntity) async {
  final file = await localFile;
  String entityId = serviceEntity.entityId;
//Read current data in file
  await readData().then((fUser) {
    if (Utils.isNullOrEmpty(fUser.managedEntities)) {
      for (var entity in fUser.managedEntities) {
        if (entity.id == entityId) {
          for (var child in entity.childCollection) {
            if (child.id == serviceEntity.id) {
              child = serviceEntity;

              String fileData = generateJson(fUser);
              //print('Writing in file $file , data: $fileData');
              file.writeAsString("$fileData");
            }
          }
        }
      }
    }
    return null;
  });
}

getEntity(String entityId) async {
//Read current data in file
  await readData().then((fUser) {
    if (Utils.isNullOrEmpty(fUser.managedEntities)) {
      for (var entity in fUser.managedEntities) {
        if (entity.id == entityId) return entity;
      }
      //TODO:Fetch entity from Server
      return EntityService().getEntity(entityId);
    }
    return null;
  });
}

void saveEntityDetails(EntityAppData str) async {
  final file = await localFile;
  UserAppData _userProfile;

//Read current data in file
  await readData().then((fUser) {
    _userProfile = fUser;
    if (Utils.isNullOrEmpty(_userProfile.managedEntities)) {
      _userProfile.managedEntities = new List<EntityAppData>();
    }

// Add new data and save
    _userProfile.managedEntities.add(str);

// TOICOC _userProfile. = str;

    String fileData = generateJson(_userProfile);
    //print('Writing in file $file , data: $fileData');
    file.writeAsString("$fileData");
  });
}
