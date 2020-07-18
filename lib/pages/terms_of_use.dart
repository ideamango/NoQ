import 'package:flutter/material.dart';
import 'package:noq/constants.dart';
import 'package:noq/login_page.dart';
import 'package:noq/style.dart';
import 'package:noq/widget/widgets.dart';

class TermsOfUsePage extends StatefulWidget {
  @override
  _TermsOfUsePageState createState() => _TermsOfUsePageState();
}

class _TermsOfUsePageState extends State<TermsOfUsePage> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData.light().copyWith(),
      home: Scaffold(
        appBar: AppBar(
          actions: <Widget>[],
          flexibleSpace: Container(
            decoration: gradientBackground,
          ),
          leading: IconButton(
            padding: EdgeInsets.all(0),
            alignment: Alignment.center,
            highlightColor: highlightColor,
            icon: Icon(Icons.arrow_back),
            color: Colors.white,
            onPressed: () {
              print("going back");
              //Navigator.of(context).pop();
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => LoginPage()));
            },
          ),
          title: Text("Agreement", style: whiteBoldTextStyle1),
        ),
        body: Center(
            child: Container(
          margin: EdgeInsets.fromLTRB(10, 10, 10, 10),
          child: ListView(
            children: <Widget>[
              Theme(
                data: ThemeData(
                  unselectedWidgetColor: Colors.grey[600],
                  accentColor: primaryAccentColor,
                ),
                child: ExpansionTile(
                  //key: PageStorageKey(this.widget.headerTitle),
                  initiallyExpanded: true,
                  title: Text(
                    "Terms of Service",
                    style: TextStyle(color: Colors.blueGrey[700], fontSize: 17),
                  ),
                  backgroundColor: Colors.white,
                  leading: Icon(
                    Icons.date_range,
                    color: primaryIcon,
                  ),
                  children: <Widget>[
                    ConstrainedBox(
                      constraints: new BoxConstraints(
                        maxHeight: MediaQuery.of(context).size.height * .3,
                      ),
                      child: Scrollbar(
                        child: SingleChildScrollView(
                          physics: BouncingScrollPhysics(),
                          child: RichText(
                              text: TextSpan(
                                  style: highlightSubTextStyle,
                                  children: <TextSpan>[
                                TextSpan(text: agreement),
                              ])),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Theme(
                data: ThemeData(
                  unselectedWidgetColor: Colors.grey[600],
                  accentColor: primaryAccentColor,
                ),
                child: ExpansionTile(
                  //key: PageStorageKey(this.widget.headerTitle),
                  initiallyExpanded: true,
                  title: Text(
                    "Privacy Policy",
                    style: TextStyle(color: Colors.blueGrey[700], fontSize: 17),
                  ),
                  backgroundColor: Colors.white,
                  leading: Icon(
                    Icons.date_range,
                    color: primaryIcon,
                  ),
                  children: <Widget>[
                    ConstrainedBox(
                      constraints: new BoxConstraints(
                        maxHeight: MediaQuery.of(context).size.height * .4,
                      ),
                      child: Scrollbar(
                        child: SingleChildScrollView(
                          physics: BouncingScrollPhysics(),
                          child: RichText(
                              text: TextSpan(
                                  style: highlightSubTextStyle,
                                  children: <TextSpan>[
                                TextSpan(
                                  text: privacy_policy,
                                ),
                              ])),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              verticalSpacer,
              verticalSpacer,
              // RaisedButton(
              //   color: btnColor,
              //   onPressed: () {
              //     print("Agreed to terms");
              //   },
              //   child: Text(
              //     "I Agree",
              //     style: buttonTextStyle,
              //   ),
              // )
            ],
          ),
        )),
      ),
    );
  }
}
