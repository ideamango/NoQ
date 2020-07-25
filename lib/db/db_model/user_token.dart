import 'package:intl/intl.dart';

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
      this.lon,
      this.entityWhatsApp});

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
  String entityWhatsApp;

  //TokenDocumentId is SlotId#UserId it is not auto-generated, will help in not duplicating the record

  Map<String, dynamic> toJson() => {
        'slotId': slotId,
        'entityId': entityId,
        'userId': userId,
        'number': number,
        'dateTime': dateTime.millisecondsSinceEpoch,
        'maxAllowed': maxAllowed,
        'slotDuration': slotDuration,
        'entityName': entityName,
        'lat': lat,
        'lon': lon,
        'entityWhatsApp': entityWhatsApp
      };

  static UserToken fromJson(Map<String, dynamic> json) {
    if (json == null) return null;
    return new UserToken(
        slotId: json['slotId'].toString(),
        entityId: json['entityId'].toString(),
        userId: json['userId'].toString(),
        number: json['number'],
        dateTime: new DateTime.fromMillisecondsSinceEpoch(
            json['dateTime'].millisecondsSinceEpoch),
        maxAllowed: json['maxAllowed'],
        slotDuration: json['slotDuration'],
        entityName: json['entityName'],
        lat: json['lat'],
        lon: json['lon'],
        entityWhatsApp: json['entityWhatsApp']);
  }

  String getDisplayName() {
    //First 3 chars of the Entity name, followed by the date and then time and Token number
    //E.g. BAT-200708-0930-10
    String name = entityName.substring(0, 3).toUpperCase();
    DateFormat formatter = DateFormat('-yyMMdd-hhmm-');
    String formattedDate = formatter.format(dateTime);

    return name + formattedDate + number.toString();
  }

  dynamic myEncode(dynamic item) {
    if (item is DateTime) {
      return item.toIso8601String();
    }
    return item;
  }
}
