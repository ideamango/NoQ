import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:noq/global_state.dart';
import 'package:noq/pages/show_application_details.dart';
import 'package:noq/services/circular_progress.dart';
import 'package:noq/style.dart';
import 'package:noq/userHomePage.dart';
import 'package:noq/widget/animated_counter.dart';
import 'package:noq/widget/appbar.dart';
import 'package:noq/widget/page_animation.dart';
import 'package:noq/widget/widgets.dart';

class OverviewPage extends StatefulWidget {
  final String entityId;
  OverviewPage({Key key, @required this.entityId}) : super(key: key);
  @override
  _OverviewPageState createState() => _OverviewPageState();
}

class _OverviewPageState extends State<OverviewPage> {
  bool initCompleted = false;
  GlobalState _gs;
  int _completedCount = 0;

  @override
  void initState() {
    super.initState();
    getGlobalState().whenComplete(() {
      if (this.mounted) {
        setState(() {
          initCompleted = true;
        });
      } else
        initCompleted = true;
    });
    Future.delayed(Duration(seconds: 1)).then((value) {
      setState(() {
        _completedCount = 2000;
      });
    });
  }

  Future<void> getGlobalState() async {
    _gs = await GlobalState.getGlobalState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    String pageTitle = "Overview";
    if (initCompleted) {
      return MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData.light().copyWith(),
        home: Scaffold(
          appBar: CustomAppBarWithBackButton(
            backRoute: UserHomePage(),
            titleTxt: pageTitle,
          ),
          body: Center(
            child: Container(
              //color: Colors.blueGrey[800],
              padding: EdgeInsets.all(10),
              child: Column(children: <Widget>[
                Card(
                  color: Colors.greenAccent,
                  child: Container(
                      width: MediaQuery.of(context).size.width * .9,
                      padding: EdgeInsets.all(10),
                      margin: EdgeInsets.all(15),
                      child: Column(
                        children: [
                          // Text(
                          //   '30',
                          //   style: TextStyle(
                          //     fontSize: 30,
                          //     fontFamily: 'Roboto',
                          //   ),
                          // ),
                          Text(
                            'Some message can be given here',
                            style: TextStyle(
                              fontSize: 15,
                              fontFamily: 'RalewayRegular',
                            ),
                          ),
                        ],
                      )),
                ),
                verticalSpacer,
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Card(
                      elevation: 20,
                      color: Colors.blue[300],
                      child: Container(
                          width: MediaQuery.of(context).size.width * .3,
                          child: Stack(
                            alignment: Alignment.topRight,
                            children: [
                              Container(
                                padding: EdgeInsets.all(10),
                                child: Column(
                                  children: [
                                    AutoSizeText(
                                      '300',
                                      maxLines: 1,
                                      minFontSize: 12,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 30,
                                        fontFamily: 'Roboto',
                                      ),
                                    ),
                                    AutoSizeText(
                                      'New Requests',
                                      maxLines: 1,
                                      minFontSize: 12,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        fontSize: 15,
                                        fontFamily: 'RalewayRegular',
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Icon(
                                Icons.new_releases_rounded,
                                color: Colors.yellowAccent,
                                size: 25,
                              )
                            ],
                          )),
                    ),
                    Card(
                      elevation: 20,
                      color: Colors.amberAccent,
                      child: GestureDetector(
                        onTap: () {
                          //User clicked on show how, lets show them.
                          print("Showing how to book time-slot");
                          Navigator.of(context).push(
                              PageAnimation.createRoute(ShowApplicationDetails(
                            entityId: widget.entityId,
                          )));
                        },
                        child: Container(
                            width: MediaQuery.of(context).size.width * .4,
                            child: Stack(
                              alignment: Alignment.topRight,
                              children: [
                                Container(
                                  width: MediaQuery.of(context).size.width * .4,
                                  padding: EdgeInsets.all(10),
                                  child: Column(
                                    children: [
                                      AutoSizeText(
                                        '1000',
                                        maxLines: 1,
                                        minFontSize: 12,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                          fontWeight: FontWeight.w600,
                                          fontSize: 30,
                                          fontFamily: 'Roboto',
                                        ),
                                      ),
                                      AutoSizeText(
                                        'In-Process',
                                        maxLines: 1,
                                        minFontSize: 12,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                          fontSize: 15,
                                          fontFamily: 'RalewayRegular',
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Icon(
                                  Icons.hourglass_bottom,
                                  color: Colors.green,
                                  size: 25,
                                )
                              ],
                            )),
                      ),
                    ),
                  ],
                ),
                verticalSpacer,
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Card(
                      elevation: 20,
                      color: Colors.pink[200],
                      child: Container(
                          width: MediaQuery.of(context).size.width * .25,
                          child: Stack(
                            alignment: Alignment.topRight,
                            children: [
                              Container(
                                width: MediaQuery.of(context).size.width * .25,
                                padding: EdgeInsets.all(10),
                                child: Column(
                                  children: [
                                    AutoSizeText(
                                      '200',
                                      maxLines: 1,
                                      minFontSize: 12,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 30,
                                        fontFamily: 'Roboto',
                                      ),
                                    ),
                                    AutoSizeText(
                                      'Cancelled',
                                      maxLines: 1,
                                      minFontSize: 12,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        fontSize: 15,
                                        fontFamily: 'RalewayRegular',
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Icon(
                                Icons.cancel,
                                color: Colors.purple,
                                size: 25,
                              )
                            ],
                          )),
                    ),
                    Card(
                      elevation: 20,
                      color: Colors.lightGreen,
                      child: Container(
                          width: MediaQuery.of(context).size.width * .25,
                          height: MediaQuery.of(context).size.width * .25,
                          child: Stack(
                            alignment: Alignment.topRight,
                            children: [
                              Container(
                                width: MediaQuery.of(context).size.width * .25,
                                // padding: EdgeInsets.fromLTRB(10, 20, 10, 10),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    AutoSizeText(
                                      '200',
                                      maxLines: 1,
                                      minFontSize: 12,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 30,
                                        fontFamily: 'Roboto',
                                      ),
                                    ),
                                    AutoSizeText(
                                      'In-Queue',
                                      maxLines: 1,
                                      minFontSize: 12,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        fontSize: 15,
                                        fontFamily: 'RalewayRegular',
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Icon(
                                Icons.star_half_outlined,
                                color: Colors.deepOrangeAccent,
                                size: 30,
                              )
                            ],
                          )),
                    ),
                    Card(
                      elevation: 20,
                      color: Colors.orangeAccent,
                      child: Container(
                          width: MediaQuery.of(context).size.width * .25,
                          child: Stack(
                            alignment: Alignment.topRight,
                            children: [
                              Container(
                                width: MediaQuery.of(context).size.width * .25,
                                padding: EdgeInsets.all(10),
                                child: Column(
                                  children: [
                                    AutoSizeText(
                                      '200',
                                      maxLines: 1,
                                      minFontSize: 12,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 30,
                                        fontFamily: 'Roboto',
                                      ),
                                    ),
                                    AutoSizeText(
                                      'Rejected',
                                      maxLines: 1,
                                      minFontSize: 12,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        fontSize: 15,
                                        fontFamily: 'RalewayRegular',
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Icon(
                                Icons.do_disturb_on_rounded,
                                color: Colors.red,
                                size: 25,
                              )
                            ],
                          )),
                    ),
                  ],
                ),
                verticalSpacer,
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Card(
                      elevation: 20,
                      color: Colors.limeAccent,
                      child: Container(
                          width: MediaQuery.of(context).size.width * .25,
                          child: Stack(
                            alignment: Alignment.topRight,
                            children: [
                              Container(
                                width: MediaQuery.of(context).size.width * .25,
                                padding: EdgeInsets.all(10),
                                child: Column(
                                  children: [
                                    AutoSizeText(
                                      '200',
                                      maxLines: 1,
                                      minFontSize: 12,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 30,
                                        fontFamily: 'Roboto',
                                      ),
                                    ),
                                    AutoSizeText(
                                      'On-Hold',
                                      maxLines: 1,
                                      minFontSize: 12,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        fontSize: 15,
                                        fontFamily: 'RalewayRegular',
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Icon(
                                Icons.star_half_outlined,
                                color: Colors.indigo[900],
                                size: 25,
                              )
                            ],
                          )),
                    ),
                    Card(
                      elevation: 20,
                      color: Colors.purple[200],
                      child: Container(
                          width: MediaQuery.of(context).size.width * .4,
                          height: MediaQuery.of(context).size.width * .2,
                          child: Stack(
                            alignment: Alignment.topRight,
                            children: [
                              Container(
                                width: MediaQuery.of(context).size.width * .4,
                                padding: EdgeInsets.all(10),
                                child: Column(
                                  children: [
                                    AutoSizeText(
                                      '40',
                                      maxLines: 1,
                                      minFontSize: 12,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 30,
                                        fontFamily: 'Roboto',
                                      ),
                                    ),
                                    AutoSizeText(
                                      'Approved',
                                      maxLines: 1,
                                      minFontSize: 12,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        fontSize: 15,
                                        fontFamily: 'RalewayRegular',
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Icon(
                                Icons.add_box,
                                color: Colors.lightGreenAccent,
                                size: 25,
                              )
                            ],
                          )),
                    ),
                  ],
                ),
                verticalSpacer,
                Card(
                  elevation: 20,
                  color: Colors.blueGrey,
                  child: Container(
                      width: MediaQuery.of(context).size.width * .7,
                      child: Stack(
                        alignment: Alignment.topRight,
                        children: [
                          Container(
                            width: MediaQuery.of(context).size.width * .7,
                            padding: EdgeInsets.all(10),
                            child: Column(
                              children: [
                                new AnimatedCount(
                                  count: _completedCount,
                                  duration: Duration(seconds: 2),
                                ),
                                AutoSizeText(
                                  'Completed ',
                                  maxLines: 1,
                                  minFontSize: 12,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    color: primaryAccentColor,
                                    fontSize: 15,
                                    fontFamily: 'RalewayRegular',
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Icon(
                            Icons.check_circle,
                            color: Colors.yellowAccent,
                            size: 25,
                          )
                        ],
                      )),
                ),
              ]),
            ),
          ),
        ),
      );
    } else {
      return MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData.light().copyWith(),
        home: new WillPopScope(
          child: Scaffold(
            appBar: CustomAppBarWithBackButton(
              backRoute: UserHomePage(),
              titleTxt: pageTitle,
            ),
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  showCircularProgress(),
                ],
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
}
