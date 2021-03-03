import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:enum_to_string/enum_to_string.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:noq/constants.dart';
import 'package:noq/db/db_model/booking_application.dart';
import 'package:noq/db/db_model/booking_application.dart';
import 'package:noq/db/db_model/booking_application.dart';
import 'package:noq/db/db_model/booking_form.dart';
import 'package:noq/db/db_model/meta_entity.dart';
import 'package:noq/db/db_model/user_token.dart';
import 'package:noq/db/db_service/query.dart';

import 'package:noq/enum/application_status.dart';
import 'package:noq/enum/entity_type.dart';
import 'package:noq/global_state.dart';
import 'package:noq/utils.dart';

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
  FirebaseApp _fb;
  GlobalState _gs;

  BookingApplicationService(FirebaseApp firebaseApp, GlobalState gs) {
    _fb = firebaseApp;
    _gs = gs;
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

  Future<BookingApplication> getApplication(String applicationId) async {
    FirebaseFirestore fStore = getFirestore();

    //TODO: Security - only the user who has submitted the Application or the Admin/Manager of the Entity should be able to access the application

    final DocumentReference appRef =
        fStore.doc('bookingApplications/' + applicationId);

    BookingApplication ba;

    DocumentSnapshot doc = await appRef.get();

    if (doc.exists) {
      Map<String, dynamic> map = doc.data();

      ba = BookingApplication.fromJson(map);
    }

    return ba;
  }

  Future<List<Tuple<BookingApplication, DocumentSnapshot>>> getApplications(
      String bookingFormID,
      String entityId,
      ApplicationStatus status,
      String userId,
      Map<String, dynamic> singleValueFields,
      List<MultiValuedQuery> multipleValueFields,
      List<RangeQuery> rangeQueries,
      String orderByFieldName,
      bool isDescending,
      DocumentSnapshot firstRecord, //for previous page
      DocumentSnapshot lastRecord, //for next page
      int takeCount) async {
    //TODO: Security - only the Admin/Manager of the Entity should be able to access the applications OR Super admin of the Global BookingForm

    FirebaseFirestore fStore = getFirestore();
    CollectionReference collectionRef =
        fStore.collection('bookingApplications');

    String statusStr = EnumToString.convertToString(status);

    Query query = collectionRef;

    if (Utils.isNotNullOrEmpty(userId)) {
      query = query.where("userId", isEqualTo: userId);
    }

    if (status != null) {
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
        if (multiValuedQuery.partialMatch) {
          query = query.where(multiValuedQuery.key,
              arrayContainsAny: multiValuedQuery.values);
        } else {
          query = query.where(multiValuedQuery.key,
              arrayContains: multiValuedQuery.values);
        }
      }
    }

    if (rangeQueries != null) {
      //TODO
    }

    if (Utils.isNotNullOrEmpty(orderByFieldName)) {
      query = query.orderBy(orderByFieldName, descending: isDescending);
    }

    if (takeCount > 0) {
      query = query.limit(takeCount);
    }

    if (lastRecord != null) {
      query = query.startAfterDocument(lastRecord);
    } else if (firstRecord != null) {
      query = query.endBeforeDocument(firstRecord);
    }

    List<Tuple<BookingApplication, QueryDocumentSnapshot>> applications =
        new List<Tuple<BookingApplication, QueryDocumentSnapshot>>();

    QuerySnapshot qs = await query.get();
    List<QueryDocumentSnapshot> qds = qs.docs;
    for (QueryDocumentSnapshot doc in qds) {
      if (doc.exists) {
        Tuple<BookingApplication, QueryDocumentSnapshot> tup =
            Tuple<BookingApplication, QueryDocumentSnapshot>(
                item1: BookingApplication.fromJson(doc.data()), item2: doc);
        applications.add(tup);
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
  Future<bool> submitApplication(
      BookingApplication ba, MetaEntity metaEntity) async {
    //Security: BookingApplication (Application Status by the applicant can be only Null, New, Cancelled), other statuses are reserved for the Manager/Admin
    //Case 1: Create the BookingApplication object in the Applications collection
    //Case 2: Create if not already created the BookingApplicationsOverview, and update the total counter and new counter
    //Case 3: If BookingForm is Auto Approved then generate the token immediately and set the numberOfApproved in counter by 1

    if (ba == null ||
        !Utils.isNotNullOrEmpty(ba.bookingFormId) ||
        ba.responseForm == null ||
        metaEntity == null) {
      throw Exception("Insufficient arguements to submit the application");
    }

    Exception e;

    bool isSuccess = false;
    DateTime now = DateTime.now();

    final User user = getFirebaseAuth().currentUser;
    FirebaseFirestore fStore = getFirestore();
    String userPhone = user.phoneNumber;
    BookingForm bf;
    BookingApplication baDraft;
    BookingApplicationsOverview localCounter;
    BookingApplicationsOverview globalCounter;

    String bookingApplicationId = ba.id;
    String bookingFormId = ba.bookingFormId;
    String localCounterId =
        bookingFormId + "#" + metaEntity.entityId + "#" + now.year.toString();
    String globalCounterId = bookingFormId + "#" + now.year.toString();

    final DocumentReference applicationRef =
        fStore.doc('bookingApplications/' + bookingApplicationId);

    final DocumentReference bookingFormRef =
        fStore.doc('bookingForms/' + bookingFormId);

    final DocumentReference localCounterRef =
        fStore.doc('counter/' + localCounterId);

    final DocumentReference globalCounterRef =
        fStore.doc('counter/' + globalCounterId);

    DocumentSnapshot doc = await bookingFormRef.get();

    String dailyStatsKey = now.year.toString() +
        "~" +
        now.month.toString() +
        "~" +
        now.day.toString();

    if (doc.exists) {
      Map<String, dynamic> map = doc.data();

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
          baDraft = BookingApplication.fromJson(applicationSnapshot.data());
          if (baDraft.timeOfSubmission != null) {
            throw new Exception(
                "Application is already submitted, can't submit again.");
          }
        }

        //setting up the mandatory fields on the Application object
        ba.timeOfSubmission = now;
        ba.entityId = metaEntity.entityId;
        ba.status = ApplicationStatus.NEW;
        ba.userId = userPhone;

        if (bf.isSystemTemplate) {
          DocumentSnapshot globalCounterSnapshot =
              await tx.get(globalCounterRef);
          //global counters have to be update or created
          if (globalCounterSnapshot.exists) {
            Map<String, dynamic> map = globalCounterSnapshot.data();
            globalCounter = BookingApplicationsOverview.fromJson(map);
          } else {
            globalCounter = new BookingApplicationsOverview(
                bookingFormId: bookingFormId, entityId: null);
          }

          if (globalCounter.dailyStats == null) {
            globalCounter.dailyStats = Map<String, Stats>();
          }

          if (!globalCounter.dailyStats.containsKey(dailyStatsKey)) {
            Stats todayStats = new Stats();
            globalCounter.dailyStats[dailyStatsKey] = todayStats;
          }
        }

        //local Counter to be updated or created
        if (localCounterSnapshot.exists) {
          Map<String, dynamic> map = localCounterSnapshot.data();
          localCounter = BookingApplicationsOverview.fromJson(map);
        } else {
          localCounter = new BookingApplicationsOverview(
              bookingFormId: bookingFormId, entityId: metaEntity.entityId);
        }

        if (localCounter.dailyStats == null) {
          localCounter.dailyStats = Map<String, Stats>();
        }

        if (!localCounter.dailyStats.containsKey(dailyStatsKey)) {
          Stats todayStats = new Stats();
          localCounter.dailyStats[dailyStatsKey] = todayStats;
        }

        if (bf.autoApproved) {
          if (globalCounter != null) {
            globalCounter.numberOfApproved++;
            globalCounter.dailyStats[dailyStatsKey].numberOfNew++;
            globalCounter.dailyStats[dailyStatsKey].numberOfApproved++;
          }
          localCounter.numberOfApproved++;
          localCounter.dailyStats[dailyStatsKey].numberOfNew++;
          localCounter.dailyStats[dailyStatsKey].numberOfApproved++;
          ba.approvedBy = SYSTEM;
          ba.notesOnApproval = AUTO_APPROVED;
          ba.timeOfApproval = now;
        } else {
          if (globalCounter != null) {
            globalCounter.numberOfNew++;
            globalCounter.dailyStats[dailyStatsKey].numberOfNew++;
          }
          localCounter.numberOfNew++;
          localCounter.dailyStats[dailyStatsKey].numberOfNew++;
        }
        if (globalCounter != null) {
          globalCounter.totalApplications++;
        }
        localCounter.totalApplications++;

        //if auto approved, then generate the token
        if (bf.autoApproved && bf.generateTokenOnApproval) {
          //generate the token
          UserTokens toks = await _gs
              .getTokenService()
              .generateTokenInTransaction(
                  tx,
                  userPhone,
                  metaEntity,
                  ba.preferredSlotTiming,
                  ba.id,
                  ba.bookingFormId,
                  ba.responseForm.formName);

          UserToken lastTok = toks.tokens[toks.tokens.length - 1];
          ba.tokenId = toks.getTokenId() + "#" + lastTok.number.toString();
        }

        tx.set(applicationRef, ba.toJson());
        tx.set(localCounterRef, localCounter.toJson());
        if (globalCounter != null) {
          tx.set(globalCounterRef, globalCounter.toJson());
        }

        isSuccess = true;
      } catch (ex) {
        print("Exception in Application submission $bookingApplicationId " +
            e.toString());
        e = ex;
        isSuccess = false;
      }
    });

    if (e != null) {
      throw e;
    }

    return false;
  }

  //to be done by the Applicant
  Future<bool> withDrawApplication(
      String applicationId, String notesOnCancellation) async {
    //set the BookingApplication status as cancelled
    //If the token is approved, cancel the token also
    if (!Utils.isNotNullOrEmpty(applicationId)) {
      throw Exception("Insufficient arguements to submit the application");
    }

    bool isSuccess = false;
    DateTime now = DateTime.now();

    final User user = getFirebaseAuth().currentUser;
    FirebaseFirestore fStore = getFirestore();
    String userPhone = user.phoneNumber;

    BookingApplication ba;

    BookingApplicationsOverview localCounter;
    BookingApplicationsOverview globalCounter;

    String bookingApplicationId = applicationId;

    final DocumentReference applicationRef =
        fStore.doc('bookingApplications/' + bookingApplicationId);

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
          ba = BookingApplication.fromJson(applicationSnapshot.data());
        } else {
          throw new Exception(
              "Application does not exists, it can't be cancelled");
        }

        ApplicationStatus existingStatus = ba.status;

        String bookingFormId = ba.bookingFormId;

        String localCounterId =
            bookingFormId + "#" + ba.entityId + "#" + now.year.toString();
        String globalCounterId = bookingFormId + "#" + now.year.toString();

        final DocumentReference localCounterRef =
            fStore.doc('counter/' + localCounterId);
        DocumentSnapshot localCounterSnapshot = await tx.get(localCounterRef);

        final DocumentReference globalCounterRef =
            fStore.doc('counter/' + globalCounterId);

        ba.status = ApplicationStatus.CANCELLED;
        ba.timeOfCancellation = DateTime.now();
        ba.notesOnCancellation = notesOnCancellation;

        if (ba.responseForm.isSystemTemplate) {
          DocumentSnapshot globalCounterSnapshot =
              await tx.get(globalCounterRef);
          //global counters have to be update or created
          if (globalCounterSnapshot.exists) {
            Map<String, dynamic> map = globalCounterSnapshot.data();
            globalCounter = BookingApplicationsOverview.fromJson(map);
          } else {
            globalCounter = new BookingApplicationsOverview(
                bookingFormId: bookingFormId, entityId: null);
          }

          if (globalCounter.dailyStats == null) {
            globalCounter.dailyStats = Map<String, Stats>();
          }

          if (!globalCounter.dailyStats.containsKey(dailyStatsKey)) {
            Stats todayStats = new Stats();
            globalCounter.dailyStats[dailyStatsKey] = todayStats;
          }
        }

        //local Counter to be updated or created
        if (localCounterSnapshot.exists) {
          Map<String, dynamic> map = localCounterSnapshot.data();
          localCounter = BookingApplicationsOverview.fromJson(map);
        } else {
          localCounter = new BookingApplicationsOverview(
              bookingFormId: bookingFormId, entityId: ba.entityId);
        }

        if (localCounter.dailyStats == null) {
          localCounter.dailyStats = Map<String, Stats>();
        }

        if (!localCounter.dailyStats.containsKey(dailyStatsKey)) {
          Stats todayStats = new Stats();
          localCounter.dailyStats[dailyStatsKey] = todayStats;
        }

        if (globalCounter != null) {
          globalCounter.numberOfCancelled++;
          globalCounter.dailyStats[dailyStatsKey].numberOfCancelled++;
        }
        localCounter.numberOfCancelled++;
        localCounter.dailyStats[dailyStatsKey].numberOfCancelled++;

        //token id should be stored as part of the application
        if (Utils.isNotNullOrEmpty(ba.tokenId)) {
          //token id format - Selenium-Covid-Vacination-Center#2021~2~17#10~30#9898989899#2

          List<String> tokenIdSplitted = ba.tokenId.split("#");

          String number = tokenIdSplitted[tokenIdSplitted.length - 1];
          int tokenNumber = int.parse(number);

          int beforeLastHash = ba.tokenId.length - number.length - 1;

          String tokenId = ba.tokenId.substring(0, beforeLastHash);

          //cancel the token
          await _gs
              .getTokenService()
              .cancelTokenInTransaction(tx, userPhone, tokenId, tokenNumber);
        }

        if (existingStatus == ApplicationStatus.APPROVED) {
          if (globalCounter != null) {
            globalCounter.numberOfApproved--;
          }
          if (localCounter != null) {
            localCounter.numberOfApproved--;
          }
        } else if (existingStatus == ApplicationStatus.NEW) {
          if (globalCounter != null) {
            globalCounter.numberOfNew--;
          }
          if (localCounter != null) {
            localCounter.numberOfNew--;
          }
        } else if (existingStatus == ApplicationStatus.COMPLETED) {
          if (globalCounter != null) {
            globalCounter.numberOfCompleted--;
          }
          if (localCounter != null) {
            localCounter.numberOfCompleted--;
          }
        } else if (existingStatus == ApplicationStatus.INPROCESS) {
          if (globalCounter != null) {
            globalCounter.numberOfInProcess--;
          }
          if (localCounter != null) {
            localCounter.numberOfInProcess--;
          }
        } else if (existingStatus == ApplicationStatus.ONHOLD) {
          if (globalCounter != null) {
            globalCounter.numberOfPutOnHold--;
          }
          if (localCounter != null) {
            localCounter.numberOfPutOnHold--;
          }
        } else if (existingStatus == ApplicationStatus.REJECTED) {
          if (globalCounter != null) {
            globalCounter.numberOfRejected--;
          }
          if (localCounter != null) {
            localCounter.numberOfRejected--;
          }
        }

        tx.set(applicationRef, ba.toJson());
        tx.set(localCounterRef, localCounter.toJson());
        if (globalCounter != null) {
          tx.set(globalCounterRef, globalCounter.toJson());
        }

        isSuccess = true;
      } catch (e) {
        print("Exception in Application submission $bookingApplicationId " +
            e.toString());
        isSuccess = false;
      }
    });

    return isSuccess;
  }

  //To be done by Manager of the Entity who has restricted rights
  Future<bool> updateApplicationStatus(
      String applicationId,
      ApplicationStatus status,
      String note,
      MetaEntity metaEntity,
      DateTime tokenTime) async {
    //TODO Security: Application Status, Time of Respective Status Change and Status can only be updated by the Entity Manager/Entity Admin
    //TODO Security: Once submitted for review, the Application can't be edited by the Applicant
    //TODO Security: Application can be only accessed and Updated by Entity Manager/Admin
    if (status == ApplicationStatus.NEW ||
        status == ApplicationStatus.CANCELLED) {
      throw new Exception("Invalid Application Status for Admin/Manager");
    }

    if (status == ApplicationStatus.APPROVED &&
        (metaEntity == null || tokenTime == null)) {
      throw new Exception(
          "Entity and Time are required for the Token generation on Approval");
    }

    Exception e;
    DateTime now = DateTime.now();

    final User user = getFirebaseAuth().currentUser;
    FirebaseFirestore fStore = getFirestore();
    String userPhone = user.phoneNumber;
    BookingForm bf;
    BookingApplication application;
    BookingApplicationsOverview localCounter;
    BookingApplicationsOverview globalCounter;
    ApplicationStatus existingStatus;

    String localCounterId;
    String globalCounterId;
    bool requestProcessed = false;

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
          application = BookingApplication.fromJson(applicationSnapshot.data());
          existingStatus = application.status;
          bf = application.responseForm;
          if (application.timeOfSubmission == null ||
              application.status == ApplicationStatus.CANCELLED) {
            throw new Exception(
                "Application is not submitted yet or it's in the cancelled state");
          }
        } else {
          throw new Exception("Application does not exist");
        }

        String entityId = application.entityId;
        String bookingFormId = application.bookingFormId;

        localCounterId =
            bookingFormId + "#" + entityId + "#" + now.year.toString();
        globalCounterId = bookingFormId + "#" + now.year.toString();

        final DocumentReference localCounterRef =
            fStore.doc('counter/' + localCounterId);

        final DocumentReference globalCounterRef =
            fStore.doc('counter/' + globalCounterId);

        DocumentSnapshot localCounterSnapshot = await tx.get(localCounterRef);

        if (bf.isSystemTemplate) {
          DocumentSnapshot globalCounterSnapshot =
              await tx.get(globalCounterRef);
          //global counters have to be update or created
          if (globalCounterSnapshot.exists) {
            Map<String, dynamic> map = globalCounterSnapshot.data();
            globalCounter = BookingApplicationsOverview.fromJson(map);
          }
        }

        //local Counter to be updated or created
        if (localCounterSnapshot.exists) {
          Map<String, dynamic> map = localCounterSnapshot.data();
          localCounter = BookingApplicationsOverview.fromJson(map);
        }

        //setting up the mandatory fields on the Application object
        if (status == ApplicationStatus.APPROVED) {
          application.timeOfApproval = now;
          application.notesOnApproval = note;
          application.approvedBy = userPhone;
          if (globalCounter != null) {
            globalCounter.numberOfApproved++;
            if (globalCounter.dailyStats.containsKey(dailyStatsKey)) {
              globalCounter.dailyStats[dailyStatsKey].numberOfApproved++;
            } else {
              Stats todayStats = new Stats();
              globalCounter.dailyStats[dailyStatsKey] = todayStats;
              globalCounter.dailyStats[dailyStatsKey].numberOfApproved++;
            }
          }
          if (localCounter != null) {
            localCounter.numberOfApproved++;
            if (localCounter.dailyStats.containsKey(dailyStatsKey)) {
              localCounter.dailyStats[dailyStatsKey].numberOfApproved++;
            } else {
              Stats todayStats = new Stats();
              localCounter.dailyStats[dailyStatsKey] = todayStats;
              localCounter.dailyStats[dailyStatsKey].numberOfApproved++;
            }
          }

          //TODO: generate the token and send the notification to the applicant
          //generate the token
          //send notification
          if (bf.generateTokenOnApproval) {
            UserTokens toks = await _gs
                .getTokenService()
                .generateTokenInTransaction(
                    tx,
                    userPhone,
                    metaEntity,
                    tokenTime,
                    application.id,
                    application.bookingFormId,
                    application.responseForm.formName);

            UserToken lastTok = toks.tokens[toks.tokens.length - 1];
            application.tokenId =
                toks.getTokenId() + "#" + lastTok.number.toString();
          }
        } else if (status == ApplicationStatus.COMPLETED) {
          application.timeOfCompletion = now;
          application.notesOnCompletion = note;
          application.completedBy = userPhone;
          if (globalCounter != null) {
            globalCounter.numberOfCompleted++;
            if (globalCounter.dailyStats.containsKey(dailyStatsKey)) {
              globalCounter.dailyStats[dailyStatsKey].numberOfCompleted++;
            } else {
              Stats todayStats = new Stats();
              globalCounter.dailyStats[dailyStatsKey] = todayStats;
              globalCounter.dailyStats[dailyStatsKey].numberOfCompleted++;
            }
          }
          if (localCounter != null) {
            localCounter.numberOfCompleted++;
            if (localCounter.dailyStats.containsKey(dailyStatsKey)) {
              localCounter.dailyStats[dailyStatsKey].numberOfCompleted++;
            } else {
              Stats todayStats = new Stats();
              localCounter.dailyStats[dailyStatsKey] = todayStats;
              localCounter.dailyStats[dailyStatsKey].numberOfCompleted++;
            }
          }
        } else if (status == ApplicationStatus.INPROCESS) {
          application.timeOfInProcess = now;
          application.notesInProcess = note;
          application.processedBy = userPhone;
          if (globalCounter != null) {
            globalCounter.numberOfInProcess++;
            if (globalCounter.dailyStats.containsKey(dailyStatsKey)) {
              globalCounter.dailyStats[dailyStatsKey].numberOfInProcess++;
            } else {
              Stats todayStats = new Stats();
              globalCounter.dailyStats[dailyStatsKey] = todayStats;
              globalCounter.dailyStats[dailyStatsKey].numberOfInProcess++;
            }
          }
          if (localCounter != null) {
            localCounter.numberOfInProcess++;
            if (localCounter.dailyStats.containsKey(dailyStatsKey)) {
              localCounter.dailyStats[dailyStatsKey].numberOfInProcess++;
            } else {
              Stats todayStats = new Stats();
              localCounter.dailyStats[dailyStatsKey] = todayStats;
              localCounter.dailyStats[dailyStatsKey].numberOfInProcess++;
            }
          }
        } else if (status == ApplicationStatus.ONHOLD) {
          application.timeOfPuttingOnHold = now;
          application.notesOnPuttingOnHold = note;
          application.putOnHoldBy = userPhone;
          if (globalCounter != null) {
            globalCounter.numberOfPutOnHold++;
            if (globalCounter.dailyStats.containsKey(dailyStatsKey)) {
              globalCounter.dailyStats[dailyStatsKey].numberOfPutOnHold++;
            } else {
              Stats todayStats = new Stats();
              globalCounter.dailyStats[dailyStatsKey] = todayStats;
              globalCounter.dailyStats[dailyStatsKey].numberOfPutOnHold++;
            }
          }
          if (localCounter != null) {
            localCounter.numberOfPutOnHold++;
            if (localCounter.dailyStats.containsKey(dailyStatsKey)) {
              localCounter.dailyStats[dailyStatsKey].numberOfPutOnHold++;
            } else {
              Stats todayStats = new Stats();
              localCounter.dailyStats[dailyStatsKey] = todayStats;
              localCounter.dailyStats[dailyStatsKey].numberOfPutOnHold++;
            }
          }
        } else if (status == ApplicationStatus.REJECTED) {
          application.timeOfRejection = now;
          application.notesOnRejection = note;
          application.rejectedBy = userPhone;
          if (globalCounter != null) {
            globalCounter.numberOfRejected++;
            if (globalCounter.dailyStats.containsKey(dailyStatsKey)) {
              globalCounter.dailyStats[dailyStatsKey].numberOfRejected++;
            } else {
              Stats todayStats = new Stats();
              globalCounter.dailyStats[dailyStatsKey] = todayStats;
              globalCounter.dailyStats[dailyStatsKey].numberOfRejected++;
            }
          }
          if (localCounter != null) {
            localCounter.numberOfRejected++;
            if (localCounter.dailyStats.containsKey(dailyStatsKey)) {
              localCounter.dailyStats[dailyStatsKey].numberOfRejected++;
            } else {
              Stats todayStats = new Stats();
              localCounter.dailyStats[dailyStatsKey] = todayStats;
              localCounter.dailyStats[dailyStatsKey].numberOfRejected++;
            }
          }
        }

        if (existingStatus == ApplicationStatus.APPROVED) {
          if (globalCounter != null) {
            globalCounter.numberOfApproved--;
          }
          if (localCounter != null) {
            localCounter.numberOfApproved--;
          }
        } else if (existingStatus == ApplicationStatus.NEW) {
          if (globalCounter != null) {
            globalCounter.numberOfNew--;
          }
          if (localCounter != null) {
            localCounter.numberOfNew--;
          }
        } else if (existingStatus == ApplicationStatus.COMPLETED) {
          if (globalCounter != null) {
            globalCounter.numberOfCompleted--;
          }
          if (localCounter != null) {
            localCounter.numberOfCompleted--;
          }
        } else if (existingStatus == ApplicationStatus.INPROCESS) {
          if (globalCounter != null) {
            globalCounter.numberOfInProcess--;
          }
          if (localCounter != null) {
            localCounter.numberOfInProcess--;
          }
        } else if (existingStatus == ApplicationStatus.ONHOLD) {
          if (globalCounter != null) {
            globalCounter.numberOfPutOnHold--;
          }
          if (localCounter != null) {
            localCounter.numberOfPutOnHold--;
          }
        } else if (existingStatus == ApplicationStatus.REJECTED) {
          if (globalCounter != null) {
            globalCounter.numberOfRejected--;
          }
          if (localCounter != null) {
            localCounter.numberOfRejected--;
          }
        }

        application.status = status;

        tx.set(applicationRef, application.toJson());
        tx.set(localCounterRef, localCounter.toJson());
        if (globalCounter != null) {
          tx.set(globalCounterRef, globalCounter.toJson());
        }

        requestProcessed = true;
      } catch (ex) {
        requestProcessed = false;
        print(ex.toString());
        e = ex;
      }
    });

    if (e != null) {
      throw e;
    }

    return requestProcessed;
  }

  Future<BookingApplicationsOverview> getApplicationsOverview(
      String bookingFormId, String entityId, int year) async {
    //entityId is optional param, assuming that bookingForm is Global Form/System form
    //if entityId is present, that means the counter is local to the Entity

    if (!Utils.isNotNullOrEmpty(bookingFormId)) {
      throw new Exception("FormId can't be null");
    }

    if (year == null) {
      throw new Exception("Year can't be null");
    }

    FirebaseFirestore fStore = getFirestore();
    BookingApplicationsOverview counter;

    final DocumentReference counterRef = fStore.doc('counter/' +
        (Utils.isNotNullOrEmpty(entityId)
            ? bookingFormId + "#" + entityId + "#" + year.toString()
            : bookingFormId + "#" + year.toString()));

    DocumentSnapshot doc = await counterRef.get();

    if (doc.exists) {
      Map<String, dynamic> map = doc.data();
      counter = BookingApplicationsOverview.fromJson(map);
    } else {
      counter = BookingApplicationsOverview(
          bookingFormId: bookingFormId, entityId: entityId);
      counter.id = null;
    }

    return counter;
  }

  Future<bool> saveBookingForm(BookingForm bf) async {
    FirebaseFirestore fStore = getFirestore();

    final DocumentReference formRef = fStore.doc('bookingForms/' + bf.id);

    DocumentSnapshot doc = await formRef.get();
    BookingForm form;
    if (doc.exists) {
      Map<String, dynamic> map = doc.data();

      form = BookingForm.fromJson(map);
    }

    //TODO: Only the Entity Admin can update BookingForm, if it is associated with an Entity and not a System Template
    //TODO: Global booking form and system template will be only edited from Backend, define the security Rule on it

    form = bf;

    formRef.set(form.toJson());

    return true;
  }

  Future<BookingForm> getBookingForm(String formId) async {
    FirebaseFirestore fStore = getFirestore();
    BookingForm form;

    final DocumentReference formRef = fStore.doc('bookingForms/' + formId);

    try {
      DocumentSnapshot doc = await formRef.get();

      if (doc.exists) {
        Map<String, dynamic> map = doc.data();
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
