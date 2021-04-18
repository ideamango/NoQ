import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:enum_to_string/enum_to_string.dart';
import 'package:firebase_auth/firebase_auth.dart' as fAuth;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:geoflutterfire/geoflutterfire.dart';
import 'package:noq/db/db_model/app_user.dart';
import 'package:noq/db/db_model/employee.dart';
import 'package:noq/db/db_model/entity.dart';
import 'package:noq/db/db_model/entity_private.dart';
import 'package:noq/db/db_model/meta_entity.dart';
import 'package:noq/db/exceptions/access_denied_exception.dart';
import 'package:noq/db/exceptions/entity_does_not_exists_exception.dart';
import 'package:noq/db/exceptions/user_does_not_exists_exception.dart';
import 'package:noq/enum/entity_type.dart';
import 'package:noq/utils.dart';

import '../../constants.dart';

class EntityService {
  FirebaseApp _fb;

  EntityService(FirebaseApp firebaseApp) {
    _fb = firebaseApp;
  }

  FirebaseFirestore getFirestore() {
    if (_fb == null) {
      return FirebaseFirestore.instance;
    } else {
      return FirebaseFirestore.instanceFor(app: _fb);
    }
  }

  FirebaseAuth getFirebaseAuth() {
    if (_fb == null) return FirebaseAuth.instance;
    return FirebaseAuth.instanceFor(app: _fb);
  }

  Future<bool> updateEntityForms(String entityId) async {
    return false;
  }

  Future<bool> upsertEntity(Entity entity) async {
    final fAuth.User fireUser = getFirebaseAuth().currentUser;
    String regNum = entity.regNum;

    FirebaseFirestore fStore = getFirestore();
    final DocumentReference entityRef =
        fStore.doc('entities/' + entity.entityId);

    final DocumentReference entityPrivateRef =
        fStore.doc('entities/' + entity.entityId + '/private_data/private');

    final DocumentReference userRef =
        fStore.doc('users/' + fireUser.phoneNumber);

    bool isSuccess = false;

    await fStore.runTransaction((Transaction tx) async {
      try {
        DocumentSnapshot entityDoc = await tx.get(entityRef);

        DocumentSnapshot usrDoc = await tx.get(userRef);

        DocumentSnapshot ePrivateDoc = await tx.get(entityPrivateRef);

        AppUser currentUser;
        if (!usrDoc.exists) {
          currentUser = new AppUser(
              id: fireUser.uid,
              ph: fireUser.phoneNumber,
              name: fireUser.displayName,
              loc: null);
        } else {
          currentUser = AppUser.fromJson(usrDoc.data());
        }

        Entity existingEntity;
        EntityPrivate ePrivate;

        if (entityDoc.exists) {
          //check if the current user is admin else it is not allowed
          Map<String, dynamic> map = entityDoc.data();
          existingEntity = Entity.fromJson(map);
          ePrivate = EntityPrivate.fromJson(ePrivateDoc.data());

          //if (existingEntity.isAdmin(fireUser.uid) == -1) {
          if (ePrivate.roles[fireUser.phoneNumber] !=
              EnumToString.convertToString(EntityRole.Admin)) {
            throw new AccessDeniedException(
                "User is not admin and can't update the entity");
          }
          ePrivate.registrationNumber = regNum;
        } else {
          // entity does not exist, so create a new EntityPrivate
          ePrivate = new EntityPrivate();
          ePrivate.roles = {
            fireUser.phoneNumber:
                EnumToString.convertToString(EntityRole.ENTITY_ADMIN)
          };
          ePrivate.registrationNumber = regNum;
          entity.verificationStatus = VERIFICATION_PENDING;
        }

        if (currentUser.isEntityAdmin(entity.entityId) == -1) {
          //add the meta-entity to the user, if not already present - will happen when the entity is new
          if (currentUser.entities == null) {
            currentUser.entities = new List<MetaEntity>();
          }
          currentUser.entities.add(entity.getMetaEntity());
          currentUser.entityVsRole[entity.entityId] = EntityRole.ENTITY_ADMIN;
        } else {
          //will happen when entity exists i.e. update scenario and current user is the admin,
          //then check for the meta-entity if anything is modified
          //update the user with the udated meta-entity
          if (existingEntity != null &&
              !entity.getMetaEntity().isEqual(existingEntity.getMetaEntity())) {
            int index = currentUser.isEntityAdmin(entity.entityId);
            currentUser.entities[index] = entity.getMetaEntity();
            currentUser.entityVsRole[entity.entityId] = EntityRole.ENTITY_ADMIN;
          }
        }

        Employee emp = new Employee(
            id: fireUser.uid,
            name: fireUser.displayName,
            ph: fireUser.phoneNumber);

        if (entity.admins == null) {
          entity.admins = new List<Employee>();
        }

        int existingIndexInAdmin = -1;
        for (int index = 0; index < entity.admins.length; index++) {
          if (entity.admins[index].ph == emp.ph) {
            existingIndexInAdmin = index;
            break;
          }
        }

        if (existingIndexInAdmin == -1) {
          //current employee is admin (creating the entity) and does not exist in the Entity Admins collection already
          entity.admins.add(emp);
        } else {
          //do not need to update existing employee info, as Entity might already have more details
          //entity.admins[existingIndexInAdmin] = emp;
        }

        tx.set(userRef, currentUser.toJson());
        //TODO: Update the meta in other Admin objects too
        tx.set(entityPrivateRef, ePrivate.toJson());

        if (entity.createdAt != null) {
          entity.modifiedAt = DateTime.now();
        } else {
          entity.createdAt = DateTime.now();
          entity.modifiedAt = DateTime.now();
        }

        tx.set(entityRef, entity.toJson());

        isSuccess = true;
      } catch (e) {
        print("Transaction Error: While making admin - " + e.toString());
        isSuccess = false;
      }
    });

    return isSuccess;
  }

  Future<Entity> getEntity(String entityId) async {
    FirebaseFirestore fStore = getFirestore();
    Entity entity;

    final DocumentReference entityRef = fStore.doc('entities/' + entityId);

    DocumentSnapshot doc = await entityRef.get();

    if (doc.exists) {
      Map<String, dynamic> map = doc.data();
      entity = Entity.fromJson(map);
    }

    return entity;
  }

  Future<EntityPrivate> getEntityPrivate(String entityId) async {
    FirebaseFirestore fStore = getFirestore();
    EntityPrivate entityPrivate;

    final DocumentReference entityPrivateRef =
        fStore.doc('entities/' + entityId + '/private_data/private');

    DocumentSnapshot doc = await entityPrivateRef.get();

    if (doc.exists) {
      Map<String, dynamic> map = doc.data();
      entityPrivate = EntityPrivate.fromJson(map);
    }

    return entityPrivate;
  }

  Future<bool> deleteEntity(String entityId) async {
    final fAuth.User fireUser = getFirebaseAuth().currentUser;
    FirebaseFirestore fStore = getFirestore();
    bool isSuccess = false;

    //STEPS:
    //1. delete all the childEntities in the recursive manner (out of the main transaction)
    //2. update the parent by removing current entityReference
    //3. update the users with current entityReference
    //4. delete the current entity
    // Known limitation - Admins of the child entities wil not be cleaned up and will see ref to the deleted objects

    DocumentReference entityRef = fStore.doc('entities/' + entityId);
    final DocumentReference entityPrivateRef =
        fStore.doc('entities/' + entityId + '/private_data/private');
    DocumentReference parentEntityRef;
    List<DocumentReference> childEntityRefs = new List<DocumentReference>();
    List<DocumentReference> childEntityPrivateRefs =
        new List<DocumentReference>();

    await fStore.runTransaction((Transaction tx) async {
      try {
        DocumentSnapshot entityDoc = await tx.get(entityRef);

        if (!entityDoc.exists) {
          return throw new EntityDoesNotExistsException(
              "Given entity does not exist");
        }

        Entity ent = Entity.fromJson(entityDoc.data());
        DocumentSnapshot ePrivateDoc = await tx.get(entityPrivateRef);
        EntityPrivate ePrivate = EntityPrivate.fromJson(ePrivateDoc.data());

        //if (ent.isAdmin(fireUser.uid) == -1) {
        if (ePrivate.roles[fireUser.phoneNumber] !=
            EnumToString.convertToString(EntityRole.ENTITY_ADMIN)) {
          throw new AccessDeniedException("This user can't delete the Entity");
        }

        print(ent.childEntities.length);
        //Step1: first delete all the child entities
        for (MetaEntity meta in ent.childEntities) {
          print(meta.entityId);
          DocumentReference childRef = fStore.doc('entities/' + meta.entityId);
          DocumentReference childPrivateRef =
              fStore.doc('entities/' + meta.entityId + '/private_data/private');
          childEntityPrivateRefs.add(childPrivateRef);
          childEntityRefs.add(childRef);
        }

        Entity parentEnt;

        if (ent.parentId != null) {
          //remove the childEntity from the parentEntity
          parentEntityRef = fStore.doc('entities/' + ent.parentId);
          DocumentSnapshot parentEntityDoc = await tx.get(parentEntityRef);

          parentEnt = Entity.fromJson(parentEntityDoc.data());
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

        List<AppUser> adminUsers = new List<AppUser>();

        //for (MetaUser usr in ent.admins) {
        for (String adminPhone in ePrivate.roles.keys) {
          DocumentReference userRef = fStore.doc('users/' + adminPhone);
          DocumentSnapshot userDoc = await tx.get(userRef);

          if (userDoc.exists) {
            AppUser u = AppUser.fromJson(userDoc.data());

            int index = u.isEntityAdmin(entityId);
            if (index != -1) {
              u.entities.removeAt(index);
              if (u.entityVsRole.containsKey(entityId)) {
                u.entityVsRole.remove(entityId);
              }
              adminUsers.add(u);
            }
          }
        }

        //step2: Update the parent if exists
        if (parentEntityRef != null) {
          tx.set(parentEntityRef, parentEnt.toJson());
        }

        //step3: update admin users
        for (AppUser u in adminUsers) {
          DocumentReference userRef = fStore.doc('users/' + u.ph);
          tx.set(userRef, u.toJson());
        }

        //Step4: now delete the child entities and the entity
        int count = 0;
        for (DocumentReference childRef in childEntityRefs) {
          tx.delete(childRef);
          tx.delete(childEntityPrivateRefs[count]);

          count++;
        }
        tx.delete(entityRef);
        tx.delete(entityPrivateRef);

        isSuccess = true;
      } catch (e) {
        isSuccess = false;
      }
    });

    return isSuccess;
  }

  Future<bool> addEmployee(
      String entityId, Employee employee, EntityRole role) async {
    final User fireUser = getFirebaseAuth().currentUser;
    FirebaseFirestore fStore = getFirestore();
    String phone = employee.ph;
    if (!Utils.isNotNullOrEmpty(phone)) {
      throw new Exception("Phone of Employee can't be null");
    }

    AppUser u;
    bool isSuccess = true;

    final DocumentReference userRef = fStore.doc('users/' + phone);
    final DocumentReference entityRef = fStore.doc('entities/' + entityId);
    final DocumentReference entityPrivateRef =
        fStore.doc('entities/' + entityId + '/private_data/private');

    await fStore.runTransaction((Transaction tx) async {
      try {
        DocumentSnapshot entityDoc = await tx.get(entityRef);
        if (!entityDoc.exists) {
          throw new EntityDoesNotExistsException(
              "Employee can't be added for the entity which does not exist");
        }

        DocumentSnapshot ePrivateDoc = await tx.get(entityPrivateRef);
        EntityPrivate ePrivate = EntityPrivate.fromJson(ePrivateDoc.data());

        Entity ent = Entity.fromJson(entityDoc.data());
        //if (ent.isAdmin(fireUser.uid) == -1) {
        if (ePrivate.roles[fireUser.phoneNumber] !=
            EnumToString.convertToString(EntityRole.ENTITY_ADMIN)) {
          //current logged in user should be admin of the entity then only he should be allowed to add another user as admin
          throw new AccessDeniedException(
              "User is not admin, hence can't add other users");
        }

        DocumentSnapshot usrDoc = await tx.get(userRef);

        if (usrDoc.exists) {
          //either the user is registered or added by another admin to an entity as an entity
          u = AppUser.fromJson(usrDoc.data());
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
            //await tx.set(userRef, u.toJson());
          }
        } else {
          // a new user will be added in the user table for that phone number
          u = new AppUser(id: null, ph: phone, name: employee.name);
          u.entities = new List<MetaEntity>();
          u.entities.add(ent.getMetaEntity());
        }

        ePrivate.roles[phone] = EnumToString.convertToString(role);

        //add this Employee to the Entity
        //if already exists in any of the collection, remove it and then update
        if (ent.admins == null) {
          ent.admins = new List<Employee>();
        }

        if (ent.managers == null) {
          ent.managers = new List<Employee>();
        }

        if (ent.executives == null) {
          ent.executives = new List<Employee>();
        }

        //------
        int existingIndexInAdmin = -1;
        for (int index = 0; index < ent.admins.length; index++) {
          if (ent.admins[index].ph == employee.ph) {
            existingIndexInAdmin = index;
            break;
          }
        }

        if (existingIndexInAdmin > -1) {
          ent.admins.removeAt(existingIndexInAdmin);
        }
        //------
        int existingIndexInManager = -1;
        for (int index = 0; index < ent.managers.length; index++) {
          if (ent.managers[index].ph == employee.ph) {
            existingIndexInManager = index;
            break;
          }
        }

        if (existingIndexInManager > -1) {
          ent.managers.removeAt(existingIndexInManager);
        }
        //------
        int existingIndexInExecutive = -1;
        for (int index = 0; index < ent.executives.length; index++) {
          if (ent.executives[index].ph == employee.ph) {
            existingIndexInExecutive = index;
            break;
          }
        }

        if (existingIndexInExecutive > -1) {
          ent.executives.removeAt(existingIndexInExecutive);
        }

        //------

        if (role == EntityRole.ENTITY_ADMIN) {
          ent.admins.add(employee);
        }

        if (role == EntityRole.ENTITY_MANAGER) {
          ent.managers.add(employee);
        }

        if (role == EntityRole.ENTITY_EXECUTIVE) {
          ent.executives.add(employee);
        }

        tx.set(userRef, u.toJson());
        tx.set(entityPrivateRef, ePrivate.toJson());
        tx.set(entityRef, ent.toJson());
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
    FirebaseFirestore fStore = getFirestore();
    final User fireUser = getFirebaseAuth().currentUser;
    String childRegNum = childEntity.regNum;

    final DocumentReference entityRef =
        fStore.doc('entities/' + parentEntityId);

    final DocumentReference childRef =
        fStore.doc('entities/' + childEntity.entityId);

    final DocumentReference userRef =
        fStore.doc('users/' + fireUser.phoneNumber);

    final DocumentReference parentEntityPrivateRef =
        fStore.doc('entities/' + parentEntityId + '/private_data/private');

    final DocumentReference childEntityPrivateRef = fStore
        .doc('entities/' + childEntity.entityId + '/private_data/private');

    Entity parentEntity;
    EntityPrivate parentEntityPrivate;

    EntityPrivate childEntityPrivate;

    bool isSuccess = false;

    await fStore.runTransaction((Transaction tx) async {
      try {
        DocumentSnapshot parentEntityDoc = await tx.get(entityRef);

        if (parentEntityDoc.exists) {
          //check if the current user is admin
          Map<String, dynamic> map = parentEntityDoc.data();
          parentEntity = Entity.fromJson(map);

          DocumentSnapshot parentEntityPrivateDoc =
              await tx.get(parentEntityPrivateRef);

          parentEntityPrivate =
              EntityPrivate.fromJson(parentEntityPrivateDoc.data());

          //if (parentEntity.isAdmin(fireUser.uid) == -1) {
          if (parentEntityPrivate.roles[fireUser.phoneNumber] !=
              EnumToString.convertToString(EntityRole.ENTITY_ADMIN)) {
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

          DocumentSnapshot childEntityDoc = await tx.get(childRef);

          if (childEntityDoc.exists) {
            //Entity existingChildEntity = Entity.fromJson(childEntityDoc.data);

            DocumentSnapshot childEntityPrivateDoc =
                await tx.get(childEntityPrivateRef);

            childEntityPrivate =
                EntityPrivate.fromJson(childEntityPrivateDoc.data());

            //int userIndex = existingChildEntity.isAdmin(fireUser.uid);
            //if (userIndex == -1) {
            if (childEntityPrivate.roles[fireUser.phoneNumber] !=
                EnumToString.convertToString(EntityRole.ENTITY_ADMIN)) {
              throw new AccessDeniedException(
                  "User is not admin of existing child entity");
            } else {
              //do nothing
            }
          } else {
            childEntityPrivate = new EntityPrivate(
                registrationNumber: childRegNum,
                roles: {
                  fireUser.phoneNumber:
                      EnumToString.convertToString(EntityRole.ENTITY_ADMIN)
                });
            childEntity.verificationStatus = VERIFICATION_PENDING;
          }
          childEntity.parentId = parentEntityId;

          DocumentSnapshot userDoc = await tx.get(userRef);
          AppUser usr;
          if (userDoc.exists) {
            usr = AppUser.fromJson(userDoc.data());
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

          tx.set(userRef, usr.toJson());

          tx.set(entityRef, parentEntity.toJson());

          tx.set(parentEntityPrivateRef, parentEntityPrivate.toJson());

          tx.set(childEntityPrivateRef, childEntityPrivate.toJson());

          if (childEntity.createdAt != null) {
            childEntity.modifiedAt = DateTime.now();
          } else {
            childEntity.createdAt = DateTime.now();
            childEntity.modifiedAt = DateTime.now();
          }

          tx.set(childRef, childEntity.toJson());

          isSuccess = true;
        } else {
          isSuccess = false;
          throw new EntityDoesNotExistsException(
              "Parent entity does not exist");
        }

        isSuccess = true;
      } catch (e) {
        print('Error upsert child to parent' + e.toString());

        isSuccess = false;
      }
    });

    return isSuccess;
  }

  Future<bool> removeEmployee(String entityId, String phone) async {
    //check of the current user is admin
    //remove from the user.entities collection
    //remove from the entity.admin collection
    final User fireUser = getFirebaseAuth().currentUser;
    FirebaseFirestore fStore = getFirestore();

    AppUser u;
    bool isSuccess = true;

    final DocumentReference userRef = fStore.doc('users/' + phone);
    final DocumentReference entityRef = fStore.doc('entities/' + entityId);
    final DocumentReference entityPrivateRef =
        fStore.doc('entities/' + entityId + '/private_data/private');

    await fStore.runTransaction((Transaction tx) async {
      try {
        //DocumentSnapshot entityDoc = await tx.get(entityRef);

        DocumentSnapshot ePrivateDoc = await tx.get(entityPrivateRef);
        if (!ePrivateDoc.exists) {
          throw new EntityDoesNotExistsException(
              "Admin can't be added for the entity which does not exist");
        }

        EntityPrivate ePrivate = EntityPrivate.fromJson(ePrivateDoc.data());

        //if (ent.isAdmin(fireUser.uid) == -1) {
        if (ePrivate.roles[fireUser.phoneNumber] !=
            EnumToString.convertToString(EntityRole.ENTITY_ADMIN)) {
          //current logged in user should be admin of the entity then only he should be allowed to add another user as admin
          throw new AccessDeniedException(
              "User is not admin, hence can't remove another user");
        }

        DocumentSnapshot entityDoc = await tx.get(entityRef);
        Entity ent = Entity.fromJson(entityDoc.data());

        DocumentSnapshot usrDoc = await tx.get(userRef);
        bool entityAlreadyExistsInUser = false;

        if (usrDoc.exists) {
          //either the user is registered or added by another admin to an entity as an entity
          u = AppUser.fromJson(usrDoc.data());
          if (u.entities == null) {
            u.entities = new List<MetaEntity>();
          }

          int count = -1;
          for (MetaEntity meta in u.entities) {
            count++;
            if (meta.entityId == entityId) {
              entityAlreadyExistsInUser = true;
              break;
            }
          }
          if (entityAlreadyExistsInUser) {
            u.entities.removeAt(count);

            if (u.entityVsRole.containsKey(entityId)) {
              u.entityVsRole.remove(entityId);
            }
            tx.set(userRef, u.toJson());
          }
        } else {
          //nothing to be done as user does not exists - removal does not make sense
        }

        if (ent.admins != null) {
          int existingIndexInAdmin = -1;
          for (int index = 0; index < ent.admins.length; index++) {
            if (ent.admins[index].ph == phone) {
              existingIndexInAdmin = index;
              break;
            }
          }

          if (existingIndexInAdmin > -1) {
            ent.admins.removeAt(existingIndexInAdmin);
          }
        }

        if (ent.managers != null) {
          int existingIndexInManager = -1;
          for (int index = 0; index < ent.managers.length; index++) {
            if (ent.managers[index].ph == phone) {
              existingIndexInManager = index;
              break;
            }
          }

          if (existingIndexInManager > -1) {
            ent.managers.removeAt(existingIndexInManager);
          }
        }

        if (ent.executives != null) {
          int existingIndexInExecutive = -1;
          for (int index = 0; index < ent.executives.length; index++) {
            if (ent.executives[index].ph == phone) {
              existingIndexInExecutive = index;
              break;
            }
          }

          if (existingIndexInExecutive > -1) {
            ent.executives.removeAt(existingIndexInExecutive);
          }
        }

        if (ePrivate.roles.containsKey(phone)) {
          ePrivate.roles.remove(phone);
          tx.set(entityPrivateRef, ePrivate.toJson());
        }
      } catch (e) {
        print("Transactio Error: While removing admin - " + e.toString());
        isSuccess = false;
      }
    });

    return isSuccess;
  }

  Future<bool> addEntityToUserFavourite(MetaEntity me) async {
    final User fireUser = getFirebaseAuth().currentUser;
    FirebaseFirestore fStore = getFirestore();

    AppUser u;
    bool isSuccess = true;

    final DocumentReference userRef =
        fStore.doc('users/' + fireUser.phoneNumber);

    await fStore.runTransaction((Transaction tx) async {
      try {
        DocumentSnapshot usrDoc = await tx.get(userRef);

        if (usrDoc.exists) {
          //either the user is registered or added by another admin to an entity as an entity
          u = AppUser.fromJson(usrDoc.data());
          if (u.favourites == null) {
            u.favourites = new List<MetaEntity>();
          }

          bool entityAlreadyExistsInUser = false;
          for (MetaEntity meta in u.favourites) {
            if (meta.entityId == me.entityId) {
              entityAlreadyExistsInUser = true;
              break;
            }
          }
          if (!entityAlreadyExistsInUser) {
            u.favourites.add(me);
            tx.set(userRef, u.toJson());
          }
        } else {
          isSuccess = false;
        }
      } catch (e) {
        print(
            "Transactio Error: While adding favourite admin - " + e.toString());
        isSuccess = false;
      }
    });

    return isSuccess;
  }

  Future<bool> removeEntityFromUserFavourite(String entityId) async {
    final User fireUser = getFirebaseAuth().currentUser;
    FirebaseFirestore fStore = getFirestore();

    AppUser u;
    bool isSuccess = true;

    final DocumentReference userRef =
        fStore.doc('users/' + fireUser.phoneNumber);

    await fStore.runTransaction((Transaction tx) async {
      try {
        DocumentSnapshot usrDoc = await tx.get(userRef);

        if (usrDoc.exists) {
          //either the user is registered or added by another admin to an entity as an entity
          u = AppUser.fromJson(usrDoc.data());
          if (u.favourites == null) {
            u.favourites = new List<MetaEntity>();
          }

          int index = -1;
          for (MetaEntity meta in u.favourites) {
            index++;
            if (meta.entityId == entityId) {
              break;
            }
          }
          if (index != -1) {
            u.favourites.removeAt(index);
            tx.set(userRef, u.toJson());
          }
        } else {
          isSuccess = false;
        }
      } catch (e) {
        print(
            "Transactio Error: While adding favourite admin - " + e.toString());
        isSuccess = false;
      }
    });

    return isSuccess;
  }

  Future<List<Entity>> search(String name, EntityType entityType, double lat,
      double lon, int radius, int pageNumber, int pageSize) async {
    double rad = radius.toDouble();
    List<Entity> entities = new List<Entity>();
    FirebaseFirestore fStore = getFirestore();
    Geoflutterfire geo = Geoflutterfire();
    GeoFirePoint center = geo.point(latitude: lat, longitude: lon);

    if (name != null && name != "") {
      name = name.toLowerCase();
    }

    String type;
    if (entityType != null) {
      type = entityType
          .toString()
          .substring(entityType.toString().indexOf('.') + 1);
    }

    var collectionReference;

    if (type != null && type != "" && name != null && name != "") {
      collectionReference = fStore
          .collection('entities')
          .where("isActive", isEqualTo: true)
          .where("nameQuery", arrayContains: name)
          .where("type", isEqualTo: type);
    } else if (name != null && name != "") {
      collectionReference = fStore
          .collection('entities')
          .where("isActive", isEqualTo: true)
          .where("nameQuery", arrayContains: name);
    } else if (type != null && type != "") {
      collectionReference = fStore
          .collection('entities')
          .where("isActive", isEqualTo: true)
          .where("type", isEqualTo: type);
    } else {
      return entities;
    }

    String field = 'coordinates';

    Stream<List<DocumentSnapshot>> stream = geo
        .collection(collectionRef: collectionReference)
        .within(center: center, radius: rad, field: field);

    try {
      for (DocumentSnapshot ds in await stream.first) {
        Entity me = Entity.fromJson(ds.data());
        me.distance = center.distance(
            lat: me.coordinates.geopoint.latitude,
            lng: me.coordinates.geopoint.longitude);
        entities.add(me);
      }
    } catch (e) {
      print("Search failed: " + e.toString());
    }

    return entities;
  }
}
