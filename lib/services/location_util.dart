import 'package:flutter/material.dart';
import 'package:noq/location.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter/services.dart';

class LocationUtil {
  static Future<Location> getLocation() async {
    Location locData;

    IPStackLocation ipStackLocation = await _getLocationFromIPStack();
    if (ipStackLocation != null) {
      locData = _convertFromIPStack(ipStackLocation);
    } else {
      //fallback to ip-api.com
      IPAPILocation ipAPILocation = await _callIPAPI();
      if (ipAPILocation != null) {
        locData = _convertFromIPAPI(ipAPILocation);
      }
    }

    if (locData == null) {
      //just to avoid failures and user can set the calling code while login
      locData = new Location();
    }

    String data = await rootBundle.loadString("assets/calling_codes.json");
    locData.allCallingCodes = json.decode(data);
    locData.callingCode = locData.allCallingCodes[locData.countryCode];

    return locData;
  }

  static Future<IPAPILocation> _callIPAPI() async {
    String ipAPIURL = "http://ip-api.com/json";

    final response = await http.get(ipAPIURL);

    if (response.statusCode == 200) {
      // If the server did return a 200 OK response,
      // then parse the JSON.
      return IPAPILocation.fromJson(jsonDecode(response.body));
    }

    return null;
  }

  static Future<IPStackLocation> _getLocationFromIPStack() async {
    String ipstackURL =
        "http://api.ipstack.com/183.83.146.130?access_key=7dfc143d00f07856308ebcdd836dda8e";

    final response = await http.get(ipstackURL);

    if (response.statusCode == 200) {
      // If the server did return a 200 OK response,
      // then parse the JSON.
      return IPStackLocation.fromJson(jsonDecode(response.body));
    }

    return null;
  }

  static Location _convertFromIPStack(IPStackLocation ipstackLoc) {
    Location loc = Location();
    loc.callingCode = ipstackLoc.calling_code;
    loc.city = ipstackLoc.city;
    loc.country = ipstackLoc.country_name;
    loc.countryCode = ipstackLoc.country_code;
    loc.isEU = ipstackLoc.continent_code == "EU" ? true : false;
    loc.region = ipstackLoc.region_name;
    loc.regionCode = ipstackLoc.region_code;
    loc.timezone = null;
    loc.zip = ipstackLoc.zip;
    loc.lat = ipstackLoc.latitude;
    loc.lon = ipstackLoc.longitude;
    loc.continent = ipstackLoc.continent_name; //"Europe"
    loc.continentCode = ipstackLoc.continent_code; //"EU"

    return loc;
  }

  static Location _convertFromIPAPI(IPAPILocation ipAPILocation) {
    Location loc = Location();
    loc.callingCode = null;
    loc.city = ipAPILocation.city;
    loc.country = ipAPILocation.country;
    loc.countryCode = ipAPILocation.countryCode;
    loc.isEU =
        (ipAPILocation.timezone.substring(0, 6) == "Europe") ? true : false;
    loc.region = ipAPILocation.regionName;
    loc.regionCode = ipAPILocation.region;
    loc.timezone = ipAPILocation.timezone; //e.g. "Europe/London"
    loc.zip = ipAPILocation.zip;
    loc.lat = ipAPILocation.lat;
    loc.lon = ipAPILocation.lon;
    loc.continent = null;
    loc.continentCode = null;
  }
}

class IPStackLocation {
  String country_name;
  String country_code;
  String region_code;
  String region_name;
  String city;
  String zip;
  bool is_eu;
  String calling_code;
  double latitude;
  double longitude;
  String continent_name;
  String continent_code;

  IPStackLocation(
      {this.country_name,
      this.country_code,
      this.region_code,
      this.region_name,
      this.city,
      this.zip,
      this.is_eu,
      this.calling_code,
      this.continent_code,
      this.continent_name});

  factory IPStackLocation.fromJson(Map<String, dynamic> json) {
    return IPStackLocation(
        country_name: json['country_name'],
        country_code: json['country_code'],
        region_code: json['region_code'],
        region_name: json['region_name'],
        city: json['city'],
        zip: json['zip'],
        is_eu: json['is_eu'],
        calling_code: json['calling_code'],
        continent_code: json['continent_code'],
        continent_name: json['continent_name']);
  }
}

class IPAPILocation {
  String country;
  String countryCode;
  String region;
  String regionName;
  String city;
  String zip;
  String timezone;
  double lat;
  double lon;

  IPAPILocation(
      {this.country,
      this.countryCode,
      this.region,
      this.regionName,
      this.city,
      this.zip,
      this.timezone,
      this.lat,
      this.lon});

  factory IPAPILocation.fromJson(Map<String, dynamic> json) {
    return IPAPILocation(
        country: json['country'],
        countryCode: json['countryCode'],
        region: json['region'],
        regionName: json['regionName'],
        city: json['city'],
        zip: json['zip'],
        timezone: json['timezone'],
        lat: json['lat'],
        lon: json['lon']);
  }
}