import 'package:flutter/material.dart';

class EntityForm {
  String formName;
  String headerMsg;
  String footerMsg;
  List<Field> formFieldList;
}

class Field {
  String label;
  bool isMandatory;
  String infoMessage;

  Field({@required this.label, @required this.isMandatory, this.infoMessage});
}

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
}
