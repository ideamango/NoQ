class Offer {
  Offer({this.message = "", this.coupon = ""});

  //SlotId is entityID#20~06~01#9~30

  String message;
  DateTime startDateTime;
  DateTime endDateTime;
  String coupon;

  Map<String, dynamic> toJson() => {
        'message': message,
        'startDateTime': startDateTime?.millisecondsSinceEpoch,
        'endDateTime': endDateTime?.millisecondsSinceEpoch,
        'coupon': coupon
      };

  static Offer fromJson(Map<String, dynamic> json) {
    if (json == null) {
      return null;
    }
    Offer ofr = Offer(message: json['message'], coupon: json['coupon']);

    ofr.startDateTime = (json['startDateTime'] != null)
        ? new DateTime.fromMillisecondsSinceEpoch(json['startDateTime'])
        : null;

    ofr.endDateTime = (json['endDateTime'] != null)
        ? new DateTime.fromMillisecondsSinceEpoch(json['endDateTime'])
        : null;

    return ofr;
  }
}
