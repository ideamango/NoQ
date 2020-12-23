import 'dart:async';
import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import 'package:noq/db/db_model/configurations.dart';
import 'package:noq/db/db_model/entity.dart';
import 'package:noq/db/db_model/meta_entity.dart';
import 'package:noq/db/db_model/app_user.dart';
import 'package:noq/db/db_model/slot.dart';
import 'package:noq/db/db_model/user_token.dart';

import 'package:noq/db/db_service/configurations_service.dart';
import 'package:noq/db/db_service/entity_service.dart';
import 'package:noq/db/db_service/token_service.dart';
import 'package:noq/events/local_notification_data.dart';
import 'package:noq/services/auth_service.dart';
import 'package:noq/tuple.dart';

import 'package:noq/utils.dart';
import 'db/db_service/user_service.dart';
import 'events/event_bus.dart';
import 'events/events.dart';
import 'package:timezone/timezone.dart' as tz;

class GlobalState {
  AppUser _currentUser;
  Configurations conf;
  List<UserToken> bookings;
  String lastSearchName;
  String lastSearchType;
  List<Entity> lastSearchResults;
  Map<String, Entity> _entities;
  FirebaseApp _secondaryFirebaseApp;

  //true is entity is saved on server and false if it is a new entity
  Map<String, bool> _entityState;
  EntityService _entityService;
  UserService _userService;
  TokenService _tokenService;
  AuthService _authService;
  String _country;
  static Future<Null> isWorking;

  static GlobalState _gs;

  GlobalState._();

  Future<void> initSecondaryFirebaseApp() async {
    String appId;
    String apiKey;
    String messagingSenderId;
    String projectId;

    for (FirebaseApp app in Firebase.apps) {
      if (app.name == "SecondaryFirebaseApp") {
        return;
      }
    }

    if (_country == "India") {
      appId = Platform.isAndroid
          ? "1:643643889883:android:2c47f2ee29f66b35c594fe"
          : "1:643643889883:ios:1e17e4f8114d5fd0c594fe";

      apiKey = "AIzaSyDYo0KL7mzN9-0ghFsO4ydCLQYFXoWvujg";
      messagingSenderId = "643643889883";
      projectId = "sukoon-india";

      await Firebase.initializeApp(
          name: 'SecondaryFirebaseApp',
          options: FirebaseOptions(
              appId: appId,
              apiKey: apiKey,
              messagingSenderId: messagingSenderId,
              projectId: projectId));
    } else if (_country == "Test") {
      appId = Platform.isAndroid
          ? "1:166667469482:android:f488ccf8299e9542e9c6d3"
          : "1:166667469482:ios:bcaebbe8fae4c8c2e9c6d3";

      apiKey = "AIzaSyBvRdM2jfG54VzciJ3sfef4xq_TalMmOAM";
      messagingSenderId = "166667469482";
      projectId = "awesomenoq";

      await Firebase.initializeApp(
          name: 'SecondaryFirebaseApp',
          options: FirebaseOptions(
              appId: appId,
              apiKey: apiKey,
              messagingSenderId: messagingSenderId,
              projectId: projectId));
    } else if (_country == "US" || !Utils.isNotNullOrEmpty(_country)) {
      // appId = Platform.isAndroid
      //     ? "1:964237045237:android:dac9374ed36f850a5784bc"
      //     : "1:964237045237:ios:458f3c6fc630f29c5784bc";

      // apiKey = "AIzaSyCZlz1Cdyi2wjOvhuIFJmWTnc4m8eUuW34";
      // messagingSenderId = "964237045237";
      // projectId = "lesssusdefault";

      // await Firebase.initializeApp(
      //     name: 'SecondaryFirebaseApp',
      //     options: FirebaseOptions(
      //         appId: appId,
      //         apiKey: apiKey,
      //         messagingSenderId: messagingSenderId,
      //         projectId: projectId));
      _gs._secondaryFirebaseApp = Firebase.apps[0];
    }

    if (_gs._secondaryFirebaseApp == null) {
      _gs._secondaryFirebaseApp = Firebase.app('SecondaryFirebaseApp');
    }
  }

  static Future<GlobalState> getGlobalState() async {
    //automatically detect country
    String country = "India";
    return await GlobalState.getGlobalStateForCountry(country);
  }

  static Future<GlobalState> getGlobalStateForCountry(String country) async {
    if (isWorking != null) {
      await isWorking; // wait for future complete
      return getGlobalStateForCountry(country);
    }

    //lock
    var completer = new Completer<Null>();
    isWorking = completer.future;

    if (_gs == null) {
      _gs = new GlobalState._();
    }

    _gs.setCountry(country);

    if (_gs._secondaryFirebaseApp == null) {
      await _gs.initSecondaryFirebaseApp();
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

    if (_gs._tokenService == null) {
      _gs._tokenService = new TokenService(_gs._secondaryFirebaseApp);
    }

    if (_gs.conf == null) {
      try {
        _gs.conf = await ConfigurationService(_gs._secondaryFirebaseApp)
            .getConfigurations();
      } catch (e) {
        print(
            "Error initializing GlobalState, Configuration could not be fetched from server..");
      }
    }

    if (_gs._entities == null) {
      _gs._entities = new Map<String, Entity>();
      _gs._entityState = new Map<String, bool>();
    }

    if (_gs._currentUser == null) {
      try {
        _gs._currentUser = await _gs._userService.getCurrentUser();
        if (_gs._currentUser != null &&
            Utils.isNullOrEmpty(_gs._currentUser.favourites))
          _gs._currentUser.favourites = new List<MetaEntity>();
      } catch (e) {
        print(
            "Error initializing GlobalState, User details could not be fetched from server..");
      }
    }

    if (_gs.bookings == null) {
      DateTime fromDate = DateTime.now().subtract(new Duration(days: 60));
      DateTime toDate = DateTime.now().add(new Duration(days: 30));

      _gs.bookings =
          await _gs._tokenService.getAllTokensForCurrentUser(fromDate, toDate);
    }

    //unlock
    completer.complete();
    isWorking = null;

    return _gs;
  }

  void setCountry(String country) {
    _country = country;
  }

  UserService getUserService() {
    return _gs._userService;
  }

  EntityService getEntityService() {
    return _gs._entityService;
  }

  TokenService getTokenService() {
    return _gs._tokenService;
  }

  AppUser getCurrentUser() {
    return _currentUser;
  }

  AuthService getAuthService() {
    return _authService;
  }

  static Future<String> getCountry() async {
    return "IN";
  }

  Future<Tuple<Entity, bool>> getEntity(String id,
      [bool fetchFromServer = true]) async {
    if (_entities.containsKey(id)) {
      return new Tuple(item1: _entities[id], item2: _entityState[id]);
    } else {
      //load from server
      if (fetchFromServer) {
        Entity ent = await _entityService.getEntity(id);
        if (ent == null) {
          return null;
        }

        _entities[id] = ent;
        _entityState[id] = true;

        return new Tuple(item1: ent, item2: true);
      } else {
        return null;
      }
    }
  }

  Future<bool> removeEntity(String id) async {
    bool isDeleted = await _entityService.deleteEntity(id);

    if (isDeleted) {
      _currentUser.entities.removeWhere((element) => element.entityId == id);
      _entities.remove(id);
      _entityState.remove(id);
    }
    return isDeleted;
  }

  Future<bool> putEntity(Entity entity, bool saveOnServer,
      [String parentId]) async {
    _entities[entity.entityId] = entity;

    bool existsInUser = false;
    if (Utils.isNullOrEmpty(_currentUser.entities)) {
      _currentUser.entities = new List<MetaEntity>();
    }
    for (MetaEntity mEnt in _currentUser.entities) {
      if (mEnt.entityId == entity.entityId) {
        existsInUser = true;
      }
    }

    if (!existsInUser) {
      _currentUser.entities.add(entity.getMetaEntity());
    }

    bool saved = false;
    if (saveOnServer) {
      if (Utils.isNotNullOrEmpty(parentId)) {
        saved =
            await _entityService.upsertChildEntityToParent(entity, parentId);
      } else {
        saved = await _entityService.upsertEntity(entity);
      }

      _entityState[entity.entityId] = saved;
    }
    return saved;
  }

  void setPastSearch(List<Entity> entityList, String name, String type) {
    _gs.lastSearchResults = entityList;
    _gs.lastSearchName = name;
    _gs.lastSearchType = type;
    return;
  }

  List<UserToken> getPastBookings() {
    List<UserToken> pastBookings = new List<UserToken>();
    DateTime now = DateTime.now();
    for (UserToken bk in bookings) {
      if (bk.dateTime.isBefore(now)) pastBookings.add(bk);
    }

    pastBookings.sort((a, b) =>
        (a.dateTime.millisecondsSinceEpoch > b.dateTime.millisecondsSinceEpoch)
            ? -1
            : 1);
    return pastBookings;
  }

  List<UserToken> getUpcomingBookings() {
    List<UserToken> newBookings = new List<UserToken>();
    DateTime now = DateTime.now();
    for (UserToken bk in bookings) {
      if (!bk.dateTime.isBefore(now)) newBookings.add(bk);
    }
    newBookings.sort((a, b) =>
        (a.dateTime.millisecondsSinceEpoch > b.dateTime.millisecondsSinceEpoch)
            ? 1
            : -1);
    return newBookings;
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

  Future<UserToken> addBooking(MetaEntity meta, Slot slot) async {
    UserToken token;
    token = await _tokenService.generateToken(meta, slot.dateTime);
    if (token != null) {
      bookings.add(token);
    }
    return token;
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

      _gs._tokenService = null;
      _gs._userService = null;
      _gs._entityService = null;
      _gs._currentUser = null;
      _gs.conf = null;
      _gs.lastSearchName = "";
      _gs.lastSearchType = "";
      _gs._secondaryFirebaseApp = null;
    }

    _gs = null;
  }

  Future<bool> cancelBooking(String tokenId) async {
    return await _tokenService.cancelToken(tokenId);
  }

  static Future<void> saveGlobalState() async {
    // writeData(_gs.toJson());
  }

  Map<String, dynamic> toJson() => {
        'currentUser': _currentUser.toJson(),
        'conf': conf.toJson(),
        'bookings': convertBookingsListToJson(this.bookings),
        'pastSearches': convertPastSearchesListToJson(this.lastSearchResults)
      };

  List<dynamic> convertBookingsListToJson(List<UserToken> tokens) {
    List<dynamic> bookingListJson = new List<dynamic>();
    if (tokens == null) return bookingListJson;
    for (UserToken token in tokens) {
      bookingListJson.add(token.toJson());
    }
    return bookingListJson;
  }

  List<dynamic> convertPastSearchesListToJson(List<Entity> metaEntities) {
    List<dynamic> searchListJson = new List<dynamic>();
    if (metaEntities == null) return searchListJson;
    for (Entity meta in metaEntities) {
      searchListJson.add(meta.toJson());
    }
    return searchListJson;
  }

  static List<Entity> convertToSearchListFromJson(
      List<dynamic> metaEntityJson) {
    List<Entity> metaEntities = new List<Entity>();

    if (metaEntityJson != null) {
      for (Map<String, dynamic> json in metaEntityJson) {
        Entity metaEnt = Entity.fromJson(json);
        metaEntities.add(metaEnt);
      }
    }
    return metaEntities;
  }

  static List<UserToken> convertToBookingsFromJson(List<dynamic> bookingsJson) {
    List<UserToken> bookings = new List<UserToken>();
    if (bookingsJson != null) {
      for (Map<String, dynamic> json in bookingsJson) {
        UserToken token = UserToken.fromJson(json);
        bookings.add(token);
      }
    }
    return bookings;
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
        var androidInitialize = new AndroidInitializationSettings("icon");
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
