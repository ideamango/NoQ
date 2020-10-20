import 'package:flutter/material.dart';
import 'package:noq/constants.dart';
import 'package:noq/style.dart';
import 'package:noq/userHomePage.dart';
import 'package:noq/widget/appbar.dart';
import 'package:noq/widget/bottom_nav_bar.dart';
import 'package:noq/widget/header.dart';
import 'package:noq/widget/widgets.dart';

class AboutUsPage extends StatefulWidget {
  @override
  _AboutUsPageState createState() => _AboutUsPageState();
}

class _AboutUsPageState extends State<AboutUsPage> {
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
    String title = "About Us";
    return MaterialApp(
      theme: ThemeData.light().copyWith(),
      home: Scaffold(
        drawer: CustomDrawer(
          //TODO phone  here
          //phone: _state.currentUser.ph,
          phone: null,
        ),
        appBar: CustomAppBar(
          titleTxt: title,
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
                    "Story of Sukoon",
                    style: TextStyle(color: Colors.blueGrey[700], fontSize: 17),
                  ),
                  backgroundColor: Colors.white,
                  leading: Icon(
                    Icons.face,
                    color: primaryIcon,
                  ),
                  children: <Widget>[
                    ConstrainedBox(
                      constraints: new BoxConstraints(
                        maxHeight: MediaQuery.of(context).size.height * .5,
                      ),
                      child: Scrollbar(
                        child: SingleChildScrollView(
                          physics: BouncingScrollPhysics(),
                          child: RichText(
                              text: TextSpan(
                                  style: highlightSubTextStyle,
                                  children: <TextSpan>[
                                TextSpan(text: ourStory),
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
                    "Our Mission",
                    style: TextStyle(color: Colors.blueGrey[700], fontSize: 17),
                  ),
                  backgroundColor: Colors.white,
                  leading: Icon(
                    Icons.description,
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
                                TextSpan(text: privacy_policy),
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
        // bottomNavigationBar: CustomBottomBar(
        //   barIndex: 3,
        // ),
      ),
    );
  }
}
