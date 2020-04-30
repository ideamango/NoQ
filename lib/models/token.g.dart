// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'token.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Token _$TokenFromJson(Map<String, dynamic> json) {
  return Token(
    id: json['id'] as int,
    phoneNo: json['phoneNo'] as String,
  )..tokenNo = json['tokenNo'] as String;
}

Map<String, dynamic> _$TokenToJson(Token instance) => <String, dynamic>{
      'id': instance.id,
      'tokenNo': instance.tokenNo,
      'phoneNo': instance.phoneNo,
    };
