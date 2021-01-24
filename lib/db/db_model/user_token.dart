import 'package:intl/intl.dart';
import 'package:noq/db/db_model/list_item.dart';
import 'package:noq/db/db_model/order.dart';
import 'package:noq/utils.dart';
import 'dart:math';

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
      this.entityWhatsApp,
      this.order,
      this.gpay,
      this.paytm,
      this.applepay,
      this.phone,
      this.rNum,
      this.address,
      this.applicationId,
      this.bookingFormId,
      this.bookingFormName});

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
  Order order;
  String gpay;
  String paytm;
  String applepay;
  String phone;
  int rNum;
  String address;
  String applicationId;
  String bookingFormId;
  String bookingFormName;

  //TokenDocumentId is SlotId#UserId it is not auto-generated, will help in not duplicating the record

  Map<String, dynamic> toJson() => {
        'slotId': slotId,
        'entityId': entityId,
        'userId': userId,
        'number': number,
        'dateTime': dateTime != null ? dateTime.millisecondsSinceEpoch : null,
        'maxAllowed': maxAllowed,
        'slotDuration': slotDuration,
        'entityName': entityName,
        'lat': lat,
        'lon': lon,
        'entityWhatsApp': entityWhatsApp,
        'order': order != null ? order.toJson() : null,
        'gpay': gpay,
        'paytm': paytm,
        'applepay': applepay,
        'phone': phone,
        'rNum': rNum,
        'address': address,
        'applicationId': applicationId,
        'bookingFormId': bookingFormId,
        'bookingFormName': bookingFormName
      };

  static UserToken fromJson(Map<String, dynamic> json) {
    if (json == null) return null;
    return new UserToken(
        slotId: json['slotId'],
        entityId: json['entityId'],
        userId: json['userId'],
        number: json['number'],
        dateTime: json['dateTime'] != null
            ? new DateTime.fromMillisecondsSinceEpoch(json['dateTime'])
            : null,
        maxAllowed: json['maxAllowed'],
        slotDuration: json['slotDuration'],
        entityName: json['entityName'],
        lat: json['lat'],
        lon: json['lon'],
        entityWhatsApp: json['entityWhatsApp'],
        order: Order.fromJson(json['order']),
        gpay: json['gpay'],
        paytm: json['paytm'],
        applepay: json['applepay'],
        phone: json['phone'],
        rNum: json['rNum'],
        address: json['address'],
        applicationId: json['applicationId'],
        bookingFormId: json['bookingFormId'],
        bookingFormName: json['bookingFormName']);
  }

  String getTokenId() {
    if (slotId == null || userId == null) {
      return null;
    }
    return slotId + '#' + userId;
  }

  String getDisplayName() {
    //First 3 chars of the Entity name, followed by the date and then time and Token number
    //E.g. BAT-200708-0930-10
    String name = entityName.substring(0, 3).toUpperCase();
    DateFormat formatter = DateFormat('-yyMMdd-hhmm-');
    String formattedDate = formatter.format(dateTime);

    return name + formattedDate + number.toString();
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
