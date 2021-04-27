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
    String title = "Story of LESSs";
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.light().copyWith(),
      home: WillPopScope(
        child: Scaffold(
          drawer: CustomDrawer(
            //TODO phone  here
            //phone: _state.currentUser.ph,
            phone: null,
          ),
          appBar: CustomAppBarWithBackButton(
            backRoute: UserHomePage(),
            titleTxt: title,
          ),
          body: Center(
              child: Container(
            margin: EdgeInsets.fromLTRB(10, 0, 10, 10),
            child: ListView(
              children: <Widget>[
                Container(
                    padding: EdgeInsets.all(0),
                    height: MediaQuery.of(context).size.height * .35,
                    child: Image.asset('assets/ourStory.png')),
                Scrollbar(
                  child: SingleChildScrollView(
                    physics: BouncingScrollPhysics(),
                    child: RichText(
                        text: TextSpan(
                            style: shareAppTextStyle,
                            children: <TextSpan>[
                          TextSpan(text: ourStory),
                        ])),
                  ),
                ),

                // Theme(
                //   data: ThemeData(
                //     unselectedWidgetColor: Colors.grey[600],
                //     accentColor: primaryAccentColor,
                //   ),
                //   child: ExpansionTile(
                //     //key: PageStorageKey(this.widget.headerTitle),
                //     initiallyExpanded: true,
                //     title: Text(
                //       "Our Mission",
                //       style:
                //           TextStyle(color: Colors.blueGrey[700], fontSize: 17),
                //     ),
                //     backgroundColor: Colors.white,
                //     leading: Icon(
                //       Icons.description,
                //       color: primaryIcon,
                //     ),
                //     children: <Widget>[
                //       ConstrainedBox(
                //         constraints: new BoxConstraints(
                //           maxHeight: MediaQuery.of(context).size.height * .3,
                //         ),
                //         child: Scrollbar(
                //           child: SingleChildScrollView(
                //             physics: BouncingScrollPhysics(),
                //             child: RichText(
                //                 text: TextSpan(
                //                     style: highlightSubTextStyle,
                //                     children: <TextSpan>[
                //                   TextSpan(text: privacyPolicy),
                //                 ])),
                //           ),
                //         ),
                //       ),
                //     ],
                //   ),
                // ),
                // verticalSpacer,
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
        onWillPop: () async {
          return true;
        },
      ),
    );
  }
}
