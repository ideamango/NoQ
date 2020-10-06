import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:noq/db/db_model/configurations.dart';
import 'package:noq/db/db_service/access_denied_exception.dart';

class ConfigurationService {
  Future<Configurations> getConfigurations() async {
    final User fireUser = FirebaseAuth.instance.currentUser;

    if (fireUser == null) {
      throw new AccessDeniedException(
          "Not authorised to read the configurations");
    }

    FirebaseFirestore fStore = FirebaseFirestore.instance;

    final DocumentReference confRef = fStore.doc('conf/configurations');

    DocumentSnapshot doc = await confRef.get();
    Configurations conf;

    if (doc.exists) {
      conf = Configurations.fromJson(doc.data());
    }
    return conf;
  }
}
