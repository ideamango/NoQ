import 'dart:async';

import '../db/db_model/employee.dart';
import '../db/db_model/entity.dart';
import '../db/db_model/entity_private.dart';

import '../global_state.dart';
import '../tuple.dart';
import '../enum/entity_role.dart';

// Get list of Stores from Server

Future<bool?> upsertEntity(Entity entity, String regNum) async {
  entity.regNum = regNum;
  GlobalState? gs =
      await (GlobalState.getGlobalState() as Future<GlobalState?>);
  return await gs?.putEntity(entity, true);
}

// Future<bool> deleteEntity(String entityId) async {
//   GlobalState gs = await GlobalState.getGlobalState();
//   return await gs.removeEntity(entityId);
// }

Future<Tuple<Entity, bool>?> getEntity(String entityId) async {
  GlobalState gs =
      await (GlobalState.getGlobalState() as FutureOr<GlobalState>);
  return await gs.getEntity(entityId);
}

Future<bool> assignAdminsFromList(
    String? entityId, List<String> adminsList) async {
  //TODO Smita - Get all admins and check which entries already exists in DB
  // Add rest of admins then
  GlobalState? gs = await GlobalState.getGlobalState();
  try {
    for (int i = 0; i < adminsList.length; i++) {
      Employee emp = new Employee();
      emp.ph = adminsList[i];
      await gs!
          .getEntityService()!
          .upsertEmployee(entityId!, emp, EntityRole.Admin);
    }
  } catch (e) {
    print(e);
    return false;
  }

  return true;
}

Future<EntityPrivate?> fetchAdmins(String entityId) async {
  GlobalState? gs = await GlobalState.getGlobalState();
  EntityPrivate? entityPrivateList =
      await gs?.getEntityService()!.getEntityPrivate(entityId);

  return entityPrivateList;
}

Future<bool> removeAdmin(String? entityId, String? phone) async {
  GlobalState? gs = await GlobalState.getGlobalState();
  bool? status = await gs?.removeEmployee(entityId, phone);
  return status ?? false;
}

Future<String?> fetchRegNum(String entityId) async {
  String? regNum;
  GlobalState gs = await (GlobalState.getGlobalState() as Future<GlobalState>);
  EntityPrivate? entityPrivateList =
      await gs.getEntityService()!.getEntityPrivate(entityId);
  if (entityPrivateList != null) {
    regNum = entityPrivateList.registrationNumber;
  }
  return regNum;
}
