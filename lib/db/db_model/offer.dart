class Offer {
  Offer({this.message, this.startDateTime, this.endDateTime, this.coupon});

  //SlotId is entityID#20~06~01#9~30

  String message;
  DateTime startDateTime;
  DateTime endDateTime;
  String coupon;

  Map<String, dynamic> toJson() => {
        'message': message,
        'startDateTime': startDateTime.millisecondsSinceEpoch,
        'endDateTime': endDateTime.millisecondsSinceEpoch,
        'coupon': coupon
      };

  static Offer fromJson(Map<String, dynamic> json) {
    if (json == null) return null;
    return new Offer(
        message: json['message'],
        startDateTime:
            new DateTime.fromMillisecondsSinceEpoch(json['startDateTime']),
        endDateTime:
            new DateTime.fromMillisecondsSinceEpoch(json['endDateTime']),
        coupon: json['coupon']);
  }
}
