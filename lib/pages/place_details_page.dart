import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../constants.dart';
import '../db/db_model/entity.dart';
import '../services/url_services.dart';
import '../style.dart';
import '../utils.dart';
import '../widget/widgets.dart';
import 'package:url_launcher/url_launcher.dart';

class PlaceDetailsPage extends StatefulWidget {
  final Entity? entity;
  PlaceDetailsPage({Key? key, required this.entity}) : super(key: key);
  @override
  _PlaceDetailsPageState createState() => _PlaceDetailsPageState();
}

class _PlaceDetailsPageState extends State<PlaceDetailsPage> {
  Entity? entity;
  final dtFormat = new DateFormat(dateDisplayFormat);
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
                      child: SingleChildScrollView(
                        child: Text(
                            entity!.description != null
                                ? entity!.description!
                                : "No Description found",
                            // overflow: TextOverflow.ellipsis,
                            maxLines: 4,
                            style: highlightSubTextStyle),
                      ),
                    ),
                  ])),
            ),
            // Card(
            //   child: Container(
            //       margin: EdgeInsets.all(10),
            //       height: MediaQuery.of(context).size.height * .08,
            //       width: MediaQuery.of(context).size.width,
            //       alignment: Alignment.center,
            //       child: Row(children: <Widget>[
            //         Text("Safety Practises we follow - ",
            //             style: placeDetailsHeadingTextStyle),
            //         horizontalSpacer,
            //         Image(
            //           image: AssetImage("assets/infoCustomer.png"),
            //         ),
            //       ])),
            // ),
            Card(
                child: Container(
              margin: EdgeInsets.all(10),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                          child: Row(children: <Widget>[
                        Text('Address - ', style: placeDetailsHeadingTextStyle),
                        Expanded(
                          child: Text(Utils.getFormattedAddress(entity!.address!),
                              maxLines: 4,
                              overflow: TextOverflow.ellipsis,
                              style: highlightSubTextStyle),
                        ),
                      ])),
                    ],
                  ),
                  SizedBox(
                    height: 5,
                  ),
                  Row(children: <Widget>[
                    Text("Opens at - ", style: placeDetailsHeadingTextStyle),
                    Text(
                        Utils.formatTime(entity!.startTimeHour.toString()) +
                            ':' +
                            Utils.formatTime(entity!.startTimeMinute.toString()),
                        style: highlightSubTextStyle),
                    horizontalSpacer,
                    horizontalSpacer,
                    Text("Closes at - ", style: placeDetailsHeadingTextStyle),
                    Text(
                        Utils.formatTime(entity!.endTimeHour.toString()) +
                            ':' +
                            Utils.formatTime(entity!.endTimeMinute.toString()),
                        style: highlightSubTextStyle),
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
                      Row(
                        children: [
                          Text('Offers - ',
                              style: placeDetailsHeadingTextStyle),
                          entity!.offer != null
                              ? Expanded(
                                  child: Text(
                                    entity!.offer!.message!,
                                    maxLines: 4,
                                    overflow: TextOverflow.ellipsis,
                                    style: highlightSubTextStyle,
                                  ),
                                )
                              : Text(placeDetailNoOffers,
                                  style: highlightSubTextStyle),
                        ],
                      ),
                      if (entity!.offer != null)
                        Row(
                            // mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              verticalSpacer,
                              Text("Valid from - ",
                                  style: placeDetailsHeadingTextStyle),
                              Text(dtFormat.format(entity!.offer!.startDateTime!),
                                  style: highlightSubTextStyle),
                              Text(" till ", style: highlightSubTextStyle),
                              Text(dtFormat.format(entity!.offer!.endDateTime!),
                                  style: highlightSubTextStyle),
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
                      Text("Contact -", style: placeDetailsHeadingTextStyle),
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
                              if (entity!.phone != null) {
                                try {
                                  callPhone(entity!.phone);
                                } catch (error) {
                                  Utils.showMyFlushbar(
                                      context,
                                      Icons.error,
                                      Duration(seconds: 5),
                                      "Could not connect call to the number ${entity!.phone} !!",
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
                            if (Utils.isNotNullOrEmpty(entity!.whatsapp)) {
                              try {
                                launchWhatsApp(
                                    message: "", phone: entity!.whatsapp);
                              } catch (error) {
                                Utils.showMyFlushbar(
                                    context,
                                    Icons.error,
                                    Duration(seconds: 5),
                                    "Could not connect to the WhatsApp number ${entity!.whatsapp} !!",
                                    "Try again later");
                              }
                            } else {
                              Utils.showMyFlushbar(
                                  context,
                                  Icons.info,
                                  Duration(seconds: 5),
                                  "WhatsApp contact information not found!!",
                                  "");
                            }
                          },
                        ),
                      ),
                      horizontalSpacer,
                      Container(
                        width: MediaQuery.of(context).size.width * .08,
                        height: MediaQuery.of(context).size.width * .07,
                        child: IconButton(
                            padding: EdgeInsets.all(0),
                            alignment: Alignment.center,
                            highlightColor: Colors.orange[300],
                            icon: Icon(
                              Icons.mail,
                              color: Colors.black,
                              size: 20,
                            ),
                            onPressed: () {
                              if (entity!.supportEmail != null) {
                                String _subjectOfMail =
                                    'Mail from LESSs app user';
                                String _mailBody = 'Your Message here..';
                                try {
                                  launchMail(entity!.supportEmail,
                                          _subjectOfMail, _mailBody)
                                      .then((retVal) {
                                    if (retVal) {
                                      Utils.showMyFlushbar(
                                          context,
                                          Icons.check,
                                          Duration(seconds: 5),
                                          "Your message has been sent.",
                                          "Our team will contact you as soon as possible.",
                                          successGreenSnackBar);
                                    } else {
                                      Utils.showMyFlushbar(
                                          context,
                                          Icons.info,
                                          Duration(seconds: 3),
                                          "Seems to be some problem with internet connection, Please check and try again.",
                                          "");
                                    }
                                  });
                                } catch (error) {
                                  Utils.showMyFlushbar(
                                      context,
                                      Icons.error,
                                      Duration(seconds: 5),
                                      "Could not connect to ${entity!.supportEmail} !!",
                                      "Try again later.");
                                }
                              } else {
                                Utils.showMyFlushbar(
                                    context,
                                    Icons.info,
                                    Duration(seconds: 5),
                                    "No Email address found!!",
                                    "");
                              }
                            }),
                      ),
                    ],
                  )),
            ),
          ],
        ));
  }
}
