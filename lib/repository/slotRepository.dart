//Post selected Slot to server
//Cancel Slot
//List Slots for particular store

import '../db/db_model/entity_slots.dart';
import '../db/db_model/meta_entity.dart';
import '../db/db_model/slot.dart';
import '../db/db_model/user_token.dart';
import '../events/event_bus.dart';
import '../events/events.dart';
import '../events/local_notification_data.dart';
import '../global_state.dart';

import '../utils.dart';

Future<List<Slot>> getSlotsListForEntity(
    MetaEntity entity, DateTime dateTime) async {
  EntitySlots entitySlots;

  GlobalState gs = await GlobalState.getGlobalState();
  entitySlots =
      await gs.getTokenService().getEntitySlots(entity.entityId, dateTime);

  return Utils.getSlots(entitySlots, entity, dateTime);
}

Future<UserToken> bookSlotForStore(MetaEntity meta, Slot slot) async {
//TODO: Have Entity object here, either pass entity object to generateToken() or create metaEntity and pass to this method.

  GlobalState gs = await GlobalState.getGlobalState();
  UserTokens tokens = await gs.addBooking(meta, slot);

  DateTime dt1Hour = tokens.dateTime.subtract(new Duration(hours: 1));
  DateTime dt15Minutes = tokens.dateTime.subtract(new Duration(minutes: 15));

  String notificationMessage = "Your token ";
  if (tokens.tokens.length > 1) {
    notificationMessage = notificationMessage + "numbers are ";
  } else {
    notificationMessage = notificationMessage + "number is ";
  }

  for (int count = 1; count <= tokens.tokens.length; count++) {
    if (count == tokens.tokens.length) {
      notificationMessage =
          notificationMessage + tokens.tokens[count - 1].getDisplayName();
    } else {
      notificationMessage = notificationMessage +
          tokens.tokens[count - 1].getDisplayName() +
          ", ";
    }
  }

  if (dt1Hour.millisecondsSinceEpoch > DateTime.now().millisecondsSinceEpoch) {
    LocalNotificationData dataForAnHour = new LocalNotificationData(
        id: tokens.rNum - 60,
        dateTime: dt1Hour,
        title: "Appointment in 1 Hour at " + tokens.entityName,
        message: notificationMessage +
            ". Please be on-time and maintain Safe Distance.");

    EventBus.fireEvent(LOCAL_NOTIFICATION_CREATED_EVENT, null, dataForAnHour);
  }

  if (dt15Minutes.millisecondsSinceEpoch >
      DateTime.now().millisecondsSinceEpoch) {
    LocalNotificationData dataFor15Minutes = new LocalNotificationData(
        id: tokens.rNum - 15,
        dateTime: dt15Minutes,
        title: "Appointment in 15 Minutes at " + tokens.entityName,
        message: notificationMessage +
            ". Follow Social Distancing norms and Stay Safe!!");

    EventBus.fireEvent(
        LOCAL_NOTIFICATION_CREATED_EVENT, null, dataFor15Minutes);
  }

  return tokens.tokens.last;
}

Future<bool> cancelToken(UserToken token) async {
  GlobalState gs = await GlobalState.getGlobalState();

  bool returnVal =
      await gs.cancelBooking(token.parent.getTokenId(), token.number);

  DateTime dt1Hour = token.parent.dateTime.subtract(new Duration(hours: 1));

  if (dt1Hour.millisecondsSinceEpoch > DateTime.now().millisecondsSinceEpoch) {
    LocalNotificationData dataForAnHour =
        new LocalNotificationData(id: token.parent.rNum - 60);
    EventBus.fireEvent(LOCAL_NOTIFICATION_REMOVED_EVENT, null, dataForAnHour);
  }

  DateTime dt15Minutes =
      token.parent.dateTime.subtract(new Duration(minutes: 15));
  if (dt15Minutes.millisecondsSinceEpoch >
      DateTime.now().millisecondsSinceEpoch) {
    LocalNotificationData dataFor15Minutes =
        new LocalNotificationData(id: token.parent.rNum - 15);

    EventBus.fireEvent(
        LOCAL_NOTIFICATION_REMOVED_EVENT, null, dataFor15Minutes);
  }

  return returnVal;
}

Future<bool> updateToken(UserTokens tokens) async {
  GlobalState gs = await GlobalState.getGlobalState();

  bool result;
  try {
    result = await gs.getTokenService().updateToken(tokens);
    print('Updated token successfully');
  } catch (e) {
    print(e.toString());
  }
  return result;
}
