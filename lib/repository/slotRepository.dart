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

Future<List<Slot>> getSlotsListForStore(
    Entity entity, DateTime dateTime) async {
  EntitySlots entitySlots;
  List<Slot> slotList = new List<Slot>();
  entitySlots = await TokenService().getEntitySlots(entity.entityId, dateTime);
  DateTime dayStartTime = new DateTime(dateTime.year, dateTime.month,
      dateTime.day, entity.startTimeHour, entity.startTimeMinute);
  DateTime breakStartTime = new DateTime(dateTime.year, dateTime.month,
      dateTime.day, entity.breakStartHour, entity.breakEndMinute);

  int firstHalfDuration = breakStartTime.difference(dayStartTime).inMinutes;

  DateTime breakEndTime = new DateTime(dateTime.year, dateTime.month,
      dateTime.day, entity.breakEndHour, entity.breakEndMinute);
  DateTime dayEndTime = new DateTime(dateTime.year, dateTime.month,
      dateTime.day, entity.endTimeHour, entity.endTimeMinute);

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
  return token;
}

Future<bool> cancelToken(String tokenId) async {
  bool returnVal = await TokenService().cancelToken(tokenId);
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
