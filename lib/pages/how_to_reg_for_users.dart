import 'package:LESSs/global_state.dart';
import 'package:LESSs/services/circular_progress.dart';
import 'package:flutter/material.dart';
import '../widget/video_player_app.dart';

class HowToRegForUsers extends StatefulWidget {
  @override
  _HowToRegForUsersState createState() => _HowToRegForUsersState();
}

class _HowToRegForUsersState extends State<HowToRegForUsers> {
  GlobalState _gs;
  String videoPath;
  bool initCompleted = false;
  @override
  void initState() {
    super.initState();
    GlobalState.getGlobalState().then((value) {
      _gs = value;
      videoPath = _gs.getConfigurations().userBookingVideoLink;
      setState(() {
        initCompleted = true;
      });
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
        body: initCompleted
            ? Center(
                child: SingleChildScrollView(
                  child: Container(
                    height: MediaQuery.of(context).size.height,
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
                            margin: EdgeInsets.all(5),
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
              )
            : showCircularProgress(),
      ),
      onWillPop: () async {
        return true;
      },
    );
  }
}
