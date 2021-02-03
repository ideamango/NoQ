import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:noq/db/db_model/entity_slots.dart';
import 'package:noq/db/db_model/meta_entity.dart';

import 'package:noq/db/db_model/user_token.dart';
import 'package:noq/db/db_model/slot.dart';

import 'package:noq/db/exceptions/max_token_reached_exception.dart';
import 'package:noq/db/exceptions/no_token_found_exception.dart';
import 'package:noq/db/exceptions/slot_full_exception.dart';
import 'package:noq/db/exceptions/token_already_exists_exception.dart';

class TokenService {
  FirebaseApp _fb;

  TokenService(FirebaseApp firebaseApp) {
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

  Future<EntitySlots> getEntitySlots(String entityId, DateTime date) async {
    FirebaseFirestore fStore = getFirestore();

    EntitySlots es;

    String entitySlotsDocId = entityId +
        "#" +
        date.year.toString() +
        "~" +
        date.month.toString() +
        "~" +
        date.day.toString();

    final DocumentReference entitySlotsRef =
        fStore.doc('slots/' + entitySlotsDocId);

    DocumentSnapshot doc = await entitySlotsRef.get();

    if (doc.exists) {
      Map<String, dynamic> map = doc.data();

      es = EntitySlots.fromJson(map);
    }

    return es;
  }

  //this method is used to generate the Token by the user passed here, e.g. EntityAdmin can also generate ToKen for other users
  Future<UserTokens> generateTokenInTransaction(
      Transaction tx,
      String userId,
      MetaEntity metaEntity,
      DateTime dateTime,
      String applicationId,
      String formId,
      String formName) async {
    UserTokens tokens;
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

    FirebaseFirestore fStore = getFirestore();
    final DocumentReference entitySlotsRef =
        fStore.doc('slots/' + entitySlotsDocId);

    final DocumentReference tokRef =
        fStore.doc('tokens/' + slotId + "#" + userId);

    try {
      DocumentSnapshot entitySlotsSnapshot = await tx.get(entitySlotsRef);
      EntitySlots es;

      if (entitySlotsSnapshot.exists) {
        DocumentSnapshot tokenSnapshot = await tx.get(tokRef);
        if (tokenSnapshot.exists && metaEntity.maxTokensPerSlotByUser == 1) {
          throw new TokenAlreadyExistsException(
              "Token for this user is already booked");
        }

        tokens = UserTokens.fromJson(tokenSnapshot.data());

        if (tokenSnapshot.exists &&
            metaEntity.maxTokensPerSlotByUser == tokens.tokens.length) {
          throw new MaxTokenReachedException(
              "Can't book more than ${metaEntity.maxTokensPerSlotByUser.toString} tokens per slot");
        }

        //atleast one token is issued for the given entity for that day
        es = EntitySlots.fromJson(entitySlotsSnapshot.data());
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
        tx.set(entitySlotsRef, es.toJson());

        if (tokens == null) {
          tokens = new UserTokens(
              slotId: slotId,
              entityId: metaEntity.entityId,
              userId: userId,
              dateTime: dateTime,
              maxAllowed: maxAllowed,
              slotDuration: metaEntity.slotDuration,
              entityName: metaEntity.name,
              lat: metaEntity.lat,
              lon: metaEntity.lon,
              entityWhatsApp: metaEntity.whatsapp,
              gpay: metaEntity.gpay,
              paytm: metaEntity.paytm,
              applepay: metaEntity.applepay,
              phone: metaEntity.phone,
              rNum: (Random().nextInt(5000) + 100),
              address: metaEntity.address,
              tokens: new List<UserToken>());
        }

        UserToken newToken = new UserToken(
            number: newNumber,
            order: null,
            applicationId: applicationId,
            bookingFormId: formId,
            bookingFormName: formName,
            parent: tokens);

        tokens.tokens.add(newToken);
        tx.set(tokRef, tokens.toJson());
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

        tokens = new UserTokens(
            slotId: slotId,
            entityId: metaEntity.entityId,
            userId: userId,
            dateTime: dateTime,
            maxAllowed: maxAllowed,
            slotDuration: slotDuration,
            entityName: metaEntity.name,
            lat: metaEntity.lat,
            lon: metaEntity.lon,
            entityWhatsApp: metaEntity.whatsapp,
            gpay: metaEntity.gpay,
            paytm: metaEntity.paytm,
            applepay: metaEntity.applepay,
            phone: metaEntity.phone,
            rNum: (Random().nextInt(5000) + 100),
            address: metaEntity.address,
            tokens: new List<UserToken>());

        UserToken newToken = new UserToken(
            number: 1,
            order: null,
            applicationId: applicationId,
            bookingFormId: formId,
            bookingFormName: formName,
            parent: tokens);

        tokens.tokens.add(newToken);

        //create EntitySlots with one slot in it
        tx.set(entitySlotsRef, es.toJson());

        //create Token
        tx.set(tokRef, tokens.toJson());
      }
    } catch (e) {
      print(
          "Error while generting token -> Transaction Error: " + e.toString());
      throw e;
    }

    return tokens;
  }

  Future<UserToken> autoGenerateTokenForNextAvailableSlot(
      MetaEntity metaEntity, DateTime preferredDateTime, Transaction tx) {}

  //this method is used to generate the Token by the current user for himself
  Future<UserTokens> generateToken(
      MetaEntity metaEntity, DateTime dateTime) async {
    final User user = getFirebaseAuth().currentUser;
    FirebaseFirestore fStore = getFirestore();
    String userPhone = user.phoneNumber;
    Exception exception;
    SlotFullException slotFullException;
    TokenAlreadyExistsException tokenAlreadyExistsException;

    //TODO: To run the validation on DateTime for holidays, break, advnanceDays and during closing hours

    UserTokens tokens;

    await fStore.runTransaction((Transaction tx) async {
      try {
        tokens = await generateTokenInTransaction(
            tx, userPhone, metaEntity, dateTime, null, null, null);
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

    return tokens;
  }

  Future<bool> cancelToken(String tokenId, [int number]) async {
    //number param is optional, only required when multiple tokens are booked by the user for the same slot
    //get the token, mark it cancelled
    //get the slot from the token
    //increase the slot maxallowed by one

    final User user = getFirebaseAuth().currentUser;
    FirebaseFirestore fStore = getFirestore();
    String userPhone = user.phoneNumber;

    bool isCancelled = false;

    final DocumentReference tokRef = fStore.doc('tokens/' + tokenId);

    await fStore.runTransaction((Transaction tx) async {
      try {
        DocumentSnapshot tokenSnapshot = await tx.get(tokRef);
        if (tokenSnapshot.exists) {
          UserTokens tokens = UserTokens.fromJson(tokenSnapshot.data());
          if (tokens.userId != userPhone) {
            throw new NoTokenFoundException(
                "Token does not belong to the requested user");
          }

          if (number == null && tokens.tokens.length > 1) {
            throw new Exception(
                "User has more than one token for the slot, please specify Token number to be cancelled");
          }

          bool numberMatched = false;

          for (UserToken tok in tokens.tokens) {
            if (number == null && tokens.tokens.length == 1) {
              tok.number = -1;
              numberMatched = true;
              break;
            } else {
              if (tok.number == number) {
                tok.number = -1;
                numberMatched = true;
              }
            }
          }

          if (!numberMatched) {
            throw new Exception(
                "Supplied token number for the cancellation did not match");
          }

          String slotId = tokens.slotId;
          List<String> parts = slotId.split("#");

          String entitySlotsDocId = parts[0] + "#" + parts[1];

          final DocumentReference entitySlotsRef =
              fStore.doc('slots/' + entitySlotsDocId);

          DocumentSnapshot doc = await tx.get(entitySlotsRef);

          Map<String, dynamic> map = doc.data();

          EntitySlots es = EntitySlots.fromJson(map);
          for (Slot sl in es.slots) {
            if (sl.slotId == slotId) {
              sl.maxAllowed++;
              sl.isFull = false;
              break;
            }
          }

          //update the token with number as -1
          tx.set(tokRef, tokens.toJson());

          //change the max allowed by 1, if a token is cancelled
          tx.set(entitySlotsRef, es.toJson());

          isCancelled = true;
        } else {
          throw new NoTokenFoundException("Token does not exists");
        }
      } catch (e) {
        print(
            "Error while canceling token -> Transactio Error: " + e.toString());
        isCancelled = false;
      }
    });

    return isCancelled;
  }

  Future<List<UserToken>> getAllTokensForSlot(String slotId) async {
    List<UserToken> userTokens = new List<UserToken>();
    User user = getFirebaseAuth().currentUser;
    if (user == null) return null;
    FirebaseFirestore fStore = getFirestore();

    QuerySnapshot qs;

    try {
      qs = await fStore
          .collection('tokens')
          .where("slotId", isEqualTo: slotId)
          .get();

      for (DocumentSnapshot ds in qs.docs) {
        UserTokens tokens = UserTokens.fromJson(ds.data());
        for (UserToken tok in tokens.tokens) {
          userTokens.add(tok);
        }
      }
    } catch (e) {
      print(
          "Error while fetching all tokens for a given slot: " + e.toString());
    }

    return userTokens;
  }

  Future<List<UserTokens>> getAllTokensForCurrentUser(
      DateTime from, DateTime to) async {
    List<UserTokens> tokens = new List<UserTokens>();
    User user = getFirebaseAuth().currentUser;
    if (user == null) return null;
    FirebaseFirestore fStore = getFirestore();

    QuerySnapshot qs;

    try {
      if (from != null && to != null) {
        qs = await fStore
            .collection('tokens')
            .where("dateTime",
                isGreaterThanOrEqualTo: from.millisecondsSinceEpoch)
            .where("dateTime", isLessThanOrEqualTo: to.millisecondsSinceEpoch)
            .where("userId", isEqualTo: user.phoneNumber)
            .get();
      } else if (from != null && to == null) {
        qs = await fStore
            .collection('tokens')
            .where("dateTime",
                isGreaterThanOrEqualTo: from.millisecondsSinceEpoch)
            .where("userId", isEqualTo: user.phoneNumber)
            .get();
      }

      for (DocumentSnapshot ds in qs.docs) {
        UserTokens tok = UserTokens.fromJson(ds.data());
        tokens.add(tok);
      }
    } catch (e) {
      print("Error while fetching tokens: " + e.toString());
    }

    return tokens;
  }

  Future<List<UserTokens>> getTokensForEntityBookedByCurrentUser(
      String entityId, DateTime date) async {
    List<UserTokens> tokens = new List<UserTokens>();
    User user = getFirebaseAuth().currentUser;
    FirebaseFirestore fStore = getFirestore();
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
          .get();

      for (DocumentSnapshot ds in qs.docs) {
        UserTokens tok = UserTokens.fromJson(ds.data());
        tokens.add(tok);
      }
    } catch (e) {
      print("Error while fetching token: " + e.toString());
    }

    return tokens;
  }

  Future<bool> deleteSlot(String slotId) async {
    //this should be restricted on Server, only to be used for testcases
    FirebaseFirestore fStore = getFirestore();

    DocumentReference slotRef = fStore.doc('slots/' + slotId);

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
    FirebaseFirestore fStore = getFirestore();

    DocumentReference tokRef = fStore.doc('tokens/' + tokenId);

    try {
      await tokRef.delete();
    } catch (e) {
      print("Error deleting token: " + e.toString());
      return false;
    }

    return true;
  }

  Future<bool> updateToken(UserTokens tokens) async {
    //this should be restricted on Server, only to be used for testcases
    final User user = getFirebaseAuth().currentUser;
    FirebaseFirestore fStore = getFirestore();

    DocumentReference tokRef = fStore.doc('tokens/' + tokens.getTokenId());

    try {
      DocumentSnapshot doc = await tokRef.get();
      if (doc.exists) {
        await tokRef.update(tokens.toJson());
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
