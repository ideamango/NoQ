import 'package:cloud_firestore/cloud_firestore.dart';

class GeoPointExt extends GeoPoint {
  GeoPointExt(double lat, double lon) : super(lat, lon);

  Map<String, dynamic> toJson() => {
        'latitude': latitude,
        'longitude': longitude,
      };

  static GeoPointExt fromJson(Map<String, dynamic> json) {
    if (json == null) return null;
    double lat = json['latitude'];
    double lon = json['longitude'];
    return new GeoPointExt(lat, lon);
  }
}
