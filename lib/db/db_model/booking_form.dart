import 'package:enum_to_string/enum_to_string.dart';
import 'package:flutter/material.dart';
import 'package:noq/enum/field_type.dart';
import 'package:uuid/uuid.dart';

class BookingForm {
  String id = Uuid().v1();
  String formName;
  String headerMsg;
  String footerMsg;
  List<Field> _formFields;
  bool autoApproved = true;

  //This is not supposed to be created by Entity Manager or Admin, right not will be done via backend on Request.
  //This implies that this BookingForm is global form not specific to any Entity
  bool isSystemTemplate = false;

  BookingForm(
      {@required this.formName,
      @required this.headerMsg,
      this.footerMsg,
      this.autoApproved});

  String addField(Field field) {
    if (_formFields == null) {
      _formFields = List<Field>();
    }
    int numberOfFields = _formFields.length;
    numberOfFields = ++numberOfFields * 10;
    String key = "KEY" + numberOfFields.toString();
    field.key = key;
    _formFields.add(field);
    return key;
  }

  Map<String, dynamic> toJson() => {
        'formName': formName,
        'headerMsg': headerMsg,
        'footerMsg': footerMsg,
        'formFields': _formFieldsToJson(_formFields),
        'autoApproved': autoApproved,
        'isSystemTemplate': isSystemTemplate
      };

  List<dynamic> _formFieldsToJson(List<Field> fields) {
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
        autoApproved: json['autoApproved']);

    bf.isSystemTemplate = json['isSystemTemplate'];
    bf._formFields = _convertToOptionValuesFromJson(json['formFields']);

    return bf;
  }

  static List<Field> _convertToOptionValuesFromJson(List<dynamic> fieldsJson) {
    List<Field> values = new List<Field>();
    if (fieldsJson == null) return null;

    for (Map<String, dynamic> value in fieldsJson) {
      if (value["type"] == EnumToString.convertToString(FieldType.TEXT)) {
        values.add(FormInputFieldText.fromJson(value));
      } else if (value["type"] ==
          EnumToString.convertToString(FieldType.NUMBER)) {
        values.add(FormInputFieldNumber.fromJson(value));
      } else if (value["type"] ==
          EnumToString.convertToString(FieldType.OPTIONS)) {
        values.add(FormInputFieldOptions.fromJson(value));
      } else if (value["type"] ==
          EnumToString.convertToString(FieldType.ATTACHMENT)) {
        values.add(FormInputFieldAttachment.fromJson(value));
      } else if (value["type"] ==
          EnumToString.convertToString(FieldType.DATETIME)) {
        values.add(FormInputFieldDateTime.fromJson(value));
      } else if (value["type"] ==
          EnumToString.convertToString(FieldType.PHONE)) {
        values.add(FormInputFieldPhone.fromJson(value));
      } else if (value["type"] ==
          EnumToString.convertToString(FieldType.OPTIONS_ATTACHMENTS)) {
        values.add(FormInputFieldOptionsWithAttachments.fromJson(value));
      }
    }
    return values;
  }

  List<Field> getFormFields() {
    //returning duplicate list, to ensure that original list is modified only via
    //addField method to maintain the order of the key
    return _formFields.toList();
  }
}

class Field {
  String key;
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
    this.type = EnumToString.convertToString(FieldType.TEXT); //"TEXT";
  }

  Map<String, dynamic> toJson() => {
        'key': key,
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

    FormInputFieldText field = FormInputFieldText(json['label'],
        json['isMandatory'], json['infoMessage'], json['maxLength']);

    field.key = json["key"];
    field.id = json["id"];
    field.isMeta = json["isMeta"];
    field.response = json['response'];

    return field;
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
    this.type = EnumToString.convertToString(FieldType.NUMBER); //"NUMBER";
  }

  Map<String, dynamic> toJson() => {
        'key': key,
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
    FormInputFieldNumber field = FormInputFieldNumber(
        json['label'],
        json['isMandatory'],
        json['infoMessage'],
        json['minValue'],
        json['maxValue']);
    field.isMeta = json['isMeta'];
    field.id = json['id'];
    field.response = json['response'];

    return field;
  }
}

class FormInputFieldOptions extends Field {
  List<Value> options;
  bool isMultiSelect;
  List<Value> responseValues;

  FormInputFieldOptions(String label, bool isMandatory, String infoMessage,
      List<Value> options, bool isMultiSelect) {
    this.label = label;
    this.isMandatory = isMandatory;
    this.infoMessage = infoMessage;
    this.options = options;
    this.isMultiSelect = isMultiSelect;
    this.type = EnumToString.convertToString(FieldType.OPTIONS); //"OPTIONS";
  }

  Map<String, dynamic> toJson() => {
        'key': key,
        'id': id,
        'label': label,
        'isMeta': isMeta,
        'isMandatory': isMandatory,
        "infoMessage": infoMessage,
        'options': convertValuesToJson(options),
        'isMultiSelect': isMultiSelect,
        'type': type
      };

  static FormInputFieldOptions fromJson(Map<String, dynamic> json) {
    if (json == null) return null;
    FormInputFieldOptions field = FormInputFieldOptions(
        json['label'],
        json['isMandatory'],
        json['infoMessage'],
        convertToValuesFromJson(json['options']),
        json['isMultiSelect']);
    field.isMeta = json['isMeta'];
    field.id = json['id'];
    return field;
  }

  static List<Value> convertToValuesFromJson(List<dynamic> valuesJson) {
    List<Value> values = new List<Value>();
    if (valuesJson == null) return values;

    for (Map<String, dynamic> json in valuesJson) {
      values.add(Value.fromJson(json));
    }
    return values;
  }

  List<dynamic> convertValuesToJson(List<Value> options) {
    List<dynamic> usersJson = new List<dynamic>();
    if (options == null) return usersJson;
    for (Value val in options) {
      usersJson.add(val.toJson());
    }
    return usersJson;
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
    this.type =
        EnumToString.convertToString(FieldType.ATTACHMENT); //"ATTACHMENT";
  }

  Map<String, dynamic> toJson() => {
        'key': key,
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
    FormInputFieldAttachment field = FormInputFieldAttachment(
        json['label'], json['isMandatory'], json['infoMessage']);
    field.isMeta = json['isMeta'];
    field.id = json['id'];
    field.responseFilePaths =
        convertToPathValuesFromJson(json['responseFilePaths']);
    field.maxAttachments = json['maxAttachments'];

    return field;
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
    this.type = EnumToString.convertToString(FieldType.DATETIME); //"DATETIME";
  }

  Map<String, dynamic> toJson() => {
        'key': key,
        'id': id,
        'label': label,
        'isMeta': isMeta,
        'isMandatory': isMandatory,
        "infoMessage": infoMessage,
        'type': type,
        'responseDateTime': responseDateTime != null
            ? responseDateTime.millisecondsSinceEpoch
            : null
      };

  static FormInputFieldDateTime fromJson(Map<String, dynamic> json) {
    if (json == null) return null;
    FormInputFieldDateTime field = FormInputFieldDateTime(
        json['label'], json['isMandatory'], json['infoMessage']);
    field.isMeta = json['isMeta'];
    field.id = json['id'];
    field.responseDateTime =
        DateTime.fromMillisecondsSinceEpoch(json['responseDateTime']);

    return field;
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
    this.type = EnumToString.convertToString(FieldType.PHONE); //"PHONE";
  }

  Map<String, dynamic> toJson() => {
        'key': key,
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
    FormInputFieldPhone field = FormInputFieldPhone(
        json['label'], json['isMandatory'], json['infoMessage']);
    field.isMeta = json['isMeta'];
    field.id = json['id'];
    field.responsePhone = json['responsePhone'];

    return field;
  }
}

class FormInputFieldOptionsWithAttachments extends Field {
  List<Value> options;
  bool isMultiSelect;
  List<Value> responseValues;

  List<String> responseFilePaths;
  int maxAttachments = 2;

  FormInputFieldOptionsWithAttachments(String label, bool isMandatory,
      String infoMessage, List<Value> options, bool isMultiSelect) {
    this.label = label;
    this.isMandatory = isMandatory;
    this.infoMessage = infoMessage;
    this.options = options;
    this.isMultiSelect = isMultiSelect;
    this.type = EnumToString.convertToString(
        FieldType.OPTIONS_ATTACHMENTS); //"OPTIONS_ATTACHMENTS";
  }

  Map<String, dynamic> toJson() => {
        'key': key,
        'id': id,
        'label': label,
        'isMeta': isMeta,
        'isMandatory': isMandatory,
        "infoMessage": infoMessage,
        'options': convertValuesToJson(options),
        'isMultiSelect': isMultiSelect,
        'type': type,
        'responseFilePaths': responseFilePaths,
        'maxAttachments': maxAttachments
      };

  static FormInputFieldOptionsWithAttachments fromJson(
      Map<String, dynamic> json) {
    if (json == null) return null;
    FormInputFieldOptionsWithAttachments fields =
        FormInputFieldOptionsWithAttachments(
            json['label'],
            json['isMandatory'],
            json['infoMessage'],
            convertToValuesFromJson(json['options']),
            json['isMultiSelect']);
    fields.isMeta = json["isMeta"];
    fields.id = json['id'];
    fields.responseFilePaths =
        convertToStringsFromJson(json['responseFilePaths']);
    fields.maxAttachments = json['maxAttachments'];
    return fields;
  }

  static List<Value> convertToValuesFromJson(List<dynamic> valuesJson) {
    List<Value> values = new List<Value>();
    if (valuesJson == null) return values;

    for (Map<String, dynamic> json in valuesJson) {
      values.add(Value.fromJson(json));
    }
    return values;
  }

  static List<String> convertToStringsFromJson(List<dynamic> valuesJson) {
    List<String> strs = new List<String>();
    if (valuesJson == null) return strs;

    for (String str in valuesJson) {
      strs.add(str);
    }
    return strs;
  }

  List<dynamic> convertValuesToJson(List<Value> options) {
    List<dynamic> usersJson = new List<dynamic>();
    if (options == null) return usersJson;
    for (Value val in options) {
      usersJson.add(val.toJson());
    }
    return usersJson;
  }
}

class FormInputFieldBool extends Field {
  bool response;
  bool defaultValue;

  FormInputFieldBool(
      String label, bool isMandatory, String infoMessage, bool defaultValue) {
    this.label = label;
    this.isMandatory = isMandatory;
    this.infoMessage = infoMessage;
    this.defaultValue = defaultValue;
    this.type = EnumToString.convertToString(FieldType.BOOL);
  }

  Map<String, dynamic> toJson() => {
        'key': key,
        'id': id,
        'label': label,
        'isMeta': isMeta,
        'isMandatory': isMandatory,
        "infoMessage": infoMessage,
        "type": type,
        "defaultValue": defaultValue,
        'response': response
      };

  static FormInputFieldBool fromJson(Map<String, dynamic> json) {
    if (json == null) return null;

    FormInputFieldBool field = FormInputFieldBool(json['label'],
        json['isMandatory'], json['infoMessage'], json["defaultValue"]);

    field.id = json["id"];
    field.isMeta = json["isMeta"];
    field.response = json['response'];

    return field;
  }
}

class Value {
  dynamic value;
  String key;

  Value(dynamic label) {
    this.key = Uuid().v1();
    this.value = label;
  }

  Map<String, dynamic> toJson() => {'key': key, 'value': value};

  static Value fromJson(Map<String, dynamic> json) {
    if (json == null) return null;

    Value textValue = Value(json['value']);

    textValue.key = json['key'];

    return textValue;
  }
}
