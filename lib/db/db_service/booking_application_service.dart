import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:noq/constants.dart';
import 'package:noq/db/db_model/booking_application.dart';
import 'package:noq/db/db_model/booking_form.dart';

import 'package:noq/enum/application_status.dart';
import 'package:noq/enum/entity_type.dart';
import 'package:noq/global_state.dart';
import 'package:noq/utils.dart';

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

  Future<List<BookingApplication>> getApplications(
      String bookingFormID,
      EntityType type,
      String entityId,
      String userId,
      ApplicationStatus status,
      DateTime toDate,
      DateTime fromDate,
      Map<String, String> fieldValues,
      int page,
      int takeCount) async {
    FirebaseFirestore fStore = getFirestore();

    return null;
  }

  //To be done by the Applicant
  Future<bool> saveDraftApplication(BookingApplication ba) async {
    //Case 1: Create the BookingApplication object in the Applications collection,
    //if time of submission is empty then the application is in draft state

    return false;
  }

  //To be done by the Applicant
  Future<bool> submitApplication(BookingApplication ba, String entityId) async {
    //Security: BookingApplication (Application Status by the applicant can be only Null, New, Cancelled), other statuses are reserved for the Manager/Admin
    //Case 1: Create the BookingApplication object in the Applications collection
    //Case 2: Create if not already created the BookingApplicationsOverview, and update the total counter and new counter
    //Case 3: If BookingForm is Auto Approved then generate the token immediately and set the numberOfApproved in counter by 1

    if (ba == null || !Utils.isNotNullOrEmpty(ba.bookingFormId)) {
      throw Exception("Insufficient arguements to submit the application");
    }

    final User user = getFirebaseAuth().currentUser;
    FirebaseFirestore fStore = getFirestore();
    String userPhone = user.phoneNumber;
    BookingForm bf;
    BookingApplication baDraft;
    BookingApplicationsOverview localCounter;
    BookingApplicationsOverview globalCounter;

    Exception exception;
    String bookingApplicationId;
    String bookingFormId = ba.bookingFormId;
    String localCounterId = bookingFormId + "#" + entityId;
    String globalCounterId = bookingFormId;

    final DocumentReference applicationRef =
        fStore.doc('bookingApplications/' + bookingApplicationId);

    final DocumentReference bookingFormRef =
        fStore.doc('bookingForms/' + bookingFormId);

    final DocumentReference localCounterRef =
        fStore.doc('counter/' + localCounterId);

    final DocumentReference globalCounterRef =
        fStore.doc('counter/' + globalCounterId);

    DocumentSnapshot doc = await bookingFormRef.get();

    if (doc.exists) {
      Map<String, dynamic> map = doc.data();

      bf = BookingForm.fromJson(map);
    } else {
      return false; //no form exists, hence can't proceed
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

        DateTime now = DateTime.now();

        //setting up the mandatory fields on the Application object
        ba.timeOfSubmission = now;
        ba.entityId = entityId;
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
                bookingFormId: bf.id, entityId: null);
          }
        }

        //local Counter to be updated or created
        if (localCounterSnapshot.exists) {
          Map<String, dynamic> map = localCounterSnapshot.data();
          localCounter = BookingApplicationsOverview.fromJson(map);
        } else {
          localCounter = new BookingApplicationsOverview(
              bookingFormId: bf.id, entityId: entityId);
        }

        if (bf.autoApproved) {
          globalCounter.numberOfApproved++;
          localCounter.numberOfApproved++;
          ba.approvedBy = SYSTEM;
          ba.notesOnApproval = AUTO_APPROVED;
          ba.timeOfApproval = now;
        } else {
          globalCounter.numberOfNew++;
          localCounter.numberOfNew++;
        }
        globalCounter.totalApplications++;
        localCounter.totalApplications++;

        //if auto approved, then generate the token
        if (bf.autoApproved) {
          //generate the token
        }

        tx.set(applicationRef, ba.toJson());
        tx.set(localCounterRef, localCounter.toJson());
        if (globalCounter != null) {
          tx.set(globalCounterRef, globalCounter.toJson());
        }
      } catch (e) {
        exception = e;
      }
    });

    return false;
  }

  //to be done by the Applicant
  Future<bool> withDrawApplication(String applicationId) async {
    //set the BookingApplication status as cancelled
    //If the token is approved, cancel the token also

    return false;
  }

  //To be done by Manager of the Entity who has restricted rights
  Future<bool> updateApplicationStatus(
      String applicationId, ApplicationStatus status, String note) async {
    //TODO Security: Application Status, Time of Respective Status Change and Status can only be updated by the Entity Manager/Entity Admin
    //TODO Security: Once submitted for review, the Application can't be edited by the Applicant
    //TODO Security: Application can be only accessed and Updated by Entity Manager/Admin
    if (status == ApplicationStatus.NEW ||
        status == ApplicationStatus.CANCELLED) {
      throw new Exception("Invalid Application Status for Admin/Manager");
    }

    Exception exception;
    DateTime now = DateTime.now();
    ;

    final User user = getFirebaseAuth().currentUser;
    FirebaseFirestore fStore = getFirestore();
    String userPhone = user.phoneNumber;
    BookingForm bf;
    BookingApplication application;
    BookingApplicationsOverview localCounter;
    BookingApplicationsOverview globalCounter;

    String bookingApplicationId;

    String localCounterId;
    String globalCounterId;

    final DocumentReference applicationRef =
        fStore.doc('bookingApplications/' + bookingApplicationId);

    final DocumentReference localCounterRef =
        fStore.doc('counter/' + localCounterId);

    final DocumentReference globalCounterRef =
        fStore.doc('counter/' + globalCounterId);

    await fStore.runTransaction((Transaction tx) async {
      try {
        DocumentSnapshot applicationSnapshot = await tx.get(applicationRef);
        DocumentSnapshot localCounterSnapshot = await tx.get(localCounterRef);

        if (applicationSnapshot.exists) {
          application = BookingApplication.fromJson(applicationSnapshot.data());
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

        localCounterId = bookingFormId + "#" + entityId;
        globalCounterId = bookingFormId;

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
          if (globalCounter != null) {
            globalCounter.numberOfApproved++;
          }
          if (localCounter != null) {
            localCounter.numberOfApproved++;
          }

          //generate the token and send the notification to the applicant

        } else if (status == ApplicationStatus.COMPLETED) {
          application.timeOfCompletion = now;
          application.notesOnCompletion = note;
          if (globalCounter != null) {
            globalCounter.numberOfCompleted++;
          }
          if (localCounter != null) {
            localCounter.numberOfCompleted++;
          }
        } else if (status == ApplicationStatus.INPROCESS) {
          application.timeOfInProcess = now;
          application.notesInProcess = note;
          if (globalCounter != null) {
            globalCounter.numberOfInProcess++;
          }
          if (localCounter != null) {
            localCounter.numberOfInProcess++;
          }
        } else if (status == ApplicationStatus.ONHOLD) {
          application.timeOfPuttingOnHold = now;
          application.notesOnPuttingOnHold = note;
          if (globalCounter != null) {
            globalCounter.numberOfPutOnHold++;
          }
          if (localCounter != null) {
            localCounter.numberOfPutOnHold++;
          }
        } else if (status == ApplicationStatus.REJECTED) {
          application.timeOfRejection = now;
          application.notesOnRejection = note;
          if (globalCounter != null) {
            globalCounter.numberOfRejected++;
          }
          if (localCounter != null) {
            localCounter.numberOfRejected++;
          }
        }
        application.status = status;

        tx.set(applicationRef, application.toJson());
        tx.set(localCounterRef, localCounter.toJson());
        if (globalCounter != null) {
          tx.set(globalCounterRef, globalCounter.toJson());
        }
      } catch (e) {
        exception = e;
      }
    });

    return false;
  }

  Future<BookingApplicationsOverview> getBookingApplicationOverview(
      String bookingFormId, String entityId) async {
    //entityId is optional param, assuming that bookingForm is Global Form/System form
    //if entityId is present, that means the counter is local to the Entity
    FirebaseFirestore fStore = getFirestore();
    BookingApplicationsOverview counter;

    final DocumentReference counterRef = fStore.doc('counter/' +
        (Utils.isNotNullOrEmpty(entityId)
            ? bookingFormId + "#" + entityId
            : bookingFormId));

    DocumentSnapshot doc = await counterRef.get();

    if (doc.exists) {
      Map<String, dynamic> map = doc.data();
      counter = BookingApplicationsOverview.fromJson(map);
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

    DocumentSnapshot doc = await formRef.get();

    if (doc.exists) {
      Map<String, dynamic> map = doc.data();
      form = BookingForm.fromJson(map);
    }

    return form;
  }
}
