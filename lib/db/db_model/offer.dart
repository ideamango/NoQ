class Offer {
  Offer({this.message, this.startDateTime, this.endDateTime, this.coupon});

  //SlotId is entityID#20~06~01#9~30

  String message;
  DateTime startDateTime;
  DateTime endDateTime;
  String coupon;

  Map<String, dynamic> toJson() => {
        'message': message,
        'startDateTime': (startDateTime != null)
            ? startDateTime.millisecondsSinceEpoch
            : null,
        'endDateTime':
            (endDateTime != null) ? endDateTime.millisecondsSinceEpoch : null,
        'coupon': coupon
      };

  static Offer fromJson(Map<String, dynamic> json) {
    if (json == null) return null;
    return new Offer(
        message: json['message'],
        startDateTime: (json['startDateTime'] != null)
            ? new DateTime.fromMillisecondsSinceEpoch(json['startDateTime'])
            : null,
        endDateTime: (json['endDateTime'] != null)
            ? new DateTime.fromMillisecondsSinceEpoch(json['endDateTime'])
            : null,
        coupon: json['coupon']);
  }
}
