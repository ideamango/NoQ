import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:noq/db/db_model/booking_application.dart';
import 'package:noq/db/db_model/booking_form.dart';

import 'package:noq/enum/application_status.dart';
import 'package:noq/enum/entity_type.dart';

class BookingApplicationService {
  FirebaseApp _fb;

  BookingApplicationService(FirebaseApp firebaseApp) {
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
    //Case 3: If BookingForm is Auto Approved then generate the token immediately

    final User user = getFirebaseAuth().currentUser;
    FirebaseFirestore fStore = getFirestore();
    String userPhone = user.phoneNumber;
    BookingForm bf;
    BookingApplication bfDraft;

    Exception exception;
    String bookingApplicationId;
    String bookingFormId = ba.bookingFormId;
    String localCounterId =
        "ApplicationCounter" + "#" + entityId + "#" + bookingFormId;
    String globalCounterId = "ApplicationCounter" + "#" + bookingFormId;

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
        if (applicationSnapshot.exists) {
          bfDraft = BookingApplication.fromJson(applicationSnapshot.data());
          if (bfDraft.timeOfSubmission != null) {
            throw new Exception(
                "Application is already submitted, can't resubmit again.");
          }
        } else {}
      } catch (e) {}
    });

    return false;
  }

  //to be done by the Applicant
  Future<bool> withDrawApplication(String applicationId) async {
    //set the BookingApplication status as cancelled
    //If the token is approved, cancel the token also

    return false;
  }

  //to be done by Manager of the Entity who has restricted rights
  Future<bool> updateApplicationStatus(
      String applicationId, ApplicationStatus status, String note) async {
    //Security: Application Status, Time of Respective Status Change and Status can only be updated by the Entity Manager/Entity Admin (not by the )
    //Security: Once submitted for review, the Application can't be edited by the Applicant

    return false;
  }

  Future<BookingApplicationsOverview> getBookingApplicationOverview(
      String bookingFormId, String entityId) async {
    return null;
  }
}
