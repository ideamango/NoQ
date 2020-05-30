import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:noq/db/db_model/my_geo_fire_point.dart';

import 'package:geoflutterfire/geoflutterfire.dart';
import 'package:noq/db/db_model/user.dart';

class DBLayer {
  static void addRecord() {
    Geoflutterfire geo = Geoflutterfire();
    Firestore _firestore = Firestore.instance;

    MyGeoFirePoint fp = new MyGeoFirePoint(12.992975, 77.660653);

    User u = new User();
    u.fn = "Far1";
    u.ln = "Far2";
    u.loc = fp;
    u.ph = "+91870997688";

    Future<DocumentReference> doc =
        _firestore.collection('users').add(u.toJson());

    GeoFirePoint center = geo.point(latitude: 12.960632, longitude: 77.641603);

// get the collection reference or query
    var collectionReference = _firestore.collection('users');

    double radius = 1;
    String field = 'loc';

    Stream<List<DocumentSnapshot>> stream = geo
        .collection(collectionRef: collectionReference)
        .within(center: center, radius: radius, field: field);

    stream.listen((List<DocumentSnapshot> documentList) {
      documentList.forEach(
          (doc) => {print(User.fromJson(doc.data).loc.geopoint.latitude)});
    });
  }
}
