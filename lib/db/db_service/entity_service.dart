import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:noq/db/db_model/entity.dart';

class EntityService {
  Future<bool> upsertEntity(Entity entity) async {
    return false;
  }

  Future<Entity> getEntity(String entityId) async {
    Firestore _firestore = Firestore.instance;
    Entity e;

    final DocumentReference entityRef =
        _firestore.document('entities/' + entityId);

    DocumentSnapshot doc = await entityRef.get();

    if (doc.exists) {
      Map<String, dynamic> map = doc.data;

      e = Entity.fromJson(map);
    }

    return e;
  }

  Future<bool> deleteEntity(String entityId) async {
    return false;
  }

  Future<bool> addToParentEntity(
      String childEntityId, String parentEntityId) async {
    return false;
  }

  Future<bool> addEntityToParent(
      Entity childEntity, String parentEntityId) async {
    return false;
  }

  Future<bool> assignAdmin(
    String entityId,
    String phone,
    String firstName,
    String lastName,
  ) async {
    return false;
  }

  Future<bool> removeAdmin(String entityId, String phone) async {
    return false;
  }

  Future<List<Entity>> searchByName(
      String name, double lat, double lon, int distance, int pageSize) async {
    List<Entity> entities = new List<Entity>();
    return entities;
  }

  Future<List<Entity>> searchByType(
      String type, double lat, double lon, int distance, pageSize) async {
    List<Entity> entities = new List<Entity>();
    return entities;
  }
}
