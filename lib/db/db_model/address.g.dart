// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'address.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Address _$AddressFromJson(Map<String, dynamic> json) {
  return Address(
    address: json['address'] as String,
    locality: json['locality'] as String,
    city: json['city'] as String,
    state: json['state'] as String,
    country: json['country'] as String,
    landmark: json['landmark'] as String,
    zipcode: json['zipcode'] as String,
  );
}

Map<String, dynamic> _$AddressToJson(Address instance) => <String, dynamic>{
      'address': instance.address,
      'locality': instance.locality,
      'city': instance.city,
      'state': instance.state,
      'country': instance.country,
      'landmark': instance.landmark,
      'zipcode': instance.zipcode,
    };
