import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:noq/constants.dart';
import 'package:noq/db/db_model/address.dart';
import 'package:noq/db/db_model/my_geo_fire_point.dart';
import 'package:noq/db/db_service/db_main.dart';
import 'package:noq/db/db_service/entity_service.dart';
import 'package:noq/db/db_service/token_service.dart';
import 'package:noq/db/db_service/user_service.dart';
import 'package:noq/global_state.dart';
import 'package:noq/models/localDB.dart';
import 'package:noq/repository/local_db_repository.dart';
import 'package:noq/services/circular_progress.dart';
import 'package:noq/services/mapService.dart';
import 'package:noq/services/qr_code_generate.dart';
import 'package:noq/services/qrcode_scan.dart';
import 'package:noq/style.dart';
import 'package:intl/intl.dart';
import 'package:noq/utils.dart';
import 'package:noq/widget/appbar.dart';
import 'package:noq/widget/bottom_nav_bar.dart';
import 'package:noq/widget/header.dart';
import 'package:noq/widget/widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:barcode_scan/barcode_scan.dart';
import 'package:flutter/services.dart';

import 'db/db_model/configurations.dart';
import 'db/db_model/entity.dart';
import 'db/db_model/entity_slots.dart';
import 'db/db_model/meta_entity.dart';
import 'db/db_model/meta_user.dart';
import 'db/db_model/slot.dart';
import 'db/db_model/user.dart';
import 'db/db_model/user_token.dart';
import 'db/db_service/configurations_service.dart';
//import 'path';

class UserHomePage extends StatefulWidget {
  @override
  _UserHomePageState createState() => _UserHomePageState();
}

class _UserHomePageState extends State<UserHomePage> {
  int i;
  List<UserToken> _pastBookingsList;
  List<UserToken> _newBookingsList;
  String _upcomingBkgStatus;
  String _pastBkgStatus;
  // UserAppData _userProfile;
  DateTime now = DateTime.now();
  final dtFormat = new DateFormat(dateDisplayFormat);
  bool isUpcomingSet = false;
  bool isPastSet = false;
//Qr code scan result
  ScanResult scanResult;

  @override
  void initState() {
    super.initState();
    _loadBookings();
  }

  Future scan() async {
    try {
      var result = await BarcodeScanner.scan();

      setState(() => scanResult = result);
    } on PlatformException catch (e) {
      var result = ScanResult(
        type: ResultType.Error,
        format: BarcodeFormat.unknown,
      );

      if (e.code == BarcodeScanner.cameraAccessDenied) {
        setState(() {
          result.rawContent = 'The user did not grant the camera permission!';
        });
      } else {
        result.rawContent = 'Unknown error: $e';
      }
      setState(() {
        scanResult = result;
        print(scanResult);
      });
    }
  }

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
        geo: geoPoint,
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
      await EntityService().upsertEntity(entity);
    } catch (e) {
      print("Exception occured " + e);
    }
  }

  void updateEntity() async {
    Address adrs = new Address(
        city: "Hyderbad",
        state: "Telangana",
        country: "India",
        address: "Shop 10, Gachibowli");

    MyGeoFirePoint geoPoint = new MyGeoFirePoint(68, 78);
    Entity entity = new Entity(
        entityId: "Entity101",
        name: "Inorbit_Modified",
        address: adrs,
        advanceDays: 3,
        isPublic: true,
        geo: geoPoint,
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
      await EntityService().upsertEntity(entity);
    } catch (e) {
      print("Exception occured " + e);
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
        geo: geoPoint,
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

    bool added =
        await EntityService().upsertChildEntityToParent(child1, 'Entity101');
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
        geo: geoPoint,
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
        geo: geoPoint,
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
      await EntityService().upsertEntity(entity);
    } catch (e) {
      print("Exception occured " + e);
    }
  }

  void clearAll() async {
    await EntityService().deleteEntity('Entity101');

    await EntityService().deleteEntity('Entity102');

    await TokenService().deleteSlot("Child101-1#2020~7~6");
    await TokenService().deleteSlot("Child101-1#2020~7~7");
    await TokenService().deleteSlot("Child101-1#2020~7~8");

    await TokenService().deleteToken("Child101-1#2020~7~6#10~30#+916052069984");
    await TokenService().deleteToken("Child101-1#2020~7~7#10~30#+916052069984");
    await TokenService().deleteToken("Child101-1#2020~7~7#12~30#+916052069984");
    await TokenService().deleteToken("Child101-1#2020~7~8#10~30#+916052069984");
    //delete user
    await UserService().deleteCurrentUser();
  }

  void dbCall() async {
    await clearAll();

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

    await updateEntity();

    await createChildEntityAndAddToParent('Child101-3', "Raymonds", false);

    await updateEntity();

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
    for (MetaUser me in child1.admins) {
      if (me.ph == '+913611009823') {
        isAdminAssignedOnEntity = true;
        break;
      }
    }

    if (isAdminAssignedOnEntity) {
      print("EntityService.assignAdmin --> SUCCESS");
    } else {
      print("EntityService.assignAdmin -----------------------> FAILURE");
    }

    Firestore fStore = Firestore.instance;

    final DocumentReference userRef = fStore.document('users/+913611009823');
    DocumentSnapshot doc = await userRef.get();
    User newAdmin;
    if (doc.exists) {
      Map<String, dynamic> map = doc.data;
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
      print("TokenService.getCurrentUser -----------------------> FAILURE");
    }

    if (isEntityAddedToAdmin) {
      print("EntityService.assignAdmin --> SUCCESS");
    } else {
      print("EntityService.assignAdmin -----------------------> FAILURE");
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

    if (allToksFromToday != null && allToksFromToday.length == 3) {
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
    for (MetaUser me in child101.admins) {
      if (me.ph == '+913611009823') {
        isAdminRemovedFromEntity = false;
        break;
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
          "EntityService.upsertChildEntityToParent (metaEntity updated in the Admin) --> Failure");
    }

    print(
        "<==========================================TESTING DONE=========================================>");

    int i = 0;
  }

  void loadDataFromPrefs() async {
    // await readData().then((fUser) {
    //   _userProfile = fUser;
    //   if (_userProfile != null) {
    //     if (_userProfile.upcomingBookings.length != 0) {
    //       var bookings = _userProfile.upcomingBookings;
    //       List<BookingListItem> newBookings = new List<BookingListItem>();
    //       List<BookingListItem> pastBookings = new List<BookingListItem>();

    //       setState(() {
    //         for (BookingAppData bk in bookings) {
    //           for (EntityAppData str in _userProfile.storesAccessed) {
    //             if (str.id == bk.storeId) {
    //               if (bk.bookingDate.isBefore(now))
    //                 pastBookings.add(new BookingListItem(str, bk));
    //               else
    //                 newBookings.add(new BookingListItem(str, bk));
    //             }
    //           }
    //         }
    //         _pastBookingsList = pastBookings;
    //         _newBookingsList = newBookings;
    //         if (_pastBookingsList.length != 0) {
    //           _pastBkgStatus = 'Success';
    //         } else
    //           _pastBkgStatus = 'NoBookings';
    //         if (_newBookingsList.length != 0) {
    //           _upcomingBkgStatus = 'Success';
    //         }
    //       });
    //     } else {
    //       setState(() {
    //         _upcomingBkgStatus = 'NoBookings';
    //         _pastBkgStatus = 'NoBookings';
    //       });
    //     }
    //   } else {
    //     setState(() {
    //       _pastBkgStatus = 'NoBookings';
    //       _upcomingBkgStatus = 'NoBookings';
    //     });
    //   }
    // });
  }

  void fetchDataFromGlobalState() {
    if (!Utils.isNullOrEmpty(GlobalState().bookings)) {
      if (GlobalState().bookings.length != 0) {
        List<UserToken> bookings = GlobalState().bookings;
        List<UserToken> newBookings = new List<UserToken>();
        List<UserToken> pastBookings = new List<UserToken>();

        setState(() {
          for (UserToken bk in bookings) {
            if (bk.dateTime.isBefore(now))
              pastBookings.add(bk);
            else
              newBookings.add(bk);
          }
          _pastBookingsList = pastBookings;
          _newBookingsList = newBookings;
          if (_pastBookingsList.length != 0) {
            _pastBkgStatus = 'Success';
          } else
            _pastBkgStatus = 'NoBookings';
          if (_newBookingsList.length != 0) {
            _upcomingBkgStatus = 'Success';
          }
        });
      }
    } else {
      setState(() {
        _upcomingBkgStatus = 'NoBookings';
        _pastBkgStatus = 'NoBookings';
      });
    }
  }

  void _loadBookings() async {
    //Fetch details from server
    _upcomingBkgStatus = 'Loading';
    _pastBkgStatus = 'Loading';
    //loadDataFromPrefs();
    fetchDataFromGlobalState();
  }

  @override
  Widget build(BuildContext context) {
    //if (_upcomingBkgStatus == 'Success') {
    String title = "Home Page";
    return MaterialApp(
      theme: ThemeData.light().copyWith(),
      home: Scaffold(
        appBar: CustomAppBar(
          titleTxt: title,
        ),
        body: ListView(
          children: <Widget>[
            Column(
              children: <Widget>[
                Card(
                  elevation: 20,
                  child: Container(
                    padding: EdgeInsets.all(5),
                    child: Column(
                      children: <Widget>[
                        Container(
                          color: Colors.teal,
                          padding: EdgeInsets.all(3),
                          child: Image.asset(
                            'assets/noq_home_bookPremises.png',
                            width: MediaQuery.of(context).size.width * .95,
                          ),
                        ),
                        // Text(homeScreenMsgTxt, style: homeMsgStyle),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            Column(
                              children: <Widget>[
                                Text(homeScreenMsgTxt2, style: homeMsgStyle2),
                                Text(
                                  homeScreenMsgTxt3,
                                  style: homeMsgStyle3,
                                ),
                              ],
                            ),
                            QrCodeScanner().build(context),

                            //GenerateScreen(),
                            // RaisedButton(
                            //   padding: EdgeInsets.all(1),
                            //   autofocus: false,
                            //   clipBehavior: Clip.none,
                            //   elevation: 20,
                            //   color: highlightColor,
                            //   child: Row(
                            //     children: <Widget>[
                            //       Text('Scan QR', style: buttonSmlTextStyle),
                            //       SizedBox(width: 5),
                            //       Icon(
                            //         Icons.camera,
                            //         color: tealIcon,
                            //         size: 26,
                            //       ),
                            //     ],
                            //   ),
                            //   onPressed: scan,
                            // )
                          ],
                        )
                      ],
                    ),
                  ),
                  //child: Image.asset('assets/noq_home.png'),
                ),
                Card(
                  elevation: 20,
                  child: Theme(
                    data: ThemeData(
                      unselectedWidgetColor: Colors.grey[600],
                      accentColor: Colors.teal,
                    ),
                    child: ExpansionTile(
                      //key: PageStorageKey(this.widget.headerTitle),
                      initiallyExpanded: true,
                      title: Text(
                        "Upcoming Bookings",
                        style: TextStyle(
                            color: Colors.blueGrey[700], fontSize: 17),
                      ),
                      backgroundColor: Colors.white,
                      leading: Icon(
                        Icons.date_range,
                        color: primaryIcon,
                      ),
                      children: <Widget>[
                        if (_upcomingBkgStatus == 'Success')
                          ConstrainedBox(
                            constraints: new BoxConstraints(
                              maxHeight:
                                  MediaQuery.of(context).size.height * .6,
                            ),

                            // decoration: BoxDecoration(
                            //     shape: BoxShape.rectangle,
                            //     borderRadius: BorderRadius.all(Radius.circular(8.0))),
                            // height: MediaQuery.of(context).size.height * .6,
                            // margin: EdgeInsets.fromLTRB(10, 10, 10, 10),
                            child: ListView.builder(
                              shrinkWrap: true,
                              //scrollDirection: Axis.vertical,
                              itemBuilder: (BuildContext context, int index) {
                                return Container(
                                  child: new Column(
                                      children: _newBookingsList
                                          .map(_buildItem)
                                          .toList()),
                                  //children: <Widget>[firstRow, secondRow],
                                );
                              },
                              itemCount: 1,
                            ),
                          ),
                        if (_upcomingBkgStatus == 'NoBookings')
                          _emptyStorePage("No bookings yet.. ",
                              "Book now to save time later!! "),
                        if (_upcomingBkgStatus == 'Loading')
                          showCircularProgress(),
                      ],
                    ),
                  ),
                ),
                Card(
                  elevation: 20,
                  child: Theme(
                    data: ThemeData(
                      unselectedWidgetColor: Colors.grey[600],
                      accentColor: Colors.teal,
                    ),
                    child: ExpansionTile(
                      title: Text(
                        "Past Bookings",
                        style: TextStyle(
                            color: Colors.blueGrey[700], fontSize: 17),
                      ),
                      backgroundColor: Colors.white,
                      leading: Icon(
                        Icons.access_time,
                        color: primaryIcon,
                      ),
                      children: <Widget>[
                        Column(
                          children: <Widget>[
                            if (_pastBkgStatus == "Success")
                              Container(
                                //height: MediaQuery.of(context).size.width * .5,
                                child: ListView.builder(
                                  shrinkWrap: true,
                                  scrollDirection: Axis.vertical,
                                  itemBuilder:
                                      (BuildContext context, int index) {
                                    return Container(
                                      child: new Column(
                                          children: _pastBookingsList
                                              .map(_buildItem)
                                              .toList()),
                                      //children: <Widget>[firstRow, secondRow],
                                    );
                                  },
                                  itemCount: 1,
                                ),
                              ),
                            if (_pastBkgStatus == 'NoBookings')
                              _emptyStorePage("No bookings in past..",
                                  "Book now to save time later!! "),
                            if (_pastBkgStatus == 'Loading')
                              showCircularProgress(),
                          ],
                        )
                      ],
                    ),
                  ),
                ),
                RaisedButton(
                  color: Colors.blue,
                  onPressed: dbCall,
                  child: Icon(Icons.add),
                ),
              ],
            ),
          ],
        ),
        drawer: CustomDrawer(),
        bottomNavigationBar: CustomBottomBar(
          barIndex: 0,
        ),
        // if (_upcomingBkgStatus == 'NoBookings') {
        //   return _emptyStorePage();
        // } else {
        //   return showCircularProgress();
        // }
      ),
    );
  }

  Widget _emptyStorePage(String msg1, String msg2) {
    return Center(
        child: Column(children: <Widget>[
      myDivider,
      Container(
          margin: EdgeInsets.fromLTRB(10, 10, 10, 10),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text(msg1, style: highlightTextStyle),
              Text(msg2, style: highlightSubTextStyle),
            ],
          ))
    ]));
  }

  Widget _buildItem(UserToken booking) {
    return Card(
      //  margin: EdgeInsets.all(10.0),

      color: Colors.white,
      elevation: 10,
      child: Container(
        decoration: BoxDecoration(
            shape: BoxShape.rectangle,
            borderRadius: BorderRadius.all(Radius.circular(5.0)),
            border: Border.all(color: Colors.teal)),
        child: new Row(
            //crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.end,
            children: <Widget>[
              Container(
                width: MediaQuery.of(context).size.width * .65,
                height: MediaQuery.of(context).size.width * .7 / 4,
                child: Column(
                  //mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: <Widget>[
                    Row(
                      children: <Widget>[],
                    ),
                    Container(
                      alignment: Alignment.centerLeft,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: <Widget>[
                          Text(
                            //'T-1030-14',
                            booking.number.toString(),
                            style: tokenTextStyle, textAlign: TextAlign.left,
                          ),
                        ],
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Container(
                          alignment: Alignment.centerLeft,
                          width: MediaQuery.of(context).size.width * .2,
                          //Text('Where: ', style: tokenHeadingTextStyle),
                          child: Text(
                            booking.entityName,
                            overflow: TextOverflow.ellipsis,
                            style: tokenDataTextStyle,
                          ),
                        ),
                        Container(
                          alignment: Alignment.centerLeft,
                          width: MediaQuery.of(context).size.width * .4,
                          //Text('Where: ', style: tokenHeadingTextStyle),
                          child: Row(
                            children: <Widget>[
                              Container(
                                // margin: EdgeInsets.fromLTRB(
                                //     0,
                                //     0,
                                //     MediaQuery.of(context).size.width * .02,
                                //     MediaQuery.of(context).size.width * .05),
                                height: MediaQuery.of(context).size.width * .07,
                                // width: 20.0,
                                child: IconButton(
                                    padding: EdgeInsets.all(0),
                                    alignment: Alignment.centerRight,
                                    highlightColor: Colors.orange[300],
                                    icon: Icon(
                                      Icons.phone,
                                      color: primaryIcon,
                                      size: 20,
                                    ),
                                    onPressed: () => {}
                                    //callStore(booking.storeInfo.phone),
                                    ),
                              ),
                              Container(
                                // margin: EdgeInsets.fromLTRB(
                                //     0,
                                //     0,
                                //     MediaQuery.of(context).size.width * .02,
                                //     MediaQuery.of(context).size.width * .05),
                                height: MediaQuery.of(context).size.width * .07,
                                // width: 20.0,
                                child: IconButton(
                                  padding: EdgeInsets.all(0),
                                  alignment: Alignment.center,
                                  highlightColor: Colors.orange[300],
                                  icon: Icon(
                                    Icons.location_on,
                                    color: primaryIcon,
                                    size: 22,
                                  ),
                                  onPressed: () => launchURL(
                                      booking.entityName,
                                      //TODO: Store address

                                      // booking.storeInfo.adrs.toString(),
                                      'Update this field, add address',
                                      booking.lat,
                                      booking.lon),
                                ),
                              ),
                              // Container(
                              //   // margin: EdgeInsets.fromLTRB(
                              //   //     0, 0, MediaQuery.of(context).size.width * .01, 0),
                              //   height: MediaQuery.of(context).size.width * .06,
                              //   // width: 20,
                              //   child: IconButton(
                              //     padding: EdgeInsets.all(0),
                              //     alignment: Alignment.centerLeft,
                              //     onPressed: () => {},
                              //     //toggleFavorite(booking.storeInfo),
                              //     highlightColor: Colors.orange[300],
                              //     iconSize: 20,
                              //     icon: booking.storeInfo.isFavourite
                              //         ? Icon(
                              //             Icons.favorite,
                              //             color: Colors.red[800],
                              //           )
                              //         : Icon(
                              //             Icons.favorite_border,
                              //             color: Colors.red[800],
                              //           ),
                              //   ),
                              // ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Container(
                //alignment: Alignment.centerRight,
                width: MediaQuery.of(context).size.width * .25,
                padding: EdgeInsets.fromLTRB(0, 5, 0, 0),
                child: Column(
                  //mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  //crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        // Text('Date: ', style: tokenHeadingTextStyle),
                        Text(
                          dtFormat.format(booking.dateTime),
                          style: tokenDataTextStyle,
                        ),
                      ],
                    ),
                    Container(
                      height: 5,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: <Widget>[
                        // Text('Time: ', style: tokenHeadingTextStyle),
                        Text(
                          booking.dateTime.hour.toString() +
                              ':' +
                              booking.dateTime.minute.toString(),
                          style: tokenDateTextStyle,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ]),
      ),
    );
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
        geo: geoPoint,
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
      await EntityService().upsertChildEntityToParent(entity, "Entity101");
    } catch (e) {
      print("Exception occured " + e);
    }
  }
}
