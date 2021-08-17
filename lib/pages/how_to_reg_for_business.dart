import 'package:flutter/material.dart';
import '../global_state.dart';
import '../widget/video_player_app.dart';

class HowToRegForBusiness extends StatefulWidget {
  @override
  _HowToRegForBusinessState createState() => _HowToRegForBusinessState();
}

class _HowToRegForBusinessState extends State<HowToRegForBusiness> {
  GlobalState _gs;
  String videoPath;
  @override
  void initState() {
    super.initState();
    GlobalState.getGlobalState().then((value) {
      _gs = value;
      videoPath = _gs.getConfigurations().userBookingVideoLink;
    });
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
        body: Center(
          child: SingleChildScrollView(
            child: Container(
              //height: MediaQuery.of(context).size.height * .9,
              margin: EdgeInsets.fromLTRB(10, 10, 10, 10),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  Card(
                    margin: EdgeInsets.all(0),
                    elevation: 0,
                    child: Container(
                      height: MediaQuery.of(context).size.height * .95,
                      width: MediaQuery.of(context).size.width * .9,
                      margin: EdgeInsets.zero,
                      padding: EdgeInsets.all(0),
                      child: VideoPlayerApp(
                        videoNwLink: videoPath,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      onWillPop: () async {
        return true;
      },
    );
  }
}
