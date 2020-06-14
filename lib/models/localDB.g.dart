// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'localDB.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UserAppData _$UserAppDataFromJson(Map<String, dynamic> json) {
  return UserAppData(
    json['id'] as String,
    json['phone'] as String,
    (json['upcomingBookings'] as List)
        ?.map((e) => e == null
            ? null
            : BookingAppData.fromJson(e as Map<String, dynamic>))
        ?.toList(),
    (json['storesAccessed'] as List)
        ?.map((e) => e == null
            ? null
            : EntityAppData.fromJson(e as Map<String, dynamic>))
        ?.toList(),
    (json['managedEntities'] as List)
        ?.map((e) => e == null
            ? null
            : EntityAppData.fromJson(e as Map<String, dynamic>))
        ?.toList(),
    json['settings'] == null
        ? null
        : SettingsAppData.fromJson(json['settings'] as Map<String, dynamic>),
  );
}

Map<String, dynamic> _$UserAppDataToJson(UserAppData instance) =>
    <String, dynamic>{
      'id': instance.id,
      'phone': instance.phone,
      'upcomingBookings': instance.upcomingBookings,
      'storesAccessed': instance.storesAccessed,
      'managedEntities': instance.managedEntities,
      'settings': instance.settings,
    };

EntityAppData _$EntityAppDataFromJson(Map<String, dynamic> json) {
  return EntityAppData()
    ..id = json['id'] as String
    ..ownedById = json['ownedById'] as String
    ..eType = json['eType'] as String
    ..name = json['name'] as String
    ..regNum = json['regNum'] as String
    ..adrs = json['adrs'] == null
        ? null
        : AddressAppData.fromJson(json['adrs'] as Map<String, dynamic>)
    ..lat = (json['lat'] as num)?.toDouble()
    ..long = (json['long'] as num)?.toDouble()
    ..opensAt = json['opensAt'] as String
    ..breakTimeFrom = json['breakTimeFrom'] as String
    ..breakTimeTo = json['breakTimeTo'] as String
    ..closesAt = json['closesAt'] as String
    ..daysClosed =
        (json['daysClosed'] as List)?.map((e) => e as String)?.toList()
    ..maxPeopleAllowed = json['maxPeopleAllowed'] as String
    ..contactPersons = (json['contactPersons'] as List)
        ?.map((e) => e == null
            ? null
            : ContactAppData.fromJson(e as Map<String, dynamic>))
        ?.toList()
    ..childCollection = (json['childCollection'] as List)
        ?.map((e) => e == null
            ? null
            : ChildEntityAppData.fromJson(e as Map<String, dynamic>))
        ?.toList()
    ..isFavourite = json['isFavourite'] as bool
    ..publicAccess = json['publicAccess'] as bool;
}

Map<String, dynamic> _$EntityAppDataToJson(EntityAppData instance) =>
    <String, dynamic>{
      'id': instance.id,
      'ownedById': instance.ownedById,
      'eType': instance.eType,
      'name': instance.name,
      'regNum': instance.regNum,
      'adrs': instance.adrs,
      'lat': instance.lat,
      'long': instance.long,
      'opensAt': instance.opensAt,
      'breakTimeFrom': instance.breakTimeFrom,
      'breakTimeTo': instance.breakTimeTo,
      'closesAt': instance.closesAt,
      'daysClosed': instance.daysClosed,
      'maxPeopleAllowed': instance.maxPeopleAllowed,
      'contactPersons': instance.contactPersons,
      'childCollection': instance.childCollection,
      'isFavourite': instance.isFavourite,
      'publicAccess': instance.publicAccess,
    };

ChildEntityAppData _$ChildEntityAppDataFromJson(Map<String, dynamic> json) {
  return ChildEntityAppData()
    ..id = json['id'] as String
    ..entityId = json['entityId'] as String
    ..cType = json['cType'] as String
    ..name = json['name'] as String
    ..regNum = json['regNum'] as String
    ..adrs = json['adrs'] == null
        ? null
        : AddressAppData.fromJson(json['adrs'] as Map<String, dynamic>)
    ..lat = (json['lat'] as num)?.toDouble()
    ..long = (json['long'] as num)?.toDouble()
    ..opensAt = json['opensAt'] as String
    ..breakTimeFrom = json['breakTimeFrom'] as String
    ..breakTimeTo = json['breakTimeTo'] as String
    ..closesAt = json['closesAt'] as String
    ..daysClosed =
        (json['daysClosed'] as List)?.map((e) => e as String)?.toList()
    ..maxPeopleAllowed = json['maxPeopleAllowed'] as String
    ..contactPersons = (json['contactPersons'] as List)
        ?.map((e) => e == null
            ? null
            : ContactAppData.fromJson(e as Map<String, dynamic>))
        ?.toList()
    ..isFavourite = json['isFavourite'] as bool
    ..publicAccess = json['publicAccess'] as bool;
}

Map<String, dynamic> _$ChildEntityAppDataToJson(ChildEntityAppData instance) =>
    <String, dynamic>{
      'id': instance.id,
      'entityId': instance.entityId,
      'cType': instance.cType,
      'name': instance.name,
      'regNum': instance.regNum,
      'adrs': instance.adrs,
      'lat': instance.lat,
      'long': instance.long,
      'opensAt': instance.opensAt,
      'breakTimeFrom': instance.breakTimeFrom,
      'breakTimeTo': instance.breakTimeTo,
      'closesAt': instance.closesAt,
      'daysClosed': instance.daysClosed,
      'maxPeopleAllowed': instance.maxPeopleAllowed,
      'contactPersons': instance.contactPersons,
      'isFavourite': instance.isFavourite,
      'publicAccess': instance.publicAccess,
    };

ContactAppData _$ContactAppDataFromJson(Map<String, dynamic> json) {
  return ContactAppData()
    ..perName = json['perName'] as String
    ..empId = json['empId'] as String
    ..perPhone1 = json['perPhone1'] as String
    ..perPhone2 = json['perPhone2'] as String
    ..role = json['role'] as String
    ..avlFromTime = json['avlFromTime'] as String
    ..avlTillTime = json['avlTillTime'] as String
    ..daysOff = (json['daysOff'] as List)?.map((e) => e as String)?.toList();
}

Map<String, dynamic> _$ContactAppDataToJson(ContactAppData instance) =>
    <String, dynamic>{
      'perName': instance.perName,
      'empId': instance.empId,
      'perPhone1': instance.perPhone1,
      'perPhone2': instance.perPhone2,
      'role': instance.role,
      'avlFromTime': instance.avlFromTime,
      'avlTillTime': instance.avlTillTime,
      'daysOff': instance.daysOff,
    };

BookingAppData _$BookingAppDataFromJson(Map<String, dynamic> json) {
  return BookingAppData(
    json['storeId'] as String,
    json['bookingDate'] == null
        ? null
        : DateTime.parse(json['bookingDate'] as String),
    json['timing'] as String,
    json['tokenNum'] as String,
    json['status'] as String,
  );
}

Map<String, dynamic> _$BookingAppDataToJson(BookingAppData instance) =>
    <String, dynamic>{
      'storeId': instance.storeId,
      'bookingDate': instance.bookingDate?.toIso8601String(),
      'timing': instance.timing,
      'tokenNum': instance.tokenNum,
      'status': instance.status,
    };

AddressAppData _$AddressAppDataFromJson(Map<String, dynamic> json) {
  return AddressAppData(
    addressLine1: json['addressLine1'] as String,
    locality: json['locality'] as String,
    landmark: json['landmark'] as String,
    city: json['city'] as String,
    state: json['state'] as String,
    country: json['country'] as String,
    postalCode: json['postalCode'] as String,
  );
}

Map<String, dynamic> _$AddressAppDataToJson(AddressAppData instance) =>
    <String, dynamic>{
      'addressLine1': instance.addressLine1,
      'locality': instance.locality,
      'landmark': instance.landmark,
      'city': instance.city,
      'state': instance.state,
      'country': instance.country,
      'postalCode': instance.postalCode,
    };

SettingsAppData _$SettingsAppDataFromJson(Map<String, dynamic> json) {
  return SettingsAppData(
    notificationOn: json['notificationOn'] as bool,
  );
}

Map<String, dynamic> _$SettingsAppDataToJson(SettingsAppData instance) =>
    <String, dynamic>{
      'notificationOn': instance.notificationOn,
    };
