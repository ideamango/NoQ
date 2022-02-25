import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import '../../location.dart';
import '../db_model/app_user.dart';

class UserService {
  FirebaseApp? _fb;

  UserService(FirebaseApp? firebaseApp) {
    _fb = firebaseApp;
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

  Future<AppUser?> getCurrentUser([Location? loc]) async {
    User? user = getFirebaseAuth().currentUser;
    if (user == null) return null;

    FirebaseFirestore fStore = getFirestore();

    final DocumentReference userRef = fStore.doc('users/' + user.phoneNumber!);

    AppUser u;

    DocumentSnapshot doc = await userRef.get();

    if (doc.exists) {
      Map<String, dynamic> map = doc.data() as Map<String, dynamic>;

      u = AppUser.fromJson(map);
    } else {
      u = new AppUser(
          id: user.uid, ph: user.phoneNumber, name: user.displayName);
      if (loc != null) {
        u.country = loc.country;
        u.state = loc.state;
        u.city = loc.city;
        u.zip = loc.zip;
      }

      userRef.set(u.toJson());
    }

    return u;
  }

  Future<bool> deleteCurrentUser() async {
    User user = getFirebaseAuth().currentUser!;
    FirebaseFirestore fStore = getFirestore();
    try {
      final DocumentReference userRef =
          fStore.doc('users/' + user.phoneNumber!);
      userRef.delete();
    } catch (e) {
      return false;
    }
    return true;
  }

  Future<bool> deleteUser(String phone) async {
    FirebaseFirestore fStore = getFirestore();
    try {
      final DocumentReference userRef = fStore.doc('users/' + phone);
      userRef.delete();
    } catch (e) {
      return false;
    }
    return true;
  }

  Future<AppUser?> getUser(String phone) async {
    FirebaseFirestore fStore = getFirestore();

    final DocumentReference userRef = fStore.doc('users/' + phone);

    AppUser? u;

    DocumentSnapshot doc = await userRef.get();

    if (doc.exists) {
      Map<String, dynamic> map = doc.data() as Map<String, dynamic>;

      u = AppUser.fromJson(map);
    }
    return u;
  }
}
