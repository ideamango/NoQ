import 'package:flutter/material.dart';
import 'package:noq/services/authService.dart';
import 'package:noq/style.dart';

class CustomAppBar extends StatefulWidget implements PreferredSizeWidget {
  CustomAppBar({Key key})
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
    AuthService().signOut(context);
  }

  @override
  Widget build(BuildContext context) {
    return AppBar(
      key: _appBarKey,
      title: Text('Awesome NoQ', style: whiteBoldTextStyle1),
      backgroundColor: Colors.teal,
      //Theme.of(context).primaryColor,
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
