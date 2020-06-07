import 'package:noq/db/db_model/address.dart';
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
      this.children,
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
      this.type});

  //SlotDocumentId is entityID#20~06~01 it is not auto-generated, will help in not duplicating the record
  String entityId;
  String name;
  Address address;
  int advanceDays;
  bool isPublic;
  List<User> admins;
  List<User> managers;
  List<MetaEntity> children;
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

  static Entity fromJson(Map<String, dynamic> json) {
    return new Entity(
        entityId: json['entityId'].toString(),
        name: json['name'].toString(),
        address: Address.fromJson(json['address']),
        advanceDays: json['advanceDays'],
        isPublic: json['isPublic'],
        maxAllowed: json['maxAllowed'],
        slotDuration: json['slotDuration'],
        slots: convertToSlotsFromJson(json['slots']),
        closedOn: convertToClosedOnArrayFromJson(json['closedOn']),
        breakStartHour: json['breakStartHour'],
        breakStartMinute: json['breakStartMinute'],
        breakEndHour: json['breakEndHour'],
        breakEndMinute: json['breakEndMinute'],
        startTimeHour: json['startTimeHour'],
        startTimeMinute: json['startTimeMinute'],
        endTimeHour: json['endTimeHour'],
        endTimeMinute: json['endTimeMinute']);
  }

  static Address convertToAddressFromJson(Map<String, dynamic> json)
  {
    return Address.fromJson(json)
  }

  static List<Slot> convertToSlotsFromJson(List<dynamic> slotsJson) {
    List<Slot> slots = new List<Slot>();

    for (Map<String, dynamic> json in slotsJson) {
      Slot sl = Slot.fromJson(json);
      slots.add(sl);
    }
    return slots;
  }

  static List<String> convertToClosedOnArrayFromJson(List<dynamic> daysJson) {
    List<String> days = new List<String>();

    for (String day in daysJson) {
      days.add(day);
    }
    return days;
  }

  Map<String, dynamic> toJson() => {
        'entityId': entityId,
        'maxAllowed': maxAllowed,
        'date': date,
        'slotDuration': slotDuration,
        'slots': slotsToJson(slots),
        'closedOn': closedOn,
        'breakStartHour': breakStartHour,
        'breakStartMinute': breakStartMinute,
        'breakEndHour': breakEndHour,
        'breakEndMinute': breakEndMinute,
        'startTimeHour': startTimeHour,
        'startTimeMinute': startTimeMinute,
        'endTimeHour': endTimeHour,
        'endTimeMinute': endTimeMinute
      };

  List<dynamic> slotsToJson(List<Slot> slots) {
    List<dynamic> slotsJson = new List<dynamic>();
    for (Slot sl in slots) {
      slotsJson.add(sl.toJson());
    }
    return slotsJson;
  }
}
