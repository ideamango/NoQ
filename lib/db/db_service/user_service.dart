import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:noq/db/db_model/app_user.dart';

class UserService {
  FirebaseApp _fb;

  UserService(FirebaseApp firebaseApp) {
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

  Future<AppUser> getCurrentUser() async {
    final User fireUser = getFirebaseAuth().currentUser;
    if (fireUser == null) return null;

    FirebaseFirestore fStore = getFirestore();

    final DocumentReference userRef =
        fStore.doc('users/' + fireUser.phoneNumber);

    AppUser u;

    DocumentSnapshot doc = await userRef.get();

    if (doc.exists) {
      Map<String, dynamic> map = doc.data();

      u = AppUser.fromJson(map);
    } else {
      u = new AppUser(
          id: fireUser.uid,
          ph: fireUser.phoneNumber,
          name: fireUser.displayName);

      userRef.set(u.toJson());
    }

    return u;
  }

  Future<bool> deleteCurrentUser() async {
    final User fireUser = getFirebaseAuth().currentUser;
    FirebaseFirestore fStore = getFirestore();
    try {
      final DocumentReference userRef =
          fStore.doc('users/' + fireUser.phoneNumber);
      userRef.delete();
    } catch (e) {
      return false;
    }
    return true;
  }
}
