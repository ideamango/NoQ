import 'package:flutter/material.dart';
import 'package:noq/global_state.dart';
import 'package:noq/pages/overview_page.dart';
import 'package:noq/services/circular_progress.dart';
import 'package:noq/userHomePage.dart';
import 'package:noq/utils.dart';
import 'package:noq/widget/appbar.dart';

class ShowApplicationDetails extends StatefulWidget {
  final String entityId;
  ShowApplicationDetails({Key key, @required this.entityId}) : super(key: key);
  @override
  _ShowApplicationDetailsState createState() => _ShowApplicationDetailsState();
}

class _ShowApplicationDetailsState extends State<ShowApplicationDetails> {
  bool initCompleted = false;
  GlobalState _gs;
  List<String> list;

  @override
  void initState() {
    super.initState();
    getGlobalState().whenComplete(() {
      getListOfData();
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

  getListOfData() {
    list = new List<String>();
    return list;
  }

  Widget _emptyPage() {
    return Center(
      child: Container(
        height: MediaQuery.of(context).size.height * .6,
        alignment: Alignment.center,
        child: SingleChildScrollView(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                SizedBox(height: MediaQuery.of(context).size.height * .02),
                Container(
                  color: Colors.transparent,
                  child: Text("No Approved Requests!"),
                  // child: Image(
                  //image: AssetImage('assets/search_home.png'),
                  // )
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  List<Widget> showListOfData() {
    return list.map(_buildItem).toList();
    // return _stores.map((contact) => new ChildItem(contact.name)).toList();
  }

  Widget _buildItem(String str) {
    return Card(
      margin: EdgeInsets.fromLTRB(8, 12, 8, 0),
      elevation: 10,
      child: Column(
        children: <Widget>[
          Text(str),
        ],
      ),
    );
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
            backRoute: OverviewPage(
              entityId: widget.entityId,
            ),
            titleTxt: "Approved Requests",
          ),
          body: Center(
            child: Column(
              children: <Widget>[
                (!Utils.isNullOrEmpty(list))
                    ? Expanded(
                        child: ListView.builder(
                            itemCount: 1,
                            itemBuilder: (BuildContext context, int index) {
                              return Container(
                                margin: EdgeInsets.fromLTRB(10, 0, 10, 50),
                                child: new Column(
                                  children: showListOfData(),
                                ),
                              );
                            }),
                      )
                    : _emptyPage(),
              ],
            ),
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
              titleTxt: "Approved Requests",
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
