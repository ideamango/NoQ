import 'package:noq/db/db_model/entity.dart';
import 'package:noq/db/db_service/entity_service.dart';

// Get list of Stores from Server

Future<bool> upsertEntity(Entity entity, String regNum) async {
  bool status = await EntityService().upsertEntity(entity, regNum);
  return status;
}

Future<bool> deleteEntity(String entityId) async {
  bool status = await EntityService().deleteEntity(entityId);
  return status;
}

Future<Entity> getEntity(String metaEntityId) async {
  Entity entity = await EntityService().getEntity(metaEntityId);
  return entity;
}

Entity createEntity(String entityId, String entityType) {
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
