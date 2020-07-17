import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:noq/constants.dart';
import 'package:noq/pages/manage_apartment_list_page.dart';
import 'package:noq/style.dart';
import 'package:noq/widget/appbar.dart';
import 'package:noq/widget/bottom_nav_bar.dart';
import 'package:noq/widget/header.dart';
import 'package:noq/widget/widgets.dart';
import 'package:url_launcher/url_launcher.dart';

class HelpPage extends StatefulWidget {
  @override
  _HelpPageState createState() => _HelpPageState();
}

class _HelpPageState extends State<HelpPage> {
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    String title = "Help";
    return MaterialApp(
      theme: ThemeData.light().copyWith(),
      home: Scaffold(
        drawer: CustomDrawer(),
        appBar: CustomAppBar(
          titleTxt: title,
        ),
        body: Container(
            margin: EdgeInsets.all(6),
            color: Colors.white,
            child: ListView(children: <Widget>[
              Column(
                //mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Card(
                      color: btnColor,
                      elevation: 20,
                      child: Padding(
                        padding: EdgeInsets.all(0),
                        child: Column(
                          children: <Widget>[
                            Container(
                                height: MediaQuery.of(context).size.width * .08,
                                width: MediaQuery.of(context).size.width,
                                padding: EdgeInsets.fromLTRB(6, 0, 0, 0),
                                decoration: btnColorContainer,
                                alignment: Alignment.center,
                                child: Text(
                                  "FAQ's",
                                  style: whiteBoldTextStyle1,
                                )),
                            Container(
                              child: myLightDivider,
                              color: btnColor,
                            ),
                            verticalSpacer,
                            Container(
                              padding: EdgeInsets.fromLTRB(6, 0, 0, 0),
                              decoration: rectLightContainer,
                              child: RichText(
                                  text: TextSpan(
                                      style: lightTextStyle,
                                      children: <TextSpan>[
                                    TextSpan(
                                        text:
                                            'Kindly check the FAQs below if you are using '),
                                    TextSpan(
                                        text:
                                            'this app for first time and have any queries regarding the working of this app. '),
                                    TextSpan(
                                        text:
                                            'If you have any query which is not covered in FAQs, you can drop a message to us at ...@mail.com. We will try our best to address that at earliest.'),
                                  ])),
                            ),
                            verticalSpacer
                          ],
                        ),
                      )),
                  Card(
                    elevation: 20,
                    shadowColor: highlightColor,
                    child: Container(
                      alignment: Alignment.center,
                      width: MediaQuery.of(context).size.width,
                      child: RichText(
                        text: TextSpan(
                          style: highlightMedBoldTextStyle,
                          children: <TextSpan>[
                            TextSpan(text: 'Avoid Rush '),
                            TextSpan(
                                text: '| Be Safe |',
                                style: highlightBoldTextStyle),
                            TextSpan(
                              text: '  Save Time.',
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Card(
                      elevation: 20,
                      child: Container(
                        // padding: EdgeInsets.all(8),
                        child: Column(
                          children: <Widget>[
                            Container(
                                height: MediaQuery.of(context).size.width * .08,
                                width: MediaQuery.of(context).size.width,
                                padding: EdgeInsets.fromLTRB(6, 0, 0, 0),
                                decoration: btnColorContainer,
                                child: Text(
                                  "Why should I use this app?",
                                  style: whiteBoldTextStyle1,
                                )),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Text('Lets look at the problems first..',
                                      style: textLabelTextStyle),
                                  verticalSpacer,
                                  RichText(
                                      text: TextSpan(
                                          style: highlightSubTextStyle,
                                          children: <TextSpan>[
                                        TextSpan(
                                            text:
                                                'There is not just one, but numerous reasons how this helps you. Here is how - '),
                                        TextSpan(
                                            text:
                                                'Maintaing social distance is need of the hour. Sometimes just unavoidable when you visit your '),
                                        TextSpan(
                                            text:
                                                'favourite grocery store for example, you see people standing in queue and wait-time could be anything from 10 mins to an hour.'),
                                        TextSpan(
                                            text:
                                                'Another problem is, Shopping at place this crowded is not at all advisable.'),
                                        TextSpan(
                                            text:
                                                'So, Not just you waste your precious time in waiting but also expose yourself to virus(Covid-19).'),
                                      ])),
                                  verticalSpacer,
                                  myDivider,
                                  verticalSpacer,
                                  Text('How this app helps me?',
                                      style: textLabelTextStyle),
                                  verticalSpacer,
                                  RichText(
                                      text: TextSpan(
                                          style: highlightSubTextStyle,
                                          children: <TextSpan>[
                                        TextSpan(
                                            text:
                                                'The idea to is plan your visits well ahead so that shopping doesnt become unsafe for you.'),
                                        TextSpan(
                                            text:
                                                'Now, How do we do this. We lists different premises like Shopping Marts, Gaming Zones, Offices, Apartments, Medical Stores etc'),
                                        TextSpan(
                                            text:
                                                ' where you might visit frequently. Dates and available time slots will be shown, you can select time and date as per your convenience.  '),
                                        TextSpan(
                                            text:
                                                ' So, Now when you visit at your pre-booked time, you dont have to wait and second as limited people would be allowed in a given time slot, it '),
                                        TextSpan(
                                            text:
                                                ' much easier to maintain distance and be safe.'),
                                      ])),
                                  verticalSpacer,
                                ],
                              ),
                            ),
                          ],
                        ),
                      )),
                  Card(
                      elevation: 20,
                      child: Container(
                        // padding: EdgeInsets.all(8),
                        child: Column(
                          children: <Widget>[
                            Container(
                                height: MediaQuery.of(context).size.width * .08,
                                width: MediaQuery.of(context).size.width,
                                padding: EdgeInsets.fromLTRB(6, 0, 0, 0),
                                decoration: btnColorContainer,
                                child: Text(
                                  "Registration",
                                  style: whiteBoldTextStyle1,
                                )),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Text('How do I register?',
                                      style: textLabelTextStyle),
                                  verticalSpacer,
                                  RichText(
                                      text: TextSpan(
                                          style: highlightSubTextStyle,
                                          children: <TextSpan>[
                                        TextSpan(
                                            text:
                                                'Registering with us is very simple and safe. We just ask for your phone number and '),
                                        TextSpan(
                                            text:
                                                'NO other details will be asked. After providing your number, you will recieve an OTP on your '),
                                        TextSpan(
                                            text:
                                                'phone number, just enter that and Done!!'),
                                      ])),
                                  verticalSpacer,
                                  myDivider,
                                  verticalSpacer,
                                  Text('Would I be charged?',
                                      style: textLabelTextStyle),
                                  verticalSpacer,
                                  RichText(
                                      text: TextSpan(
                                          style: highlightSubTextStyle,
                                          children: <TextSpan>[
                                        TextSpan(
                                            text:
                                                'There is absolutely no charge for registration or for using this app. '),
                                        TextSpan(
                                            text:
                                                'However, If you like our work, you can always donate any amount as per your wish to keep us motivated. '),
                                        TextSpan(
                                          text: 'Click here to donate!!',
                                          style: new TextStyle(
                                              color: highlightColor),
                                          recognizer: new TapGestureRecognizer()
                                            ..onTap = () {
                                              //TODO: Smita- add payments options google pay  etc
                                              launch(
                                                  'https://docs.flutter.io/flutter/services/UrlLauncher-class.html');
                                            },
                                        ),
                                      ])),
                                  verticalSpacer,
                                  myDivider,
                                  verticalSpacer,
                                  Text(
                                      'Can I have multiple accounts with same phone number?',
                                      style: textLabelTextStyle),
                                  verticalSpacer,
                                  RichText(
                                      text: TextSpan(
                                          style: highlightSubTextStyle,
                                          children: <TextSpan>[
                                        TextSpan(
                                            text:
                                                'Each phone number can be associated with one account only. '),
                                      ])),
                                  verticalSpacer
                                ],
                              ),
                            ),
                          ],
                        ),
                      )),
                  Card(
                      elevation: 20,
                      child: Container(
                        // padding: EdgeInsets.all(8),
                        child: Column(
                          children: <Widget>[
                            Container(
                                height: MediaQuery.of(context).size.width * .08,
                                width: MediaQuery.of(context).size.width,
                                padding: EdgeInsets.fromLTRB(6, 0, 0, 0),
                                decoration: btnColorContainer,
                                child: Text(
                                  "How does it work?",
                                  style: whiteBoldTextStyle1,
                                )),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Text('Which all places can we book a slot?',
                                      style: textLabelTextStyle),
                                  verticalSpacer,
                                  RichText(
                                      text: TextSpan(
                                          style: highlightSubTextStyle,
                                          children: <TextSpan>[
                                        TextSpan(
                                            text:
                                                'We have listed few places where we felt pre-planning and booking time-slot would be help. But owner of any place where crowd '),
                                        TextSpan(
                                            text:
                                                'is expected and pre-panning would be of help, would definitely can be added here for benefit of all. '),
                                        TextSpan(
                                            text:
                                                'Few Examples of Places are Shopping Marts, Gaming Zones in Mall, Apartment amenities such as Lawn Tennis Court, Grocery Store, Gym, Local vegetable vendor etc.'),
                                      ])),
                                  verticalSpacer,
                                  myDivider,
                                  verticalSpacer,
                                  Text('How can we book ?',
                                      style: textLabelTextStyle),
                                  verticalSpacer,
                                  RichText(
                                      text: TextSpan(
                                          style: highlightSubTextStyle,
                                          children: <TextSpan>[
                                        TextSpan(
                                            text:
                                                'You can search for different places using \'Search\' feature. Futher, select date and time when you are planing to'),
                                        TextSpan(
                                            text:
                                                'visit that place. See how many people have booked that slot, in case, u decide to visit the place when less people are visiting '),
                                        TextSpan(
                                            text:
                                                'you can just so do it. Now, visit store conveniently at booked time and avoid all that rush!!'),
                                      ])),
                                  verticalSpacer,
                                  myDivider,
                                  verticalSpacer,
                                  Text('How can I list my business/store here?',
                                      style: textLabelTextStyle),
                                  verticalSpacer,
                                  RichText(
                                      text: TextSpan(
                                          style: highlightSubTextStyle,
                                          children: <TextSpan>[
                                        TextSpan(
                                            text:
                                                'Business can only be added by owner of that business. Using \'Managed Entities\' feature,'),
                                        TextSpan(
                                            text:
                                                ' you can add the business and all details like opening/closing time, people allowed during one slot to minimise crowd inside premises.'),
                                        TextSpan(
                                            text:
                                                'Fill all other important details. If your business has whatsapp contact, on-call contact person, please provide that too, that would help people to enquire.'),
                                        TextSpan(
                                          text:
                                              '\nClick here to register your business!!',
                                          style: new TextStyle(
                                              color: highlightColor),
                                          recognizer: new TapGestureRecognizer()
                                            ..onTap = () {
                                              //TODO: Smita- add payments options google pay  etc
                                              Navigator.pop(context);
                                              Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                      builder: (context) =>
                                                          ManageApartmentsListPage()));
                                            },
                                        ),
                                      ])),
                                  verticalSpacer,
                                  myDivider,
                                  verticalSpacer,
                                  Text(
                                      'Cannot find my favourite places here, what to do?',
                                      style: textLabelTextStyle),
                                  verticalSpacer,
                                  RichText(
                                      text: TextSpan(
                                          style: highlightSubTextStyle,
                                          children: <TextSpan>[
                                        TextSpan(
                                            text:
                                                'You can contact us and leave message about the same. We will try our best to get them onboard.'),
                                        TextSpan(
                                            text:
                                                'Our ultimate purpose is to help create safe environment for all.'),
                                      ])),
                                  verticalSpacer
                                ],
                              ),
                            ),
                          ],
                        ),
                      )),
                ],
              ),
            ])),
        bottomNavigationBar: CustomBottomBar(
          barIndex: 0,
        ),
      ),
    );
  }
}
