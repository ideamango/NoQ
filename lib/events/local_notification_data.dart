class LocalNotificationData {
  LocalNotificationData({this.dateTime, this.title, this.message, this.id});

  //SlotId is entityID#20~06~01#9~30

  String? title;
  String? message;
  DateTime? dateTime;
  int? id;
}
