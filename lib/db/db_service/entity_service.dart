import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:noq/db/db_model/entity.dart';
import 'package:noq/db/db_model/user.dart';
import 'package:noq/db/db_service/AccessDeniedException.dart';

class EntityService {
  Future<bool> upsertEntity(Entity entity) async {
    final FirebaseUser user = await FirebaseAuth.instance.currentUser();
    Firestore fStore = Firestore.instance;
    String userId = user.uid;

    final DocumentReference entityRef =
        fStore.document('entities/' + entity.entityId);

    DocumentSnapshot doc = await entityRef.get();

    if (doc.exists) {
      //check if the current user is admin
      Map<String, dynamic> map = doc.data;
      entity = Entity.fromJson(map);

      bool accessAllowed = false;

      for (User usr in entity.admins) {
        if (usr.firebaseId == userId) {
          accessAllowed = true;
          break;
        }
      }

      if (!accessAllowed) {
        throw new AccessDeniedException(
            "User is not admin and can't update the entity");
      }
    }

    await entityRef.setData(entity.toJson(), merge: false);

    return true;
  }

  Future<Entity> getEntity(String entityId) async {
    Firestore fStore = Firestore.instance;
    Entity entity;

    final DocumentReference entityRef = fStore.document('entities/' + entityId);

    DocumentSnapshot doc = await entityRef.get();

    if (doc.exists) {
      Map<String, dynamic> map = doc.data;
      entity = Entity.fromJson(map);
    }

    return entity;
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
