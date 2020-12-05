import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:noq/db/db_model/entity.dart';
import 'package:noq/services/url_services.dart';
import 'package:noq/style.dart';
import 'package:noq/utils.dart';
import 'package:noq/widget/widgets.dart';
import 'package:url_launcher/url_launcher.dart';

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
        //  color: Colors.blue,
        padding: EdgeInsets.all(10),
        height: MediaQuery.of(context).size.height * .7,
        width: MediaQuery.of(context).size.width,
        child: Column(
          children: [
            Card(
              child: Container(
                  margin: EdgeInsets.all(10),
                  height: MediaQuery.of(context).size.height * .08,
                  width: MediaQuery.of(context).size.width,
                  alignment: Alignment.center,
                  child: Row(children: <Widget>[
                    Text(
                      "About - ",
                      style: highlightSubTextStyle,
                    ),
                    Text(
                        entity.description != null
                            ? entity.description
                            : "No Description found",
                        style: highlightSubTextStyle),
                  ])),
            ),
            Card(
              child: Container(
                  margin: EdgeInsets.all(10),
                  height: MediaQuery.of(context).size.height * .08,
                  width: MediaQuery.of(context).size.width,
                  alignment: Alignment.center,
                  child: Row(children: <Widget>[
                    Text("Safety Practises we follow - ",
                        style: highlightSubTextStyle),
                    horizontalSpacer,
                    Image(
                      image: AssetImage("assets/infoCustomer.png"),
                    ),
                  ])),
            ),
            Card(
                child: Container(
              margin: EdgeInsets.all(10),
              child: Row(children: <Widget>[
                Text("Opens at -", style: highlightSubTextStyle),
                Text(
                    Utils.formatTime(entity.startTimeHour.toString()) +
                        ':' +
                        Utils.formatTime(entity.startTimeMinute.toString()),
                    style: highlightSubTextStyle),
                horizontalSpacer,
                horizontalSpacer,
                Text("Closes at -", style: highlightSubTextStyle),
                Text(
                    Utils.formatTime(entity.endTimeHour.toString()) +
                        ':' +
                        Utils.formatTime(entity.endTimeMinute.toString()),
                    style: highlightSubTextStyle),
              ]),
            )),
            Card(
              child: Container(
                  margin: EdgeInsets.all(10),
                  height: MediaQuery.of(context).size.height * .08,
                  width: MediaQuery.of(context).size.width,
                  alignment: Alignment.center,
                  child: Column(
                    children: [
                      RichText(
                          text: TextSpan(
                              style: highlightSubTextStyle,
                              children: <TextSpan>[
                            TextSpan(text: 'Offers / Sales / Discounts - '),
                            TextSpan(
                              text: entity.offer.message,
                              style: new TextStyle(color: highlightColor),
                              recognizer: new TapGestureRecognizer()
                                ..onTap = () {
                                  //TODO: Smita- add payments options google pay  etc
                                  launch('https://google.com');
                                },
                            ),
                          ])),
                      Row(children: <Widget>[
                        Text("Starts at -", style: highlightSubTextStyle),
                        Text(
                            Utils.formatTime(entity.startTimeHour.toString()) +
                                ':' +
                                Utils.formatTime(
                                    entity.startTimeMinute.toString()),
                            style: highlightSubTextStyle),
                        horizontalSpacer,
                        horizontalSpacer,
                        Text("Ends at -", style: highlightSubTextStyle),
                        Text(
                            Utils.formatTime(entity.endTimeHour.toString()) +
                                ':' +
                                Utils.formatTime(
                                    entity.endTimeMinute.toString()),
                            style: highlightSubTextStyle),
                      ]),
                    ],
                  )),
            ),
            Card(
              child: Container(
                  margin: EdgeInsets.all(10),
                  height: MediaQuery.of(context).size.height * .08,
                  width: MediaQuery.of(context).size.width,
                  alignment: Alignment.center,
                  child: Row(
                    children: [
                      Text("Contact @", style: highlightSubTextStyle),
                      Container(
                        width: MediaQuery.of(context).size.width * .08,
                        height: MediaQuery.of(context).size.width * .07,
                        child: IconButton(
                            padding: EdgeInsets.all(0),
                            alignment: Alignment.center,
                            highlightColor: Colors.orange[300],
                            icon: Icon(
                              Icons.phone,
                              color: Colors.black,
                              size: 20,
                            ),
                            onPressed: () {
                              if (entity.phone != null) {
                                try {
                                  callPhone(entity.phone);
                                } catch (error) {
                                  Utils.showMyFlushbar(
                                      context,
                                      Icons.error,
                                      Duration(seconds: 5),
                                      "Could not connect call to the number ${entity.phone} !!",
                                      "Try again later.");
                                }
                              } else {
                                Utils.showMyFlushbar(
                                    context,
                                    Icons.info,
                                    Duration(seconds: 5),
                                    "Contact information not found!!",
                                    "");
                              }
                            }),
                      ),
                      Container(
                        width: MediaQuery.of(context).size.width * .08,
                        height: MediaQuery.of(context).size.width * .07,
                        child: IconButton(
                          padding: EdgeInsets.all(0),
                          alignment: Alignment.center,
                          highlightColor: Colors.orange[300],
                          icon: ImageIcon(
                            AssetImage('assets/whatsapp.png'),
                            size: 20,
                            color: Colors.black,
                          ),
                          onPressed: () {
                            if (Utils.isNotNullOrEmpty(entity.whatsapp)) {
                              try {
                                launchWhatsApp(
                                    message: "", phone: entity.whatsapp);
                              } catch (error) {
                                Utils.showMyFlushbar(
                                    context,
                                    Icons.error,
                                    Duration(seconds: 5),
                                    "Could not connect to the Whatsapp number ${entity.whatsapp} !!",
                                    "Try again later");
                              }
                            } else {
                              Utils.showMyFlushbar(
                                  context,
                                  Icons.info,
                                  Duration(seconds: 5),
                                  "Whatsapp contact information not found!!",
                                  "");
                            }
                          },
                        ),
                      ),
                    ],
                  )),
            ),
          ],
        ));
  }
}
