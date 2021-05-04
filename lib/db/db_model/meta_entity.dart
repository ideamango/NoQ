import 'package:enum_to_string/enum_to_string.dart';

import '../../enum/entity_type.dart';
import 'meta_form.dart';
import 'offer.dart';

/// This allows the `User` class to access private members in
/// the generated file. The value for this is *.g.dart, where
/// the star denotes the source file name.

class MetaEntity {
  MetaEntity(
      {this.entityId = "",
      this.name = "",
      this.type,
      this.advanceDays = 0,
      this.isPublic = false,
      this.closedOn,
      this.breakStartHour = 0,
      this.breakStartMinute = 0,
      this.breakEndHour = 0,
      this.breakEndMinute = 0,
      this.startTimeHour = 0,
      this.startTimeMinute = 0,
      this.endTimeHour = 0,
      this.endTimeMinute = 0,
      this.isActive = false,
      this.distance = 0,
      this.address = "",
      this.lat = 0,
      this.lon = 0,
      this.slotDuration = 0,
      this.maxAllowed = 0,
      this.whatsapp = "",
      this.parentId = "",
      this.upiId = "",
      this.upiPhoneNumber = "",
      this.upiQRImagePath = "",
      this.offer,
      this.phone = "",
      this.hasChildren = false,
      this.isBookable = false,
      this.forms,
      this.maxTokensPerSlotByUser = 1,
      this.maxPeoplePerToken = 1,
      this.parentGroupId = "",
      this.supportEmail = "",
      this.maxTokenByUserInDay,
      this.enableVideoChat = false});

  MetaEntity.withValues({this.entityId, this.type});

  //SlotDocumentId is entityID#20~06~01 it is not auto-generated, will help in not duplicating the record
  String entityId;
  String name;
  EntityType type;
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
  String upiId;
  String upiPhoneNumber;
  String upiQRImagePath;
  Offer offer;
  String phone;
  bool hasChildren;
  bool isBookable;
  List<MetaForm> forms;
  int maxTokensPerSlotByUser;
  int maxPeoplePerToken;
  String parentGroupId;
  String supportEmail;
  int maxTokenByUserInDay;
  bool enableVideoChat;

  static MetaEntity fromJson(Map<String, dynamic> json) {
    if (json == null) return null;
    return new MetaEntity(
        entityId: json['entityId'],
        name: json['name'],
        type: EnumToString.fromString(EntityType.values, json['type']),
        advanceDays: json['advanceDays'],
        isPublic: json['isPublic'],
        closedOn: convertToClosedOnArrayFromJson(json['closedOn']),
        startTimeHour: json['startTimeHour'],
        startTimeMinute: json['startTimeMinute'],
        breakStartHour: json['breakStartHour'],
        breakStartMinute: json['breakStartMinute'],
        breakEndHour: json['breakEndHour'],
        breakEndMinute: json['breakEndMinute'],
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
        upiId: json['upiId'],
        upiPhoneNumber: json['upiPhoneNumber'],
        upiQRImagePath: json['upiQRImagePath'],
        offer: Offer.fromJson(json['offer']),
        phone: json['phone'],
        hasChildren: json['hasChildren'],
        isBookable: json['isBookable'],
        forms: convertToMetaFormsFromJson(json['forms']),
        maxTokensPerSlotByUser: json['maxTokensPerSlotByUser'],
        maxPeoplePerToken: json['maxPeoplePerToken'],
        parentGroupId: json['parentGroupId'],
        supportEmail: json['supportEmail'],
        maxTokenByUserInDay: json['maxTokenByUserInDay'],
        enableVideoChat: json['enableVideoChat']);
  }

  static List<String> convertToClosedOnArrayFromJson(List<dynamic> daysJson) {
    List<String> days = [];
    if (daysJson == null) return days;

    for (String day in daysJson) {
      days.add(day);
    }
    return days;
  }

  static List<MetaForm> convertToMetaFormsFromJson(List<dynamic> metaFormJson) {
    List<MetaForm> metaForms = [];
    if (metaFormJson == null) return metaForms;

    for (Map<String, dynamic> json in metaFormJson) {
      MetaForm metaEnt = MetaForm.fromJson(json);
      metaForms.add(metaEnt);
    }
    return metaForms;
  }

  List<dynamic> metaFormsToJson(List<MetaForm> metaForms) {
    List<dynamic> usersJson = [];
    if (metaForms == null) return usersJson;
    for (MetaForm meta in metaForms) {
      usersJson.add(meta.toJson());
    }
    return usersJson;
  }

  Map<String, dynamic> toJson() => {
        'entityId': entityId,
        'name': name,
        'type': EnumToString.convertToString(type),
        'advanceDays': advanceDays,
        'isPublic': isPublic,
        'startTimeHour': startTimeHour,
        'startTimeMinute': startTimeMinute,
        'breakStartHour': breakStartHour,
        'breakStartMinute': breakStartMinute,
        'breakEndHour': breakEndHour,
        'breakEndMinute': breakEndMinute,
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
        'upiId': upiId,
        'upiPhoneNumber': upiPhoneNumber,
        'upiQRImagePath': upiQRImagePath,
        'offer': offer != null ? offer.toJson() : null,
        'phone': phone,
        'hasChildren': hasChildren,
        'isBookable': isBookable,
        'forms': metaFormsToJson(forms),
        'maxTokensPerSlotByUser': maxTokensPerSlotByUser,
        'maxPeoplePerToken': maxPeoplePerToken,
        'parentGroupId': parentGroupId,
        'supportEmail': supportEmail,
        'maxTokenByUserInDay': maxTokenByUserInDay,
        'enableVideoChat': enableVideoChat
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
        metaEnt.whatsapp == this.whatsapp &&
        metaEnt.upiId == this.upiId &&
        metaEnt.upiPhoneNumber == this.upiPhoneNumber &&
        metaEnt.upiQRImagePath == this.upiQRImagePath &&
        metaEnt.isBookable == this.isBookable &&
        metaEnt.maxTokensPerSlotByUser == this.maxTokensPerSlotByUser &&
        metaEnt.maxPeoplePerToken == this.maxPeoplePerToken &&
        metaEnt.maxTokenByUserInDay == this.maxTokenByUserInDay &&
        metaEnt.enableVideoChat == this.enableVideoChat) {
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
