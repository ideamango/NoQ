class Slot {
  int id;
  String storeId;
  String slotStrTime;
  String slotEndTime;
  int slotAvlFlg;

  Slot({
    this.id,
    this.storeId,
    this.slotStrTime,
    this.slotEndTime,
    this.slotAvlFlg,
  });

  // factory Store.fromJSON(Map<String, dynamic> jsonMap) {
  //   return Store(
  //       id: jsonMap['id'],
  //       name: jsonMap['name'],
  //       adrs: jsonMap['adrs'],
  //       regNum: jsonMap['regNum'],
  //       lat: jsonMap['lat'],
  //       long: jsonMap['long'],
  //       opensAt: jsonMap['opensAt'],
  //       closesAt: jsonMap['closesAt'],
  //       daysClosed: jsonMap['daysClosed'],
  //       insideAptFlg: jsonMap['insideAptFlg']);
  // }
}
