import 'package:flutter/material.dart';
import 'package:noq/db/db_model/entity.dart';

class PlaceDetailsPage extends StatefulWidget {
  final Entity entity;
  PlaceDetailsPage({Key key, @required this.entity}) : super(key: key);
  @override
  _PlaceDetailsPageState createState() => _PlaceDetailsPageState();
}

class _PlaceDetailsPageState extends State<PlaceDetailsPage> {
  Entity entity;
  @override
  Widget build(BuildContext context) {
    entity = widget.entity;
    return Container(
        color: Colors.blue,
        padding: EdgeInsets.all(10),
        height: MediaQuery.of(context).size.height * .7,
        width: MediaQuery.of(context).size.width,
        child: Column(
          children: [
            Card(
              child: Container(
                  height: MediaQuery.of(context).size.height * .08,
                  width: MediaQuery.of(context).size.width,
                  alignment: Alignment.center,
                  child: (Text("Description"))),
            ),
            Card(
              child: Container(
                  height: MediaQuery.of(context).size.height * .08,
                  width: MediaQuery.of(context).size.width,
                  alignment: Alignment.center,
                  child: (Text("Safety Practises we follow"))),
            ),
            Card(
              child: Container(
                  height: MediaQuery.of(context).size.height * .08,
                  width: MediaQuery.of(context).size.width,
                  alignment: Alignment.center,
                  child: (Text("Timings , Map"))),
            ),
            Card(
              child: Container(
                  height: MediaQuery.of(context).size.height * .08,
                  width: MediaQuery.of(context).size.width,
                  alignment: Alignment.center,
                  child: (Text("Offers"))),
            ),
            Card(
              child: Container(
                  height: MediaQuery.of(context).size.height * .08,
                  width: MediaQuery.of(context).size.width,
                  alignment: Alignment.center,
                  child: (Text("Contact details"))),
            ),
          ],
        ));
  }
}
