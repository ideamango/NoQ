import 'package:noq/db/db_model/meta_form.dart';
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
      this.formToEntityTypeMapping,
      this.formMetaData});

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
  List<MetaForm> formMetaData;

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
        'formToEntityTypeMapping': convertFromMap(formToEntityTypeMapping),
        'formMetaData': metaFormsToJson(formMetaData)
      };

  Map<String, dynamic> convertFromMap(Map<String, String> dailyStats) {
    if (dailyStats == null) {
      return null;
    }

    Map<String, dynamic> map = Map<String, dynamic>();
    dailyStats.forEach((k, v) => map[k] = v);
    return map;
  }

  List<dynamic> metaFormsToJson(List<MetaForm> metaForms) {
    List<dynamic> metaFormsJson = new List<dynamic>();
    if (metaForms == null) return metaFormsJson;
    for (MetaForm metaForm in metaForms) {
      metaFormsJson.add(metaForm.toJson());
    }
    return metaFormsJson;
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
            convertToMapFromJSON(json['formToEntityTypeMapping']),
        formMetaData: convertToFormMetaData(json['formMetaData']));
  }

  static List<MetaForm> convertToFormMetaData(List<dynamic> json) {
    List<MetaForm> metaForms = new List<MetaForm>();
    if (json == null) return metaForms;

    for (Map<String, dynamic> metaFormJson in json) {
      MetaForm sl = MetaForm.fromJson(metaFormJson);
      metaForms.add(sl);
    }
    return metaForms;
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
