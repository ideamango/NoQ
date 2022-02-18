import 'package:LESSs/db/db_model/user_token.dart';

class Slot {
  Slot(
      {this.slotId,
      this.totalBooked,
      this.maxAllowed,
      this.dateTime,
      this.slotDuration,
      this.isFull,
      this.tokens,
      this.totalCancelled});

  //SlotId is entityID#20~06~01#9~30

  String? slotId;
  int? totalBooked = 0;
  int? maxAllowed;
  DateTime? dateTime;
  int? slotDuration;
  bool? isFull = false;
  List<UserTokens?>? tokens = [];
  int? totalCancelled = 0;

  Map<String, dynamic> toJson() => {
        'slotId': slotId,
        'totalBooked': totalBooked,
        'maxAllowed': maxAllowed,
        'dateTime': dateTime!.millisecondsSinceEpoch,
        'slotDuration': slotDuration,
        'isFull': isFull,
        'tokens': tokensToJson(tokens),
        'totalCancelled': totalCancelled
      };

  List<dynamic>? tokensToJson(List<UserTokens?>? tokens) {
    if (tokens == null) {
      return null;
    }
    List<dynamic> tokensJson = [];
    for (UserTokens? userTokens in tokens) {
      tokensJson.add(userTokens!.toJson());
    }

    return tokensJson;
  }

  static List<UserTokens?>? userTokensFromJson(List<dynamic>? tokenJson) {
    if (tokenJson == null) {
      return null;
    }

    List<UserTokens?> uts = [];

    for (dynamic json in tokenJson) {
      UserTokens? ut = UserTokens.fromJson(json);
      uts.add(ut);
    }

    return uts;
  }

  static Slot fromJson(Map<String, dynamic> json) {
    if (json == null) return null;
    return new Slot(
        slotId: json['slotId'],
        totalBooked: json['totalBooked'],
        maxAllowed: json['maxAllowed'],
        dateTime: new DateTime.fromMillisecondsSinceEpoch(json['dateTime']),
        slotDuration: json['slotDuration'],
        isFull: json['isFull'],
        tokens: userTokensFromJson(json['tokens']),
        totalCancelled: json['totalCancelled']);
  }
}
