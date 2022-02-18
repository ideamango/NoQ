import 'dart:io';

import 'package:LESSs/global_state.dart';

import '../widget/page_animation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import '../constants.dart';
import '../pages/contact_us.dart';
import '../pages/manage_entity_list_page.dart';
import '../style.dart';
import '../userHomePage.dart';
import '../widget/appbar.dart';
import '../widget/header.dart';
import '../widget/widgets.dart';
import 'upi_payment_page.dart';

class HelpPage extends StatefulWidget {
  HelpPage({
    Key? key,
  }) : super(key: key);
  @override
  _HelpPageState createState() => _HelpPageState();
}

class _HelpPageState extends State<HelpPage> {
  bool initCompleted = false;
  GlobalState? _gs;
  String? upiId;
  String? upiQrImgPath;
  String? emailId;
  @override
  void initState() {
    getGlobalState().then((gs) {
      _gs = gs;
      emailId = _gs!.getConfigurations()!.contactEmail;
      upiId = _gs!.getConfigurations()!.upi;
      upiQrImgPath = "assets/bigpiq_gpay.jpg";
      upiId = upiId;
      setState(() {
        initCompleted = true;
      });
    });
    super.initState();
  }

  Future<GlobalState?> getGlobalState() async {
    return await GlobalState.getGlobalState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    String title = "Help Center";
    return WillPopScope(
      child: Scaffold(
        appBar: CustomAppBarWithBackButton(
          backRoute: UserHomePage(),
          titleTxt: title,
        ),
        body: Container(
            margin: EdgeInsets.all(6),
            color: Colors.white,
            child: ListView(children: <Widget>[
              Column(
                children: <Widget>[
                  Card(
                    elevation: 20,
                    child: Container(
                        height: MediaQuery.of(context).size.height * .2,
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
                              child: RichText(
                                  text: TextSpan(
                                      style: TextStyle(
                                          fontFamily: "AkkuratPro",
                                          color: Colors.black),
                                      children: <TextSpan>[
                                    TextSpan(text: faqHeadline),
                                    TextSpan(
                                      text: emailId,
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
                                  ])),
                            ),
                            verticalSpacer
                          ],
                        ),
                      )),
                  Card(
                      elevation: 20,
                      child: Container(
                        child: Column(
                          children: <Widget>[
                            Container(
                                height: MediaQuery.of(context).size.width * .08,
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
                                  Text(faq1, style: faqQuesStyle),
                                  verticalSpacer,
                                  RichText(
                                      text: TextSpan(
                                          style: faqAnsStyle,
                                          children: <TextSpan>[
                                        TextSpan(text: faqAns1),
                                      ])),
                                  verticalSpacer,
                                  myDivider,
                                  verticalSpacer,
                                  Text(faq2, style: faqQuesStyle),
                                  verticalSpacer,
                                  RichText(
                                      text: TextSpan(
                                          style: faqAnsStyle,
                                          children: <TextSpan>[
                                        TextSpan(text: faqAns2),
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
                                  Text(faq3, style: faqQuesStyle),
                                  verticalSpacer,
                                  RichText(
                                      text: TextSpan(
                                          style: faqAnsStyle,
                                          children: <TextSpan>[
                                        TextSpan(text: faqAns3),
                                      ])),
                                  verticalSpacer,
                                  myDivider,
                                  verticalSpacer,
                                  Text(faq4, style: faqQuesStyle),
                                  verticalSpacer,
                                  RichText(
                                      text: TextSpan(
                                          style: faqAnsStyle,
                                          children: <TextSpan>[
                                        TextSpan(text: faqAns4),
                                        TextSpan(
                                          text: faqAns4_2,
                                          style: new TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.orange[700]),
                                          recognizer: new TapGestureRecognizer()
                                            ..onTap = () {
                                              Navigator.of(context).push(
                                                  new MaterialPageRoute(
                                                      builder: (BuildContext
                                                              context) =>
                                                          UPIPaymentPage(
                                                            upiId: upiId,
                                                            upiQrCodeImgPath:
                                                                upiQrImgPath,
                                                            backRoute:
                                                                HelpPage(),
                                                            isDonation: true,
                                                            showMinimum: false,
                                                          )));
                                            },
                                        ),
                                      ])),
                                  verticalSpacer,
                                  myDivider,
                                  verticalSpacer,
                                  Text(faq5, style: faqQuesStyle),
                                  verticalSpacer,
                                  RichText(
                                      text: TextSpan(
                                          style: faqAnsStyle,
                                          children: <TextSpan>[
                                        TextSpan(text: faqAns5),
                                      ])),
                                  verticalSpacer,
                                  myDivider,
                                  verticalSpacer,
                                  Text(faq6, style: faqQuesStyle),
                                  verticalSpacer,
                                  RichText(
                                      text: TextSpan(
                                          style: faqAnsStyle,
                                          children: <TextSpan>[
                                        TextSpan(text: faqAns6),
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
                                  Text(faq7, style: faqQuesStyle),
                                  verticalSpacer,
                                  RichText(
                                      text: TextSpan(
                                          style: faqAnsStyle,
                                          children: <TextSpan>[
                                        TextSpan(text: faqAns7),
                                      ])),
                                  verticalSpacer,
                                  myDivider,
                                  verticalSpacer,
                                  Text(faq8, style: faqQuesStyle),
                                  verticalSpacer,
                                  RichText(
                                      text: TextSpan(
                                          style: faqAnsStyle,
                                          children: <TextSpan>[
                                        TextSpan(text: faqAns8),
                                      ])),
                                  verticalSpacer,
                                  myDivider,
                                  verticalSpacer,
                                  Text(faq9, style: faqQuesStyle),
                                  verticalSpacer,
                                  RichText(
                                      text: TextSpan(
                                          style: faqAnsStyle,
                                          children: <TextSpan>[
                                        TextSpan(
                                          text: faqAns9,
                                        ),
                                      ])),
                                  verticalSpacer,
                                  myDivider,
                                  verticalSpacer,
                                  Text(faq10, style: faqQuesStyle),
                                  verticalSpacer,
                                  RichText(
                                      text: TextSpan(
                                          style: faqAnsStyle,
                                          children: <TextSpan>[
                                        TextSpan(text: faqAns10),
                                      ])),
                                  verticalSpacer,
                                  myDivider,
                                  verticalSpacer,
                                  Text(faq11, style: faqQuesStyle),
                                  verticalSpacer,
                                  RichText(
                                      text: TextSpan(
                                          style: faqAnsStyle,
                                          children: <TextSpan>[
                                        TextSpan(text: faqAns11),
                                      ])),
                                  verticalSpacer,
                                  myDivider,
                                  verticalSpacer,
                                  Text(faq12, style: faqQuesStyle),
                                  verticalSpacer,
                                  RichText(
                                      text: TextSpan(
                                          style: faqAnsStyle,
                                          children: <TextSpan>[
                                        TextSpan(text: faqAns12),
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
                                alignment: Alignment.center,
                                decoration: btnColorContainer,
                                child: Text(
                                  faqHead4,
                                  style: whiteBoldTextStyle1,
                                )),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Text(faq13, style: faqQuesStyle),
                                  verticalSpacer,
                                  RichText(
                                      text: TextSpan(
                                          style: faqAnsStyle,
                                          children: <TextSpan>[
                                        TextSpan(text: faqAns13),
                                      ])),
                                  verticalSpacer,
                                  myDivider,
                                  verticalSpacer,
                                  Text(faq14, style: faqQuesStyle),
                                  verticalSpacer,
                                  RichText(
                                      text: TextSpan(
                                          style: faqAnsStyle,
                                          children: <TextSpan>[
                                        TextSpan(text: faqAns14),
                                        TextSpan(
                                          text: faqAns14_2,
                                          style: new TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.orange[700]),
                                          recognizer: new TapGestureRecognizer()
                                            ..onTap = () {
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
                                  Text(faq15, style: faqQuesStyle),
                                  verticalSpacer,
                                  RichText(
                                      text: TextSpan(
                                          style: faqAnsStyle,
                                          children: <TextSpan>[
                                        TextSpan(text: faqAns15),
                                      ])),
                                  verticalSpacer,
                                  myDivider,
                                  verticalSpacer,
                                  Text(faq16, style: faqQuesStyle),
                                  verticalSpacer,
                                  RichText(
                                      text: TextSpan(
                                          style: faqAnsStyle,
                                          children: <TextSpan>[
                                        TextSpan(text: faqAns16),
                                      ])),
                                  verticalSpacer,
                                  myDivider,
                                  verticalSpacer,
                                  Text(faq17, style: faqQuesStyle),
                                  verticalSpacer,
                                  RichText(
                                      text: TextSpan(
                                          style: faqAnsStyle,
                                          children: <TextSpan>[
                                        TextSpan(text: faqAns17),
                                      ])),
                                  verticalSpacer,
                                  myDivider,
                                  verticalSpacer,
                                  Text(faq18, style: faqQuesStyle),
                                  verticalSpacer,
                                  RichText(
                                      text: TextSpan(
                                          style: faqAnsStyle,
                                          children: <TextSpan>[
                                        TextSpan(text: faqAns18),
                                      ])),
                                  verticalSpacer,
                                  myDivider,
                                  verticalSpacer,
                                  Text(faq19, style: faqQuesStyle),
                                  verticalSpacer,
                                  RichText(
                                      text: TextSpan(
                                          style: faqAnsStyle,
                                          children: <TextSpan>[
                                        TextSpan(text: faqAns19),
                                      ])),
                                  verticalSpacer,
                                  myDivider,
                                  verticalSpacer,
                                  Text(faq20, style: faqQuesStyle),
                                  verticalSpacer,
                                  RichText(
                                      text: TextSpan(
                                          style: faqAnsStyle,
                                          children: <TextSpan>[
                                        TextSpan(text: faqAns20),
                                      ])),
                                  verticalSpacer,
                                  myDivider,
                                  verticalSpacer,
                                  Text(faq21, style: faqQuesStyle),
                                  verticalSpacer,
                                  RichText(
                                      text: TextSpan(
                                          style: faqAnsStyle,
                                          children: <TextSpan>[
                                        TextSpan(text: faqAns21),
                                      ])),
                                  verticalSpacer,
                                  myDivider,
                                  verticalSpacer,
                                  Text(faq22, style: faqQuesStyle),
                                  verticalSpacer,
                                  RichText(
                                      text: TextSpan(
                                          style: faqAnsStyle,
                                          children: <TextSpan>[
                                        TextSpan(text: faqAns22),
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
                      child: Column(children: <Widget>[
                        Container(
                            height: MediaQuery.of(context).size.width * .08,
                            width: MediaQuery.of(context).size.width,
                            padding: EdgeInsets.fromLTRB(6, 0, 0, 0),
                            alignment: Alignment.center,
                            decoration: btnColorContainer,
                            child: Text(
                              faqHead4,
                              style: whiteBoldTextStyle1,
                            )),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Text(faq23, style: faqQuesStyle),
                                verticalSpacer,
                                RichText(
                                    text: TextSpan(
                                        style: faqAnsStyle,
                                        children: <TextSpan>[
                                      TextSpan(text: faqAns23),
                                    ])),
                                verticalSpacer,
                                myDivider,
                                verticalSpacer,
                                Text(faq24, style: faqQuesStyle),
                                verticalSpacer,
                                RichText(
                                    text: TextSpan(
                                        style: faqAnsStyle,
                                        children: <TextSpan>[
                                      TextSpan(text: faqAns24),
                                    ])),
                                verticalSpacer,
                                myDivider,
                                verticalSpacer,
                                Text(faq25, style: faqQuesStyle),
                                verticalSpacer,
                                RichText(
                                    text: TextSpan(
                                        style: faqAnsStyle,
                                        children: <TextSpan>[
                                      TextSpan(text: faqAns25),
                                    ])),
                                verticalSpacer,
                              ]),
                        ),
                      ]),
                    ),
                  ),
                ],
              ),
            ])),
      ),
      onWillPop: () async {
        Navigator.of(context).popUntil(ModalRoute.withName('/dashboard'));
        Navigator.of(context).push(new MaterialPageRoute(
            builder: (BuildContext context) => UserHomePage()));
        return false;
      },
    );
  }
}
