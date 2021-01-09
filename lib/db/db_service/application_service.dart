import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:noq/db/db_model/booking_application.dart';

import 'package:noq/enum/application_status.dart';
import 'package:noq/enum/entity_type.dart';

class ApplicationService {
  FirebaseApp _fb;

  ApplicationService(FirebaseApp firebaseApp) {
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

  Future<BookingApplication> getApplications(
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

  Future<bool> submitApplication(BookingApplication ba) async {
    return false;
  }
}
