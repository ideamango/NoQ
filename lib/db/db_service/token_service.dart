import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:noq/db/db_model/entity_slots.dart';
import 'package:noq/db/db_model/meta_entity.dart';

import 'package:noq/db/db_service/slot_full_exception.dart';
import 'package:noq/db/db_model/user_token.dart';
import 'package:noq/db/db_model/slot.dart';
import 'package:noq/db/db_service/token_already_exists_exception.dart';
import 'package:noq/db/db_service/token_not_exist_exception.dart';

class TokenService {
  Future<EntitySlots> getEntitySlots(String entityId, DateTime date) async {
    Firestore fStore = Firestore.instance;

    EntitySlots es;

    String entitySlotsDocId = entityId +
        "#" +
        date.year.toString() +
        "~" +
        date.month.toString() +
        "~" +
        date.day.toString();

    final DocumentReference entitySlotsRef =
        fStore.document('slots/' + entitySlotsDocId);

    DocumentSnapshot doc = await entitySlotsRef.get();

    if (doc.exists) {
      Map<String, dynamic> map = doc.data;

      es = EntitySlots.fromJson(map);
    }

    return es;
  }

  Future<UserToken> generateToken(
      MetaEntity metaEntity, DateTime dateTime) async {
    final FirebaseUser user = await FirebaseAuth.instance.currentUser();
    Firestore fStore = Firestore.instance;
    String userPhone = user.phoneNumber;
    Exception exception;
    SlotFullException slotFullException;
    TokenAlreadyExistsException tokenAlreadyExistsException;

    //TODO: To run the validation on DateTime for holidays, break, advnanceDays and during closing hours

    String entitySlotsDocId = metaEntity.entityId +
        "#" +
        dateTime.year.toString() +
        "~" +
        dateTime.month.toString() +
        "~" +
        dateTime.day.toString();

    String slotId = entitySlotsDocId +
        "#" +
        dateTime.hour.toString() +
        "~" +
        dateTime.minute.toString();

    final DocumentReference entitySlotsRef =
        fStore.document('slots/' + entitySlotsDocId);

    final DocumentReference tokRef =
        fStore.document('tokens/' + slotId + "#" + userPhone);

    UserToken token;

    await fStore.runTransaction((Transaction tx) async {
      try {
        DocumentSnapshot entitySlotsSnapshot = await tx.get(entitySlotsRef);
        EntitySlots es;

        if (entitySlotsSnapshot.exists) {
          DocumentSnapshot tokenSnapshot = await tx.get(tokRef);
          if (tokenSnapshot.exists) {
            throw new TokenAlreadyExistsException(
                "Token for this user is already booked");
          }

          //atleast one token is issued for the given entity for that day
          es = EntitySlots.fromJson(entitySlotsSnapshot.data);
          int maxAllowed = es.maxAllowed;

          int slotCount = -1;
          bool slotExist = false;
          int newNumber = 1;
          for (var sl in es.slots) {
            slotCount++;
            if (sl.dateTime.hour == dateTime.hour &&
                sl.dateTime.minute == dateTime.minute) {
              //slot already exists for given time
              if (sl.isFull) {
                throw new SlotFullException(
                    "Token can't be generated as the slot is full");
              }

              newNumber = sl.currentNumber + 1;

              if (sl.maxAllowed == newNumber) {
                // set the isFull for that slot to true
                sl.isFull = true;
              }
              // set the current number to be incremented
              sl.currentNumber = newNumber;

              slotExist = true;
              break;
            }
          }

          if (!slotExist) {
            // Create a new Slot with current number as 1 and add to the Slots list of Entity_Slots object
            Slot sl = new Slot(
                currentNumber: 1,
                slotId: slotId,
                maxAllowed: es.maxAllowed,
                dateTime: dateTime,
                slotDuration: es.slotDuration,
                isFull: false);
            es.slots.add(sl);
          }

          // Save the EntitySlots using set method
          await tx.set(entitySlotsRef, es.toJson());

          Map<String, dynamic> tokenJson = <String, dynamic>{
            'slotId': slotId,
            'entityId': metaEntity.entityId,
            'userId': userPhone,
            'number': newNumber,
            'dateTime': dateTime.millisecondsSinceEpoch,
            'maxAllowed': maxAllowed,
            'slotDuration': metaEntity.slotDuration,
            'entityName': metaEntity.name,
            'lat': metaEntity.lat,
            'lon': metaEntity.lon,
            'entityWhatsApp': metaEntity.whatsapp,
            'gpay': metaEntity.gpay,
            'paytm': metaEntity.paytm,
            'applepay': metaEntity.applepay,
            'order': null,
            'phone': metaEntity.phone
          };
          //create token
          await tx.set(tokRef, tokenJson);

          token = UserToken.fromJson(tokenJson);
        } else {
          //This is the first token for the entity for the given day
          int maxAllowed = metaEntity.maxAllowed;
          int slotDuration = metaEntity.slotDuration;
          List<String> closedOn = metaEntity.closedOn;
          int breakStartHour = metaEntity.breakStartHour;
          int breakStartMinute = metaEntity.breakStartMinute;
          int breakEndHour = metaEntity.breakEndHour;
          int breakEndMinute = metaEntity.breakEndMinute;
          int startTimeHour = metaEntity.startTimeHour;
          int startTimeMinute = metaEntity.startTimeHour;
          int endTimeHour = metaEntity.endTimeHour;
          int endTimeMinute = metaEntity.endTimeMinute;

          EntitySlots es = new EntitySlots(
              slots: new List<Slot>(),
              entityId: metaEntity.entityId,
              date: new DateTime(dateTime.year, dateTime.month, dateTime.day),
              maxAllowed: maxAllowed,
              slotDuration: slotDuration,
              closedOn: closedOn,
              breakStartHour: breakStartHour,
              breakStartMinute: breakStartMinute,
              breakEndHour: breakEndHour,
              breakEndMinute: breakEndMinute,
              startTimeHour: startTimeHour,
              startTimeMinute: startTimeMinute,
              endTimeHour: endTimeHour,
              endTimeMinute: endTimeMinute);

          Slot sl = new Slot(
              currentNumber: 1,
              slotId: slotId,
              maxAllowed: es.maxAllowed,
              dateTime: dateTime,
              slotDuration: es.slotDuration,
              isFull: false);
          es.slots.add(sl);

          Map<String, dynamic> tokenJson = <String, dynamic>{
            'slotId': slotId,
            'entityId': metaEntity.entityId,
            'userId': userPhone,
            'number': 1,
            'dateTime': dateTime.millisecondsSinceEpoch,
            'maxAllowed': maxAllowed,
            'slotDuration': slotDuration,
            'entityName': metaEntity.name,
            'lat': metaEntity.lat,
            'lon': metaEntity.lon,
            'entityWhatsApp': metaEntity.whatsapp,
            'gpay': metaEntity.gpay,
            'paytm': metaEntity.paytm,
            'applepay': metaEntity.applepay,
            'order': null,
            'phone': metaEntity.phone
          };

          //create EntitySlots with one slot in it
          await tx.set(entitySlotsRef, es.toJson());
          //create Token

          await tx.set(tokRef, tokenJson);

          token = UserToken.fromJson(tokenJson);
        }
      } catch (e) {
        print("Error while generting token -> Transaction Error: " +
            e.toString());
        if (e is SlotFullException) {
          slotFullException = e;
        }
        if (e is TokenAlreadyExistsException) {
          tokenAlreadyExistsException = e;
        }
        exception = e;
      }
    });

    if (slotFullException != null) {
      throw slotFullException;
    }

    if (tokenAlreadyExistsException != null) {
      throw tokenAlreadyExistsException;
    }

    if (exception != null) {
      throw exception;
    }

    return token;
  }

  Future<bool> cancelToken(String tokenId) async {
    //get the token, mark it cancelled
    //get the slot from the token
    //increase the slot maxallowed by one

    final FirebaseUser user = await FirebaseAuth.instance.currentUser();
    Firestore fStore = Firestore.instance;
    String userPhone = user.phoneNumber;

    bool isCancelled = false;

    final DocumentReference tokRef = fStore.document('tokens/' + tokenId);

    await fStore.runTransaction((Transaction tx) async {
      try {
        DocumentSnapshot tokenSnapshot = await tx.get(tokRef);
        if (tokenSnapshot.exists) {
          if (tokenSnapshot.data['userId'] != userPhone) {
            throw new TokenNotExistsException(
                "Token does not belong to the requested user");
          }

          int currentNum = tokenSnapshot.data['number'];
          if (currentNum == -1) {
            throw new Exception("Token is already cancelled");
          }

          String slotId = tokenSnapshot.data['slotId'];
          List<String> parts = slotId.split("#");

          String entitySlotsDocId = parts[0] + "#" + parts[1];

          final DocumentReference entitySlotsRef =
              fStore.document('slots/' + entitySlotsDocId);

          DocumentSnapshot doc = await entitySlotsRef.get();

          Map<String, dynamic> map = doc.data;

          EntitySlots es = EntitySlots.fromJson(map);
          for (Slot sl in es.slots) {
            if (sl.slotId == slotId) {
              sl.maxAllowed++;
              sl.isFull = false;
              break;
            }
          }

          //update the token with number as -1
          await tx.update(tokRef, <String, dynamic>{'number': -1});

          //change the max allowed by 1, if a token is cancelled
          await tx.set(entitySlotsRef, es.toJson());

          isCancelled = true;
        } else {
          throw new TokenNotExistsException("Token does not exists");
        }
      } catch (e) {
        print(
            "Error while canceling token -> Transactio Error: " + e.toString());
        isCancelled = false;
      }
    });

    return isCancelled;
  }

  Future<List<UserToken>> getAllTokensForCurrentUser(
      DateTime from, DateTime to) async {
    List<UserToken> tokens = new List<UserToken>();
    FirebaseUser user = await FirebaseAuth.instance.currentUser();
    Firestore fStore = Firestore.instance;

    QuerySnapshot qs;

    try {
      if (from != null && to != null) {
        qs = await fStore
            .collection('tokens')
            .where("dateTime",
                isGreaterThanOrEqualTo: from.millisecondsSinceEpoch)
            .where("dateTime", isLessThanOrEqualTo: to.millisecondsSinceEpoch)
            .where("userId", isEqualTo: user.phoneNumber)
            .getDocuments();
      } else if (from != null && to == null) {
        qs = await fStore
            .collection('tokens')
            .where("dateTime",
                isGreaterThanOrEqualTo: from.millisecondsSinceEpoch)
            .where("userId", isEqualTo: user.phoneNumber)
            .getDocuments();
      }

      for (DocumentSnapshot ds in qs.documents) {
        UserToken tok = UserToken.fromJson(ds.data);
        tokens.add(tok);
      }
    } catch (e) {
      print("Error while fetching tokens: " + e.toString());
    }

    return tokens;
  }

  Future<List<UserToken>> getTokensForEntityBookedByCurrentUser(
      String entityId, DateTime date) async {
    List<UserToken> tokens = new List<UserToken>();
    FirebaseUser user = await FirebaseAuth.instance.currentUser();
    Firestore fStore = Firestore.instance;
    DateTime inputDate = new DateTime(date.year, date.month, date.day);
    DateTime nextDay = inputDate.add(new Duration(days: 1));

    try {
      QuerySnapshot qs = await fStore
          .collection('tokens')
          .where("dateTime",
              isGreaterThanOrEqualTo: date.millisecondsSinceEpoch)
          .where("dateTime", isLessThan: nextDay.millisecondsSinceEpoch)
          .where("userId", isEqualTo: user.phoneNumber)
          .where("entityId", isEqualTo: entityId)
          .getDocuments();

      for (DocumentSnapshot ds in qs.documents) {
        UserToken tok = UserToken.fromJson(ds.data);
        tokens.add(tok);
      }
    } catch (e) {
      print("Error while fetching token: " + e.toString());
    }

    return tokens;
  }

  Future<bool> deleteSlot(String slotId) async {
    //this should be restricted on Server, only to be used for testcases
    Firestore fStore = Firestore.instance;

    DocumentReference slotRef = fStore.document('slots/' + slotId);

    try {
      await slotRef.delete();
    } catch (e) {
      print(e);
      return false;
    }

    return true;
  }

  Future<bool> deleteToken(String tokenId) async {
    //this should be restricted on Server, only to be used for testcases
    Firestore fStore = Firestore.instance;

    DocumentReference tokRef = fStore.document('tokens/' + tokenId);

    try {
      await tokRef.delete();
    } catch (e) {
      print("Error deleting token: " + e.toString());
      return false;
    }

    return true;
  }

  Future<bool> updateToken(UserToken token) async {
    //this should be restricted on Server, only to be used for testcases
    final FirebaseUser user = await FirebaseAuth.instance.currentUser();
    Firestore fStore = Firestore.instance;

    DocumentReference tokRef = fStore.document('tokens/' + token.getTokenId());

    try {
      DocumentSnapshot doc = await tokRef.get();
      if (doc.exists) {
        await tokRef.updateData(token.toJson());
        return true;
      }
    } catch (e) {
      //TODO Smita - Exception by line  await tokRef.updateData(token.toJson());
      // e.toStr - Error while updating Token: Invalid argument: Instance of 'Order'
      print("Error while updating Token: " + e.toString());
      return false;
    }

    return false;
  }
}
