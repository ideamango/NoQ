class Address {
  Address(
      {this.address = "",
      this.locality = "",
      this.city = "",
      this.state = "",
      this.country = "",
      this.landmark = "",
      this.zipcode = ""});

  String? address;
  String? locality;
  String? city;
  String? state;
  String? country;
  String? landmark;
  String? zipcode;

  Map<String, dynamic> toJson() => {
        'address': address,
        'locality': locality,
        'city': city,
        'state': state,
        'country': country,
        'landmark': landmark,
        'zipcode': zipcode
      };

  static Address fromJson(Map<String, dynamic> json) {
    return new Address(
        address: json['address'],
        locality: json['locality'],
        city: json['city'],
        state: json['state'],
        country: json['country'],
        landmark: json['landmark'],
        zipcode: json['zipcode']);
  }
}
