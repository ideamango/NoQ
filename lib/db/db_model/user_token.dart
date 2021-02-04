import 'package:intl/intl.dart';
import 'package:noq/db/db_model/list_item.dart';
import 'package:noq/db/db_model/order.dart';
import 'package:noq/utils.dart';

class UserTokens {
  UserTokens(
      {this.slotId,
      this.entityId,
      this.userId,
      this.dateTime,
      this.maxAllowed,
      this.slotDuration,
      this.entityName,
      this.lat,
      this.lon,
      this.entityWhatsApp,
      this.gpay,
      this.paytm,
      this.applepay,
      this.phone,
      this.rNum,
      this.address,
      this.tokens});

  String slotId; //entityID#20~06~01#9~30
  String entityId;
  String userId;
  DateTime dateTime;
  int maxAllowed;
  int slotDuration;
  String entityName;
  double lat;
  double lon;
  String entityWhatsApp;
  String gpay;
  String paytm;
  String applepay;
  String phone;
  int rNum;
  String address;
  List<UserToken> tokens;

  //TokenDocumentId is SlotId#UserId it is not auto-generated, will help in not duplicating the record

  Map<String, dynamic> toJson() => {
        'slotId': slotId,
        'entityId': entityId,
        'userId': userId,
        'dateTime': dateTime != null ? dateTime.millisecondsSinceEpoch : null,
        'maxAllowed': maxAllowed,
        'slotDuration': slotDuration,
        'entityName': entityName,
        'lat': lat,
        'lon': lon,
        'entityWhatsApp': entityWhatsApp,
        'gpay': gpay,
        'paytm': paytm,
        'applepay': applepay,
        'phone': phone,
        'rNum': rNum,
        'address': address,
        'tokens': tokensToJson(tokens)
      };

  static UserTokens fromJson(Map<String, dynamic> json) {
    if (json == null) return null;
    UserTokens tokens = new UserTokens(
        slotId: json['slotId'],
        entityId: json['entityId'],
        userId: json['userId'],
        dateTime: json['dateTime'] != null
            ? new DateTime.fromMillisecondsSinceEpoch(json['dateTime'])
            : null,
        maxAllowed: json['maxAllowed'],
        slotDuration: json['slotDuration'],
        entityName: json['entityName'],
        lat: json['lat'],
        lon: json['lon'],
        entityWhatsApp: json['entityWhatsApp'],
        gpay: json['gpay'],
        paytm: json['paytm'],
        applepay: json['applepay'],
        phone: json['phone'],
        rNum: json['rNum'],
        address: json['address'],
        tokens: convertToTokensFromJson(json['tokens']));

    for (UserToken token in tokens.tokens) {
      token.parent = tokens;
    }

    return tokens;
  }

  static List<UserToken> convertToTokensFromJson(List<dynamic> toksJson) {
    List<UserToken> toks = new List<UserToken>();
    if (toksJson == null) return toks;

    for (Map<String, dynamic> json in toksJson) {
      UserToken sl = UserToken.fromJson(json);
      toks.add(sl);
    }
    return toks;
  }

  List<dynamic> tokensToJson(List<UserToken> toks) {
    List<dynamic> tokensJson = new List<dynamic>();
    if (toks == null) return tokensJson;
    for (UserToken tok in tokens) {
      tokensJson.add(tok.toJson());
    }
    return tokensJson;
  }

  String getTokenId() {
    if (slotId == null || userId == null) {
      return null;
    }
    return slotId + '#' + userId;
  }

  String getDisplayNamePrefix() {
    String name = entityName.substring(0, 3).toUpperCase();
    DateFormat formatter = DateFormat('-yyMMdd-hhmm-');
    String formattedDate = formatter.format(dateTime);

    String prefix = name + formattedDate;
    return prefix;
  }

  List<String> getDisplayNames() {
    //First 3 chars of the Entity name, followed by the date and then time and Token number
    //E.g. BAT-200708-0930-10

    List<String> tokenNames = List<String>();
    for (UserToken tok in tokens) {
      tokenNames.add(tok.getDisplayName());
    }

    return tokenNames;
  }

  List<dynamic> metaEntitiesToJson(List<ListItem> items) {
    List<dynamic> itemsJson = new List<dynamic>();
    if (items == null) return itemsJson;
    for (ListItem item in items) {
      itemsJson.add(item.toJson());
    }
    return itemsJson;
  }

  static List<ListItem> convertToListItemsFromJson(
      List<dynamic> listItemsJson) {
    List<ListItem> items = new List<ListItem>();
    if (Utils.isNullOrEmpty(listItemsJson)) return items;

    for (Map<String, dynamic> json in listItemsJson) {
      ListItem item = ListItem.fromJson(json);
      items.add(item);
    }
    return items;
  }

  dynamic myEncode(dynamic item) {
    if (item is DateTime) {
      return item.toIso8601String();
    }
    return item;
  }
}

class UserToken {
  UserToken(
      {this.number,
      this.order,
      this.applicationId,
      this.bookingFormId,
      this.bookingFormName,
      this.parent});

  Order order;
  int number;
  String applicationId;
  String bookingFormId;
  String bookingFormName;
  UserTokens parent;

  Map<String, dynamic> toJson() => {
        'number': number,
        'order': order != null ? order.toJson() : null,
        'applicationId': applicationId,
        'bookingFormId': bookingFormId,
        'bookingFormName': bookingFormName
      };

  static UserToken fromJson(Map<String, dynamic> json) {
    if (json == null) return null;
    return new UserToken(
        number: json['number'],
        order: Order.fromJson(json['order']),
        applicationId: json['applicationId'],
        bookingFormId: json['bookingFormId'],
        bookingFormName: json['bookingFormName']);
  }

  String getDisplayName() {
    return parent.getDisplayNamePrefix() + number.toString();
  }
}
