import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:noq/constants.dart';
import 'package:noq/style.dart';
import 'package:noq/widget/carousel_user_register.dart';
import 'package:noq/widget/video_player_app.dart';

class HowToRegForUsers extends StatefulWidget {
  @override
  _HowToRegForUsersState createState() => _HowToRegForUsersState();
}

class _HowToRegForUsersState extends State<HowToRegForUsers> {
  bool initCompleted = false;

  //For Carousel
  int _currentIndex = 0;
  List cardList = [
    Item1_login(),
    Item2_login(),
    Item3_search(),
    Item4_ViewLists(),
    Item5_BookSlots(),
    Item6_Token(),
    Item7_Done()
    //  Item7()
  ];
  List<T> map<T>(List list, Function handler) {
    List<T> result = [];
    for (var i = 0; i < list.length; i++) {
      result.add(handler(i, list[i]));
    }
    return result;
  }

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
      debugShowCheckedModeBanner: false,
      theme: ThemeData.light().copyWith(),
      home: WillPopScope(
        child: Scaffold(
          resizeToAvoidBottomInset: true,
          body: SingleChildScrollView(
            child: Container(
              //height: MediaQuery.of(context).size.height * .9,
              margin: EdgeInsets.fromLTRB(10, 10, 10, 10),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  Card(
                    margin: EdgeInsets.all(8),
                    elevation: 20,
                    child: Container(
                      height: MediaQuery.of(context).size.height * .95,
                      width: MediaQuery.of(context).size.width * .9,
                      margin: EdgeInsets.zero,
                      padding: EdgeInsets.all(0),
                      child: VideoPlayerApp(
                        videoNwLink:
                            'https://firebasestorage.googleapis.com/v0/b/awesomenoq.appspot.com/o/search_book.mp4?alt=media&token=168009a3-b6f5-4e7f-86d3-12c5770051c2',
                      ),
                    ),
                  ),
                  // Container(
                  //   padding: EdgeInsets.all(0),
                  //   margin: EdgeInsets.all(0),
                  //   child: FlatButton(
                  //     padding: EdgeInsets.all(0),
                  //     color: btnColor,
                  //     splashColor: highlightColor.withOpacity(.8),
                  //     onPressed: () {
                  //       Navigator.of(context).pop();
                  //     },
                  //     child: Row(
                  //       mainAxisAlignment: MainAxisAlignment.center,
                  //       children: <Widget>[
                  //         Container(
                  //           padding: EdgeInsets.fromLTRB(0, 0, 0, 0),
                  //           transform: Matrix4.translationValues(5.0, 0, 0),
                  //           child: Icon(
                  //             Icons.arrow_back_ios,
                  //             color: Colors.cyan[400],
                  //             size: 18,
                  //             // color: Colors.white38,
                  //           ),
                  //         ),
                  //         Container(
                  //           padding: EdgeInsets.fromLTRB(0, 0, 0, 0),
                  //           transform: Matrix4.translationValues(-8.0, 0, 0),
                  //           child: Icon(
                  //             Icons.arrow_back_ios,
                  //             color: Colors.white,
                  //             size: 20,
                  //             // color: Colors.white,
                  //           ),
                  //         ),
                  //         Text(
                  //           "Go back & Register",
                  //           style: subHeadingTextStyle,
                  //         ),
                  //       ],
                  //     ),
                  //   ),
                  // ),
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
