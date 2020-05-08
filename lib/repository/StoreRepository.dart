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

List<StoreAppData> getDummyList() {
  List<StoreAppData> searchStores = [
    new StoreAppData(
        "1",
        "Apartment vendor",
        "Aparna Cyberzon, Hyderabad",
        17.441903,
        78.375869,
        "9:00 am",
        "10:00 pm",
        [
          "1",
          "6",
        ],
        true,
        false),
    new StoreAppData(
        "2",
        "Vijetha",
        "MyHome Vihanga, rthrthertherhtrherth,Gachibowli, Hyderabad",
        17.432400,
        78.331858,
        "9:00 am",
        "10:00 pm",
        ["7"],
        true,
        false),
    new StoreAppData("3", "IKEA", "Hitech City, Madhapur, Hyderabad", 17.435436,
        78.386707, "9:00 am", "10:00 pm", ["0"], false, false),
    new StoreAppData("4", "Inorbit", "Kavuri Hills, Hyderabad", 17.435436,
        78.386707, "9:00 am", "10:00 pm", ["0"], false, false),
    new StoreAppData("5", "PVR", "Kavuri Hills, Hyderabad", 17.435436,
        78.386707, "8:00 am", "11:00 pm", ["0"], false, false)
  ];
  return searchStores;
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
