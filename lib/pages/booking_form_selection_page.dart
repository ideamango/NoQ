import 'package:flutter/material.dart';
import 'package:noq/db/db_model/meta_entity.dart';
import 'package:noq/db/db_model/meta_form.dart';
import 'package:noq/global_state.dart';
import 'package:noq/pages/booking_application_form.dart';
import 'package:noq/pages/covid_token_booking_form.dart';
import 'package:noq/pages/manage_entity_list_page.dart';
import 'package:noq/pages/overview_page.dart';
import 'package:noq/pages/search_entity_page.dart';
import 'package:noq/services/circular_progress.dart';
import 'package:noq/services/create_form_fields.dart';
import 'package:noq/style.dart';
import 'package:noq/utils.dart';
import 'package:noq/widget/appbar.dart';
import 'package:noq/widget/header.dart';
import 'package:noq/widget/page_animation.dart';

class BookingFormSelection extends StatefulWidget {
  final MetaEntity metaEntity;
  final List<MetaForm> forms;
  final DateTime preferredSlotTime;
  final dynamic isAdmin;
  final dynamic backRoute;
  BookingFormSelection(
      {Key key,
      @required this.metaEntity,
      @required this.forms,
      @required this.preferredSlotTime,
      @required this.isAdmin,
      @required this.backRoute})
      : super(key: key);

  @override
  _BookingFormSelectionState createState() => _BookingFormSelectionState();
}

class _BookingFormSelectionState extends State<BookingFormSelection> {
  MetaEntity metaEntity;
  List<MetaForm> forms;
  GlobalState _gs;
  bool initCompleted = false;
  int _radioValue1 = -1;
  int _selectedValue = -1;
  int index = 0;
  dynamic fwdRoute;
  @override
  void initState() {
    super.initState();
    // metaEntity = this.widget.metaEntity;
    forms = this.widget.forms;
    getGlobalState().whenComplete(() {
      setState(() {
        initCompleted = true;
      });
    });
  }

  Future<void> getGlobalState() async {
    _gs = await GlobalState.getGlobalState();
  }

  void _handleRadioValueChange1(int value) {
    setState(() {
      _selectedValue = value;
      if (!widget.isAdmin) {
        fwdRoute = CreateFormFields(
          bookingFormId: forms[_selectedValue].id,
          metaEntity: widget.metaEntity,
          preferredSlotTime: widget.preferredSlotTime,
          backRoute: SearchEntityPage(),
        );

        // fwdRoute = BookingApplicationFormPage(
        //   bookingFormId: forms[_selectedValue].id,
        //   metaEntity: widget.metaEntity,
        //   //TODO: getting null check this - SMITA
        //   preferredSlotTime: widget.preferredSlotTime,
        //   backRoute: SearchEntityPage(),
        // );
      } else {
        //If admin then show overview page as per selected form id
        fwdRoute = OverviewPage(
          bookingFormId: forms[_selectedValue].id,
          entityId: widget.metaEntity.entityId,
          metaEntity: widget.metaEntity,
          bookingFormName: forms[_selectedValue].name,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (initCompleted) {
      return MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData.light().copyWith(),
        home: WillPopScope(
          child: Scaffold(
            drawer: CustomDrawer(
              phone: _gs.getCurrentUser().ph,
            ),
            appBar: AppBar(
              // key: _appBarKey,
              title: Text(
                "Booking Application Forms",
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
                    if (widget.backRoute != null)
                      Navigator.of(context)
                          .push(PageAnimation.createRoute(widget.backRoute));
                  }),

              actions: <Widget>[],
              // leading: Builder(
              //   builder: (BuildContext context) {
              //     return IconButton(
              //       color: Colors.white,
              //       icon: Icon(Icons.more_vert),
              //       onPressed: () => Scaffold.of(context).openDrawer(),
              //     );
              //   },
              // ),
            ),
            body: Padding(
              padding: const EdgeInsets.fromLTRB(6, 6, 6, 6),
              child: Container(
                padding: EdgeInsets.all(10),
                child: new Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      "Select the purpose for submitting application request",
                      style: TextStyle(
                        color: Colors.blueGrey[700],
                        fontFamily: 'RalewayRegular',
                        letterSpacing: 0.5,
                        fontSize: 12.0,
                        //height: 2,
                      ),
                    ),
                    Expanded(
                      child: Container(
                        padding: EdgeInsets.only(top: 10),
                        child: ListView.builder(
                            itemCount: forms.length,
                            itemBuilder: (BuildContext context, int index) {
                              return GestureDetector(
                                onTap: () {
                                  _handleRadioValueChange1(index);
                                },
                                child: Container(
                                  color: (_selectedValue == index)
                                      ? Colors.cyan[100]
                                      : Colors.transparent,
                                  //  child: Text("$index"),
                                  child: Row(
                                    children: [
                                      new Radio(
                                        activeColor: (_selectedValue == index)
                                            ? Colors.blueGrey[900]
                                            : Colors.blueGrey[600],
                                        hoverColor: highlightColor,
                                        focusColor: highlightColor,
                                        value: index,
                                        groupValue: _selectedValue,
                                        onChanged: _handleRadioValueChange1,
                                      ),
                                      Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Wrap(children: [
                                            new Text(
                                              forms[index].name,
                                              style: TextStyle(
                                                color: (_selectedValue == index)
                                                    ? Colors.blueGrey[900]
                                                    : Colors.blueGrey[600],
                                                fontWeight: FontWeight.w800,
                                                fontFamily: 'RalewayRegular',
                                                letterSpacing: 0.5,
                                                fontSize: 14.0,
                                                //height: 2,
                                              ),
                                            ),
                                          ]),
                                          forms[index].description != null
                                              ? new Text(
                                                  forms[index].description,
                                                  style: TextStyle(
                                                      fontSize: 10,
                                                      color: (_selectedValue ==
                                                              index)
                                                          ? Colors.indigo
                                                          : Colors
                                                              .blueGrey[600]),
                                                )
                                              : Container(),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            }),
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        FlatButton(
                            child: Icon(
                              Icons.arrow_forward,
                              color: Colors.white,
                            ),
                            color: btnColor,
                            onPressed: () {
                              if (_selectedValue == -1) {
                                print("Nothing selected");
                                Utils.showMyFlushbar(
                                    context,
                                    Icons.error,
                                    Duration(seconds: 5),
                                    "No Form Selected!!",
                                    "Please select something..");
                              } else {
                                if (fwdRoute != null)
                                  Navigator.of(context).push(
                                      PageAnimation.createRoute(fwdRoute));
                              }
                            }),
                      ],
                    )
                  ],
                ),
              ),
            ),
          ),
          onWillPop: () async {
            return true;
          },
        ),
      );
    } else {
      return MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData.light().copyWith(),
        home: WillPopScope(
          child: Scaffold(
            appBar: AppBar(
              actions: <Widget>[],
              flexibleSpace: Container(
                decoration: gradientBackground,
              ),
              leading: IconButton(
                padding: EdgeInsets.all(0),
                alignment: Alignment.center,
                highlightColor: highlightColor,
                icon: Icon(Icons.arrow_back),
                color: Colors.white,
                onPressed: () {
                  print("going back");
                  Navigator.of(context).pop();
                },
              ),
              title: Text("Booking Request Form",
                  style: TextStyle(color: Colors.white, fontSize: 16)),
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
            return true;
          },
        ),
      );
    }
  }
}
