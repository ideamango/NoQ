import './list_item.dart';
import './message.dart';
import '../../utils.dart';

class Order {
  Order(
      {this.billNo,
      this.items,
      this.comments,
      this.status, //ReadyforPickUp, Processing, Dispatched, Accepted, Rejected, Created, Cancelled, Default
      this.billAmount,
      this.deliveryMode, //OnPremiseShopping, PickUp, HomeDelivery
      this.deliveryAddress,
      this.orderCreatedDateTime,
      this.deliveryDateTime,
      this.entityId,
      this.isPublic,
      this.userId});

  String? billNo;
  List<ListItem>? items; //
  List<Message>? comments;
  String? status;
  double? billAmount;
  String? deliveryMode;
  String? deliveryAddress;
  DateTime? orderCreatedDateTime;
  DateTime? deliveryDateTime;
  String? entityId;
  bool? isPublic;
  String? userId;

  //TokenDocumentId is SlotId#UserId it is not auto-generated, will help in not duplicating the record

  Map<String, dynamic> toJson() => {
        'billNo': billNo,
        'items': listOfItemsToJson(items),
        'comments': listOfMessagesToJson(comments),
        'status': status,
        'billAmount': billAmount,
        'deliveryMode': deliveryMode,
        'deliveryAddress': deliveryAddress,
        'orderCreatedDateTime': orderCreatedDateTime != null
            ? orderCreatedDateTime!.millisecondsSinceEpoch
            : null,
        'deliveryDateTime': deliveryDateTime != null
            ? deliveryDateTime!.millisecondsSinceEpoch
            : null,
        'entityId': entityId,
        'isPublic': isPublic,
        'userId': userId
      };

  static Order? fromJson(Map<String, dynamic>? json) {
    if (json == null) return null;
    return new Order(
        billNo: json['billNo'],
        items: convertToListItemsFromJson(json['items']),
        comments: convertToMessageFromJson(json['comments']),
        status: json['status'],
        billAmount: json['billAmount'],
        deliveryMode: json['deliveryMode'],
        deliveryAddress: json['deliveryAddress'],
        orderCreatedDateTime: json['orderCreatedDateTime'] != null
            ? new DateTime.fromMillisecondsSinceEpoch(
                json['orderCreatedDateTime'])
            : null,
        deliveryDateTime: json['deliveryDateTime'] != null
            ? new DateTime.fromMillisecondsSinceEpoch(json['deliveryDateTime'])
            : null,
        entityId: json['entityId'],
        isPublic: json['isPublic'],
        userId: json['userId']);
  }

  List<dynamic> listOfMessagesToJson(List<Message>? items) {
    List<dynamic> itemsJson = [];
    if (items == null) return itemsJson;
    for (Message item in items) {
      itemsJson.add(item.toJson());
    }
    return itemsJson;
  }

  List<dynamic> listOfItemsToJson(List<ListItem>? items) {
    List<dynamic> itemsJson = [];
    if (items == null) return itemsJson;
    for (ListItem item in items) {
      itemsJson.add(item.toJson());
    }
    return itemsJson;
  }

  static List<Message> convertToMessageFromJson(List<dynamic>? listItemsJson) {
    List<Message> items = [];
    if (Utils.isNullOrEmpty(listItemsJson)) return items;

    for (Map<String, dynamic> json
        in listItemsJson as Iterable<Map<String, dynamic>>) {
      Message? item = Message.fromJson(json);
      items.add(item!);
    }
    return items;
  }

  static List<ListItem> convertToListItemsFromJson(
      List<dynamic>? listItemsJson) {
    List<ListItem> items = [];
    if (Utils.isNullOrEmpty(listItemsJson)) return items;

    for (Map<String, dynamic> json
        in listItemsJson as Iterable<Map<String, dynamic>>) {
      ListItem? item = ListItem.fromJson(json);
      items.add(item!);
    }
    return items;
  }
}
