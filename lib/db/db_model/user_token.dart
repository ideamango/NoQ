import 'package:intl/intl.dart';
import './list_item.dart';
import './order.dart';
import '../../utils.dart';

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
      this.phone,
      this.rNum,
      this.address,
      this.tokens,
      this.upiId,
      this.upiPhoneNumber,
      this.upiQRImagePath});

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
  String phone;
  int rNum;
  String address;
  List<UserToken> tokens;
  String upiId;
  String upiPhoneNumber;
  String upiQRImagePath;

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
        'phone': phone,
        'rNum': rNum,
        'address': address,
        'tokens': tokensToJson(tokens),
        'upiId': upiId,
        'upiPhoneNumber': upiPhoneNumber,
        'upiQRImagePath': upiQRImagePath
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
        phone: json['phone'],
        rNum: json['rNum'],
        address: json['address'],
        tokens: convertToTokensFromJson(json['tokens']),
        upiId: json['upiId'],
        upiPhoneNumber: json['upiPhoneNumber'],
        upiQRImagePath: json['upiQRImagePath']);

    for (UserToken token in tokens.tokens) {
      token.parent = tokens;
    }

    return tokens;
  }

  static List<UserToken> convertToTokensFromJson(List<dynamic> toksJson) {
    List<UserToken> toks = [];
    if (toksJson == null) return toks;

    for (Map<String, dynamic> json in toksJson) {
      UserToken sl = UserToken.fromJson(json);
      toks.add(sl);
    }
    return toks;
  }

  List<dynamic> tokensToJson(List<UserToken> toks) {
    List<dynamic> tokensJson = [];
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

    List<String> tokenNames = [];
    for (UserToken tok in tokens) {
      tokenNames.add(tok.getDisplayName());
    }

    return tokenNames;
  }

  List<dynamic> metaEntitiesToJson(List<ListItem> items) {
    List<dynamic> itemsJson = [];
    if (items == null) return itemsJson;
    for (ListItem item in items) {
      itemsJson.add(item.toJson());
    }
    return itemsJson;
  }

  static List<ListItem> convertToListItemsFromJson(
      List<dynamic> listItemsJson) {
    List<ListItem> items = [];
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

class TokenStats {
  int numberOfTokensCreated = 0;
  int numberOfTokensCancelled = 0;

  Map<String, dynamic> toJson() => {
        'numberOfTokensCreated': numberOfTokensCreated,
        'numberOfTokensCancelled': numberOfTokensCancelled,
      };

  static TokenStats fromJson(Map<String, dynamic> json) {
    if (json == null) return null;

    TokenStats overview = TokenStats();
    overview.numberOfTokensCreated = json['numberOfTokensCreated'];
    overview.numberOfTokensCancelled = json['numberOfTokensCancelled'];

    return overview;
  }
}

class TokenCounter {
  TokenCounter({this.entityId, this.year});

  String entityId;
  String year;

  Map<String, TokenStats>
      slotWiseStats; //key should be year~month~day#slot-time

  Map<String, dynamic> toJson() => {
        'id': entityId + "#" + year,
        'entityId': entityId,
        'year': year,
        'slotWiseStats': convertFromMap(slotWiseStats)
      };

  static TokenCounter fromJson(Map<String, dynamic> json) {
    if (json == null) return null;

    TokenCounter overview =
        TokenCounter(entityId: json['entityId'], year: json['year']);

    overview.slotWiseStats = convertToMapFromJSON(json['slotWiseStats']);
    return overview;
  }

  Map<String, dynamic> convertFromMap(Map<String, TokenStats> dailyStats) {
    if (dailyStats == null) {
      return null;
    }

    Map<String, dynamic> map = Map<String, dynamic>();

    dailyStats.forEach((k, v) => map[k] = v.toJson());

    return map;
  }

  TokenStats getTokenStatsForMonth(int month) {
    TokenStats ts = new TokenStats();
    slotWiseStats.forEach((key, value) {
      int tokenMonth = int.parse(key.split('~')[1]);
      if (tokenMonth == month) {
        ts.numberOfTokensCreated += value.numberOfTokensCreated;
        ts.numberOfTokensCancelled += value.numberOfTokensCancelled;
      }
    });

    return ts;
  }

  TokenStats getTokenStatsForDay(DateTime date) {
    TokenStats ts = new TokenStats();
    slotWiseStats.forEach((key, value) {
      String tokenDate = (key.split('#')[0]);
      List<String> dateList = tokenDate.split('~');

      if (int.parse(dateList[0]) == date.year &&
          int.parse(dateList[1]) == date.month &&
          int.parse(dateList[2]) == date.day) {
        ts.numberOfTokensCreated += value.numberOfTokensCreated;
        ts.numberOfTokensCancelled += value.numberOfTokensCancelled;
      }
    });

    return ts;
  }

  Map<String, TokenStats> getTokenStatsMonthWiseForYear() {
    Map<String, TokenStats> map = new Map<String, TokenStats>();
    slotWiseStats.forEach((key, value) {
      String tokenMonth = key.split('#')[1];
      if (map.containsKey(tokenMonth)) {
        TokenStats ts = map[tokenMonth];
        ts.numberOfTokensCreated += value.numberOfTokensCreated;
        ts.numberOfTokensCancelled += value.numberOfTokensCancelled;
      } else {
        TokenStats ts = new TokenStats();
        map[tokenMonth] = ts;
        ts.numberOfTokensCreated += value.numberOfTokensCreated;
        ts.numberOfTokensCancelled += value.numberOfTokensCancelled;
      }
    });

    return map;
  }

  Map<String, TokenStats> getTokenStatsDayWiseForMonth(int month) {
    Map<String, TokenStats> dayWiseStats = Map<String, TokenStats>();
    slotWiseStats.forEach((key, value) {
      String tokenDate = (key.split('#')[0]);
      String slot = (key.split('#')[1]);
      List<String> dateList = tokenDate.split('~');
      String day = (dateList[2]);
      if (int.parse(dateList[1]) == month) {
        if (dayWiseStats.containsKey(day)) {
          dayWiseStats[day].numberOfTokensCreated =
              dayWiseStats[day].numberOfTokensCreated +
                  value.numberOfTokensCreated;
          dayWiseStats[day].numberOfTokensCancelled =
              dayWiseStats[day].numberOfTokensCancelled +
                  value.numberOfTokensCancelled;
        } else {
          dayWiseStats[day.toString()] = value;
        }
      }
    });

    return dayWiseStats;
  }

  Map<String, TokenStats> getTokenStatsSlotWiseForDay(DateTime date) {
    Map<String, TokenStats> slotWiseStatsForDay = Map<String, TokenStats>();
    slotWiseStats.forEach((key, value) {
      String tokenDate = (key.split('#')[0]);
      String slot = (key.split('#')[1]);
      List<String> dateList = tokenDate.split('~');

      if (int.parse(dateList[0]) == date.year &&
          int.parse(dateList[1]) == date.month &&
          int.parse(dateList[2]) == date.day) {
        slotWiseStatsForDay[slot] = value;
      }
    });

    return slotWiseStatsForDay;
  }

  TokenStats getTokenStatsForYear() {
    TokenStats ts = new TokenStats();
    slotWiseStats.forEach((key, value) {
      ts.numberOfTokensCreated += value.numberOfTokensCreated;
      ts.numberOfTokensCancelled += value.numberOfTokensCancelled;
    });

    return ts;
  }

  Map<String, TokenStats> getTokenStatsTimeSlotWise(
      DateTime to, DateTime from) {
    Map<String, TokenStats> slotWiseStatsForRange =
        new Map<String, TokenStats>();

    slotWiseStats.forEach((key, value) {
      int tokenYear = int.parse(key.split('#')[0]);
      int tokenMonth = int.parse(key.split('#')[1]);
      int tokenDay = int.parse(key.split('#')[2]);
      String timeSlot = key.split('#')[3];

      DateTime dt = new DateTime(tokenYear, tokenMonth, tokenDay);

      if (dt.isAfter(to) && dt.isBefore(from)) {
        if (slotWiseStatsForRange.containsKey(timeSlot)) {
          TokenStats ts = slotWiseStatsForRange[timeSlot];
          ts.numberOfTokensCreated += value.numberOfTokensCreated;
          ts.numberOfTokensCancelled += value.numberOfTokensCancelled;
        } else {
          TokenStats ts = new TokenStats();
          ts.numberOfTokensCreated += value.numberOfTokensCreated;
          ts.numberOfTokensCancelled += value.numberOfTokensCancelled;
          slotWiseStatsForRange[timeSlot] = ts;
        }
      }
    });

    return slotWiseStatsForRange;
  }

  static Map<String, TokenStats> convertToMapFromJSON(
      Map<dynamic, dynamic> map) {
    Map<String, TokenStats> roles = new Map<String, TokenStats>();
    map.forEach((k, v) => roles[k] = TokenStats.fromJson(v));
    return roles;
  }
}
