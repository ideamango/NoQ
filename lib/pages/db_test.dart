import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:noq/db/db_model/address.dart';
import 'package:noq/db/db_model/configurations.dart';
import 'package:noq/db/db_model/entity.dart';
import 'package:noq/db/db_model/entity_private.dart';
import 'package:noq/db/db_model/entity_slots.dart';
import 'package:noq/db/db_model/meta_entity.dart';
import 'package:noq/db/db_model/my_geo_fire_point.dart';
import 'package:noq/db/db_model/slot.dart';
import 'package:noq/db/db_model/user.dart';
import 'package:noq/db/db_model/user_token.dart';
import 'package:noq/db/db_service/configurations_service.dart';
import 'package:noq/db/db_service/entity_service.dart';
import 'package:noq/db/db_service/token_service.dart';
import 'package:noq/db/db_service/user_service.dart';

class DBTest {
  void createEntity() async {
    Address adrs = new Address(
        city: "Hyderbad",
        state: "Telangana",
        country: "India",
        address: "Shop 10, Gachibowli");

    MyGeoFirePoint geoPoint = new MyGeoFirePoint(68, 78);
    Entity entity = new Entity(
        entityId: "Entity101",
        name: "Inorbit",
        address: adrs,
        advanceDays: 3,
        isPublic: true,
        //geo: geoPoint,
        maxAllowed: 60,
        slotDuration: 60,
        closedOn: ["Saturday", "Sunday"],
        breakStartHour: 13,
        breakStartMinute: 30,
        breakEndHour: 14,
        breakEndMinute: 30,
        startTimeHour: 10,
        startTimeMinute: 30,
        endTimeHour: 21,
        endTimeMinute: 0,
        parentId: null,
        type: "Mall",
        isBookable: false,
        isActive: true,
        coordinates: geoPoint);

    try {
      await EntityService().upsertEntity(entity, "testReg");
    } catch (e) {
      print("Exception occured " + e.toString());
    }
  }

  void updateEntity(String name) async {
    Entity ent = await EntityService().getEntity("Entity101");
    ent.name = name;

    Address adrs = new Address(
        city: "Hyderbad",
        state: "Telangana",
        country: "India",
        address: "Shop 10, Gachibowli");

    try {
      await EntityService().upsertEntity(ent, null);
    } catch (e) {
      print("Exception occured " + e.toString());
    }
  }

  void createChildEntityAndAddToParent(
      String id, String name, bool isActive) async {
    Address adrs = new Address(
        city: "Hyderbad",
        state: "Telangana",
        country: "India",
        address: "Shop 10, Gachibowli");

    MyGeoFirePoint geoPoint = new MyGeoFirePoint(12.960632, 77.641603);

    Entity child1 = new Entity(
        entityId: id,
        name: name, //just some random number,
        address: adrs,
        advanceDays: 5,
        isPublic: true,
        maxAllowed: 50,
        slotDuration: 30,
        closedOn: ["Saturday", "Sunday"],
        breakStartHour: 13,
        breakStartMinute: 15,
        breakEndHour: 14,
        breakEndMinute: 30,
        startTimeHour: 10,
        startTimeMinute: 30,
        endTimeHour: 21,
        endTimeMinute: 0,
        parentId: null,
        type: "Shop",
        isBookable: true,
        isActive: isActive,
        coordinates: geoPoint);
    try {
      bool added = await EntityService()
          .upsertChildEntityToParent(child1, 'Entity101', "testregnum");
    } catch (e) {
      print("Exception while creating Child101: " + e.toString());
    }
    print("Child1 created....");
  }

  void updateChildEntity(String id, String name) {
    Address adrs = new Address(
        city: "Hyderbad",
        state: "Telangana",
        country: "India",
        address: "Shop 10, Gachibowli");

    MyGeoFirePoint geoPoint = new MyGeoFirePoint(12.960632, 77.641603);

    Entity child1 = new Entity(
        entityId: id,
        name: "Bata",
        address: adrs,
        advanceDays: 5,
        isPublic: true,
        //geo: geoPoint,
        maxAllowed: 50,
        slotDuration: 30,
        closedOn: ["Saturday", "Sunday"],
        breakStartHour: 13,
        breakStartMinute: 15,
        breakEndHour: 14,
        breakEndMinute: 30,
        startTimeHour: 10,
        startTimeMinute: 30,
        endTimeHour: 21,
        endTimeMinute: 0,
        parentId: null,
        type: "Shop",
        isBookable: true,
        isActive: true,
        coordinates: geoPoint);
  }

  Future<void> createEntity2() async {
    Address adrs = new Address(
        city: "Hyderbad",
        state: "Telangana",
        country: "India",
        address: "Shop 10, Gachibowli");

    MyGeoFirePoint geoPoint = new MyGeoFirePoint(12.960632, 77.641603);
    Entity entity = new Entity(
        entityId: "Entity102",
        name: "Habinaro",
        address: adrs,
        advanceDays: 3,
        isPublic: true,
        //geo: geoPoint,
        maxAllowed: 60,
        slotDuration: 60,
        closedOn: ["Saturday", "Sunday"],
        breakStartHour: 13,
        breakStartMinute: 30,
        breakEndHour: 14,
        breakEndMinute: 30,
        startTimeHour: 10,
        startTimeMinute: 30,
        endTimeHour: 21,
        endTimeMinute: 0,
        parentId: null,
        type: "Store",
        isBookable: false,
        isActive: true,
        coordinates: geoPoint);

    try {
      await EntityService().upsertEntity(entity, "");
    } catch (e) {
      print("Exception occured " + e.toString());
    }
  }

  void clearAll() async {
    try {
      await TokenService().deleteSlot("Child101-1#2020~7~6");
      await TokenService().deleteSlot("Child101-1#2020~7~7");
      await TokenService().deleteSlot("Child101-1#2020~7~8");

      await TokenService()
          .deleteToken("Child101-1#2020~7~6#10~30#+916052069984");
      await TokenService()
          .deleteToken("Child101-1#2020~7~7#10~30#+916052069984");
      await TokenService()
          .deleteToken("Child101-1#2020~7~7#12~30#+916052069984");
      await TokenService()
          .deleteToken("Child101-1#2020~7~8#10~30#+916052069984");
      await EntityService().deleteEntity('Entity101');

      await EntityService().deleteEntity('Entity102');
      //delete user
      await UserService().deleteCurrentUser();
    } catch (e) {}
  }

  void dbCall1() async {
    await clearAll();
    //await securityPermissionTests();
    await tests();
  }

  Future<void> securityPermissionTests() async {
    await updateEntity("Inorbit_AdminCheck");
    await EntityService().assignAdmin('Child101-1', "+913611009823");
    await EntityService().assignAdmin('Entity102', "+913611009823");
    await EntityService().removeAdmin('Entity102', "+913611009823");
    await EntityService().assignAdmin('Entity102', "+913611009823");
  }

  void tests() async {
    final FirebaseUser fireUser = await FirebaseAuth.instance.currentUser();
    Firestore fStore = Firestore.instance;

    print(
        "<==================================TESTING STARTED==========================================>");

    Configurations conf = await ConfigurationService().getConfigurations();

    User u = await UserService().getCurrentUser();

    try {
      await createChildEntityAndAddToParent(
          'Child101-1', "Bata", true); //should fail as entity does not exists
    } catch (EntityDoesNotExistsException) {
      print(
          "EntityService.upsertChildEntityToParent (expected exception thrown) --> SUCCESS");
    }
    await createEntity();

    await createEntity2();

    await createChildEntityAndAddToParent('Child101-1', "Bata", true);

    await EntityService().assignAdmin('Child101-1', "+913611009823");

    await createChildEntityAndAddToParent('Child101-2', "Habinaro", true);

    await updateEntity("Inorbit_Modified");

    await createChildEntityAndAddToParent('Child101-3', "Raymonds", false);

    await updateEntity("Inorbit_Modified_Again");

    Entity ent = await EntityService().getEntity('Entity101');

    Entity child1 = await EntityService().getEntity('Child101-1');

    Entity child2 = await EntityService().getEntity('Child101-2');

    Entity child3 = await EntityService().getEntity('Child101-3');

    UserToken tok1 = await TokenService().generateToken(
        child1.getMetaEntity(), new DateTime(2020, 7, 6, 10, 30, 0, 0));

    UserToken tok21 = await TokenService().generateToken(
        child1.getMetaEntity(), new DateTime(2020, 7, 7, 12, 30, 0, 0));

    UserToken tok22 = await TokenService().generateToken(
        child1.getMetaEntity(), new DateTime(2020, 7, 7, 10, 30, 0, 0));

    UserToken tok3 = await TokenService().generateToken(
        child1.getMetaEntity(), new DateTime(2020, 7, 8, 10, 30, 0, 0));

    List<UserToken> toks = await TokenService().getAllTokensForCurrentUser(
        new DateTime(2020, 7, 8), new DateTime(2020, 7, 9));

    bool isAdminAssignedOnEntity = false;

    // for (MetaUser me in child1.admins) {
    //   if (me.ph == '+913611009823') {
    //     isAdminAssignedOnEntity = true;
    //     break;
    //   }
    // }

    final DocumentReference entityPrivateRef = fStore
        .document('entities/' + child1.entityId + '/private_data/private');
    DocumentSnapshot doc = await entityPrivateRef.get();

    EntityPrivate ePrivate;
    if (doc.exists) {
      Map<String, dynamic> map = doc.data;
      ePrivate = EntityPrivate.fromJson(map);
      if (ePrivate.roles['+913611009823'] == "admin") {
        isAdminAssignedOnEntity = true;
      }
    }

    if (isAdminAssignedOnEntity) {
      print("EntityService.assignAdmin --> SUCCESS");
    } else {
      print("EntityService.assignAdmin -----------------------> FAILURE");
    }

    final DocumentReference userRef = fStore.document('users/+913611009823');
    DocumentSnapshot doc1 = await userRef.get();
    User newAdmin;
    if (doc1.exists) {
      Map<String, dynamic> map = doc1.data;
      newAdmin = User.fromJson(map);
    }

    bool isEntityAddedToAdmin = false;

    if (newAdmin != null) {
      for (MetaEntity me in newAdmin.entities) {
        if (me.entityId == "Child101-1") {
          isEntityAddedToAdmin = true;
          break;
        }
      }
    } else {
      print("UserService.getCurrentUser -----------------------> FAILURE");
    }

    if (isEntityAddedToAdmin) {
      print("EntityService.assignAdmin --> SUCCESS");
    } else {
      print(
          "EntityService.assignAdmin ------------------------------> FAILURE");
    }

    if (toks != null && toks.length == 1) {
      print("TokenService.getAllTokensForCurrentUser --> SUCCESS");
    } else {
      print(
          "TokenService.getAllTokensForCurrentUser -----------------------> FAILURE");
    }

    List<UserToken> toksBetween6thAnd9th = await TokenService()
        .getAllTokensForCurrentUser(
            new DateTime(2020, 7, 6), new DateTime(2020, 7, 9));

    if (toksBetween6thAnd9th != null && toksBetween6thAnd9th.length == 4) {
      print("TokenService.getAllTokensForCurrentUser --> SUCCESS");
    } else {
      print(
          "TokenService.getAllTokensForCurrentUser -----------------------> FAILURE");
    }

    List<UserToken> allToksFromToday = await TokenService()
        .getAllTokensForCurrentUser(new DateTime(2020, 7, 7), null);

    if (allToksFromToday != null && allToksFromToday.length >= 3) {
      //should get all the tokens from 7th June onwards
      print("TokenService.getAllTokensForCurrentUser --> SUCCESS");
    } else {
      print(
          "TokenService.getAllTokensForCurrentUser -----------------------> FAILURE");
    }

    EntitySlots es = await TokenService()
        .getEntitySlots('Child101-1', new DateTime(2020, 7, 7));

    if (es != null && es.slots.length == 2) {
      print("TokenService.getEntitySlots --> SUCCESS");
    } else {
      print("TokenService.getEntitySlots -----------------------> FAILURE");
    }

    List<UserToken> toksForDayForEntity = await TokenService()
        .getTokensForEntityBookedByCurrentUser(
            'Child101-1', new DateTime(2020, 7, 7));

    if (toksForDayForEntity.length == 2) {
      print("TokenService.getTokensForEntityBookedByCurrentUser --> SUCCESS");
    } else {
      print(
          "TokenService.getTokensForEntityBookedByCurrentUser ------------------------> FAILURE");
    }

    await TokenService().cancelToken("Child101-1#2020~7~7#10~30#+916052069984");

    EntitySlots esWithCancelledSlot = await TokenService()
        .getEntitySlots('Child101-1', new DateTime(2020, 7, 7));

    if (esWithCancelledSlot != null && esWithCancelledSlot.slots.length == 2) {
      bool isSuccess = false;
      for (Slot s in esWithCancelledSlot.slots) {
        if (s.maxAllowed == 51) {
          isSuccess = true;
        }
      }
      if (isSuccess) {
        print("TokenService.getEntitySlots --> SUCCESS");
      } else {
        print(
            "TokenService.getEntitySlots -----------------------> FAILURE --> Cancellation of token should have increased maxAllowed");
      }
    } else {
      print("TokenService.getEntitySlots -----------------------> FAILURE");
    }

    print("----------Search Only Type--with Name null ----------");

    List<Entity> entitiesByTypeAndNameNull = await EntityService()
        .search(null, "Shop", 12.970632, 77.641603, 2, 1, 2);

    for (Entity me in entitiesByTypeAndNameNull) {
      print(me.name + ":" + me.distance.toString());
    }

    if (entitiesByTypeAndNameNull != null &&
        entitiesByTypeAndNameNull.length == 2) {
      print("EntityService.search --> SUCCESS");
    } else {
      print("EntityService.search -----------------------> FAILURE");
    }

    print("----------Search Only Partial Name-- Type null-----------");

    List<Entity> entitiesByTypeNullAndName =
        await EntityService().search("Habi", "", 12.970632, 77.641603, 2, 1, 2);

    for (Entity me in entitiesByTypeNullAndName) {
      print(me.name + ":" + me.distance.toString());
    }

    if (entitiesByTypeNullAndName != null &&
        entitiesByTypeNullAndName.length == 2) {
      print("EntityService.search --> SUCCESS");
    } else {
      print("EntityService.search -----------------------> FAILURE");
    }

    print("---------Search By Partial Name and Type --------------");

    List<Entity> entitiesByTypeAndName = await EntityService()
        .search("Bat", "Shop", 12.970632, 77.641603, 2, 1, 2);

    for (Entity me in entitiesByTypeAndName) {
      print(me.name + ":" + me.distance.toString());
    }

    if (entitiesByTypeAndName != null && entitiesByTypeAndName.length == 1) {
      print("EntityService.search --> SUCCESS");
    } else {
      print("EntityService.search -----------------------> FAILURE");
    }

    print(
        "---------Search By Name and Type again for 2 Habi but of different type--------------");

    List<Entity> entitiesByTypeAndNameAgain = await EntityService()
        .search("Habina", "Shop", 12.970632, 77.641603, 2, 1, 2);

    for (Entity me in entitiesByTypeAndNameAgain) {
      print(me.name + ":" + me.distance.toString());
    }

    if (entitiesByTypeAndNameAgain != null &&
        entitiesByTypeAndNameAgain.length == 1) {
      print("EntityService.search --> SUCCESS");
    } else {
      print("EntityService.search -----------------------> FAILURE");
    }

    print(
        "---------Search By Name and Type Store (no intersection) --------------");

    List<Entity> noIntersection = await EntityService()
        .search("Bata", "Store", 12.970632, 77.641603, 2, 1, 2);

    for (Entity me in noIntersection) {
      print(me.name + ":" + me.distance.toString());
    }

    if (noIntersection != null && noIntersection.length == 0) {
      print("EntityService.search --> SUCCESS");
    } else {
      print("EntityService.search -----------------------> FAILURE");
    }

    await EntityService().removeAdmin('Child101-1', "+913611009823");

    Entity child101 = await EntityService().getEntity('Child101-1');

    bool isAdminRemovedFromEntity = true;
    // for (MetaUser me in child101.admins) {
    //   if (me.ph == '+913611009823') {
    //     isAdminRemovedFromEntity = false;
    //     break;
    //   }
    // }

    final DocumentReference child101PrivateRef = fStore
        .document('entities/' + child1.entityId + '/private_data/private');
    DocumentSnapshot docChild101 = await child101PrivateRef.get();

    EntityPrivate ePrivateChild101;
    if (doc.exists) {
      Map<String, dynamic> map = docChild101.data;
      ePrivateChild101 = EntityPrivate.fromJson(map);
      if (ePrivateChild101.roles['+913611009823'] == "admin") {
        isAdminAssignedOnEntity = false;
      }
    }

    if (isAdminRemovedFromEntity) {
      print("EntityService.removeAdmin --> SUCCESS");
    } else {
      print("EntityService.removeAdmin -----------------------> FAILURE");
    }

    DocumentSnapshot removedAdminDoc = await userRef.get();
    User removedAdmin;
    if (doc.exists) {
      Map<String, dynamic> map = removedAdminDoc.data;
      removedAdmin = User.fromJson(map);
    }

    bool isEntityRemovedFromAdmin = true;

    if (removedAdmin != null) {
      for (MetaEntity me in removedAdmin.entities) {
        if (me.entityId == "Child101-1") {
          isEntityRemovedFromAdmin = false;
          break;
        }
      }
    } else {
      print("TokenService.getCurrentUser -----------------------> FAILURE");
    }

    if (isEntityRemovedFromAdmin) {
      print("EntityService.removeAdmin --> SUCCESS");
    } else {
      print("EntityService.removeAdmin -----------------------> FAILURE");
    }

    //----------

    await EntityService().addEntityToUserFavourite(child101.getMetaEntity());

    User curUser = await UserService().getCurrentUser();

    bool isEntityAddedToCurrentUser = false;

    if (curUser != null) {
      for (MetaEntity me in curUser.favourites) {
        if (me.entityId == "Child101-1") {
          isEntityAddedToCurrentUser = true;
          break;
        }
      }
    } else {
      print("TokenService.getCurrentUser -----------------------> FAILURE");
    }

    if (isEntityAddedToCurrentUser) {
      print("EntityService.addEntityToUserFavourite --> SUCCESS");
    } else {
      print(
          "EntityService.addEntityToUserFavourite -----------------------> FAILURE");
    }

    await EntityService().removeEntityFromUserFavourite("Child101-1");

    curUser = await UserService().getCurrentUser();

    bool isEntityRemovedFromCurrentUser = true;

    if (curUser != null) {
      for (MetaEntity me in curUser.favourites) {
        if (me.entityId == "Child101-1") {
          isEntityRemovedFromCurrentUser = false;
          break;
        }
      }
    } else {
      print("TokenService.getCurrentUser -----------------------> FAILURE");
    }

    if (isEntityRemovedFromCurrentUser) {
      print("EntityService.removeEntityFromUserFavourite --> SUCCESS");
    } else {
      print(
          "EntityService.removeEntityFromUserFavourite -----------------------> FAILURE");
    }

    //---- Update child entity with upsertChild method which should update the metaEntity in the parentEntity and Admin user
    await updateChild101();

    Entity parentEnt = await EntityService().getEntity('Entity101');
    bool metaNameChangedInParent = false;
    for (MetaEntity me in parentEnt.childEntities) {
      if (me.name == "Bata updated") {
        metaNameChangedInParent = true;
        break;
      }
    }

    if (metaNameChangedInParent) {
      print(
          "EntityService.upsertChildEntityToParent (metaEntity updated in the Parent) --> SUCCESS");
    } else {
      print(
          "EntityService.upsertChildEntityToParent (metaEntity updated in the Parent) --> Failure");
    }

    User user = await UserService().getCurrentUser();

    bool metaNameChangedInAdminUser = false;

    for (MetaEntity me in user.entities) {
      if (me.name == "Bata updated") {
        metaNameChangedInAdminUser = true;
        break;
      }
    }

    if (metaNameChangedInAdminUser) {
      print(
          "EntityService.upsertChildEntityToParent (metaEntity updated in the Admin) --> SUCCESS");
    } else {
      print(
          "EntityService.upsertChildEntityToParent (metaEntity updated in the Admin) ---------------------> Failure");
    }

    print(
        "<==========================================TESTING DONE=========================================>");

    int i = 0;
  }

  Future<void> updateChild101() async {
    Address adrs = new Address(
        city: "Hyderbad",
        state: "Telangana",
        country: "India",
        address: "Shop 10, Gachibowli");

    MyGeoFirePoint geoPoint = new MyGeoFirePoint(12.960632, 77.641603);
    Entity entity = new Entity(
        entityId: "Child101-1",
        name: "Bata updated",
        address: adrs,
        advanceDays: 3,
        isPublic: true,
        maxAllowed: 60,
        slotDuration: 60,
        closedOn: ["Saturday", "Sunday"],
        breakStartHour: 13,
        breakStartMinute: 30,
        breakEndHour: 14,
        breakEndMinute: 30,
        startTimeHour: 10,
        startTimeMinute: 30,
        endTimeHour: 21,
        endTimeMinute: 0,
        parentId: 'Entity101',
        type: "Shop",
        isBookable: false,
        isActive: true,
        coordinates: geoPoint);

    try {
      await EntityService()
          .upsertChildEntityToParent(entity, "Entity101", "SampleChildRegNum");
    } catch (e) {
      print("Exception occured " + e.toString());
    }
  }
}
