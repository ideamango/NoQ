import 'package:noq/db/db_model/employee.dart';
import 'package:noq/db/db_model/entity.dart';
import 'package:noq/db/db_model/entity_private.dart';
import 'package:noq/db/db_service/entity_service.dart';
import 'package:noq/enum/entity_type.dart';
import 'package:noq/global_state.dart';
import 'package:noq/tuple.dart';
import 'package:noq/utils.dart';

// Get list of Stores from Server

Future<bool> upsertEntity(Entity entity, String regNum) async {
  entity.regNum = regNum;
  GlobalState gs = await GlobalState.getGlobalState();
  return await gs.putEntity(entity, true);
}

Future<bool> deleteEntity(String entityId) async {
  GlobalState gs = await GlobalState.getGlobalState();
  return await gs.removeEntity(entityId);
}

Future<Tuple<Entity, bool>> getEntity(String entityId) async {
  GlobalState gs = await GlobalState.getGlobalState();
  return await gs.getEntity(entityId);
}

Future<bool> assignAdminsFromList(
    String entityId, List<String> adminsList) async {
  //TODO Smita - Get all admins and check which entries already exists in DB
  // Add rest of admins then
  GlobalState gs = await GlobalState.getGlobalState();
  try {
    for (int i = 0; i < adminsList.length; i++) {
      Employee emp = new Employee();
      emp.ph = adminsList[i];
      await gs
          .getEntityService()
          .addEmployee(entityId, emp, EntityRole.ENTITY_ADMIN);
    }
  } catch (e) {
    print(e);
    return false;
  }

  return true;
}

Future<EntityPrivate> fetchAdmins(String entityId) async {
  GlobalState gs = await GlobalState.getGlobalState();
  EntityPrivate entityPrivateList =
      await gs.getEntityService().getEntityPrivate(entityId);

  return entityPrivateList;
}

Future<bool> removeAdmin(String entityId, String phone) async {
  GlobalState gs = await GlobalState.getGlobalState();
  bool status = await gs.getEntityService().removeEmployee(entityId, phone);
  return status;
}

Future<String> fetchRegNum(String entityId) async {
  String regNum;
  GlobalState gs = await GlobalState.getGlobalState();
  EntityPrivate entityPrivateList =
      await gs.getEntityService().getEntityPrivate(entityId);
  if (entityPrivateList != null) {
    regNum = entityPrivateList.registrationNumber;
  }
  return regNum;
}
