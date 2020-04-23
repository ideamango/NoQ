import 'package:flutter/material.dart';
import 'package:noq/repository/StoreRepository.dart';
import 'package:noq/style.dart';
import 'package:noq/models/Store.dart';
import 'package:noq/services/color.dart';

class UserFavStoresListPage extends StatelessWidget {
  int i;
  List<Store> _stores = getUserFavStores();
  @override
  Widget build(BuildContext context) {
    return _buildFavStoresListPage();
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

  Widget _buildItem(Store str) {
    return Card(
        elevation: 10,
        child: new Column(children: <Widget>[
          Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                new Container(
                  margin: EdgeInsets.fromLTRB(10, 10, 5, 5),
                  padding: EdgeInsets.all(5),
                  alignment: Alignment.center,
                  decoration: ShapeDecoration(
                      shape: CircleBorder(), color: Colors.indigo
                      //createMaterialColor(Color(0xFF174378)),
                      ),
                  child: Icon(
                    Icons.shopping_cart,
                    color: Colors.white,
                    size: 15,
                  ),
                ),
                new Container(
                  padding: EdgeInsets.fromLTRB(10.0, 5.0, 0, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Container(
                        padding: EdgeInsets.fromLTRB(0, 5, 5, 5),
                        child:
                            Column(crossAxisAlignment: CrossAxisAlignment.start,
                                // mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                              Text(
                                str.name.toString(),
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Text(
                                    str.adrs,
                                  ),
                                  Container(
                                    width: 20.0,
                                    height: 20.0,
                                    child: IconButton(
                                      alignment: Alignment.center,
                                      padding: EdgeInsets.all(0),
                                      onPressed: () => {
                                        // launchURL(str.name, str.adrs, str.lat,
                                        //     str.long),
                                      },
                                      highlightColor: Colors.orange[300],
                                      icon: Icon(
                                        Icons.location_on,
                                        color: Colors.blueGrey,
                                      ),
                                    ),
                                  ),
                                ],
                              )
                            ]),
                      ),
                      DefaultTextStyle.merge(
                        child: Container(
                            child: Row(children: [
                          Icon(Icons.remove_circle,
                              color: Colors.blueGrey[300]),
                          Icon(Icons.add_circle, color: Colors.orange),
                          Icon(Icons.remove_circle,
                              color: Colors.blueGrey[300]),
                          Icon(Icons.remove_circle,
                              color: Colors.blueGrey[300]),
                          Icon(Icons.remove_circle,
                              color: Colors.blueGrey[300]),
                        ])),
                      ),
                    ],
                  ),
                ),
              ]),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Row(
                children: <Widget>[],
              ),
              Row(
                //mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  //Icon(Icons.play_circle_filled, color: Colors.blueGrey[300]),
                  Text('Opens at:', style: labelTextStyle),
                  Text(str.opensAt, style: lightSubTextStyle),
                ],
              ),
              Row(
                children: [
                  //Icon(Icons.pause_circle_filled, color: Colors.blueGrey[300]),
                  Text('Closes at:', style: labelTextStyle),
                  Text(str.closesAt, style: lightSubTextStyle),
                ],
              ),
              Row(
                children: <Widget>[
                  new Container(
                    width: 40.0,
                    height: 20.0,
                    child: MaterialButton(
                      color: Colors.orange,
                      child: Text(
                        "Book Slot",
                        style: new TextStyle(
                            fontFamily: 'Montserrat',
                            letterSpacing: 0.5,
                            color: Colors.white,
                            fontSize: 10),
                      ),
                      onPressed: () => {
                        //onPressed_bookSlotBtn();
                      },
                      highlightColor: Colors.orange[300],
                    ),
                  )
                ],
              ),
            ],
          )
        ]));
  }
}
