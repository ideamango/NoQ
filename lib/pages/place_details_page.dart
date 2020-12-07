import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:noq/constants.dart';
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
    return SingleChildScrollView(
        //  color: Colors.blue,
        padding: EdgeInsets.all(10),
        // height: MediaQuery.of(context).size.height * .7,
        // width: MediaQuery.of(context).size.width,
        child: Column(
          children: [
            Card(
              child: Container(
                  margin: EdgeInsets.all(10),
                  // height: MediaQuery.of(context).size.height * .08,
                  width: MediaQuery.of(context).size.width,
                  alignment: Alignment.center,
                  child: Row(children: <Widget>[
                    Text(
                      "About - ",
                      style: placeDetailsHeadingTextStyle,
                    ),
                    Expanded(
                      child: Text(
                          entity.description != null
                              ? entity.description
                              : "No Description found",
                          overflow: TextOverflow.visible,
                          //maxLines: 4,
                          style: highlightSubTextStyle),
                    ),
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
                        style: placeDetailsHeadingTextStyle),
                    horizontalSpacer,
                    Image(
                      image: AssetImage("assets/infoCustomer.png"),
                    ),
                  ])),
            ),
            Card(
                child: Container(
              margin: EdgeInsets.all(10),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: RichText(
                            text: TextSpan(
                                style: highlightSubTextStyle,
                                children: <TextSpan>[
                              TextSpan(
                                  text: 'Address - ',
                                  style: placeDetailsHeadingTextStyle),
                              TextSpan(
                                  text:
                                      Utils.getFormattedAddress(entity.address),
                                  style: labelSmlTextStyle),
                            ])),
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
                  ),
                  Row(children: <Widget>[
                    Text("Opens at - ", style: placeDetailsHeadingTextStyle),
                    Text(
                        Utils.formatTime(entity.startTimeHour.toString()) +
                            ':' +
                            Utils.formatTime(entity.startTimeMinute.toString()),
                        style: labelSmlTextStyle),
                    horizontalSpacer,
                    horizontalSpacer,
                    Text("Closes at - ", style: placeDetailsHeadingTextStyle),
                    Text(
                        Utils.formatTime(entity.endTimeHour.toString()) +
                            ':' +
                            Utils.formatTime(entity.endTimeMinute.toString()),
                        style: labelSmlTextStyle),
                  ]),
                ],
              ),
            )),
            Card(
              child: Container(
                  margin: EdgeInsets.all(10),
                  //   height: MediaQuery.of(context).size.height * .08,
                  width: MediaQuery.of(context).size.width,
                  alignment: Alignment.center,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      RichText(
                          text: TextSpan(
                              style: highlightSubTextStyle,
                              children: <TextSpan>[
                            TextSpan(
                                text: 'Offers - ',
                                style: placeDetailsHeadingTextStyle),
                            entity.offer != null
                                ? TextSpan(
                                    text: entity.offer.message,
                                    style: linkTextStyle,
                                    recognizer: new TapGestureRecognizer()
                                      ..onTap = () {
                                        //TODO: Smita- add payments options google pay  etc
                                        launch('https://google.com');
                                      },
                                  )
                                : TextSpan(text: placeDetailNoOffers),
                          ])),
                      verticalSpacer,
                      verticalSpacer,
                      Row(
                          // mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Text("Valid from ", style: placeDetailsHeadingSml),
                            Text(
                                Utils.formatTime(
                                        entity.startTimeHour.toString()) +
                                    ':' +
                                    Utils.formatTime(
                                        entity.startTimeMinute.toString()),
                                style: placeDetailsHeadingSml),
                            Text(" till ", style: placeDetailsHeadingSml),
                            Text(
                                Utils.formatTime(
                                        entity.endTimeHour.toString()) +
                                    ':' +
                                    Utils.formatTime(
                                        entity.endTimeMinute.toString()),
                                style: placeDetailsHeadingSml),
                          ]),
                    ],
                  )),
            ),
            Card(
              child: Container(
                  margin: EdgeInsets.all(10),
                  //  height: MediaQuery.of(context).size.height * .08,
                  width: MediaQuery.of(context).size.width,
                  alignment: Alignment.center,
                  child: Row(
                    children: [
                      Text("Contact @", style: placeDetailsHeadingTextStyle),
                      horizontalSpacer,
                      horizontalSpacer,
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
                      horizontalSpacer,
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
