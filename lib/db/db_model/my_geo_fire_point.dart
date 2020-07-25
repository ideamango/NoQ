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

  String geohash;
  GeoPointExt geopoint;

  Map<String, dynamic> toJson() => {
        'geohash': geohash,
        'geopoint': geopoint,
      };

  static MyGeoFirePoint fromJson(Map<String, dynamic> json) {
    if (json == null) return null;
    GeoPoint p = json['geopoint'];
    if (p == null) return null;
    GeoPointExt point = GeoPointExt(p.latitude, p.longitude);
    double lat = point.latitude;
    double lon = point.longitude;
    return new MyGeoFirePoint(lat, lon);
  }
}
