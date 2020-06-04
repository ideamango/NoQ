import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:noq/db/db_model/entity_slots.dart';

import 'package:noq/db/db_service/slot_full_exception.dart';
import 'package:noq/db/db_model/user_token.dart';
import 'package:noq/db/db_model/slot.dart';
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
        fStore.document('tokens/' + entitySlotsDocId);

    DocumentSnapshot doc = await entitySlotsRef.get();

    if (doc.exists) {
      Map<String, dynamic> map = doc.data;

      es = EntitySlots.fromJson(map);

      var slots = doc.data['slots'];
    }

    return es;
  }

  Future<UserToken> generateToken(String entityId, DateTime dateTime) async {
    final FirebaseUser user = await FirebaseAuth.instance.currentUser();
    Firestore fStore = Firestore.instance;
    String userId = user.uid;
    //TODO: To run the validation on DateTime for holidays, break and during closing hours

    String entitySlotsDocId = entityId +
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
        fStore.document('tokens/' + slotId + "#" + userId);

    UserToken token;

    await fStore.runTransaction((Transaction tx) async {
      try {
        DocumentSnapshot entitySlotsSnapshot = await tx.get(entitySlotsRef);
        EntitySlots es;
        if (entitySlotsSnapshot.exists) {
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
                //TODO: set the isFull for that slot to true
                sl.isFull = true;
              }
              //TODO: set the current number to be incremented
              sl.currentNumber = newNumber;

              slotExist = true;
              break;
            }
          }

          if (!slotExist) {
            //TODO: Create a new Slot with current number as 1 and add to the Slots list of Entity_Slots object
            Slot sl = new Slot(
                currentNumber: newNumber,
                slotId: slotId,
                maxAllowed: es.maxAllowed,
                dateTime: dateTime,
                slotDuration: es.slotDuration,
                isFull: false);
            es.slots.add(sl);
          }

          //TODO: Save the EntitySlots using set method
          await tx.set(entitySlotsRef, es.toJson());

          Map<String, dynamic> tokenJson = <String, dynamic>{
            'slotId': slotId,
            'entityId': entityId,
            'userId': userId,
            'number': newNumber,
            'dateTime': dateTime,
            'maxAllowed': maxAllowed
          };
          //create token
          await tx.set(tokRef, tokenJson);

          token = UserToken.fromJson(tokenJson);
        } else {
          //This is the first token for the entity for the given day
          int maxAllowed = 5; // TODO: to be fetched from Entity
          int slotDuration = 30; //TODO: To be fetched from Entity
          List<String> closedOn = ["Saturday", "Sunday"];
          int breakStartHour = 13;
          int breakStartMinute = 30;
          int breakEndHour = 14;
          int breakEndMinute = 15;
          int startTimeHour = 10;
          int startTimeMinute = 0;
          int endTimeHour = 8;
          int endTimeMinute = 30;

          EntitySlots es = new EntitySlots(
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
            'entityId': entityId,
            'userId': userId,
            'number': 1,
            'dateTime': dateTime,
            'maxAllowed': maxAllowed
          };

          //create Slot
          await tx.set(entitySlotsRef, es.toJson());
          //create Token
          await tx.set(tokRef, tokenJson);

          token = UserToken.fromJson(tokenJson);
        }
      } catch (e) {
        print("Transactio Error: " + e.toString());
      }
    });

    return token;
  }

  Future<bool> cancelToken(String tokenId) async {
    //get the token, mark it cancelled
    //get the slot from the token
    //increase the slot maxallowed by one

    final FirebaseUser user = await FirebaseAuth.instance.currentUser();
    Firestore fStore = Firestore.instance;
    String userId = user.uid;

    bool isCancelled = false;

    final DocumentReference tokRef = fStore.document('tokens/' + tokenId);

    await fStore.runTransaction((Transaction tx) async {
      try {
        DocumentSnapshot tokenSnapshot = await tx.get(tokRef);
        if (tokenSnapshot.exists) {
          if (tokenSnapshot.data['userId'] != userId) {
            throw new TokenNotExistsException(
                "Token does not belong to the requested user");
          }

          String slotId = tokenSnapshot.data['slotId'];
          int maxAllowed = tokenSnapshot.data['maxAllowed'];

          final DocumentReference slotRef = fStore.document('slots/' + slotId);

          //update the token with number as -1
          await tx.update(tokRef, <String, dynamic>{'number': -1});

          //change the max allowed by 1, if a token is cancelled
          await tx
              .update(slotRef, <String, dynamic>{'maxAllowed': maxAllowed + 1});

          isCancelled = true;
        } else {
          throw new TokenNotExistsException("Token does not exists");
        }
      } catch (e) {
        print("Transactio Error: " + e.toString());
      }
    });

    return isCancelled;
  }

  Future<List<UserToken>> getTokens(DateTime from, DateTime to) async {
    return null;
  }
}
