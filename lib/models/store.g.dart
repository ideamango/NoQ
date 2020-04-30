// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'store.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Store _$StoreFromJson(Map<String, dynamic> json) {
  return Store(
    json['id'] as int,
    json['name'] as String,
    json['adrs'] as String,
    json['regNum'] as String,
    (json['lat'] as num)?.toDouble(),
    (json['long'] as num)?.toDouble(),
    json['opensAt'] as String,
    json['closesAt'] as String,
    (json['daysClosed'] as List)?.map((e) => e as String)?.toList(),
    json['insideAptFlg'] as bool,
  );
}

Map<String, dynamic> _$StoreToJson(Store instance) => <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'adrs': instance.adrs,
      'regNum': instance.regNum,
      'lat': instance.lat,
      'long': instance.long,
      'opensAt': instance.opensAt,
      'closesAt': instance.closesAt,
      'daysClosed': instance.daysClosed,
      'insideAptFlg': instance.insideAptFlg,
    };
