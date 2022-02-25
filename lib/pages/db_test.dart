import 'dart:async';

import 'package:LESSs/db/exceptions/cant_remove_admin_with_one_admin_exception.dart';
import 'package:LESSs/db/exceptions/entity_deletion_denied_child_exists_exception.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:enum_to_string/enum_to_string.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:uuid/uuid.dart';
import '../db/db_model/address.dart';
import '../db/db_model/booking_application.dart';
import '../db/db_model/booking_form.dart';
import '../db/db_model/configurations.dart';
import '../db/db_model/employee.dart';
import '../db/db_model/entity.dart';
import '../db/db_model/entity_private.dart';
import '../db/db_model/entity_slots.dart';
import '../db/db_model/meta_entity.dart';
import '../db/db_model/meta_form.dart';
import '../db/db_model/my_geo_fire_point.dart';
import '../db/db_model/offer.dart';
import '../db/db_model/slot.dart';
import '../db/db_model/app_user.dart';
import '../db/db_model/user_token.dart';
import '../db/db_service/booking_application_service.dart';
import '../enum/application_status.dart';
import '../enum/entity_type.dart';
import '../events/event_bus.dart';
import '../events/events.dart';
import '../events/local_notification_data.dart';
import '../constants.dart';
import '../global_state.dart';
import '../triplet.dart';
import '../tuple.dart';
import '../utils.dart';

import '../enum/entity_role.dart';

class DBTest {
  String Covid_Vacination_Center = "Selenium-Covid-Vacination-Center";
  String Test_Hospital_center = "TEST_HOSPITAL_CENTER";
  String Test_Hospital_Child_Clinic = "TEST_HOSPITAL_CHILD_CLINIC";
  String Multi_Forms_School_ID = "Selenium-School_Multiple_Forms";

  double lat = 71.70; //17.444317
  double lon = -42.60; //78.355321

  String NEBULA_CLINIC = "NEBULA_CLINIC";
  String BIGPIQ_PRIVATE_OFFICE = "BIGPIQ_PRIVATE_OFFICE";
  String PLUTO_CLINIC = "PLUTO_CLINIC";
  String VENUS_HEART_CLINIC = "VENUS_HEART_CLINIC";
  String SATURN_CLINIC = "SATURN_CLINIC";
  String MERCURY_CLINIC = "MERCURY_CLINIC";
  String SILVER_APARTMENT = "SILVER_APARTMENT";
  String SILVER_APARTMENT_GYM = "SILVER_APARTMENT_GYM";
  String SILVER_APARTMENT_MURTHY_CLINIC = "SILVER_APARTMENT_MURTHY_CLINIC";

  String SILVER_APARTMENT_SALON = "SILVER_APARTMENT_SALON";
  String SILVER_APARTMENT_BADMINTON_COURT_1 =
      "SILVER_APARTMENT_BADMINTON_COURT_1";
  String SILVER_APARTMENT_BADMINTON_COURT_2 =
      "SILVER_APARTMENT_BADMINTON_COURT_2";
  String CYBER_APARTMENT = "CYBER_APARTMENT";
  String CYBER_APARTMENT_STAR_CLINIC = "CYBER_APARTMENT_SINGH_CLINIC";
  String HOME_APARTMENT = "HOME_APARTMENT";
  String HOME_APARTMENT_SINGH_CLINIC = "HOME_APARTMENT_SINGH_CLINIC";

  GlobalState? _gs;
  DBTest() {
    GlobalState.clearGlobalState();
    GlobalState.getGlobalState().then((value) => _gs = value);
  }

  void dbCall() async {
    // FirebaseCrashlytics.instance.crash();
    // GlobalState gs = await GlobalState.getGlobalState();
    // gs.initializeNotification();
    _gs = await GlobalState.getGlobalState();
    fireLocalNotificationEvent();

    //this should be carefully called
    await systemSetUp();

    await clearAll();
    await tests();
    await createDummyPlaces();
    await securityPermissionTests();
    await creatEntitiesForScreenShots();
  }

  Future<void> systemSetUp() async {
    //await createConf();
    await deleteBookingForms();
    await createBookingForms();
  }

  Future<void> createConf() async {}

  Future<void> deleteBookingForms() async {
    try {
      await _gs!
          .getApplicationService()!
          .deleteBookingForm(COVID_VACCINATION_BOOKING_FORM_ID_OLD);

      await _gs!
          .getApplicationService()!
          .deleteBookingForm(COVID_VACCINATION_CLINIC_BOOKING_FORM_ID);

      await _gs!
          .getApplicationService()!
          .deleteBookingForm(COVID_VACCINATION_HOSPITAL_BOOKING_FORM_ID);

      await _gs!
          .getApplicationService()!
          .deleteBookingForm(COVID_VACCINATION_EMPLOYEES_BOOKING_FORM_ID);

      await _gs!
          .getApplicationService()!
          .deleteBookingForm(SCHOOL_GENERAL_NEW_ADMISSION_BOOKING_FORM_ID);

      await _gs!
          .getApplicationService()!
          .deleteBookingForm(SCHOOL_GENERAL_TC_REQUEST_FORM_ID);

      await _gs!
          .getApplicationService()!
          .deleteBookingForm(HOSPITAL_ADMISSION_FORM);

      await _gs!
          .getApplicationService()!
          .deleteBookingForm(DOCTOR_CONSULTATION_HOSPITAL_FORM);
      await _gs!
          .getApplicationService()!
          .deleteBookingForm(DOCTOR_CONSULTATION_CLINIC_FORM);

      await _gs!
          .getApplicationService()!
          .deleteBookingForm(MEDICAL_TEST_HOSPITAL_FORM);

      await _gs!
          .getApplicationService()!
          .deleteBookingForm(MEDICAL_TEST_DIAGNOSTIC_FORM);

      await _gs!
          .getApplicationService()!
          .deleteBookingForm(GENERAL_VACCINE_HOSPITAL_FORM);

      await _gs!
          .getApplicationService()!
          .deleteBookingForm(GENERAL_VACCINE_CLINIC_FORM);
    } catch (e) {
      print("Error while cleaning the system booking forms");
    }
  }

  Future<Entity> addFormToEntity(Entity entity, String templateFormID,
      bool autoApproved, bool allowedOnline) async {
    if (entity.forms == null) {
      entity.forms = [];
    }

    BookingForm form = await (_gs!
        .getApplicationService()!
        .getBookingForm(templateFormID) as FutureOr<BookingForm>);
    form.id = templateFormID + "#" + Uuid().v1();
    form.autoApproved = autoApproved;
    form.allowedOnline = allowedOnline;
    entity.forms!.add(form.getMetaForm());
    await _gs!.getApplicationService()!.saveBookingForm(form);
    if (Utils.isNotNullOrEmpty(entity.parentId)) {
      await _gs!
          .getEntityService()!
          .upsertChildEntityToParent(entity, entity.parentId!);
    } else {
      await _gs!.getEntityService()!.upsertEntity(entity);
    }
    return entity;
  }

  Future<void> creatEntitiesForScreenShots() async {
    print("Started adding data for screenshots..");
    MyGeoFirePoint geoPoint = new MyGeoFirePoint(lat + 0.00767, lon + 0.00396);

    Address bigpiqAdrs = new Address(
        city: "Hyderbad",
        state: "Telangana",
        country: "India",
        address: "Block 11, Cyber Towers, Hitech City");

    Entity bigpiq = await createEntity(
        BIGPIQ_PRIVATE_OFFICE,
        "BIGPIQ Technologies Pvt. Ltd.",
        bigpiqAdrs,
        geoPoint,
        EntityType.PLACE_TYPE_PRIVATE_OFFICE,
        false,
        4,
        true);

    await addFormToEntity(
        bigpiq, COVID_VACCINATION_EMPLOYEES_BOOKING_FORM_ID, true, false);

    Address nebulaAdrs = new Address(
        city: "Hyderbad",
        state: "Telangana",
        country: "India",
        address: "Block 22, Behind Cyber Towers, Hitech City");

    Entity nebulaClinic = await createEntity(
        NEBULA_CLINIC,
        "Nebula Clinic HiTech City",
        nebulaAdrs,
        geoPoint,
        EntityType.PLACE_TYPE_MEDICAL_CLINIC,
        true,
        2,
        false);

    await addFormToEntity(
        nebulaClinic, GENERAL_VACCINE_CLINIC_FORM, true, false);
    await addFormToEntity(nebulaClinic, MEDICAL_TEST_CLINIC_FORM, true, false);
    await addFormToEntity(
        nebulaClinic, DOCTOR_CONSULTATION_CLINIC_FORM, true, true);

    Address plutoAdrs = new Address(
        city: "Hyderbad",
        state: "Telangana",
        country: "India",
        address: "Tower1, Cyberlane, Hitech City");

    Entity plutoClinic = await createEntity(
        PLUTO_CLINIC,
        "Pluto Fertility Center",
        plutoAdrs,
        new MyGeoFirePoint(lat + 0.00767, lon + 0.00396),
        EntityType.PLACE_TYPE_MEDICAL_CLINIC,
        true,
        2,
        false);

    await addFormToEntity(
        plutoClinic, GENERAL_VACCINE_CLINIC_FORM, true, false);
    await addFormToEntity(plutoClinic, MEDICAL_TEST_CLINIC_FORM, true, false);
    await addFormToEntity(
        plutoClinic, DOCTOR_CONSULTATION_CLINIC_FORM, true, true);

    Address venusAdrs = new Address(
        city: "Hyderbad",
        state: "Telangana",
        country: "India",
        address: "Plot No 6, Old Mumbai Highway");

    Entity venusClinic = await createEntity(
        VENUS_HEART_CLINIC,
        "Venus Heart Speciality Center",
        venusAdrs,
        new MyGeoFirePoint(lat + 0.00710, lon + 0.00417),
        EntityType.PLACE_TYPE_MEDICAL_CLINIC,
        false,
        2,
        false);

    // await addFormToEntity(
    //     venusClinic, COVID_VACCINATION_CLINIC_BOOKING_FORM_ID, true, false);
    await addFormToEntity(
        venusClinic, DOCTOR_CONSULTATION_CLINIC_FORM, true, true);

    Address saturnAdrs = new Address(
        city: "Hyderbad",
        state: "Telangana",
        country: "India",
        address: "B22/310 D-5B, Hitech City");

    Entity saturnClinic = await createEntity(
        SATURN_CLINIC,
        "Saturn Pediatrics",
        saturnAdrs,
        new MyGeoFirePoint(lat + 0.00867, lon + 0.00396),
        EntityType.PLACE_TYPE_MEDICAL_CLINIC,
        false,
        2,
        false);

    // await addFormToEntity(
    //     saturnClinic, COVID_VACCINATION_CLINIC_BOOKING_FORM_ID, true, false);
    await addFormToEntity(
        saturnClinic, DOCTOR_CONSULTATION_CLINIC_FORM, true, false);

    Address mercuryAdrs = new Address(
        city: "Hyderbad",
        state: "Telangana",
        country: "India",
        address: "C23/520 D-7D, Hitech City,");

    await createEntity(
        MERCURY_CLINIC,
        "Mercury Multi Speciality Clinic",
        mercuryAdrs,
        new MyGeoFirePoint(lat + 0.00767, lon + 0.00496),
        EntityType.PLACE_TYPE_MEDICAL_CLINIC,
        true,
        2,
        false);

    Address silverAdrs = new Address(
        city: "Hyderbad",
        state: "Telangana",
        country: "India",
        address: "B27/320 C-5B, Hitech City");

    await createEntity(
        SILVER_APARTMENT,
        "Silver Blossom Apartment",
        silverAdrs,
        new MyGeoFirePoint(lat + 0.00767, lon + 0.00399),
        EntityType.PLACE_TYPE_APARTMENT,
        false,
        null,
        true);

    await createEntity(
        SILVER_APARTMENT_GYM,
        "Main Gym",
        silverAdrs,
        new MyGeoFirePoint(lat + 0.00799, lon + 0.00396),
        EntityType.PLACE_TYPE_GYM,
        false,
        10,
        true,
        SILVER_APARTMENT);

    await createEntity(
        SILVER_APARTMENT_MURTHY_CLINIC,
        "Doctor Murthy Clinic",
        silverAdrs,
        geoPoint,
        EntityType.PLACE_TYPE_MEDICAL_CLINIC,
        true,
        2,
        true,
        SILVER_APARTMENT);

    Offer offer = new Offer(
        message: "Get 40% off on facial on Thursdays", coupon: "THUR40");
    offer.startDateTime = new DateTime(2021, 8, 13, 10, 30, 0, 0);
    offer.endDateTime = new DateTime(2022, 8, 20, 10, 30, 0, 0);

    Entity salon = await createEntity(
        SILVER_APARTMENT_SALON,
        "MyStyle Salon",
        silverAdrs,
        geoPoint,
        EntityType.PLACE_TYPE_SALON,
        false,
        2,
        true,
        SILVER_APARTMENT);

    salon.offer = offer;
    await _gs!.getEntityService()!.upsertEntity(salon);

    await createEntity(
        SILVER_APARTMENT_BADMINTON_COURT_1,
        "Badminton Court 1",
        silverAdrs,
        geoPoint,
        EntityType.PLACE_TYPE_SPORTS,
        false,
        5,
        true,
        SILVER_APARTMENT);

    await createEntity(
        SILVER_APARTMENT_BADMINTON_COURT_2,
        "Badminton Court 2",
        silverAdrs,
        geoPoint,
        EntityType.PLACE_TYPE_SPORTS,
        false,
        5,
        true,
        SILVER_APARTMENT);

    Address cyberAdrs = new Address(
        city: "Hyderbad",
        state: "Telangana",
        country: "India",
        address: "320 C-5B, Hitech City");

    await createEntity(CYBER_APARTMENT, "Cyber Heights Apartment", cyberAdrs,
        geoPoint, EntityType.PLACE_TYPE_APARTMENT, false, null, true);

    await createEntity(
        CYBER_APARTMENT_STAR_CLINIC,
        "STAR Clinic",
        cyberAdrs,
        geoPoint,
        EntityType.PLACE_TYPE_MEDICAL_CLINIC,
        true,
        2,
        true,
        CYBER_APARTMENT);

    Address homeMyHomeAdrs = new Address(
        city: "Hyderbad",
        state: "Telangana",
        country: "India",
        address: "52, Hitech City road");

    await createEntity(HOME_APARTMENT, "HomeMyHome Apartment", homeMyHomeAdrs,
        geoPoint, EntityType.PLACE_TYPE_APARTMENT, false, null, false);

    await createEntity(
        HOME_APARTMENT_SINGH_CLINIC,
        "Doctor Singh Clinic",
        cyberAdrs,
        geoPoint,
        EntityType.PLACE_TYPE_MEDICAL_CLINIC,
        true,
        2,
        true,
        HOME_APARTMENT);

    print("Finshed adding data for screenshots..");
  }

  Future<Entity> createEntity(
      String id,
      String name,
      Address adrs,
      MyGeoFirePoint geoPoint,
      EntityType type,
      bool onlineConsultation,
      int? maxAllowed,
      bool isPrivate,
      [String? parentId]) async {
    Entity entity = new Entity(
        entityId: id,
        name: name,
        address: adrs,
        advanceDays: 4,
        isPublic: isPrivate,
        //geo: geoPoint,
        maxAllowed: maxAllowed,
        slotDuration: 30,
        closedOn: (type == EntityType.PLACE_TYPE_APARTMENT ||
                type == EntityType.PLACE_TYPE_HOSPITAL ||
                type == EntityType.PLACE_TYPE_MALL)
            ? null
            : [WEEK_DAY_SUNDAY],
        breakStartHour: type == EntityType.PLACE_TYPE_APARTMENT ? null : 13,
        breakStartMinute: type == EntityType.PLACE_TYPE_APARTMENT ? null : 30,
        breakEndHour: type == EntityType.PLACE_TYPE_APARTMENT ? null : 14,
        breakEndMinute: type == EntityType.PLACE_TYPE_APARTMENT ? null : 30,
        startTimeHour: type == EntityType.PLACE_TYPE_APARTMENT ? null : 10,
        startTimeMinute: type == EntityType.PLACE_TYPE_APARTMENT ? null : 30,
        endTimeHour: type == EntityType.PLACE_TYPE_APARTMENT ? null : 21,
        endTimeMinute: type == EntityType.PLACE_TYPE_APARTMENT ? null : 0,
        parentId: parentId,
        type: type,
        isBookable: (type == EntityType.PLACE_TYPE_APARTMENT ||
                type == EntityType.PLACE_TYPE_HOSPITAL ||
                type == EntityType.PLACE_TYPE_MALL)
            ? false
            : true,
        isActive: true,
        coordinates: geoPoint,
        allowOnlineAppointment: onlineConsultation,
        maxTokensByUserInDay: 2);

    try {
      entity.regNum = "testReg";
      if (parentId == null) {
        await _gs!.getEntityService()!.upsertEntity(entity);
      } else {
        await _gs!
            .getEntityService()!
            .upsertChildEntityToParent(entity, parentId);
      }
    } catch (e) {
      print("Exception occured " + e.toString());
    }

    return entity;
  }

  Future<void> createBookingForms() async {
    await createBookingFormGlobalCovidVaccination_OLD(
        COVID_VACCINATION_BOOKING_FORM_ID_OLD);

    await createBookingGlobalSchoolNewAdmission(
        SCHOOL_GENERAL_NEW_ADMISSION_BOOKING_FORM_ID);
    await createBookingFormGlobalSchoolTC(SCHOOL_GENERAL_TC_REQUEST_FORM_ID);

    await createBookingFormForCovidVaccination(
        COVID_VACCINATION_CLINIC_BOOKING_FORM_ID);

    await createBookingFormForCovidVaccination(
        COVID_VACCINATION_EMPLOYEES_BOOKING_FORM_ID);

    await createBookingFormForCovidVaccination(
        COVID_VACCINATION_HOSPITAL_BOOKING_FORM_ID);
    await createNewAdmissionFormForHospital(HOSPITAL_ADMISSION_FORM);

    await createDoctorConsultationForm(DOCTOR_CONSULTATION_HOSPITAL_FORM);
    await createDoctorConsultationForm(DOCTOR_CONSULTATION_CLINIC_FORM);

    await createGeneralVaccineForm(GENERAL_VACCINE_HOSPITAL_FORM);
    await createGeneralVaccineForm(GENERAL_VACCINE_CLINIC_FORM);

    await createMedicalTestRequestFormForClinic(MEDICAL_TEST_CLINIC_FORM);
    await createMedicalTestRequestFormForHospital(MEDICAL_TEST_HOSPITAL_FORM);
    await createMedicalTestRequestFormForDiagnosticCenter(
        MEDICAL_TEST_DIAGNOSTIC_FORM);
  }

  Future<void> clearAll() async {
    DateTime now = DateTime.now();

    await deleteEntity('SalonMyHomeApartment');
    await deleteEntity(Test_Hospital_Child_Clinic);
    await deleteEntity(Test_Hospital_center);
    await deleteEntity('MyHomeApartment');
    await deleteEntity('SportsEntity103');
    await deleteEntity('SportsEntity104');
    await deleteEntity('SportsEntity105');
    await deleteEntity('BankEntity106');
    await deleteEntity('SalonEntity107');
    await deleteEntity('SalonEntity108');
    await deleteEntity('GymEntity109');
    await deleteEntity('GymEntity110');

    try {
      bool deleted = await _gs!.getEntityService()!.deleteEntity('Entity101');
      if (deleted) {
        print(
            "Entity101 deletion failed as per expectation as Child Enities Exists --> FAILURE");
      }
    } catch (e) {
      if (e is EntityDeletionDeniedChildExistsException) {
        print(
            "Entity101 deletion failed as per expectation as Child Enities Exists --> SUCCESS");
      } else {
        print(
            "Entity101 deletion failed as per expectation as Child Enities Exists --> FAILURE");
      }
    }

    //Delete Screenshot entities
    await deleteEntity(BIGPIQ_PRIVATE_OFFICE);
    await deleteEntity(NEBULA_CLINIC);
    await deleteEntity(PLUTO_CLINIC);
    await deleteEntity(VENUS_HEART_CLINIC);
    await deleteEntity(SATURN_CLINIC);
    await deleteEntity(MERCURY_CLINIC);
    await deleteEntity(CYBER_APARTMENT_STAR_CLINIC);
    await deleteEntity(CYBER_APARTMENT);
    await deleteEntity(HOME_APARTMENT_SINGH_CLINIC);
    await deleteEntity(HOME_APARTMENT);

    try {
      //first delete all children then deleted parent Entity
      await deleteEntity(SILVER_APARTMENT_GYM);
      await deleteEntity(SILVER_APARTMENT_MURTHY_CLINIC);
      await deleteEntity(SILVER_APARTMENT_SALON);
      await deleteEntity(SILVER_APARTMENT_BADMINTON_COURT_1);
      await deleteEntity(SILVER_APARTMENT_BADMINTON_COURT_2);
      await deleteEntity(SILVER_APARTMENT);
    } catch (e) {
      print("SILVER_APARTMENT deletion failed --> FAILURE");
    }

    try {
      //first delete all children then deleted parent Entity
      await deleteEntity('Child101-1');

      await deleteEntity('Child101-2');

      await deleteEntity('Child101-3');

      await deleteEntity('Entity101');
    } catch (e) {
      print("Entity101 deletion failed --> FAILURE");
    }

    await deleteEntity('Entity102');

    //delete user

    await _gs!.getUserService()!.deleteCurrentUser();
    await deleteEntity(Covid_Vacination_Center);
    await deleteEntity(Multi_Forms_School_ID);

    _gs!.getUserService()!.deleteUser("+912626262626");
    _gs!.getUserService()!.deleteUser("+916565656565");
    _gs!.getUserService()!.deleteUser("+919611006955");
    _gs!.getUserService()!.deleteUser("+919611009823");
    _gs!.getUserService()!.deleteUser("+911111111111");
    _gs!.getUserService()!.deleteUser("+913611009823");
    _gs!.getUserService()!.deleteUser("+919999999999");
  }

  Future<void> deleteEntity(String entityId) async {
    try {
      await _gs!.getEntityService()!.deleteEntity(entityId);
      await _gs!.getTokenService()!.deleteSlotsForEntity(entityId);
      await _gs!.getTokenService()!.deleteTokensForEntity(entityId);
      await _gs!.getTokenService()!.deleteTokenCountersForEntity(entityId);
      await _gs!.getApplicationService()!.deleteApplicationsForEntity(entityId);
    } catch (e) {
      print(entityId + " is not cleared");
    }
  }

  Future<void> tests() async {
    final User? fireUser = _gs!.getAuthService()!.getFirebaseAuth().currentUser;

    FirebaseApp secondaryApp =
        await (_gs!.initSecondaryFirebaseApp() as FutureOr<FirebaseApp>);

    FirebaseFirestore fStore = FirebaseFirestore.instanceFor(app: secondaryApp);

    print(
        "<==================================TESTING STARTED==========================================>");

    Configurations? conf = _gs!.getConfigurations();

    AppUser? u = await _gs!.getUserService()!.getCurrentUser();

    try {
      await createChildEntityAndAddToParent(
          'Child101-1', "Bata", true); //should fail as entity does not exists
    } catch (EntityDoesNotExistsException) {
      print(
          "EntityService.upsertChildEntityToParent (expected exception thrown) --> SUCCESS");
    }
    await createInorbitEntity();

    await createEntity2();

    await createChildEntityAndAddToParent('Child101-1', "Bata", true);

    Employee emp = new Employee();
    emp.ph = "+913611009823";
    emp.name = "FName1 User1";

    await _gs!
        .getEntityService()!
        .upsertEmployee('Child101-1', emp, EntityRole.Admin);

    await createChildEntityAndAddToParent('Child101-2', "Habinaro", true);

    await updateEntity("Inorbit_Modified");

    await createChildEntityAndAddToParent('Child101-3', "Raymonds", false);

    await updateEntity("Inorbit_Modified_Again");

    Entity? ent = await _gs!.getEntityService()!.getEntity('Entity101');

    Entity child1 = await (_gs!.getEntityService()!.getEntity('Child101-1')
        as FutureOr<Entity>);

    Entity? child2 = await _gs!.getEntityService()!.getEntity('Child101-2');

    Entity? child3 = await _gs!.getEntityService()!.getEntity('Child101-3');

    print("Token generation started..");

    try {
      await _gs!.getTokenService()!.generateToken(
          child1.getMetaEntity(), new DateTime(2020, 7, 6, 10, 30, 0, 0));
    } catch (e) {
      print("generate token threw Slotful exception");
    }

    print("Tok1 generated");

    await _gs!.getTokenService()!.generateToken(
        child1.getMetaEntity(), new DateTime(2020, 7, 7, 12, 30, 0, 0));
    print("Tok21 generated");

    await _gs!.getTokenService()!.generateToken(
        child1.getMetaEntity(), new DateTime(2020, 7, 7, 10, 30, 0, 0));
    print("Tok22 generated");

    await _gs!.getTokenService()!.generateToken(
        child1.getMetaEntity(), new DateTime(2020, 7, 8, 10, 30, 0, 0));
    print("Tok3 generated");

    print("Token generation ended.");

    List<UserTokens?> toks = await (_gs!
            .getTokenService()!
            .getAllTokensForCurrentUser(
                new DateTime(2020, 7, 8), new DateTime(2020, 7, 9))
        as FutureOr<List<UserTokens?>>);
    print("Got the Tokens between 8th July and 9th July: " +
        toks.length.toString());

    bool isAdminAssignedOnEntity = false;

    final DocumentReference entityPrivateRef =
        fStore.doc('entities/' + child1.entityId! + '/private_data/private');
    DocumentSnapshot doc = await entityPrivateRef.get();

    EntityPrivate? ePrivate;
    if (doc.exists) {
      Map<String, dynamic>? map = doc.data() as Map<String, dynamic>?;
      ePrivate = EntityPrivate.fromJson(map);
      if (ePrivate!.roles!['+913611009823'] ==
          EnumToString.convertToString(EntityRole.Admin)) {
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
    AppUser? newAdmin;
    if (doc1.exists) {
      Map<String, dynamic> map = doc1.data() as Map<String, dynamic>;
      newAdmin = AppUser.fromJson(map);
    }

    bool isEntityAddedToAdmin = false;

    if (newAdmin != null) {
      for (MetaEntity? me in newAdmin.entities!) {
        if (me!.entityId == "Child101-1") {
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

    List<UserTokens?>? toksBetween6thAnd9th = await _gs!
        .getTokenService()!
        .getAllTokensForCurrentUser(
            new DateTime(2020, 7, 6), new DateTime(2020, 7, 9));

    if (toksBetween6thAnd9th != null && toksBetween6thAnd9th.length == 4) {
      print("TokenService.getAllTokensForCurrentUser --> SUCCESS");
    } else {
      print(
          "TokenService.getAllTokensForCurrentUser -----------------------> FAILURE");
    }

    List<UserTokens?>? allToksFromToday = await _gs!
        .getTokenService()!
        .getAllTokensForCurrentUser(new DateTime(2020, 7, 7), null);

    if (allToksFromToday != null && allToksFromToday.length >= 3) {
      //should get all the tokens from 7th June onwards
      print("TokenService.getAllTokensForCurrentUser --> SUCCESS");
    } else {
      print(
          "TokenService.getAllTokensForCurrentUser -----------------------> FAILURE");
    }

    EntitySlots? es = await _gs!
        .getTokenService()!
        .getEntitySlots('Child101-1', new DateTime(2020, 7, 7));

    if (es != null && es.slots!.length == 2) {
      print("TokenService.getEntitySlots --> SUCCESS");
    } else {
      print("TokenService.getEntitySlots -----------------------> FAILURE");
    }

    List<UserTokens?> toksForDayForEntity = await _gs!
        .getTokenService()!
        .getTokensForEntityBookedByCurrentUser(
            'Child101-1', new DateTime(2020, 7, 7));

    if (toksForDayForEntity.length == 2) {
      print("TokenService.getTokensForEntityBookedByCurrentUser --> SUCCESS");
    } else {
      print(
          "TokenService.getTokensForEntityBookedByCurrentUser ------------------------> FAILURE");
    }

    Triplet<UserToken, TokenCounter, EntitySlots>? cancelledTup;
    cancelledTup = await _gs!
        .getTokenService()!
        .cancelToken("Child101-1#2020~7~7#10~30#+919999999999");

    UserToken? cancelledToken = cancelledTup!.item1;

    if (cancelledToken == null) {
      print("TokenService.cancelToken ------> FAILURE");
    }

    List<UserTokens?> toksForDayForEntityAfterCancellation = await _gs!
        .getTokenService()!
        .getTokensForEntityBookedByCurrentUser(
            'Child101-1', new DateTime(2020, 7, 7));
    for (UserTokens? tokenOnSeventh in toksForDayForEntityAfterCancellation) {
      if (tokenOnSeventh!.slotId! + "#" + tokenOnSeventh.userId! ==
          "Child101-1#2020~7~7#10~30#+919999999999") {
        if (tokenOnSeventh.tokens![0].number == -1) {
          print("TokenService.cancelToken ------> Success");
        } else {
          print("TokenService.cancelToken --------------------> FAILURE");
        }
      }
    }

    EntitySlots? esWithCancelledSlot = await _gs!
        .getTokenService()!
        .getEntitySlots('Child101-1', new DateTime(2020, 7, 7));

    if (esWithCancelledSlot != null && esWithCancelledSlot.slots!.length == 2) {
      bool isSuccess = false;
      for (Slot s in esWithCancelledSlot.slots!) {
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

    List<Entity> entitiesByTypeAndNameNull = await _gs!
        .getEntityService()!
        .search(null, EntityType.PLACE_TYPE_SHOP, 71.70, -42.60, 2, 1, 2);

    for (Entity me in entitiesByTypeAndNameNull) {
      print(me.name! + ":" + me.distance.toString());
    }

    if (entitiesByTypeAndNameNull != null &&
        entitiesByTypeAndNameNull.length >= 2) {
      print("EntityService.search --> SUCCESS");
    } else {
      print("EntityService.search ------------------------> FAILURE");
    }

    print("----------Search Only Partial Name-- Type null-----------");

    List<Entity> entitiesByTypeNullAndName = await _gs!
        .getEntityService()!
        .search("Habi", null, 71.70, -42.60, 2, 1, 2);

    for (Entity me in entitiesByTypeNullAndName) {
      print(me.name! + ":" + me.distance.toString());
    }

    if (entitiesByTypeNullAndName != null &&
        entitiesByTypeNullAndName.length == 2) {
      print("EntityService.search --> SUCCESS");
    } else {
      print(
          "EntityService.search -----------------------------------------------> FAILURE");
    }

    print("---------Search By Partial Name and Type --------------");

    List<Entity> entitiesByTypeAndName = await _gs!
        .getEntityService()!
        .search("Bat", EntityType.PLACE_TYPE_SHOP, 71.70, -42.60, 2, 1, 2);

    for (Entity me in entitiesByTypeAndName) {
      print(me.name! + ":" + me.distance.toString());
    }

    if (entitiesByTypeAndName != null && entitiesByTypeAndName.length == 1) {
      print("EntityService.search --> SUCCESS");
    } else {
      print(
          "EntityService.search -----------------------------------------> FAILURE");
    }

    print(
        "---------Search By Name and Type again for 2 Habi but of different type--------------");

    List<Entity> entitiesByTypeAndNameAgain = await _gs!
        .getEntityService()!
        .search("Habina", EntityType.PLACE_TYPE_SHOP, 71.70, -42.60, 2, 1, 2);

    for (Entity me in entitiesByTypeAndNameAgain) {
      print(me.name! + ":" + me.distance.toString());
    }

    if (entitiesByTypeAndNameAgain != null &&
        entitiesByTypeAndNameAgain.length == 1) {
      print("EntityService.search --> SUCCESS");
    } else {
      print("EntityService.search ---------------------------------> FAILURE");
    }

    print(
        "---------Search By Name and Type Store (no intersection) --------------");

    List<Entity> noIntersection = await _gs!
        .getEntityService()!
        .search("Bata", EntityType.PLACE_TYPE_POPSHOP, 71.70, -42.60, 2, 1, 2);

    for (Entity me in noIntersection) {
      print(me.name! + ":" + me.distance.toString());
    }

    if (noIntersection != null && noIntersection.length == 0) {
      print("EntityService.search --> SUCCESS");
    } else {
      print("EntityService.search --------------------------> FAILURE");
    }

    await _gs!
        .getEntityService()!
        .removeEmployee('Child101-1', "+913611009823");

    try {
      bool removed = await _gs!.removeEmployee('Child101-1', "+919999999999");
      if (removed) {
        print(
            "Remove Admin failed as per expectation, as +919999999999 was the only admin --> FAILURE");
      }
    } catch (e) {
      if (e is CantRemoveAdminWithOneAdminException) {
        print(
            "Remove Admin failed as per expectation, as +919999999999 was the only admin --> SUCCESS");
      } else {
        print(
            "Remove Admin failed as per expectation, as +919999999999 was the only admin --> FAILURE");
      }
    }

    Entity? child101 = await _gs!.getEntityService()!.getEntity('Child101-1');

    bool isAdminRemovedFromEntity = true;
    // for (MetaUser me in child101.admins) {
    //   if (me.ph == '+913611009823') {
    //     isAdminRemovedFromEntity = false;
    //     break;
    //   }
    // }

    final DocumentReference child101PrivateRef =
        fStore.doc('entities/' + child1.entityId! + '/private_data/private');
    DocumentSnapshot docChild101 = await child101PrivateRef.get();

    EntityPrivate? ePrivateChild101;
    if (doc.exists) {
      Map<String, dynamic>? map = docChild101.data() as Map<String, dynamic>?;
      ePrivateChild101 = EntityPrivate.fromJson(map);
      if (ePrivateChild101!.roles!['+913611009823'] ==
          EnumToString.convertToString(EntityRole.Admin)) {
        isAdminAssignedOnEntity = false;
      }
    }

    if (isAdminRemovedFromEntity) {
      print("EntityService.removeAdmin --> SUCCESS");
    } else {
      print("EntityService.removeAdmin -----------------------> FAILURE");
    }

    DocumentSnapshot removedAdminDoc = await userRef.get();
    AppUser? removedAdmin;
    if (doc.exists) {
      Map<String, dynamic> map =
          removedAdminDoc.data()! as Map<String, dynamic>;
      removedAdmin = AppUser.fromJson(map);
    }

    bool isEntityRemovedFromAdmin = true;

    if (removedAdmin != null) {
      for (MetaEntity? me in removedAdmin.entities!) {
        if (me!.entityId == "Child101-1") {
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

    await _gs!
        .getEntityService()!
        .addEntityToUserFavourite(child101!.getMetaEntity());

    AppUser? curUser = await _gs!.getUserService()!.getCurrentUser();

    bool isEntityAddedToCurrentUser = false;

    if (curUser != null) {
      for (MetaEntity? me in curUser.favourites!) {
        if (me!.entityId == "Child101-1") {
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

    await _gs!.getEntityService()!.removeEntityFromUserFavourite("Child101-1");

    curUser = await _gs!.getUserService()!.getCurrentUser();

    bool isEntityRemovedFromCurrentUser = true;

    if (curUser != null) {
      for (MetaEntity? me in curUser.favourites!) {
        if (me!.entityId == "Child101-1") {
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

    Entity parentEnt = await (_gs!.getEntityService()!.getEntity('Entity101')
        as FutureOr<Entity>);
    bool metaNameChangedInParent = false;
    for (MetaEntity? me in parentEnt.childEntities!) {
      if (me!.name == "Bata updated") {
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

    AppUser user =
        await (_gs!.getUserService()!.getCurrentUser() as FutureOr<AppUser>);

    bool metaNameChangedInAdminUser = false;

    for (MetaEntity? me in user.entities!) {
      if (me!.name == "Bata updated") {
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

    Entity bata = await (_gs!.getEntityService()!.getEntity('Child101-1')
        as FutureOr<Entity>);

    if (bata.offer != null &&
        bata.offer!.coupon == "Coup10" &&
        bata.managers != null &&
        bata.managers![0].employeeId == "Emp410") {
      print("Offer and Manager added on Entity --> SUCCESS");
    } else {
      print(
          "Offer and Manager added on Entity ------------------------------> Failure");
    }

    Employee emp2 = new Employee();
    emp2.ph = "+919611006955";
    emp2.name = "FName2 User2";

    bool admin6955 =
        await _gs!.addEmployee("Child101-3", emp2, EntityRole.Admin);

    print(
        "+919611006955 added as an admin to the Child101-3, check on the real device");

    List<UserToken> tokens = await (_gs!
            .getTokenService()!
            .getAllTokensForSlot("Child101-1#2020~7~7#10~30")
        as FutureOr<List<UserToken>>);

    if (tokens.length == 1) {
      print("TokenService.getAllTokensForSlot --> SUCCESS");
    } else {
      print(
          "TokenService.getAllTokensForSlot -----------------------------------> failure");
    }

    BookingForm bf = await testCovidCenterBookingForm();
    Entity covVacinationCenter =
        await (testBookingApplicationSubmission(bf) as FutureOr<Entity>);
    BookingApplication approvedBA = await testBookingApplicationStatusChange();

    await testApplicationCancellation(approvedBA);

    await testAvailableFreeSlots(covVacinationCenter.getMetaEntity());

    await testMultipleBookingFormsWithSchoolEntity();

    testPaginationInFetchingApplication();

    await testTokenCounter(bata);

    await testAddManagerAndExecutivesToApartmentWithSalon();

    await testRemoveAdminManagerAndExecutive();

    createTestHospital();

    print(
        "<==========================================TESTING DONE=========================================>");

    int i = 0;
  }

  Future<void> securityPermissionTests() async {
    print("Security permission test started.. ");

    updateEntity("Inorbit_AdminCheck");
    Employee emp = new Employee();
    emp.ph = "+913611009823";
    emp.name = "FName1 User1";
    await _gs!
        .getEntityService()!
        .upsertEmployee('Child101-1', emp, EntityRole.Admin);
    await _gs!
        .getEntityService()!
        .upsertEmployee('Entity102', emp, EntityRole.Admin);
    await _gs!
        .getEntityService()!
        .upsertEmployee('Entity102', emp, EntityRole.Admin);
    await _gs!
        .getEntityService()!
        .upsertEmployee('Entity102', emp, EntityRole.Admin);

    print("Security permission test completed.");
  }

  Future<void> createInorbitEntity() async {
    Address adrs = new Address(
        city: "Hyderbad",
        state: "Telangana",
        country: "India",
        address: "Shop 10, Gachibowli");

    MyGeoFirePoint geoPoint = new MyGeoFirePoint(lat, lon);
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
        type: EntityType.PLACE_TYPE_MALL,
        isBookable: false,
        isActive: true,
        coordinates: geoPoint);

    try {
      entity.regNum = "testReg";
      await _gs!.getEntityService()!.upsertEntity(entity);
    } catch (e) {
      print("Exception occured " + e.toString());
    }
  }

  Future<void> updateChildEntityBataWithOfferAndManager() async {
    Entity ent = await (_gs!.getEntityService()!.getEntity("Child101-1")
        as FutureOr<Entity>);

    Address adrs = new Address(
        city: "Hyderbad",
        state: "Telangana",
        country: "India",
        address: "Shop 10, Gachibowli");

    //update the offer and manager

    Offer offer =
        new Offer(message: "Get 10% off on branded items", coupon: "Coup10");
    offer.startDateTime = new DateTime(2020, 8, 13, 10, 30, 0, 0);
    offer.endDateTime = new DateTime(2020, 8, 20, 10, 30, 0, 0);

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
      ent.managers = [];
    }
    ent.managers!.add(manager1);

    try {
      ent.regNum = "BataRegNumber";
      await _gs!.getEntityService()!.upsertEntity(ent);
    } catch (e) {
      print("Exception occured " + e.toString());
    }
  }

  Future<void> updateEntity(String name) async {
    Entity ent = await (_gs!.getEntityService()!.getEntity("Entity101")
        as FutureOr<Entity>);
    ent.name = name;

    Address adrs = new Address(
        city: "Hyderbad",
        state: "Telangana",
        country: "India",
        address: "Shop 10, Gachibowli");

    try {
      await _gs!.getEntityService()!.upsertEntity(ent);
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

    MyGeoFirePoint geoPoint = new MyGeoFirePoint(lat, lon);

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
        type: EntityType.PLACE_TYPE_SHOP,
        isBookable: true,
        isActive: isActive,
        coordinates: geoPoint,
        maxTokensPerSlotByUser: 5,
        maxTokensByUserInDay: 15);
    try {
      child1.regNum = "testregnum";
      bool added = await _gs!
          .getEntityService()!
          .upsertChildEntityToParent(child1, 'Entity101');
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

    MyGeoFirePoint geoPoint = new MyGeoFirePoint(lat, lon);

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
        type: EntityType.PLACE_TYPE_SHOP,
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
        type: EntityType.PLACE_TYPE_RESTAURANT,
        isBookable: false,
        isActive: true,
        coordinates: geoPoint);

    // Employee manager1 = new Employee(name: "Rakesh", ph: "+91888888888", employeeId: "empyId", shiftStartHour: );

    try {
      await _gs!.getEntityService()!.upsertEntity(entity);
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

  Future<void> testTokenCounter(Entity bata) async {
    //set the max token booked by a user in a slot to 3
    await _gs!.getEntityService()!.upsertEntity(bata);
    MetaEntity? me = bata.getMetaEntity();

    //book tokens for April 13th (10:30 - 3, 11:30 - 2, 3:30 - 3), April 14th (11:30 - 3) = Total: 11

    await _gs!
        .getTokenService()!
        .generateToken(me, new DateTime(2021, 4, 13, 10, 30));
    await _gs!
        .getTokenService()!
        .generateToken(me, new DateTime(2021, 4, 13, 10, 30));
    await _gs!
        .getTokenService()!
        .generateToken(me, new DateTime(2021, 4, 13, 10, 30));

    Triplet<UserTokens, TokenCounter, EntitySlots> tup1 = await (_gs!
            .getTokenService()!
            .generateToken(me, new DateTime(2021, 4, 13, 11, 30))
        as FutureOr<Triplet<UserTokens, TokenCounter, EntitySlots>>);
    UserTokens ut1 = tup1.item1!;

    await _gs!
        .getTokenService()!
        .generateToken(me, new DateTime(2021, 4, 13, 11, 30));

    await _gs!
        .getTokenService()!
        .generateToken(me, new DateTime(2021, 4, 13, 15, 30));
    await _gs!
        .getTokenService()!
        .generateToken(me, new DateTime(2021, 4, 13, 15, 30));
    await _gs!
        .getTokenService()!
        .generateToken(me, new DateTime(2021, 4, 13, 15, 30));

    await _gs!
        .getTokenService()!
        .generateToken(me, new DateTime(2021, 4, 14, 11, 30));
    await _gs!
        .getTokenService()!
        .generateToken(me, new DateTime(2021, 4, 14, 11, 30));
    await _gs!
        .getTokenService()!
        .generateToken(me, new DateTime(2021, 4, 14, 11, 30));

    //book tokens for May 1st (10:30 - 2, 11:30 - 1, 12:30 - 1) = Total: 4
    Triplet<UserTokens, TokenCounter, EntitySlots> tup2 = await (_gs!
            .getTokenService()!
            .generateToken(me, new DateTime(2021, 5, 1, 10, 30))
        as FutureOr<Triplet<UserTokens, TokenCounter, EntitySlots>>);
    UserTokens ut2 = tup2.item1!;
    await _gs!
        .getTokenService()!
        .generateToken(me, new DateTime(2021, 5, 1, 10, 30));
    await _gs!
        .getTokenService()!
        .generateToken(me, new DateTime(2021, 5, 1, 11, 30));
    await _gs!
        .getTokenService()!
        .generateToken(me, new DateTime(2021, 5, 1, 12, 30));

    //cancel 3 tokens - 1 from April and 2 from May

    await _gs!.getTokenService()!.cancelToken(ut1.getTokenId(), 1);

    await _gs!.getTokenService()!.cancelToken(ut2.getTokenId(), 1);

    await _gs!.getTokenService()!.cancelToken(ut2.getTokenId(), 2);

    TokenCounter tc = await (_gs!.getTokenService()!.getTokenCounterForEntity(
        bata.entityId!, "2021") as FutureOr<TokenCounter>);

    if (tc.getTokenStatsForDay(DateTime(2021, 4, 14)).numberOfTokensCreated ==
            3 &&
        tc.getTokenStatsForDay(DateTime(2021, 4, 14)).numberOfTokensCancelled ==
            0 &&
        tc.getTokenStatsForDay(DateTime(2021, 5, 1)).numberOfTokensCancelled ==
            2 &&
        tc.getTokenStatsForDay(DateTime(2021, 5, 1)).numberOfTokensCreated ==
            4) {
      print("TokenCounter.getTokenStatsForDay() --> SUCCESS");
    } else {
      print(
          "TokenCounter.getTokenStatsForDay() ---------------------------> FAILURE");
    }

    if (tc.getTokenStatsForMonth(4).numberOfTokensCreated == 11 &&
        tc.getTokenStatsForMonth(4).numberOfTokensCancelled == 1 &&
        tc.getTokenStatsForMonth(5).numberOfTokensCreated == 4) {
      print("TokenCounter.getTokenStatsForMonth() --> SUCCESS");
    } else {
      print(
          "TokenCounter.getTokenStatsForMonth() ---------------------------> FAILURE");
    }

    if (tc.getTokenStatsForYear().numberOfTokensCreated == 15 &&
        tc.getTokenStatsForYear().numberOfTokensCancelled == 3) {
      print("TokenCounter.getTokenStatsForYear() --> SUCCESS");
    } else {
      print(
          "TokenCounter.getTokenStatsForYear() ---------------------------> FAILURE");
    }

    String slot13April1130 = "11~30";

    Map<String, TokenStats> slotWiseStats =
        tc.getTokenStatsSlotWiseForDay(DateTime(2021, 4, 13));

    TokenStats ts = slotWiseStats[slot13April1130]!;
    if (ts.numberOfTokensCreated == 2 && ts.numberOfTokensCancelled == 1) {
      print("TokenCounter.getTokenStatsSlotWiseForDay() --> SUCCESS");
    } else {
      print(
          "TokenCounter.getTokenStatsSlotWiseForDay() ---------------------------> FAILURE");
    }
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
        type: EntityType.PLACE_TYPE_SHOP,
        isBookable: false,
        isActive: true,
        coordinates: geoPoint,
        phone: "+919611009823",
        whatsapp: "+919611009823",
        maxTokensByUserInDay: 15,
        maxTokensPerSlotByUser: 5);

    try {
      entity.regNum = "SampleChildRegNum";
      await _gs!
          .getEntityService()!
          .upsertChildEntityToParent(entity, "Entity101");
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

    MyGeoFirePoint geoPoint = new MyGeoFirePoint(lat, lon);
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
        type: EntityType.PLACE_TYPE_SPORTS,
        isBookable: true,
        isActive: true,
        verificationStatus: VERIFICATION_VERIFIED,
        coordinates: geoPoint,
        offer: offer,
        upiPhoneNumber: "+919611009823",
        phone: "+918328592031",
        upiId: "+919611009823",
        whatsapp: "+918328592031");

    try {
      entity.regNum = "testReg111";
      await _gs!.getEntityService()!.upsertEntity(entity);
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

    MyGeoFirePoint geoPoint = new MyGeoFirePoint(lat, lon);
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
        type: EntityType.PLACE_TYPE_SPORTS,
        isBookable: true,
        isActive: true,
        verificationStatus: VERIFICATION_PENDING,
        coordinates: geoPoint,
        offer: null,
        upiPhoneNumber: "+919611009823",
        phone: "+918328592031",
        upiId: "+919611009823",
        whatsapp: "+918328592031");

    try {
      entity.regNum = "testReg111";
      await _gs!.getEntityService()!.upsertEntity(
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

    MyGeoFirePoint geoPoint = new MyGeoFirePoint(lat, lon);
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
        type: EntityType.PLACE_TYPE_SPORTS,
        isBookable: true,
        isActive: true,
        verificationStatus: VERIFICATION_REJECTED,
        coordinates: geoPoint,
        offer: offer,
        upiPhoneNumber: "+919611009823",
        phone: "+918328592031",
        upiId: "+919611009823",
        whatsapp: "+918328592031");

    try {
      entity.regNum = "testReg111";
      await _gs!.getEntityService()!.upsertEntity(entity);
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

    MyGeoFirePoint geoPoint = new MyGeoFirePoint(lat, lon);
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
        type: EntityType.PLACE_TYPE_BANK,
        isBookable: true,
        isActive: true,
        verificationStatus: VERIFICATION_PENDING,
        coordinates: geoPoint,
        offer: offer,
        upiPhoneNumber: "+919611009823",
        phone: "+918328592031",
        upiId: "+919611009823",
        whatsapp: "+918328592031");

    try {
      entity.regNum = "testReg111";
      await _gs!.getEntityService()!.upsertEntity(entity);
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

    MyGeoFirePoint geoPoint = new MyGeoFirePoint(lat, lon);
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
        type: EntityType.PLACE_TYPE_SALON,
        isBookable: true,
        isActive: true,
        verificationStatus: VERIFICATION_PENDING,
        coordinates: geoPoint,
        offer: offer,
        upiPhoneNumber: "+919611009823",
        phone: "+918328592031",
        upiId: "+919611009823",
        whatsapp: "+918328592031");

    try {
      entity.regNum = "testReg111";
      await _gs!.getEntityService()!.upsertEntity(entity);
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

    MyGeoFirePoint geoPoint = new MyGeoFirePoint(lat, lon);
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
        type: EntityType.PLACE_TYPE_SALON,
        isBookable: true,
        isActive: true,
        verificationStatus: VERIFICATION_PENDING,
        coordinates: geoPoint,
        offer: offer,
        upiPhoneNumber: "+919611009823",
        phone: "+918328592031",
        upiId: "+919611009823",
        whatsapp: "+918328592031");

    try {
      entity.regNum = "testReg111";
      await _gs!.getEntityService()!.upsertEntity(entity);
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

    MyGeoFirePoint geoPoint = new MyGeoFirePoint(lat, lon);
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
        type: EntityType.PLACE_TYPE_GYM,
        isBookable: true,
        isActive: true,
        verificationStatus: VERIFICATION_VERIFIED,
        coordinates: geoPoint,
        offer: offer,
        upiPhoneNumber: "+919611009823",
        phone: "+918328592031",
        upiId: "+919611009823",
        whatsapp: "+918328592031",
        allowOnlineAppointment: true);

    try {
      entity.regNum = "testReg111";
      await _gs!.getEntityService()!.upsertEntity(entity);
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

    MyGeoFirePoint geoPoint = new MyGeoFirePoint(lat, lon);
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
        type: EntityType.PLACE_TYPE_GYM,
        isBookable: true,
        isActive: true,
        verificationStatus: VERIFICATION_VERIFIED,
        coordinates: geoPoint,
        offer: offer,
        upiPhoneNumber: "+919611009823",
        phone: "+918328592031",
        upiId: "+919611009823",
        whatsapp: "+918328592031");

    try {
      entity.regNum = "testReg111";
      await _gs!.getEntityService()!.upsertEntity(entity);
    } catch (e) {
      print("Exception occured " + e.toString());
    }
  }

  Future<void> testAddManagerAndExecutivesToApartmentWithSalon() async {
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

    MyGeoFirePoint geoPoint = new MyGeoFirePoint(lat, lon);
    Entity entity = new Entity(
        entityId: "MyHomeApartment",
        name: "Homely Apartment",
        address: adrs,
        advanceDays: 9,
        isPublic: false,
        maxAllowed: 0,
        slotDuration: 0,
        closedOn: [WEEK_DAY_THURSDAY],
        breakStartHour: null,
        breakStartMinute: null,
        breakEndHour: null,
        breakEndMinute: null,
        startTimeHour: null,
        startTimeMinute: null,
        endTimeHour: null,
        endTimeMinute: 0,
        parentId: null,
        type: EntityType.PLACE_TYPE_APARTMENT,
        isBookable: false,
        isActive: true,
        verificationStatus: null,
        coordinates: geoPoint,
        offer: null,
        upiPhoneNumber: null,
        phone: "+918328592031",
        upiId: "",
        whatsapp: null,
        supportEmail: "test@test.com");

    try {
      entity.regNum = "testReg111";
      await _gs!.getEntityService()!.upsertEntity(entity);
    } catch (e) {
      print("Exception occured " + e.toString());
    }

    Entity childEntity = new Entity(
        entityId: "SalonMyHomeApartment",
        name: "Salon My Home Apartment",
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
        type: EntityType.PLACE_TYPE_SALON,
        isBookable: true,
        isActive: true,
        verificationStatus: VERIFICATION_VERIFIED,
        coordinates: geoPoint,
        offer: offer,
        upiPhoneNumber: "+919611009823",
        phone: "+918328592031",
        upiId: "+919611009823",
        whatsapp: "+918328592031");

    try {
      entity.regNum = "testReg111123";
      await _gs!
          .getEntityService()!
          .upsertChildEntityToParent(childEntity, "MyHomeApartment");
    } catch (e) {
      print("Exception occured " + e.toString());
    }

    //this is added so that removal of single admin case does not arise
    Employee secondAdmin = new Employee();
    secondAdmin.name = "Second Admin";
    secondAdmin.ph = "+911111111111";

    try {
      await _gs!
          .getEntityService()!
          .upsertEmployee("MyHomeApartment", secondAdmin, EntityRole.Admin);

      await _gs!.getEntityService()!.upsertEmployee(
          "SalonMyHomeApartment", secondAdmin, EntityRole.Admin);
    } catch (e) {
      print("Exception occured " + e.toString());
    }

    Employee adminSalon = new Employee();
    adminSalon.name = "FName SalonMyHomeAdmin";
    adminSalon.ph = "+912626262626"; //Nokia - Salon Manager

    Employee managerMyHomeApt = new Employee();
    managerMyHomeApt.name = "FName MyHomeManager";
    managerMyHomeApt.ph = "+916565656565"; //redmi note 3 - Apartment Manager

    Employee executive1 = new Employee();
    executive1.name = "FName MyHomeExecutive";
    executive1.ph = "+912626262626"; //Nokia - Apartment Executive

    try {
      await _gs!.getEntityService()!.upsertEmployee(
          "MyHomeApartment", managerMyHomeApt, EntityRole.Manager);
      await _gs!
          .getEntityService()!
          .upsertEmployee("MyHomeApartment", executive1, EntityRole.Executive);
      await _gs!
          .getEntityService()!
          .upsertEmployee("SalonMyHomeApartment", adminSalon, EntityRole.Admin);
    } catch (e) {
      print("Exception occured " + e.toString());
    }

    AppUser salonAdmin = await (_gs!.getUserService()!.getUser("+912626262626")
        as FutureOr<AppUser>);
    Entity? salon =
        await _gs!.getEntityService()!.getEntity("SalonMyHomeApartment");

    EntityPrivate? salonPrivate =
        await _gs!.getEntityService()!.getEntityPrivate("SalonMyHomeApartment");
    if (salonAdmin.entityVsRole!["SalonMyHomeApartment"] == EntityRole.Admin &&
        salon!.getRole("+912626262626") == EntityRole.Admin &&
        salonPrivate!.roles!["+912626262626"] ==
            EnumToString.convertToString(EntityRole.Admin)) {
      print("AddEmployee as an Admin is working fine --> SUCCESS");
    } else {
      print("AddEmployee as an Admin -----------------------> FAILURE");
    }

    AppUser apartmentManager = await (_gs!
        .getUserService()!
        .getUser("+916565656565") as FutureOr<AppUser>);
    Entity? apartment =
        await _gs!.getEntityService()!.getEntity("MyHomeApartment");

    EntityPrivate? apartmentPrivate =
        await _gs!.getEntityService()!.getEntityPrivate("MyHomeApartment");
    if (apartmentManager.entityVsRole!["MyHomeApartment"] ==
            EntityRole.Manager &&
        apartment!.getRole("+916565656565") == EntityRole.Manager &&
        apartmentPrivate!.roles!["+916565656565"] ==
            EnumToString.convertToString(EntityRole.Manager)) {
      print("AddEmployee as an Manager is working fine --> SUCCESS");
    } else {
      print("AddEmployee as an Manager -----------------------> FAILURE");
    }

    AppUser apartmentExecutive = await (_gs!
        .getUserService()!
        .getUser("+912626262626") as FutureOr<AppUser>);

    if (apartmentExecutive.entityVsRole!["MyHomeApartment"] ==
            EntityRole.Executive &&
        apartment!.getRole("+912626262626") == EntityRole.Executive &&
        apartmentPrivate!.roles!["+912626262626"] ==
            EnumToString.convertToString(EntityRole.Executive)) {
      print("AddEmployee as an Executive is working fine --> SUCCESS");
    } else {
      print("AddEmployee as an Executive -----------------------> FAILURE");
    }

    //now make the manager as Admin of the Apartment
    try {
      await _gs!.getEntityService()!.upsertEmployee(
          "MyHomeApartment", managerMyHomeApt, EntityRole.Admin);
    } catch (e) {
      print("Exception occured " + e.toString());
    }

    apartmentManager = await (_gs!.getUserService()!.getUser("+916565656565")
        as FutureOr<AppUser>);
    apartment = await _gs!.getEntityService()!.getEntity("MyHomeApartment");

    apartmentPrivate =
        await _gs!.getEntityService()!.getEntityPrivate("MyHomeApartment");
    if (apartmentManager.entityVsRole!["MyHomeApartment"] !=
            EntityRole.Manager &&
        apartmentManager.entityVsRole!["MyHomeApartment"] == EntityRole.Admin &&
        apartment!.getRole("+916565656565") == EntityRole.Admin &&
        apartmentPrivate!.roles!["+916565656565"] ==
            EnumToString.convertToString(EntityRole.Admin)) {
      print(
          "AddEmployee to promote Manager to Admin is working fine --> SUCCESS");
    } else {
      print(
          "AddEmployee to promote Manager to Admin -----------------------> FAILURE");
    }
  }

  Future<void> testRemoveAdminManagerAndExecutive() async {
    try {
      await _gs!
          .getEntityService()!
          .removeEmployee("MyHomeApartment", "+916565656565");
      await _gs!
          .getEntityService()!
          .removeEmployee("MyHomeApartment", "+912626262626");
      await _gs!
          .getEntityService()!
          .removeEmployee("SalonMyHomeApartment", "+912626262626");
    } catch (e) {
      print("Exception occured " + e.toString());
    }

    AppUser salonAdmin = await (_gs!.getUserService()!.getUser("+912626262626")
        as FutureOr<AppUser>);
    Entity? salon =
        await _gs!.getEntityService()!.getEntity("SalonMyHomeApartment");

    EntityPrivate? salonPrivate =
        await _gs!.getEntityService()!.getEntityPrivate("SalonMyHomeApartment");
    if (!salonAdmin.entityVsRole!.containsKey("SalonMyHomeApartment") &&
        salon!.getRole("+912626262626") == null &&
        !salonPrivate!.roles!.containsKey("+912626262626")) {
      print("RemoveEmployee as an Admin is working fine --> SUCCESS");
    } else {
      print("RemoveEmployee as an Admin -----------------------> FAILURE");
    }

    AppUser apartmentManager = await (_gs!
        .getUserService()!
        .getUser("+916565656565") as FutureOr<AppUser>);
    Entity? apartment =
        await _gs!.getEntityService()!.getEntity("MyHomeApartment");

    EntityPrivate? apartmentPrivate =
        await _gs!.getEntityService()!.getEntityPrivate("MyHomeApartment");
    if (!apartmentManager.entityVsRole!.containsKey("MyHomeApartment") &&
        apartment!.getRole("+916565656565") == null &&
        !apartmentPrivate!.roles!.containsKey("+916565656565")) {
      print("RemoveEmployee for a Manager is working fine --> SUCCESS");
    } else {
      print("RemoveEmployee for a Manager -----------------------> FAILURE");
    }

    AppUser apartmentExecutive = await (_gs!
        .getUserService()!
        .getUser("+912626262626") as FutureOr<AppUser>);

    if (!apartmentExecutive.entityVsRole!.containsKey("MyHomeApartment") &&
        apartment!.getRole("+912626262626") == null &&
        !apartmentPrivate!.roles!.containsKey("+912626262626")) {
      print("RemoveEmployee for an Executive is working fine --> SUCCESS");
    } else {
      print("RemoveEmployee for an Executive -----------------------> FAILURE");
    }
  }

  Future<BookingForm> testCovidCenterBookingForm() async {
    Address adrs = new Address(
        city: "Hyderbad",
        state: "Telangana",
        country: "India",
        address: "Shop 61, Towli Chowk Bazar, Gachibowli");

    BookingForm bf = await (_gs!
            .getApplicationService()!
            .getBookingForm(COVID_VACCINATION_BOOKING_FORM_ID_OLD)
        as FutureOr<BookingForm>);

    List<MetaForm> forms = [];
    forms.add(bf.getMetaForm());

    MyGeoFirePoint geoPoint = new MyGeoFirePoint(lat, lon);
    Entity entity = new Entity(
        entityId: Covid_Vacination_Center,
        name: "Selenium Covid Vacination Center",
        address: adrs,
        advanceDays: 7,
        isPublic: true,
        maxAllowed: 60,
        slotDuration: 60,
        closedOn: [WEEK_DAY_MONDAY, WEEK_DAY_FRIDAY],
        breakStartHour: 13,
        breakStartMinute: 30,
        breakEndHour: 14,
        breakEndMinute: 30,
        startTimeHour: 10,
        startTimeMinute: 30,
        endTimeHour: 21,
        endTimeMinute: 0,
        parentId: null,
        type: EntityType.PLACE_TYPE_COVID19_VACCINATION_CENTER,
        isBookable: true,
        isActive: true,
        verificationStatus: VERIFICATION_VERIFIED,
        coordinates: geoPoint,
        offer: null,
        upiPhoneNumber: "+919611009823",
        phone: "+918328592031",
        upiId: "+919611009823",
        whatsapp: "+918328592031",
        forms: forms,
        maxTokensPerSlotByUser: 2,
        maxTokensByUserInDay: 15);

    try {
      entity.regNum = "testReg111";
      await _gs!.getEntityService()!.upsertEntity(entity);
    } catch (e) {
      print("Exception occured " + e.toString());
    }

    return bf;

    // FormInputFieldOptions options =
    //     seleniumVacCenter.tokenBookingForm.formFields[2];

    // if (seleniumVacCenter.tokenBookingForm.formFields.length == 3 &&
    //     options.values.length == 11) {
    //   print("Token Booking Form Fields tested --> SUCCESS");
    // } else {
    //   print(
    //       "Token Booking Form Fields tested -----------------------> FAILURE");
    // }
  }

  Future<Entity?> testBookingApplicationSubmission(BookingForm bf) async {
    //Case 1: Application submission
    //Case 2: Application state change by Admin
    //Case 3: Counter increment for Global and Local both

    Entity? vacinationCenter =
        await _gs!.getEntityService()!.getEntity(Covid_Vacination_Center);

    for (int i = 0; i < 10; i++) {
      FormInputFieldText nameInput =
          bf.getFormFields()[0] as FormInputFieldText;
      nameInput.response = "FN LN " + i.toString();

      FormInputFieldDateTime ageInput =
          bf.getFormFields()[1] as FormInputFieldDateTime;
      ageInput.responseDateTime = DateTime(2001, 8, 6);

      FormInputFieldOptionsWithAttachments healthDetailsInput =
          bf.getFormFields()[2] as FormInputFieldOptionsWithAttachments;
      healthDetailsInput.responseValues = [];
      healthDetailsInput.responseValues!.add(healthDetailsInput.options![1]);
      healthDetailsInput.responseValues!.add(healthDetailsInput.options![3]);

      FormInputFieldOptionsWithAttachments idProof =
          bf.getFormFields()[3] as FormInputFieldOptionsWithAttachments;
      idProof.responseValues = [];
      idProof.responseValues!.add(idProof.options![1]);
      idProof.responseValues!.add(idProof.options![3]);
      idProof.responseFilePaths = [];
      idProof.responseFilePaths!.add(
          "https://firebasestorage.googleapis.com/v0/b/sukoon-india.appspot.com/o/8d33fca0-567c-11eb-ab9e-3186f616ddb9%238d3200d0-567c-11eb-8f72-39e1ef14fb06%23O72Pv6XakoRlxNKYbZLruYaMlwi1%23scaled_f511c73a-5c2b-43b6-91b7-fe1698dffb671714737705318816047.jpg?alt=media&token=d4b890c9-ff3c-4529-a65f-493e29763b61");
      idProof.responseFilePaths!.add(
          "https://firebasestorage.googleapis.com/v0/b/sukoon-india.appspot.com/o/fe3de7b0-567e-11eb-ae5b-5772ee4a0592%23fe3c12f0-567e-11eb-a11e-7f5c09f04575%23O72Pv6XakoRlxNKYbZLruYaMlwi1%23scaled_323f121e-f284-4d7f-8d58-95c81a3d6f2d5266208110146393983.jpg?alt=media&token=3415fa17-fc43-42fe-8e97-55cffea2f368");

      FormInputFieldOptionsWithAttachments frontLineWorker =
          bf.getFormFields()[4] as FormInputFieldOptionsWithAttachments;
      frontLineWorker.responseValues = [];
      frontLineWorker.responseValues!.add(frontLineWorker.options![0]);
      frontLineWorker.responseValues!.add(frontLineWorker.options![2]);
      frontLineWorker.responseFilePaths = [];
      frontLineWorker.responseFilePaths!.add(
          "https://firebasestorage.googleapis.com/v0/b/sukoon-india.appspot.com/o/8d33fca0-567c-11eb-ab9e-3186f616ddb9%238d3200d0-567c-11eb-8f72-39e1ef14fb06%23O72Pv6XakoRlxNKYbZLruYaMlwi1%23scaled_f511c73a-5c2b-43b6-91b7-fe1698dffb671714737705318816047.jpg?alt=media&token=d4b890c9-ff3c-4529-a65f-493e29763b61");
      frontLineWorker.responseFilePaths!.add(
          "https://firebasestorage.googleapis.com/v0/b/sukoon-india.appspot.com/o/fe3de7b0-567e-11eb-ae5b-5772ee4a0592%23fe3c12f0-567e-11eb-a11e-7f5c09f04575%23O72Pv6XakoRlxNKYbZLruYaMlwi1%23scaled_323f121e-f284-4d7f-8d58-95c81a3d6f2d5266208110146393983.jpg?alt=media&token=3415fa17-fc43-42fe-8e97-55cffea2f368");

      BookingApplication ba = new BookingApplication();
      ba.responseForm = bf;
      ba.bookingFormId = bf.id;
      ba.id = COVID_VACCINATION_BOOKING_FORM_ID_OLD +
          "#" +
          "TestApplicationID" +
          i.toString();
      DateTime now = DateTime.now();
      ba.preferredSlotTiming = DateTime(
              now.year,
              now.month,
              now.day,
              vacinationCenter!.startTimeHour!,
              vacinationCenter.startTimeMinute!)
          .add(Duration(days: 1));

      if (Utils.checkIfClosed(
          ba.preferredSlotTiming, vacinationCenter.closedOn!)) {
        ba.preferredSlotTiming = ba.preferredSlotTiming!.add(Duration(days: 1));
      }

      BookingApplicationService tas = _gs!.getApplicationService()!;

      await tas.submitApplication(ba, vacinationCenter.getMetaEntity());
    }

    // BookingApplicationCounter globalOverView = await _gs
    //     .getApplicationService()
    //     .getApplicationsOverview(
    //         COVID_VACCINATION_CLINIC_BOOKING_FORM_ID, null, DateTime.now().year);

    BookingApplicationCounter localOverView = await (_gs!
        .getApplicationService()!
        .getApplicationsOverview(
            COVID_VACCINATION_BOOKING_FORM_ID_OLD,
            Covid_Vacination_Center,
            DateTime.now().year) as FutureOr<BookingApplicationCounter>);

    // if (globalOverView.numberOfApproved == 0 &&
    //     globalOverView.numberOfNew == 10 &&
    //     globalOverView.numberOfCompleted == 0 &&
    //     globalOverView.totalApplications == 10) {
    //   print("GlobalApplicationOverview stats after submission --> SUCCESS");
    // } else {
    //   print(
    //       "GlobalApplicationOverview stats after submission ------------------------------> Failure");
    // }

    if (localOverView.numberOfApproved == 0 &&
        localOverView.numberOfNew == 10 &&
        localOverView.numberOfCompleted == 0 &&
        localOverView.totalApplications == 10) {
      print("LocalApplicationOverview stats after submission --> SUCCESS");
    } else {
      print(
          "LocalApplicationOverview stats after submission ------------------------------> Failure");
    }

    return vacinationCenter;
  }

  Future<BookingApplication> testBookingApplicationStatusChange() async {
    List<Tuple<BookingApplication, DocumentSnapshot>> applications = await _gs!
        .getApplicationService()!
        .getApplications(
            COVID_VACCINATION_BOOKING_FORM_ID_OLD,
            Covid_Vacination_Center,
            null,
            null,
            null,
            null,
            null,
            null,
            null,
            null,
            null,
            -1);

    Entity testingCenter = await (_gs!
        .getEntityService()!
        .getEntity(Covid_Vacination_Center) as FutureOr<Entity>);

    BookingApplication bs1 = applications[0].item1!;
    await _gs!.getApplicationService()!.updateApplicationStatus(
        bs1.id!,
        ApplicationStatus.APPROVED,
        "Notes on Approval",
        testingCenter.getMetaEntity(),
        bs1.preferredSlotTiming);

    BookingApplication bs2 = applications[1].item1!;
    await _gs!.getApplicationService()!.updateApplicationStatus(
        bs2.id!,
        ApplicationStatus.APPROVED,
        "Notes on Approval for app 2",
        testingCenter.getMetaEntity(),
        bs2.preferredSlotTiming);

    BookingApplication bs3 = applications[2].item1!;
    await _gs!.getApplicationService()!.updateApplicationStatus(bs3.id!,
        ApplicationStatus.COMPLETED, "Notes on Completion", null, null);

    BookingApplication bs7 = applications[6].item1!;
    await _gs!.getApplicationService()!.updateApplicationStatus(bs7.id!,
        ApplicationStatus.ONHOLD, "Notes on putting on Hold", null, null);

    BookingApplication bs10 = applications[9].item1!;
    await _gs!.getApplicationService()!.updateApplicationStatus(
        bs10.id!,
        ApplicationStatus.REJECTED,
        "Notes on rejecting this application",
        null,
        null);

    //now get the ApplicationOver object to check the count
    // BookingApplicationCounter globalOverView = await _gs
    //     .getApplicationService()
    //     .getApplicationsOverview(
    //         COVID_VACCINATION_CLINIC_BOOKING_FORM_ID, null, DateTime.now().year);

    BookingApplicationCounter localOverView = await (_gs!
        .getApplicationService()!
        .getApplicationsOverview(
            COVID_VACCINATION_BOOKING_FORM_ID_OLD,
            Covid_Vacination_Center,
            DateTime.now().year) as FutureOr<BookingApplicationCounter>);

    // if (globalOverView.numberOfApproved == 2 &&
    //     globalOverView.numberOfNew == 5 &&
    //     globalOverView.numberOfCompleted == 1 &&
    //     globalOverView.totalApplications == 10 &&
    //     globalOverView.numberOfPutOnHold == 1 &&
    //     globalOverView.numberOfRejected == 1) {
    //   print("GlobalApplicationOverview stats after status change --> SUCCESS");
    // } else {
    //   print(
    //       "GlobalApplicationOverview stats after status change ------------------------------> Failure");
    // }

    if (localOverView.numberOfApproved == 2 &&
        localOverView.numberOfNew == 5 &&
        localOverView.numberOfCompleted == 1 &&
        localOverView.totalApplications == 10 &&
        localOverView.numberOfPutOnHold == 1 &&
        localOverView.numberOfRejected == 1) {
      print("LocalApplicationOverview stats after status change --> SUCCESS");
    } else {
      print(
          "LocalApplicationOverview stats after status change ------------------------------> Failure");
    }

    String dailyStatsKey = DateTime.now().year.toString() +
        "~" +
        DateTime.now().month.toString() +
        "~" +
        DateTime.now().day.toString();

    ApplicationStats localStats = localOverView.dailyStats![dailyStatsKey]!;

    if (localStats.numberOfApproved == 2 && localStats.numberOfNew == 10) {
      print(
          "LocalApplicationOverview Daily Stats after status change --> SUCCESS");
    } else {
      print(
          "LocalApplicationOverview Daily stats after status change ------------------------------> Failure");
    }

    // ApplicationStats globalStats = globalOverView.dailyStats[dailyStatsKey];

    // if (globalStats.numberOfApproved == 2 && globalStats.numberOfNew == 10) {
    //   print(
    //       "GlobalApplicationOverview Daily Stats after status change --> SUCCESS");
    // } else {
    //   print(
    //       "GlobalApplicationOverview Daily stats after status change ------------------------------> Failure");
    // }

    List<Tuple<BookingApplication, DocumentSnapshot>> approvedApplications =
        await _gs!.getApplicationService()!.getApplications(
            COVID_VACCINATION_BOOKING_FORM_ID_OLD,
            Covid_Vacination_Center,
            ApplicationStatus.APPROVED,
            null,
            null,
            null,
            null,
            null,
            null,
            null,
            null,
            -1);

    if (approvedApplications.length == 2) {
      print("ApprovedApplicationCount stats --> SUCCESS");
    } else {
      print(
          "ApprovedApplicationCount stats ------------------------------> Failure");
    }

    return bs2;
  }

  Future<void> testApplicationCancellation(
      BookingApplication approvedBA) async {
    bool isCancelled = false;
    UserToken? token;

    Triplet<UserToken, TokenCounter, EntitySlots> tuple = await _gs!
        .getApplicationService()!
        .withDrawApplication(approvedBA.id!,
            "Cancelled the application and as a result the token should also get cancelled");
    token = tuple.item1;

    if (token != null) isCancelled = true;

    // //now get the ApplicationOver object to check the count
    // BookingApplicationCounter globalOverView = await _gs
    //     .getApplicationService()
    //     .getApplicationsOverview(
    //         COVID_VACCINATION_CLINIC_BOOKING_FORM_ID, null, DateTime.now().year);

    BookingApplicationCounter localOverView = await (_gs!
        .getApplicationService()!
        .getApplicationsOverview(
            COVID_VACCINATION_BOOKING_FORM_ID_OLD,
            Covid_Vacination_Center,
            DateTime.now().year) as FutureOr<BookingApplicationCounter>);

    // if (globalOverView.numberOfApproved == 1 &&
    //     globalOverView.numberOfNew == 5 &&
    //     globalOverView.numberOfCompleted == 1 &&
    //     globalOverView.totalApplications == 10 &&
    //     globalOverView.numberOfPutOnHold == 1 &&
    //     globalOverView.numberOfRejected == 1 &&
    //     globalOverView.numberOfCancelled == 1) {
    //   print("GlobalApplicationOverview stats after cancellation --> SUCCESS");
    // } else {
    //   print(
    //       "GlobalApplicationOverview stats after cancellation ------------------------------> Failure");
    // }

    if (localOverView.numberOfApproved == 1 &&
        localOverView.numberOfNew == 5 &&
        localOverView.numberOfCompleted == 1 &&
        localOverView.totalApplications == 10 &&
        localOverView.numberOfPutOnHold == 1 &&
        localOverView.numberOfRejected == 1) {
      print("LocalApplicationOverview stats after cancellation --> SUCCESS");
    } else {
      print(
          "LocalApplicationOverview stats after cancellation ------------------------------> Failure");
    }

    String dailyStatsKey = DateTime.now().year.toString() +
        "~" +
        DateTime.now().month.toString() +
        "~" +
        DateTime.now().day.toString();

    ApplicationStats localStats = localOverView.dailyStats![dailyStatsKey]!;

    if (localStats.numberOfCancelled == 1 &&
        localStats.numberOfApproved == 2 &&
        localStats.numberOfNew == 10) {
      print(
          "LocalApplicationOverview Daily Stats after cancellation --> SUCCESS");
    } else {
      print(
          "LocalApplicationOverview Daily stats after cancellation ------------------------------> Failure");
    }

    // ApplicationStats globalStats = globalOverView.dailyStats[dailyStatsKey];

    // if (globalStats.numberOfCancelled == 1 &&
    //     globalStats.numberOfApproved == 2 &&
    //     globalStats.numberOfNew == 10) {
    //   print(
    //       "GlobalApplicationOverview Daily Stats after cancellation --> SUCCESS");
    // } else {
    //   print(
    //       "GlobalApplicationOverview Daily stats after cancellation ------------------------------> Failure");
    // }

    List<Tuple<BookingApplication, DocumentSnapshot>> approvedApplications =
        await _gs!.getApplicationService()!.getApplications(
            COVID_VACCINATION_BOOKING_FORM_ID_OLD,
            Covid_Vacination_Center,
            ApplicationStatus.APPROVED,
            null,
            null,
            null,
            null,
            null,
            null,
            null,
            null,
            -1);

    if (approvedApplications.length == 1) {
      print("ApprovedApplicationCount stats --> SUCCESS");
    } else {
      print(
          "ApprovedApplicationCount stats ------------------------------> Failure");
    }
  }

  Future<void> testAvailableFreeSlots(MetaEntity? me) async {
    List<List<Slot>> listOfslots =
        await _gs!.getTokenService()!.getSlotsFromNow(me, false);
    if (listOfslots.length == 7 && listOfslots[6].length == 9) {
      print("Getting all slots --> SUCCESS");
    } else {
      print("Getting all slots ------------------------------> Failure");
    }

    List<List<Slot>> listOfFreeSlots =
        await _gs!.getTokenService()!.getSlotsFromNow(me, true);
    if (listOfFreeSlots.length == 7 && listOfFreeSlots[6].length == 9) {
      print("Getting free slots --> SUCCESS");
    } else {
      print("Getting free slots ------------------------------> Failure");
    }
  }

  Future<void> testMultipleBookingFormsWithSchoolEntity() async {
    Address adrs = new Address(
        city: "Hyderbad",
        state: "Telangana",
        country: "India",
        address: "Shop 61, Towli Chowk Bazar, Gachibowli");

    //admission form
    BookingForm admissionForm = await (_gs!
            .getApplicationService()!
            .getBookingForm(SCHOOL_GENERAL_NEW_ADMISSION_BOOKING_FORM_ID)
        as FutureOr<BookingForm>);

    print("AdmissionForm for a school with is created");

    //TC request
    BookingForm tcForm = await (_gs!
            .getApplicationService()!
            .getBookingForm(SCHOOL_GENERAL_TC_REQUEST_FORM_ID)
        as FutureOr<BookingForm>);

    print("TCForm for a school with is created");

    List<MetaForm> forms = [];
    forms.add(admissionForm.getMetaForm());
    forms.add(tcForm.getMetaForm());

    MyGeoFirePoint geoPoint = new MyGeoFirePoint(lat, lon);
    Entity entity = new Entity(
        entityId: Multi_Forms_School_ID,
        name: "Selenium International School",
        address: adrs,
        advanceDays: 7,
        isPublic: true,
        maxAllowed: 5,
        slotDuration: 30,
        closedOn: [WEEK_DAY_SUNDAY],
        breakStartHour: 13,
        breakStartMinute: 30,
        breakEndHour: 14,
        breakEndMinute: 30,
        startTimeHour: 10,
        startTimeMinute: 30,
        endTimeHour: 21,
        endTimeMinute: 0,
        parentId: null,
        type: EntityType.PLACE_TYPE_SCHOOL,
        isBookable: true,
        isActive: true,
        verificationStatus: VERIFICATION_VERIFIED,
        coordinates: geoPoint,
        offer: null,
        upiPhoneNumber: "+919611009823",
        phone: "+918328592031",
        upiId: "+919611009823",
        whatsapp: "+918328592031",
        forms: forms,
        maxTokensPerSlotByUser: 2);

    try {
      entity.regNum = "testReg2222";
      await _gs!.getEntityService()!.upsertEntity(entity);
      print("Creating a school with multiple forms");
    } catch (e) {
      print("Exception occured while creating a school with multiple form " +
          e.toString());
    }
  }

  void testPaginationInFetchingApplication() async {
    List<Tuple<BookingApplication, DocumentSnapshot>> top5Applications =
        await _gs!.getApplicationService()!.getApplications(
            COVID_VACCINATION_BOOKING_FORM_ID_OLD,
            Covid_Vacination_Center,
            null,
            null,
            null,
            null,
            null,
            "timeOfSubmission",
            true,
            null,
            null,
            5);

    if (top5Applications.length == 5) {
      print("Top 5 applications fetched --> SUCCESS");
    } else {
      print(
          "Top 5 applications fetched ------------------------------> Failure");
    }

    DocumentSnapshot? lastDoc = top5Applications[4].item2;

    List<Tuple<BookingApplication, DocumentSnapshot>> next5Applications =
        await _gs!.getApplicationService()!.getApplications(
            COVID_VACCINATION_BOOKING_FORM_ID_OLD,
            Covid_Vacination_Center,
            null,
            null,
            null,
            null,
            null,
            "timeOfSubmission",
            true,
            null,
            lastDoc,
            5);

    if (next5Applications.length == 5) {
      print("Next 5 applications fetched --> SUCCESS");
    } else {
      print(
          "Next 5 applications fetched ------------------------------> Failure");
    }

    List<Tuple<BookingApplication, DocumentSnapshot>>
        previousApplicationsFrom6thTo9th = await _gs!
            .getApplicationService()!
            .getApplications(
                COVID_VACCINATION_BOOKING_FORM_ID_OLD,
                Covid_Vacination_Center,
                null,
                null,
                null,
                null,
                null,
                "timeOfSubmission",
                false,
                null,
                lastDoc,
                5);

    if (previousApplicationsFrom6thTo9th.length == 4) {
      print("From 6th to 9th applications fetched --> SUCCESS");
    } else {
      print(
          "From 6th to 9th applications fetched ------------------------------> Failure");
    }
  }

  Future<BookingForm> createBookingGlobalSchoolNewAdmission(
      String formId) async {
    BookingForm admissionForm = new BookingForm(
        formName: "Admission Request Form",
        headerMsg:
            "You request will be approved based on the information provided by you, please enter the correct information.",
        footerMsg:
            "Please carry Transfer Certificate, Birth Certificate, Photo ID of the Student, 3 passport photo of student, 1 photo of parent. Please mark your presence 5 minutes prior to your appointment time.",
        autoApproved: true);

    admissionForm.isSystemTemplate = true;
    admissionForm.id = formId;
    admissionForm.autoApproved = false;

    FormInputFieldText nameInput = FormInputFieldText(
        "Name of the Student",
        true,
        "Please enter your name as per Government ID proof or Birth Certificate",
        50);
    nameInput.isMeta = true;

    admissionForm.addField(nameInput);

    FormInputFieldDateTime dob = FormInputFieldDateTime(
        "Date of Birth of the Student",
        true,
        "Please select the student's Date of Birth");
    dob.isMeta = true;
    dob.isAge = true;

    admissionForm.addField(dob);

    FormInputFieldOptions classDetailsInput = FormInputFieldOptions(
        "Admission seeking for ",
        false,
        "Please select the class you are seeking admission for ",
        [
          Value('Nursery'),
          Value('LKG'),
          Value('UKG'),
          Value('Class 1'),
          Value('Class 2'),
          Value('Class 3'),
          Value('Class 4'),
          Value('Class 5'),
          Value('Class 6'),
          Value('Class 7'),
          Value('Class 8'),
          Value('Class 9'),
          Value('Class 10'),
          Value('Class 11'),
          Value('Class 12')
        ],
        false);

    classDetailsInput.isMeta = true;
    classDetailsInput.defaultValueIndex = 0;

    admissionForm.addField(classDetailsInput);

    FormInputFieldAttachment tcImage = FormInputFieldAttachment(
        "Upload Transfer certificate",
        false,
        "If the student is moving from another school, you need to submit the original Transfer Certificate");

    admissionForm.addField(tcImage);

    FormInputFieldOptionsWithAttachments idProof =
        FormInputFieldOptionsWithAttachments(
            "Government Issued ID Proof",
            true,
            "Select valid government issued ID Proof and upload its images.",
            [
              Value('Birth Certificate'),
              Value('Passport'),
              Value('Aadhaar Card'),
              Value('Bank Passbook'),
              Value('Any other government issued photo ID'),
            ],
            false);

    admissionForm.addField(idProof);

    FormInputFieldText fatherInput = FormInputFieldText(
        "Name of the Father", true, "Please enter student's father name", 50);
    fatherInput.isMeta = false;

    admissionForm.addField(fatherInput);

    FormInputFieldText motherInput = FormInputFieldText(
        "Name of mother", true, "Please enter student's mother name", 50);
    motherInput.isMeta = false;

    admissionForm.addField(motherInput);

    FormInputFieldText parentEmail = FormInputFieldText(
        "Parent's email address",
        true,
        "Please enter Parent's email address",
        50);
    parentEmail.isMeta = false;
    parentEmail.isEmail = true;

    admissionForm.addField(parentEmail);

    FormInputFieldPhone parentPhone = FormInputFieldPhone(
        "Parent phone number",
        true,
        "Please enter Parent's primary phone number on which school can contact");
    parentPhone.isMeta = false;

    admissionForm.addField(parentPhone);

    //NOTE: If this is executed, every time the ID of the field is going to change
    await _gs!.getApplicationService()!.saveBookingForm(admissionForm);

    return admissionForm;
  }

  Future<BookingForm> createBookingFormGlobalSchoolTC(String formId) async {
    BookingForm tcForm = new BookingForm(
        formName: "Transfer Certificate Request Form",
        headerMsg:
            "Please ensure that all dues are cleared before making this request.",
        footerMsg: "",
        autoApproved: true);

    tcForm.isSystemTemplate = true;
    tcForm.id = formId;
    tcForm.autoApproved = true;

    FormInputFieldText nameInput = FormInputFieldText("Name of the Student",
        true, "Please enter your name of the student as per school record", 50);
    nameInput.isMeta = true;
    nameInput.isMandatory = true;

    tcForm.addField(nameInput);

    FormInputFieldText rollNumberInput = FormInputFieldText(
        "Student's roll number",
        true,
        "Please enter student's roll number",
        50);
    rollNumberInput.isMeta = true;
    rollNumberInput.isMandatory = true;

    tcForm.addField(rollNumberInput);

    FormInputFieldOptions classDetailsInput = FormInputFieldOptions(
        "Student's class",
        false,
        "Please select the current class of the student",
        [
          Value('Nursery'),
          Value('LKG'),
          Value('UKG'),
          Value('Class 1'),
          Value('Class 2'),
          Value('Class 3'),
          Value('Class 4'),
          Value('Class 5'),
          Value('Class 6'),
          Value('Class 7'),
          Value('Class 8'),
          Value('Class 9'),
          Value('Class 10'),
          Value('Class 11'),
          Value('Class 12')
        ],
        false);

    classDetailsInput.isMeta = true;
    classDetailsInput.defaultValueIndex = -1;
    classDetailsInput.isMandatory = true;

    tcForm.addField(classDetailsInput);

    FormInputFieldOptions relationWithStudent = FormInputFieldOptions(
        "Your relation",
        false,
        "Please select the current class of the student",
        [Value('Self'), Value('Father'), Value('Mother'), Value('Gaurdian')],
        false);

    relationWithStudent.isMeta = false;
    relationWithStudent.defaultValueIndex = -1;
    relationWithStudent.isMandatory = true;

    //NOTE: If this is executed, every time the ID of the field is going to change
    await _gs!.getApplicationService()!.saveBookingForm(tcForm);

    return tcForm;
  }

  Future<BookingForm> createBookingFormGlobalCovidVaccination_OLD(
      String formId) async {
    BookingForm bf = new BookingForm(
        formName: "Covid-19 Vacination Applicant Details",
        headerMsg:
            "You request will be approved based on the information provided by you, please enter the correct information.",
        footerMsg:
            "Applicant must carry the same ID proof documents to the vacination center. Also mark your presence 15 minutes prior to your alloted time. Failing to do so will result in cancellation of your application.",
        autoApproved: true);

    bf.isSystemTemplate = true;
    bf.id = formId;
    bf.autoApproved = false;

    FormInputFieldText nameInput = FormInputFieldText("Name of the Applicant",
        true, "Please enter your name as per Government ID proof", 50);
    nameInput.isMeta = true;

    bf.addField(nameInput);

    FormInputFieldDateTime dob = FormInputFieldDateTime(
        "Date of Birth of the Applicant",
        true,
        "Please select the applicant's Date of Birth");
    dob.isMeta = true;
    dob.isAge = true;

    bf.addField(dob);

    FormInputFieldOptionsWithAttachments healthDetailsInput =
        FormInputFieldOptionsWithAttachments(
            "Pre-existing Medical Conditions",
            false,
            "Please select all known medical conditions the applicant have",
            [
              Value('None'),
              Value('Chronic kidney disease'),
              Value('Chronic lung disease'),
              Value('Diabetes'),
              Value('Heart Conditions'),
              Value('Other Cardiovascular and Cerebrovascular Diseases'),
              Value("Hemoglobin disorders"),
              Value("HIV or weakened Immune System"),
              Value("Liver disease"),
              Value("Neurologic conditions such as dementia"),
              Value("Overweight and Severe Obesity"),
              Value("Pregnancy")
            ],
            true);

    healthDetailsInput.isMeta = true;
    healthDetailsInput.defaultValueIndex = 0;

    bf.addField(healthDetailsInput);

    FormInputFieldOptionsWithAttachments frontLineWorkerProof =
        FormInputFieldOptionsWithAttachments(
            "Only for Frontline workers",
            false,
            "Please select the category by Applicant's profession and upload a supporting ID proof/documents. Applicant must carry these documents along with him/her to the Vaccination Center.",
            [
              Value('None'),
              Value('Medical Professional'),
              Value('Government Official'),
              Value('MP/MLA'),
              Value('Others'),
            ],
            false);
    frontLineWorkerProof.isMeta = true;
    frontLineWorkerProof.defaultValueIndex = 0;
    bf.addField(frontLineWorkerProof);

    FormInputFieldOptionsWithAttachments idProof =
        FormInputFieldOptionsWithAttachments(
            "Government Issued ID Proof",
            true,
            "Select valid government issued ID Proof and upload its images. The applicant must carry these documents along with him/her to the Vaccination Center.",
            [
              Value('PAN'),
              Value('Passport'),
              Value('Driving License'),
              Value('Aadhaar Card'),
              Value('Bank Passbook'),
              Value('Any other government issued photo ID'),
            ],
            false);

    bf.addField(idProof);

    FormInputFieldPhone phoneField = FormInputFieldPhone(
        "Applicant's phone number",
        true,
        "Please enter the applicant's phone number");

    bf.addField(phoneField);
    //NOTE: If this is executed, every time the ID of the field is going to change
    await _gs!.getApplicationService()!.saveBookingForm(bf);
    return bf;
  }

  Future<BookingForm> createBookingFormForCovidVaccination(
      String formId) async {
    BookingForm bf = new BookingForm(
        formName: "Covid-19 Vaccination Registration Form",
        headerMsg:
            "You request will be approved based on the information provided by you, please enter the correct information.",
        footerMsg:
            "Applicant must carry the same ID proof documents to the vacination center. Also mark your presence 5 minutes prior to your alloted time-slot. Failing to do so could result in cancellation of your application.",
        autoApproved: true);

    bf.isSystemTemplate = true;
    bf.id = formId;
    bf.autoApproved = false;

    if (formId == COVID_VACCINATION_EMPLOYEES_BOOKING_FORM_ID) {
      FormInputFieldText employeeId = FormInputFieldText(
          "Employee ID of the Applicant",
          true,
          "Please enter your Employee ID",
          50);
      employeeId.isMeta = true;

      bf.addField(employeeId);

      FormInputFieldOptions self = FormInputFieldOptions(
          "Self/Dependant",
          true,
          "Are you booking for Self or your dependant",
          [Value('Self'), Value('Dependant')],
          false);

      bf.addField(self);
    }

    FormInputFieldText nameInput = FormInputFieldText("Name of the Applicant",
        true, "Please enter your name as per Government ID proof", 50);
    nameInput.isMeta = true;

    bf.addField(nameInput);

    FormInputFieldDateTime dob = FormInputFieldDateTime(
        "Year of Birth of the Applicant",
        true,
        "Please select the applicant's year of Birth");
    dob.isMeta = true;
    dob.isAge = true;
    dob.yearOnly = true;

    bf.addField(dob);

    FormInputFieldPhone phoneField = FormInputFieldPhone(
        "Registered phone number with COWIN",
        true,
        "Please enter the applicant's phone number which is registered with COWIN app (optional)");
    phoneField.isMandatory = false;

    bf.addField(phoneField);

    FormInputFieldOptions preferredVaccine = FormInputFieldOptions(
        "Preferred vaccine",
        true,
        "You will be alloted the time-slot based on the availability of Vaccine selected by you",
        [Value('COVISHIELD'), Value('COVAXIN')],
        false);

    preferredVaccine.isMeta = true;
    preferredVaccine.defaultValueIndex = 0;

    bf.addField(preferredVaccine);

    FormInputFieldOptions doseNumber = FormInputFieldOptions(
        "Dose number",
        true,
        "You will be alloted the time-slot based on the availability of Vaccine selected by you",
        [Value('Dose 1'), Value('Dose 2')],
        false);

    doseNumber.isMeta = true;
    doseNumber.defaultValueIndex = 0;

    bf.addField(doseNumber);

    FormInputFieldInt cowinSecrete = FormInputFieldInt(
        "COWIN Secrete Code",
        true,
        "This is last four digit of REF ID on the COWIN app (optional)",
        0000,
        9999);
    cowinSecrete.maxLength = 4;
    cowinSecrete.minLength = 4;
    cowinSecrete.isMandatory = false;
    bf.addField(cowinSecrete);

    if (formId != COVID_VACCINATION_EMPLOYEES_BOOKING_FORM_ID) {
      FormInputFieldAttachment payment = FormInputFieldAttachment(
          "Payment receipt (if applicable)",
          false,
          "Please attach image of payment made (you can take screenshot and attach)");
      payment.paymentProofRequired = true;

      bf.addField(payment);
    }

    //NOTE: If this is executed, every time the ID of the field is going to change
    await _gs!.getApplicationService()!.saveBookingForm(bf);
    return bf;
  }

  Future<BookingForm> createNewAdmissionFormForHospital(String formId) async {
    BookingForm admissionForm = new BookingForm(
        formName: "Admission Request Form",
        headerMsg:
            "Your request will be approved based on the information provided by you, please enter the correct information.",
        footerMsg:
            "Please carry previous medical test results and doctor's prescription (if any). Please mark your presence 5 minutes prior to your appointment time.",
        autoApproved: false);

    admissionForm.isSystemTemplate = true;
    admissionForm.id = formId;
    admissionForm.autoApproved = false;

    FormInputFieldText nameInput = FormInputFieldText("Name of the Patient",
        true, "Please enter patient name as per Government ID proof", 100);
    nameInput.isMeta = true;

    admissionForm.addField(nameInput);

    FormInputFieldDateTime dob = FormInputFieldDateTime(
        "Year of Birth of the Patient",
        true,
        "Please select the patient's Year of Birth");
    dob.isMeta = true;
    dob.isAge = true;
    dob.yearOnly = true;

    admissionForm.addField(dob);

    FormInputFieldOptions gender = FormInputFieldOptions(
        "Gender",
        false,
        "Please select the Patient's gender ",
        [Value('Male'), Value('Female'), Value('Other')],
        false);

    gender.isMeta = false;
    gender.defaultValueIndex = 0;

    admissionForm.addField(gender);

    FormInputFieldOptions bloodGroup = FormInputFieldOptions(
        "Blood group",
        false,
        "Please select the Patient's Blood group/type. If it's not known, don't select any option.",
        [
          Value('O+'),
          Value('O-'),
          Value('A+'),
          Value('A-'),
          Value('B+'),
          Value('B-'),
          Value('AB+'),
          Value('AB-')
        ],
        false);

    bloodGroup.isMeta = true;
    bloodGroup.defaultValueIndex = 0;

    admissionForm.addField(bloodGroup);

    FormInputFieldText emergencyContactName = FormInputFieldText(
        "Name of the emergency contact",
        true,
        "Please enter name of the emergency contact",
        50);
    emergencyContactName.isMeta = false;

    admissionForm.addField(emergencyContactName);

    FormInputFieldPhone emergencyContactPhone = FormInputFieldPhone(
        "Emergency contact phone number",
        true,
        "Please enter Emergency contact's phone number on which hospital can contact");
    emergencyContactPhone.isMeta = false;

    admissionForm.addField(emergencyContactPhone);

    FormInputFieldAttachment medicalReport = FormInputFieldAttachment(
        "Medical Report",
        false,
        "Please attach Medical report, if you have (optional)");

    FormInputFieldAttachment medicalPrescription = FormInputFieldAttachment(
        "Doctor's prescription",
        false,
        "Please attach Doctor's prescription, if you have (optional)");

    admissionForm.addField(medicalReport);
    admissionForm.addField(medicalPrescription);

    FormInputFieldText specialNotes = FormInputFieldText(
        "Special notes",
        false,
        "Please enter other details about patient's condition, symptoms, allergies, etc.",
        500);
    admissionForm.addField(specialNotes);

    //NOTE: If this is executed, every time the ID of the field is going to change
    await _gs!.getApplicationService()!.saveBookingForm(admissionForm);

    return admissionForm;
  }

  Future<BookingForm> createGeneralVaccineForm(String formId) async {
    BookingForm vaccineForm = new BookingForm(
        formName: "General Vaccination Form",
        headerMsg:
            "Your request will be approved based on the information provided by you, please enter the correct information.",
        footerMsg:
            "Please carry previous medical test results and doctor's prescription (if any). Please mark your presence 5 minutes prior to your appointment time.",
        autoApproved: false);

    vaccineForm.isSystemTemplate = true;
    vaccineForm.id = formId;
    vaccineForm.autoApproved = true;
    vaccineForm.allowedOnline = false;

    FormInputFieldText nameInput = FormInputFieldText("Name of the Patient",
        true, "Please enter patient name as per Government ID proof", 100);
    nameInput.isMeta = true;

    vaccineForm.addField(nameInput);

    FormInputFieldDateTime dob = FormInputFieldDateTime(
        "Year of Birth of the Patient",
        true,
        "Please select the patient's Year of Birth");
    dob.isMeta = true;
    dob.isAge = true;
    dob.yearOnly = true;

    vaccineForm.addField(dob);

    FormInputFieldOptions gender = FormInputFieldOptions(
        "Gender",
        false,
        "Please select the Patient's gender ",
        [Value('Male'), Value('Female'), Value('Other')],
        false);

    gender.isMeta = false;
    gender.defaultValueIndex = 0;

    vaccineForm.addField(gender);

    FormInputFieldOptions bloodGroup = FormInputFieldOptions(
        "Blood group",
        false,
        "Please select the Patient's Blood group/type. If it's not known, don't select any option.",
        [
          Value('O+'),
          Value('O-'),
          Value('A+'),
          Value('A-'),
          Value('B+'),
          Value('B-'),
          Value('AB+'),
          Value('AB-')
        ],
        false);

    bloodGroup.isMeta = true;
    bloodGroup.defaultValueIndex = 0;

    vaccineForm.addField(bloodGroup);

    FormInputFieldOptions vaccineType = FormInputFieldOptions(
        "Choose the Vaccine",
        false,
        "Please select the desease against which the patient is to be vaccinated",
        [
          Value('Smallpox'),
          Value('Rotavirus'),
          Value('Measles'),
          Value('Chickenpox'),
          Value('Yellow fever'),
          Value('Hepatitis B'),
          Value('Hepatitis A'),
          Value('Tetanus'),
          Value('Influenza'),
          Value('Poliovirus'),
          Value('Others')
        ],
        true);

    vaccineType.isMeta = true;
    vaccineType.defaultValueIndex = 0;

    vaccineForm.addField(vaccineType);

    FormInputFieldPhone patientContactPhone = FormInputFieldPhone(
        "Patient's phone number",
        true,
        "Please enter Patient's phone number on which Doctor can contact");
    patientContactPhone.isMeta = false;

    vaccineForm.addField(patientContactPhone);

    FormInputFieldAttachment medicalReport = FormInputFieldAttachment(
        "Medical Report",
        false,
        "Please attach Medical report, if you have (optional)");

    vaccineForm.addField(medicalReport);

    FormInputFieldAttachment medicalPrescription = FormInputFieldAttachment(
        "Doctor's prescription",
        false,
        "Please attach Doctor's prescription, if you have (optional)");

    vaccineForm.addField(medicalPrescription);

    FormInputFieldText specialNotes = FormInputFieldText(
        "Special notes",
        false,
        "Please enter other details about patient's condition, symptoms, allergies, etc.",
        500);
    vaccineForm.addField(specialNotes);

    //NOTE: If this is executed, every time the ID of the field is going to change
    await _gs!.getApplicationService()!.saveBookingForm(vaccineForm);

    return vaccineForm;
  }

  Future<BookingForm> createDoctorConsultationForm(String formId) async {
    BookingForm doctorConsultationForm = new BookingForm(
        formName: "Doctor Consultation Request",
        headerMsg:
            "Your request will be approved based on the information provided by you, please enter the correct information.",
        footerMsg:
            "Please carry previous medical test results and doctor's prescription (if any). Please mark your presence 5 minutes prior to your appointment time.",
        autoApproved: false);

    doctorConsultationForm.isSystemTemplate = true;
    doctorConsultationForm.id = formId;
    doctorConsultationForm.autoApproved = true;
    doctorConsultationForm.allowedOnline = true;

    FormInputFieldText nameInput = FormInputFieldText("Name of the Patient",
        true, "Please enter patient name as per Government ID proof", 100);
    nameInput.isMeta = true;

    doctorConsultationForm.addField(nameInput);

    FormInputFieldDateTime dob = FormInputFieldDateTime(
        "Year of Birth of the Patient",
        true,
        "Please select the patient's Year of Birth");
    dob.isMeta = true;
    dob.isAge = true;
    dob.yearOnly = true;

    doctorConsultationForm.addField(dob);

    FormInputFieldOptions gender = FormInputFieldOptions(
        "Gender",
        false,
        "Please select the Patient's gender ",
        [Value('Male'), Value('Female'), Value('Other')],
        false);

    gender.isMeta = false;
    gender.defaultValueIndex = 0;

    doctorConsultationForm.addField(gender);

    FormInputFieldOptions bloodGroup = FormInputFieldOptions(
        "Blood group",
        false,
        "Please select the Patient's Blood group/type. If it's not known, don't select any option.",
        [
          Value('O+'),
          Value('O-'),
          Value('A+'),
          Value('A-'),
          Value('B+'),
          Value('B-'),
          Value('AB+'),
          Value('AB-')
        ],
        false);

    bloodGroup.isMeta = true;
    bloodGroup.defaultValueIndex = 0;

    doctorConsultationForm.addField(bloodGroup);

    FormInputFieldOptions problemType = FormInputFieldOptions(
        "Medical Condition",
        false,
        "Please select patient's existing Health condition(s), you can provide more details in the Special Notes",
        [
          Value('Breathing difficulty'),
          Value('Low Oxygen levels'),
          Value('Chest pain'),
          Value('Diabetes'),
          Value('Fever'),
          Value('Cold & Cough'),
          Value('High Blood Pressure'),
          Value('Low Blood Pressure '),
          Value('Headache'),
          Value('Backache'),
          Value('Stomach issue'),
          Value('Kidney disease'),
          Value('Alergies'),
          Value('Chronic Lung disease'),
          Value('Heart Conditions'),
          Value("HIV or weakened Immune System"),
          Value("Liver disease"),
          Value("Skin disease"),
          Value("Neurologic conditions such as dementia"),
          Value("Overweight and Severe Obesity"),
          Value("Pregnancy"),
          Value('Others'),
        ],
        true);

    problemType.isMeta = true;
    problemType.defaultValueIndex = 0;

    doctorConsultationForm.addField(problemType);

    FormInputFieldPhone patientContactPhone = FormInputFieldPhone(
        "Patient's phone number",
        true,
        "Please enter Patient's phone number on which Doctor can contact");
    patientContactPhone.isMeta = false;

    doctorConsultationForm.addField(patientContactPhone);

    FormInputFieldAttachment medicalReport = FormInputFieldAttachment(
        "Medical Report",
        false,
        "Please attach Medical report, if you have (optional)");

    doctorConsultationForm.addField(medicalReport);

    FormInputFieldAttachment medicalPrescription = FormInputFieldAttachment(
        "Doctor's prescription",
        false,
        "Please attach Doctor's prescription, if you have (optional)");

    doctorConsultationForm.addField(medicalPrescription);

    FormInputFieldAttachment payment = FormInputFieldAttachment(
        "Payment receipt",
        false,
        "Please attach image of payment made (you can take screenshot and attach)");
    payment.paymentProofRequired = true;

    doctorConsultationForm.addField(payment);

    FormInputFieldText specialNotes = FormInputFieldText(
        "Special notes",
        false,
        "Please enter other details about patient's condition, symptoms, allergies, etc.",
        500);
    doctorConsultationForm.addField(specialNotes);

    //NOTE: If this is executed, every time the ID of the field is going to change
    await _gs!.getApplicationService()!.saveBookingForm(doctorConsultationForm);

    return doctorConsultationForm;
  }

  Future<BookingForm> createMedicalTestRequestFormForClinic(
      String formId) async {
    BookingForm form = createMedicalTestRequestForm(formId);

    //NOTE: If this is executed, every time the ID of the field is going to change
    await _gs!.getApplicationService()!.saveBookingForm(form);

    return form;
  }

  Future<BookingForm> createMedicalTestRequestFormForHospital(
      String formId) async {
    BookingForm form = createMedicalTestRequestForm(formId);

    //NOTE: If this is executed, every time the ID of the field is going to change
    await _gs!.getApplicationService()!.saveBookingForm(form);

    return form;
  }

  Future<BookingForm> createMedicalTestRequestFormForDiagnosticCenter(
      String formId) async {
    BookingForm form = createMedicalTestRequestForm(formId);

    FormInputFieldOptions atHomeSampleCollection = FormInputFieldOptions(
        "Mode of Sample Collection (if applicable)",
        false,
        "Please select the place of sample collection (only if applicable), for certain tests your physical visit to the testing lab is necessary",
        [Value('Lab'), Value('Home')],
        false);

    atHomeSampleCollection.isMeta = false;
    atHomeSampleCollection.defaultValueIndex = 1;

    form.addField(atHomeSampleCollection);

    //NOTE: If this is executed, every time the ID of the field is going to change
    await _gs!.getApplicationService()!.saveBookingForm(form);

    return form;
  }

  BookingForm createMedicalTestRequestForm(String formId) {
    BookingForm medicalTestForm = new BookingForm(
        formName: "Medical Test Request",
        headerMsg:
            "Your request will be approved based on the information provided by you, please enter the correct information.",
        footerMsg:
            "Please mark your presence 5 minutes prior to your appointment time.",
        autoApproved: false);

    medicalTestForm.isSystemTemplate = true;
    medicalTestForm.id = formId;
    medicalTestForm.autoApproved = false;

    FormInputFieldText nameInput = FormInputFieldText("Name of the Patient",
        true, "Please enter patient name as per Government ID proof", 100);
    nameInput.isMeta = true;

    medicalTestForm.addField(nameInput);

    FormInputFieldDateTime dob = FormInputFieldDateTime(
        "Year of Birth of the Patient",
        true,
        "Please select the patient's Year of Birth");
    dob.isMeta = true;
    dob.isAge = true;
    dob.yearOnly = true;

    medicalTestForm.addField(dob);

    FormInputFieldOptions gender = FormInputFieldOptions(
        "Gender",
        false,
        "Please select the Patient's gender ",
        [Value('Male'), Value('Female'), Value('Other')],
        false);

    gender.isMeta = false;
    gender.defaultValueIndex = 0;

    medicalTestForm.addField(gender);

    FormInputFieldOptions medicalTestType = FormInputFieldOptions(
        "Medical Tests",
        true,
        "Please select the Medical test you want to conduct, you can provide more details in the Special Notes",
        [
          Value('Basic Health Checkup'),
          Value('Advanced Full Body Checkup'),
          Value('Covid-19 - Antigen Rapid'),
          Value('Covid-19 - PCR'),
          Value('Fasting Blood Sugar'),
          Value('Post Lunch Blood Sugar'),
          Value('E.C.G'),
          Value('HIV'),
          Value('HBSAG (Hepatitis B surface antigen)'),
          Value('HCV (Hepatitis C virus)'),
          Value('Complete Blood Test'),
          Value('Urine Routine & Microscopy'),
          Value('Urine Culture'),
          Value('CT Scan'),
          Value('Eye checkup'),
          Value('Cholesterol (lipid profile)'),
          Value('Liver function'),
          Value('Full blood count'),
          Value('Complete Blood Count'),
          Value('Lung function test'),
          Value('Dental checkup'),
          Value('Abdominal Ultrasound'),
          Value('EKG/Echo'),
          Value("Allergy Testing"),
          Value("Liver disease"),
          Value("Endoscopy"),
          Value('Others'),
        ],
        true);

    medicalTestType.isMeta = true;
    medicalTestType.defaultValueIndex = 0;

    medicalTestForm.addField(medicalTestType);

    FormInputFieldPhone patientContactPhone = FormInputFieldPhone(
        "Patient's phone number",
        true,
        "Please enter Patient's phone number on which Doctor can contact");
    patientContactPhone.isMeta = false;

    medicalTestForm.addField(patientContactPhone);

    FormInputFieldText patientEmail = FormInputFieldText("Email", false,
        "Please enter email to which you wish to receive test reports", 60);
    patientEmail.isMeta = true;
    patientEmail.isEmail = true;

    medicalTestForm.addField(patientEmail);

    FormInputFieldAttachment medicalPrescription = FormInputFieldAttachment(
        "Doctor's prescription",
        false,
        "Please attach Doctor's prescription, certain tests are only done on doctor's prescription");

    medicalTestForm.addField(medicalPrescription);

    FormInputFieldText specialNotes = FormInputFieldText(
        "Special notes", false, "Please provide additonal details", 500);
    medicalTestForm.addField(specialNotes);

    return medicalTestForm;
  }

  void createTestHospital() async {
    print("Creating the Test Hospital...");
    Address adrs = new Address(
        city: "Hyderbad",
        state: "Telangana",
        country: "India",
        address: "Shop 61, Towli Chowk Bazar, Gachibowli");

    List<MetaForm> forms = [];

    BookingForm hospitalMedicalCheckup = await (_gs!
        .getApplicationService()!
        .getBookingForm(MEDICAL_TEST_HOSPITAL_FORM) as FutureOr<BookingForm>);
    hospitalMedicalCheckup.autoApproved = false;
    hospitalMedicalCheckup.allowedOnline = false;

    BookingForm hospitalAdmission = await (_gs!
        .getApplicationService()!
        .getBookingForm(HOSPITAL_ADMISSION_FORM) as FutureOr<BookingForm>);
    hospitalAdmission.autoApproved = false;
    hospitalAdmission.allowedOnline = false;

    forms.add(hospitalMedicalCheckup.getMetaForm());
    forms.add(hospitalAdmission.getMetaForm());

    MyGeoFirePoint geoPoint = new MyGeoFirePoint(lat, lon);

    Entity entity = new Entity(
        entityId: Test_Hospital_center,
        name: "Test Selenium Hospital",
        address: adrs,
        advanceDays: 7,
        isPublic: true,
        maxAllowed: 60,
        slotDuration: 60,
        closedOn: [WEEK_DAY_FRIDAY],
        breakStartHour: 13,
        breakStartMinute: 30,
        breakEndHour: 14,
        breakEndMinute: 30,
        startTimeHour: 10,
        startTimeMinute: 30,
        endTimeHour: 21,
        endTimeMinute: 0,
        parentId: null,
        type: EntityType.PLACE_TYPE_HOSPITAL,
        isBookable: true,
        isActive: true,
        verificationStatus: VERIFICATION_VERIFIED,
        coordinates: geoPoint,
        offer: null,
        upiPhoneNumber: "+919611009823",
        phone: "+918328592031",
        upiId: "+919611009823",
        whatsapp: "+918328592031",
        forms: forms,
        maxTokensPerSlotByUser: 2,
        maxTokensByUserInDay: 15,
        allowOnlineAppointment: true,
        allowWalkinAppointment: true);

    try {
      entity.regNum = "testReg111";
      await _gs!.getEntityService()!.upsertEntity(entity);
    } catch (e) {
      print("Exception occured " + e.toString());
    }

    print("Test Hospital create.");

    //create child medical clinic and diagnostics center

    print("Creating the Test Hospital Child clinic...");
    List<MetaForm> clinicForms = [];

    BookingForm hospitalDoctorConsultation = await (_gs!
            .getApplicationService()!
            .getBookingForm(DOCTOR_CONSULTATION_HOSPITAL_FORM)
        as FutureOr<BookingForm>);
    hospitalDoctorConsultation.autoApproved = true;
    hospitalDoctorConsultation.allowedOnline = true;
    clinicForms.add(hospitalDoctorConsultation.getMetaForm());

    Entity childClinic = new Entity(
        entityId: Test_Hospital_Child_Clinic,
        name: "Test Selenium Hospital Clinic",
        address: adrs,
        advanceDays: 7,
        isPublic: true,
        maxAllowed: 60,
        slotDuration: 60,
        closedOn: [WEEK_DAY_FRIDAY],
        breakStartHour: 13,
        breakStartMinute: 30,
        breakEndHour: 14,
        breakEndMinute: 30,
        startTimeHour: 10,
        startTimeMinute: 30,
        endTimeHour: 21,
        endTimeMinute: 0,
        parentId: null,
        type: EntityType.PLACE_TYPE_MEDICAL_CLINIC,
        isBookable: true,
        isActive: true,
        verificationStatus: VERIFICATION_VERIFIED,
        coordinates: geoPoint,
        offer: null,
        upiPhoneNumber: "+919611009823",
        phone: "+918328592031",
        upiId: "+919611009823",
        whatsapp: "+918328592031",
        forms: clinicForms,
        maxTokensPerSlotByUser: 2,
        maxTokensByUserInDay: 15,
        allowOnlineAppointment: true,
        allowWalkinAppointment: true);
    try {
      await _gs!
          .getEntityService()!
          .upsertChildEntityToParent(childClinic, entity.entityId!);
    } catch (e) {
      print("Exception occured " + e.toString());
    }
    print("Test Hospital clild clinic created.");
  }
}
