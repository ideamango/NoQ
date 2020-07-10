//Post selected Slot to server
//Cancel Slot
//List Slots for particular store

import 'dart:convert';
import 'package:http/http.dart';
import 'package:noq/db/db_model/entity.dart';
import 'package:noq/db/db_model/entity_slots.dart';
import 'package:noq/db/db_model/meta_entity.dart';
import 'package:noq/db/db_model/slot.dart';
import 'package:noq/db/db_model/user_token.dart';
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

Future<UserToken> bookSlotForStore(
    MetaEntity metaEntity, DateTime dateTime) async {
  UserToken token = await TokenService().generateToken(metaEntity, dateTime);
  // String jsonString =
  //     '[{"id": "1", "storeId": "21","slotStrTime": "9:00","slotEndTime": "9:30","slotAvlFlg": "true","slotSelected":"false"},{"id": "2", "storeId": "21","slotStrTime": "9:30","slotEndTime": "10:00","slotAvlFlg": "true","slotSelected":"false"},{"id": "3", "storeId": "21","slotStrTime": "10:00","slotEndTime": "10:30","slotAvlFlg": "false","slotSelected":"false"},{"id": "4", "storeId": "21","slotStrTime": "10:30","slotEndTime": "11:00","slotAvlFlg": "true","slotSelected":"false"}]';

  // // String url = "https://jsonplaceholder.typicode.com/posts";
  // // Response res =
  // //     await get(Uri.encodeFull(url), headers: {"Accept": "application/json"});
  // // int statusCode = res.statusCode;
  // // //Map<String, String> headers = response.headers;
  // // //String contentType = headers["content-type"];
  // // //Check if status code is 200
  // // if (statusCode == 404) {
  // //   //in case of no results found

  // // } else if (statusCode == 200) {
  // //   //resBody = res.body;
  // resBody = jsonString;
  // var data = json.decode(resBody);

  // var resSlots = data as List;

  // slots = resSlots.map((slot) => Slot.fromJSON(slot)).toList();
  return token;
}
