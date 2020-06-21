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
      this.endTimeMinute,
      this.isActive});

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
  bool isActive;

  static MetaEntity fromJson(Map<String, dynamic> json) {
    if (json == null) return null;
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
        endTimeMinute: json['endTimeMinute'],
        isActive: json['isActive']);
  }

  static List<String> convertToClosedOnArrayFromJson(List<dynamic> daysJson) {
    List<String> days = new List<String>();
    if (daysJson == null) return days;

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
        'endTimeMinute': endTimeMinute,
        'isActive': isActive
      };

  bool isEqual(MetaEntity metaEnt) {
    if (metaEnt.advanceDays == this.advanceDays &&
        metaEnt.endTimeHour == this.endTimeHour &&
        metaEnt.endTimeMinute == this.endTimeMinute &&
        metaEnt.entityId == this.entityId &&
        metaEnt.isActive == this.isActive &&
        metaEnt.isPublic == this.isPublic &&
        metaEnt.name == this.name) {
      if (this.closedOn != null && metaEnt.closedOn != null) {
        int matchCount = 0;

        for (String day in this.closedOn) {
          for (String val in metaEnt.closedOn) {
            if (day == val) {
              matchCount++;
            }
          }
        }
        if (matchCount == this.closedOn.length) {
          return true;
        }
      }

      if (this.closedOn == null && metaEnt.closedOn == null) {
        return true;
      }
    }
    return false;
  }
}
