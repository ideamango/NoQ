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

void saveEntityDetails(EntityAppData str) async {
//Read current data in file
  await readData().then((fUser) {
    if (!Utils.isNullOrEmpty(fUser.managedEntities)) {
//if exists then update else add

      for (var element in fUser.managedEntities) {
        if (element.id == str.id) {
          element = str;
          writeData(fUser);
          return;
        }
      }
    } else {
      fUser.managedEntities = new List<EntityAppData>();
    }
    fUser.managedEntities.add(str);
    writeData(fUser);
    return;

    //TODO: Update on server
    //EntityService().upsertEntity(str);
    //_userProfile.managedEntities.clear();
  });
}

void deleteServiceFromDb(ChildEntityAppData str) async {
//Read current data in file
  await readData().then((fUser) {
    if (!Utils.isNullOrEmpty(fUser.managedEntities)) {
//if exists then delete

      for (var managedEntity in fUser.managedEntities) {
        if (managedEntity.id == str.parentEntityId) {
          managedEntity.childCollection.remove(str);
        }
      }
//Update info in local DB
      writeData(fUser);

      //TODO: Update on server
      //EntityService().upsertEntity(str);
    }
  });
}

void deleteEntityFromDb(EntityAppData str) async {
//Read current data in file
  await readData().then((fUser) {
    if (!Utils.isNullOrEmpty(fUser.managedEntities)) {
//if exists then delete

      fUser.managedEntities.forEach((element) {
        if (element.id == str.id) {
          fUser.managedEntities.remove(element);
        }
      });
//Update info in local DB
      writeData(fUser);

      //TODO: Update on server
      //EntityService().upsertEntity(str);
    }
  });
}

saveChildEntity(ChildEntityAppData serviceEntity) async {
  String entityId = serviceEntity.parentEntityId;
//Read current data in file
  await readData().then((fUser) {
    if (!Utils.isNullOrEmpty(fUser.managedEntities)) {
      for (var entity in fUser.managedEntities) {
        if (entity.id == entityId) {
          if (!Utils.isNullOrEmpty(entity.childCollection)) {
//if exists then update else add

            for (var element in entity.childCollection) {
              if (element.id == serviceEntity.id) {
                element = serviceEntity;
                writeData(fUser);
                return;
              }
            }
          } else {
            entity.childCollection = new List<ChildEntityAppData>();
          }
          entity.childCollection.add(serviceEntity);
          writeData(fUser);
          return;

          //print('Writing in file $file , data: $fileData');

          //TODO: Update on server
          //EntityService().upsertEntity(str);
        }
      }
    }
  });
}

Future<List<EntityAppData>> getEntityList() async {
  await readData().then((fUser) {
    if (Utils.isNullOrEmpty(fUser.managedEntities))
      return null;
    else {
      fUser.managedEntities.clear();
      writeData(fUser);

      return fUser.managedEntities;
    }
  });
}

Future<EntityAppData> getEntity(String entityId) async {
//Read current data in file
  await readData().then((fUser) {
    if (!Utils.isNullOrEmpty(fUser.managedEntities)) {
      for (var entity in fUser.managedEntities) {
        if (entity.id == entityId) return entity;
      }
      //TODO:Fetch entity from Server
      // return EntityService().getEntity(entityId);
    }
    return null;
  });
  return null;
}
