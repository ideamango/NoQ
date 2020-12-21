import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:noq/db/db_model/address.dart';
import 'package:noq/db/db_model/configurations.dart';
import 'package:noq/db/db_model/employee.dart';
import 'package:noq/db/db_model/entity.dart';
import 'package:noq/db/db_model/entity_private.dart';
import 'package:noq/db/db_model/entity_slots.dart';
import 'package:noq/db/db_model/meta_entity.dart';
import 'package:noq/db/db_model/my_geo_fire_point.dart';
import 'package:noq/db/db_model/offer.dart';
import 'package:noq/db/db_model/slot.dart';
import 'package:noq/db/db_model/app_user.dart';
import 'package:noq/db/db_model/user_token.dart';
import 'package:noq/db/db_service/configurations_service.dart';
import 'package:noq/db/db_service/entity_service.dart';
import 'package:noq/db/db_service/token_service.dart';
import 'package:noq/db/db_service/user_service.dart';
import 'package:noq/events/event_bus.dart';
import 'package:noq/events/events.dart';
import 'package:noq/events/local_notification_data.dart';
import 'package:noq/constants.dart';

class DBTest {
  Future<void> createEntity() async {
    Address adrs = new Address(
        city: "Hyderbad",
        state: "Telangana",
        country: "India",
        address: "Shop 10, Gachibowli");

    MyGeoFirePoint geoPoint = new MyGeoFirePoint(17.444317, 78.355321);
    Entity entity = new Entity(
        entityId: "Entity101",
        name: "Inorbit",
        address: adrs,
        advanceDays: 3,
        isPublic: true,
        //geo: geoPoint,
        maxAllowed: 60,
        slotDuration: 60,
        closedOn: [WEEK_DAY_SATURDAY, WEEK_DAY_SUNDAY],
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
      entity.regNum = "testReg";
      await EntityService().upsertEntity(entity);
    } catch (e) {
      print("Exception occured " + e.toString());
    }
  }

  Future<void> updateChildEntityBataWithOfferAndManager() async {
    Entity ent = await EntityService().getEntity("Child101-1");

    Address adrs = new Address(
        city: "Hyderbad",
        state: "Telangana",
        country: "India",
        address: "Shop 10, Gachibowli");

    //update the offer and manager

    Offer offer = new Offer(
        message: "Get 10% off on branded items",
        startDateTime: new DateTime(2020, 8, 13, 10, 30, 0, 0),
        endDateTime: new DateTime(2020, 8, 20, 10, 30, 0, 0),
        coupon: "Coup10");

    Employee manager1 = new Employee(
        name: "Manager1 LName",
        ph: "+91999999999",
        employeeId: "Emp410",
        shiftStartHour: 9,
        shiftStartMinute: 30,
        shiftEndHour: 8,
        shiftEndMinute: 30);

    ent.address = adrs;
    ent.offer = offer;
    if (ent.managers == null) {
      ent.managers = new List<Employee>();
    }
    ent.managers.add(manager1);

    try {
      ent.regNum = "BataRegNumber";
      await EntityService().upsertEntity(ent);
    } catch (e) {
      print("Exception occured " + e.toString());
    }
  }

  Future<void> updateEntity(String name) async {
    Entity ent = await EntityService().getEntity("Entity101");
    ent.name = name;

    Address adrs = new Address(
        city: "Hyderbad",
        state: "Telangana",
        country: "India",
        address: "Shop 10, Gachibowli");

    try {
      await EntityService().upsertEntity(ent);
    } catch (e) {
      print("Exception occured " + e.toString());
    }
  }

  Future<void> createChildEntityAndAddToParent(
      String id, String name, bool isActive) async {
    Address adrs = new Address(
        city: "Hyderbad",
        state: "Telangana",
        country: "India",
        address: "Shop 10, Gachibowli");

    MyGeoFirePoint geoPoint = new MyGeoFirePoint(17.444317, 78.355321);

    Entity child1 = new Entity(
        entityId: id,
        name: name, //just some random number,
        address: adrs,
        advanceDays: 5,
        isPublic: true,
        maxAllowed: 50,
        slotDuration: 30,
        closedOn: [WEEK_DAY_SATURDAY, WEEK_DAY_SUNDAY],
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
      child1.regNum = "testregnum";
      bool added =
          await EntityService().upsertChildEntityToParent(child1, 'Entity101');
    } catch (e) {
      print("Exception while creating Child101: " + e.toString());
      throw e;
    }
    print("Child1 created....");
  }

  void updateChildEntity(String id, String name) {
    Address adrs = new Address(
        city: "Hyderbad",
        state: "Telangana",
        country: "India",
        address: "Shop 10, Gachibowli");

    MyGeoFirePoint geoPoint = new MyGeoFirePoint(17.444317, 78.355321);

    Entity child1 = new Entity(
        entityId: id,
        name: "Bata",
        address: adrs,
        advanceDays: 5,
        isPublic: true,
        //geo: geoPoint,
        maxAllowed: 50,
        slotDuration: 30,
        closedOn: [WEEK_DAY_SATURDAY, WEEK_DAY_SUNDAY],
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

    MyGeoFirePoint geoPoint =
        new MyGeoFirePoint(17.430290, 78.324762); //yum yum tree
    Entity entity = new Entity(
        entityId: "Entity102",
        name: "Habinaro",
        address: adrs,
        advanceDays: 3,
        isPublic: false,
        //geo: geoPoint,
        maxAllowed: 3,
        slotDuration: 60,
        closedOn: [WEEK_DAY_SATURDAY, WEEK_DAY_SUNDAY],
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

    // Employee manager1 = new Employee(name: "Rakesh", ph: "+91888888888", employeeId: "empyId", shiftStartHour: );

    try {
      await EntityService().upsertEntity(entity);
    } catch (e) {
      print("Exception occured " + e.toString());
    }
  }

  void fireLocalNotificationEvent() {
    LocalNotificationData dataFor10Sec = new LocalNotificationData(
        dateTime: DateTime.now().add(new Duration(seconds: 10)),
        id: 1,
        title: "Appointment",
        message: "Token ");
    EventBus.fireEvent(LOCAL_NOTIFICATION_CREATED_EVENT, null, dataFor10Sec);

    LocalNotificationData dataFor20Sec = new LocalNotificationData(
        dateTime: DateTime.now().add(new Duration(seconds: 20)),
        id: 2,
        title: "Appointment in 15 minutes at " + "Habinaro",
        message: "Gentle reminder for your token number " +
            "HAB-201012-0530-1" +
            " at " +
            "Habinaro" +
            ". Please be on time and follow social distancing norms.");
    EventBus.fireEvent(LOCAL_NOTIFICATION_CREATED_EVENT, null, dataFor20Sec);
  }

  Future<void> clearAll() async {
    try {
      await EntityService().deleteEntity('SportsEntity103');
      await EntityService().deleteEntity('SportsEntity104');
      await EntityService().deleteEntity('SportsEntity105');
      await EntityService().deleteEntity('BankEntity106');
      await EntityService().deleteEntity('SalonEntity107');
      await EntityService().deleteEntity('SalonEntity108');
      await EntityService().deleteEntity('GymEntity109');
      await EntityService().deleteEntity('GymEntity110');

      await TokenService().deleteSlot("Child101-1#2020~7~6");
      await TokenService().deleteSlot("Child101-1#2020~7~7");
      await TokenService().deleteSlot("Child101-1#2020~7~8");

      await TokenService()
          .deleteToken("Child101-1#2020~7~6#10~30#+919999999999");
      await TokenService()
          .deleteToken("Child101-1#2020~7~7#10~30#+919999999999");
      await TokenService()
          .deleteToken("Child101-1#2020~7~7#12~30#+919999999999");
      await TokenService()
          .deleteToken("Child101-1#2020~7~8#10~30#+919999999999");
      await EntityService().deleteEntity('Entity101');

      await EntityService().deleteEntity('Entity102');
      //delete user
      await UserService().deleteCurrentUser();
    } catch (e) {
      print("Error occurred in cleaning.. may be DB is already cleaned.");
    }
  }

  void dbCall() async {
    // FirebaseCrashlytics.instance.crash();
    // GlobalState gs = await GlobalState.getGlobalState();
    // gs.initializeNotification();
    fireLocalNotificationEvent();

    await clearAll();
    await tests();
    await createDummyPlaces();
    await securityPermissionTests();
  }

  Future<void> securityPermissionTests() async {
    print("Security permission test started.. ");

    updateEntity("Inorbit_AdminCheck");
    await EntityService().assignAdmin('Child101-1', "+913611009823");
    await EntityService().assignAdmin('Entity102', "+913611009823");
    await EntityService().removeAdmin('Entity102', "+913611009823");
    await EntityService().assignAdmin('Entity102', "+913611009823");

    print("Security permission test completed.");
  }

  Future<void> tests() async {
    final User fireUser = FirebaseAuth.instance.currentUser;
    FirebaseFirestore fStore = FirebaseFirestore.instance;

    print(
        "<==================================TESTING STARTED==========================================>");

    Configurations conf = await ConfigurationService().getConfigurations();

    AppUser u = await UserService().getCurrentUser();

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

    print("Token generation started..");

    try {
      UserToken tok1 = await TokenService().generateToken(
          child1.getMetaEntity(), new DateTime(2020, 7, 6, 10, 30, 0, 0));
    } catch (e) {
      print("generate token threw Slotful exception");
    }

    print("Tok1 generated");

    UserToken tok21 = await TokenService().generateToken(
        child1.getMetaEntity(), new DateTime(2020, 7, 7, 12, 30, 0, 0));
    print("Tok21 generated");

    UserToken tok22 = await TokenService().generateToken(
        child1.getMetaEntity(), new DateTime(2020, 7, 7, 10, 30, 0, 0));
    print("Tok22 generated");

    UserToken tok3 = await TokenService().generateToken(
        child1.getMetaEntity(), new DateTime(2020, 7, 8, 10, 30, 0, 0));
    print("Tok3 generated");

    print("Token generation ended.");

    List<UserToken> toks = await TokenService().getAllTokensForCurrentUser(
        new DateTime(2020, 7, 8), new DateTime(2020, 7, 9));
    print("Got the Tokens between 8th July and 9th July: " +
        toks.length.toString());

    bool isAdminAssignedOnEntity = false;

    // for (MetaUser me in child1.admins) {
    //   if (me.ph == '+913611009823') {
    //     isAdminAssignedOnEntity = true;
    //     break;
    //   }
    // }

    final DocumentReference entityPrivateRef =
        fStore.doc('entities/' + child1.entityId + '/private_data/private');
    DocumentSnapshot doc = await entityPrivateRef.get();

    EntityPrivate ePrivate;
    if (doc.exists) {
      Map<String, dynamic> map = doc.data();
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

    final DocumentReference userRef = fStore.doc('users/+913611009823');
    DocumentSnapshot doc1 = await userRef.get();
    AppUser newAdmin;
    if (doc1.exists) {
      Map<String, dynamic> map = doc1.data();
      newAdmin = AppUser.fromJson(map);
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
      print("EntityService.assignAdmin ---> SUCCESS");
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

    bool isTokenCancelled = await TokenService()
        .cancelToken("Child101-1#2020~7~7#10~30#+919999999999");

    if (!isTokenCancelled) {
      print("TokenService.cancelToken ------> FAILURE");
    }

    List<UserToken> toksForDayForEntityAfterCancellation = await TokenService()
        .getTokensForEntityBookedByCurrentUser(
            'Child101-1', new DateTime(2020, 7, 7));
    for (UserToken tokenOnSeventh in toksForDayForEntityAfterCancellation) {
      if (tokenOnSeventh.slotId + "#" + tokenOnSeventh.userId ==
          "Child101-1#2020~7~7#10~30#+919999999999") {
        if (tokenOnSeventh.number == -1) {
          print("TokenService.cancelToken ------> Success");
        } else {
          print("TokenService.cancelToken --------------------> FAILURE");
        }
      }
    }

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

    List<Entity> entitiesByTypeAndNameNull =
        await EntityService().search(null, "Shop", 17.4338, 78.3321, 2, 1, 2);

    for (Entity me in entitiesByTypeAndNameNull) {
      print(me.name + ":" + me.distance.toString());
    }

    if (entitiesByTypeAndNameNull != null &&
        entitiesByTypeAndNameNull.length >= 2) {
      print("EntityService.search --> SUCCESS");
    } else {
      print("EntityService.search -----------------------> FAILURE");
    }

    print("----------Search Only Partial Name-- Type null-----------");

    List<Entity> entitiesByTypeNullAndName =
        await EntityService().search("Habi", "", 17.4338, 78.3321, 2, 1, 2);

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

    List<Entity> entitiesByTypeAndName =
        await EntityService().search("Bat", "Shop", 17.4338, 78.3321, 2, 1, 2);

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
        .search("Habina", "Shop", 17.4338, 78.3321, 2, 1, 2);

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
        .search("Bata", "Store", 17.4338, 78.3321, 2, 1, 2);

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

    final DocumentReference child101PrivateRef =
        fStore.doc('entities/' + child1.entityId + '/private_data/private');
    DocumentSnapshot docChild101 = await child101PrivateRef.get();

    EntityPrivate ePrivateChild101;
    if (doc.exists) {
      Map<String, dynamic> map = docChild101.data();
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
    AppUser removedAdmin;
    if (doc.exists) {
      Map<String, dynamic> map = removedAdminDoc.data();
      removedAdmin = AppUser.fromJson(map);
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

    AppUser curUser = await UserService().getCurrentUser();

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

    AppUser user = await UserService().getCurrentUser();

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

    await updateChildEntityBataWithOfferAndManager();

    Entity bata = await EntityService().getEntity('Child101-1');

    if (bata.offer != null &&
        bata.offer.coupon == "Coup10" &&
        bata.managers != null &&
        bata.managers[0].employeeId == "Emp410") {
      print("Offer and Manager added on Entity --> SUCCESS");
    } else {
      print(
          "Offer and Manager added on Entity ------------------------------> Failure");
    }

    bool admin6955 =
        await EntityService().assignAdmin("Child101-3", "+919611006955");

    print(
        "+919611006955 added as an admin to the Child101-3, check on the real device");

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

    MyGeoFirePoint geoPoint =
        new MyGeoFirePoint(17.433643, 78.369051); //sweet basket, gachibowli
    Entity entity = new Entity(
        entityId: "Child101-1",
        name: "Bata updated",
        address: adrs,
        advanceDays: 3,
        isPublic: true,
        maxAllowed: 60,
        slotDuration: 60,
        closedOn: [WEEK_DAY_SATURDAY, WEEK_DAY_SUNDAY],
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
        coordinates: geoPoint,
        phone: "+919611009823",
        whatsapp: "+919611009823");

    try {
      entity.regNum = "SampleChildRegNum";
      await EntityService().upsertChildEntityToParent(entity, "Entity101");
    } catch (e) {
      print("Exception occured " + e.toString());
    }
  }

  Future<void> createDummyPlaces() async {
    print("Creating dummy places...");

    await createSportCenter();
    await createSportCenter2();
    await createSportCenter3();

    await createBank();
    await createSalon();
    await createSalon2();

    await createGym();
    await createPrivateGym();

    print("Dummy place creation completed.");
  }

  Future<void> createSportCenter() async {
    Address adrs = new Address(
        city: "Hyderbad",
        state: "Telangana",
        country: "India",
        address: "Shop 121, Row 5, Gachibowli",
        landmark: "Behind Max Plaza");

    Offer offer = new Offer();
    offer.coupon = "Coup10";
    offer.message = "Avail 10% off on booking betwee 1 PM to 5 PM on weekdays";

    MyGeoFirePoint geoPoint = new MyGeoFirePoint(17.444317, 78.355321);
    Entity entity = new Entity(
        entityId: "SportsEntity103",
        name: "Place Sport",
        address: adrs,
        advanceDays: 5,
        isPublic: true,
        maxAllowed: 60,
        slotDuration: 60,
        closedOn: [WEEK_DAY_TUESDAY],
        breakStartHour: 13,
        breakStartMinute: 30,
        breakEndHour: 14,
        breakEndMinute: 30,
        startTimeHour: 10,
        startTimeMinute: 30,
        endTimeHour: 21,
        endTimeMinute: 0,
        parentId: null,
        type: PLACE_TYPE_SPORTS,
        isBookable: true,
        isActive: true,
        verificationStatus: VERIFICATION_VERIFIED,
        coordinates: geoPoint,
        offer: offer,
        paytm: "+919611009823",
        phone: "+918328592031",
        gpay: "+919611009823",
        whatsapp: "+918328592031");

    try {
      entity.regNum = "testReg111";
      await EntityService().upsertEntity(entity);
    } catch (e) {
      print("Exception occured " + e.toString());
    }
  }

  Future<void> createSportCenter2() async {
    Address adrs = new Address(
        city: "Hyderbad",
        state: "Telangana",
        country: "India",
        address: "Shop 121, Row 5, Gachibowli");

    MyGeoFirePoint geoPoint = new MyGeoFirePoint(17.444317, 78.355321);
    Entity entity = new Entity(
        entityId: "SportsEntity104",
        name: "Place Sports Center 2",
        address: adrs,
        advanceDays: 3,
        isPublic: true,
        maxAllowed: 60,
        slotDuration: 60,
        closedOn: [WEEK_DAY_TUESDAY, WEEK_DAY_THURSDAY],
        breakStartHour: 13,
        breakStartMinute: 30,
        breakEndHour: 14,
        breakEndMinute: 30,
        startTimeHour: 10,
        startTimeMinute: 30,
        endTimeHour: 21,
        endTimeMinute: 0,
        parentId: null,
        type: PLACE_TYPE_SPORTS,
        isBookable: true,
        isActive: true,
        verificationStatus: VERIFICATION_PENDING,
        coordinates: geoPoint,
        offer: null,
        paytm: "+919611009823",
        phone: "+918328592031",
        gpay: "+919611009823",
        whatsapp: "+918328592031");

    try {
      entity.regNum = "testReg111";
      await EntityService().upsertEntity(
        entity,
      );
    } catch (e) {
      print("Exception occured " + e.toString());
    }
  }

  Future<void> createSportCenter3() async {
    Address adrs = new Address(
        city: "Hyderbad",
        state: "Telangana",
        country: "India",
        address: "Shop 121, Chowk Bazar, Gachibowli");

    Offer offer = new Offer();
    offer.coupon = "Coup10";
    offer.message = "Avail 10% off on booking betwee 1 PM to 5 PM on weekdays";

    MyGeoFirePoint geoPoint = new MyGeoFirePoint(17.444317, 78.355321);
    Entity entity = new Entity(
        entityId: "SportsEntity105",
        name: "Place Sports 3",
        address: adrs,
        advanceDays: 2,
        isPublic: true,
        maxAllowed: 60,
        slotDuration: 60,
        closedOn: null,
        breakStartHour: 13,
        breakStartMinute: 30,
        breakEndHour: 14,
        breakEndMinute: 30,
        startTimeHour: 10,
        startTimeMinute: 30,
        endTimeHour: 21,
        endTimeMinute: 0,
        parentId: null,
        type: PLACE_TYPE_SPORTS,
        isBookable: true,
        isActive: true,
        verificationStatus: VERIFICATION_REJECTED,
        coordinates: geoPoint,
        offer: offer,
        paytm: "+919611009823",
        phone: "+918328592031",
        gpay: "+919611009823",
        whatsapp: "+918328592031");

    try {
      entity.regNum = "testReg111";
      await EntityService().upsertEntity(entity);
    } catch (e) {
      print("Exception occured " + e.toString());
    }
  }

  Future<void> createBank() async {
    Address adrs = new Address(
        city: "Hyderbad",
        state: "Telangana",
        country: "India",
        address: "Shop 61, Towli Chowk Bazar, Gachibowli");

    Offer offer = new Offer();
    offer.coupon = "Coup10";
    offer.message = "Life time free credit cards!!";

    MyGeoFirePoint geoPoint = new MyGeoFirePoint(17.444317, 78.355321);
    Entity entity = new Entity(
        entityId: "BankEntity106",
        name: "Place Bank State of Peeru",
        address: adrs,
        advanceDays: 2,
        isPublic: true,
        maxAllowed: 60,
        slotDuration: 60,
        closedOn: null,
        breakStartHour: 13,
        breakStartMinute: 30,
        breakEndHour: 14,
        breakEndMinute: 30,
        startTimeHour: 10,
        startTimeMinute: 30,
        endTimeHour: 21,
        endTimeMinute: 0,
        parentId: null,
        type: PLACE_TYPE_BANK,
        isBookable: true,
        isActive: true,
        verificationStatus: VERIFICATION_PENDING,
        coordinates: geoPoint,
        offer: offer,
        paytm: "+919611009823",
        phone: "+918328592031",
        gpay: "+919611009823",
        whatsapp: "+918328592031");

    try {
      entity.regNum = "testReg111";
      await EntityService().upsertEntity(entity);
    } catch (e) {
      print("Exception occured " + e.toString());
    }
  }

  Future<void> createSalon() async {
    Address adrs = new Address(
        city: "Hyderbad",
        state: "Telangana",
        country: "India",
        address: "Shop 61, Towli Chowk Bazar, Gachibowli");

    Offer offer = new Offer();
    offer.coupon = "Coup20";
    offer.message =
        "20% off on Face packs, hurry offer for limited period only!!";
    offer.startDateTime = DateTime.now().add(Duration(days: 1));
    offer.endDateTime = DateTime.now().add(Duration(days: 10));

    MyGeoFirePoint geoPoint = new MyGeoFirePoint(17.444317, 78.355321);
    Entity entity = new Entity(
        entityId: "SalonEntity107",
        name: "Place Smarty Solon and Parlour",
        address: adrs,
        advanceDays: 2,
        isPublic: true,
        maxAllowed: 60,
        slotDuration: 60,
        closedOn: null,
        breakStartHour: 13,
        breakStartMinute: 30,
        breakEndHour: 14,
        breakEndMinute: 30,
        startTimeHour: 10,
        startTimeMinute: 30,
        endTimeHour: 21,
        endTimeMinute: 0,
        parentId: null,
        type: PLACE_TYPE_SALON,
        isBookable: true,
        isActive: true,
        verificationStatus: VERIFICATION_PENDING,
        coordinates: geoPoint,
        offer: offer,
        paytm: "+919611009823",
        phone: "+918328592031",
        gpay: "+919611009823",
        whatsapp: "+918328592031");

    try {
      entity.regNum = "testReg111";
      await EntityService().upsertEntity(entity);
    } catch (e) {
      print("Exception occured " + e.toString());
    }
  }

  Future<void> createSalon2() async {
    Address adrs = new Address(
        city: "Hyderbad",
        state: "Telangana",
        country: "India",
        address: "Shop 61, Towli Chowk Bazar, Gachibowli");

    Offer offer = new Offer();
    offer.coupon = "Coup20";
    offer.message =
        "20% off on Hair dressing, hurry offer for limited period only!!";
    offer.startDateTime = DateTime.now().add(Duration(days: 1));
    offer.endDateTime = DateTime.now().add(Duration(days: 5));

    MyGeoFirePoint geoPoint = new MyGeoFirePoint(17.444317, 78.355321);
    Entity entity = new Entity(
        entityId: "SalonEntity108",
        name: "Place Rocky Salon",
        address: adrs,
        advanceDays: 2,
        isPublic: true,
        maxAllowed: 60,
        slotDuration: 60,
        closedOn: null,
        breakStartHour: 13,
        breakStartMinute: 30,
        breakEndHour: 14,
        breakEndMinute: 30,
        startTimeHour: 10,
        startTimeMinute: 30,
        endTimeHour: 21,
        endTimeMinute: 0,
        parentId: null,
        type: PLACE_TYPE_SALON,
        isBookable: true,
        isActive: true,
        verificationStatus: VERIFICATION_PENDING,
        coordinates: geoPoint,
        offer: offer,
        paytm: "+919611009823",
        phone: "+918328592031",
        gpay: "+919611009823",
        whatsapp: "+918328592031");

    try {
      entity.regNum = "testReg111";
      await EntityService().upsertEntity(entity);
    } catch (e) {
      print("Exception occured " + e.toString());
    }
  }

  Future<void> createGym() async {
    Address adrs = new Address(
        city: "Hyderbad",
        state: "Telangana",
        country: "India",
        address: "Shop 61, Towli Chowk Bazar, Gachibowli");

    Offer offer = new Offer();
    offer.coupon = "Great Diwali Offer";
    offer.message = "Couple discount, offer valid till 31st March!";
    offer.startDateTime = DateTime.now();
    offer.endDateTime = DateTime.utc(2021, 11, 4);

    MyGeoFirePoint geoPoint = new MyGeoFirePoint(17.444317, 78.355321);
    Entity entity = new Entity(
        entityId: "GymEntity109",
        name: "Place Great Tyson Gymkhana",
        address: adrs,
        advanceDays: 7,
        isPublic: true,
        maxAllowed: 60,
        slotDuration: 60,
        closedOn: [WEEK_DAY_MONDAY],
        breakStartHour: 13,
        breakStartMinute: 30,
        breakEndHour: 14,
        breakEndMinute: 30,
        startTimeHour: 10,
        startTimeMinute: 30,
        endTimeHour: 21,
        endTimeMinute: 0,
        parentId: null,
        type: PLACE_TYPE_GYM,
        isBookable: true,
        isActive: true,
        verificationStatus: VERIFICATION_VERIFIED,
        coordinates: geoPoint,
        offer: offer,
        paytm: "+919611009823",
        phone: "+918328592031",
        gpay: "+919611009823",
        whatsapp: "+918328592031");

    try {
      entity.regNum = "testReg111";
      await EntityService().upsertEntity(entity);
    } catch (e) {
      print("Exception occured " + e.toString());
    }
  }

  Future<void> createPrivateGym() async {
    Address adrs = new Address(
        city: "Hyderbad",
        state: "Telangana",
        country: "India",
        address: "Shop 61, Towli Chowk Bazar, Gachibowli");

    Offer offer = new Offer();
    offer.coupon = "Great Diwali Offer";
    offer.message = "30% off for yearly subscription before Diwali 2021!!";
    offer.startDateTime = DateTime.now();
    offer.endDateTime = DateTime.utc(2021, 11, 4);

    MyGeoFirePoint geoPoint = new MyGeoFirePoint(17.444317, 78.355321);
    Entity entity = new Entity(
        entityId: "GymEntity110",
        name: "Place Great Private Gymkhana",
        address: adrs,
        advanceDays: 7,
        isPublic: false,
        maxAllowed: 60,
        slotDuration: 60,
        closedOn: [WEEK_DAY_THURSDAY],
        breakStartHour: 13,
        breakStartMinute: 30,
        breakEndHour: 14,
        breakEndMinute: 30,
        startTimeHour: 10,
        startTimeMinute: 30,
        endTimeHour: 21,
        endTimeMinute: 0,
        parentId: null,
        type: PLACE_TYPE_GYM,
        isBookable: true,
        isActive: true,
        verificationStatus: VERIFICATION_VERIFIED,
        coordinates: geoPoint,
        offer: offer,
        paytm: "+919611009823",
        phone: "+918328592031",
        gpay: "+919611009823",
        whatsapp: "+918328592031");

    try {
      entity.regNum = "testReg111";
      await EntityService().upsertEntity(entity);
    } catch (e) {
      print("Exception occured " + e.toString());
    }
  }
}
