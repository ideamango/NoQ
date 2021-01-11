import 'package:flutter/material.dart';
import 'package:noq/global_state.dart';
import 'package:noq/services/circular_progress.dart';
import 'package:noq/userHomePage.dart';
import 'package:noq/widget/appbar.dart';

class TemplatePage extends StatefulWidget {
  final String entityId;
  TemplatePage({Key key, @required this.entityId}) : super(key: key);
  @override
  _TemplatePageState createState() => _TemplatePageState();
}

class _TemplatePageState extends State<TemplatePage> {
  bool initCompleted = false;
  GlobalState _gs;

  @override
  void initState() {
    super.initState();
    getGlobalState().whenComplete(() {
      if (this.mounted) {
        setState(() {
          initCompleted = true;
        });
      } else
        initCompleted = true;
    });
  }

  Future<void> getGlobalState() async {
    _gs = await GlobalState.getGlobalState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (initCompleted) {
      return MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData.light().copyWith(),
        home: Scaffold(
          appBar: CustomAppBarWithBackButton(
            backRoute: UserHomePage(),
            titleTxt: "New Page Title",
          ),
          body: Center(
            child: Column(children: <Widget>[
              Card(
                child: Text('New Card'),
              ),
            ]),
          ),
        ),
      );
    } else {
      return MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData.light().copyWith(),
        home: new WillPopScope(
          child: Scaffold(
            appBar: CustomAppBarWithBackButton(
              backRoute: UserHomePage(),
              titleTxt: "New Page Title",
            ),
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  showCircularProgress(),
                ],
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
}
