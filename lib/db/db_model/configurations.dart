import 'package:noq/utils.dart';

class Configurations {
  Configurations(
      {this.entityTypes,
      this.messages,
      this.keyMessage,
      this.contactEmail,
      this.contactPhone,
      this.whatsappPhone,
      this.supportReasons,
      this.enableDonation,
      this.phCountryCode,
      this.searchRadius,
      this.bookingDataFromDays,
      this.bookingDataToDays,
      this.formToEntityTypeMapping});

  List<String> entityTypes;
  List<String> messages;
  String keyMessage;
  String contactEmail;
  String contactPhone;
  String whatsappPhone;
  List<String> supportReasons;
  bool enableDonation;
  String phCountryCode;
  int searchRadius;
  int bookingDataFromDays;
  int bookingDataToDays;
  Map<String, String> formToEntityTypeMapping;

  Map<String, dynamic> toJson() => {
        'entityTypes': entityTypes,
        'messages': messages,
        'keyMessage': keyMessage,
        'contactEmail': contactEmail,
        'contactPhone': contactPhone,
        'whatsappPhone': whatsappPhone,
        'supportReasons': supportReasons,
        'enableDonation': enableDonation,
        'phCountryCode': phCountryCode,
        'searchRadius': searchRadius,
        'bookingDataFromDays': bookingDataFromDays,
        'bookingDataToDays': bookingDataToDays,
        'formToEntityTypeMapping': convertFromMap(formToEntityTypeMapping)
      };

  Map<String, dynamic> convertFromMap(Map<String, String> dailyStats) {
    if (dailyStats == null) {
      return null;
    }

    Map<String, dynamic> map = Map<String, dynamic>();
    dailyStats.forEach((k, v) => map[k] = v);
    return map;
  }

  static Map<String, String> convertToMapFromJSON(Map<dynamic, dynamic> map) {
    Map<String, String> roles = new Map<String, String>();
    if (map != null) {
      map.forEach((k, v) => roles[k] = v);
    }
    return roles;
  }

  static Configurations fromJson(Map<String, dynamic> json) {
    if (json == null) return null;
    return new Configurations(
        entityTypes: convertToStringsArrayFromJson(json['entityTypes']),
        messages: convertToStringsArrayFromJson(json['messages']),
        keyMessage: json['keyMessage'],
        contactEmail: json['contactEmail'],
        contactPhone: json['contactPhone'],
        whatsappPhone: json['whatsappPhone'],
        supportReasons: convertToStringsArrayFromJson(json['supportReasons']),
        enableDonation: json['enableDonation'],
        phCountryCode: json['phCountryCode'],
        searchRadius: json['searchRadius'],
        bookingDataFromDays: json['bookingDataFromDays'],
        bookingDataToDays: json['bookingDataToDays'],
        formToEntityTypeMapping:
            convertToMapFromJSON(json['formToEntityTypeMapping']));
  }

  static List<String> convertToStringsArrayFromJson(List<dynamic> json) {
    List<String> strs = new List<String>();
    if (Utils.isNullOrEmpty(json)) return strs;

    for (String str in json) {
      strs.add(str);
    }
    return strs;
  }
}
