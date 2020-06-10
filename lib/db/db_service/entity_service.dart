import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:noq/db/db_model/entity.dart';
import 'package:noq/db/db_model/meta_entity.dart';
import 'package:noq/db/db_model/user.dart';
import 'package:noq/db/db_service/AccessDeniedException.dart';
import 'package:noq/db/db_service/EntityDoesNotExistsException.dart';

class EntityService {
  Future<bool> upsertEntity(Entity entity) async {
    Firestore fStore = Firestore.instance;
    final DocumentReference entityRef =
        fStore.document('entities/' + entity.entityId);

    DocumentSnapshot doc = await entityRef.get();

    if (doc.exists) {
      //check if the current user is admin
      Map<String, dynamic> map = doc.data;
      entity = Entity.fromJson(map);

      if (!await isEditAllowed(entity.admins)) {
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
    Firestore fStore = Firestore.instance;

    Entity ent = await getEntity(entityId);

    if (!await isEditAllowed(ent.admins)) {
      throw new AccessDeniedException("This user can't delete the Entity");
    }

    final DocumentReference entityRef = fStore.document('entities/' + entityId);
    entityRef.delete();

    return true;
  }

  Future<bool> addToParentEntity(
      String childEntityId, String parentEntityId) async {
    return false;
  }

  Future<bool> addEntityToParent(
      Entity childEntity, String parentEntityId) async {
    Firestore fStore = Firestore.instance;
    final DocumentReference entityRef =
        fStore.document('entities/' + parentEntityId);

    final DocumentReference childRef =
        fStore.document('entities/' + childEntity.entityId);

    Entity parentEntity;

    await fStore.runTransaction((Transaction tx) async {
      DocumentSnapshot parentEntityDoc = await tx.get(entityRef);

      if (parentEntityDoc.exists) {
        //check if the current user is admin
        Map<String, dynamic> map = parentEntityDoc.data;
        parentEntity = Entity.fromJson(map);

        if (!await isEditAllowed(parentEntity.admins)) {
          throw new AccessDeniedException(
              "User is not admin and can't update the entity");
        }

        bool childEntityExist = false;
        int count = -1;

        for (MetaEntity meta in parentEntity.childEntities) {
          count++;
          if (meta.entityId == childEntity.entityId) {
            childEntityExist = true;
            break;
          }
        }

        MetaEntity metaEnt = new MetaEntity(
            entityId: childEntity.entityId,
            name: childEntity.name,
            type: childEntity.type,
            advanceDays: childEntity.advanceDays,
            isPublic: childEntity.isPublic,
            closedOn: childEntity.closedOn,
            startTimeHour: childEntity.startTimeHour,
            startTimeMinute: childEntity.startTimeMinute,
            endTimeHour: childEntity.endTimeHour,
            endTimeMinute: childEntity.endTimeMinute,
            isActive: childEntity.isActive);

        if (childEntityExist) {
          parentEntity.childEntities[count] = metaEnt;
        } else {
          parentEntity.childEntities.add(metaEnt);
        }

        childEntity.parentId = parentEntityId;

        await tx.set(entityRef, parentEntity.toJson());

        await tx.set(childRef, childEntity.toJson());
      } else {
        throw new EntityDoesNotExistsException("Parent entity does not exist");
      }
    });

    return true;
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

  Future<bool> isEditAllowed(List<User> admins) async {
    final FirebaseUser user = await FirebaseAuth.instance.currentUser();
    String userId = user.uid;

    bool isEditAllowed = false;

    for (User usr in admins) {
      if (usr.firebaseId == userId) {
        isEditAllowed = true;
        break;
      }
    }

    return isEditAllowed;
  }
}
