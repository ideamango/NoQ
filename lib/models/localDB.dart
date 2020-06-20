import 'package:json_annotation/json_annotation.dart';
import 'package:noq/constants.dart';
part 'localDB.g.dart';

@JsonSerializable()
class UserAppData {
  final String id;
  //final String name;
  final String phone;
  // final String adrs;
  final List<BookingAppData> upcomingBookings;
  List<EntityAppData> storesAccessed;
  List<EntityAppData> managedEntities;

  final SettingsAppData settings;

  UserAppData(this.id, this.phone, this.upcomingBookings, this.storesAccessed,
      this.managedEntities, this.settings);

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
class EntityAppData {
  String id;
  String ownedById;
  String eType;
  String name;
  String regNum;
  AddressAppData adrs;
  double lat;
  double long;
  String opensAt;
  String breakTimeFrom;
  String breakTimeTo;
  String closesAt;
  List<String> daysClosed;
  String maxPeopleAllowed;
  List<ContactAppData> contactPersons;
  List<ChildEntityAppData> childCollection;
  bool isFavourite;
  bool publicAccess;

  EntityAppData();
  EntityAppData.eType(this.eType, this.id);

  EntityAppData.values(
      this.id,
      this.ownedById,
      this.eType,
      this.name,
      this.regNum,
      this.adrs,
      this.lat,
      this.long,
      this.opensAt,
      this.breakTimeFrom,
      this.breakTimeTo,
      this.closesAt,
      this.daysClosed,
      this.maxPeopleAllowed,
      this.contactPersons,
      this.childCollection,
      this.isFavourite,
      this.publicAccess);
  factory EntityAppData.fromJson(Map<String, dynamic> json) =>
      _$EntityAppDataFromJson(json);

  Map<String, dynamic> toJson() => _$EntityAppDataToJson(this);

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
class ChildEntityAppData {
  String id;
  String parentEntityId;
  String cType;
  String name;
  String regNum;
  AddressAppData adrs;
  double lat;
  double long;
  String opensAt;
  String breakTimeFrom;
  String breakTimeTo;
  String closesAt;
  List<String> daysClosed;
  String maxPeopleAllowed;
  List<ContactAppData> contactPersons;
  bool isFavourite;
  bool publicAccess;
  ChildEntityAppData();

  ChildEntityAppData.cType(this.id, this.cType, this.parentEntityId, this.adrs);

  ChildEntityAppData.allValues(
    this.id,
    this.parentEntityId,
    this.cType,
    this.name,
    this.regNum,
    this.adrs,
    this.lat,
    this.long,
    this.opensAt,
    this.breakTimeFrom,
    this.breakTimeTo,
    this.closesAt,
    this.daysClosed,
    this.maxPeopleAllowed,
    this.contactPersons,
    this.isFavourite,
    this.publicAccess,
  );
  factory ChildEntityAppData.fromJson(Map<String, dynamic> json) =>
      _$ChildEntityAppDataFromJson(json);

  Map<String, dynamic> toJson() => _$ChildEntityAppDataToJson(this);
}

@JsonSerializable()
class ContactAppData {
  String perName;
  String empId;
  String perPhone1;
  String perPhone2;
  String role;
  String avlFromTime;
  String avlTillTime;
  List<String> daysOff;
  ContactAppData();
  ContactAppData.type(this.role);

  ContactAppData.values(
      this.perName,
      this.empId,
      this.perPhone1,
      this.perPhone2,
      this.role,
      this.avlFromTime,
      this.avlTillTime,
      this.daysOff);
  factory ContactAppData.fromJson(Map<String, dynamic> json) =>
      _$ContactAppDataFromJson(json);

  Map<String, dynamic> toJson() => _$ContactAppDataToJson(this);

  // factory BookingAppData.fromJSON(Map<String, dynamic> jsonMap) {
  //   return BookingAppData(
  //       storeName: jsonMap['storeName'],
  //       timing: jsonMap['timing'],
  //       tokenNum: jsonMap['tokenNum'],
  //       status: jsonMap['status']);
  // }
}

@JsonSerializable()
class BookingAppData {
  String storeId;
  DateTime bookingDate;
  String timing;
  String tokenNum;
  String status;

  BookingAppData(
      this.storeId, this.bookingDate, this.timing, this.tokenNum, this.status);
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
class AddressAppData {
  String addressLine1;
  String locality;
  String landmark;
  String city;
  String state;
  String country;
  String postalCode;

  AddressAppData(
      {this.addressLine1,
      this.locality,
      this.landmark,
      this.city,
      this.state,
      this.country,
      this.postalCode});
  @override
  String toString() {
    String adrsStr;
    adrsStr = addressLine1 + locality + city + postalCode;

    return adrsStr;
  }

  factory AddressAppData.fromJson(Map<String, dynamic> json) =>
      _$AddressAppDataFromJson(json);

  Map<String, dynamic> toJson() => _$AddressAppDataToJson(this);

  // factory SettingsAppData.fromJSON(Map<String, dynamic> jsonMap) {
  //   return SettingsAppData(notificationOn: jsonMap['notificationOn']);
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

class BookingListItem {
  EntityAppData storeInfo;
  BookingAppData bookingInfo;

  BookingListItem(this.storeInfo, this.bookingInfo);
}
