import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:noq/db/db_model/app_user.dart';

class UserService {
  Future<AppUser> getCurrentUser() async {
    final User fireUser = FirebaseAuth.instance.currentUser;
    FirebaseFirestore fStore = FirebaseFirestore.instance;

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
    final User fireUser = FirebaseAuth.instance.currentUser;
    FirebaseFirestore fStore = FirebaseFirestore.instance;
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
