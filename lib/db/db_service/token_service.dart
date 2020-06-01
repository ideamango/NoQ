import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:noq/db/db_service/slot_full_exception.dart';
import 'package:noq/db/db_model/user_token.dart';
import 'package:noq/db/db_model/slot.dart';
import 'package:noq/db/db_service/token_not_exist_exception.dart';

class TokenService {
  Future<UserToken> generateToken(String entityId, DateTime dateTime) async {
    final FirebaseUser user = await FirebaseAuth.instance.currentUser();
    Firestore fStore = Firestore.instance;
    String userId = user.uid;

    //check if the slot is created exists for the given DateTime

    //if slot exists:
    //try updating the slot with conditional write where currentNumber == newnumber-1, if not the update should fail
    String slotDocId = entityId +
        "#" +
        dateTime.year.toString() +
        "~" +
        dateTime.month.toString() +
        "~" +
        dateTime.day.toString() +
        "#" +
        dateTime.hour.toString() +
        "~" +
        dateTime.minute.toString();

    final DocumentReference slotRef = fStore.document('slots/' + slotDocId);

    final DocumentReference tokRef =
        fStore.document('tokens/' + slotDocId + "#" + userId);

    UserToken token;

    await fStore.runTransaction((Transaction tx) async {
      try {
        DocumentSnapshot slotSnapshot = await tx.get(slotRef);
        if (slotSnapshot.exists) {
          int maxAllowed = slotSnapshot.data['maxAllowed'];
          if (slotSnapshot.data['currentNumber'] >= maxAllowed) {
            throw new SlotFullException(
                "Token can't be generated as the slot is full");
          }
          int newNumber = slotSnapshot.data['currentNumber'] + 1;

          await tx
              .update(slotRef, <String, dynamic>{'currentNumber': newNumber});

          Map<String, dynamic> tokenJson = <String, dynamic>{
            'slotId': slotDocId,
            'entityId': entityId,
            'userId': userId,
            'number': newNumber,
            'dateTime': slotSnapshot.data['dateTime'],
            'maxAllowed': maxAllowed
          };
          //create token
          await tx.set(tokRef, tokenJson);

          token = UserToken.fromJson(tokenJson);
        } else {
          int maxAllowed = 5; // TODO: to be fetched from Entity
          int slotDuration = 30; //TODO: To be fetched from Entity

          Map<String, dynamic> slotJson = <String, dynamic>{
            'entityId': entityId,
            'maxAllowed': maxAllowed,
            'dateTime': dateTime,
            'currentNumber': 1,
            'slotDuration': slotDuration
          };

          Map<String, dynamic> tokenJson = <String, dynamic>{
            'slotId': slotDocId,
            'entityId': entityId,
            'userId': userId,
            'number': 1,
            'dateTime': dateTime,
            'maxAllowed': maxAllowed
          };

          //create Slot
          await tx.set(slotRef, slotJson);
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
