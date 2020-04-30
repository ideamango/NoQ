import 'package:json_annotation/json_annotation.dart';
part 'store.g.dart';

@JsonSerializable()
class Store {
  final int id;
  final String name;
  final String adrs;
  final String regNum;
  final double lat;
  final double long;
  final String opensAt;
  final String closesAt;
  final List<String> daysClosed;
  final bool insideAptFlg;

  Store(this.id, this.name, this.adrs, this.regNum, this.lat, this.long,
      this.opensAt, this.closesAt, this.daysClosed, this.insideAptFlg);
  factory Store.fromJson(Map<String, dynamic> json) => _$StoreFromJson(json);

  // Map<String, dynamic> toJson() => _$SlotToJson(this);
  // factory Store.fromJSON(Map<String, dynamic> jsonMap) {
  //   return Store(
  //       jsonMap['id'],
  //       jsonMap['name'],
  //       jsonMap['adrs'],
  //       jsonMap['regNum'],
  //       jsonMap['lat'],
  //       jsonMap['long'],
  //       jsonMap['opensAt'],
  //       jsonMap['closesAt'],
  //       jsonMap['daysClosed'],
  //       jsonMap['insideAptFlg']);
  // }
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

final xstores = [
  new Store(1, "IKEA", "MyHome Vihanga, Gachibowli, Hyderabad", "Reg1",
      17.441903, 78.375869, "9:00 am", "10:00 pm", ["ew", "er", "er"], false),
  new Store(2, "Vijetha", "MyHome Vihanga, Gachibowli, Hyderabad", "Reg1",
      17.432400, 78.331858, "9:00 am", "10:00 pm", ["ew", "er", "er"], true),
  new Store(3, "Vijetha", "MyHome Vihanga Gachibowli Hyderabad", "Reg1",
      17.435436, 78.386707, "9:00 am", "10:00 pm", ["ew", "er", "er"], false)
];
