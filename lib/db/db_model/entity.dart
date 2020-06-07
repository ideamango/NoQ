import 'package:noq/db/db_model/address.dart';
import 'package:noq/db/db_model/employee.dart';
import 'package:noq/db/db_model/meta_entity.dart';
import 'package:noq/db/db_model/my_geo_fire_point.dart';
import 'package:noq/db/db_model/user.dart';

class Entity {
  Entity(
      {this.entityId,
      this.name,
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
      this.isBookable});

  //SlotDocumentId is entityID#20~06~01 it is not auto-generated, will help in not duplicating the record
  String entityId;
  String name;
  Address address;
  int advanceDays;
  bool isPublic;
  List<User> admins;
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

  Map<String, dynamic> toJson() => {
        'entityId': entityId,
        'name': name,
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
        'isBookable': isBookable
      };

  List<dynamic> usersToJson(List<User> users) {
    List<dynamic> usersJson = new List<dynamic>();
    if (users == null) return usersJson;
    for (User usr in users) {
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
    return new Entity(
        entityId: json['entityId'].toString(),
        name: json['name'].toString(),
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
        isBookable: json['isBookable']);
  }

  static Address convertToAddressFromJson(Map<String, dynamic> json) {
    return Address.fromJson(json);
  }

  static List<User> convertToUsersFromJson(List<dynamic> usersJson) {
    List<User> users = new List<User>();

    for (Map<String, dynamic> json in usersJson) {
      User sl = User.fromJson(json);
      users.add(sl);
    }
    return users;
  }

  static List<Employee> convertToEmployeesFromJson(List<dynamic> usersJson) {
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
}
