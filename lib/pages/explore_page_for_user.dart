import 'package:flutter/material.dart';
import 'package:noq/login_page.dart';
import 'package:noq/style.dart';

class ExplorePageForUser extends StatefulWidget {
  //final String forPage;
  //SearchStoresPage({Key key, @required this.forPage}) : super(key: key);
  @override
  _ExplorePageForUserState createState() => _ExplorePageForUserState();
}

class _ExplorePageForUserState extends State<ExplorePageForUser> {
  bool initCompleted = false;

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
    return MaterialApp(
      theme: ThemeData.light().copyWith(),
      home: WillPopScope(
        child: Scaffold(
          resizeToAvoidBottomInset: false,
          body: Center(
            child: Container(
              margin: EdgeInsets.fromLTRB(
                  10,
                  MediaQuery.of(context).size.width * .5,
                  10,
                  MediaQuery.of(context).size.width * .5),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Card(
                    margin: EdgeInsets.zero,
                    elevation: 20,
                    child: Container(
                      width: MediaQuery.of(context).size.width * .92,
                      margin: EdgeInsets.zero,
                      padding: EdgeInsets.all(0),
                      child:
                          Image(image: AssetImage('assets/infoCustomer.png')),
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.all(0),
                    margin: EdgeInsets.all(0),
                    child: FlatButton(
                      padding: EdgeInsets.all(0),
                      color: Colors.transparent,
                      splashColor: highlightColor.withOpacity(.8),
                      onPressed: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => LoginPage()));
                      },
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Container(
                            padding: EdgeInsets.fromLTRB(0, 0, 0, 0),
                            transform: Matrix4.translationValues(5.0, 0, 0),
                            child: Icon(
                              Icons.arrow_back_ios,
                              color: Colors.cyan[400],
                              size: 18,
                              // color: Colors.white38,
                            ),
                          ),
                          Container(
                            padding: EdgeInsets.fromLTRB(0, 0, 0, 0),
                            transform: Matrix4.translationValues(-8.0, 0, 0),
                            child: Icon(
                              Icons.arrow_back_ios,
                              color: primaryDarkColor,
                              size: 20,
                              // color: Colors.white,
                            ),
                          ),
                          Text(
                            "Explore as a user",
                            style: subHeadingTextStyle,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        onWillPop: () async {
          return true;
        },
      ),
    );
  }
}
