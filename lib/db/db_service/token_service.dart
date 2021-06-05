import 'dart:math';

import 'package:LESSs/db/exceptions/MaxTokenReachedByUserPerDayException.dart';
import 'package:LESSs/db/exceptions/access_denied_exception.dart';
import 'package:LESSs/db/exceptions/token_already_cancelled_exception.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/services.dart';

import '../../tuple.dart';
import '../db_model/entity_slots.dart';
import '../db_model/meta_entity.dart';

import '../db_model/user_token.dart';
import '../db_model/slot.dart';

import '../exceptions/MaxTokenReachedByUserPerSlotException.dart';
import '../exceptions/no_token_found_exception.dart';
import '../exceptions/slot_full_exception.dart';
import '../exceptions/token_already_exists_exception.dart';

import '../../constants.dart';
import '../../utils.dart';

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

  Future<List<List<Slot>>> getSlotsFromNow(
      MetaEntity me, bool onlyFreeSlot) async {
    FirebaseFirestore fStore = getFirestore();
    CollectionReference collectionRef = fStore.collection('slots');

    DateTime currentDate = DateTime.now();
    int holidaySkip = 0;
    int dayCount = 0;
    while (true) {
      DateTime nextDay = currentDate.add(Duration(days: dayCount));
      dayCount++;
      for (String closedDay in me.closedOn) {
        if (Utils.getDayNumber(closedDay.toLowerCase()) == nextDay.weekday) {
          holidaySkip++;
          break;
        }
      }
      if (dayCount - holidaySkip == me.advanceDays) {
        break;
      }
    }

    Query query = collectionRef;

    query = query.where("entityId", isEqualTo: me.entityId);

    query = query.where("date", isGreaterThanOrEqualTo: DateTime.now());

    if (me.advanceDays > 1) {
      query = query.where("date",
          isLessThanOrEqualTo:
              DateTime.now().add(Duration(days: dayCount - 1)));
    }

    List<EntitySlots> entitySlots = [];

    QuerySnapshot qs = await query.get();
    List<QueryDocumentSnapshot> qds = qs.docs;
    for (QueryDocumentSnapshot doc in qds) {
      if (doc.exists) {
        entitySlots.add(EntitySlots.fromJson(doc.data()));
      }
    }

    List<List<Slot>> dayWiseSlots = [];

    for (int i = 0; i < dayCount; i++) {
      DateTime date = currentDate.add(Duration(days: i));
      EntitySlots currentES;
      for (EntitySlots es in entitySlots) {
        if (es.date.year == date.year &&
            es.date.month == date.month &&
            es.date.day == date.day) {
          currentES = es;
          break;
        }
      }

      if (currentES == null) {
        if (!Utils.checkIfClosed(date, me.closedOn)) {
          currentES = EntitySlots(
              slots: null,
              entityId: me.entityId,
              maxAllowed: me.maxAllowed,
              date: date,
              slotDuration: me.slotDuration,
              closedOn: me.closedOn,
              breakStartHour: me.breakStartHour,
              breakStartMinute: me.breakStartMinute,
              breakEndHour: me.breakEndHour,
              breakEndMinute: me.breakEndMinute,
              startTimeHour: me.startTimeHour,
              startTimeMinute: me.startTimeMinute,
              endTimeHour: me.endTimeHour,
              endTimeMinute: me.endTimeMinute);
        }
      }

      if (currentES != null) {
        dayWiseSlots.add(Utils.getSlots(currentES, me, date));
      }
    }

    if (onlyFreeSlot) {
      List<List<Slot>> dayWiseFreeSlots = [];
      int count = -1;
      for (List<Slot> slots in dayWiseSlots) {
        bool dayExist = false;
        for (Slot sl in slots) {
          if (!sl.isFull) {
            if (!dayExist) {
              dayWiseFreeSlots.add([]);
              dayExist = true;
              count++;
            }
            dayWiseFreeSlots[count].add(sl);
          }
        }
      }

      return dayWiseFreeSlots;
    }

    return dayWiseSlots;
  }

  Future<UserTokens> getUserToken(String tokenId) async {
    FirebaseFirestore fStore = getFirestore();

    UserTokens userToks;

    try {
      final DocumentReference tokenCounterRef = fStore.doc('tokens/' + tokenId);

      DocumentSnapshot doc = await tokenCounterRef.get();

      if (doc.exists) {
        Map<String, dynamic> map = doc.data();

        userToks = UserTokens.fromJson(map);
      }
    } catch (e) {
      if (e.code == "permission-denied") {
        throw new AccessDeniedException(
            "You do not have permission to view the Token.");
      }
    }

    return userToks;
  }

  Future<TokenCounter> getTokenCounterForEntity(
      String entityId, String year) async {
    FirebaseFirestore fStore = getFirestore();

    TokenCounter tokenCounter;

    String tokenCounterId = TOKEN_COUNTER_PREFIX + "#" + entityId + "#" + year;

    final DocumentReference tokenCounterRef =
        fStore.doc('counter/' + tokenCounterId);

    DocumentSnapshot doc = await tokenCounterRef.get();

    if (doc.exists) {
      Map<String, dynamic> map = doc.data();

      tokenCounter = TokenCounter.fromJson(map);
    }

    return tokenCounter;
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
  Future<Tuple<UserTokens, TokenCounter>> generateTokenInTransaction(
      Transaction tx,
      String userId,
      MetaEntity metaEntity,
      DateTime dateTime,
      String applicationId,
      String formId,
      String formName,
      [bool enableVideoChat = false]) async {
    Exception e;

    UserTokens tokens;
    TokenCounter tokenCounter;
    String yearMonthDay = dateTime.year.toString() +
        "~" +
        dateTime.month.toString() +
        "~" +
        dateTime.day.toString();

    String hourMinute =
        dateTime.hour.toString() + "~" + dateTime.minute.toString();

    String entitySlotsDocId = metaEntity.entityId + "#" + yearMonthDay;

    String slotId = entitySlotsDocId + "#" + hourMinute;

    String tokenCounterId = TOKEN_COUNTER_PREFIX +
        "#" +
        metaEntity.entityId +
        "#" +
        dateTime.year.toString();

    FirebaseFirestore fStore = getFirestore();
    final DocumentReference entitySlotsRef =
        fStore.doc('slots/' + entitySlotsDocId);

    final DocumentReference tokRef =
        fStore.doc('tokens/' + slotId + "#" + userId);

    final DocumentReference tokenCounterRef =
        fStore.doc('counter/' + tokenCounterId);

    try {
      DocumentSnapshot entitySlotsSnapshot = await tx.get(entitySlotsRef);
      EntitySlots es;

      if (entitySlotsSnapshot.exists) {
        DocumentSnapshot tokenSnapshot = await tx.get(tokRef);
        tokens = UserTokens.fromJson(tokenSnapshot.data());
        // if (tokenSnapshot.exists && metaEntity.maxTokensPerSlotByUser == 1) {
        //   if (tokens.tokens[0].number != -1)
        //     throw new TokenAlreadyExistsException(
        //         "Token for this user is already booked");
        // }

        if (tokenSnapshot.exists &&
            metaEntity.maxTokensPerSlotByUser <= tokens.tokens.length) {
          int numberOfCancelledInSlot = 0;
          for (UserToken ut in tokens.tokens) {
            if (ut.number == -1) {
              numberOfCancelledInSlot++;
            }
          }

          if (tokens.tokens.length - numberOfCancelledInSlot ==
              metaEntity.maxTokensPerSlotByUser) {
            throw new MaxTokenReachedByUserPerSlotException(
                "Can't book more than ${metaEntity.maxTokensPerSlotByUser.toString} tokens per slot");
          }
        }

        //atleast one token is issued for the given entity for that day
        es = EntitySlots.fromJson(entitySlotsSnapshot.data());
        int maxAllowed = es.maxAllowed;

        int slotCount = -1;

        int newNumber = 1;
        Slot existingSlot;
        for (var sl in es.slots) {
          slotCount++;
          if (sl.dateTime.hour == dateTime.hour &&
              sl.dateTime.minute == dateTime.minute) {
            //slot already exists for given time
            if (sl.isFull) {
              throw new SlotFullException(
                  "Token can't be generated as the slot is full");
            }

            newNumber = sl.totalBooked != null ? sl.totalBooked + 1 : 1;

            if (sl.maxAllowed == newNumber) {
              // set the isFull for that slot to true
              sl.isFull = true;
            }
            // set the current number to be incremented
            sl.totalBooked = newNumber;

            existingSlot = sl;
            break;
          }
        }

        //check if the user has already reached the limit for the day
        int dayCountForUser = 0;
        int numberOfCancelledInDay = 0;
        for (Slot sl in es.slots) {
          for (UserTokens uts in sl.tokens) {
            if (uts.userId == userId) {
              int numOfTokensInASlot = uts.tokens.length;
              dayCountForUser += numOfTokensInASlot;
            }
            for (UserToken ut in uts.tokens) {
              if (ut.number == -1) {
                numberOfCancelledInDay++;
              }
            }
          }
        }

        if (dayCountForUser - numberOfCancelledInDay ==
            metaEntity.maxTokensByUserInDay) {
          throw new MaxTokenReachedByUserPerDayException(
              "User has reached max token count for the day, which is " +
                  dayCountForUser.toString());
        }

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
              upiId: metaEntity.upiId,
              upiPhoneNumber: metaEntity.upiPhoneNumber,
              upiQRImagePath: metaEntity.upiQRImagePath,
              phone: metaEntity.phone,
              rNum: (Random().nextInt(5000) + 100),
              address: metaEntity.address,
              tokens: [],
              isOnlineAppointment: enableVideoChat);
        }

        UserToken newToken = new UserToken(
            number: newNumber,
            order: null,
            applicationId: applicationId,
            bookingFormId: formId,
            bookingFormName: formName,
            parent: tokens);

        tokens.tokens.add(newToken);

        if (existingSlot == null) {
          // Create a new Slot with current number as 1 and add to the Slots list of Entity_Slots object
          Slot newSlot = new Slot(
              totalBooked: 1,
              slotId: slotId,
              maxAllowed: es.maxAllowed,
              dateTime: dateTime,
              slotDuration: es.slotDuration,
              isFull: false,
              totalCancelled: 0);
          if (newSlot.tokens == null) {
            newSlot.tokens = [];
          }
          newSlot.tokens.add(tokens);
          es.slots.add(newSlot);
        } else {
          if (existingSlot.tokens == null) {
            existingSlot.tokens = [];
          }
          int existingTokenIndex = -1;
          bool tokenAlreadyExists = false;
          for (UserTokens uts in existingSlot.tokens) {
            existingTokenIndex++;
            if (uts.getTokenId() == tokens.getTokenId()) {
              tokenAlreadyExists = true;
              break;
            }
          }

          if (existingTokenIndex > -1 && tokenAlreadyExists) {
            existingSlot.tokens[existingTokenIndex] = tokens;
          } else {
            existingSlot.tokens.add(tokens);
          }
        }
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
        int startTimeMinute = metaEntity.startTimeMinute;
        int endTimeHour = metaEntity.endTimeHour;
        int endTimeMinute = metaEntity.endTimeMinute;

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
            upiId: metaEntity.upiId,
            upiPhoneNumber: metaEntity.upiPhoneNumber,
            upiQRImagePath: metaEntity.upiQRImagePath,
            phone: metaEntity.phone,
            rNum: (Random().nextInt(5000) + 100),
            address: metaEntity.address,
            tokens: [],
            isOnlineAppointment: enableVideoChat);

        UserToken newToken = new UserToken(
            number: 1,
            order: null,
            applicationId: applicationId,
            bookingFormId: formId,
            bookingFormName: formName,
            parent: tokens);

        es = new EntitySlots(
            slots: [],
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
            totalBooked: 1,
            slotId: slotId,
            maxAllowed: es.maxAllowed,
            dateTime: dateTime,
            slotDuration: es.slotDuration,
            isFull: false,
            totalCancelled: 0);
        if (sl.tokens == null) {
          sl.tokens = [];
        }

        sl.tokens.add(tokens);

        es.slots.add(sl);

        tokens.tokens.add(newToken);
      }

      DocumentSnapshot tokenCounterSnapshot = await tx.get(tokenCounterRef);

      if (tokenCounterSnapshot.exists) {
        Map<String, dynamic> map = tokenCounterSnapshot.data();
        tokenCounter = TokenCounter.fromJson(map);
      } else {
        tokenCounter = new TokenCounter(
            entityId: metaEntity.entityId, year: dateTime.year.toString());
        tokenCounter.slotWiseStats = new Map<String, TokenStats>();
      }

      //update the TokenCounter, check the key year~month~day#slot-time
      String key = yearMonthDay + "#" + hourMinute;
      if (!tokenCounter.slotWiseStats.containsKey(key)) {
        tokenCounter.slotWiseStats[key] = TokenStats();
      }
      tokenCounter.slotWiseStats[key].numberOfTokensCreated =
          tokenCounter.slotWiseStats[key].numberOfTokensCreated + 1;

      //create EntitySlots with one slot in it
      tx.set(entitySlotsRef, es.toJson());

      //create Token
      tx.set(tokRef, tokens.toJson());
      //create/update the TokenCounter
      tx.set(tokenCounterRef, tokenCounter.toJson());
    } catch (ex) {
      print(
          "Error while generting token -> Transaction Error: " + e.toString());
      throw ex;
    }

    return new Tuple(item1: tokens, item2: tokenCounter);
  }

  Future<UserToken> autoGenerateTokenForNextAvailableSlot(
      MetaEntity metaEntity, DateTime preferredDateTime, Transaction tx) {}

  //this method is used to generate the Token by the current user for himself
  //Throws => MaxTokenReachedByUserPerSlotException, TokenAlreadyExistsException, SlotFullException, MaxTokenReachedByUserPerDayException
  Future<Tuple<UserTokens, TokenCounter>> generateToken(
      MetaEntity metaEntity, DateTime dateTime,
      [bool enableVideoChat = false]) async {
    User user = getFirebaseAuth().currentUser;
    FirebaseFirestore fStore = getFirestore();
    String userPhone = user.phoneNumber;
    Exception exception;
    SlotFullException slotFullException;
    TokenAlreadyExistsException tokenAlreadyExistsException;

    //TODO: To run the validation on DateTime for holidays, break, advnanceDays and during closing hours

    Tuple<UserTokens, TokenCounter> tuple;

    await fStore.runTransaction((Transaction tx) async {
      try {
        tuple = await generateTokenInTransaction(tx, userPhone, metaEntity,
            dateTime, null, null, null, enableVideoChat);
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

    return tuple;
  }

  Future<Tuple<UserToken, TokenCounter>> cancelTokenInTransaction(
      Transaction tx, String userId, String tokenId,
      [int number]) async {
    FirebaseFirestore fStore = getFirestore();

    String userPhone = userId;

    bool isCancelled = false;

    TokenCounter tokenCounter;

    UserToken tokenCancelled;

    final DocumentReference tokRef = fStore.doc('tokens/' + tokenId);
    try {
      DocumentSnapshot tokenSnapshot = await tx.get(tokRef);
      if (tokenSnapshot.exists) {
        UserTokens tokens = UserTokens.fromJson(tokenSnapshot.data());
        // if (tokens.userId != userPhone) {
        //   throw new NoTokenFoundException(
        //       "Token does not belong to the requested user");
        // }

        if (number == null && tokens.tokens.length > 1) {
          throw new Exception(
              "User has more than one token for the slot, please specify Token number to be cancelled");
        }

        bool numberMatched = false;

        for (UserToken tok in tokens.tokens) {
          if (number == null && tokens.tokens.length == 1) {
            if (tok.number == -1) {
              throw new TokenAlreadyCancelledException(
                  "Token is already cancelled");
            }
            tok.numberBeforeCancellation = tok.number;
            tok.number = -1;
            numberMatched = true;
            tokenCancelled = tok;
            break;
          } else {
            if (tok.number == number) {
              tok.numberBeforeCancellation = tok.number;
              tok.number = -1;
              numberMatched = true;
              tokenCancelled = tok;
              break;
            }
          }
        }

        if (!numberMatched) {
          throw new TokenAlreadyCancelledException(
              "Token number for the cancellation not found OR already cancelled");
        }

        String slotId = tokens.slotId;
        List<String> parts = slotId.split("#");
        String entityId = parts[0];
        String yearMonthDay = parts[1];
        String hourMinute = parts[2];
        List<String> dateParts = yearMonthDay.split("~");
        String year = dateParts[0];

        DateTime tokenDateTime;

        String entitySlotsDocId = entityId + "#" + parts[1];

        final DocumentReference entitySlotsRef =
            fStore.doc('slots/' + entitySlotsDocId);

        DocumentSnapshot doc = await tx.get(entitySlotsRef);

        Map<String, dynamic> map = doc.data();

        EntitySlots es = EntitySlots.fromJson(map);
        for (Slot sl in es.slots) {
          if (sl.slotId == slotId) {
            sl.maxAllowed++;
            sl.totalCancelled++;
            sl.isFull = false;
            break;
          }
        }

        String tokenCounterId =
            TOKEN_COUNTER_PREFIX + "#" + entityId + "#" + year;

        final DocumentReference tokenCounterRef =
            fStore.doc('counter/' + tokenCounterId);

        DocumentSnapshot tokenCounterSnapshot = await tx.get(tokenCounterRef);

        if (tokenCounterSnapshot.exists) {
          Map<String, dynamic> map = tokenCounterSnapshot.data();
          tokenCounter = TokenCounter.fromJson(map);
        } else {
          tokenCounter = new TokenCounter(entityId: entityId, year: year);
          tokenCounter.slotWiseStats = new Map<String, TokenStats>();
        }

        //update the TokenCounter, check the key year~month~day#slot-time
        String key = yearMonthDay + "#" + hourMinute;
        if (!tokenCounter.slotWiseStats.containsKey(key)) {
          tokenCounter.slotWiseStats[key] = TokenStats();
        }
        tokenCounter.slotWiseStats[key].numberOfTokensCancelled =
            tokenCounter.slotWiseStats[key].numberOfTokensCancelled + 1;

        //update slot object with the new state of token
        Slot slot;
        int count;
        for (Slot sl in es.slots) {
          count = -1;
          for (UserTokens uts in sl.tokens) {
            count++;
            if (uts.getTokenId() == tokens.getTokenId()) {
              slot = sl;
              break;
            }
          }
          if (slot != null) {
            break;
          }
        }

        if (slot != null && count > -1) {
          slot.tokens[count] = tokens;
        }

        //create/update the TokenCounter
        tx.set(tokenCounterRef, tokenCounter.toJson());

        //update the token with number as -1
        tx.set(tokRef, tokens.toJson());

        //change the max allowed by 1, if a token is cancelled
        tx.set(entitySlotsRef, es.toJson());

        return new Tuple(item1: tokenCancelled, item2: tokenCounter);
      } else {
        throw new NoTokenFoundException("Token does not exists");
      }
    } catch (ex) {
      print(
          "Error while canceling token -> Transactio Error: " + ex.toString());
      isCancelled = false;
      throw ex;
    }

    return null;
  }

  Future<Tuple<UserToken, TokenCounter>> cancelToken(String tokenId,
      [int number]) async {
    //number param is optional, only required when multiple tokens are booked by the user for the same slot
    //get the token, mark it cancelled
    //get the slot from the token
    //increase the slot maxallowed by one

    User user = getFirebaseAuth().currentUser;
    String userPhone = user.phoneNumber;
    FirebaseFirestore fStore = getFirestore();

    Tuple<UserToken, TokenCounter> tuple;

    await fStore.runTransaction((Transaction tx) async {
      tuple = await cancelTokenInTransaction(tx, userPhone, tokenId, number);
    });

    return tuple;
  }

  Future<List<UserToken>> getAllTokensForSlot(String slotId) async {
    List<UserToken> userTokens = [];
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
    List<UserTokens> tokens = [];
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
      throw e;
    }

    return tokens;
  }

  Future<List<UserTokens>> getTokensForEntityBookedByCurrentUser(
      String entityId, DateTime date) async {
    List<UserTokens> tokens = [];
    User user = getFirebaseAuth().currentUser;
    FirebaseFirestore fStore = getFirestore();

    try {
      Query q = fStore
          .collection('tokens')
          .where("userId", isEqualTo: user.phoneNumber)
          .where("entityId", isEqualTo: entityId);
      if (date != null) {
        DateTime inputDate = new DateTime(date.year, date.month, date.day);
        DateTime nextDay = inputDate.add(new Duration(days: 1));
        q = q
            .where("dateTime",
                isGreaterThanOrEqualTo: date.millisecondsSinceEpoch)
            .where("dateTime", isLessThan: nextDay.millisecondsSinceEpoch);
      }

      QuerySnapshot qs = await q.get();

      for (DocumentSnapshot ds in qs.docs) {
        UserTokens tok = UserTokens.fromJson(ds.data());
        tokens.add(tok);
      }
    } catch (e) {
      print("Error while fetching token: " + e.toString());
    }

    return tokens;
  }

  Future<void> deleteSlotsForEntity(String entityId) async {
    CollectionReference slots = FirebaseFirestore.instance.collection('slots');

    WriteBatch batch = FirebaseFirestore.instance.batch();
    QuerySnapshot qs;
    return slots
        .where('entityId', isEqualTo: entityId)
        .get()
        .then((querySnapshot) {
      querySnapshot.docs.forEach((document) {
        batch.delete(document.reference);
      });

      return batch.commit();
    });
  }

  Future<void> deleteTokensForEntity(String entityId) async {
    CollectionReference slots = FirebaseFirestore.instance.collection('tokens');

    WriteBatch batch = FirebaseFirestore.instance.batch();
    QuerySnapshot qs;
    return slots
        .where('entityId', isEqualTo: entityId)
        .get()
        .then((querySnapshot) {
      querySnapshot.docs.forEach((document) {
        batch.delete(document.reference);
      });

      return batch.commit();
    });
  }

  Future<void> deleteTokenCountersForEntity(String entityId) async {
    CollectionReference slots =
        FirebaseFirestore.instance.collection('counter');

    WriteBatch batch = FirebaseFirestore.instance.batch();
    QuerySnapshot qs;
    return slots
        .where('entityId', isEqualTo: entityId)
        .get()
        .then((querySnapshot) {
      querySnapshot.docs.forEach((document) {
        batch.delete(document.reference);
      });

      return batch.commit();
    });
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

  Future<bool> deleteTokenCounter(String entityId, String year) async {
    //this should be restricted on Server, only to be used for testcases
    FirebaseFirestore fStore = getFirestore();

    String tokenCounterId = TOKEN_COUNTER_PREFIX + "#" + entityId + "#" + year;

    DocumentReference tokRef = fStore.doc('counter/' + tokenCounterId);

    try {
      await tokRef.delete();
    } catch (e) {
      print("Error deleting tokenCounter: " + e.toString());
      return false;
    }

    return true;
  }

  Future<bool> updateToken(UserTokens tokens) async {
    //this should be restricted on Server, only to be used for testcases
    User user = getFirebaseAuth().currentUser;
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
