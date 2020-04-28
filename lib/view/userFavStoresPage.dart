import 'package:flutter/material.dart';
import 'package:noq/dashboard.dart';
import 'package:noq/models/localDB.dart';
import 'package:noq/pages/slotsDialog.dart';
import 'package:noq/repository/StoreRepository.dart';
import 'package:noq/repository/local_db_repository.dart';
import 'package:noq/services/mapService.dart';
import 'package:noq/style.dart';
import 'package:noq/models/store.dart';
import 'package:noq/services/color.dart';
import 'package:noq/view/showSlotsPage.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserFavStoresListPage extends StatefulWidget {
  @override
  _UserFavStoresListPageState createState() => _UserFavStoresListPageState();
}

class _UserFavStoresListPageState extends State<UserFavStoresListPage> {
  int i;
  List<StoreAppData> _stores;
  String _favStoreStatus;
  UserAppData fUserProfile;
  bool isFavourited = true;
  DateTime dateTime;

  @override
  void initState() {
    super.initState();
    _loadFavStores();
  }

  void toggleFavorite(StoreAppData strData) {
    setState(() {
      isFavourited = !isFavourited;
      // if (strData.isFavourite == false)
      //   _stores.removeWhere((item) => item.id == strData.id);
      //widget.onFavoriteChanged(isFavourited);
    });
    modifyStoreList(strData);
  }

  void modifyStoreList(StoreAppData strData) {}
  void _loadFavStores() async {
    //Load details from local files
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int userId = prefs.getInt('userId');
    //Fetch details from server

    await readData().then((fUser) {
      fUserProfile = fUser;
      if (fUserProfile.favStores.length != 0) {
        setState(() {
          _favStoreStatus = 'Success';

          _stores = fUserProfile.favStores;
        });
      } else {
        setState(() {
          _favStoreStatus = 'NoFavStore';
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_favStoreStatus != 'Success') {
      return _emptyFavStorePage();
    } else {
      return _buildFavStoresListPage();
    }
  }

  void showSlots(int storeId) {
    showSlotsDialog(context, storeId, dateTime);
  }

  Widget _emptyFavStorePage() {
    return Center(
        child: Center(
            child: Container(
      margin: EdgeInsets.fromLTRB(10, 10, 10, 10),
      child: Text('No favourite stores yet!!'),
    )));
  }

  Widget _buildFavStoresListPage() {
    return Center(
      child: Container(
        margin: EdgeInsets.fromLTRB(10, 10, 10, 10),
        child: ListView.builder(
            itemCount: _stores.length,
            itemBuilder: (BuildContext context, int index) {
              return Container(
                child: new Column(children: _stores.map(_buildItem).toList()),
                //children: <Widget>[firstRow, secondRow],
              );
            }),
      ),
    );
  }

  Widget _buildItem(StoreAppData str) {
    return Card(
        elevation: 10,
        child: new Row(
          children: <Widget>[
            Column(
              children: <Widget>[
                new Container(
                  margin: EdgeInsets.fromLTRB(10, 10, 5, 5),
                  padding: EdgeInsets.all(5),
                  alignment: Alignment.center,
                  decoration: ShapeDecoration(
                    shape: CircleBorder(),
                    color: darkIcon,
                  ),
                  child: Icon(
                    Icons.shopping_cart,
                    color: Colors.white,
                    size: 20,
                  ),
                )
              ],
            ),
            Column(children: <Widget>[
              Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    new Container(
                      padding: EdgeInsets.fromLTRB(10.0, 5.0, 0, 0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Container(
                            padding: EdgeInsets.fromLTRB(0, 5, 5, 5),
                            child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    // crossAxisAlignment: CrossAxisAlignment.center,
                                    children: <Widget>[
                                      Text(
                                        str.name.toString(),
                                      ),
                                    ],
                                  ),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: <Widget>[
                                      Text(
                                        str.adrs,
                                      ),
                                    ],
                                  )
                                ]),
                          ),
                          Row(
                            children: <Widget>[
                              Text('Stores opens on days: ',
                                  style: lightSubTextStyle),
                              DefaultTextStyle.merge(
                                child: Container(
                                    child: Row(children: [
                                  Icon(Icons.remove_circle,
                                      size: 18.0, color: Colors.blueGrey[300]),
                                  Icon(Icons.add_circle,
                                      size: 18.0, color: Colors.orange),
                                  Icon(Icons.remove_circle,
                                      size: 18.0, color: Colors.blueGrey[300]),
                                  Icon(Icons.remove_circle,
                                      size: 18.0, color: Colors.blueGrey[300]),
                                  Icon(Icons.remove_circle,
                                      size: 18.0, color: Colors.blueGrey[300]),
                                ])),
                              ),
                            ],
                          ),
                          Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  //mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                  children: [
                                    //Icon(Icons.play_circle_filled, color: Colors.blueGrey[300]),
                                    Text('Opens at:', style: labelTextStyle),
                                    Text(str.opensAt, style: lightSubTextStyle),
                                  ],
                                ),
                                Container(child: Text('   ')),
                                Row(
                                  children: [
                                    //Icon(Icons.pause_circle_filled, color: Colors.blueGrey[300]),
                                    Text('Closes at:', style: labelTextStyle),
                                    Text(str.closesAt,
                                        style: lightSubTextStyle),
                                  ],
                                ),
                              ]),
                        ],
                      ),
                    ),
                  ]),
            ]),
            Column(children: <Widget>[
              Container(
                height: 22,
                width: 20,
                // margin: EdgeInsets.fromLTRB(10, 10, 5, 5),
                // alignment: Alignment.topRight,
                // decoration: ShapeDecoration(
                //   shape: RoundedRectangleBorder(
                //       borderRadius: BorderRadius.all(Radius.circular(6)),
                //       side: BorderSide.none),
                //   color: Theme.of(context).primaryColor,
                // ),
                child: IconButton(
                  alignment: Alignment.topRight,
                  //padding: EdgeInsets.all(2),
                  onPressed: () => toggleFavorite(str),
                  highlightColor: Colors.orange[300],
                  iconSize: 16,
                  icon: isFavourited
                      ? Icon(
                          Icons.star,
                          color: darkIcon,
                        )
                      : Icon(
                          Icons.star_border,
                          color: darkIcon,
                        ),
                ),
              ),
              Container(
                //margin: EdgeInsets.fromLTRB(20, 10, 5, 5),

                height: 22.0,
                width: 20.0,
                //alignment: Alignment.center,
                // decoration: ShapeDecoration(
                //   shape: RoundedRectangleBorder(
                //       borderRadius: BorderRadius.all(Radius.circular(4)),
                //       side: BorderSide.none),
                //   color: Theme.of(context).primaryColor,
                // ),
                child: IconButton(
                  // padding: EdgeInsets.all(2),
                  //iconSize: 14,
                  alignment: Alignment.centerRight,
                  highlightColor: Colors.orange[300],
                  icon: Icon(
                    Icons.location_on,
                    color: darkIcon,
                    size: 20,
                  ),
                  onPressed: () =>
                      launchURL(str.name, str.adrs, str.lat, str.long),
                ),
              ),
              Container(
                width: 20.0,
                height: 22.0,
                // alignment: Alignment.center,
                // decoration: ShapeDecoration(
                //   shape: RoundedRectangleBorder(
                //       borderRadius: BorderRadius.all(Radius.circular(2)),
                //       side: BorderSide.none),
                //   color: Theme.of(context).primaryColor,
                // ),
                child: IconButton(
                    alignment: Alignment.bottomCenter,
                    padding: EdgeInsets.all(2),
                    iconSize: 25,
                    highlightColor: highlightColor,
                    icon: Icon(
                      Icons.arrow_forward,
                      color: darkIcon,
                    ),
                    onPressed: () => showSlots(str.id)),
              )
            ]),
          ],
        ));
  }

// class FavoritesStores {
//   List favorites = [];

//   void addFavorite(StoreAppData store) {
//     favorites.add(store);
//   }

//   void removeFavorite(StoreAppData store) {
//     favorites.remove(store);
//   }

//   bool isFavorite(StoreAppData store) {
//     return favorites.contains(store);
//   }
}
