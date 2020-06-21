import 'package:flutter/material.dart';
import 'package:noq/login_page.dart';
import 'package:noq/models/localDB.dart';
import 'package:noq/pages/manage_apartment_list_page.dart';
import 'package:noq/pages/manage_apartment_page.dart';
import 'package:noq/pages/showSlotsPage.dart';
import 'package:noq/pages/userAccountPage.dart';
import 'package:noq/pages/userBookingPage.dart';

import 'package:noq/services/authService.dart';
import 'package:noq/style.dart';
import 'package:noq/userHomePage.dart';

Widget userAccountPage(BuildContext context) {
  return UserAccountPage();
}

Widget manageApartmentPages(BuildContext context) {
  return ManageApartmentsListPage();
}

Widget userHomePage(BuildContext context) {
  return UserHomePage();
}

Widget userBookingPage(BuildContext context, UserAppData userProfile) {
  return UserBookingPage();
}

Widget rateAppPage(BuildContext context) {
  Widget _rateAppPage;
  _rateAppPage = Center(
      child: Container(
          margin: EdgeInsets.fromLTRB(10, 10, 10, 10),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text("Rate our app if it bought happiness!!",
                  style: highlightTextStyle),
              Text('Be Safe | Save Time.', style: highlightSubTextStyle),
            ],
          )));
  return _rateAppPage;
}

Widget needHelpPage(BuildContext context) {
  Widget _needHelpPage;
  _needHelpPage = Center(
      child: Container(
          margin: EdgeInsets.fromLTRB(10, 10, 10, 10),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text("We are working on getting best help to you..",
                  style: highlightTextStyle),
              Text('Be Safe | Save Time.', style: highlightSubTextStyle),
            ],
          )));
  return _needHelpPage;
}

Widget shareAppPage(BuildContext context) {
  Widget _shareAppPage;

  // _shareAppPage = Center(
  //     child: Container(
  //         margin: EdgeInsets.fromLTRB(10, 10, 10, 10),
  //         child: Column(
  //           mainAxisAlignment: MainAxisAlignment.center,
  //           children: <Widget>[
  //             Text("Share and spread happiness!!", style: highlightTextStyle),
  //             Text('Be Safe | Save Time.', style: highlightSubTextStyle),
  //           ],
  //         )));
  // return _shareAppPage;

  void _logout() {
    AuthService().signOut(context);
  }
  // AuthService().signOut(context);

  return Container(
      child: RaisedButton(
    color: Colors.grey,
    elevation: 20,
    onPressed: _logout,
    child: Text('Logout', style: buttonMedTextStyle),
  ));
}

Widget slotsPage(BuildContext context) {
  return ShowSlotsPage();
}
