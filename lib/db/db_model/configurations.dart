import 'package:enum_to_string/enum_to_string.dart';
import './meta_form.dart';
import '../../enum/entity_type.dart';
import '../../utils.dart';

class Configurations {
  Configurations(
      {this.entityTypes,
      this.messages,
      this.keyMessage,
      this.contactEmail,
      this.contactPhone,
      this.whatsappPhone,
      this.supportReasons,
      this.phCountryCode,
      this.searchRadius,
      this.bookingDataFromDays,
      this.bookingDataToDays,
      this.donation,
      this.formToEntityTypeMapping,
      this.formMetaData,
      this.latestVersion,
      this.typeToChildType,
      this.androidAppVersionToEntityTypes,
      this.iosAppVersionToEntityTypes,
      this.upi});

  List<String> entityTypes;
  List<String> messages;
  String keyMessage;
  String contactEmail;
  String contactPhone;
  String whatsappPhone;
  List<String> supportReasons;
  String phCountryCode;
  int searchRadius;
  int bookingDataFromDays;
  int bookingDataToDays;
  Map<String, String> donation;

  Map<String, String> formToEntityTypeMapping;
  List<MetaForm> formMetaData;
  Map<String, String> latestVersion;
  Map<String, List<String>> typeToChildType;
  Map<String, List<String>> androidAppVersionToEntityTypes;
  Map<String, List<String>> iosAppVersionToEntityTypes;
  String upi;

  Map<String, dynamic> toJson() => {
        'entityTypes': entityTypes,
        'messages': messages,
        'keyMessage': keyMessage,
        'contactEmail': contactEmail,
        'contactPhone': contactPhone,
        'whatsappPhone': whatsappPhone,
        'supportReasons': supportReasons,
        'phCountryCode': phCountryCode,
        'searchRadius': searchRadius,
        'bookingDataFromDays': bookingDataFromDays,
        'bookingDataToDays': bookingDataToDays,
        'donation': convertFromMap(donation),
        'formToEntityTypeMapping': convertFromMap(formToEntityTypeMapping),
        'formMetaData': metaFormsToJson(formMetaData),
        'latestVersion': convertFromMap(latestVersion),
        'typeToChildType': convertFromMapOfList(typeToChildType),
        'androidAppVersionToEntityTypes':
            convertFromMapOfList(androidAppVersionToEntityTypes),
        'iosAppVersionToEntityTypes':
            convertFromMapOfList(iosAppVersionToEntityTypes),
        'upi': upi
      };

  Map<String, dynamic> convertFromMap(Map<String, String> dailyStats) {
    if (dailyStats == null) {
      return null;
    }

    Map<String, dynamic> map = Map<String, dynamic>();
    dailyStats.forEach((k, v) => map[k] = v);
    return map;
  }

  Map<String, dynamic> convertFromMapOfList(
      Map<String, List<String>> dailyStats) {
    if (dailyStats == null) {
      return null;
    }

    Map<String, dynamic> map = Map<String, dynamic>();
    dailyStats.forEach((k, v) => map[k] = v);
    return map;
  }

  List<dynamic> metaFormsToJson(List<MetaForm> metaForms) {
    List<dynamic> metaFormsJson = [];
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
        phCountryCode: json['phCountryCode'],
        searchRadius: json['searchRadius'],
        bookingDataFromDays: json['bookingDataFromDays'],
        bookingDataToDays: json['bookingDataToDays'],
        donation: convertToMapFromJSON(json['donation']),
        formToEntityTypeMapping:
            convertToMapFromJSON(json['formToEntityTypeMapping']),
        formMetaData: convertToFormMetaData(json['formMetaData']),
        latestVersion: convertToMapFromJSON(json['latestVersion']),
        typeToChildType: convertToMapOfList(json['typeToChildType']),
        androidAppVersionToEntityTypes:
            convertToMapOfList(json['androidAppVersionToEntityTypes']),
        iosAppVersionToEntityTypes:
            convertToMapOfList(json['iosAppVersionToEntityTypes']),
        upi: json['upi']);
  }

  static List<MetaForm> convertToFormMetaData(List<dynamic> json) {
    List<MetaForm> metaForms = [];
    if (json == null) return metaForms;

    for (Map<String, dynamic> metaFormJson in json) {
      MetaForm sl = MetaForm.fromJson(metaFormJson);
      metaForms.add(sl);
    }
    return metaForms;
  }

  static Map<String, List<String>> convertToMapOfList(
      Map<String, dynamic> json) {
    if (json == null) {
      return null;
    }
    Map<String, List<String>> map = new Map<String, List<String>>();

    json.forEach((k, v) {
      map[k] = convertToStringsArrayFromJson(v);
    });

    return map;
  }

  static List<String> convertToStringsArrayFromJson(List<dynamic> json) {
    List<String> strs = [];
    if (Utils.isNullOrEmpty(json)) return strs;

    for (String str in json) {
      strs.add(str);
    }
    return strs;
  }

  List<MetaForm> getMetaForms(EntityType eType) {
    List<MetaForm> forms = [];
    if (this.formToEntityTypeMapping == null) {
      return forms;
    }

    this.formToEntityTypeMapping.forEach((k, v) {
      if (v == EnumToString.convertToString(eType)) {
        for (MetaForm form in this.formMetaData) {
          if (form.id == k) {
            forms.add(form);
            break;
          }
        }
      }
    });

    return forms;
  }

  bool isDonationEnabled() {
    if (donation != null &&
        donation.containsKey("isEnabled") &&
        donation["isEnabled"].toLowerCase() == "true") {
      return true;
    }
    return false;
  }

  String getDonationMessage() {
    if (donation != null && donation.containsKey("message")) {
      return donation["message"];
    }
    return "";
  }
}
