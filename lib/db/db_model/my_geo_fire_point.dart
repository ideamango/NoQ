import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geoflutterfire/geoflutterfire.dart';

import 'geo_point_ext.dart';

class MyGeoFirePoint {
  MyGeoFirePoint(double lat, double lon) {
    Geoflutterfire geo = Geoflutterfire();
    GeoFirePoint point = geo.point(latitude: lat, longitude: lon);
    geohash = point.hash;
    geopoint = new GeoPointExt(lat, lon);
  }

  String? geohash;
  GeoPointExt? geopoint;

  Map<String, dynamic> toJson() => {
        'geohash': geohash,
        'geopoint': geopoint,
      };

  static MyGeoFirePoint? fromJson(Map<String, dynamic>? json) {
    if (json == null) return null;

    if (json['geopoint'] is GeoPoint) {
      GeoPoint p = json['geopoint'];
      return new MyGeoFirePoint(p.latitude, p.longitude);
    } else if (json['geopoint'] is Map) {
      double lat = json['geopoint']['latitude'];
      double lon = json['geopoint']['longitude'];
      return new MyGeoFirePoint(lat, lon);
    }
    return null;
  }
}
