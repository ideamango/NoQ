import 'package:flutter/material.dart';
import 'package:noq/global_state.dart';
import 'package:noq/services/authService.dart';
import 'package:noq/style.dart';
import 'package:noq/userHomePage.dart';
import 'package:noq/utils.dart';
import 'package:noq/widget/widgets.dart';

class CustomAppBar extends StatefulWidget implements PreferredSizeWidget {
  final String titleTxt;
  CustomAppBar({Key key, @required this.titleTxt})
      : preferredSize = Size.fromHeight(kToolbarHeight),
        super(key: key);

  @override
  final Size preferredSize; // default is 56.0

  @override
  _CustomAppBarState createState() => _CustomAppBarState();
}

class _CustomAppBarState extends State<CustomAppBar> {
  final GlobalKey _appBarKey = new GlobalKey();
  void _logout() {
    showDialog(
        barrierDismissible: false,
        context: context,
        builder: (_) => AlertDialog(
              titlePadding: EdgeInsets.fromLTRB(10, 15, 10, 10),
              contentPadding: EdgeInsets.all(0),
              actionsPadding: EdgeInsets.all(5),
              //buttonPadding: EdgeInsets.all(0),
              title: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    'Are you sure you want to logout?',
                    style: TextStyle(
                      fontSize: 15,
                      color: Colors.blueGrey[600],
                    ),
                  ),
                  verticalSpacer,
                  // myDivider,
                ],
              ),
              content: Divider(
                color: Colors.blueGrey[400],
                height: 1,
                //indent: 40,
                //endIndent: 30,
              ),

              //content: Text('This is my content'),
              actions: <Widget>[
                SizedBox(
                  height: 24,
                  child: FlatButton(
                    color: Colors.transparent,
                    splashColor: highlightColor.withOpacity(.8),
                    textColor: Colors.orange,
                    shape: RoundedRectangleBorder(
                        side: BorderSide(color: Colors.orange)),
                    child: Text('Yes'),
                    onPressed: () {
                      Utils.showMyFlushbar(
                          context,
                          Icons.info_outline,
                          Duration(
                            seconds: 3,
                          ),
                          "Logging off.. ",
                          "Hope to see you soon!!");
                      Navigator.of(context, rootNavigator: true).pop();
                      Future.delayed(Duration(seconds: 2)).then((value) {
                        AuthService().signOut(context);
                        GlobalState.resetGlobalState();
                      });
                    },
                  ),
                ),
                SizedBox(
                  height: 24,
                  child: FlatButton(
                    // elevation: 20,
                    autofocus: true,
                    focusColor: highlightColor,
                    splashColor: highlightColor,
                    color: Colors.white,
                    textColor: Colors.orange,
                    shape: RoundedRectangleBorder(
                        side: BorderSide(color: Colors.orange)),
                    child: Text('No'),
                    onPressed: () {
                      Navigator.of(context, rootNavigator: true).pop();
                      // Navigator.of(context, rootNavigator: true).pop('dialog');
                    },
                  ),
                ),
              ],
            ));
  }

  @override
  Widget build(BuildContext context) {
    return AppBar(
      key: _appBarKey,
      title: Text(
        widget.titleTxt,
        style: drawerdefaultTextStyle,
        overflow: TextOverflow.ellipsis,
      ),
      flexibleSpace: Container(
        decoration: gradientBackground,
      ),
      actions: <Widget>[
        IconButton(
            icon: Icon(Icons.exit_to_app),
            color: Colors.white,
            onPressed: _logout)
      ],
    );
  }
}

class CustomAppBarWithBackButton extends StatefulWidget
    implements PreferredSizeWidget {
  final String titleTxt;
  final dynamic backRoute;
  CustomAppBarWithBackButton(
      {Key key, @required this.titleTxt, @required this.backRoute})
      : preferredSize = Size.fromHeight(kToolbarHeight),
        super(key: key);

  @override
  final Size preferredSize; // default is 56.0

  @override
  _CustomAppBarWithBackButtonState createState() =>
      _CustomAppBarWithBackButtonState();
}

class _CustomAppBarWithBackButtonState
    extends State<CustomAppBarWithBackButton> {
  final GlobalKey _appBarKey = new GlobalKey();
  void _logout() {
    showDialog(
        barrierDismissible: false,
        context: context,
        builder: (_) => AlertDialog(
              titlePadding: EdgeInsets.fromLTRB(10, 15, 10, 10),
              contentPadding: EdgeInsets.all(0),
              actionsPadding: EdgeInsets.all(5),
              //buttonPadding: EdgeInsets.all(0),
              title: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    'Are you sure you want to logout?',
                    style: TextStyle(
                      fontSize: 15,
                      color: Colors.blueGrey[600],
                    ),
                  ),
                  verticalSpacer,
                  // myDivider,
                ],
              ),
              content: Divider(
                color: Colors.blueGrey[400],
                height: 1,
                //indent: 40,
                //endIndent: 30,
              ),

              //content: Text('This is my content'),
              actions: <Widget>[
                SizedBox(
                  height: 24,
                  child: RaisedButton(
                    elevation: 0,
                    color: Colors.transparent,
                    splashColor: highlightColor.withOpacity(.8),
                    textColor: Colors.orange,
                    shape: RoundedRectangleBorder(
                        side: BorderSide(color: Colors.orange)),
                    child: Text('Yes'),
                    onPressed: () {
                      Navigator.of(context, rootNavigator: true).pop();
                      AuthService().signOut(context);
                    },
                  ),
                ),
                SizedBox(
                  height: 24,
                  child: RaisedButton(
                    elevation: 20,
                    autofocus: true,
                    focusColor: highlightColor,
                    splashColor: highlightColor,
                    color: Colors.white,
                    textColor: Colors.orange,
                    shape: RoundedRectangleBorder(
                        side: BorderSide(color: Colors.orange)),
                    child: Text('No'),
                    onPressed: () {
                      Navigator.of(context, rootNavigator: true).pop();
                      // Navigator.of(context, rootNavigator: true).pop('dialog');
                    },
                  ),
                ),
              ],
            ));
  }

  @override
  Widget build(BuildContext context) {
    return AppBar(
      key: _appBarKey,
      title: Text(
        widget.titleTxt,
        style: TextStyle(color: Colors.white, fontSize: 16),
        overflow: TextOverflow.ellipsis,
      ),
      flexibleSpace: Container(
        decoration: gradientBackground,
      ),
      leading: IconButton(
          padding: EdgeInsets.all(0),
          alignment: Alignment.center,
          highlightColor: Colors.orange[300],
          icon: Icon(Icons.arrow_back),
          color: Colors.white,
          onPressed: () {
            Navigator.of(context).pop();
            Navigator.push(context,
                MaterialPageRoute(builder: (context) => widget.backRoute));
          }),

      actions: <Widget>[
        IconButton(
            icon: Icon(Icons.exit_to_app),
            color: Colors.white,
            onPressed: _logout)
      ],
      // leading: Builder(
      //   builder: (BuildContext context) {
      //     return IconButton(
      //       color: Colors.white,
      //       icon: Icon(Icons.more_vert),
      //       onPressed: () => Scaffold.of(context).openDrawer(),
      //     );
      //   },
      // ),
    );
  }
}
