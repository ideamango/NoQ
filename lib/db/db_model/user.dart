import 'package:noq/db/db_model/meta_entity.dart';
import 'package:noq/db/db_model/meta_user.dart';

import 'my_geo_fire_point.dart';

class User {
  User({this.id, this.name, this.loc, this.ph, this.entities, this.favourites});

  //just need an id which is unique even if later phone or firebase id changes
  String id;
  String name;
  MyGeoFirePoint loc;
  String ph;
  List<MetaEntity> entities;
  List<MetaEntity> favourites;

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'loc': loc != null ? loc.toJson() : null,
        'ph': ph,
        'entities': metaEntitiesToJson(entities),
        'favourites': metaEntitiesToJson(favourites)
      };

  static User fromJson(Map<String, dynamic> json) {
    if (json == null) return null;
    return new User(
        id: json['id'],
        name: json['name'],
        loc: MyGeoFirePoint.fromJson(json['loc']),
        ph: json['ph'],
        entities: convertToMetaEntitiesFromJson(json['entities']),
        favourites: convertToMetaEntitiesFromJson(json['favourites']));
  }

  List<dynamic> metaEntitiesToJson(List<MetaEntity> metaEntities) {
    List<dynamic> usersJson = new List<dynamic>();
    if (metaEntities == null) return usersJson;
    for (MetaEntity meta in metaEntities) {
      usersJson.add(meta.toJson());
    }
    return usersJson;
  }

  static List<MetaEntity> convertToMetaEntitiesFromJson(
      List<dynamic> metaEntityJson) {
    List<MetaEntity> metaEntities = new List<MetaEntity>();
    if (metaEntityJson == null) return metaEntities;

    for (Map<String, dynamic> json in metaEntityJson) {
      MetaEntity metaEnt = MetaEntity.fromJson(json);
      metaEntities.add(metaEnt);
    }
    return metaEntities;
  }

  int isEntityAdmin(String entityId) {
    int count = -1;
    if (entities == null) return count;

    for (MetaEntity meta in entities) {
      count++;
      if (meta.entityId == entityId) {
        return count;
      }
    }
    return -1;
  }

  MetaUser getMetaUser() {
    return new MetaUser(id: id, ph: ph, name: name);
  }
}
