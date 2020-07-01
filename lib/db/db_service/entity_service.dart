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
    bool isSuccess = false;

    //STEPS:
    //1. delete all the childEntities in the recursive manner (out of the main transaction)
    //2. update the parent by removing current entityReference
    //3. update the users with current entityReference
    //4. delete the current entity
    // Known limitation - Admins of the child entities wil not be cleaned up and will see ref to the deleted objects

    DocumentReference entityRef = fStore.document('entities/' + entityId);
    DocumentReference parentEntityRef;
    List<DocumentReference> childEntityRefs = new List<DocumentReference>();

    await fStore.runTransaction((Transaction tx) async {
      try {
        DocumentSnapshot entityDoc = await tx.get(entityRef);

        if (!entityDoc.exists) {
          return throw new EntityDoesNotExistsException(
              "Given entity does not exist");
        }

        Entity ent = Entity.fromJson(entityDoc.data);

        if (ent.isAdmin(fireUser.uid) == -1) {
          throw new AccessDeniedException("This user can't delete the Entity");
        }

        //Step1: first delete all the child entities
        for (MetaEntity meta in ent.childEntities) {
          DocumentReference childRef =
              fStore.document('entities/' + meta.entityId);
          childEntityRefs.add(childRef);
        }

        Entity parentEnt;

        if (ent.parentId != null) {
          //remove the childEntity from the parentEntity
          parentEntityRef = fStore.document('entities/' + ent.parentId);
          DocumentSnapshot parentEntityDoc = await tx.get(parentEntityRef);

          parentEnt = Entity.fromJson(parentEntityDoc.data);
          int index = -1;
          for (MetaEntity childMeta in parentEnt.childEntities) {
            index++;
            if (childMeta.entityId == entityId) {
              break;
            }
          }
          if (index != -1) {
            parentEnt.childEntities.removeAt(index);
          }
        }

        List<User> adminUsers = new List<User>();

        for (MetaUser usr in ent.admins) {
          DocumentReference userRef = fStore.document('users/' + usr.ph);
          DocumentSnapshot userDoc = await tx.get(userRef);

          if (userDoc.exists) {
            User u = User.fromJson(userDoc.data);

            int index = u.isEntityAdmin(entityId);
            if (index != -1) {
              u.entities.removeAt(index);
              adminUsers.add(u);
            }
          }
        }

        //step2: Update the parent if exists
        if (parentEntityRef != null) {
          await tx.set(parentEntityRef, parentEnt.toJson());
        }

        //step3: update admin users
        for (User u in adminUsers) {
          DocumentReference userRef = fStore.document('users/' + u.ph);
          await tx.set(userRef, u.toJson());
        }

        //Step4: now delete the child entities and the entity
        for (DocumentReference childRef in childEntityRefs) {
          await tx.delete(childRef);
        }
        await tx.delete(entityRef);

        isSuccess = true;
      } catch (e) {
        isSuccess = false;
        print(e);
      }
    });

    return isSuccess;
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
          // a new user will be added in the user table for that phone number
          u = new User(id: null, ph: phone, name: null);
          u.entities = new List<MetaEntity>();
          u.entities.add(ent.getMetaEntity());
          tx.set(userRef, u.toJson());
        }

        //now update the entity
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
      try {
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
          throw new EntityDoesNotExistsException(
              "Parent entity does not exist");
        }
      } catch (e) {
        print(e);
        isSuccess = false;
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

  Future<List<MetaEntity>> searchByName(String name, double lat, double lon,
      double radius, int pageNumber, int pageSize) async {
    List<MetaEntity> entities = new List<MetaEntity>();
    Firestore fStore = Firestore.instance;
    Geoflutterfire geo = Geoflutterfire();

    // var queryRef = fStore.collection('entities').where('name', isEqualTo: name);
    // GeoFirePoint center = geo.point(latitude: lat, longitude: lon);
    // double radius = double.parse(distance.toString());
    // var stream = geo
    //     .collection(collectionRef: queryRef)
    //     .within(center: center, radius: radius, field: 'coordinates')
    //     .skip((pageNumber - 1) * pageSize)
    //     .take(pageSize);

    // stream.listen((List<DocumentSnapshot> documentList) {
    //   documentList.forEach((doc) => {entities.add(Entity.fromJson(doc.data))});
    // });
    //-------------------------
    // var collectionReference = fStore.collection('entities');
    // GeoFirePoint center = geo.point(latitude: lat, longitude: lon);

    // double radius = 5;
    // String field = 'coordinates';

    // Stream<List<DocumentSnapshot>> stream = geo
    //     .collection(collectionRef: collectionReference)
    //     .within(center: center, radius: radius, field: field);

    // await stream.listen((List<DocumentSnapshot> documentList) {
    //   documentList.forEach((doc) => {entities.add(Entity.fromJson(doc.data))});
    // });
    //---------------------------

    GeoFirePoint center = geo.point(latitude: lat, longitude: lon);

    // QuerySnapshot qs = await fStore
    //     .collection('entities')
    //     .where("query", arrayContains: "smi")
    //     .getDocuments();

    // print("Array Contains result count: " + qs.documents.length.toString());

    var collectionReference =
        fStore.collection('entities').where("nameQuery", arrayContains: name);

    // var collectionReference =
    //     fStore.collection('entities').where("name", isEqualTo: "Bata");

    // var collectionReference = fStore.collection('entities');

    String field = 'coordinates';

    Stream<List<DocumentSnapshot>> stream = geo
        .collection(collectionRef: collectionReference)
        .within(center: center, radius: radius, field: field);
    //    .take(pageSize);
    //.skip(pageNumber - 1);
    if (stream.first == null) {
      return entities;
    }

    try {
      for (DocumentSnapshot ds in await stream.first) {
        MetaEntity me = Entity.fromJson(ds.data).getMetaEntity();
        me.distance = center.distance(lat: me.lat, lng: me.lon);
        entities.add(me);
      }
    } catch (e) {
      print(e);
    }

    return entities;
  }

  Future<List<MetaEntity>> searchByType(String type, double lat, double lon,
      double radius, int pageNumber, int pageSize) async {
    List<MetaEntity> entities = new List<MetaEntity>();
    Firestore fStore = Firestore.instance;
    Geoflutterfire geo = Geoflutterfire();
    GeoFirePoint center = geo.point(latitude: lat, longitude: lon);

    var collectionReference =
        fStore.collection('entities').where("type", isEqualTo: type);

    String field = 'coordinates';

    Stream<List<DocumentSnapshot>> stream = geo
        .collection(collectionRef: collectionReference)
        .within(center: center, radius: radius, field: field);

    try {
      for (DocumentSnapshot ds in await stream.first) {
        MetaEntity me = Entity.fromJson(ds.data).getMetaEntity();
        me.distance = center.distance(lat: me.lat, lng: me.lon);
        entities.add(me);
      }
    } catch (e) {
      print(e);
    }

    return entities;
  }

  Future<List<MetaEntity>> search(String name, String type, double lat,
      double lon, double radius, int pageNumber, int pageSize) async {
    List<MetaEntity> entities = new List<MetaEntity>();
    Firestore fStore = Firestore.instance;
    Geoflutterfire geo = Geoflutterfire();
    GeoFirePoint center = geo.point(latitude: lat, longitude: lon);

    var collectionReference;

    if (type != null && type != "" && name != null && name != "") {
      collectionReference = fStore
          .collection('entities')
          .where("isActive", isEqualTo: "true")
          .where("nameQuery", arrayContains: name)
          .where("type", isEqualTo: type);
    } else if (name != null && name != "") {
      collectionReference = fStore
          .collection('entities')
          .where("isActive", isEqualTo: "true")
          .where("nameQuery", arrayContains: name);
    } else if (type != null && type != "") {
      collectionReference = fStore
          .collection('entities')
          .where("isActive", isEqualTo: "true")
          .where("type", isEqualTo: type);
    } else {
      return entities;
    }

    String field = 'coordinates';

    Stream<List<DocumentSnapshot>> stream = geo
        .collection(collectionRef: collectionReference)
        .within(center: center, radius: radius, field: field);

    try {
      for (DocumentSnapshot ds in await stream.first) {
        MetaEntity me = Entity.fromJson(ds.data).getMetaEntity();
        me.distance = center.distance(lat: me.lat, lng: me.lon);
        entities.add(me);
      }
    } catch (e) {
      print(e);
    }

    return entities;
  }
}
