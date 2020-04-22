import "dart:convert";
import "package:http/http.dart";
import "../models/Store.dart";

// Get list of Stores from Server
class StoreRepository {
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

      stores = resStores.map<Store>((data) => Store.fromJSON(data)).toList();
      return stores;
    }
    return null;
  }

  static List<Store> getDummyList() {
    var days = new List(3);
    days.add("S");
    days.add("M");
    days.add("T");

    Store store1 = new Store(
        1,
        "Vijetha",
        "MyHome Vihanga, Gachibowli, Hyderabad",
        "Reg1",
        17.432400,
        78.331858,
        "9:00 am",
        "10:00 pm",
        days,
        true);

    Store store2 = new Store(
        1,
        "Vijetha",
        "MyHome Vihanga Gachibowli Hyderabad",
        "Reg1",
        17.435436,
        78.386707,
        "9:00 am",
        "10:00 pm",
        days,
        false);

    Store store3 = new Store(1, "IKEA", "MyHome Vihanga, Gachibowli, Hyderabad",
        "Reg1", 17.441903, 78.375869, "9:00 am", "10:00 pm", days, false);

    List<Store> st = new List(3);
    st.add(store1);
    st.add(store2);
    st.add(store3);

    return st;
  }
}
