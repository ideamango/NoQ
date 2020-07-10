import 'package:noq/db/db_model/address.dart';
import 'package:noq/db/db_model/employee.dart';
import 'package:noq/db/db_model/meta_entity.dart';
import 'package:noq/db/db_model/meta_user.dart';
import 'package:noq/db/db_model/my_geo_fire_point.dart';

class Entity {
  Entity(
      {this.entityId,
      this.name,
      this.description,
      this.regNum,
      this.address,
      this.advanceDays,
      this.isPublic,
      this.admins,
      this.managers,
      this.childEntities,
      this.geo,
      this.maxAllowed,
      this.slotDuration,
      this.closedOn,
      this.breakStartHour,
      this.breakStartMinute,
      this.breakEndHour,
      this.breakEndMinute,
      this.startTimeHour,
      this.startTimeMinute,
      this.endTimeHour,
      this.endTimeMinute,
      this.parentId,
      this.type,
      this.isBookable,
      this.isActive,
      this.coordinates,
      this.distance});

  Entity.withValues(entityId, type);
  //SlotDocumentId is entityID#20~06~01 it is not auto-generated, will help in not duplicating the record
  String entityId;
  String name;
  String description;
  String regNum;
  Address address;
  int advanceDays;
  bool isPublic;
  List<MetaUser> admins;
  List<Employee> managers;
  List<MetaEntity> childEntities;
  MyGeoFirePoint geo;
  int maxAllowed;
  int slotDuration;
  List<String> closedOn;
  int breakStartHour;
  int breakStartMinute;
  int breakEndHour;
  int breakEndMinute;
  int startTimeHour;
  int startTimeMinute;
  int endTimeHour;
  int endTimeMinute;
  String parentId;
  String type;
  bool isBookable;
  bool isActive;
  MyGeoFirePoint coordinates;
  double distance;

  Map<String, dynamic> toJson() => {
        'entityId': entityId,
        'name': name,
        'description': description,
        'regNum': regNum,
        'address': address.toJson(),
        'advanceDays': advanceDays,
        'isPublic': isPublic,
        'admins': usersToJson(admins),
        'managers': employeesToJson(managers),
        'childEntities': metaEntitiesToJson(childEntities),
        'maxAllowed': maxAllowed,
        'slotDuration': slotDuration,
        'closedOn': closedOn,
        'breakStartHour': breakStartHour,
        'breakStartMinute': breakStartMinute,
        'breakEndHour': breakEndHour,
        'breakEndMinute': breakEndMinute,
        'startTimeHour': startTimeHour,
        'startTimeMinute': startTimeMinute,
        'endTimeHour': endTimeHour,
        'endTimeMinute': endTimeMinute,
        'parentId': parentId,
        'type': type,
        'isBookable': isBookable,
        'isActive': isActive,
        'coordinates': coordinates.toJson(),
        'nameQuery': constructQueriableList(name),
        'distance': distance
      };

  List<dynamic> usersToJson(List<MetaUser> users) {
    List<dynamic> usersJson = new List<dynamic>();
    if (users == null) return usersJson;
    for (MetaUser usr in users) {
      usersJson.add(usr.toJson());
    }
    return usersJson;
  }

  List<dynamic> employeesToJson(List<Employee> emps) {
    List<dynamic> usersJson = new List<dynamic>();
    if (emps == null) return usersJson;
    for (Employee emp in emps) {
      usersJson.add(emp.toJson());
    }
    return usersJson;
  }

  List<dynamic> metaEntitiesToJson(List<MetaEntity> metaEntities) {
    List<dynamic> usersJson = new List<dynamic>();
    if (metaEntities == null) return usersJson;
    for (MetaEntity meta in metaEntities) {
      usersJson.add(meta.toJson());
    }
    return usersJson;
  }

  static Entity fromJson(Map<String, dynamic> json) {
    if (json == null) return null;
    return new Entity(
        entityId: json['entityId'].toString(),
        name: json['name'].toString(),
        description: json['description'],
        regNum: json['regNum'],
        address: Address.fromJson(json['address']),
        advanceDays: json['advanceDays'],
        isPublic: json['isPublic'],
        admins: convertToUsersFromJson(json['admins']),
        managers: convertToEmployeesFromJson(json['managers']),
        childEntities: convertToMetaEntitiesFromJson(json['childEntities']),
        maxAllowed: json['maxAllowed'],
        slotDuration: json['slotDuration'],
        closedOn: convertToClosedOnArrayFromJson(json['closedOn']),
        breakStartHour: json['breakStartHour'],
        breakStartMinute: json['breakStartMinute'],
        breakEndHour: json['breakEndHour'],
        breakEndMinute: json['breakEndMinute'],
        startTimeHour: json['startTimeHour'],
        startTimeMinute: json['startTimeMinute'],
        endTimeHour: json['endTimeHour'],
        endTimeMinute: json['endTimeMinute'],
        parentId: json['parentId'],
        type: json['type'],
        isBookable: json['isBookable'],
        isActive: json['isActive'],
        coordinates: MyGeoFirePoint.fromJson(json['coordinates']),
        distance: json['distance']);
  }

  static Address convertToAddressFromJson(Map<String, dynamic> json) {
    return Address.fromJson(json);
  }

  static List<MetaUser> convertToUsersFromJson(List<dynamic> usersJson) {
    if (usersJson == null) return null;
    List<MetaUser> users = new List<MetaUser>();

    for (Map<String, dynamic> json in usersJson) {
      MetaUser sl = MetaUser.fromJson(json);
      users.add(sl);
    }
    return users;
  }

  static List<Employee> convertToEmployeesFromJson(List<dynamic> usersJson) {
    if (usersJson == null) return null;
    List<Employee> users = new List<Employee>();

    for (Map<String, dynamic> json in usersJson) {
      Employee emp = Employee.fromJson(json);
      users.add(emp);
    }
    return users;
  }

  static List<MetaEntity> convertToMetaEntitiesFromJson(
      List<dynamic> metaEntityJson) {
    List<MetaEntity> metaEntities = new List<MetaEntity>();

    for (Map<String, dynamic> json in metaEntityJson) {
      MetaEntity metaEnt = MetaEntity.fromJson(json);
      metaEntities.add(metaEnt);
    }
    return metaEntities;
  }

  static List<String> convertToClosedOnArrayFromJson(List<dynamic> daysJson) {
    List<String> days = new List<String>();

    for (String day in daysJson) {
      days.add(day);
    }
    return days;
  }

  MetaEntity getMetaEntity() {
    MetaEntity meta = new MetaEntity(
        entityId: entityId,
        name: name,
        type: type,
        advanceDays: advanceDays,
        isPublic: isPublic,
        closedOn: closedOn,
        breakStartHour: breakStartHour,
        breakStartMinute: breakStartMinute,
        breakEndHour: breakEndHour,
        breakEndMinute: breakEndMinute,
        startTimeHour: startTimeHour,
        startTimeMinute: startTimeMinute,
        endTimeHour: endTimeHour,
        endTimeMinute: endTimeMinute,
        isActive: isActive,
        lat: coordinates.geopoint.latitude,
        lon: coordinates.geopoint.longitude,
        slotDuration: slotDuration,
        maxAllowed: maxAllowed,
        distance: distance);

    return meta;
  }

  int isAdmin(String userId) {
    int count = -1;
    if (admins == null) return count;

    for (MetaUser usr in admins) {
      count++;
      if (usr.id == userId) {
        return count;
      }
    }

    return -1;
  }

  List<String> constructQueriableList(String string) {
    String lowercased = string.toLowerCase();
    List<String> queriables = new List<String>();
    for (int i = 1; i <= lowercased.length; i++) {
      queriables.add(lowercased.substring(0, i));
    }
    return queriables;
  }
}
