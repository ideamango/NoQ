import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:noq/db/db_model/user.dart';

class UserService {
  //This method is to be called when the user logs in the system for the first time
  Future<User> createUser() async {
    final FirebaseUser fireUser = await FirebaseAuth.instance.currentUser();
    Firestore fStore = Firestore.instance;

    final DocumentReference userRef =
        fStore.document('users/' + fireUser.phoneNumber);

    User u;

    await fStore.runTransaction((Transaction tx) async {
      try {
        DocumentSnapshot usrDoc = await tx.get(userRef);
        if (usrDoc.exists) {
          u = User.fromJson(usrDoc.data);
        } else {
          u = new User(
              id: fireUser.uid,
              ph: fireUser.phoneNumber,
              name: fireUser.displayName);

          tx.set(userRef, u.toJson());
        }
      } catch (e) {
        print("Transactio Error: " + e.toString());
        u = null;
      }
    });

    return u;
  }

  Future<User> getCurrentUser() async {
    final FirebaseUser fireUser = await FirebaseAuth.instance.currentUser();
    Firestore fStore = Firestore.instance;

    final DocumentReference userRef =
        fStore.document('users/' + fireUser.phoneNumber);

    User u;

    DocumentSnapshot doc = await userRef.get();

    if (doc.exists) {
      Map<String, dynamic> map = doc.data;

      u = User.fromJson(map);
    } else {
      u = new User(
          id: fireUser.uid,
          ph: fireUser.phoneNumber,
          name: fireUser.displayName);

      userRef.setData(u.toJson());
    }

    return u;
  }

  Future<bool> deleteCurrentUser() async {
    final FirebaseUser fireUser = await FirebaseAuth.instance.currentUser();
    Firestore fStore = Firestore.instance;
    try {
      final DocumentReference userRef =
          fStore.document('users/' + fireUser.phoneNumber);
      await userRef.delete();
    } catch (e) {
      return false;
    }
    return true;
  }
}
