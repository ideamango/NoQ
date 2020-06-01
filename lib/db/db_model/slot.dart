class Slot {
  Slot(
      {this.entityId,
      this.currentNumber,
      this.maxAllowed,
      this.dateTime,
      this.slotDuration,
      this.isFull});

  //SlotDocumentId is entityID#20~06~01#9~30 it is not auto-generated, will help in not duplicating the record

  String entityId;
  int currentNumber;
  int maxAllowed;
  DateTime dateTime;
  int slotDuration;
  bool isFull;

  Map<String, dynamic> toJson() => {
        'entityId': entityId,
        'currentNumber': currentNumber,
        'maxAllowed': maxAllowed,
        'dateTime': dateTime,
        'slotDuration': slotDuration,
        'isFull': isFull
      };

  static Slot fromJson(Map<String, dynamic> json) {
    return new Slot(
      entityId: json['entityId'].toString(),
      currentNumber: json['currentNumber'],
      maxAllowed: json['maxAllowed'],
      dateTime: new DateTime.fromMillisecondsSinceEpoch(
          json['dateTime'].seconds * 1000),
      slotDuration: json['slotDuration'],
      isFull: json['isFull'],
    );
  }
}
