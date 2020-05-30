import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:noq/db/db_model/my_geo_fire_point.dart';
import 'package:noq/db/db_model/user.dart';

class UserService {
  Future<String> registerUser(String phone, String firstName, String lastName,
      String firebaseId, double lat, double lon) async {
    //TODO:
    //1. If the user with the same phone or firebaseId already exits, do not allow the creation - throw exception

    Firestore _firestore = Firestore.instance;
    MyGeoFirePoint fp;
    if (lat != null && lon != null) {
      fp = new MyGeoFirePoint(lat, lon);
    }

    User u = new User(
      firebaseId: firebaseId,
      fn: firstName,
      ln: lastName,
      loc: fp,
      ph: phone,
    );

    DocumentReference docRef =
        await _firestore.collection('users').add(u.toJson());

    return docRef.documentID;
  }

  bool updateUser(String phone, String firstName, String lastName,
      String firebaseId, double lat, double lon) {}
}
