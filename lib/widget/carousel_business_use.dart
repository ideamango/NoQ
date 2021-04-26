import 'package:flutter/material.dart';
import '../style.dart';
import '../widget/widgets.dart';

class Item1_login extends StatelessWidget {
  const Item1_login({Key key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Image.asset(
            'assets/bscreen_register.png',
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
            'assets/bscreen_place_list.png',
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
            'assets/bscreen_add_new_place.png',
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
            'assets/bscreen_fill_details_general.png',
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
            'assets/bscreen_fill_details_offer.png',
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
            'assets/bscreen_fill_details_save.png',
            height: MediaQuery.of(context).size.height * .7,
            fit: BoxFit.cover,
          )
        ],
      ),
    );
  }
}

// class Item7_Notifications extends StatelessWidget {
//   const Item7_Notifications({Key key}) : super(key: key);
//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: <Widget>[
//           Image.asset(
//             'assets/screen_notifications.png',
//             height: 140.0,
//             fit: BoxFit.cover,
//           )
//         ],
//       ),
//     );
//   }
// }
