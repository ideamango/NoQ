class Configurations {
  Configurations({this.entityTypes, this.messages, this.keyMessage});

  List<String> entityTypes;
  List<String> messages;
  String keyMessage;

  Map<String, dynamic> toJson() => {
        'entityTypes': entityTypes,
        'messages': messages,
        'keyMessage': keyMessage
      };

  static Configurations fromJson(Map<String, dynamic> json) {
    if (json == null) return null;
    return new Configurations(
        entityTypes: convertToStringsArrayFromJson(json['entityTypes']),
        messages: convertToStringsArrayFromJson(json['messages']),
        keyMessage: json['keyMessage']);
  }

  static List<String> convertToStringsArrayFromJson(List<dynamic> json) {
    List<String> strs = new List<String>();

    for (String str in json) {
      strs.add(str);
    }
    return strs;
  }
}
