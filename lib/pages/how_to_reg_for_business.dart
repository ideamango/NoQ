import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:noq/login_page.dart';
import 'package:noq/style.dart';
import 'package:noq/widget/carousel_business_use.dart';
import 'package:noq/widget/video_player_app.dart';

class HowToRegForBusiness extends StatefulWidget {
  @override
  _HowToRegForBusinessState createState() => _HowToRegForBusinessState();
}

class _HowToRegForBusinessState extends State<HowToRegForBusiness> {
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
              margin: EdgeInsets.fromLTRB(10, 10, 10, 10),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  Card(
                    margin: EdgeInsets.zero,
                    elevation: 20,
                    child: Container(
                      height: MediaQuery.of(context).size.height * .9,
                      padding: EdgeInsets.all(0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Column(
                            children: <Widget>[
                              CarouselSlider(
                                options: CarouselOptions(
                                  height:
                                      MediaQuery.of(context).size.height * .87,
                                  autoPlay: true,
                                  autoPlayInterval: Duration(seconds: 3),
                                  autoPlayAnimationDuration:
                                      Duration(milliseconds: 800),
                                  autoPlayCurve: Curves.easeIn,
                                  pauseAutoPlayOnTouch: true,
                                  aspectRatio: 2.0,
                                  onPageChanged:
                                      (index, carouselPageChangedReason) {
                                    setState(() {
                                      _currentIndex = index;
                                    });
                                  },
                                ),
                                items: cardList.map((card) {
                                  return Builder(
                                      builder: (BuildContext context) {
                                    return Container(
                                      height:
                                          MediaQuery.of(context).size.height *
                                              .75,
                                      width: MediaQuery.of(context).size.width,
                                      child: card,
                                    );
                                  });
                                }).toList(),
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: <Widget>[
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children:
                                        map<Widget>(cardList, (index, url) {
                                      return Container(
                                        width: 7.0,
                                        height: 7.0,
                                        margin: EdgeInsets.symmetric(
                                            vertical: 2.0, horizontal: 2.0),
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: _currentIndex == index
                                              ? highlightColor
                                              : Colors.grey,
                                        ),
                                      );
                                    }),
                                  ),
                                ],
                              )
                            ],
                          ),
                          // Column(
                          //   children: <Widget>[
                          //     Text(homeScreenMsgTxt2, style: homeMsgStyle2),
                          //     Text(
                          //       homeScreenMsgTxt3,
                          //       style: homeMsgStyle3,
                          //     ),
                          //   ],
                          // )
                        ],
                      ),
                    ),
                    //child: Image.asset('assets/noq_home.png'),
                  ),
                  // Card(
                  //   margin: EdgeInsets.all(8),
                  //   elevation: 20,
                  //   child: Container(
                  //     width: MediaQuery.of(context).size.width * .92,
                  //     margin: EdgeInsets.zero,
                  //     padding: EdgeInsets.all(0),
                  //     child: VideoPlayerApp(
                  //       videoNwLink:
                  //           'https://firebasestorage.googleapis.com/v0/b/awesomenoq.appspot.com/o/how_to_guide_user.mp4?alt=media&token=53bf4d71-9163-40cc-9afb-40c7d45a56a5',
                  //     ),
                  //   ),
                  // ),
                  Container(
                    padding: EdgeInsets.all(0),
                    margin: EdgeInsets.all(0),
                    child: FlatButton(
                      padding: EdgeInsets.all(0),
                      color: btnColor,
                      splashColor: highlightColor.withOpacity(.8),
                      onPressed: () {
                        Navigator.of(context).pop();
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
