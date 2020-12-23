import 'package:flutter/material.dart';
import 'package:noq/constants.dart';
import 'package:noq/db/db_service/token_service.dart';
import 'package:noq/global_state.dart';
import 'package:noq/services/url_services.dart';
import 'package:noq/style.dart';
import 'package:noq/userHomePage.dart';
import 'package:noq/utils.dart';
import 'package:noq/widget/appbar.dart';
import 'package:noq/widget/header.dart';
import 'package:noq/widget/widgets.dart';
import 'package:url_launcher/url_launcher.dart';

class ManageBookings extends StatefulWidget {
  final String entityId;
  ManageBookings({Key key, @required this.entityId}) : super(key: key);
  @override
  _ManageBookingsState createState() => _ManageBookingsState();
}

class _ManageBookingsState extends State<ManageBookings> {
  TextEditingController _mailController = new TextEditingController();
  TextEditingController _nameController = new TextEditingController();
  TextEditingController _phController = new TextEditingController();
  final GlobalKey<FormFieldState> phnKey = new GlobalKey<FormFieldState>();
  TextEditingController _msgController = new TextEditingController();
  String _reasonType;
  List<String> attachments = [];
  String _mailBody;
  String _altPh;
  String _mailFirstline;
  String _mailSecLine;
  bool _validate = false;
  String _errMsg;
  bool initCompleted = false;
  GlobalState _state;
  DateTime currentDate = DateTime.now();

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
    _state = await GlobalState.getGlobalState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  String validateText(String value) {
    if (value == null || value == "") {
      return 'Please enter your message';
    }
    // _entityDetailsFormKey.currentState.save();
    return null;
  }

  _launchURL(String toMailId, String subject, String body) async {
    var url = 'mailto:$toMailId?subject=$subject&body=$body';
    if (await canLaunch(url)) {
      launch(url).then((value) => Utils.showMyFlushbar(
          context,
          Icons.check,
          Duration(seconds: 5),
          "Your message has been sent.",
          "Our team will contact you as soon as possible."));

      print("Mail sent");
    } else {
      //throw 'Could not launch $url';
      Utils.showMyFlushbar(
          context,
          Icons.check,
          Duration(seconds: 3),
          "Seems to be some problem with internet connection, Please check and try again.",
          "");
    }
  }

  TokenService getTokenService() {
    return TokenService();
  }

  List<String> getData(DateTime dateTime) {
    getTokenService().getEntitySlots(widget.entityId, currentDate);
    return List<String>();
  }

  Widget getCurrentDayBooking() {
    getData(currentDate);
    return Container(child: Text('Date time slots and bookings'));
  }

  Widget getUpcomingBookings() {
    return Container(child: Text('Date time slots and Up bookings'));
  }

  Widget getPastBookings() {
    return Container(child: Text('Date time slots and Past bookings'));
  }

  @override
  Widget build(BuildContext context) {
    if (!initCompleted) {
      return MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData.light().copyWith(),
        home: WillPopScope(
          child: Scaffold(
            appBar: CustomAppBar(
              titleTxt: "Contact Us",
            ),
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  showCircularProgress(),
                ],
              ),
            ),
            //drawer: CustomDrawer(),
            //bottomNavigationBar: CustomBottomBar(barIndex: 0),
          ),
          onWillPop: () async {
            Navigator.push(context,
                MaterialPageRoute(builder: (context) => UserHomePage()));
            return false;
          },
        ),
      );
    } else {
      return MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData.light().copyWith(),
        home: DefaultTabController(
          length: 3,
          child: Scaffold(
            appBar: AppBar(
              bottom: TabBar(
                tabs: [
                  Tab(icon: Icon(Icons.arrow_back_ios), child: Text("Prev")),
                  Tab(icon: Icon(Icons.date_range), child: Text("Today")),
                  Tab(
                      icon: Icon(Icons.arrow_forward_ios_outlined),
                      child: Text("Next")),
                ],
              ),
              title: Text('View Bookings'),
            ),
            body: TabBarView(
              children: [
                getPastBookings(),
                getCurrentDayBooking(),
                getUpcomingBookings(),
              ],
            ),
          ),
        ),
      );
    }
  }

  showCircularProgress() {}
}