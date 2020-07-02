import "dart:convert";
import "package:http/http.dart";
import 'package:noq/models/localDB.dart';
import "package:noq/models/store.dart";

// Get list of Stores from Server

Future<List<Store>> getStores() async {
  List<Store> stores;
  // make GET request
  String url = "https://jsonplaceholder.typicode.com/posts";
  Response res =
      await get(Uri.encodeFull(url), headers: {"Accept": "application/json"});
  int statusCode = res.statusCode;
  //Map<String, String> headers = response.headers;
  //String contentType = headers["content-type"];
  //Check if status code is 200
  if (statusCode == 404) {
    //in case of no results found

  } else if (statusCode == 200) {
    var data = json.decode(res.body);
    var resStores = data["stores"] as List;

    stores = resStores.map<Store>((data) => Store.fromJson(data)).toList();
    return stores;
  }
  return null;
}

List<EntityAppData> getLocalStoreList() {
  List<EntityAppData> searchStores = [
    new EntityAppData.values(
        "AQ1",
        "Owner1",
        'Apartment',
        "Aparna CyberZon Apartment",
        "Reg123",
        null,
        17.441903,
        78.375869,
        "8:00 am",
        "12:00 pm",
        "01:00 pm",
        "10:00 pm",
        [
          "1",
          "6",
        ],
        "20",
        [],
        [],
        true,
        false),
    new EntityAppData.values(
        "VJ2",
        "Owner1",
        'HyperMart',
        "Vijetha Store",
        "123456789",
        null,
        17.432400,
        78.331858,
        "9:00 am",
        "12:00 pm",
        "01:00 pm",
        "10:00 pm",
        ["7"],
        "20",
        [],
        [],
        true,
        true),
    new EntityAppData.values(
        "AB34",
        "Owner2",
        'MedicalStore',
        "Medplus Pharmacy",
        "123456789",
        null,
        17.432400,
        78.331858,
        "9:00 am",
        "12:00 pm",
        "01:00 pm",
        "10:00 pm",
        ["7"],
        "20",
        [],
        [],
        true,
        false),
    new EntityAppData.values(
        "In77",
        "Owner3",
        'HyperMart',
        "Reliance Mart",
        "123456789",
        null,
        17.432400,
        78.331858,
        "9:00 am",
        "12:00 pm",
        "01:00 pm",
        "10:00 pm",
        ["7"],
        "20",
        [],
        [],
        true,
        true),
    new EntityAppData.values(
        "IK12",
        'Owner4',
        'Mall',
        "IKEA Store",
        "123456789",
        null,
        17.432400,
        78.331858,
        "9:00 am",
        "12:00 pm",
        "01:00 pm",
        "10:00 pm",
        ["7"],
        "20",
        [],
        [],
        false,
        true)
  ];
  return searchStores;
}

List<EntityAppData> getStoreListServer() {
  List<EntityAppData> searchStores = [
    new EntityAppData.values(
        "1231",
        'Owner8',
        'Mall',
        "Inorbit Mall",
        "Reg123",
        null,
        17.441903,
        78.375869,
        "8:00 am",
        "12:00 pm",
        "01:00 pm",
        "10:00 pm",
        [
          "1",
          "6",
        ],
        "20",
        [],
        [],
        true,
        false),
    new EntityAppData.values(
        "1231",
        'Owner8',
        'Salon',
        "Mirrors Salon",
        "Reg123",
        null,
        17.441903,
        78.375869,
        "8:00 am",
        "12:00 pm",
        "01:00 pm",
        "10:00 pm",
        [
          "1",
          "6",
        ],
        "20",
        [],
        [],
        true,
        false),
    new EntityAppData.values(
        "157777231",
        'Owner9',
        'Apartment',
        "Aparna Sarovar Apartment",
        "Reg123",
        null,
        17.441903,
        78.375869,
        "8:00 am",
        "12:00 pm",
        "01:00 pm",
        "10:00 pm",
        [
          "1",
          "6",
        ],
        "20",
        [],
        [],
        true,
        false),
    new EntityAppData.values(
        "erwer1231",
        'Owner10',
        'Apartment',
        "Aparna CyberLife Apartment",
        "Reg123",
        null,
        17.441903,
        78.375869,
        "8:00 am",
        "12:00 pm",
        "01:00 pm",
        "10:00 pm",
        [
          "1",
          "6",
        ],
        "20",
        [],
        [],
        true,
        false),
  ];
  return searchStores;
}

List<EntityAppData> getTypedEntities(String entityType) {
  List<EntityAppData> filteredList = new List<EntityAppData>();
  List<EntityAppData> searchStores = getStoreListServer();

  for (var en in searchStores) {
    if (en.eType.toLowerCase() == entityType.toLowerCase())
      filteredList.add(en);
  }

  return filteredList;
}

// List<Store> getUserFavStores() {
//   List<Store> favStores = [
//     new Store(1, "IKEA", "MyHome Vihanga, Gachibowli, Hyderabad", "Reg1",
//         17.441903, 78.375869, "9:00 am", "10:00 pm", ["ew", "er", "er"], false),
//     new Store(2, "Vijetha", "MyHome Vihanga, Gachibowli, Hyderabad", "Reg1",
//         17.432400, 78.331858, "9:00 am", "10:00 pm", ["ew", "er", "er"], true),
//     new Store(3, "Inorbit", "MyHome Vihanga Gachibowli Hyderabad", "Reg1",
//         17.435436, 78.386707, "9:00 am", "10:00 pm", ["ew", "er", "er"], false)
//   ];
//   return favStores;
// }
