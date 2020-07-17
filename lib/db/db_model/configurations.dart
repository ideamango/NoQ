class Configurations {
  Configurations(
      {this.entityTypes,
      this.messages,
      this.keyMessage,
      this.contactEmail,
      this.contactPhone,
      this.supportReasons,
      this.enableDonation});

  List<String> entityTypes;
  List<String> messages;
  String keyMessage;
  String contactEmail;
  String contactPhone;
  List<String> supportReasons;
  bool enableDonation;

  Map<String, dynamic> toJson() => {
        'entityTypes': entityTypes,
        'messages': messages,
        'keyMessage': keyMessage,
        'contactEmail': contactEmail,
        'contactPhone': contactPhone,
        'supportReasons': supportReasons,
        'enableDonation': enableDonation
      };

  static Configurations fromJson(Map<String, dynamic> json) {
    if (json == null) return null;
    return new Configurations(
        entityTypes: convertToStringsArrayFromJson(json['entityTypes']),
        messages: convertToStringsArrayFromJson(json['messages']),
        keyMessage: json['keyMessage'],
        contactEmail: json['contactEmail'],
        contactPhone: json['contactPhone'],
        supportReasons: convertToStringsArrayFromJson(json['supportReasons']),
        enableDonation: json['enableDonation']);
  }

  static List<String> convertToStringsArrayFromJson(List<dynamic> json) {
    List<String> strs = new List<String>();

    for (String str in json) {
      strs.add(str);
    }
    return strs;
  }
}
