import 'package:cloud_firestore/cloud_firestore.dart';
import '../db_model/my_geo_fire_point.dart';

import 'package:geoflutterfire/geoflutterfire.dart';
import '../db_model/slot.dart';
import '../db_model/app_user.dart';

class DBLayer {
  static void addRecord() async {
    Geoflutterfire geo = Geoflutterfire();
    FirebaseFirestore _firestore = FirebaseFirestore.instance;

    MyGeoFirePoint fp = new MyGeoFirePoint(12.992975, 77.660653);

    AppUser u = new AppUser();
    // u.fn = "Far1";
    // u.ln = "Far2";
    u.loc = fp;
    u.ph = "+91870997688";

    Future<DocumentReference> doc =
        _firestore.collection('users').add(u.toJson());

    Slot sl = new Slot();
    sl.slotId = "TestEntId";
    sl.totalBooked = 10;
    sl.dateTime = DateTime.now();
    sl.maxAllowed = 60;
    sl.slotDuration = 30;

    final CollectionReference slotsRef =
        FirebaseFirestore.instance.collection('/slots');

    var postID = "1";

    try {
      Map<String, dynamic> slData = sl.toJson();
      await slotsRef.doc(postID).set(slData);
    } catch (e) {
      print(
          "Error occured as tried creating slot with same id: " + e.toString());
    }

    GeoFirePoint center = geo.point(latitude: 12.960632, longitude: 77.641603);

// get the collection reference or query
    var collectionReference = _firestore.collection('users');

    double radius = 1;
    String field = 'loc';

    Stream<List<DocumentSnapshot>> stream = geo
        .collection(collectionRef: collectionReference)
        .within(center: center, radius: radius, field: field);

    stream.listen((List<DocumentSnapshot> documentList) {
      documentList.forEach((doc) => {
            print(AppUser.fromJson(doc.data() as Map<String, dynamic>)
                .loc!
                .geopoint!
                .latitude)
          });
    });
  }
}
