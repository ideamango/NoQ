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
import 'package:intl/intl.dart';

Future<List<Slot>> getSlotsListForStore(
    Entity entity, DateTime dateTime) async {
  EntitySlots entitySlots;
  List<Slot> slotList;
  entitySlots = await TokenService().getEntitySlots(entity.type, dateTime);
  slotList = entitySlots.slots;
  return slotList;
}

Future<UserToken> bookSlotForStore(
    MetaEntity metaEntity, Slot slot, DateTime dateTime) async {
//TODO: Have Entity object here, either pass entity object to generateToken() or create metaEntity and pass to this method.
  UserToken token = await TokenService().generateToken(metaEntity, dateTime);

  return token;
}
