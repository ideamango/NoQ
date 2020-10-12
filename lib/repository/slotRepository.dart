//Post selected Slot to server
//Cancel Slot
//List Slots for particular store

import 'package:noq/db/db_model/entity.dart';
import 'package:noq/db/db_model/entity_slots.dart';
import 'package:noq/db/db_model/meta_entity.dart';
import 'package:noq/db/db_model/slot.dart';
import 'package:noq/db/db_model/user_token.dart';
import 'package:noq/db/db_service/entity_service.dart';
import 'package:noq/db/db_service/slot_full_exception.dart';
import 'package:noq/db/db_service/token_service.dart';
import 'package:noq/events/event_bus.dart';
import 'package:noq/events/events.dart';
import 'package:noq/events/local_notification_data.dart';

Future<List<Slot>> getSlotsListForStore(
    Entity entity, DateTime dateTime) async {
  EntitySlots entitySlots;
  List<Slot> slotList = new List<Slot>();
  DateTime breakStartTime;
  DateTime breakEndTime;
  DateTime dayStartTime;
  DateTime dayEndTime;
  entitySlots = await TokenService().getEntitySlots(entity.entityId, dateTime);
  dayStartTime = new DateTime(dateTime.year, dateTime.month, dateTime.day,
      entity.startTimeHour, entity.startTimeMinute);
  dayEndTime = new DateTime(dateTime.year, dateTime.month, dateTime.day,
      entity.endTimeHour, entity.endTimeMinute);

  if (entity.breakEndHour == null || entity.breakStartHour == null) {
    breakStartTime = dayStartTime;
    breakEndTime = dayStartTime;
  } else {
    breakStartTime = new DateTime(dateTime.year, dateTime.month, dateTime.day,
        entity.breakStartHour, entity.breakEndMinute);
    breakEndTime = new DateTime(dateTime.year, dateTime.month, dateTime.day,
        entity.breakEndHour, entity.breakEndMinute);
  }

  int firstHalfDuration = breakStartTime.difference(dayStartTime).inMinutes;

  int secondHalfDuration = dayEndTime.difference(breakEndTime).inMinutes;

  int numberOfSlotsInFirstHalf = firstHalfDuration ~/ entity.slotDuration;

  int numberOfSlotsInSecondHalf = secondHalfDuration ~/ entity.slotDuration;

  //no slots are booked for this entity yet on this date
  for (int count = 0; count < numberOfSlotsInFirstHalf; count++) {
    int minutesToAdd = count * entity.slotDuration;
    DateTime dt = dayStartTime.add(new Duration(minutes: minutesToAdd));
    Slot sl = checkIfSlotExists(entitySlots, dt);
    if (sl == null) {
      sl = new Slot(
          slotId: "",
          currentNumber: 0,
          maxAllowed: entity.maxAllowed,
          dateTime: dt,
          slotDuration: entity.slotDuration,
          isFull: false);
    }

    slotList.add(sl);
  }

  for (int count = 0; count < numberOfSlotsInSecondHalf; count++) {
    int minutesToAdd = count * entity.slotDuration;
    DateTime dt = breakEndTime.add(new Duration(minutes: minutesToAdd));
    Slot sl = checkIfSlotExists(entitySlots, dt);
    if (sl == null) {
      sl = new Slot(
          slotId: "",
          currentNumber: 0,
          maxAllowed: entity.maxAllowed,
          dateTime: dt,
          slotDuration: entity.slotDuration,
          isFull: false);
    }

    slotList.add(sl);
  }
  return slotList;
}

Slot checkIfSlotExists(EntitySlots entitySlots, DateTime dt) {
  if (entitySlots == null) {
    return null;
  }

  for (Slot sl in entitySlots.slots) {
    if (sl.dateTime.compareTo(dt) == 0) {
      return sl;
    }
  }
  return null;
}

Future<UserToken> bookSlotForStore(MetaEntity meta, Slot slot) async {
//TODO: Have Entity object here, either pass entity object to generateToken() or create metaEntity and pass to this method.
  UserToken token;
  try {
    token = await TokenService().generateToken(meta, slot.dateTime);
    print("Token Booked: $token");
  } catch (e) {
    throw e;
  }

  LocalNotificationData dataForAnHour = new LocalNotificationData(
      dateTime:
          token.dateTime.add(new Duration(hours: 1)), //this should be 1 hour
      // dateTime: DateTime.now().add(new Duration(seconds: 10)),
      title: "Appointment in an hour at " + token.entityName,
      message: "This is a reminder for your token number " +
          token.getDisplayName() +
          " at " +
          token.entityName +
          ". Please be on time and maintain safe distance.");
  EventBus.fireEvent(LOCAL_NOTIFICATION_CREATED_EVENT, null, dataForAnHour);

  LocalNotificationData dataFor15Minutes = new LocalNotificationData(
      dateTime:
          token.dateTime.add(new Duration(minutes: 15)), //this should be 1 hour
      // dateTime: DateTime.now().add(new Duration(seconds: 10)),
      title: "Appointment in 15 minutes at " + token.entityName,
      message: "Gentle reminder for your token number " +
          token.getDisplayName() +
          " at " +
          token.entityName +
          ". Please be on time and follow social distancing norms.");
  EventBus.fireEvent(LOCAL_NOTIFICATION_CREATED_EVENT, null, dataFor15Minutes);

  return token;
}

Future<bool> cancelToken(String tokenId) async {
  bool returnVal = await TokenService().cancelToken(tokenId);
  //TODO: Unregister LocalNotification event
  return returnVal;
}

Future<bool> updateToken(UserToken token) async {
  bool result;
  try {
    result = await TokenService().updateToken(token);
    print('Updated token successfully');
  } catch (e) {
    print(e.toString());
  }
  return result;
}
