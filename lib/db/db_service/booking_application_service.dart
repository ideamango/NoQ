import 'package:LESSs/db/db_model/entity_slots.dart';
import 'package:LESSs/db/exceptions/access_denied_exception.dart';
import 'package:LESSs/db/exceptions/application_status_not_allowed.dart';
import 'package:LESSs/db/exceptions/slot_time_null_cant_approve_application_exception.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:enum_to_string/enum_to_string.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/services.dart';
import '../../constants.dart';
import '../../triplet.dart';
import '../db_model/booking_application.dart';
import '../db_model/booking_form.dart';
import '../db_model/meta_entity.dart';
import '../db_model/user_token.dart';
import '../db_service/query.dart';

import '../../enum/application_status.dart';
import '../../global_state.dart';
import '../../utils.dart';

import '../../tuple.dart';

//Applications can be submitted without or with Time Slot
//Show all the Applications for a given timeslot
//Show all the tokens for a given timeslot
//Show all the Applications for a given day or period
//Show all the Applications for a given bookingFormID on day or period
//Given a token, a QR code will be generated which will be used by the Admin to bring up the corresponding Application
//Solution:
//Store issued TokenID, SlotId with the Application object on Approval
//Store ApplicationID and BookingFormID, BookingFormName with the Token object

class BookingApplicationService {
  FirebaseApp? _fb;
  GlobalState? _gs;

  BookingApplicationService(FirebaseApp? firebaseApp, GlobalState? gs) {
    _fb = firebaseApp;
    _gs = gs;
  }

  FirebaseFirestore getFirestore() {
    if (_fb == null) {
      return FirebaseFirestore.instance;
    } else {
      return FirebaseFirestore.instanceFor(app: _fb!);
    }
  }

  FirebaseAuth getFirebaseAuth() {
    if (_fb == null) return FirebaseAuth.instance;
    return FirebaseAuth.instanceFor(app: _fb!);
  }

  Future<BookingApplication?> getApplication(String? applicationId) async {
    FirebaseFirestore fStore = getFirestore();
    if (!Utils.isNotNullOrEmpty(applicationId)) {
      return null;
    }

    //TODO: Security - only the user who has submitted the Application or the Admin/Manager of the Entity should be able to access the application
    BookingApplication? ba;
    try {
      final DocumentReference appRef =
          fStore.doc('bookingApplications/' + applicationId!);

      DocumentSnapshot doc = await appRef.get();

      if (doc.exists) {
        Map<String, dynamic>? map = doc.data() as Map<String, dynamic>?;

        ba = BookingApplication.fromJson(map);
      }
    } catch (e) {
      // if (e.code == "permission-denied") {
      //   throw new AccessDeniedException(
      //       "You do not have permission to view the Application details.");
      // }
    }

    return ba;
  }

  Future<List<Tuple<BookingApplication, DocumentSnapshot>>> getApplications(
      String? bookingFormID,
      String? entityId,
      ApplicationStatus? status,
      String? userId,
      Map<String, dynamic>? singleValueFields,
      List<MultiValuedQuery>? multipleValueFields,
      List<RangeQuery>? rangeQueries,
      String? orderByFieldName,
      bool? isDescending,
      DocumentSnapshot? firstRecord, //for previous page
      DocumentSnapshot? lastRecord, //for next page
      int takeCount) async {
    //TODO: Security - only the Admin/Manager of the Entity should be able to access the applications OR Super admin of the Global BookingForm

    FirebaseFirestore fStore = getFirestore();
    CollectionReference collectionRef =
        fStore.collection('bookingApplications');

    Query query = collectionRef;

    if (Utils.isNotNullOrEmpty(userId)) {
      query = query.where("userId", isEqualTo: userId);
    }

    if (status != null) {
      String statusStr = EnumToString.convertToString(status);
      query = query.where("status", isEqualTo: statusStr);
    }

    if (Utils.isNotNullOrEmpty(entityId)) {
      query = query.where("entityId", isEqualTo: entityId);
    }

    if (Utils.isNotNullOrEmpty(bookingFormID)) {
      query = query.where("bookingFormId", isEqualTo: bookingFormID);
    }

    if (singleValueFields != null) {
      singleValueFields.forEach((key, val) {
        query = query.where(key, isEqualTo: val);
      });
    }

    if (multipleValueFields != null) {
      for (MultiValuedQuery multiValuedQuery in multipleValueFields) {
        if (multiValuedQuery.partialMatch!) {
          query = query.where(multiValuedQuery.key!,
              arrayContainsAny: multiValuedQuery.values);
        } else {
          query = query.where(multiValuedQuery.key!,
              arrayContains: multiValuedQuery.values);
        }
      }
    }

    if (rangeQueries != null) {
      //TODO
    }

    if (Utils.isNotNullOrEmpty(orderByFieldName)) {
      query = query.orderBy(orderByFieldName!, descending: isDescending!);
    }
    //TODO - takeCount coming as null
    if (takeCount > 0) {
      query = query.limit(takeCount);
    }

    if (lastRecord != null) {
      query = query.startAfterDocument(lastRecord);
    } else if (firstRecord != null) {
      query = query.endBeforeDocument(firstRecord);
    }

    List<Tuple<BookingApplication, QueryDocumentSnapshot>> applications = [];

    QuerySnapshot qs = await query.get();
    List<QueryDocumentSnapshot> qds = qs.docs;
    for (QueryDocumentSnapshot doc in qds) {
      if (doc.exists) {
        Tuple<BookingApplication, QueryDocumentSnapshot> tup =
            Tuple<BookingApplication, QueryDocumentSnapshot>(
                item1: BookingApplication.fromJson(
                    doc.data() as Map<String, dynamic>),
                item2: doc);
        applications.add(tup);
        print(tup.item1!.id);
      }
    }

    return applications;
  }

  //To be done by the Applicant
  Future<bool> saveDraftApplication(BookingApplication ba) async {
    //Case 1: Create the BookingApplication object in the Applications collection,
    //if time of submission is empty then the application is in draft state

    return false;
  }

  //To be done by the Applicant
  //Throws => MaxTokenReachedByUserPerSlotException, TokenAlreadyExistsException, SlotFullException, MaxTokenReachedByUserPerDayException
  Future<Triplet<UserToken, TokenCounter, EntitySlots>> submitApplication(
      BookingApplication? ba, MetaEntity? metaEntity,
      [bool? enableVideoChat = false]) async {
    //Security: BookingApplication (Application Status by the applicant can be only Null, New, Cancelled), other statuses are reserved for the Manager/Admin
    //Case 1: Create the BookingApplication object in the Applications collection
    //Case 2: Create if not already created the BookingApplicationsOverview, and update the total counter and new counter
    //Case 3: If BookingForm is Auto Approved then generate the token immediately and set the numberOfApproved in counter by 1

    if (ba == null ||
        !Utils.isNotNullOrEmpty(ba.bookingFormId) ||
        ba.responseForm == null ||
        metaEntity == null) {
      throw Exception("Insufficient arguments to submit the application");
    }

    Exception? e;

    UserToken? tok;

    bool isSuccess = false;
    DateTime now = DateTime.now();

    final User user = getFirebaseAuth().currentUser!;
    FirebaseFirestore fStore = getFirestore();
    String? userPhone = user.phoneNumber;
    BookingForm? bf;
    BookingApplication? baDraft;
    BookingApplicationCounter? localCounter;
    TokenCounter? tokenCounter;
    EntitySlots? es;
    //BookingApplicationCounter globalCounter;

    String bookingApplicationId = ba.id!;
    String bookingFormId = ba.bookingFormId!;
    String localCounterId =
        bookingFormId + "#" + metaEntity.entityId! + "#" + now.year.toString();
    //String globalCounterId = bookingFormId + "#" + now.year.toString();

    final DocumentReference applicationRef =
        fStore.doc('bookingApplications/' + bookingApplicationId);

    final DocumentReference bookingFormRef =
        fStore.doc('bookingForms/' + bookingFormId);

    final DocumentReference localCounterRef =
        fStore.doc('counter/' + localCounterId);

    // final DocumentReference globalCounterRef =
    //     fStore.doc('counter/' + globalCounterId);

    DocumentSnapshot doc = await bookingFormRef.get();

    String dailyStatsKey = now.year.toString() +
        "~" +
        now.month.toString() +
        "~" +
        now.day.toString();

    if (doc.exists) {
      Map<String, dynamic>? map = doc.data() as Map<String, dynamic>?;

      bf = BookingForm.fromJson(map);
    } else {
      return throw new Exception(
          "For this booking application the corresponding Form does not exists"); //no form exists, hence can't proceed
    }

    await fStore.runTransaction((Transaction tx) async {
      try {
        DocumentSnapshot applicationSnapshot = await tx.get(applicationRef);
        DocumentSnapshot localCounterSnapshot = await tx.get(localCounterRef);

        if (applicationSnapshot.exists) {
          baDraft = BookingApplication.fromJson(
              applicationSnapshot.data() as Map<String, dynamic>);
          if (baDraft!.timeOfSubmission != null) {
            throw new Exception(
                "Application is already submitted, can't submit again.");
          }
        }

        //setting up the mandatory fields on the Application object
        ba.timeOfSubmission = now;
        ba.entityId = metaEntity.entityId;
        ba.entityName = metaEntity.name;
        ba.status = ApplicationStatus.NEW;
        ba.userId = userPhone;

        // if (bf.isSystemTemplate) {
        //   DocumentSnapshot globalCounterSnapshot =
        //       await tx.get(globalCounterRef);
        //   //global counters have to be update or created
        //   if (globalCounterSnapshot.exists) {
        //     Map<String, dynamic> map = globalCounterSnapshot.data();
        //     globalCounter = BookingApplicationCounter.fromJson(map);
        //   } else {
        //     globalCounter = new BookingApplicationCounter(
        //         bookingFormId: bookingFormId, entityId: null);
        //   }

        //   if (globalCounter.dailyStats == null) {
        //     globalCounter.dailyStats = Map<String, ApplicationStats>();
        //   }

        //   if (!globalCounter.dailyStats.containsKey(dailyStatsKey)) {
        //     ApplicationStats todayStats = new ApplicationStats();
        //     globalCounter.dailyStats[dailyStatsKey] = todayStats;
        //   }
        // }

        //local Counter to be updated or created
        if (localCounterSnapshot.exists) {
          Map<String, dynamic>? map =
              localCounterSnapshot.data() as Map<String, dynamic>?;
          localCounter = BookingApplicationCounter.fromJson(map);
        } else {
          localCounter = new BookingApplicationCounter(
              bookingFormId: bookingFormId, entityId: metaEntity.entityId);
        }

        if (localCounter!.dailyStats == null) {
          localCounter!.dailyStats = Map<String, ApplicationStats>();
        }

        if (!localCounter!.dailyStats!.containsKey(dailyStatsKey)) {
          ApplicationStats todayStats = new ApplicationStats();
          localCounter!.dailyStats![dailyStatsKey] = todayStats;
        }

        if (bf!.autoApproved!) {
          // if (globalCounter != null) {
          //   globalCounter.numberOfApproved++;
          //   globalCounter.dailyStats[dailyStatsKey].numberOfNew++;
          //   globalCounter.dailyStats[dailyStatsKey].numberOfApproved++;
          // }

          localCounter!.numberOfApproved = localCounter!.numberOfApproved! + 1;
          localCounter!.dailyStats![dailyStatsKey]!.numberOfNew =
              localCounter!.dailyStats![dailyStatsKey]!.numberOfNew! + 1;
          localCounter!.dailyStats![dailyStatsKey]!.numberOfApproved =
              localCounter!.dailyStats![dailyStatsKey]!.numberOfApproved! + 1;
          ba.approvedBy = SYSTEM;
          ba.notesOnApproval = AUTO_APPROVED;
          ba.status = ApplicationStatus.APPROVED;
          ba.timeOfApproval = now;
        } else {
          // if (globalCounter != null) {
          //   globalCounter.numberOfNew++;
          //   globalCounter.dailyStats[dailyStatsKey].numberOfNew++;
          // }
          localCounter!.numberOfNew = localCounter!.numberOfNew! + 1;
          localCounter!.dailyStats![dailyStatsKey]!.numberOfNew =
              localCounter!.dailyStats![dailyStatsKey]!.numberOfNew! + 1;
        }
        // if (globalCounter != null) {
        //   globalCounter.totalApplications++;
        // }
        localCounter!.totalApplications = localCounter!.totalApplications! + 1;

        //if auto approved, then generate the token
        if (bf.appointmentRequired! &&
            bf.autoApproved! &&
            bf.generateTokenOnApproval!) {
          //generate the token
          Triplet<UserTokens, TokenCounter, EntitySlots> triplet;
          UserTokens? toks;
          try {
            triplet = await _gs!.getTokenService()!.generateTokenInTransaction(
                tx,
                userPhone!,
                metaEntity,
                ba.preferredSlotTiming!,
                ba.id,
                ba.bookingFormId,
                ba.responseForm!.formName,
                enableVideoChat);
            toks = triplet.item1;
            tokenCounter = triplet.item2;
            es = triplet.item3;
          } catch (e) {
            throw e;
          }

          UserToken lastTok = toks!.tokens![toks.tokens!.length - 1];
          ba.tokenId = lastTok.getID();

          //HACK: by accessing bookings of GS to add this new Token, so that it apears immediately in users list
          _gs!.bookings!.add(new Tuple<UserToken, DocumentSnapshot>(
              item1: lastTok, item2: null));
          tok = lastTok;
        }

        ba.isOnlineModeOfInteraction = enableVideoChat;
        tx.set(applicationRef, ba.toJson() as Map<String, dynamic>);
        tx.set(localCounterRef, localCounter!.toJson());
        // if (globalCounter != null) {
        //   tx.set(globalCounterRef, globalCounter.toJson());
        // }

        isSuccess = true;
      } on PlatformException catch (pe) {
        if (pe.code == "permission-denied") {
          e = new AccessDeniedException(
              "You do not have permission to create the Application.");
        } else {
          e = pe;
        }
      } catch (ex) {
        print("Exception in Application submission $bookingApplicationId " +
            e.toString());

        e = ex as Exception;
        isSuccess = false;
      }
    });

    if (e != null) {
      throw e!;
    }

    if (tok != null) {
      //auto generated Token is issued, create a notification
      _gs!.getNotificationService()!.registerTokenNotification(tok!.parent!);
    }
    return new Triplet(item1: tok, item2: tokenCounter, item3: es);
  }

  //to be done by the Applicant
  //Throws => TokenAlreadyCancelledException, NoTokenFoundException
  Future<Triplet<UserToken, TokenCounter, EntitySlots>> withDrawApplication(
      String applicationId, String notesOnCancellation) async {
    //set the BookingApplication status as cancelled
    //If the token is approved, cancel the token also
    if (!Utils.isNotNullOrEmpty(applicationId)) {
      throw Exception("Insufficient arguements to submit the application");
    }

    bool isSuccess = false;
    DateTime now = DateTime.now();

    final User user = getFirebaseAuth().currentUser!;
    FirebaseFirestore fStore = getFirestore();
    String? userPhone = user.phoneNumber;
    Exception? e;
    UserTokens? cancelledTokens;
    UserToken? cancelledTok;
    TokenCounter? tokenCounter;

    BookingApplication? ba;

    BookingApplicationCounter? localCounter;
    //BookingApplicationCounter globalCounter;

    String bookingApplicationId = applicationId;

    final DocumentReference applicationRef =
        fStore.doc('bookingApplications/' + bookingApplicationId);

    Triplet<UserToken, TokenCounter, EntitySlots>? triplet;

    // final DocumentReference bookingFormRef =
    //     fStore.doc('bookingForms/' + bookingFormId);
    // DocumentSnapshot doc = await bookingFormRef.get();

    String dailyStatsKey = now.year.toString() +
        "~" +
        now.month.toString() +
        "~" +
        now.day.toString();

    await fStore.runTransaction((Transaction tx) async {
      try {
        DocumentSnapshot applicationSnapshot = await tx.get(applicationRef);

        if (applicationSnapshot.exists) {
          ba = BookingApplication.fromJson(
              applicationSnapshot.data() as Map<String, dynamic>);
        } else {
          throw new Exception(
              "Application does not exists, it can't be cancelled");
        }

        ApplicationStatus? existingStatus = ba!.status;

        String bookingFormId = ba!.bookingFormId!;

        String localCounterId =
            bookingFormId + "#" + ba!.entityId! + "#" + now.year.toString();
        //String globalCounterId = bookingFormId + "#" + now.year.toString();

        final DocumentReference localCounterRef =
            fStore.doc('counter/' + localCounterId);
        DocumentSnapshot localCounterSnapshot = await tx.get(localCounterRef);

        // final DocumentReference globalCounterRef =
        //     fStore.doc('counter/' + globalCounterId);

        ba!.status = ApplicationStatus.CANCELLED;
        ba!.timeOfCancellation = DateTime.now();
        ba!.notesOnCancellation = notesOnCancellation;

        if (ba!.responseForm!.isSystemTemplate!) {
          // DocumentSnapshot globalCounterSnapshot =
          //     await tx.get(globalCounterRef);
          //global counters have to be update or created
          // if (globalCounterSnapshot.exists) {
          //   Map<String, dynamic> map = globalCounterSnapshot.data();
          //   globalCounter = BookingApplicationCounter.fromJson(map);
          // } else {
          //   globalCounter = new BookingApplicationCounter(
          //       bookingFormId: bookingFormId, entityId: null);
          // }

          // if (globalCounter.dailyStats == null) {
          //   globalCounter.dailyStats = Map<String, ApplicationStats>();
          // }

          // if (!globalCounter.dailyStats.containsKey(dailyStatsKey)) {
          //   ApplicationStats todayStats = new ApplicationStats();
          //   globalCounter.dailyStats[dailyStatsKey] = todayStats;
          // }
        }

        //local Counter to be updated or created
        if (localCounterSnapshot.exists) {
          Map<String, dynamic>? map =
              localCounterSnapshot.data() as Map<String, dynamic>;
          localCounter = BookingApplicationCounter.fromJson(map);
        } else {
          localCounter = new BookingApplicationCounter(
              bookingFormId: bookingFormId, entityId: ba!.entityId);
        }

        if (localCounter!.dailyStats == null) {
          localCounter!.dailyStats = Map<String, ApplicationStats>();
        }

        if (!localCounter!.dailyStats!.containsKey(dailyStatsKey)) {
          ApplicationStats todayStats = new ApplicationStats();
          localCounter!.dailyStats![dailyStatsKey] = todayStats;
        }

        // if (globalCounter != null) {
        //   globalCounter.numberOfCancelled++;
        //   globalCounter.dailyStats[dailyStatsKey].numberOfCancelled++;
        // }
        localCounter!.numberOfCancelled = localCounter!.numberOfCancelled! + 1;
        localCounter!.dailyStats![dailyStatsKey]!.numberOfCancelled =
            localCounter!.dailyStats![dailyStatsKey]!.numberOfCancelled! + 1;

        //token id should be stored as part of the application
        if (Utils.isNotNullOrEmpty(ba!.tokenId)) {
          //token id format - Selenium-Covid-Vacination-Center#2021~2~17#10~30#9898989899#2

          Tuple<String, int> tokenIdSplitted =
              Utils.getTokenIdWithoutNumber(ba!.tokenId!);
          String tokenIdWithoutNumber = tokenIdSplitted.item1!;
          int? tokenNumber = tokenIdSplitted.item2;

          //cancel the token
          triplet = await _gs!.getTokenService()!.cancelTokenInTransaction(
              tx, userPhone, tokenIdWithoutNumber, tokenNumber);
          cancelledTok = triplet!.item1;
          tokenCounter = triplet!.item2;
          cancelledTokens = cancelledTok!.parent;

          //update the GlobalState bookings collection with the cancelled token
          // int index = -1;
          // bool matched = false;

          // if (_gs.bookings != null) {
          //   for (Tuple<UserToken, DocumentSnapshot> ut in _gs.bookings) {
          //     index++;
          //     for (UserToken cut in cancelledTokens.tokens) {
          //       if (ut.item1.getID() == cut.getID() &&
          //           tokenNumber == cut.numberBeforeCancellation) {
          //         matched = true;
          //         cancelledTok = cut;
          //         break;
          //       }
          //     }
          //     if (matched) {
          //       break;
          //     }
          //   }

          //   if (index > -1 && cancelledTok != null) {
          //     _gs.bookings[index] = new Tuple<UserToken, DocumentSnapshot>(
          //         item1: cancelledTok, item2: null);
          //   }
          // }
        }

        if (existingStatus == ApplicationStatus.APPROVED) {
          // if (globalCounter != null) {
          //   globalCounter.numberOfApproved--;
          // }
          if (localCounter != null) {
            localCounter!.numberOfApproved =
                localCounter!.numberOfApproved! - 1;
          }
        } else if (existingStatus == ApplicationStatus.NEW) {
          // if (globalCounter != null) {
          //   globalCounter.numberOfNew--;
          // }
          if (localCounter != null) {
            localCounter!.numberOfNew = localCounter!.numberOfNew! - 1;
          }
        } else if (existingStatus == ApplicationStatus.COMPLETED) {
          // if (globalCounter != null) {
          //   globalCounter.numberOfCompleted--;
          // }
          if (localCounter != null) {
            localCounter!.numberOfCompleted =
                localCounter!.numberOfCompleted! - 1;
          }
        } else if (existingStatus == ApplicationStatus.INPROCESS) {
          // if (globalCounter != null) {
          //   globalCounter.numberOfInProcess--;
          // }
          if (localCounter != null) {
            localCounter!.numberOfInProcess =
                localCounter!.numberOfInProcess! - 1;
          }
        } else if (existingStatus == ApplicationStatus.ONHOLD) {
          // if (globalCounter != null) {
          //   globalCounter.numberOfPutOnHold--;
          // }
          if (localCounter != null) {
            localCounter!.numberOfPutOnHold =
                localCounter!.numberOfPutOnHold! - 1;
          }
        } else if (existingStatus == ApplicationStatus.REJECTED) {
          // if (globalCounter != null) {
          //   globalCounter.numberOfRejected--;
          // }
          if (localCounter != null) {
            localCounter!.numberOfRejected =
                localCounter!.numberOfRejected! - 1;
          }
        }

        tx.set(applicationRef, ba!.toJson() as Map<String, dynamic>);
        tx.set(localCounterRef, localCounter!.toJson());
        // if (globalCounter != null) {
        //   tx.set(globalCounterRef, globalCounter.toJson());
        // }

        isSuccess = true;
      } on PlatformException catch (pe) {
        if (pe.code == "permission-denied") {
          e = new AccessDeniedException(
              "You do not have permission to cancel the Application.");
        } else {
          e = pe;
        }
      } catch (ex) {
        print("Exception in Application submission $bookingApplicationId " +
            ex.toString());
        isSuccess = false;
        e = ex as Exception;
      }
    });

    if (e != null) {
      throw e!;
    }

    // if (isSuccess && cancelledTokens != null && cancelledTok != null) {
    //   _gs.getNotificationService().unRegisterTokenNotification(cancelledTok);
    // }
    return new Triplet<UserToken, TokenCounter, EntitySlots>(
        item1: cancelledTok, item2: tokenCounter, item3: triplet!.item3);
  }

  //To be called by Manager of the Entity who has restricted rights or by the Admin
  //Throws: SlotTimeNotDefinedCantApproveException, ApplicationStatusNotAllowed, TokenAlreadyExistsException
  //MaxTokenReachedByUserPerSlotException, SlotFullException, MaxTokenReachedByUserPerDayException,
  Future<Triplet<BookingApplication, TokenCounter, EntitySlots>>
      updateApplicationStatus(String applicationId, ApplicationStatus status,
          String note, MetaEntity? metaEntity, DateTime? tokenTime,
          [bool enableVideoChat = false]) async {
    //TODO Security: Application Status, Time of Respective Status Change and Status can only be updated by the Entity Manager/Entity Admin
    //TODO Security: Once submitted for review, the Application can't be edited by the Applicant
    //TODO Security: Application can be only accessed and Updated by Entity Manager/Admin
    if (status == ApplicationStatus.NEW ||
        status == ApplicationStatus.CANCELLED) {
      throw new ApplicationStatusNotAllowed(
          "Invalid Application Status for Admin/Manager");
    }

    if (status == ApplicationStatus.APPROVED &&
        (metaEntity == null || tokenTime == null)) {
      throw new SlotTimeNotDefinedCantApproveException(
          "Entity and Time are required for the Token generation on Approval");
    }
    //For testing
    //if (applicationId != null) return false;
    //For testing
    Exception? e;
    DateTime now = DateTime.now();

    final User user = getFirebaseAuth().currentUser!;
    FirebaseFirestore fStore = getFirestore();
    String? userPhone = user.phoneNumber;
    String? requestingUser;
    BookingForm? bf;
    BookingApplication? application;
    BookingApplicationCounter? localCounter;
    //BookingApplicationCounter globalCounter;
    ApplicationStatus? existingStatus;
    UserTokens? cancelledTokens;
    UserToken? cancelledToken;

    String localCounterId;
    //String globalCounterId;
    bool requestProcessed = false;
    TokenCounter? tokenCounter;
    EntitySlots? es;

    String dailyStatsKey = now.year.toString() +
        "~" +
        now.month.toString() +
        "~" +
        now.day.toString();

    final DocumentReference applicationRef =
        fStore.doc('bookingApplications/' + applicationId);

    await fStore.runTransaction((Transaction tx) async {
      try {
        DocumentSnapshot applicationSnapshot = await tx.get(applicationRef);

        if (applicationSnapshot.exists) {
          application = BookingApplication.fromJson(
              applicationSnapshot.data() as Map<String, dynamic>);
          existingStatus = application!.status;
          bf = application!.responseForm;
          if (application!.timeOfSubmission == null ||
              application!.status == ApplicationStatus.CANCELLED ||
              application!.status == status) {
            throw new Exception(
                "Application is not submitted yet or it's in the cancelled state or same status is sent again");
          }
        } else {
          throw new Exception("Application does not exist");
        }

        String entityId = application!.entityId!;
        String bookingFormId = application!.bookingFormId!;
        requestingUser = application!.userId;

        localCounterId =
            bookingFormId + "#" + entityId + "#" + now.year.toString();
        //globalCounterId = bookingFormId + "#" + now.year.toString();

        final DocumentReference localCounterRef =
            fStore.doc('counter/' + localCounterId);

        // final DocumentReference globalCounterRef =
        //     fStore.doc('counter/' + globalCounterId);

        DocumentSnapshot localCounterSnapshot = await tx.get(localCounterRef);

        // if (bf.isSystemTemplate) {
        //   DocumentSnapshot globalCounterSnapshot =
        //       await tx.get(globalCounterRef);
        //   //global counters have to be update or created
        //   if (globalCounterSnapshot.exists) {
        //     Map<String, dynamic> map = globalCounterSnapshot.data();
        //     globalCounter = BookingApplicationCounter.fromJson(map);
        //   }
        // }

        //local Counter to be updated or created
        if (localCounterSnapshot.exists) {
          Map<String, dynamic>? map =
              localCounterSnapshot.data() as Map<String, dynamic>;
          localCounter = BookingApplicationCounter.fromJson(map);
        }

        //setting up the mandatory fields on the Application object
        if (status == ApplicationStatus.APPROVED) {
          application!.timeOfApproval = now;
          application!.notesOnApproval = note;
          application!.approvedBy = userPhone;
          // if (globalCounter != null) {
          //   globalCounter.numberOfApproved++;
          //   if (globalCounter.dailyStats.containsKey(dailyStatsKey)) {
          //     globalCounter.dailyStats[dailyStatsKey].numberOfApproved++;
          //   } else {
          //     ApplicationStats todayStats = new ApplicationStats();
          //     globalCounter.dailyStats[dailyStatsKey] = todayStats;
          //     globalCounter.dailyStats[dailyStatsKey].numberOfApproved++;
          //   }
          // }
          if (localCounter != null) {
            localCounter!.numberOfApproved =
                localCounter!.numberOfApproved! + 1;
            if (localCounter!.dailyStats!.containsKey(dailyStatsKey)) {
              localCounter!.dailyStats![dailyStatsKey]!.numberOfApproved =
                  localCounter!.dailyStats![dailyStatsKey]!.numberOfApproved! +
                      1;
            } else {
              ApplicationStats todayStats = new ApplicationStats();
              localCounter!.dailyStats![dailyStatsKey] = todayStats;
              localCounter!.dailyStats![dailyStatsKey]!.numberOfApproved =
                  localCounter!.dailyStats![dailyStatsKey]!.numberOfApproved! +
                      1;
            }
          }

          //TODO: generate the token and send the notification to the applicant
          //generate the token
          //send notification
          UserTokens? toks;
          Triplet<UserTokens, TokenCounter, EntitySlots> triplet;
          if (bf!.generateTokenOnApproval! && bf!.appointmentRequired!) {
            try {
              triplet = await _gs!
                  .getTokenService()!
                  .generateTokenInTransaction(
                      tx,
                      requestingUser!,
                      metaEntity!,
                      tokenTime!,
                      application!.id,
                      application!.bookingFormId,
                      application!.responseForm!.formName,
                      enableVideoChat);
              toks = triplet.item1;
              tokenCounter = triplet.item2;
              es = triplet.item3;
            } catch (e) {
              throw e;
            }

            UserToken lastTok = toks!.tokens![toks.tokens!.length - 1];
            application!.tokenId = lastTok.getID();
          }
        } else if (status == ApplicationStatus.COMPLETED) {
          application!.timeOfCompletion = now;
          application!.notesOnCompletion = note;
          application!.completedBy = userPhone;
          // if (globalCounter != null) {
          //   globalCounter.numberOfCompleted++;
          //   if (globalCounter.dailyStats.containsKey(dailyStatsKey)) {
          //     globalCounter.dailyStats[dailyStatsKey].numberOfCompleted++;
          //   } else {
          //     ApplicationStats todayStats = new ApplicationStats();
          //     globalCounter.dailyStats[dailyStatsKey] = todayStats;
          //     globalCounter.dailyStats[dailyStatsKey].numberOfCompleted++;
          //   }
          // }
          if (localCounter != null) {
            localCounter!.numberOfCompleted =
                localCounter!.numberOfCompleted! + 1;
            if (localCounter!.dailyStats!.containsKey(dailyStatsKey)) {
              localCounter!.dailyStats![dailyStatsKey]!.numberOfCompleted =
                  localCounter!.dailyStats![dailyStatsKey]!.numberOfCompleted! +
                      1;
            } else {
              ApplicationStats todayStats = new ApplicationStats();
              localCounter!.dailyStats![dailyStatsKey] = todayStats;
              localCounter!.dailyStats![dailyStatsKey]!.numberOfCompleted =
                  localCounter!.dailyStats![dailyStatsKey]!.numberOfCompleted! +
                      1;
            }
          }
        } else if (status == ApplicationStatus.INPROCESS) {
          application!.timeOfInProcess = now;
          application!.notesInProcess = note;
          application!.processedBy = userPhone;
          // if (globalCounter != null) {
          //   globalCounter.numberOfInProcess++;
          //   if (globalCounter.dailyStats.containsKey(dailyStatsKey)) {
          //     globalCounter.dailyStats[dailyStatsKey].numberOfInProcess++;
          //   } else {
          //     ApplicationStats todayStats = new ApplicationStats();
          //     globalCounter.dailyStats[dailyStatsKey] = todayStats;
          //     globalCounter.dailyStats[dailyStatsKey].numberOfInProcess++;
          //   }
          // }
          if (localCounter != null) {
            localCounter!.numberOfInProcess =
                localCounter!.numberOfInProcess! + 1;
            if (localCounter!.dailyStats!.containsKey(dailyStatsKey)) {
              localCounter!.dailyStats![dailyStatsKey]!.numberOfInProcess =
                  localCounter!.dailyStats![dailyStatsKey]!.numberOfInProcess! +
                      1;
            } else {
              ApplicationStats todayStats = new ApplicationStats();
              localCounter!.dailyStats![dailyStatsKey] = todayStats;
              localCounter!.dailyStats![dailyStatsKey]!.numberOfInProcess =
                  localCounter!.dailyStats![dailyStatsKey]!.numberOfInProcess! +
                      1;
            }
          }
        } else if (status == ApplicationStatus.ONHOLD) {
          application!.timeOfPuttingOnHold = now;
          application!.notesOnPuttingOnHold = note;
          application!.putOnHoldBy = userPhone;
          // if (globalCounter != null) {
          //   globalCounter.numberOfPutOnHold++;
          //   if (globalCounter.dailyStats.containsKey(dailyStatsKey)) {
          //     globalCounter.dailyStats[dailyStatsKey].numberOfPutOnHold++;
          //   } else {
          //     ApplicationStats todayStats = new ApplicationStats();
          //     globalCounter.dailyStats[dailyStatsKey] = todayStats;
          //     globalCounter.dailyStats[dailyStatsKey].numberOfPutOnHold++;
          //   }
          // }
          if (application!.tokenId != null &&
              existingStatus == ApplicationStatus.APPROVED) {
            //this means that the application was approved earlier (auto or by admin),
            //but now has been put on hold, resulting into the cancellation of the token

            //If the Status was OnHold or Rejected or Cancelled, the token would not be present or it will already be cancelled
            //If the status is Completed, there is no point of cancelling the Token
            //if the Application is new, the Token hasn't been generated yet
            Tuple<String, int> tokenIdSplitted =
                Utils.getTokenIdWithoutNumber(application!.tokenId!);
            String tokenIdWithoutNumber = tokenIdSplitted.item1!;
            int? tokenNumber = tokenIdSplitted.item2;
            Triplet<UserToken, TokenCounter, EntitySlots>? triplet;
            triplet = await _gs!.getTokenService()!.cancelTokenInTransaction(
                tx, userPhone, tokenIdWithoutNumber, tokenNumber);
            cancelledToken = triplet!.item1;
            tokenCounter = triplet.item2;
            cancelledTokens = cancelledToken!.parent;
            es = triplet.item3;
          }

          if (localCounter != null) {
            localCounter!.numberOfPutOnHold =
                localCounter!.numberOfPutOnHold! + 1;
            if (localCounter!.dailyStats!.containsKey(dailyStatsKey)) {
              localCounter!.dailyStats![dailyStatsKey]!.numberOfPutOnHold =
                  localCounter!.dailyStats![dailyStatsKey]!.numberOfPutOnHold! +
                      1;
            } else {
              ApplicationStats todayStats = new ApplicationStats();
              localCounter!.dailyStats![dailyStatsKey] = todayStats;
              localCounter!.dailyStats![dailyStatsKey]!.numberOfPutOnHold =
                  localCounter!.dailyStats![dailyStatsKey]!.numberOfPutOnHold! +
                      1;
            }
          }
        } else if (status == ApplicationStatus.REJECTED) {
          application!.timeOfRejection = now;
          application!.notesOnRejection = note;
          application!.rejectedBy = userPhone;
          // if (globalCounter != null) {
          //   globalCounter.numberOfRejected++;
          //   if (globalCounter.dailyStats.containsKey(dailyStatsKey)) {
          //     globalCounter.dailyStats[dailyStatsKey].numberOfRejected++;
          //   } else {
          //     ApplicationStats todayStats = new ApplicationStats();
          //     globalCounter.dailyStats[dailyStatsKey] = todayStats;
          //     globalCounter.dailyStats[dailyStatsKey].numberOfRejected++;
          //   }
          // }

          if (application!.tokenId != null &&
              existingStatus == ApplicationStatus.APPROVED) {
            Tuple<String, int> tokenIdSplitted =
                Utils.getTokenIdWithoutNumber(application!.tokenId!);
            String tokenIdWithoutNumber = tokenIdSplitted.item1!;
            int? tokenNumber = tokenIdSplitted.item2;
            Triplet<UserToken, TokenCounter, EntitySlots>? triplet;
            triplet = await _gs!.getTokenService()!.cancelTokenInTransaction(
                tx, userPhone, tokenIdWithoutNumber, tokenNumber);
            cancelledToken = triplet!.item1;
            tokenCounter = triplet.item2;
            es = triplet.item3;
            cancelledTokens = cancelledToken!.parent;
          }

          if (localCounter != null) {
            localCounter!.numberOfRejected =
                localCounter!.numberOfRejected! + 1;
            if (localCounter!.dailyStats!.containsKey(dailyStatsKey)) {
              localCounter!.dailyStats![dailyStatsKey]!.numberOfRejected =
                  localCounter!.dailyStats![dailyStatsKey]!.numberOfRejected! +
                      1;
            } else {
              ApplicationStats todayStats = new ApplicationStats();
              localCounter!.dailyStats![dailyStatsKey] = todayStats;
              localCounter!.dailyStats![dailyStatsKey]!.numberOfRejected =
                  localCounter!.dailyStats![dailyStatsKey]!.numberOfRejected! +
                      1;
            }
          }
        }

        if (existingStatus == ApplicationStatus.APPROVED) {
          // if (globalCounter != null) {
          //   globalCounter.numberOfApproved--;
          // }
          if (localCounter != null) {
            localCounter!.numberOfApproved =
                localCounter!.numberOfApproved! - 1;
          }
        } else if (existingStatus == ApplicationStatus.NEW) {
          // if (globalCounter != null) {
          //   globalCounter.numberOfNew--;
          // }
          if (localCounter != null) {
            localCounter!.numberOfNew = localCounter!.numberOfNew! - 1;
          }
        } else if (existingStatus == ApplicationStatus.COMPLETED) {
          // if (globalCounter != null) {
          //   globalCounter.numberOfCompleted--;
          // }
          if (localCounter != null) {
            localCounter!.numberOfCompleted =
                localCounter!.numberOfCompleted! - 1;
          }
        } else if (existingStatus == ApplicationStatus.INPROCESS) {
          // if (globalCounter != null) {
          //   globalCounter.numberOfInProcess--;
          // }
          if (localCounter != null) {
            localCounter!.numberOfInProcess =
                localCounter!.numberOfInProcess! - 1;
          }
        } else if (existingStatus == ApplicationStatus.ONHOLD) {
          // if (globalCounter != null) {
          //   globalCounter.numberOfPutOnHold--;
          // }
          if (localCounter != null) {
            localCounter!.numberOfPutOnHold =
                localCounter!.numberOfPutOnHold! - 1;
          }
        } else if (existingStatus == ApplicationStatus.REJECTED) {
          // if (globalCounter != null) {
          //   globalCounter.numberOfRejected--;
          // }
          if (localCounter != null) {
            localCounter!.numberOfRejected =
                localCounter!.numberOfRejected! - 1;
          }
        }

        application!.status = status;

        tx.set(applicationRef, application!.toJson() as Map<String, dynamic>);
        tx.set(localCounterRef, localCounter!.toJson());
        // if (globalCounter != null) {
        //   tx.set(globalCounterRef, globalCounter.toJson());
        // }

        requestProcessed = true;
      } on PlatformException catch (pe) {
        if (pe.code == "permission-denied") {
          e = new AccessDeniedException(
              "You do not have permission to update the Application.");
        } else {
          e = pe;
        }
      } catch (ex) {
        requestProcessed = false;
        print(ex.toString());
        e = ex as Exception;
      }
    });

    if (e != null) {
      throw e!;
    }

    return new Triplet<BookingApplication, TokenCounter, EntitySlots>(
        item1: application, item2: tokenCounter, item3: es);
  }

  Future<BookingApplicationCounter?> getApplicationsOverview(
      String? bookingFormId, String? entityId, int year) async {
    //entityId is optional param, assuming that bookingForm is Global Form/System form
    //if entityId is present, that means the counter is local to the Entity

    if (!Utils.isNotNullOrEmpty(bookingFormId)) {
      throw new Exception("FormId can't be null");
    }

    if (year == null) {
      throw new Exception("Year can't be null");
    }

    FirebaseFirestore fStore = getFirestore();
    BookingApplicationCounter? counter;

    final DocumentReference counterRef = fStore.doc('counter/' +
        (Utils.isNotNullOrEmpty(entityId)
            ? bookingFormId! + "#" + entityId! + "#" + year.toString()
            : bookingFormId! + "#" + year.toString()));

    DocumentSnapshot doc = await counterRef.get();

    if (doc.exists) {
      Map<String, dynamic>? map = doc.data() as Map<String, dynamic>;
      counter = BookingApplicationCounter.fromJson(map);
    } else {
      counter = BookingApplicationCounter(
          bookingFormId: bookingFormId, entityId: entityId);
      counter.id = null;
    }

    return counter;
  }

  Future<bool> saveBookingForm(BookingForm bf) async {
    FirebaseFirestore fStore = getFirestore();

    final DocumentReference formRef = fStore.doc('bookingForms/' + bf.id!);

    DocumentSnapshot doc = await formRef.get();
    BookingForm? form;
    if (doc.exists) {
      Map<String, dynamic>? map = doc.data() as Map<String, dynamic>;

      form = BookingForm.fromJson(map);
    }

    //TODO: Only the Entity Admin can update BookingForm, if it is associated with an Entity and not a System Template
    //TODO: Global booking form and system template will be only edited from Backend, define the security Rule on it

    form = bf;

    formRef.set(form.toJson());

    return true;
  }

  Future<BookingForm?> getBookingForm(String formId) async {
    FirebaseFirestore fStore = getFirestore();
    BookingForm? form;

    final DocumentReference formRef = fStore.doc('bookingForms/' + formId);

    try {
      DocumentSnapshot doc = await formRef.get();

      if (doc.exists) {
        Map<String, dynamic>? map = doc.data() as Map<String, dynamic>;
        form = BookingForm.fromJson(map);
      }
    } catch (e) {
      print(e.toString());
    }

    return form;
  }

  Future<bool> deleteCounter(String counterId) async {
    FirebaseFirestore fStore = getFirestore();

    final DocumentReference counterRef = fStore.doc('counter/' + counterId);

    try {
      counterRef.delete();
    } catch (e) {
      return false;
    }
    return true;
  }

  Future<void> deleteApplicationsForEntity(String entityId) async {
    CollectionReference slots =
        FirebaseFirestore.instance.collection('bookingApplications');

    WriteBatch batch = FirebaseFirestore.instance.batch();
    QuerySnapshot qs;
    int count = 0;
    return slots
        .where('entityId', isEqualTo: entityId)
        .get()
        .then((querySnapshot) {
      querySnapshot.docs.forEach((document) {
        count++;
        batch.delete(document.reference);
      });

      if (count > 0) {
        return batch.commit();
      }
    });
  }

  Future<bool> deleteBookingForm(String formId) async {
    FirebaseFirestore fStore = getFirestore();

    final DocumentReference formRef = fStore.doc('bookingForms/' + formId);

    try {
      formRef.delete();
    } catch (e) {
      return false;
    }
    return true;
  }

  Future<bool> deleteApplication(String applicationId) async {
    FirebaseFirestore fStore = getFirestore();

    final DocumentReference applicationRef =
        fStore.doc('bookingApplications/' + applicationId);

    try {
      applicationRef.delete();
    } catch (e) {
      return false;
    }
    return true;
  }
}
