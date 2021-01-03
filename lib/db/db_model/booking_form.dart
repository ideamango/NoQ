import 'package:flutter/material.dart';

class BookingForm {
  String formName;
  String headerMsg;
  String footerMsg;
  List<Field> formFieldList;
  bool autoApproved;

  BookingForm(
      {@required this.formName,
      @required this.headerMsg,
      this.footerMsg,
      @required this.formFieldList,
      this.autoApproved});

  Map<String, dynamic> toJson() => {
        'formName': formName,
        'headerMsg': headerMsg,
        'footerMsg': footerMsg,
        'formFieldList': formFieldsToJson(formFieldList),
        'autoApproved': autoApproved
      };

  List<dynamic> formFieldsToJson(List<Field> fields) {
    List<dynamic> fieldsJson = new List<dynamic>();
    for (Field sl in fields) {
      fieldsJson.add(sl.toJson());
    }
    return fieldsJson;
  }

  static BookingForm fromJson(Map<String, dynamic> json) {
    if (json == null) return null;
    return new BookingForm(
        formName: json['formName'],
        headerMsg: json['headerMsg'],
        footerMsg: json['footerMsg'],
        formFieldList: convertToOptionValuesFromJson(json['formFieldList']),
        autoApproved: json['autoApproved']);
  }

  static List<Field> convertToOptionValuesFromJson(List<dynamic> fieldsJson) {
    List<Field> values = new List<Field>();
    if (fieldsJson == null) return values;

    for (Map<String, dynamic> value in fieldsJson) {
      if (value.containsKey("TEXT")) {
        values.add(FormInputFieldText.fromJson(value));
      } else if (value.containsKey("NUMBER")) {
        values.add(FormInputFieldNumber.fromJson(value));
      } else if (value.containsKey("OPTIONS")) {
        values.add(FormInputFieldOptions.fromJson(value));
      }
    }
    return values;
  }
}

class Field {
  String label;
  bool isMandatory;
  String infoMessage;
  Map<String, dynamic> toJson() => {
        //action implementation is in the derived classes
      };
}

class FormInputFieldText extends Field {
  int maxLength;
  String type = "TEXT";

  FormInputFieldText(
      String label, bool isMandatory, String infoMessage, int maxLength) {
    this.label = label;
    this.isMandatory = isMandatory;
    this.infoMessage = infoMessage;
    this.maxLength = maxLength;
  }

  Map<String, dynamic> toJson() => {
        'maxLength': maxLength,
        'label': label,
        'isMandatory': isMandatory,
        "infoMessage": infoMessage,
        "type": type
      };

  static FormInputFieldText fromJson(Map<String, dynamic> json) {
    if (json == null) return null;
    return new FormInputFieldText(json['label'], json['isMandatory'],
        json['infoMessage'], json['maxLength']);
  }
}

class FormInputFieldNumber extends Field {
  double maxValue;
  double minValue;
  String type = "NUMBER";

  FormInputFieldNumber(String label, bool isMandatory, String infoMessage,
      double minValue, double maxValue) {
    this.label = label;
    this.isMandatory = isMandatory;
    this.minValue = minValue;
    this.infoMessage = infoMessage;
    this.maxValue = maxValue;
  }
  Map<String, dynamic> toJson() => {
        'label': label,
        'isMandatory': isMandatory,
        "infoMessage": infoMessage,
        'minValue': minValue,
        'maxValue': maxValue,
        'type': type
      };

  static FormInputFieldNumber fromJson(Map<String, dynamic> json) {
    if (json == null) return null;
    return new FormInputFieldNumber(json['label'], json['isMandatory'],
        json['infoMessage'], json['minValue'], json['maxValue']);
  }
}

class FormInputFieldOptions extends Field {
  String label;
  bool isMandatory;
  String infoMessage;
  List<String> values;
  bool isMultiSelect;
  String type = "OPTIONS";

  FormInputFieldOptions(String label, bool isMandatory, String infoMessage,
      List<String> values, bool isMultiSelect) {
    this.label = label;
    this.isMandatory = isMandatory;
    this.infoMessage = infoMessage;
    this.values = values;
    this.isMultiSelect = isMultiSelect;
  }

  Map<String, dynamic> toJson() => {
        'label': label,
        'isMandatory': isMandatory,
        "infoMessage": infoMessage,
        'values': values,
        'isMultiSelect': isMultiSelect,
        'type': type
      };

  static FormInputFieldOptions fromJson(Map<String, dynamic> json) {
    if (json == null) return null;
    return new FormInputFieldOptions(
        json['label'],
        json['isMandatory'],
        json['infoMessage'],
        convertToOptionValuesFromJson(json['maxValue']),
        json['isMultiSelect']);
  }

  static List<String> convertToOptionValuesFromJson(List<dynamic> valuesJson) {
    List<String> values = new List<String>();
    if (valuesJson == null) return values;

    for (String value in valuesJson) {
      values.add(value);
    }
    return values;
  }
}
