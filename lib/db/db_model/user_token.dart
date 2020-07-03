class UserToken {
  UserToken(
      {this.slotId,
      this.entityId,
      this.userId,
      this.number,
      this.dateTime,
      this.maxAllowed,
      this.slotDuration,
      this.entityName,
      this.lat,
      this.lon});

  String slotId; //entityID#20~06~01#9~30
  String entityId;
  String userId;
  int number;
  DateTime dateTime;
  int maxAllowed;
  int slotDuration;
  String entityName;
  double lat;
  double lon;

  //TokenDocumentId is SlotId#UserId it is not auto-generated, will help in not duplicating the record

  Map<String, dynamic> toJson() => {
        'slotId': slotId,
        'entityId': entityId,
        'userId': userId,
        'number': number,
        'dateTime': dateTime,
        'maxAllowed': maxAllowed,
        'slotDuration': slotDuration,
        'entityName': entityName,
        'lat': lat,
        'lon': lon
      };

  static UserToken fromJson(Map<String, dynamic> json) {
    if (json == null) return null;
    return new UserToken(
        slotId: json['slotId'].toString(),
        entityId: json['entityId'].toString(),
        userId: json['userId'].toString(),
        number: json['currentNumber'],
        dateTime: new DateTime.fromMillisecondsSinceEpoch(
            json['dateTime'].millisecondsSinceEpoch),
        maxAllowed: json['maxAllowed'],
        slotDuration: json['slotDuration'],
        entityName: json['entityName'],
        lat: json['lat'],
        lon: json['lon']);
  }
}
