import 'package:noq/db/db_model/entity.dart';
import 'package:noq/db/db_model/entity_private.dart';
import 'package:noq/db/db_service/entity_service.dart';
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
  return await gs.deleteEntity(entityId);
}

Future<Tuple<Entity, bool>> getEntity(String entityId) async {
  GlobalState gs = await GlobalState.getGlobalState();
  return await gs.getEntity(entityId);
}

Future<Entity> createEntity(String entityId, String entityType) async {
  Entity entity = new Entity(
      entityId: entityId,
      name: null,
      address: null,
      advanceDays: null,
      isPublic: false,
      //geo: geoPoint,
      maxAllowed: null,
      slotDuration: null,
      closedOn: [],
      breakStartHour: null,
      breakStartMinute: null,
      breakEndHour: null,
      breakEndMinute: null,
      startTimeHour: null,
      startTimeMinute: null,
      endTimeHour: null,
      endTimeMinute: null,
      parentId: null,
      type: entityType,
      isBookable: false,
      isActive: false,
      coordinates: null);

  GlobalState gs = await GlobalState.getGlobalState();
  await gs.putEntity(entity, false);

  return entity;
}

Future<bool> assignAdminsFromList(
    String entityId, List<String> adminsList) async {
  //TODO Smita - Get all admins and check which entries already exists in DB
  // Add rest of admins then
  try {
    for (int i = 0; i < adminsList.length; i++) {
      await EntityService().assignAdmin(entityId, adminsList[i]);
    }
  } catch (e) {
    print(e);
    return false;
  }

  return true;
}

Future<EntityPrivate> fetchAdmins(String entityId) async {
  EntityPrivate entityPrivateList =
      await EntityService().getEntityPrivate(entityId);

  return entityPrivateList;
}

Future<bool> removeAdmin(String entityId, String phone) async {
  bool status = await EntityService().removeAdmin(entityId, phone);
  return status;
}

Future<String> fetchRegNum(String entityId) async {
  String regNum;

  EntityPrivate entityPrivateList =
      await EntityService().getEntityPrivate(entityId);
  if (entityPrivateList != null) {
    regNum = entityPrivateList.registrationNumber;
  }
  return regNum;
}
