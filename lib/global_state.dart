import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:noq/db/db_model/configurations.dart';
import 'package:noq/db/db_model/entity.dart';
import 'package:noq/db/db_model/meta_entity.dart';
import 'package:noq/db/db_model/app_user.dart';
import 'package:noq/db/db_model/user_token.dart';
import 'package:noq/db/db_service/configurations_service.dart';
import 'package:noq/db/db_service/token_service.dart';
import 'package:noq/events/local_notification_data.dart';
import 'package:noq/repository/local_db_repository.dart';
import 'package:noq/utils.dart';
import 'db/db_service/user_service.dart';
import 'events/event_bus.dart';
import 'events/events.dart';
import 'package:timezone/timezone.dart' as tz;

class GlobalState {
  AppUser currentUser;
  Configurations conf;
  List<UserToken> bookings;
  List<Entity> pastSearches;

  static GlobalState _gs;

  GlobalState._();

  GlobalState.withValues(
      {this.currentUser, this.conf, this.bookings, this.pastSearches});

  static Future<GlobalState> getGlobalState() async {
    if (_gs == null) {
      _gs = new GlobalState._();
    }
    if (_gs.currentUser == null) {
      try {
        _gs.currentUser = await UserService().getCurrentUser();
        if (Utils.isNullOrEmpty(_gs.currentUser.favourites))
          _gs.currentUser.favourites = new List<MetaEntity>();
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
          await TokenService().getAllTokensForCurrentUser(fromDate, toDate);
    }

    return _gs;
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

  Future<bool> addFavourite(MetaEntity me) async {
    _gs.currentUser.favourites.add(me);
    // saveGlobalState();
    return true;
  }

  Future<bool> removeFavourite(MetaEntity me) async {
    _gs.currentUser.favourites
        .removeWhere((element) => element.entityId == me.entityId);
    //  saveGlobalState();
    return true;
  }

  Future<bool> addEntity(MetaEntity me) async {
    _gs.currentUser.entities.add(me);
    // saveGlobalState();
    return true;
  }

  Future<bool> removeEntity(String entityId) async {
    _gs.currentUser.entities
        .removeWhere((element) => element.entityId == entityId);
    //  saveGlobalState();
    return true;
  }

  Future<bool> updateMetaEntity(MetaEntity metaEntity) async {
    for (int i = 0; i < _gs.currentUser.entities.length; i++) {
      if (_gs.currentUser.entities[i].entityId == metaEntity.entityId) {
        _gs.currentUser.entities[i] = metaEntity;
      }
    }
    return true;
  }

  Future<bool> updateSearchResults(List<Entity> list) async {
    _gs.pastSearches = list;
    return true;
  }

  Future<bool> addBooking(UserToken token) async {
    _gs.bookings.add(token);
    //  saveGlobalState();
    return true;
  }

  static resetGlobalState() {
    _gs = null;
  }

  cancelBooking() async {}

  static Future<void> saveGlobalState() async {
    // writeData(_gs.toJson());
  }

  Map<String, dynamic> toJson() => {
        'currentUser': currentUser.toJson(),
        'conf': conf.toJson(),
        'bookings': convertBookingsListToJson(this.bookings),
        'pastSearches': convertPastSearchesListToJson(this.pastSearches)
      };

  static Future<GlobalState> fromJson(Map<String, dynamic> json) async {
    if (json == null) return null;

    return new GlobalState.withValues(
      currentUser: AppUser.fromJson(json['currentUser']),
      conf: Configurations.fromJson(json['conf']),
      bookings: convertToBookingsFromJson(json['bookings']),
      pastSearches: convertToSearchListFromJson(json['pastSearches']),
    );
  }

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
