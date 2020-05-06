import 'package:json_annotation/json_annotation.dart';
part 'localDB.g.dart';

@JsonSerializable()
class UserAppData {
  final String id;
  final String name;
  final String phone;
  final String adrs;
  final List<BookingAppData> upcomingBookings;
  final List<BookingAppData> pastBookings;
  final List<StoreAppData> favStores;
  final SettingsAppData settings;

  UserAppData(this.id, this.name, this.phone, this.adrs, this.upcomingBookings,
      this.pastBookings, this.favStores, this.settings);

  factory UserAppData.fromJson(Map<String, dynamic> json) =>
      _$UserAppDataFromJson(json);

  Map<String, dynamic> toJson() => _$UserAppDataToJson(this);

  // factory LocalUser.fromJSON(Map<String, dynamic> jsonMap) {
  //   return LocalUser(
  //       jsonMap['id'],
  //       jsonMap['name'],
  //       jsonMap['adrs'],
  //       jsonMap['upcomingBookings'],
  //       jsonMap['pastBookings'],
  //       jsonMap['favStores'],
  //       jsonMap['settings']);
  // }
}

@JsonSerializable()
class StoreAppData {
  final String id;
  final String name;
  final String adrs;
  final double lat;
  final double long;
  final String opensAt;
  final String closesAt;

  final List<String> daysClosed;
  final bool insideAptFlg;
  bool isFavourite;

  StoreAppData(this.id, this.name, this.adrs, this.lat, this.long, this.opensAt,
      this.closesAt, this.daysClosed, this.insideAptFlg, this.isFavourite);
  factory StoreAppData.fromJson(Map<String, dynamic> json) =>
      _$StoreAppDataFromJson(json);

  Map<String, dynamic> toJson() => _$StoreAppDataToJson(this);

  // factory LocalStore.fromJSON(Map<String, dynamic> jsonMap) {
  //   return LocalStore(
  //       jsonMap['id'],
  //       jsonMap['name'],
  //       jsonMap['adrs'],
  //       jsonMap['lat'],
  //       jsonMap['long'],
  //       jsonMap['opensAt'],
  //       jsonMap['closesAt'],
  //       jsonMap['daysClosed'],
  //       jsonMap['insideAptFlg']);
  // }
  // Map<String, dynamic> toJSON() {
  //   return ({
  //     'id': this.id,
  //     'name': this.name,
  //     'adrs': this.adrs,
  //     'lat': this.lat,
  //     'long': this.long,
  //     'opensAt': this.opensAt,
  //     'closesAt': this.closesAt,
  //     'daysClosed': this.daysClosed,
  //     'insideAptFlg': this.insideAptFlg
  //   });
  // }
}

@JsonSerializable()
class BookingAppData {
  String storeId;
  String storeName;
  DateTime bookingDate;
  String timing;
  String tokenNum;
  String status;

  BookingAppData(this.storeId, this.storeName, this.bookingDate, this.timing,
      this.tokenNum, this.status);
  factory BookingAppData.fromJson(Map<String, dynamic> json) =>
      _$BookingAppDataFromJson(json);

  Map<String, dynamic> toJson() => _$BookingAppDataToJson(this);

  // factory BookingAppData.fromJSON(Map<String, dynamic> jsonMap) {
  //   return BookingAppData(
  //       storeName: jsonMap['storeName'],
  //       timing: jsonMap['timing'],
  //       tokenNum: jsonMap['tokenNum'],
  //       status: jsonMap['status']);
  // }
}

@JsonSerializable()
class SettingsAppData {
  bool notificationOn;

  SettingsAppData({this.notificationOn});
  factory SettingsAppData.fromJson(Map<String, dynamic> json) =>
      _$SettingsAppDataFromJson(json);

  Map<String, dynamic> toJson() => _$SettingsAppDataToJson(this);

  // factory SettingsAppData.fromJSON(Map<String, dynamic> jsonMap) {
  //   return SettingsAppData(notificationOn: jsonMap['notificationOn']);
  // }
}

// final dummyUser = [
//   new LocalUser(1, "IKEA", "MyHome Vihanga, Gachibowli, Hyderabad", "9:00 am",
//       "10:00 pm", ["ew", "er", "er"], false),
// ];
