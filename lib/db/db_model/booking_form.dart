import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

class BookingForm {
  String id = Uuid().v1();
  String formName;
  String headerMsg;
  String footerMsg;
  List<Field> formFields;
  bool autoApproved = true;

  //This is not supposed to be created by Entity Manager or Admin, right not will be done via backend on Request.
  //This implies that this BookingForm is global form not specific to any Entity
  bool isSystemTemplate = false;

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
        'autoApproved': autoApproved,
        'isSystemTemplate': isSystemTemplate
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
    BookingForm bf = BookingForm(
        formName: json['formName'],
        headerMsg: json['headerMsg'],
        footerMsg: json['footerMsg'],
        formFields: convertToOptionValuesFromJson(json['formFieldList']),
        autoApproved: json['autoApproved']);

    bf.isSystemTemplate = json['isSystemTemplate'];

    return bf;
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
  bool isMeta = false;
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
        'isMeta': isMeta,
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
    textField.isMeta = json["isMeta"];
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
        'isMeta': isMeta,
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
    numberField.isMeta = json['isMeta'];
    numberField.id = json['id'];
    numberField.response = json['response'];

    return numberField;
  }
}

class FormInputFieldOptions extends Field {
  List<String> options;
  bool isMultiSelect;
  List<String> responseValues;

  FormInputFieldOptions(String label, bool isMandatory, String infoMessage,
      List<String> options, bool isMultiSelect) {
    this.label = label;
    this.isMandatory = isMandatory;
    this.infoMessage = infoMessage;
    this.options = options;
    this.isMultiSelect = isMultiSelect;
    this.type = "OPTIONS";
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'label': label,
        'isMeta': isMeta,
        'isMandatory': isMandatory,
        "infoMessage": infoMessage,
        'options': options,
        'isMultiSelect': isMultiSelect,
        'type': type
      };

  static FormInputFieldOptions fromJson(Map<String, dynamic> json) {
    if (json == null) return null;
    FormInputFieldOptions optionsField = FormInputFieldOptions(
        json['label'],
        json['isMandatory'],
        json['infoMessage'],
        convertToOptionValuesFromJson(json['options']),
        json['isMultiSelect']);
    optionsField.isMeta = json['isMeta'];
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
  List<String> responseFilePaths;
  int maxAttachments = 2;

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
        'isMeta': isMeta,
        'isMandatory': isMandatory,
        "infoMessage": infoMessage,
        'type': type,
        'responseFilePaths': responseFilePaths,
        'maxAttachments': maxAttachments
      };
  static List<String> convertToPathValuesFromJson(List<dynamic> valuesJson) {
    List<String> values = new List<String>();
    if (valuesJson == null) return values;

    for (String value in valuesJson) {
      values.add(value);
    }
    return values;
  }

  static FormInputFieldAttachment fromJson(Map<String, dynamic> json) {
    if (json == null) return null;
    FormInputFieldAttachment attachmentField = FormInputFieldAttachment(
        json['label'], json['isMandatory'], json['infoMessage']);
    attachmentField.isMeta = json['isMeta'];
    attachmentField.id = json['id'];
    attachmentField.responseFilePaths =
        convertToPathValuesFromJson(json['responseFilePaths']);
    attachmentField.maxAttachments = json['maxAttachments'];

    return attachmentField;
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
        'isMeta': isMeta,
        'isMandatory': isMandatory,
        "infoMessage": infoMessage,
        'type': type,
        'responseDateTime': responseDateTime.millisecondsSinceEpoch
      };

  static FormInputFieldDateTime fromJson(Map<String, dynamic> json) {
    if (json == null) return null;
    FormInputFieldDateTime dateTimeField = FormInputFieldDateTime(
        json['label'], json['isMandatory'], json['infoMessage']);
    dateTimeField.isMeta = json['isMeta'];
    dateTimeField.id = json['id'];
    dateTimeField.responseDateTime =
        DateTime.fromMillisecondsSinceEpoch(json['responseDateTime']);

    return dateTimeField;
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
        'isMeta': isMeta,
        'isMandatory': isMandatory,
        "infoMessage": infoMessage,
        'type': type,
        'responsePhone': responsePhone
      };

  static FormInputFieldPhone fromJson(Map<String, dynamic> json) {
    if (json == null) return null;
    FormInputFieldPhone phoneField = FormInputFieldPhone(
        json['label'], json['isMandatory'], json['infoMessage']);
    phoneField.isMeta = json['isMeta'];
    phoneField.id = json['id'];
    phoneField.responsePhone = json['responsePhone'];

    return phoneField;
  }
}

class FormInputFieldOptionsWithAttachments extends Field {
  List<String> options;
  bool isMultiSelect;
  List<String> responseValues;

  List<String> responseFilePaths;
  int maxAttachments = 2;

  FormInputFieldOptionsWithAttachments(String label, bool isMandatory,
      String infoMessage, List<String> options, bool isMultiSelect) {
    this.label = label;
    this.isMandatory = isMandatory;
    this.infoMessage = infoMessage;
    this.options = options;
    this.isMultiSelect = isMultiSelect;
    this.type = "OPTIONS_ATTACHMENTS";
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'label': label,
        'isMeta': isMeta,
        'isMandatory': isMandatory,
        "infoMessage": infoMessage,
        'options': options,
        'isMultiSelect': isMultiSelect,
        'type': type,
        'responseFilePaths': responseFilePaths,
        'maxAttachments': maxAttachments
      };

  static FormInputFieldOptionsWithAttachments fromJson(
      Map<String, dynamic> json) {
    if (json == null) return null;
    FormInputFieldOptionsWithAttachments optionsFieldWithAttachments =
        FormInputFieldOptionsWithAttachments(
            json['label'],
            json['isMandatory'],
            json['infoMessage'],
            convertToValuesFromJson(json['options']),
            json['isMultiSelect']);
    optionsFieldWithAttachments.isMeta = json["isMeta"];
    optionsFieldWithAttachments.id = json['id'];
    optionsFieldWithAttachments.responseFilePaths =
        convertToValuesFromJson(json['responseFilePaths']);
    optionsFieldWithAttachments.maxAttachments = json['maxAttachments'];
    return optionsFieldWithAttachments;
  }

  static List<String> convertToValuesFromJson(List<dynamic> valuesJson) {
    List<String> values = new List<String>();
    if (valuesJson == null) return values;

    for (String value in valuesJson) {
      values.add(value);
    }
    return values;
  }
}
