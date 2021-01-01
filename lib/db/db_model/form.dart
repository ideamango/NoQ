class Form {
  String formName;
  String headerMsg;
  String footerMsg;
  List<Field> formFieldList;
}

class Field {}

class FormInputFieldText extends Field {
  String maxLength;
  String label;
  bool isMandatory;
  String infoMessage;

  Map<String, dynamic> toJson() => {
        'maxLength': maxLength,
        'label': label,
        'isMandatory': isMandatory,
        "infoMessage": infoMessage
      };

  static FormInputFieldText fromJson(Map<String, dynamic> json) {
    if (json == null) return null;
    return new FormInputFieldText();
  }
}

class FormInputFieldNumber extends Field {
  String minValue;
  String maxValue;
}

class FormInputFieldOptions extends Field {
  List<String> values;
  bool isMultiSelect;
}
