import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:noq/db/db_model/configurations.dart';
import 'package:noq/db/exceptions/access_denied_exception.dart';

class ConfigurationService {
  FirebaseApp _fb;
  ConfigurationService(FirebaseApp fb) {
    _fb = fb;
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

  Future<Configurations> getConfigurations() async {
    final User fireUser = getFirebaseAuth().currentUser;

    if (fireUser == null) {
      throw new AccessDeniedException(
          "Not authorised to read the configurations");
    }

    FirebaseFirestore fStore = getFirestore();

    final DocumentReference confRef = fStore.doc('conf/configurations');

    DocumentSnapshot doc = await confRef.get();
    Configurations conf;

    if (doc.exists) {
      conf = Configurations.fromJson(doc.data());
    }
    return conf;
  }
}
