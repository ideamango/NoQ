import 'package:enum_to_string/enum_to_string.dart';
import './meta_entity.dart';
import './meta_user.dart';
import '../../enum/entity_type.dart';

import '../../utils.dart';

import '../../enum/entity_role.dart';
import 'my_geo_fire_point.dart';

class AppUser {
  AppUser({this.id = "", this.name = "", this.ph = ""});

  //just need an id which is unique even if later phone or firebase id changes
  String? id;
  String? name;

  MyGeoFirePoint? loc;
  String? ph;
  List<MetaEntity?>? entities;
  List<MetaEntity?>? favourites;
  Map<String?, EntityRole?>? entityVsRole;
  String? country;
  String? state;
  String? city;
  String? zip;

  // factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);

  // /// `toJson` is the convention for a class to declare support for serialization
  // /// to JSON. The implementation simply calls the private, generated
  // /// helper method `_$UserToJson`.
  // Map<String, dynamic> toJson() => _$UserToJson(this);

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'loc': loc != null ? loc!.toJson() : null,
        'ph': ph,
        'entities': metaEntitiesToJson(entities),
        'favourites': metaEntitiesToJson(favourites),
        'entityVsRole': convertFromMap(entityVsRole),
        'country': country,
        'state': state,
        'city': city,
        'zip': zip
      };

  static AppUser fromJson(Map<String, dynamic> json) {
    AppUser appUser =
        AppUser(id: json['id'], name: json['name'], ph: json['ph']);

    appUser.loc = MyGeoFirePoint.fromJson(json['loc']);
    appUser.entities = convertToMetaEntitiesFromJson(json['entities']);
    appUser.favourites = convertToMetaEntitiesFromJson(json['favourites']);
    appUser.entityVsRole = convertToMapFromJSON(json['entityVsRole']);
    appUser.country = json['country'];
    appUser.state = json['state'];
    appUser.city = json["city"];
    appUser.zip = json["zip"];

    return appUser;
  }

  Map<String?, dynamic> convertFromMap(Map<String?, EntityRole?>? entityRoles) {
    Map<String?, dynamic> map = Map<String?, dynamic>();
    if (entityRoles == null) {
      return map;
    }
    entityRoles.forEach((k, v) => map[k] = EnumToString.convertToString(v));
    return map;
  }

  static Map<String?, EntityRole?> convertToMapFromJSON(
      Map<dynamic, dynamic>? map) {
    Map<String?, EntityRole?> roles = new Map<String?, EntityRole?>();
    if (map != null) {
      map.forEach(
          (k, v) => roles[k] = EnumToString.fromString(EntityRole.values, v));
    }
    return roles;
  }

  List<dynamic> metaEntitiesToJson(List<MetaEntity?>? metaEntities) {
    List<dynamic> usersJson = [];
    if (metaEntities == null) return usersJson;
    for (MetaEntity? meta in metaEntities) {
      usersJson.add(meta!.toJson());
    }
    return usersJson;
  }

  static List<MetaEntity?> convertToMetaEntitiesFromJson(
      List<dynamic>? metaEntityJson) {
    List<MetaEntity?> metaEntities = [];
    if (Utils.isNullOrEmpty(metaEntityJson)) return metaEntities;

    for (Map<String, dynamic> json in metaEntityJson as Iterable<Map<String, dynamic>>) {
      MetaEntity metaEnt = MetaEntity.fromJson(json);
      metaEntities.add(metaEnt);
    }
    return metaEntities;
  }

  int getAdminIndex(String? entityId) {
    int count = -1;
    if (entities == null) return count;

    for (MetaEntity? meta in entities!) {
      count++;
      if (meta!.entityId == entityId) {
        return count;
      }
    }
    return -1;
  }

  bool isEntityAdmin(String entityId) {
    if (entityVsRole != null &&
        entityVsRole!.containsKey(entityId) &&
        entityVsRole![entityId] == EntityRole.Admin) {
      return true;
    } else {
      return false;
    }
  }

  bool isEntityManager(String entityId) {
    if (entityVsRole != null &&
        entityVsRole!.containsKey(entityId) &&
        entityVsRole![entityId] == EntityRole.Manager) {
      return true;
    } else {
      return false;
    }
  }

  bool isEntityExecutive(String entityId) {
    if (entityVsRole != null &&
        entityVsRole!.containsKey(entityId) &&
        entityVsRole![entityId] == EntityRole.Executive) {
      return true;
    } else {
      return false;
    }
  }

  MetaUser getMetaUser() {
    return new MetaUser(id: id, ph: ph, name: name);
  }
}
