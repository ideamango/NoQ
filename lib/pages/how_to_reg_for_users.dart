import 'package:flutter/material.dart';
import '../widget/video_player_app.dart';

class HowToRegForUsers extends StatefulWidget {
  @override
  _HowToRegForUsersState createState() => _HowToRegForUsersState();
}

class _HowToRegForUsersState extends State<HowToRegForUsers> {
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
                          'https://firebasestorage.googleapis.com/v0/b/sukoon-india.appspot.com/o/Assets%2Fhow_to_search_forUser.mp4?alt=media&token=b57fcfc9-a3c8-4c0d-8046-87e74ffd8bbe',
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
    );
  }
}
