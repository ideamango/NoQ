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

