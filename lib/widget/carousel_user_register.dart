import 'package:flutter/material.dart';
import 'package:noq/style.dart';
import 'package:noq/widget/video_player_app.dart';
import 'package:noq/widget/widgets.dart';

class Item1_login extends StatelessWidget {
  const Item1_login({Key key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Image.asset(
            'assets/screen_login1.png',
            height: MediaQuery.of(context).size.height * .7,
            fit: BoxFit.cover,
          ),
          verticalSpacer,
          Text(
            "Login with Mobile Number",
            style: homeMsgStyle2,
          ),
        ],
      ),
    );
  }
}

class Item2_login extends StatelessWidget {
  const Item2_login({Key key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Image.asset(
            'assets/screen_login2.png',
            height: MediaQuery.of(context).size.height * .7,
            fit: BoxFit.cover,
          )
        ],
      ),
      // child: Column(
      //   mainAxisAlignment: MainAxisAlignment.center,
      //   children: <Widget>[
      //     Text("Data",
      //         style: TextStyle(
      //             color: Colors.white,
      //             fontSize: 22.0,
      //             fontWeight: FontWeight.bold)),
      //     Text("Data",
      //         style: TextStyle(
      //             color: Colors.white,
      //             fontSize: 17.0,
      //             fontWeight: FontWeight.w600)),
      //   ],
      // ),
    );
  }
}

class Item3_search extends StatelessWidget {
  const Item3_search({Key key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Image.asset(
            'assets/screen_search.png',
            height: MediaQuery.of(context).size.height * .7,
            fit: BoxFit.cover,
          )
        ],
      ),
    );
  }
}

class Item4_ViewLists extends StatelessWidget {
  const Item4_ViewLists({Key key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Image.asset(
            'assets/screen_view_list.png',
            height: MediaQuery.of(context).size.height * .7,
            fit: BoxFit.cover,
          )
        ],
      ),
    );
  }
}

class Item5_BookSlots extends StatelessWidget {
  const Item5_BookSlots({Key key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Image.asset(
            'assets/screen_view_slots.png',
            height: MediaQuery.of(context).size.height * .7,
            fit: BoxFit.cover,
          )
        ],
      ),
    );
  }
}

class Item6_Token extends StatelessWidget {
  const Item6_Token({Key key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Image.asset(
            'assets/screen_token.png',
            height: MediaQuery.of(context).size.height * .7,
            fit: BoxFit.cover,
          )
        ],
      ),
    );
  }
}

class Item7_Done extends StatelessWidget {
  const Item7_Done({Key key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * .7,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          VideoPlayerApp(
              videoNwLink:
                  "https://firebasestorage.googleapis.com/v0/b/awesomenoq.appspot.com/o/animated_login.mp4?alt=media&token=9c640d2a-887c-41fd-9bd4-d288ef1e232d"),
        ],
      ),
    );
  }
}
