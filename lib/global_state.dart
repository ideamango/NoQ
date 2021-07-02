import 'dart:async';
import 'dart:io';

import 'package:LESSs/services/location_util.dart';
import 'package:LESSs/triplet.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:enum_to_string/enum_to_string.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:version/version.dart';

import './db/db_model/configurations.dart';
import './db/db_model/entity.dart';
import './db/db_model/meta_entity.dart';
import './db/db_model/app_user.dart';
import './db/db_model/slot.dart';
import './db/db_model/user_token.dart';
import './db/db_service/booking_application_service.dart';

import './db/db_service/configurations_service.dart';
import './db/db_service/entity_service.dart';
import './db/db_service/token_service.dart';
import './enum/entity_type.dart';
import './events/local_notification_data.dart';
import './location.dart';
import './services/auth_service.dart';
import './tuple.dart';

import './utils.dart';
import 'package:package_info/package_info.dart';
import 'db/db_model/employee.dart';
import 'db/db_model/entity_slots.dart';
import 'db/db_service/notification_service.dart';
import 'db/db_service/user_service.dart';
import 'enum/entity_role.dart';
import 'events/event_bus.dart';
import 'events/events.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:firebase_remote_config/firebase_remote_config.dart';

class GlobalState {
  AppUser _currentUser;
  Configurations _conf;
  List<Tuple<UserToken, DocumentSnapshot>> bookings;
  String lastSearchName;
  EntityType lastSearchType;
  List<Entity> lastSearchResults;
  Map<String, Entity> _entities;
  FirebaseApp _secondaryFirebaseApp;
  FirebaseAuth _fbAuth;
  FirebaseStorage firebaseStorage;

  //true is entity is saved on server and false if it is a new entity
  Map<String, bool> _entityState;
  EntityService _entityService;
  UserService _userService;
  TokenService _tokenService;
  NotificationService _notificationService;
  BookingApplicationService _applicationService;
  AuthService _authService;
  static Future<Null> isWorking;
  Location _locData;
  PackageInfo packageInfo;

  String appName;
  String packageName;
  String version;
  String buildNumber;
  bool isAndroid;
  bool isIOS;

  RemoteConfig remoteConfig;

  static GlobalState _gs;

  GlobalState._();

  Future<FirebaseApp> initSecondaryFirebaseApp() async {
    packageInfo = await PackageInfo.fromPlatform();

    appName = packageInfo.appName;
    packageName = packageInfo.packageName;
    version = packageInfo.version;
    buildNumber = packageInfo.buildNumber;
    isAndroid = Platform.isAndroid;
    isIOS = Platform.isIOS;

    //comment following line to continue to work with secondary Firebase
    _gs._secondaryFirebaseApp = Firebase.apps[0];

    String appId;
    String apiKey;
    String messagingSenderId;
    String projectId;
    String clientId;
    String storageBucket;
    String dbUrl;

    // for (FirebaseApp app in Firebase.apps) {
    //   if (app.name == "SecondaryFirebaseApp") {
    //     _gs._secondaryFirebaseApp = app;
    //     return app;
    //   }
    // }

    // if (_locData.countryCode == "Test") {
    //   appId = Platform.isAndroid
    //       ? "1:166667469482:android:f488ccf8299e9542e9c6d3"
    //       : "1:166667469482:ios:bcaebbe8fae4c8c2e9c6d3";

    //   apiKey = "AIzaSyBvRdM2jfG54VzciJ3sfef4xq_TalMmOAM";
    //   messagingSenderId = "166667469482";
    //   projectId = "awesomenoq";
    //   clientId =
    //       "166667469482-fjai5a1piepdp0tlr05hqrhl7clrq727.apps.googleusercontent.com";
    //   storageBucket = 'awesomenoq.appspot.com';
    //   dbUrl = 'https: //awesomenoq.firebaseio.com';
    //   await Firebase.initializeApp(
    //       name: 'SecondaryFirebaseApp',
    //       options: FirebaseOptions(
    //           appId: appId,
    //           apiKey: apiKey,
    //           bundleID: 'net.lesss',
    //           gcmSenderID: messagingSenderId,
    //           googleAppID: appId,
    //           iosBundleId: "net.lesss",
    //           iosClientId: clientId,
    //           messagingSenderId: messagingSenderId,
    //           projectId: projectId,
    //           storageBucket: storageBucket,
    //           databaseURL: dbUrl));
    // } else if (_locData.isEU) {
    //   //firebase project with location as EU, not handled yet

    // } else if (_locData.countryCode == "IN") {
    //   appId = Platform.isAndroid
    //       ? "1:643643889883:android:2c47f2ee29f66b35c594fe"
    //       : "1:643643889883:ios:1e17e4f8114d5fd0c594fe";

    //   apiKey = "AIzaSyDYo0KL7mzN9-0ghFsO4ydCLQYFXoWvujg";
    //   messagingSenderId = "643643889883";
    //   projectId = "sukoon-india";

    //   await Firebase.initializeApp(
    //       name: 'SecondaryFirebaseApp',
    //       options: FirebaseOptions(
    //           appId: appId,
    //           apiKey: apiKey,
    //           messagingSenderId: messagingSenderId,
    //           projectId: projectId,
    //           iosBundleId: "net.lesss",
    //           trackingId: "",
    //           iosClientId:
    //               "643643889883-dffliinmljkuoh98r25fqt5c2up4rq9r.apps.googleusercontent.com",
    //           storageBucket: "gs://sukoon-india.appspot.com",
    //           databaseURL: "https://sukoon-india.firebaseio.com"));
    // } else if (_locData.countryCode == "US") {
    //   // appId = Platform.isAndroid
    //   //     ? "1:964237045237:android:dac9374ed36f850a5784bc"
    //   //     : "1:964237045237:ios:458f3c6fc630f29c5784bc";

    //   // apiKey = "AIzaSyCZlz1Cdyi2wjOvhuIFJmWTnc4m8eUuW34";
    //   // messagingSenderId = "964237045237";
    //   // projectId = "lesssusdefault";

    //   // await Firebase.initializeApp(
    //   //     name: 'SecondaryFirebaseApp',
    //   //     options: FirebaseOptions(
    //   //         appId: appId,
    //   //         apiKey: apiKey,
    //   //         messagingSenderId: messagingSenderId,
    //   //         projectId: projectId));
    //   _gs._secondaryFirebaseApp = Firebase.apps[0];
    // } else {
    //   //for all countries store in Default-US
    //   _gs._secondaryFirebaseApp = Firebase.apps[0];
    // }

    if (_gs._secondaryFirebaseApp == null) {
      _gs._secondaryFirebaseApp = Firebase.app('SecondaryFirebaseApp');
    }

    if (_gs.firebaseStorage == null) {
      _gs.firebaseStorage =
          FirebaseStorage.instanceFor(app: _gs._secondaryFirebaseApp);
    }

    return _gs._secondaryFirebaseApp;
  }

  Configurations getConfigurations() {
    return _conf;
  }

  Location getLocation() {
    return _locData;
  }

  bool isEligibleForUpdate() {
    if (_conf.latestVersion == null) return false;

    Version latestVer = _conf.getLatestPublishedVersion();
    if (latestVer != null) {
      try {
        Version currentVersion = Version.parse(version);
        if (currentVersion < latestVer) {
          return true;
        }
      } catch (e) {
        return false;
      }
    }
    return false;
  }

  static Future<GlobalState> getGlobalState() async {
    Location loc;
    if (_gs == null || _gs._locData == null) {
      //automatically detect country
      //loc = await LocationUtil.getLocation();
    }
    //loc.countryCode = "Test";
    //return await GlobalState.getGlobalStateForCountry(loc);

    return await GlobalState.getGlobalStateForCountry(loc);
  }

  static Future<GlobalState> getGlobalStateForCountry(Location location) async {
    if (isWorking != null) {
      await isWorking; // wait for future complete
      return getGlobalStateForCountry(location);
    }

    //lock
    var completer = new Completer<Null>();
    isWorking = completer.future;

    if (_gs == null) {
      _gs = new GlobalState._();
    }

    if (_gs._secondaryFirebaseApp == null) {
      await _gs.initSecondaryFirebaseApp();
    }

    if (_gs._fbAuth == null) {
      _gs._fbAuth = FirebaseAuth.instanceFor(app: _gs._secondaryFirebaseApp);
    }

    if (_gs.remoteConfig == null) {
      _gs.remoteConfig = RemoteConfig.instance;
    }

    if (_gs._authService == null) {
      _gs._authService = new AuthService(_gs._secondaryFirebaseApp);
    }

    if (_gs._entityService == null) {
      _gs._entityService = new EntityService(_gs._secondaryFirebaseApp);
    }

    if (_gs._userService == null) {
      _gs._userService = new UserService(_gs._secondaryFirebaseApp);
    }

    if (_gs._notificationService == null) {
      _gs._notificationService =
          new NotificationService(_gs._secondaryFirebaseApp);
    }

    if (_gs._tokenService == null) {
      _gs._tokenService = new TokenService(_gs._secondaryFirebaseApp);
    }

    if (_gs._applicationService == null) {
      _gs._applicationService =
          new BookingApplicationService(_gs._secondaryFirebaseApp, _gs);
    }

    if (_gs._conf == null && _gs._fbAuth.currentUser != null) {
      try {
        _gs._conf = await ConfigurationService(_gs._secondaryFirebaseApp)
            .getConfigurations();
      } catch (e) {
        print(
            "Error initializing GlobalState, Configuration could not be fetched from server..");
      }
    }

    if (_gs._locData == null && _gs._conf != null) {
      if (location != null) {
        _gs._locData = location;
      } else {
        //automatically detect country
        try {
          _gs._locData = await LocationUtil.getLocation(_gs._conf);
        } catch (e) {
          print("Error getting location from the IP: " + e.toString());
        }
      }
    }

    if (_gs._entities == null) {
      _gs._entities = new Map<String, Entity>();
      _gs._entityState = new Map<String, bool>();
    }

    if (_gs._currentUser == null &&
        _gs._conf != null &&
        _gs._fbAuth.currentUser != null) {
      try {
        _gs._currentUser = await _gs._userService.getCurrentUser(_gs._locData);
        if (_gs._currentUser != null &&
            Utils.isNullOrEmpty(_gs._currentUser.favourites))
          _gs._currentUser.favourites = [];
      } catch (e) {
        print(
            "Error initializing GlobalState, User details could not be fetched from server..");
      }
    }

    //_gs.getUpcomingBookings(1, 5);

    // if (_gs._currentUser != null && _gs.bookings == null) {
    //   DateTime fromDate = DateTime.now().subtract(new Duration(days: 60));
    //   DateTime toDate = DateTime.now().add(new Duration(days: 30));

    //   try {
    //     List<Tuple<UserTokens, DocumentSnapshot>> listTokens =
    //         await _gs._tokenService.getTokens(null, _gs._currentUser.ph, null,
    //             DateTime.now(), false, null, null, 5);
    //     _gs.bookings = [];

    //     if (listTokens != null && listTokens.length > 0) {
    //       for (Tuple<UserTokens, DocumentSnapshot> tokens in listTokens) {
    //         for (UserToken token in tokens.item1.tokens) {
    //           _gs.bookings.add(new Tuple<UserToken, DocumentSnapshot>(
    //               item1: token, item2: tokens.item2));
    //         }
    //       }
    //     }
    //   } catch (e) {
    //     print("In exception");
    //   }
    // }

    //unlock
    completer.complete();
    isWorking = null;

    return _gs;
  }

  UserService getUserService() {
    return _gs == null ? null : _gs._userService;
  }

  NotificationService getNotificationService() {
    return _gs == null ? null : _gs._notificationService;
  }

  EntityService getEntityService() {
    return _gs._entityService;
  }

  BookingApplicationService getApplicationService() {
    return _gs == null ? null : _gs._applicationService;
  }

  TokenService getTokenService() {
    return _gs == null ? null : _gs._tokenService;
  }

  AppUser getCurrentUser() {
    return _currentUser;
  }

  AuthService getAuthService() {
    return _authService;
  }

  static Future<String> getCountry() async {
    return _gs == null ? null : _gs._locData.country;
  }

  Future<Tuple<Entity, bool>> getEntity(String id,
      [bool fetchFromServer = false]) async {
    if (_entityService == null) return null;
    if (fetchFromServer || !_entities.containsKey(id)) {
      Entity ent = await _entityService.getEntity(id);
      if (ent == null) {
        return null;
      }

      _entities[id] = ent;
      _entityState[id] = true;

      return new Tuple(item1: ent, item2: true);
    } else if (_entities.containsKey(id)) {
      return new Tuple(item1: _entities[id], item2: _entityState[id]);
    }
  }

  Future<bool> removeEmployee(String entityId, String phone) async {
    if (_gs == null) return false;
    Entity updatedEntity =
        await _gs.getEntityService().removeEmployee(entityId, phone);
    if (updatedEntity != null) {
      putEntity(updatedEntity, false);
      return true;
    }

    return false;
  }

  Future<bool> addEmployee(
      String entityId, Employee employee, EntityRole role) async {
    Entity updatedEntity =
        await _gs.getEntityService().upsertEmployee(entityId, employee, role);
    if (updatedEntity != null) {
      putEntity(updatedEntity, false);
      return true;
    }
    return false;
  }

  Future<bool> removeEntity(String id, [String parentId]) async {
    bool isDeleted = await _entityService.deleteEntity(id);

    if (isDeleted) {
      _currentUser.entities.removeWhere((element) => element.entityId == id);
      _currentUser.entityVsRole.remove(id);
      _entities.remove(id);
      _entityState.remove(id);
      if (Utils.isNotNullOrEmpty(parentId)) {
        Tuple<Entity, bool> parent = await getEntity(parentId, false);
        Entity parentEnt = parent.item1;
        parentEnt.removeChildEntity(id);
      }
    }
    return isDeleted;
  }

  Future<bool> putEntity(Entity entity, bool saveOnServer,
      [String parentId]) async {
    _entities[entity.entityId] = entity;

    bool existsInUser = false;
    if (Utils.isNullOrEmpty(_currentUser.entities)) {
      _currentUser.entities = [];
    }
    for (MetaEntity mEnt in _currentUser.entities) {
      if (mEnt.entityId == entity.entityId) {
        existsInUser = true;
      }
    }

    if (!existsInUser) {
      _currentUser.entities.add(entity.getMetaEntity());
    }

    if (_currentUser.entityVsRole == null) {
      _currentUser.entityVsRole = new Map<String, EntityRole>();
    }

    _currentUser.entityVsRole[entity.entityId] = EntityRole.Admin;

    bool saved = false;
    if (saveOnServer) {
      if (Utils.isNotNullOrEmpty(parentId)) {
        saved =
            await _entityService.upsertChildEntityToParent(entity, parentId);
      } else {
        saved = await _entityService.upsertEntity(entity);
      }
    }
    _entityState[entity.entityId] = saved;
    return saved;
  }

  void setPastSearch(List<Entity> entityList, String name, EntityType type) {
    if (_gs == null) return;
    _gs.lastSearchResults = entityList;
    _gs.lastSearchName = name;
    _gs.lastSearchType = type;
    return;
  }

  Future<List<UserToken>> getPastBookings(int startNum, int takeCount) async {
    if (_gs._currentUser == null) {
      return [];
    }

    if (_gs._currentUser != null && _gs.bookings == null) {
      _gs.bookings = [];
    }

    List<UserToken> newBookings = [];
    DateTime now = DateTime.now();

    for (Tuple<UserToken, DocumentSnapshot> tok in _gs.bookings) {
      if (tok.item1.parent.dateTime.isBefore(now)) newBookings.add(tok.item1);
    }

    newBookings.sort((a, b) => (a.parent.dateTime.millisecondsSinceEpoch >
            b.parent.dateTime.millisecondsSinceEpoch)
        ? -1
        : 1);
    //CASE:1 - When number of Bokkings we are trying is already in the GS collection.
    // So no Server call. Get from GS
    if (newBookings.length >= startNum + takeCount - 1) {
      //e.g. total items are 10, start num is 6 and take count is 5
      //e.g. total items are 15, start num is 6 and take count is 5

      List<UserToken> list = [];
      list.addAll(newBookings.getRange(startNum - 1, startNum + takeCount - 1));
      return list;
    }
    //CASE:2 - Few bookings can be fetched from GS collection  and all from given range are not in GS collection,
    // So some are fetched from Server.
    else if (newBookings.length >= startNum &&
        newBookings.length < startNum + takeCount - 1) {
      //e.g. total items are 1, start num is 1 and take count is 3
      //e.g. total items are 10, start num is 6 and take count is 8
      //e.g. total items are 10, start num is 1 and take count is 11

      List<UserToken> uts = [];
      uts.addAll(newBookings.getRange(startNum - 1, newBookings.length));

      Tuple<UserToken, DocumentSnapshot> lastDoc;
      if (uts.length > 0) {
        for (Tuple<UserToken, DocumentSnapshot> doc in _gs.bookings) {
          if (doc.item1.getID() == uts[uts.length - 1].getID()) {
            lastDoc = doc;
            break;
          }
        }
      }

      DocumentSnapshot lastDocSnap;
      if (lastDoc != null) {
        if (lastDoc.item2 == null) {
          Tuple<UserTokens, DocumentSnapshot> tokDetails = await _gs
              ._tokenService
              .getToken(lastDoc.item1.parent.getTokenId());

          if (tokDetails != null) {
            lastDoc.item2 = tokDetails.item2;
            lastDocSnap = tokDetails.item2;
          }
        } else {
          lastDocSnap = lastDoc.item2;
        }
      }
      //remaining tokens to be loaded from server

      int remainingCount = takeCount - uts.length;
      List<Tuple<UserTokens, DocumentSnapshot>> remainingTokens =
          await _gs._tokenService.getTokens(null, _gs._currentUser.ph, null,
              now, true, null, lastDocSnap, remainingCount);

      if (remainingTokens != null && remainingTokens.length > 0) {
        for (Tuple<UserTokens, DocumentSnapshot> tokens in remainingTokens) {
          for (UserToken token in tokens.item1.tokens) {
            _gs.bookings.add(new Tuple<UserToken, DocumentSnapshot>(
                item1: token, item2: tokens.item2));
            uts.add(token);
          }
        }
      }
      return uts;
    }
    //CASE:3 - Requested range for tokens starts just after the length of GS collection
    // All items to be fetched from Server.
    else if (startNum == newBookings.length + 1) {
      //e.g. total items are 10, start num is 11 and take count is 3
      //this is first time scenario where start num = 1 and no items will be there in the newBookings
      //also this will be usual load more scenario from server when user reaches to the last item in the list
      List<UserToken> uts = [];
      Tuple<UserToken, DocumentSnapshot> lastDoc;
      if (newBookings.length > 0) {
        for (Tuple<UserToken, DocumentSnapshot> doc in _gs.bookings) {
          if (doc.item1.getID() ==
              newBookings[newBookings.length - 1].getID()) {
            lastDoc = doc;
            break;
          }
        }
      }

      DocumentSnapshot lastDocSnap;
      if (lastDoc != null) {
        if (lastDoc.item2 == null) {
          Tuple<UserTokens, DocumentSnapshot> tokDetails = await _gs
              ._tokenService
              .getToken(lastDoc.item1.parent.getTokenId());

          if (tokDetails != null) {
            lastDoc.item2 = tokDetails.item2;
            lastDocSnap = tokDetails.item2;
          }
        } else {
          lastDocSnap = lastDoc.item2;
        }
      }

      List<Tuple<UserTokens, DocumentSnapshot>> allTokens =
          await _gs._tokenService.getTokens(null, _gs._currentUser.ph, null,
              now, true, null, lastDocSnap, takeCount);

      if (allTokens != null && allTokens.length > 0) {
        for (Tuple<UserTokens, DocumentSnapshot> tokens in allTokens) {
          for (UserToken token in tokens.item1.tokens) {
            _gs.bookings.add(new Tuple<UserToken, DocumentSnapshot>(
                item1: token, item2: tokens.item2));
            uts.add(token);
          }
        }
      }
      return uts;
    } else {
      throw new Exception("Supplied param for loading Tokens is not valid");
    }
  }

  Future<List<UserToken>> getUpcomingBookings(
      int startNum, int takeCount) async {
    if (_gs._currentUser == null) {
      return [];
    }

    if (_gs._currentUser != null && _gs.bookings == null) {
      _gs.bookings = [];
    }

    List<UserToken> newBookings = [];
    DateTime now = DateTime.now();

    for (Tuple<UserToken, DocumentSnapshot> tok in _gs.bookings) {
      if (!tok.item1.parent.dateTime.isBefore(now)) newBookings.add(tok.item1);
    }

    newBookings.sort((a, b) => (a.parent.dateTime.millisecondsSinceEpoch >
            b.parent.dateTime.millisecondsSinceEpoch)
        ? 1
        : -1);
    //CASE:1
    if (newBookings.length >= startNum + takeCount - 1) {
      //e.g. total items are 10, start num is 6 and take count is 5
      List<UserToken> list = [];
      list.addAll(newBookings.getRange(startNum - 1, startNum + takeCount - 1));
      return list;
    }
    //CASE:2
    else if (newBookings.length >= startNum &&
        newBookings.length < startNum + takeCount - 1) {
      List<UserToken> uts = [];
      uts.addAll(newBookings.getRange(startNum - 1, newBookings.length));

      Tuple<UserToken, DocumentSnapshot> lastDoc;

      if (uts.length > 0) {
        for (Tuple<UserToken, DocumentSnapshot> doc in _gs.bookings) {
          if (doc.item1.getID() == uts[uts.length - 1].getID()) {
            lastDoc = doc;
            break;
          }
        }
      }
      DocumentSnapshot lastDocSnap;
      if (lastDoc != null) {
        if (lastDoc.item2 == null) {
          Tuple<UserTokens, DocumentSnapshot> tokDetails = await _gs
              ._tokenService
              .getToken(lastDoc.item1.parent.getTokenId());

          if (tokDetails != null) {
            lastDoc.item2 = tokDetails.item2;
            lastDocSnap = tokDetails.item2;
          }
        } else {
          lastDocSnap = lastDoc.item2;
        }
      }
      //remaining tokens to be loaded from server

      int remainingCount = takeCount - uts.length;
      List<Tuple<UserTokens, DocumentSnapshot>> remainingTokens =
          await _gs._tokenService.getTokens(null, _gs._currentUser.ph, null,
              now, false, null, lastDocSnap, remainingCount);

      if (remainingTokens != null && remainingTokens.length > 0) {
        for (Tuple<UserTokens, DocumentSnapshot> tokens in remainingTokens) {
          for (UserToken token in tokens.item1.tokens) {
            _gs.bookings.add(new Tuple<UserToken, DocumentSnapshot>(
                item1: token, item2: tokens.item2));
            uts.add(token);
          }
        }
      }
      return uts;
    }
    //CASE:3
    else if (startNum == newBookings.length + 1) {
      //this is first time scenario where start num = 1 and no items will be there in the newBookings
      //also this will be usual load more scenario from server when user reaches to the last item in the list
      List<UserToken> uts = [];
      Tuple<UserToken, DocumentSnapshot> lastDoc;
      if (newBookings.length > 0) {
        for (Tuple<UserToken, DocumentSnapshot> doc in _gs.bookings) {
          if (doc.item1.getID() ==
              newBookings[newBookings.length - 1].getID()) {
            lastDoc = doc;
            break;
          }
        }
      }

      DocumentSnapshot lastDocSnap;
      if (lastDoc != null) {
        if (lastDoc.item2 == null) {
          Tuple<UserTokens, DocumentSnapshot> tokDetails = await _gs
              ._tokenService
              .getToken(lastDoc.item1.parent.getTokenId());

          if (tokDetails != null) {
            lastDoc.item2 = tokDetails.item2;
            lastDocSnap = tokDetails.item2;
          }
        } else {
          lastDocSnap = lastDoc.item2;
        }
      }

      List<Tuple<UserTokens, DocumentSnapshot>> allTokens =
          await _gs._tokenService.getTokens(null, _gs._currentUser.ph, null,
              now, false, null, lastDocSnap, takeCount);

      if (allTokens != null && allTokens.length > 0) {
        for (Tuple<UserTokens, DocumentSnapshot> tokens in allTokens) {
          for (UserToken token in tokens.item1.tokens) {
            _gs.bookings.add(new Tuple<UserToken, DocumentSnapshot>(
                item1: token, item2: tokens.item2));
            uts.add(token);
          }
        }
      }
      return uts;
    } else {
      throw new Exception("Supplied param for loading Tokens is not valid");
    }
  }

  List<EntityType> getActiveEntityTypes() {
    List<EntityType> types = [];
    if (_conf == null) return types;
    List<String> stringTypes;

    if (isAndroid) {
      stringTypes = _conf.androidAppVersionToEntityTypes[version];
    }

    if (isIOS) {
      stringTypes = _conf.iosAppVersionToEntityTypes[version];
    }

    if (stringTypes != null) {
      for (String type in stringTypes) {
        types.add(EnumToString.fromString(EntityType.values, type));
      }
    }

    return types;
  }

  List<EntityType> getActiveChildEntityTypes(EntityType parentType) {
    List<EntityType> types = [];
    if (_conf == null) return types;

    if (!_conf.typeToChildType
        .containsKey(EnumToString.convertToString(parentType))) {
      return types;
    }

    List<String> childTypes =
        _conf.typeToChildType[EnumToString.convertToString(parentType)];

    List<EntityType> activeTypeForThisAppVerison = getActiveEntityTypes();

    for (String childType in childTypes) {
      EntityType type = EnumToString.fromString(EntityType.values, childType);
      for (EntityType activeType in activeTypeForThisAppVerison) {
        if (type == activeType) {
          types.add(type);
          break;
        }
      }
    }
    return types;
  }

  Future<bool> addFavourite(MetaEntity newMe) async {
    for (MetaEntity me in _currentUser.favourites) {
      if (me.entityId == newMe.entityId) {
        return true;
      }
    }

    //add first and then make the server call, this is to improve the responsiveness
    _currentUser.favourites.add(newMe);

    bool isSuccess = await _entityService.addEntityToUserFavourite(newMe);

    if (isSuccess) {
      return true;
    } else {
      _currentUser.favourites
          .removeWhere((element) => element.entityId == newMe.entityId);
      return false;
    }
  }

  Future<bool> removeFavourite(MetaEntity me) async {
    bool isRemoved = false;
    for (MetaEntity meta in _currentUser.favourites) {
      if (meta.entityId == me.entityId) {
        _currentUser.favourites
            .removeWhere((element) => element.entityId == me.entityId);

        isRemoved =
            await _entityService.removeEntityFromUserFavourite(me.entityId);

        if (isRemoved) {
          return true;
        } else {
          //as it could not be removed on server, add it back
          _currentUser.favourites.add(me);
          return false;
        }
      }
    }

    return true;
  }

  Future<bool> updateMetaEntity(MetaEntity metaEntity) async {
    for (int i = 0; i < _currentUser.entities.length; i++) {
      if (_currentUser.entities[i].entityId == metaEntity.entityId) {
        _currentUser.entities[i] = metaEntity;
      }
    }
    return true;
  }

  Future<bool> updateSearchResults(List<Entity> list) async {
    _gs.lastSearchResults = list;
    return true;
  }

  //Throws => MaxTokenReachedByUserPerSlotException, TokenAlreadyExistsException, SlotFullException, MaxTokenReachedByUserPerDayException
  Future<Triplet<UserTokens, TokenCounter, EntitySlots>> addBooking(
      MetaEntity meta, Slot slot, bool enableVideoChat) async {
    UserTokens tokens;
    Triplet<UserTokens, TokenCounter, EntitySlots> triplet;
    triplet =
        await _tokenService.generateToken(meta, slot.dateTime, enableVideoChat);

    tokens = triplet.item1;

    UserToken newToken;
    bool matched;
    if (tokens != null) {
      for (UserToken tok in tokens.tokens) {
        matched = false;
        for (Tuple<UserToken, DocumentSnapshot> ut in bookings) {
          if (ut.item1.getID() == tok.getID()) {
            matched = true;
            break;
          }
        }

        if (!matched) {
          newToken = tok;
          break;
        }
      }
      if (newToken != null) {
        bookings.add(
            Tuple<UserToken, DocumentSnapshot>(item1: newToken, item2: null));
      }
    }
    return triplet;
  }

  static clearGlobalState() {
    if (_gs != null) {
      // ignore: unnecessary_statements
      _gs._entityState != null ? _gs._entityState.clear() : null;
      // ignore: unnecessary_statements
      _gs._entities != null ? _gs._entities.clear() : null;
      // ignore: unnecessary_statements
      _gs.lastSearchResults != null ? _gs.lastSearchResults.clear() : null;
      // ignore: unnecessary_statements
      _gs.bookings != null ? _gs.bookings.clear() : null;
      _gs.bookings = null;

      _gs._tokenService = null;
      _gs._userService = null;
      _gs._entityService = null;
      _gs._currentUser = null;
      _gs._applicationService = null;
      _gs._authService = null;
      _gs._conf = null;
      _gs.lastSearchName = "";
      _gs.lastSearchType = null;
      _gs._secondaryFirebaseApp = null;
    }

    _gs = null;
  }

  //Throws => TokenAlreadyCancelledException, NoTokenFoundException
  Future<bool> cancelBooking(String tokenId, [int number]) async {
    Triplet<UserToken, TokenCounter, EntitySlots> tuple;
    if (_gs == null || _tokenService == null) return false;

    tuple = await _tokenService.cancelToken(tokenId, number);
    UserToken ut = tuple.item1;
    UserTokens uts = ut.parent;
    if (uts != null) {
      //update the bookings in the collection
      int index = -1;
      UserToken cancelledToken;
      bool didMatch = false;
      for (Tuple<UserToken, DocumentSnapshot> existingTok in bookings) {
        index++;
        if (existingTok.item1.parent.getTokenId() == uts.getTokenId()) {
          if (number == null) {
            didMatch = true;
            cancelledToken = uts.tokens[0];
            break;
          } else {
            //supplied number should not exist in the returned UserTokens object as that would have changed to -1 and original number should match
            for (UserToken ut in uts.tokens) {
              if (number == ut.numberBeforeCancellation &&
                  number == existingTok.item1.number) {
                didMatch = true;
                cancelledToken = ut;
                break;
              }
            }
            if (didMatch) {
              break;
            }
          }
        }
      }

      if (didMatch) {
        bookings[index] = new Tuple<UserToken, DocumentSnapshot>(
            item1: cancelledToken, item2: null);
      }
      return true;
    } else {
      return false;
    }
  }

  static Future<void> saveGlobalState() async {
    // writeData(_gs.toJson());
  }

  List<dynamic> convertPastSearchesListToJson(List<Entity> metaEntities) {
    List<dynamic> searchListJson = [];
    if (metaEntities == null) return searchListJson;
    for (Entity meta in metaEntities) {
      searchListJson.add(meta.toJson());
    }
    return searchListJson;
  }

  static List<Entity> convertToSearchListFromJson(
      List<dynamic> metaEntityJson) {
    List<Entity> metaEntities = [];

    if (metaEntityJson != null) {
      for (Map<String, dynamic> json in metaEntityJson) {
        Entity metaEnt = Entity.fromJson(json);
        metaEntities.add(metaEnt);
      }
    }
    return metaEntities;
  }

  bool _isNotificationInitialized = false;
  FlutterLocalNotificationsPlugin localNotification;

  bool isNotificationInitialized() {
    return _isNotificationInitialized;
  }

  void initializeNotification() {
    try {
      if (!_isNotificationInitialized) {
        //_configureLocalTimeZone();

        localNotification = new FlutterLocalNotificationsPlugin();
        var androidInitialize = new AndroidInitializationSettings(
            "@drawable/ic_stat_name"); //this is not working hence trying below way of setting the icon
        //https://nitishk72.medium.com/flutter-local-notification-1e43a353877b
        //https://pub.dev/packages/flutter_local_notifications#custom-notification-icons-and-sounds
        // var androidInitialize =
        //     new AndroidInitializationSettings("@mipmap/ic_launcher");
        var iOSInitialize = new IOSInitializationSettings();
        var initializationSettings = new InitializationSettings(
            android: androidInitialize, iOS: iOSInitialize);

        localNotification.initialize(initializationSettings,
            onSelectNotification: onSelectNotification);

        registerForLocalNotificationCreatedEvent();
        registerForLocalNotificationCancelledEvent();
        _isNotificationInitialized = true;
      }
    } catch (e) {
      print("Notification init failed: " + e.toString());
    }
  }

  Future onSelectNotification(String payload) async {
    print(" onSelectNotification clicked");
  }

  void registerForLocalNotificationCancelledEvent() {
    EventBus.registerEvent(LOCAL_NOTIFICATION_REMOVED_EVENT, null,
        (event, arg) {
      if (event == null) {
        return;
      }

      LocalNotificationData data = event.eventData;
      if (data != null && data.id != null) {
        localNotification.cancel(data.id);
      }
    });
  }

  void registerForLocalNotificationCreatedEvent() {
    EventBus.registerEvent(LOCAL_NOTIFICATION_CREATED_EVENT, null,
        (event, arg) {
      var androidDetails = new AndroidNotificationDetails(
          "channelId", "channelName", "channelDescription",
          importance: Importance.max, priority: Priority.high);

      var iOSDetails = new IOSNotificationDetails();

      var generalNotificationDetails =
          new NotificationDetails(android: androidDetails, iOS: iOSDetails);

      if (event == null) {
        return;
      }

      LocalNotificationData data = event.eventData;

      var tzDateTime = tz.TZDateTime.from(data.dateTime, tz.local);

      localNotification.zonedSchedule(data.id, data.title, data.message,
          tzDateTime, generalNotificationDetails,
          uiLocalNotificationDateInterpretation:
              UILocalNotificationDateInterpretation.wallClockTime,
          androidAllowWhileIdle: true);
    });
  }
}
