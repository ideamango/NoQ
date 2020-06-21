import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:geoflutterfire/geoflutterfire.dart';
import 'package:noq/db/db_model/entity.dart';
import 'package:noq/db/db_model/meta_entity.dart';
import 'package:noq/db/db_model/meta_user.dart';
import 'package:noq/db/db_model/user.dart';
import 'package:noq/db/db_service/access_denied_exception.dart';
import 'package:noq/db/db_service/entity_does_not_exists_exception.dart';

import 'user_does_not_exists_exception.dart';

class EntityService {
  Future<bool> upsertEntity(Entity entity) async {
    final FirebaseUser fireUser = await FirebaseAuth.instance.currentUser();

    Firestore fStore = Firestore.instance;
    final DocumentReference entityRef =
        fStore.document('entities/' + entity.entityId);

    final DocumentReference userRef =
        fStore.document('users/' + fireUser.phoneNumber);

    bool isSuccess = false;

    await fStore.runTransaction((Transaction tx) async {
      try {
        DocumentSnapshot entityDoc = await tx.get(entityRef);
        DocumentSnapshot usrDoc = await tx.get(userRef);

        User currentUser;
        if (!usrDoc.exists) {
          currentUser = new User(
              id: fireUser.uid,
              ph: fireUser.phoneNumber,
              name: fireUser.displayName,
              loc: null);
        } else {
          currentUser = User.fromJson(usrDoc.data);
        }

        Entity existingEntity;

        if (entityDoc.exists) {
          //check if the current user is admin else it is not allowed
          Map<String, dynamic> map = entityDoc.data;
          existingEntity = Entity.fromJson(map);

          if (existingEntity.isAdmin(fireUser.uid) == -1) {
            throw new AccessDeniedException(
                "User is not admin and can't update the entity");
          }

          entity.admins = existingEntity.admins;
          entity.childEntities = existingEntity.childEntities;
        } else {
          entity.admins = new List<MetaUser>();
          entity.admins.add(currentUser.getMetaUser());
        }

        if (currentUser.isEntityAdmin(entity.entityId) == -1) {
          //add the meta-entity to the user, if not already present - will happen when the entity is new
          if (currentUser.entities == null) {
            currentUser.entities = new List<MetaEntity>();
          }
          currentUser.entities.add(entity.getMetaEntity());
          tx.set(userRef, currentUser.toJson());
        } else {
          //will happen when entity exists i.e. update scenario and current user is the admin,
          //then check for the meta-entity if anything is modified
          //update the user with the udated meta-entity
          if (existingEntity != null &&
              !entity.getMetaEntity().isEqual(existingEntity.getMetaEntity())) {
            int index = currentUser.isEntityAdmin(entity.entityId);
            currentUser.entities[index] = entity.getMetaEntity();
            tx.set(userRef, currentUser.toJson());
          }
        }

        //TODO: Update the meta in other Admin objects too

        tx.set(entityRef, entity.toJson());
        isSuccess = true;
      } catch (e) {
        print("Transactio Error: While making admin - " + e.toString());
        isSuccess = false;
      }
    });

    return isSuccess;
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
    final FirebaseUser fireUser = await FirebaseAuth.instance.currentUser();
    Firestore fStore = Firestore.instance;

    Entity ent = await getEntity(entityId);

    if (ent == null)
      return throw new EntityDoesNotExistsException(
          "Given entity does not exist");

    if (ent.isAdmin(fireUser.uid) == -1) {
      throw new AccessDeniedException("This user can't delete the Entity");
    }

    //first delete all the child entities and then itself
    for (MetaEntity meta in ent.childEntities) {
      try {
        final DocumentReference childEntityRef =
            fStore.document('entities/' + meta.entityId);
        await childEntityRef.delete();
      } catch (e) {
        print("Failed to delete child-entity with id: " +
            meta.entityId +
            "Error: " +
            e.toString());
      }
    }

    final DocumentReference entityRef = fStore.document('entities/' + entityId);

    await entityRef.delete();

    return true;
  }

  Future<bool> assignAdmin(String entityId, String phone) async {
    final FirebaseUser fireUser = await FirebaseAuth.instance.currentUser();
    Firestore fStore = Firestore.instance;

    User u;
    bool isSuccess = true;

    final DocumentReference userRef = fStore.document('users/' + phone);
    final DocumentReference entityRef = fStore.document('entities/' + entityId);

    await fStore.runTransaction((Transaction tx) async {
      try {
        DocumentSnapshot entityDoc = await tx.get(entityRef);
        if (!entityDoc.exists) {
          throw new EntityDoesNotExistsException(
              "Admin can't be added for the entity which does not exist");
        }

        Entity ent = Entity.fromJson(entityDoc.data);
        if (ent.isAdmin(fireUser.uid) == -1) {
          //current logged in user should be admin of the entity then only he should be allowed to add another user as admin
          throw new AccessDeniedException(
              "User is not admin, hence can't make other users as admin");
        }

        DocumentSnapshot usrDoc = await tx.get(userRef);

        if (usrDoc.exists) {
          //either the user is registered or added by another admin to an entity as an entity
          u = User.fromJson(usrDoc.data);
          if (u.entities == null) {
            u.entities = new List<MetaEntity>();
          }

          bool entityAlreadyExistsInUser = false;
          for (MetaEntity meta in u.entities) {
            if (meta.entityId == ent.entityId) {
              entityAlreadyExistsInUser = true;
              break;
            }
          }
          if (!entityAlreadyExistsInUser) {
            u.entities.add(ent.getMetaEntity());
            tx.set(userRef, u.toJson());
          }
        } else {
          u = new User(
              id: fireUser.uid,
              ph: fireUser.phoneNumber,
              name: fireUser.displayName);
          u.entities = new List<MetaEntity>();
          u.entities.add(ent.getMetaEntity());
          tx.set(userRef, u.toJson());
        }

        bool isAlreadyAdmin = false;

        for (MetaUser usr in ent.admins) {
          if (usr.id == phone) {
            isAlreadyAdmin = true;
            break;
          }
        }

        if (!isAlreadyAdmin) {
          ent.admins.add(u.getMetaUser());
          tx.set(entityRef, ent.toJson());
        }
      } catch (e) {
        print("Transactio Error: While making admin - " + e.toString());
        isSuccess = false;
      }
    });

    return isSuccess;
  }

  Future<bool> addToParentEntity(
      String childEntityId, String parentEntityId) async {
    //this is an existing entity which is being moved under a parent entity

    return false;
  }

  Future<bool> upsertChildEntityToParent(
      Entity childEntity, String parentEntityId) async {
    //ChildEntity might already exists or can be new
    //ChildEntity Meta should be added in the parentEntity
    //ChildEntity should have parentEntityId set on the parentId attribute
    Firestore fStore = Firestore.instance;
    final FirebaseUser fireUser = await FirebaseAuth.instance.currentUser();
    final DocumentReference entityRef =
        fStore.document('entities/' + parentEntityId);

    final DocumentReference childRef =
        fStore.document('entities/' + childEntity.entityId);

    final DocumentReference userRef =
        fStore.document('users/' + fireUser.phoneNumber);

    Entity parentEntity;

    bool isSuccess = false;

    await fStore.runTransaction((Transaction tx) async {
      DocumentSnapshot parentEntityDoc = await tx.get(entityRef);

      DocumentSnapshot childEntityDoc = await tx.get(childRef);

      if (parentEntityDoc.exists) {
        //check if the current user is admin
        Map<String, dynamic> map = parentEntityDoc.data;
        parentEntity = Entity.fromJson(map);

        if (parentEntity.isAdmin(fireUser.uid) == -1) {
          throw new AccessDeniedException(
              "User is not admin and can't update the entity");
        }

        bool childEntityAlreadyExistInParent = false;
        int count = -1;

        for (MetaEntity meta in parentEntity.childEntities) {
          count++;
          if (meta.entityId == childEntity.entityId) {
            childEntityAlreadyExistInParent = true;
            break;
          }
        }

        if (childEntityAlreadyExistInParent) {
          parentEntity.childEntities[count] = childEntity.getMetaEntity();
        } else {
          parentEntity.childEntities.add(childEntity.getMetaEntity());
        }

        if (childEntityDoc.exists) {
          Entity existingChildEntity = Entity.fromJson(childEntityDoc.data);

          int userIndex = existingChildEntity.isAdmin(fireUser.uid);
          if (userIndex == -1) {
            throw new AccessDeniedException(
                "User is not admin of existing child entity");
          } else {
            MetaUser mu = new MetaUser(
                id: fireUser.uid,
                name: fireUser.displayName,
                ph: fireUser.phoneNumber);
            childEntity.admins = existingChildEntity.admins;
            childEntity.admins[userIndex] = mu;
          }
        } else {
          MetaUser mu = new MetaUser(
              id: fireUser.uid,
              name: fireUser.displayName,
              ph: fireUser.phoneNumber);
          if (childEntity.admins == null) {
            childEntity.admins = new List<MetaUser>();
          }
          childEntity.admins.add(mu);
        }
        childEntity.parentId = parentEntityId;

        DocumentSnapshot userDoc = await tx.get(userRef);
        User usr;
        if (userDoc.exists) {
          usr = User.fromJson(userDoc.data);
        } else {
          //user should exist, as this user is the admin of the parent entity
          throw new UserDoesNotExistsException("User does not exist");
        }

        int childEntityIndex = usr.isEntityAdmin(childEntity.entityId);

        if (childEntityIndex == -1) {
          usr.entities.add(childEntity.getMetaEntity());
        } else {
          usr.entities[childEntityIndex] = childEntity.getMetaEntity();
        }

        await tx.set(userRef, usr.toJson());

        await tx.set(entityRef, parentEntity.toJson());

        await tx.set(childRef, childEntity.toJson());

        isSuccess = true;
      } else {
        isSuccess = false;
        throw new EntityDoesNotExistsException("Parent entity does not exist");
      }
    });

    return isSuccess;
  }

  Future<bool> removeAdmin(String entityId, String phone) async {
    //check of the current user is admin
    //remove from the user.entities collection
    //remove from the entity.admin collection
    final FirebaseUser fireUser = await FirebaseAuth.instance.currentUser();
    Firestore fStore = Firestore.instance;

    User u;
    bool isSuccess = true;

    final DocumentReference userRef = fStore.document('users/' + phone);
    final DocumentReference entityRef = fStore.document('entities/' + entityId);

    await fStore.runTransaction((Transaction tx) async {
      try {
        DocumentSnapshot entityDoc = await tx.get(entityRef);
        if (!entityDoc.exists) {
          throw new EntityDoesNotExistsException(
              "Admin can't be added for the entity which does not exist");
        }

        Entity ent = Entity.fromJson(entityDoc.data);
        if (ent.isAdmin(fireUser.uid) == -1) {
          //current logged in user should be admin of the entity then only he should be allowed to add another user as admin
          throw new AccessDeniedException(
              "User is not admin, hence can't remove another user as an admin");
        }

        DocumentSnapshot usrDoc = await tx.get(userRef);
        bool isAlreadyAdmin = false;
        bool entityAlreadyExistsInUser = false;

        if (usrDoc.exists) {
          //either the user is registered or added by another admin to an entity as an entity
          u = User.fromJson(usrDoc.data);
          if (u.entities == null) {
            u.entities = new List<MetaEntity>();
          }

          int count = -1;
          for (MetaEntity meta in u.entities) {
            count++;
            if (meta.entityId == ent.entityId) {
              entityAlreadyExistsInUser = true;
              break;
            }
          }
          if (entityAlreadyExistsInUser) {
            u.entities.removeAt(count);
            tx.set(userRef, u.toJson());
          }
        } else {
          //nothing to be done as user does not exists
        }

        int index = -1;
        for (MetaUser usr in ent.admins) {
          index++;
          if (usr.ph == phone) {
            isAlreadyAdmin = true;
            break;
          }
        }

        if (isAlreadyAdmin) {
          ent.admins.removeAt(index);
          tx.set(entityRef, ent.toJson());
        }
      } catch (e) {
        print("Transactio Error: While removing admin - " + e.toString());
        isSuccess = false;
      }
    });

    return isSuccess;
  }

  Future<List<Entity>> searchByName(String name, double lat, double lon,
      int distance, int pageNumber, int pageSize) async {
    List<Entity> entities = new List<Entity>();
    Firestore fStore = Firestore.instance;
    Geoflutterfire geo = Geoflutterfire();

    var queryRef = fStore
        .collection('entities')
        .where('name', isGreaterThanOrEqualTo: name);
    GeoFirePoint center = geo.point(latitude: lat, longitude: lon);
    double radius = double.parse(distance.toString());
    var stream = geo
        .collection(collectionRef: queryRef)
        .within(center: center, radius: radius, field: 'coordinates')
        .skip((pageNumber - 1) * pageSize)
        .take(pageSize);

    stream.listen((List<DocumentSnapshot> documentList) {
      documentList.forEach((doc) => {entities.add(Entity.fromJson(doc.data))});
    });
    return entities;
  }

  Future<List<Entity>> searchByType(
      String type, double lat, double lon, int distance, pageSize) async {
    List<Entity> entities = new List<Entity>();
    return entities;
  }
}
