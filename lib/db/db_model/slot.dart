class Slot {
  Slot(
      {this.slotId,
      this.currentNumber,
      this.maxAllowed,
      this.dateTime,
      this.slotDuration,
      this.isFull});

  //SlotId is entityID#20~06~01#9~30

  String slotId;
  int currentNumber;
  int maxAllowed;
  DateTime dateTime;
  int slotDuration;
  bool isFull = false;

  Map<String, dynamic> toJson() => {
        'slotId': slotId,
        'currentNumber': currentNumber,
        'maxAllowed': maxAllowed,
        'dateTime': dateTime,
        'slotDuration': slotDuration,
        'isFull': isFull
      };

  static Slot fromJson(Map<String, dynamic> json) {
    if (json == null) return null;
    return new Slot(
        slotId: json['slotId'].toString(),
        currentNumber: json['currentNumber'],
        maxAllowed: json['maxAllowed'],
        dateTime: new DateTime.fromMillisecondsSinceEpoch(
            json['dateTime'].seconds * 1000),
        slotDuration: json['slotDuration'],
        isFull: json['isFull']);
  }
}
