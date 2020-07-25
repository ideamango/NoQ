import 'package:noq/utils.dart';
import 'package:json_annotation/json_annotation.dart';

/// This allows the `User` class to access private members in
/// the generated file. The value for this is *.g.dart, where
/// the star denotes the source file name.
part 'configurations.g.dart';

/// An annotation for the code generator to know that this class needs the
/// JSON serialization logic to be generated.
@JsonSerializable()
class Configurations {
  Configurations(
      {this.entityTypes,
      this.messages,
      this.keyMessage,
      this.contactEmail,
      this.contactPhone,
      this.supportReasons,
      this.enableDonation});

  List<String> entityTypes;
  List<String> messages;
  String keyMessage;
  String contactEmail;
  String contactPhone;
  List<String> supportReasons;
  bool enableDonation;

  factory Configurations.fromJson(Map<String, dynamic> json) =>
      _$ConfigurationsFromJson(json);

  /// `toJson` is the convention for a class to declare support for serialization
  /// to JSON. The implementation simply calls the private, generated
  /// helper method `_$UserToJson`.
  Map<String, dynamic> toJson() => _$ConfigurationsToJson(this);

  // Map<String, dynamic> toJson() => {
  //       'entityTypes': entityTypes,
  //       'messages': messages,
  //       'keyMessage': keyMessage,
  //       'contactEmail': contactEmail,
  //       'contactPhone': contactPhone,
  //       'supportReasons': supportReasons,
  //       'enableDonation': enableDonation
  //     };

  // static Configurations fromJson(Map<String, dynamic> json) {
  //   if (json == null) return null;
  //   return new Configurations(
  //       entityTypes: convertToStringsArrayFromJson(json['entityTypes']),
  //       messages: convertToStringsArrayFromJson(json['messages']),
  //       keyMessage: json['keyMessage'],
  //       contactEmail: json['contactEmail'],
  //       contactPhone: json['contactPhone'],
  //       supportReasons: convertToStringsArrayFromJson(json['supportReasons']),
  //       enableDonation: json['enableDonation']);
  // }

  static List<String> convertToStringsArrayFromJson(List<dynamic> json) {
    List<String> strs = new List<String>();
    if (Utils.isNullOrEmpty(json)) return strs;

    for (String str in json) {
      strs.add(str);
    }
    return strs;
  }
}
