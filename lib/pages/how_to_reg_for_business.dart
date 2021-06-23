import 'package:flutter/material.dart';
import '../widget/video_player_app.dart';

class HowToRegForBusiness extends StatefulWidget {
  @override
  _HowToRegForBusinessState createState() => _HowToRegForBusinessState();
}

class _HowToRegForBusinessState extends State<HowToRegForBusiness> {
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
                          'https://firebasestorage.googleapis.com/v0/b/awesomenoq.appspot.com/o/search_book.mp4?alt=media&token=168009a3-b6f5-4e7f-86d3-12c5770051c2',
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
