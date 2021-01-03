import 'package:noq/db/db_model/slot.dart';

class EntitySlots {
  EntitySlots(
      {this.slots,
      this.entityId,
      this.maxAllowed,
      this.date,
      this.slotDuration,
      this.closedOn,
      this.breakStartHour,
      this.breakStartMinute,
      this.breakEndHour,
      this.breakEndMinute,
      this.startTimeHour,
      this.startTimeMinute,
      this.endTimeHour,
      this.endTimeMinute});

  //SlotDocumentId is entityID#20~06~01 it is not auto-generated, will help in not duplicating the record
  String entityId;
  int maxAllowed;
  DateTime date;
  int slotDuration;
  List<Slot> slots;
  List<String> closedOn;
  int breakStartHour;
  int breakStartMinute;
  int breakEndHour;
  int breakEndMinute;
  int startTimeHour;
  int startTimeMinute;
  int endTimeHour;
  int endTimeMinute;

  static EntitySlots fromJson(Map<String, dynamic> json) {
    if (json == null) return null;
    return new EntitySlots(
        entityId: json['entityId'],
        maxAllowed: json['maxAllowed'],
        date: new DateTime.fromMillisecondsSinceEpoch(
            json['date'].seconds * 1000),
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
