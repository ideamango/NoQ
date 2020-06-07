class MetaEntity {
  MetaEntity(
      {this.entityId,
      this.name,
      this.type,
      this.advanceDays,
      this.isPublic,
      this.closedOn,
      this.startTimeHour,
      this.startTimeMinute,
      this.endTimeHour,
      this.endTimeMinute});

  //SlotDocumentId is entityID#20~06~01 it is not auto-generated, will help in not duplicating the record
  String entityId;
  String name;
  String type;
  int advanceDays;
  bool isPublic;
  List<String> closedOn;
  int startTimeHour;
  int startTimeMinute;
  int endTimeHour;
  int endTimeMinute;

  static MetaEntity fromJson(Map<String, dynamic> json) {
    return new MetaEntity(
        entityId: json['entityId'].toString(),
        name: json['name'],
        type: json['type'],
        advanceDays: json['advanceDays'],
        isPublic: json['isPublic'],
        closedOn: convertToClosedOnArrayFromJson(json['closedOn']),
        startTimeHour: json['startTimeHour'],
        startTimeMinute: json['startTimeMinute'],
        endTimeHour: json['endTimeHour'],
        endTimeMinute: json['endTimeMinute']);
  }

  static List<String> convertToClosedOnArrayFromJson(List<dynamic> daysJson) {
    List<String> days = new List<String>();

    for (String day in daysJson) {
      days.add(day);
    }
    return days;
  }

  Map<String, dynamic> toJson() => {
        'entityId': entityId,
        'name': name,
        'type': type,
        'advanceDays': advanceDays,
        'isPublic': isPublic,
        'startTimeHour': startTimeHour,
        'startTimeMinute': startTimeMinute,
        'endTimeHour': endTimeHour,
        'endTimeMinute': endTimeMinute
      };
}
