class Slot {
  String id;
  String storeId;
  String slotStrTime;
  String slotEndTime;
  String slotAvlFlg;
  String slotSelected = "false";
  bool slotBooked;
  String tokenNum;

  Slot(
      {this.id,
      this.storeId,
      this.slotStrTime,
      this.slotEndTime,
      this.slotAvlFlg,
      this.slotSelected,
      this.slotBooked,
      this.tokenNum});
  // factory Slot.fromJson(Map<String, dynamic> json) => _$SlotFromJson(json);

  // Map<String, dynamic> toJson() => _$SlotToJson(this);
  factory Slot.fromJSON(Map<String, dynamic> jsonMap) {
    return Slot(
        id: jsonMap['id'],
        storeId: jsonMap['storeId'],
        slotStrTime: jsonMap['slotStrTime'],
        slotEndTime: jsonMap['slotEndTime'],
        slotAvlFlg: jsonMap['slotAvlFlg'],
        slotSelected: jsonMap['slotSelected'],
        slotBooked: jsonMap['slotBooked'],
        tokenNum: jsonMap['tokenNum']);
  }
}
