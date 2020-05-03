// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'localDB.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UserAppData _$UserAppDataFromJson(Map<String, dynamic> json) {
  return UserAppData(
    json['id'] as String,
    json['name'] as String,
    json['phone'] as String,
    json['adrs'] as String,
    (json['upcomingBookings'] as List)
        ?.map((e) => e == null
            ? null
            : BookingAppData.fromJson(e as Map<String, dynamic>))
        ?.toList(),
    (json['pastBookings'] as List)
        ?.map((e) => e == null
            ? null
            : BookingAppData.fromJson(e as Map<String, dynamic>))
        ?.toList(),
    (json['favStores'] as List)
        ?.map((e) =>
            e == null ? null : StoreAppData.fromJson(e as Map<String, dynamic>))
        ?.toList(),
    json['settings'] == null
        ? null
        : SettingsAppData.fromJson(json['settings'] as Map<String, dynamic>),
  );
}

Map<String, dynamic> _$UserAppDataToJson(UserAppData instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'phone': instance.phone,
      'adrs': instance.adrs,
      'upcomingBookings': instance.upcomingBookings,
      'pastBookings': instance.pastBookings,
      'favStores': instance.favStores,
      'settings': instance.settings,
    };

StoreAppData _$StoreAppDataFromJson(Map<String, dynamic> json) {
  return StoreAppData(
    json['id'] as String,
    json['name'] as String,
    json['adrs'] as String,
    (json['lat'] as num)?.toDouble(),
    (json['long'] as num)?.toDouble(),
    json['opensAt'] as String,
    json['closesAt'] as String,
    (json['daysClosed'] as List)?.map((e) => e as String)?.toList(),
    json['insideAptFlg'] as bool,
    json['isFavourite'] as bool,
  );
}

Map<String, dynamic> _$StoreAppDataToJson(StoreAppData instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'adrs': instance.adrs,
      'lat': instance.lat,
      'long': instance.long,
      'opensAt': instance.opensAt,
      'closesAt': instance.closesAt,
      'daysClosed': instance.daysClosed,
      'insideAptFlg': instance.insideAptFlg,
      'isFavourite': instance.isFavourite,
    };

BookingAppData _$BookingAppDataFromJson(Map<String, dynamic> json) {
  return BookingAppData(
    json['storeName'] as String,
    json['timing'] as String,
    json['tokenNum'] as String,
    json['status'] as String,
  );
}

Map<String, dynamic> _$BookingAppDataToJson(BookingAppData instance) =>
    <String, dynamic>{
      'storeName': instance.storeName,
      'timing': instance.timing,
      'tokenNum': instance.tokenNum,
      'status': instance.status,
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
