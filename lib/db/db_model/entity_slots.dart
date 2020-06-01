import 'package:noq/db/db_model/slot.dart';

class EntitySlots {
  EntitySlots(
      {this.entityId,
      this.maxAllowed,
      this.date,
      this.slotDuration,
      this.slots});

  //SlotDocumentId is entityID#20~06~01 it is not auto-generated, will help in not duplicating the record
  String entityId;
  int maxAllowed;
  DateTime date;
  int slotDuration;
  List<Slot> slots;

  static EntitySlots fromJson(Map<String, dynamic> json) {
    return new EntitySlots(
        entityId: json['entityId'].toString(),
        maxAllowed: json['maxAllowed'],
        date: new DateTime.fromMillisecondsSinceEpoch(
            json['date'].seconds * 1000),
        slotDuration: json['slotDuration'],
        slots: json['slots']);
  }

  static List<Slot> convertToSlotsFromJson(Map<String, dynamic> slotsMap) {}
}
