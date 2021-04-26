import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import '../constants.dart';
import '../global_state.dart';
import '../pages/contact_us.dart';
import '../pages/manage_entity_list_page.dart';
import '../style.dart';
import '../userHomePage.dart';
import '../widget/appbar.dart';
import '../widget/bottom_nav_bar.dart';
import '../widget/custom_expansion_tile.dart';
import '../widget/header.dart';
import '../widget/widgets.dart';
import 'package:url_launcher/url_launcher.dart';

class HelpPage extends StatefulWidget {
  final String phone;
  HelpPage({Key key, @required this.phone}) : super(key: key);
  @override
  _HelpPageState createState() => _HelpPageState();
}

class _HelpPageState extends State<HelpPage> {
  String _phone;
  @override
  void initState() {
    super.initState();
    _phone = widget.phone;
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    String title = "How can we help you?";
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.light().copyWith(),
      home: WillPopScope(
        child: Scaffold(
          drawer: CustomDrawer(
              //TODO provide phone number
              //phone: _state.currentUser.ph,
              phone: _phone),
          appBar: CustomAppBarWithBackButton(
            backRoute: UserHomePage(),
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
                      elevation: 20,
                      child: Container(
                          height: MediaQuery.of(context).size.height * .3,
                          child: Image.asset('assets/faq.png')),
                    ),
                    Card(
                        elevation: 20,
                        child: Padding(
                          padding: EdgeInsets.all(0),
                          child: Column(
                            children: <Widget>[
                              verticalSpacer,
                              Container(
                                padding: EdgeInsets.all(5),
                                //  decoration: rectLightContainer,
                                child: RichText(
                                    text: TextSpan(
                                        style: highlightSubTextStyle,
                                        children: <TextSpan>[
                                      TextSpan(
                                          text:
                                              'Below you will find all the help to use LESSs like a pro. Still if you didn\'t find the answer you are looking for, feel free to drop a message to us at '),
                                      TextSpan(
                                        text: 'care@bigpiq.com',
                                        style: TextStyle(color: Colors.blue),
                                        recognizer: new TapGestureRecognizer()
                                          ..onTap = () => Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                  builder: (context) =>
                                                      ContactUsPage(
                                                        showAppBar: true,
                                                      ))),
                                      ),
                                      // TextSpan(
                                      //     text:
                                      //         ' We will try our best to address that at earliest.'),
                                    ])),
                              ),
                              verticalSpacer
                            ],
                          ),
                        )),
                    // Container(
                    //   //padding: EdgeInsets.only(left: 5),
                    //   //decoration: darkContainer,
                    //   child: Theme(
                    //     data: ThemeData(
                    //       unselectedWidgetColor: Colors.white,
                    //       accentColor: Colors.grey[50],
                    //     ),
                    //     child: CustomExpansionTile(
                    //       //key: PageStorageKey(this.widget.headerTitle),
                    //       initiallyExpanded: true,

                    //       title: Row(
                    //         children: <Widget>[
                    //           Container(
                    //             height: MediaQuery.of(context).size.width * .1,
                    //             width: MediaQuery.of(context).size.width * .8,
                    //             child: Text(
                    //               "How Sukoon helps bring Sukoon to your life?",
                    //               softWrap: true,
                    //               style: TextStyle(
                    //                   color: primaryDarkColor, fontSize: 15),
                    //             ),
                    //           ),
                    //           SizedBox(width: 5),
                    //         ],
                    //       ),
                    //       // backgroundColor: Colors.blueGrey[500],

                    //       children: <Widget>[
                    //         new Container(
                    //           width: MediaQuery.of(context).size.width * .94,
                    //           decoration: darkContainer,
                    //           padding: EdgeInsets.all(2.0),
                    //           child: Row(
                    //             children: <Widget>[
                    //               Expanded(
                    //                 child: Column(
                    //                   crossAxisAlignment:
                    //                       CrossAxisAlignment.start,
                    //                   children: <Widget>[
                    //                     Text('Lets look at the problems first..',
                    //                         style: textLabelTextStyle),
                    //                     verticalSpacer,
                    //                     RichText(
                    //                         text: TextSpan(
                    //                             style: highlightSubTextStyle,
                    //                             children: <TextSpan>[
                    //                           TextSpan(
                    //                               text:
                    //                                   'There is not just one, but numerous reasons how this helps you. Here is how - '),
                    //                           TextSpan(
                    //                               text:
                    //                                   'Maintaing social distance is need of the hour. Sometimes just unavoidable when you visit your '),
                    //                           TextSpan(
                    //                               text:
                    //                                   'favourite grocery store for example, you see people standing in queue and wait-time could be anything from 10 mins to an hour.'),
                    //                           TextSpan(
                    //                               text:
                    //                                   'Another problem is, Shopping at place this crowded is not at all advisable.'),
                    //                           TextSpan(
                    //                               text:
                    //                                   'So, Not just you waste your precious time in waiting but also expose yourself to virus(Covid-19).'),
                    //                         ])),
                    //                     verticalSpacer,
                    //                     myDivider,
                    //                     verticalSpacer,
                    //                     Text('How this app helps me?',
                    //                         style: textLabelTextStyle),
                    //                     verticalSpacer,
                    //                     RichText(
                    //                         text: TextSpan(
                    //                             style: highlightSubTextStyle,
                    //                             children: <TextSpan>[
                    //                           TextSpan(
                    //                               text:
                    //                                   'The idea to is plan your visits well ahead so that shopping doesnt become unsafe for you.'),
                    //                           TextSpan(
                    //                               text:
                    //                                   'Now, How do we do this. We lists different premises like Shopping Marts, Gaming Zones, Offices, Apartments, Medical Stores etc'),
                    //                           TextSpan(
                    //                               text:
                    //                                   ' where you might visit frequently. Dates and available time slots will be shown, you can select time and date as per your convenience.  '),
                    //                           TextSpan(
                    //                               text:
                    //                                   ' So, Now when you visit at your pre-booked time, you dont have to wait and second as limited people would be allowed in a given time slot, it '),
                    //                           TextSpan(
                    //                               text:
                    //                                   ' much easier to maintain distance and be safe.'),
                    //                         ])),
                    //                     verticalSpacer,
                    //                   ],
                    //                 ),
                    //               ),
                    //             ],
                    //           ),
                    //         ),
                    //       ],
                    //     ),
                    //   ),
                    // ),
                    Card(
                        elevation: 20,
                        child: Container(
                          // padding: EdgeInsets.all(8),
                          child: Column(
                            children: <Widget>[
                              Container(
                                  height:
                                      MediaQuery.of(context).size.width * .08,
                                  width: MediaQuery.of(context).size.width,
                                  alignment: Alignment.center,
                                  padding: EdgeInsets.fromLTRB(6, 0, 0, 0),
                                  decoration: btnColorContainer,
                                  child: Text(
                                    faqHead1,
                                    style: faqTabTextStyle,
                                  )),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    Text(faqHead1Sub1,
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
                                    Text(faqHead1Sub2,
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
                                                  'Now, How do we do this. We lists different places like Shopping Marts, Gaming Zones, Offices, Apartments, Medical Stores, etc'),
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
                                  height:
                                      MediaQuery.of(context).size.width * .08,
                                  width: MediaQuery.of(context).size.width,
                                  padding: EdgeInsets.fromLTRB(6, 0, 0, 0),
                                  alignment: Alignment.center,
                                  decoration: btnColorContainer,
                                  child: Text(
                                    faqHead2,
                                    style: whiteBoldTextStyle1,
                                  )),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    Text(faqHead2Sub2,
                                        style: textLabelTextStyle),
                                    verticalSpacer,
                                    RichText(
                                        text: TextSpan(
                                            style: highlightSubTextStyle,
                                            children: <TextSpan>[
                                          TextSpan(
                                              text:
                                                  'Registering with us is very simple and safe. We just ask for your phone number and NO other details will be asked. After providing your number, you will recieve an OTP on your '),
                                          TextSpan(
                                              text:
                                                  'phone number, just enter that and Done!!'),
                                        ])),
                                    verticalSpacer,
                                    myDivider,
                                    verticalSpacer,
                                    Text(faqHead2Sub3,
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
                                            recognizer:
                                                new TapGestureRecognizer()
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
                                  height:
                                      MediaQuery.of(context).size.width * .08,
                                  width: MediaQuery.of(context).size.width,
                                  padding: EdgeInsets.fromLTRB(6, 0, 0, 0),
                                  decoration: btnColorContainer,
                                  alignment: Alignment.center,
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
                                    Text('How to book a time-slot?',
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
                                    Text(
                                        'How can I list my business/place here?',
                                        style: textLabelTextStyle),
                                    verticalSpacer,
                                    RichText(
                                        text: TextSpan(
                                            style: highlightSubTextStyle,
                                            children: <TextSpan>[
                                          TextSpan(
                                              text:
                                                  'Business can only be added by person who is either owner or authorized to manage the place. Using "Manage your Places" option, '),
                                          TextSpan(
                                              text:
                                                  'you can add the business and all details like opening/closing time, location of the place, number of people allowed in a time-slot to minimise crowd inside place.'),
                                          TextSpan(
                                              text:
                                                  'Fill all other important details. If your business has whatsapp contact, on-call contact person, please provide that too, that would help customers to contact you.'),
                                          TextSpan(
                                            text:
                                                '\nClick here to register your business!!',
                                            style: new TextStyle(
                                                color: highlightColor),
                                            recognizer:
                                                new TapGestureRecognizer()
                                                  ..onTap = () {
                                                    //TODO: Smita- add payments options google pay  etc
                                                    Navigator.pop(context);
                                                    Navigator.push(
                                                        context,
                                                        MaterialPageRoute(
                                                            builder: (context) =>
                                                                ManageEntityListPage()));
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
          // bottomNavigationBar: CustomBottomBar(
          //   barIndex: 0,
          // ),
        ),
        onWillPop: () async {
          return true;
        },
      ),
    );
  }
}
