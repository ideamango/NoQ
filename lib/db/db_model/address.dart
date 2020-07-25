import 'package:json_annotation/json_annotation.dart';

/// This allows the `User` class to access private members in
/// the generated file. The value for this is *.g.dart, where
/// the star denotes the source file name.
part 'address.g.dart';

/// An annotation for the code generator to know that this class needs the
/// JSON serialization logic to be generated.
@JsonSerializable()
class Address {
  Address(
      {this.address,
      this.locality,
      this.city,
      this.state,
      this.country,
      this.landmark,
      this.zipcode});

  String address;
  String locality;
  String city;
  String state;
  String country;
  String landmark;
  String zipcode;

  factory Address.fromJson(Map<String, dynamic> json) =>
      _$AddressFromJson(json);

  /// `toJson` is the convention for a class to declare support for serialization
  /// to JSON. The implementation simply calls the private, generated
  /// helper method `_$UserToJson`.
  Map<String, dynamic> toJson() => _$AddressToJson(this);

  // Map<String, dynamic> toJson() => {
  //       'address': address,
  //       'locality': locality,
  //       'city': city,
  //       'state': state,
  //       'country': country,
  //       'landmark': landmark,
  //       'zipcode': zipcode
  //     };

  // static Address fromJson(Map<String, dynamic> json) {
  //   if (json == null) return null;
  //   return new Address(
  //       address: json['address'],
  //       locality: json['locality'],
  //       city: json['city'],
  //       state: json['state'],
  //       country: json['country'],
  //       landmark: json['landmark'],
  //       zipcode: json['zipcode']);
  // }
}
