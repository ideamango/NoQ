import 'package:flutter/material.dart';
import '../db/db_model/user_token.dart';
import '../global_state.dart';
import '../repository/local_db_repository.dart';
import '../style.dart';
import '../widget/appbar.dart';
import '../widget/bottom_nav_bar.dart';
import '../widget/header.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserNotificationsPage extends StatefulWidget {
  @override
  _UserNotificationsPageState createState() => _UserNotificationsPageState();
}

class _UserNotificationsPageState extends State<UserNotificationsPage> {
  int? i;
  late List<dynamic> _bookings;
  bool? _notificationsFlg;
  List<String>? _notificationsList;
  GlobalState? _state;
  bool _initCompleted = false;

  @override
  void initState() {
    super.initState();
    getGlobalState().then((value) {
      _loadNotifications();
      _initCompleted = true;
    });
  }

  Future<void> getGlobalState() async {
    _state = await GlobalState.getGlobalState();
  }

  void _loadNotifications() async {
    setState(() {
      //TODO: SMita - no logic for notifications
      _notificationsFlg = (_state!.getConfigurations() != null) ? true : false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_initCompleted) {
      if (_notificationsList != null) {
        return _buildNotificationPage();
      } else {
        return _emptyPage();
      }
    }
    return _emptyPage();
  }

  Widget _emptyPage() {
    String title = "Notifications";
    return WillPopScope(
      child: Scaffold(
        drawer: CustomDrawer(
          phone: _state!.getCurrentUser()!.ph,
        ),
        appBar: CustomAppBar(
          titleTxt: title,
        ),
        body: Center(
          child: Container(
              margin: EdgeInsets.fromLTRB(10, 10, 10, 10),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Text(
                    'No Notifications yet!!',
                    style: highlightTextStyle,
                  ),
                  Text('Be Safe | Save Time.', style: highlightSubTextStyle),
                ],
              )),
        ),
        // bottomNavigationBar: CustomBottomBar(
        //   barIndex: 0,
        // ),
      ),
      onWillPop: () async {
        return true;
      },
    );
  }

  Widget _buildNotificationPage() {
    String title = "My Notifications";
    return Scaffold(
      drawer: CustomDrawer(
        phone: _state!.getCurrentUser()!.ph,
      ),
      appBar: CustomAppBar(
        titleTxt: title,
      ),
      body: Center(
        child: Container(
          margin: EdgeInsets.fromLTRB(10, 10, 10, 10),
          child: ListView.builder(
              itemCount: _bookings.length,
              itemBuilder: (BuildContext context, int index) {
                return Container(
                  child:
                      new Column(children: _bookings.map(_buildItem).toList()),
                  //children: <Widget>[firstRow, secondRow],
                );
              }),
        ),
      ),
      // bottomNavigationBar: CustomBottomBar(
      //   barIndex: 3,
      // ),
    );
  }

  Widget _buildItem(dynamic str) {
    return Card(
        elevation: 10,
        child: new Column(children: <Widget>[
          Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                new Container(
                  padding: EdgeInsets.fromLTRB(10.0, 5.0, 0, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Container(
                        padding: EdgeInsets.fromLTRB(0, 5, 5, 5),
                        child:
                            Column(crossAxisAlignment: CrossAxisAlignment.start,
                                // mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                              Text(
                                  //TODOD : str.storeInfo.name.toString(),
                                  'notifications'),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Text(
                                    str.timing,
                                  ),
                                  Container(
                                    width: 20.0,
                                    height: 20.0,
                                    child: IconButton(
                                      alignment: Alignment.center,
                                      padding: EdgeInsets.all(0),
                                      onPressed: () => {
                                        // launchURL(str.name, str.adrs, str.lat,
                                        //     str.long),
                                      },
                                      highlightColor: Colors.orange[300],
                                      icon: Icon(
                                        Icons.location_on,
                                        color: Colors.blueGrey,
                                      ),
                                    ),
                                  ),
                                ],
                              )
                            ]),
                      ),
                    ],
                  ),
                ),
              ]),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Row(
                children: <Widget>[],
              ),
              Row(
                children: <Widget>[
                  new Container(
                    width: 40.0,
                    height: 20.0,
                    child: MaterialButton(
                      color: Colors.orange,
                      child: Text(
                        "Book Slot",
                        style: new TextStyle(
                            fontFamily: 'Montserrat',
                            letterSpacing: 0.5,
                            color: Colors.white,
                            fontSize: 10),
                      ),
                      onPressed: () => {
                        //onPressed_bookSlotBtn();
                      },
                      highlightColor: Colors.orange[300],
                    ),
                  )
                ],
              ),
            ],
          )
        ]));
  }
}
