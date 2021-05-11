import 'package:LESSs/db/db_model/user_token.dart';

class Slot {
  Slot(
      {this.slotId,
      this.currentNumber,
      this.maxAllowed,
      this.dateTime,
      this.slotDuration,
      this.isFull,
      this.tokens});

  //SlotId is entityID#20~06~01#9~30

  String slotId;
  int currentNumber;
  int maxAllowed;
  DateTime dateTime;
  int slotDuration;
  bool isFull = false;
  List<UserTokens> tokens = [];

  Map<String, dynamic> toJson() => {
        'slotId': slotId,
        'currentNumber': currentNumber,
        'maxAllowed': maxAllowed,
        'dateTime': dateTime.millisecondsSinceEpoch,
        'slotDuration': slotDuration,
        'isFull': isFull,
        'tokens': tokensToJson(tokens)
      };

  List<dynamic> tokensToJson(List<UserTokens> tokens) {
    if (tokens == null) {
      return null;
    }
    List<dynamic> tokensJson = [];
    for (UserTokens userTokens in tokens) {
      tokensJson.add(userTokens.toJson());
    }

    return tokensJson;
  }

  static List<UserTokens> userTokensFromJson(List<dynamic> tokenJson) {
    if (tokenJson == null) {
      return null;
    }

    List<UserTokens> uts = [];

    for (dynamic json in tokenJson) {
      UserTokens ut = UserTokens.fromJson(json);
      uts.add(ut);
    }

    return uts;
  }

  static Slot fromJson(Map<String, dynamic> json) {
    if (json == null) return null;
    return new Slot(
        slotId: json['slotId'],
        currentNumber: json['currentNumber'],
        maxAllowed: json['maxAllowed'],
        dateTime: new DateTime.fromMillisecondsSinceEpoch(json['dateTime']),
        slotDuration: json['slotDuration'],
        isFull: json['isFull'],
        tokens: userTokensFromJson(json['tokens']));
  }
}
