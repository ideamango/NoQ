import 'package:LESSs/db/db_model/user_token.dart';
import 'package:LESSs/events/event_bus.dart';
import 'package:LESSs/events/events.dart';
import 'package:LESSs/events/local_notification_data.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import '../db_model/app_user.dart';

class NotificationService {
  FirebaseApp _fb;

  NotificationService(FirebaseApp firebaseApp) {
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

  void registerTokenNotification(UserTokens tokens) {
    User user = getFirebaseAuth().currentUser;
    if (tokens.userId == user.phoneNumber) {
      DateTime dt1Hour = tokens.dateTime.subtract(new Duration(hours: 1));
      DateTime dt15Minutes =
          tokens.dateTime.subtract(new Duration(minutes: 15));
      DateTime dt1Minutes = tokens.dateTime.subtract(new Duration(minutes: 1));

      UserToken lastToken = tokens.tokens[tokens.tokens.length - 1];

      String notificationMessage =
          "Your token number is " + lastToken.getDisplayName();

      if (dt1Hour.millisecondsSinceEpoch >
          DateTime.now().millisecondsSinceEpoch) {
        LocalNotificationData dataForAnHour = new LocalNotificationData(
            id: tokens.rNum -
                60 +
                lastToken
                    .getNumber(), //assuming the last one in the UserToken is the latest one
            dateTime: dt1Hour,
            title: tokens.enableVideoChat
                ? "Online Appointment in 1 Hour at " + tokens.entityName
                : "Walk-in Appointment in 1 Hour at " + tokens.entityName,
            message: tokens.enableVideoChat
                ? notificationMessage +
                    ". Make sure you have working internet connection and WhatsApp on your phone."
                : notificationMessage +
                    ". Please be on-time and follow Social distancing norms.");

        EventBus.fireEvent(
            LOCAL_NOTIFICATION_CREATED_EVENT, null, dataForAnHour);
      }

      if (dt15Minutes.millisecondsSinceEpoch >
          DateTime.now().millisecondsSinceEpoch) {
        LocalNotificationData dataFor15Minutes = new LocalNotificationData(
            id: tokens.rNum - 15 + lastToken.getNumber(),
            dateTime: dt15Minutes,
            title: tokens.enableVideoChat
                ? "Online Appointment in 15 minutes at " + tokens.entityName
                : "Walk-in Appointment in 15 minutes at " + tokens.entityName,
            message: tokens.enableVideoChat
                ? notificationMessage +
                    ". Make sure you have working internet connection and WhatsApp on your phone."
                : notificationMessage +
                    ". Please be on-time and follow Social distancing norms.");

        EventBus.fireEvent(
            LOCAL_NOTIFICATION_CREATED_EVENT, null, dataFor15Minutes);
      }

      if (dt1Minutes.millisecondsSinceEpoch >
          DateTime.now().millisecondsSinceEpoch) {
        LocalNotificationData dataFor1Minutes = new LocalNotificationData(
            id: tokens.rNum - 1 + lastToken.getNumber(),
            dateTime: dt1Minutes,
            title: tokens.enableVideoChat
                ? "Online Appointment in less than a minute at " +
                    tokens.entityName
                : "Walk-in Appointment in less than a minute at " +
                    tokens.entityName,
            message: tokens.enableVideoChat
                ? notificationMessage +
                    ". Make sure you have working internet connection and WhatsApp on your phone."
                : notificationMessage +
                    ". Please be on-time and follow Social distancing norms.");

        EventBus.fireEvent(
            LOCAL_NOTIFICATION_CREATED_EVENT, null, dataFor1Minutes);
      }
    } else {
      //push the notification to the server for the delivery to the user's phone
    }
  }

  void unRegisterTokenNotification(UserToken token) {
    User user = getFirebaseAuth().currentUser;
    if (token.parent.userId == user.phoneNumber) {
      //this the current user is the one who is generating the Token, so the Notification can stay Local
      DateTime dt1Hour = token.parent.dateTime.subtract(new Duration(hours: 1));

      if (dt1Hour.millisecondsSinceEpoch >
          DateTime.now().millisecondsSinceEpoch) {
        LocalNotificationData dataForAnHour = new LocalNotificationData(
            id: token.parent.rNum - 60 + token.getNumber());
        EventBus.fireEvent(
            LOCAL_NOTIFICATION_REMOVED_EVENT, null, dataForAnHour);
      }

      DateTime dt15Minutes =
          token.parent.dateTime.subtract(new Duration(minutes: 15));
      if (dt15Minutes.millisecondsSinceEpoch >
          DateTime.now().millisecondsSinceEpoch) {
        LocalNotificationData dataFor15Minutes = new LocalNotificationData(
            id: token.parent.rNum - 15 + token.getNumber());

        EventBus.fireEvent(
            LOCAL_NOTIFICATION_REMOVED_EVENT, null, dataFor15Minutes);
      }

      DateTime dt1Minutes =
          token.parent.dateTime.subtract(new Duration(minutes: 1));
      if (dt1Minutes.millisecondsSinceEpoch >
          DateTime.now().millisecondsSinceEpoch) {
        LocalNotificationData dataFor1Minutes = new LocalNotificationData(
            id: token.parent.rNum - 1 + token.getNumber());

        EventBus.fireEvent(
            LOCAL_NOTIFICATION_REMOVED_EVENT, null, dataFor1Minutes);
      }
    } else {
      //send a push notification to the server for delivery to that userPhone
    }
  }
}
