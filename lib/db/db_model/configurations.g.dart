// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'configurations.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Configurations _$ConfigurationsFromJson(Map<String, dynamic> json) {
  return Configurations(
    entityTypes:
        (json['entityTypes'] as List)?.map((e) => e as String)?.toList(),
    messages: (json['messages'] as List)?.map((e) => e as String)?.toList(),
    keyMessage: json['keyMessage'] as String,
    contactEmail: json['contactEmail'] as String,
    contactPhone: json['contactPhone'] as String,
    supportReasons:
        (json['supportReasons'] as List)?.map((e) => e as String)?.toList(),
    enableDonation: json['enableDonation'] as bool,
  );
}

Map<String, dynamic> _$ConfigurationsToJson(Configurations instance) =>
    <String, dynamic>{
      'entityTypes': instance.entityTypes,
      'messages': instance.messages,
      'keyMessage': instance.keyMessage,
      'contactEmail': instance.contactEmail,
      'contactPhone': instance.contactPhone,
      'supportReasons': instance.supportReasons,
      'enableDonation': instance.enableDonation,
    };
