import 'package:flutter/material.dart';
import '../login_page.dart';
import '../style.dart';
import '../widget/video_player_app.dart';

class ExplorePageForBusiness extends StatefulWidget {
  //final String forPage;
  //SearchStoresPage({Key key, @required this.forPage}) : super(key: key);
  @override
  _ExplorePageForBusinessState createState() => _ExplorePageForBusinessState();
}

class _ExplorePageForBusinessState extends State<ExplorePageForBusiness> {
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
    return WillPopScope(
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        body: Container(
          margin: EdgeInsets.fromLTRB(10, 10, 10, 10),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              //TODO Phase2 - show videos on HOW TO
              // Card(
              //   margin: EdgeInsets.all(8),
              //   elevation: 20,
              //   child: Container(
              //     width: MediaQuery.of(context).size.width * .92,
              //     margin: EdgeInsets.zero,
              //     padding: EdgeInsets.all(0),
              //     child: VideoPlayerApp(
              //       videoNwLink:
              //           'https://firebasestorage.googleapis.com/v0/b/awesomenoq.appspot.com/o/business_info.mp4?alt=media&token=382d4df1-d167-4554-abf3-926257b095eb',
              //     ),
              //   ),
              // ),
              Card(
                margin: EdgeInsets.fromLTRB(12, 30, 12, 12),
                elevation: 20,
                child: Container(
                  // width: MediaQuery.of(context).size.width * .92,
                  margin: EdgeInsets.zero,
                  padding: EdgeInsets.all(0),
                  child: Image(image: AssetImage('assets/infoBusiness.png')),
                ),
              ),
              Container(
                padding: EdgeInsets.all(0),
                margin: EdgeInsets.all(0),
                child: FlatButton(
                  padding: EdgeInsets.all(0),
                  color: btnColor,
                  splashColor: highlightColor.withOpacity(.8),
                  onPressed: () {
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) => LoginPage()));
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
                          color: Colors.white,
                          size: 20,
                          // color: Colors.white,
                        ),
                      ),
                      Text(
                        "Go back & Register",
                        style: btnTextStyle,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      onWillPop: () async {
        return true;
      },
    );
  }
}
