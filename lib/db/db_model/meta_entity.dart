import 'package:json_annotation/json_annotation.dart';

/// This allows the `User` class to access private members in
/// the generated file. The value for this is *.g.dart, where
/// the star denotes the source file name.
part 'meta_entity.g.dart';

/// An annotation for the code generator to know that this class needs the
/// JSON serialization logic to be generated.
@JsonSerializable()
class MetaEntity {
  MetaEntity(
      {this.entityId,
      this.name,
      this.type,
      this.advanceDays,
      this.isPublic,
      this.closedOn,
      this.breakStartHour,
      this.breakStartMinute,
      this.breakEndHour,
      this.breakEndMinute,
      this.startTimeHour,
      this.startTimeMinute,
      this.endTimeHour,
      this.endTimeMinute,
      this.isActive,
      this.distance,
      this.address,
      this.lat,
      this.lon,
      this.slotDuration,
      this.maxAllowed,
      this.whatsapp,
      this.parentId,
      this.gpay,
      this.paytm,
      this.applepay});
  MetaEntity.withValues({this.entityId, this.type});

  //SlotDocumentId is entityID#20~06~01 it is not auto-generated, will help in not duplicating the record
  String entityId;
  String name;
  String type;
  int advanceDays;
  bool isPublic;
  List<String> closedOn;
  int breakStartHour;
  int breakStartMinute;
  int breakEndHour;
  int breakEndMinute;
  int startTimeHour;
  int startTimeMinute;
  int endTimeHour;
  int endTimeMinute;
  bool isActive;
  double distance;
  String address;
  double lat;
  double lon;
  int slotDuration;
  int maxAllowed;
  String whatsapp;
  String parentId;
  String gpay;
  String paytm;
  String applepay;

  static MetaEntity fromJson(Map<String, dynamic> json) {
    if (json == null) return null;
    return new MetaEntity(
        entityId: json['entityId'],
        name: json['name'],
        type: json['type'],
        advanceDays: json['advanceDays'],
        isPublic: json['isPublic'],
        closedOn: convertToClosedOnArrayFromJson(json['closedOn']),
        startTimeHour: json['startTimeHour'],
        startTimeMinute: json['startTimeMinute'],
        endTimeHour: json['endTimeHour'],
        endTimeMinute: json['endTimeMinute'],
        isActive: json['isActive'],
        distance: json['distance'],
        address: json['address'],
        lat: json['lat'],
        lon: json['lon'],
        slotDuration: json['slotDuration'],
        maxAllowed: json['maxAllowed'],
        whatsapp: json['whatsapp'],
        parentId: json['parentId'],
        gpay: json['gpay'],
        paytm: json['paytm'],
        applepay: json['applepay']);
  }

  static List<String> convertToClosedOnArrayFromJson(List<dynamic> daysJson) {
    List<String> days = new List<String>();
    if (daysJson == null) return days;

    for (String day in daysJson) {
      days.add(day);
    }
    return days;
  }

  Map<String, dynamic> toJson() => {
        'entityId': entityId,
        'name': name,
        'type': type,
        'advanceDays': advanceDays,
        'isPublic': isPublic,
        'startTimeHour': startTimeHour,
        'startTimeMinute': startTimeMinute,
        'endTimeHour': endTimeHour,
        'endTimeMinute': endTimeMinute,
        'isActive': isActive,
        'distance': distance,
        'lat': lat,
        'lon': lon,
        'slotDuration': slotDuration,
        'maxAllowed': maxAllowed,
        'whatsapp': whatsapp,
        'parentId': parentId,
        'gpay': gpay,
        'paytm': paytm,
        'applepay': applepay
      };

  bool isEqual(MetaEntity metaEnt) {
    if (metaEnt.advanceDays == this.advanceDays &&
        metaEnt.breakStartHour == this.breakStartHour &&
        metaEnt.breakStartMinute == this.breakStartMinute &&
        metaEnt.breakEndHour == this.breakEndHour &&
        metaEnt.breakEndMinute == this.breakEndMinute &&
        metaEnt.startTimeHour == this.startTimeHour &&
        metaEnt.startTimeMinute == this.startTimeMinute &&
        metaEnt.endTimeHour == this.endTimeHour &&
        metaEnt.endTimeMinute == this.endTimeMinute &&
        metaEnt.entityId == this.entityId &&
        metaEnt.isActive == this.isActive &&
        metaEnt.isPublic == this.isPublic &&
        metaEnt.name == this.name &&
        metaEnt.slotDuration == this.slotDuration &&
        metaEnt.lat == this.lat &&
        metaEnt.lon == this.lon &&
        metaEnt.maxAllowed == this.maxAllowed &&
        metaEnt.whatsapp == this.whatsapp) {
      if (this.closedOn != null && metaEnt.closedOn != null) {
        int matchCount = 0;

        for (String day in this.closedOn) {
          for (String val in metaEnt.closedOn) {
            if (day == val) {
              matchCount++;
            }
          }
        }
        if (matchCount == this.closedOn.length) {
          return true;
        }
      }

      if (this.closedOn == null && metaEnt.closedOn == null) {
        return true;
      }
    }
    return false;
  }
}
