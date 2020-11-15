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
  List<Entity> pastSearches;
  Map<String, Entity> _entities;
  Map<String, bool> _entityState;
  EntityService _entityService;
  UserService _userService;
  TokenService _tokenService;

  static GlobalState _gs;

  GlobalState._();

  // GlobalState.withValues(
  //     {this._currentUser, this.conf, this.bookings, this.pastSearches});

  static Future<GlobalState> getGlobalState() async {
    if (_gs == null) {
      _gs = new GlobalState._();
    }

    if (_gs._entityService == null) {
      _gs._entityService = new EntityService();
    }

    if (_gs._userService == null) {
      _gs._userService = new UserService();
    }

    if (_gs._tokenService == null) {
      _gs._tokenService = new TokenService();
    }

    if (_gs._entities == null) {
      _gs._entities = new Map<String, Entity>();
      _gs._entityState = new Map<String, bool>();
    }

    if (_gs._currentUser == null) {
      try {
        _gs._currentUser = await _gs._userService.getCurrentUser();
        if (Utils.isNullOrEmpty(_gs._currentUser.favourites))
          _gs._currentUser.favourites = new List<MetaEntity>();
      } catch (e) {
        print(
            "Error initializing GlobalState, User details could not be fetched from server..");
      }
    }

    if (_gs.conf == null) {
      try {
        _gs.conf = await ConfigurationService().getConfigurations();
      } catch (e) {
        print(
            "Error initializing GlobalState, Configuration could not be fetched from server..");
      }
    }
    if (_gs.bookings == null) {
      DateTime fromDate = DateTime.now().subtract(new Duration(days: 60));
      DateTime toDate = DateTime.now().add(new Duration(days: 30));

      _gs.bookings =
          await _gs._tokenService.getAllTokensForCurrentUser(fromDate, toDate);
    }

    return _gs;
  }

  AppUser getCurrentUser() {
    return _currentUser;
  }

  Future<Tuple<Entity, bool>> getEntity(String id) async {
    if (_entities.containsKey(id)) {
      return new Tuple(item1: _entities[id], item2: _entityState[id]);
    } else {
      //load from server
      Entity ent = await _entityService.getEntity(id);
      if (ent == null) {
        return null;
      }

      _entities[id] = ent;
      _entityState[id] = true;

      return new Tuple(item1: ent, item2: true);
    }
  }

  Future<bool> deleteEntity(String id) async {
    bool isDeleted = await _entityService.deleteEntity(id);
    if (isDeleted) {
      _entities.remove(id);
      _entityState.remove(id);
      return true;
    }
    return false;
  }

  Future<bool> putEntity(Entity entity, bool saveOnServer) async {
    _entities[entity.entityId] = entity;
    if (saveOnServer) {
      if (await _entityService.upsertEntity(entity)) {
        _entityState[entity.entityId] = true;
        return true;
      } else {
        _entityState[entity.entityId] = false;
      }
    } else {
      _entityState[entity.entityId] = false;
    }
    return false;
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

    bool isSuccess = await _entityService.addEntityToUserFavourite(newMe);

    if (isSuccess) {
      _currentUser.favourites.add(newMe);

      return true;
    }
    return false;
  }

  Future<bool> removeFavourite(MetaEntity me) async {
    bool isRemoved = false;
    for (MetaEntity meta in _currentUser.favourites) {
      if (meta.entityId == me.entityId) {
        isRemoved =
            await _entityService.removeEntityFromUserFavourite(me.entityId);

        if (isRemoved) {
          _currentUser.favourites
              .removeWhere((element) => element.entityId == me.entityId);
          return true;
        } else {
          return false;
        }
      }
    }

    return true;
  }

  Future<Entity> createEntity(String entityId, String entityType,
      [String parentId]) async {
    Entity entity = new Entity(
        entityId: entityId,
        name: null,
        address: null,
        advanceDays: null,
        isPublic: false,
        //geo: geoPoint,
        maxAllowed: null,
        slotDuration: null,
        closedOn: [],
        breakStartHour: null,
        breakStartMinute: null,
        breakEndHour: null,
        breakEndMinute: null,
        startTimeHour: null,
        startTimeMinute: null,
        endTimeHour: null,
        endTimeMinute: null,
        parentId: parentId,
        type: entityType,
        isBookable: false,
        isActive: false,
        coordinates: null);

    await putEntity(entity, false);

    return entity;
  }

  Future<bool> addEntityToCurrentUser(Entity entity, bool saveOnServer) async {
    for (MetaEntity mEnt in _currentUser.entities) {
      if (mEnt.entityId == entity.entityId) {
        return true;
      }
    }

    _currentUser.entities.add(entity.getMetaEntity());
    await putEntity(entity, saveOnServer);

    return true;
  }

  Future<bool> removeEntity(String entityId) async {
    _currentUser.entities
        .removeWhere((element) => element.entityId == entityId);

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
    _gs.pastSearches = list;
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

  static resetGlobalState() {
    _gs = null;
  }

  Future<bool> cancelBooking(String tokenId) async {
    return await TokenService().cancelToken(tokenId);
  }

  static Future<void> saveGlobalState() async {
    // writeData(_gs.toJson());
  }

  Map<String, dynamic> toJson() => {
        'currentUser': _currentUser.toJson(),
        'conf': conf.toJson(),
        'bookings': convertBookingsListToJson(this.bookings),
        'pastSearches': convertPastSearchesListToJson(this.pastSearches)
      };

  // static Future<GlobalState> fromJson(Map<String, dynamic> json) async {
  //   if (json == null) return null;

  //   return new GlobalState.withValues(
  //     _currentUser: AppUser.fromJson(json['currentUser']),
  //     conf: Configurations.fromJson(json['conf']),
  //     bookings: convertToBookingsFromJson(json['bookings']),
  //     pastSearches: convertToSearchListFromJson(json['pastSearches']),
  //   );
  // }

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
