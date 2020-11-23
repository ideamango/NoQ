import 'package:flutter/material.dart';

class ExplorePageForBusiness extends StatefulWidget {
  //final String forPage;
  //SearchStoresPage({Key key, @required this.forPage}) : super(key: key);
  @override
  _ExplorePageForBusinessState createState() => _ExplorePageForBusinessState();
}

class _ExplorePageForBusinessState extends State<ExplorePageForBusiness> {
  bool initCompleted = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData.light().copyWith(),
      home: WillPopScope(
        child: Scaffold(
          resizeToAvoidBottomInset: false,
          body: Center(
            child: Container(
              margin: EdgeInsets.fromLTRB(
                  10,
                  MediaQuery.of(context).size.width * .5,
                  10,
                  MediaQuery.of(context).size.width * .5),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[Text("Beware Businesses !!!")],
              ),
            ),
          ),
        ),
        onWillPop: () async {
          return true;
        },
      ),
    );
  }
}
