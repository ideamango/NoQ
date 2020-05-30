import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geoflutterfire/geoflutterfire.dart';

class MyGeoFirePoint {
  MyGeoFirePoint(double lat, double lon) {
    Geoflutterfire geo = Geoflutterfire();
    GeoFirePoint point = geo.point(latitude: lat, longitude: lon);
    geohash = point.hash;
    geopoint = point.geoPoint;
  }

  String geohash;
  GeoPoint geopoint;

  Map<String, dynamic> toJson() => {
        'geohash': geohash,
        'geopoint': geopoint,
      };

  static MyGeoFirePoint fromJson(Map<String, dynamic> json) {
    GeoPoint point = json['geopoint'] as GeoPoint;
    double lat = point.latitude;
    double lon = point.longitude;
    return new MyGeoFirePoint(lat, lon);
  }
}
