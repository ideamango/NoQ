// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'meta_entity.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MetaEntity _$MetaEntityFromJson(Map<String, dynamic> json) {
  return MetaEntity(
    entityId: json['entityId'] as String,
    name: json['name'] as String,
    type: json['type'] as String,
    advanceDays: json['advanceDays'] as int,
    isPublic: json['isPublic'] as bool,
    closedOn: (json['closedOn'] as List)?.map((e) => e as String)?.toList(),
    breakStartHour: json['breakStartHour'] as int,
    breakStartMinute: json['breakStartMinute'] as int,
    breakEndHour: json['breakEndHour'] as int,
    breakEndMinute: json['breakEndMinute'] as int,
    startTimeHour: json['startTimeHour'] as int,
    startTimeMinute: json['startTimeMinute'] as int,
    endTimeHour: json['endTimeHour'] as int,
    endTimeMinute: json['endTimeMinute'] as int,
    isActive: json['isActive'] as bool,
    distance: (json['distance'] as num)?.toDouble(),
    address: json['address'] as String,
    lat: (json['lat'] as num)?.toDouble(),
    lon: (json['lon'] as num)?.toDouble(),
    slotDuration: json['slotDuration'] as int,
    maxAllowed: json['maxAllowed'] as int,
    whatsapp: json['whatsapp'] as String,
    parentId: json['parentId'] as String,
  );
}

Map<String, dynamic> _$MetaEntityToJson(MetaEntity instance) =>
    <String, dynamic>{
      'entityId': instance.entityId,
      'name': instance.name,
      'type': instance.type,
      'advanceDays': instance.advanceDays,
      'isPublic': instance.isPublic,
      'closedOn': instance.closedOn,
      'breakStartHour': instance.breakStartHour,
      'breakStartMinute': instance.breakStartMinute,
      'breakEndHour': instance.breakEndHour,
      'breakEndMinute': instance.breakEndMinute,
      'startTimeHour': instance.startTimeHour,
      'startTimeMinute': instance.startTimeMinute,
      'endTimeHour': instance.endTimeHour,
      'endTimeMinute': instance.endTimeMinute,
      'isActive': instance.isActive,
      'distance': instance.distance,
      'address': instance.address,
      'lat': instance.lat,
      'lon': instance.lon,
      'slotDuration': instance.slotDuration,
      'maxAllowed': instance.maxAllowed,
      'whatsapp': instance.whatsapp,
      'parentId': instance.parentId,
    };
