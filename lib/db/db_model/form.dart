import 'package:flutter/material.dart';

class EntityForm {
  String formName;
  String headerMsg;
  String footerMsg;
  List<Field> formFieldList;
}

class Field {}

class FormInputFieldText extends Field {
  String label;
  bool isMandatory;
  String infoMessage;
  int maxLength;

  FormInputFieldText(
      {@required this.label,
      @required this.isMandatory,
      this.infoMessage,
      @required this.maxLength});

  Map<String, dynamic> toJson() => {
        'maxLength': maxLength,
        'label': label,
        'isMandatory': isMandatory,
        "infoMessage": infoMessage
      };

  static FormInputFieldText fromJson(Map<String, dynamic> json) {
    if (json == null) return null;
    return new FormInputFieldText(
        label: json['label'],
        isMandatory: json['isMandatory'],
        infoMessage: json['infoMessage'],
        maxLength: json['maxLength']);
  }
}

class FormInputFieldNumber extends Field {
  String label;
  bool isMandatory;
  String infoMessage;
  double maxValue;
  double minValue;

  FormInputFieldNumber(
      {@required this.label,
      @required this.isMandatory,
      this.infoMessage,
      this.maxValue,
      this.minValue});

  Map<String, dynamic> toJson() => {
        'label': label,
        'isMandatory': isMandatory,
        "infoMessage": infoMessage,
        'maxValue': maxValue,
        'minValue': minValue
      };

  static FormInputFieldNumber fromJson(Map<String, dynamic> json) {
    if (json == null) return null;
    return new FormInputFieldNumber(
        label: json['label'],
        isMandatory: json['isMandatory'],
        infoMessage: json['infoMessage'],
        maxValue: json['maxValue'],
        minValue: json['minValue']);
  }
}

class FormInputFieldOptions extends Field {
  String label;
  bool isMandatory;
  String infoMessage;
  List<String> values;
  bool isMultiSelect;

  FormInputFieldOptions(
      {@required this.label,
      @required this.isMandatory,
      @required this.infoMessage,
      @required this.values,
      @required this.isMultiSelect});

  Map<String, dynamic> toJson() => {
        'label': label,
        'isMandatory': isMandatory,
        "infoMessage": infoMessage,
        'values': values,
        'isMultiSelect': isMultiSelect
      };

  static FormInputFieldOptions fromJson(Map<String, dynamic> json) {
    if (json == null) return null;
    return new FormInputFieldOptions(
        label: json['label'],
        isMandatory: json['isMandatory'],
        infoMessage: json['infoMessage'],
        values: convertToOptionValuesFromJson(json['maxValue']),
        isMultiSelect: json['isMultiSelect']);
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
