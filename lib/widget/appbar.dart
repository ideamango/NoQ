import 'package:flutter/material.dart';

import '../style.dart';

import '../utils.dart';
import '../widget/page_animation.dart';

class CustomAppBar extends StatefulWidget implements PreferredSizeWidget {
  final String titleTxt;
  CustomAppBar({Key? key, required this.titleTxt})
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
        maxLines: 2,
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
  final String? titleTxt;
  final dynamic backRoute;
  CustomAppBarWithBackButton(
      {Key? key, required this.titleTxt, required this.backRoute})
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
        widget.titleTxt!,
        maxLines: 2,
        style: TextStyle(color: Colors.white, fontSize: 15),
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
            if (widget.backRoute != null)
              Navigator.of(context)
                  .push(PageNoAnimation.createRoute(widget.backRoute));
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

class CustomAppBarWithNoAnimationBackButton extends StatefulWidget
    implements PreferredSizeWidget {
  final String titleTxt;
  final dynamic backRoute;
  CustomAppBarWithNoAnimationBackButton(
      {Key? key, required this.titleTxt, required this.backRoute})
      : preferredSize = Size.fromHeight(kToolbarHeight),
        super(key: key);

  @override
  final Size preferredSize; // default is 56.0

  @override
  _CustomAppBarWithNoAnimationBackButtonState createState() =>
      _CustomAppBarWithNoAnimationBackButtonState();
}

class _CustomAppBarWithNoAnimationBackButtonState
    extends State<CustomAppBarWithNoAnimationBackButton> {
  final GlobalKey _appBarKey = new GlobalKey();

  @override
  Widget build(BuildContext context) {
    return AppBar(
      key: _appBarKey,
      title: Text(
        widget.titleTxt,
        maxLines: 2,
        style: TextStyle(color: Colors.white, fontSize: 15),
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
            if (widget.backRoute != null)
              Navigator.of(context)
                  .push(PageReverseAnimation.createRoute(widget.backRoute));
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

class CustomAppBarWithBackFwdButton extends StatefulWidget
    implements PreferredSizeWidget {
  final String titleTxt;
  final dynamic backRoute;
  final dynamic fwdRoute;
  CustomAppBarWithBackFwdButton(
      {Key? key,
      required this.titleTxt,
      required this.backRoute,
      required this.fwdRoute})
      : preferredSize = Size.fromHeight(kToolbarHeight),
        super(key: key);

  @override
  final Size preferredSize; // default is 56.0

  @override
  _CustomAppBarWithBackFwdButtonState createState() =>
      _CustomAppBarWithBackFwdButtonState();
}

class _CustomAppBarWithBackFwdButtonState
    extends State<CustomAppBarWithBackFwdButton> {
  final GlobalKey _appBarKey = new GlobalKey();

  @override
  Widget build(BuildContext context) {
    return AppBar(
      key: _appBarKey,
      title: Text(
        widget.titleTxt,
        maxLines: 2,
        style: TextStyle(color: Colors.white, fontSize: 15),
        overflow: TextOverflow.ellipsis,
      ),
      flexibleSpace: Container(
        decoration: gradientBackground,
      ),
      leading: IconButton(
          padding: EdgeInsets.all(0),
          alignment: Alignment.center,
          highlightColor: Colors.orange[300],
          icon: Icon(Icons.arrow_back_ios),
          color: Colors.white,
          onPressed: () {
            Navigator.of(context).pop();
            if (widget.backRoute != null)
              Navigator.of(context).push(new MaterialPageRoute(
                  builder: (BuildContext context) => widget.backRoute));
          }),

      actions: <Widget>[
        IconButton(
            icon: Icon(Icons.arrow_forward_ios),
            color: Colors.white,
            onPressed: () {
              //Navigator.of(context).pop();
              if (widget.fwdRoute != null)
                Navigator.of(context).push(new MaterialPageRoute(
                    builder: (BuildContext context) => widget.fwdRoute));
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
