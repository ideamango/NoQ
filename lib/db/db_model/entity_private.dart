import 'dart:ffi';

class EntityPrivate {
  Map<String, String> roles;
  String registrationNumber;

  EntityPrivate({this.roles, this.registrationNumber});

  static EntityPrivate fromJson(Map<String, dynamic> json) {
    if (json == null) return null;
    return new EntityPrivate(
        roles: convert((json['roles'] as Map<String, dynamic>)),
        registrationNumber: json['registrationNumber']);
  }

  Map<String, dynamic> toJson() => {
        'roles': roles,
        'registrationNumber': registrationNumber
      };

  static Map<String, String> convert(Map<dynamic, dynamic> jsonRoles) {
    Map<String, String> roles = new Map<String, String>();
    jsonRoles.forEach((k, v) => roles[k] = v);
    return roles;
  }
}
