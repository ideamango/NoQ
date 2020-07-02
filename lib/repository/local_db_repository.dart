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
  await file.writeAsString("$fileData");
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

      for (int i = 0; i < fUser.managedEntities.length; i++) {
        if (fUser.managedEntities[i].id == str.id) {
          //TODO: Update list outside loop, writeData(fuser doiesnt have updated values ISSUE ISSUE)
          fUser.managedEntities[i] = str;
          fUser.storesAccessed.add(str);
          writeData(fUser);
          return;
        }
      }
    } else {
      fUser.managedEntities = new List<EntityAppData>();
    }
    fUser.managedEntities.add(str);
    //TODO: ForTesting only - Remove later
    fUser.storesAccessed.add(str);

    //TODO: ForTesting

    writeData(fUser);
    return;

    //TODO: Update on server
    //EntityService().upsertEntity(str);
    //_userProfile.managedEntities.clear();
  });
}

Future<String> deleteServiceFromDb(ChildEntityAppData str) async {
//Read current data in file
  await readData().then((fUser) {
    if (!Utils.isNullOrEmpty(fUser.managedEntities)) {
//if exists then delete

      for (int i = 0; i < fUser.managedEntities.length; i++) {
        if (fUser.managedEntities[i].id == str.parentEntityId) {
          fUser.managedEntities[i].childCollection.remove(str);
        }
      }
//Update info in local DB
      writeData(fUser);

      //TODO: Update on server
      //EntityService().upsertEntity(str);
    }
    return "Success";
  });
  return "";
}

Future<String> deleteEntityFromDb(EntityAppData str) async {
//Read current data in file
  await readData().then((fUser) {
    if (!Utils.isNullOrEmpty(fUser.managedEntities)) {
//if exists then delete
      EntityAppData delEntity;
      fUser.managedEntities.forEach((element) {
        if (element.id == str.id) {
          delEntity = element;
        }
      });
      fUser.managedEntities.remove(delEntity);
      //todo: remove this line , added for testing
      // fUser.storesAccessed.clear();
      //todo: remove this line , added for testing
//Update info in local DB
      writeData(fUser);

      //TODO: Update on server
      //EntityService().upsertEntity(str);
    }
    return "Success";
  });
  return "";
}

saveChildEntity(ChildEntityAppData serviceEntity) async {
  String entityId = serviceEntity.parentEntityId;
//Read current data in file
  await readData().then((fUser) {
    if (!Utils.isNullOrEmpty(fUser.managedEntities)) {
      for (int i = 0; i < fUser.managedEntities.length; i++) {
        if (fUser.managedEntities[i].id == entityId) {
          if (!Utils.isNullOrEmpty(fUser.managedEntities[i].childCollection)) {
//if exists then update else add

            for (int j = 0;
                j < fUser.managedEntities[i].childCollection.length;
                j++) {
              if (fUser.managedEntities[i].childCollection[j].id ==
                  serviceEntity.id) {
                fUser.managedEntities[i].childCollection[j] = serviceEntity;
                writeData(fUser);
                return;
              }
            }
          } else {
            fUser.managedEntities[i].childCollection =
                new List<ChildEntityAppData>();
          }
          fUser.managedEntities[i].childCollection.add(serviceEntity);
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
      for (int i = 0; i < fUser.managedEntities.length; i++) {
        if (fUser.managedEntities[i].id == entityId)
          return fUser.managedEntities[i];
      }
      //TODO:Fetch entity from Server
      // return EntityService().getEntity(entityId);
    }
    return null;
  });
  return null;
}
