import 'package:flutter/material.dart';
import 'package:noq/global_state.dart';
import 'package:noq/services/auth_service.dart';
import 'package:noq/style.dart';
import 'package:noq/userHomePage.dart';
import 'package:noq/utils.dart';
import 'package:noq/widget/page_animation.dart';
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
            onPressed: () {
              Utils.logout(context);
            })
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
            Navigator.of(context)
                .push(PageAnimation.createRoute(widget.backRoute));
          }),

      actions: <Widget>[
        IconButton(
            icon: Icon(Icons.exit_to_app),
            color: Colors.white,
            onPressed: () {
              Utils.logout(context);
            })
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
