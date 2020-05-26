import 'package:flutter/material.dart';
import 'package:noq/models/localDB.dart';

class ChildEntityDetailsPage extends StatefulWidget {
  final EntityAppData entity;
  ChildEntityDetailsPage({Key key, @required this.entity}) : super(key: key);
  @override
  _ChildEntityDetailsPageState createState() => _ChildEntityDetailsPageState();
}

class _ChildEntityDetailsPageState extends State<ChildEntityDetailsPage> {
  @override
  void initState() {
    super.initState();
    print(widget.entity.isFavourite.toString());
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Add child entities',
      //theme: ThemeData.light().copyWith(),
      home: Scaffold(
        appBar: AppBar(title: Text(''), backgroundColor: Colors.teal,
            //Theme.of(context).primaryColor,
            actions: <Widget>[]),
        body: Center(
          child: Text("In center"),
        ),
        // bottomNavigationBar: buildBottomItems()
      ),
    );
  }
}
