class Form {
  String formName;
  String headerMsg;
  String footerMsg;
  List<Field> formFieldList;
}

class Field {
  String label;
  bool isMandatory;
  String infoMessage;
}

class FormInputFieldText extends Field {
  String maxLength;
}

class FormInputFieldNumber extends Field {
  String minValue;
  String maxValue;
}

class FormInputFieldOptions extends Field {
  List<String> values;
  bool isMultiSelect;
}
