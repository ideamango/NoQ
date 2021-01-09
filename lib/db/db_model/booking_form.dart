import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

class BookingForm {
  String id = Uuid().v1();
  String formName;
  String headerMsg;
  String footerMsg;
  List<Field> formFields;
  bool autoApproved = true;

  BookingForm(
      {@required this.formName,
      @required this.headerMsg,
      this.footerMsg,
      @required this.formFields,
      this.autoApproved});

  Map<String, dynamic> toJson() => {
        'formName': formName,
        'headerMsg': headerMsg,
        'footerMsg': footerMsg,
        'formFieldList': formFieldsToJson(formFields),
        'autoApproved': autoApproved
      };

  List<dynamic> formFieldsToJson(List<Field> fields) {
    List<dynamic> fieldsJson = new List<dynamic>();
    if (fields == null) return null;
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
        formFields: convertToOptionValuesFromJson(json['formFieldList']),
        autoApproved: json['autoApproved']);
  }

  static List<Field> convertToOptionValuesFromJson(List<dynamic> fieldsJson) {
    List<Field> values = new List<Field>();
    if (fieldsJson == null) return null;

    for (Map<String, dynamic> value in fieldsJson) {
      if (value["type"] == "TEXT") {
        values.add(FormInputFieldText.fromJson(value));
      } else if (value["type"] == "NUMBER") {
        values.add(FormInputFieldNumber.fromJson(value));
      } else if (value["type"] == "OPTIONS") {
        values.add(FormInputFieldOptions.fromJson(value));
      }
    }
    return values;
  }
}

class Field {
  String id = Uuid().v1();
  String label;
  bool isMandatory;
  String infoMessage;
  String type;
  Map<String, dynamic> toJson() => {
        //action implementation is in the derived classes
      };
}

class FormInputFieldText extends Field {
  int maxLength;
  String response;

  FormInputFieldText(
      String label, bool isMandatory, String infoMessage, int maxLength) {
    this.label = label;
    this.isMandatory = isMandatory;
    this.infoMessage = infoMessage;
    this.maxLength = maxLength;
    this.type = "TEXT";
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'maxLength': maxLength,
        'label': label,
        'isMandatory': isMandatory,
        "infoMessage": infoMessage,
        "type": type,
        'response': response
      };

  static FormInputFieldText fromJson(Map<String, dynamic> json) {
    if (json == null) return null;

    FormInputFieldText textField = FormInputFieldText(json['label'],
        json['isMandatory'], json['infoMessage'], json['maxLength']);

    textField.id = json["id"];
    textField.response = json['response'];

    return textField;
  }
}

class FormInputFieldNumber extends Field {
  double maxValue;
  double minValue;

  double response;

  FormInputFieldNumber(String label, bool isMandatory, String infoMessage,
      double minValue, double maxValue) {
    this.label = label;
    this.isMandatory = isMandatory;
    this.minValue = minValue;
    this.infoMessage = infoMessage;
    this.maxValue = maxValue;
    this.type = "NUMBER";
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'label': label,
        'isMandatory': isMandatory,
        "infoMessage": infoMessage,
        'minValue': minValue,
        'maxValue': maxValue,
        'type': type,
        'response': response
      };

  static FormInputFieldNumber fromJson(Map<String, dynamic> json) {
    if (json == null) return null;
    FormInputFieldNumber numberField = FormInputFieldNumber(
        json['label'],
        json['isMandatory'],
        json['infoMessage'],
        json['minValue'],
        json['maxValue']);

    numberField.id = json['id'];
    numberField.response = json['response'];

    return numberField;
  }
}

class FormInputFieldOptions extends Field {
  List<String> values;
  bool isMultiSelect;
  List<String> responseValues;

  FormInputFieldOptions(String label, bool isMandatory, String infoMessage,
      List<String> values, bool isMultiSelect) {
    this.label = label;
    this.isMandatory = isMandatory;
    this.infoMessage = infoMessage;
    this.values = values;
    this.isMultiSelect = isMultiSelect;
    this.type = "OPTIONS";
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'label': label,
        'isMandatory': isMandatory,
        "infoMessage": infoMessage,
        'values': values,
        'isMultiSelect': isMultiSelect,
        'type': type
      };

  static FormInputFieldOptions fromJson(Map<String, dynamic> json) {
    if (json == null) return null;
    FormInputFieldOptions optionsField = FormInputFieldOptions(
        json['label'],
        json['isMandatory'],
        json['infoMessage'],
        convertToOptionValuesFromJson(json['values']),
        json['isMultiSelect']);

    optionsField.id = json['id'];
    return optionsField;
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

class FormInputFieldAttachment extends Field {
  String responseFilePath;

  FormInputFieldAttachment(
    String label,
    bool isMandatory,
    String infoMessage,
  ) {
    this.label = label;
    this.isMandatory = isMandatory;
    this.infoMessage = infoMessage;
    this.type = "ATTACHMENT";
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'label': label,
        'isMandatory': isMandatory,
        "infoMessage": infoMessage,
        'type': type,
        'responseFilePath': responseFilePath
      };

  static FormInputFieldAttachment fromJson(Map<String, dynamic> json) {
    if (json == null) return null;
    FormInputFieldAttachment numberField = FormInputFieldAttachment(
        json['label'], json['isMandatory'], json['infoMessage']);

    numberField.id = json['id'];
    numberField.responseFilePath = json['responseFilePath'];

    return numberField;
  }
}

class FormInputFieldDateTime extends Field {
  DateTime responseDateTime;

  FormInputFieldDateTime(
    String label,
    bool isMandatory,
    String infoMessage,
  ) {
    this.label = label;
    this.isMandatory = isMandatory;
    this.infoMessage = infoMessage;
    this.type = "DATETIME";
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'label': label,
        'isMandatory': isMandatory,
        "infoMessage": infoMessage,
        'type': type,
        'responseDateTime': responseDateTime.millisecondsSinceEpoch
      };

  static FormInputFieldDateTime fromJson(Map<String, dynamic> json) {
    if (json == null) return null;
    FormInputFieldDateTime numberField = FormInputFieldDateTime(
        json['label'], json['isMandatory'], json['infoMessage']);

    numberField.id = json['id'];
    numberField.responseDateTime =
        DateTime.fromMillisecondsSinceEpoch(json['responseDateTime']);

    return numberField;
  }
}

class FormInputFieldPhone extends Field {
  String responsePhone;
  String
      countryCode; //e.g. +91, this is to be set while creating the field in the booking form

  FormInputFieldPhone(String label, bool isMandatory, String infoMessage) {
    this.label = label;
    this.isMandatory = isMandatory;
    this.infoMessage = infoMessage;
    this.type = "DATETIME";
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'label': label,
        'isMandatory': isMandatory,
        "infoMessage": infoMessage,
        'type': type,
        'responsePhone': responsePhone
      };

  static FormInputFieldPhone fromJson(Map<String, dynamic> json) {
    if (json == null) return null;
    FormInputFieldPhone numberField = FormInputFieldPhone(
        json['label'], json['isMandatory'], json['infoMessage']);

    numberField.id = json['id'];
    numberField.responsePhone = json['responsePhone'];

    return numberField;
  }
}
