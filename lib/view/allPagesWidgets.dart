import 'package:flutter/material.dart';
import 'package:noq/login_page.dart';
import 'package:noq/models/localDB.dart';
import 'package:noq/services/authService.dart';
import 'package:noq/userHomePage.dart';
import 'package:noq/view/showSlotsPage.dart';
import 'package:noq/view/userBookingPage.dart';
import 'package:noq/view/userFavStoresPage.dart';
import 'package:noq/view/userMyAccountPage.dart';
import 'package:noq/view/userNotificationsPage.dart';

Widget userAccountPage(BuildContext context) {
  Widget _userSettingsPage;
  _userSettingsPage = Container(
      child: Column(children: <Widget>[
    Card(
        child: Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
      Text('Logout'),
      Container(
        width: 40.0,
        height: 20.0,
        child: IconButton(
          //alignment: Alignment.center,
          padding: EdgeInsets.all(0),
          onPressed: () {
            AuthService().signOut(context);
          },
          highlightColor: Colors.orange[300],
          icon: Icon(
            Icons.exit_to_app,
            color: Colors.blueGrey,
          ),
        ),
      ),
    ])),
  ]));
  return _userSettingsPage;
  // return UserMyAccountPage(
  //   storage: Storage(),
  // );
}

Widget userHomePage(BuildContext context) {
  Widget _userAccountPage;
  _userAccountPage = Container(
      child: Column(children: <Widget>[
    Text("Welcome to user Account Page"),
  ]));
  return UserHomePage();
}

Widget userBookingPage(BuildContext context, UserAppData userProfile) {
  return UserBookingPage();
}

// Widget userFavStoresPage(BuildContext context, UserAppData userProfile) {
//   // Widget _userFavStoresPage;
//   // _userFavStoresPage = Container(
//   //     child: Column(children: <Widget>[
//   //   Text("Welcome to user _userFavStoresPage"),
//   //   Text("Welcome to user _userFavStoresPage"),
//   // ]));
//   //return UserFavStoresListPage();
// }

Widget userNotifications(BuildContext context) {
  Widget _userNotifications;
  _userNotifications = Container(
      child: Column(children: <Widget>[
    Text("Welcome to user _userNotifications"),
    Text("Welcome to user _userNotifications"),
  ]));
  return UserNotificationsPage();
}

Widget rateAppPage(BuildContext context) {
  Widget _rateAppPage;
  _rateAppPage = Container(
      child: Column(children: <Widget>[
    Text("Welcome to user rateAppPage"),
    Text("Welcome to user rateAppPage"),
  ]));
  return _rateAppPage;
}

Widget needHelpPage(BuildContext context) {
  Widget _needHelpPage;
  _needHelpPage = Container(
      child: Column(children: <Widget>[
    Text("Welcome to user needHelpPage"),
    Text("Welcome to user needHelpPage"),
  ]));
  return _needHelpPage;
}

Widget shareAppPage(BuildContext context) {
  Widget _shareAppPage;
  _shareAppPage = Container(
      child: Column(children: <Widget>[
    Text("Welcome to user shareAppPage"),
    Text("Welcome to user shareAppPage"),
  ]));
  return _shareAppPage;
}

Widget logoutPage(BuildContext context) {
  // AuthService().signOut(context);

  return null;
}

Widget slotsPage(BuildContext context) {
  return ShowSlotsPage();
}
