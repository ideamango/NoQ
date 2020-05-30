import 'my_geo_fire_point.dart';

class User {
  User({this.id, this.firebaseId, this.fn, this.ln, this.loc, this.ph});

  String id;
  String firebaseId;
  String fn;
  String ln;
  MyGeoFirePoint loc;
  String ph;

  Map<String, dynamic> toJson() => {
        'id': id,
        'firebaseId': firebaseId,
        'fn': fn,
        'ln': ln,
        'loc': loc.toJson(),
        'ph': ph
      };

  static User fromJson(Map<String, dynamic> json) {
    return new User(
      id: json['id'].toString(),
      firebaseId: json['firebaseId'],
      fn: json['fn'],
      ln: json['ln'],
      loc: MyGeoFirePoint.fromJson(json['loc']),
      ph: json['ph'],
    );
  }
}
