import 'package:flutter/material.dart';
import '../global_state.dart';
import '../services/circular_progress.dart';
import '../userHomePage.dart';
import '../widget/appbar.dart';

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
      return Scaffold(
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
      );
    } else {
      return new WillPopScope(
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
      );
    }
  }
}
