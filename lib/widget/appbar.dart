import 'package:flutter/material.dart';

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
  @override
  Widget build(BuildContext context) {
    return AppBar(
      key: _appBarKey,
      title: Text(''),
      backgroundColor: Colors.white,
      //Theme.of(context).primaryColor,
      actions: <Widget>[],
      leading: Builder(
        builder: (BuildContext context) {
          return IconButton(
            color: Colors.teal,
            icon: Icon(Icons.more_vert),
            onPressed: () => Scaffold.of(context).openDrawer(),
          );
        },
      ),
    );
  }
}
