import 'package:LESSs/db/db_model/entity.dart';
import 'package:LESSs/widget/widgets.dart';
import 'package:flutter/material.dart';
import '../db/db_model/meta_entity.dart';
import '../db/db_model/meta_form.dart';
import '../global_state.dart';
import '../pages/booking_application_form.dart';
import '../pages/covid_token_booking_form.dart';
import '../pages/entity_applications_list_page.dart';
import '../pages/manage_entity_list_page.dart';
import '../pages/overview_page.dart';
import '../pages/search_entity_page.dart';
import '../services/circular_progress.dart';
import '../services/create_form_fields.dart';
import '../style.dart';
import '../utils.dart';
import '../widget/appbar.dart';
import '../widget/header.dart';
import '../widget/page_animation.dart';

class BookingFormSelection extends StatefulWidget {
  final String entityId;
  final Entity entity;
  final DateTime preferredSlotTime;
  final dynamic isFullAccess;
  final bool forUser;
  final bool isOnlineToken;
  final dynamic backRoute;
  BookingFormSelection(
      {Key key,
      @required this.entityId,
      @required this.entity,
      @required this.preferredSlotTime,
      @required this.isFullAccess,
      @required this.forUser,
      @required this.isOnlineToken,
      @required this.backRoute})
      : super(key: key);

  @override
  _BookingFormSelectionState createState() => _BookingFormSelectionState();
}

class _BookingFormSelectionState extends State<BookingFormSelection> {
  MetaEntity metaEntity;
  Entity entity;
  List<MetaForm> forms;
  GlobalState _gs;
  bool initCompleted = false;
  int _radioValue1 = -1;
  int _selectedValue = -1;
  int index = 0;
  dynamic dashBoardRoute;
  dynamic reportsRoute;
  String errStr;
  @override
  void initState() {
    super.initState();
    // metaEntity = this.widget.metaEntity;

    getGlobalState().whenComplete(() {
      if (widget.entity == null) {
        _gs.getEntity(widget.entityId).then((value) {
          if (value == null) {
            errStr =
                "Oops..There seems to some problem. Please try again later.";
          } else {
            entity = value.item1;
            forms = entity.forms;
          }
          setState(() {
            initCompleted = true;
          });
        });
      } else {
        entity = widget.entity;
        forms = entity.forms;
        setState(() {
          initCompleted = true;
        });
      }
    });
  }

  Future<void> getGlobalState() async {
    _gs = await GlobalState.getGlobalState();
  }

  void _handleRadioValueChange1(int value) {
    setState(() {
      _selectedValue = value;
      if (widget.forUser) {
        dashBoardRoute = CreateFormFields(
          bookingFormId: forms[_selectedValue].id,
          metaEntity: entity.getMetaEntity(),
          preferredSlotTime: widget.preferredSlotTime,
          isOnlineToken: widget.isOnlineToken,
          backRoute: SearchEntityPage(),
        );
      } else {
        reportsRoute = EntityApplicationListPage(
          bookingFormId: forms[_selectedValue].id,
          metaEntity: entity.getMetaEntity(),
          bookingFormName: forms[_selectedValue].name,
          isReadOnly: !widget.isFullAccess,
        );
        //If admin then show overview page as per selected form id
        dashBoardRoute = OverviewPage(
          bookingFormId: forms[_selectedValue].id,
          metaEntity: entity.getMetaEntity(),
          bookingFormName: forms[_selectedValue].name,
          isReadOnly: !widget.isFullAccess,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (initCompleted) {
      return WillPopScope(
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
                    Navigator.of(context).push(new MaterialPageRoute(
                        builder: (BuildContext context) => widget.backRoute));
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
          body: Utils.isStrNullOrEmpty(errStr)
              ? Padding(
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
                                            activeColor:
                                                (_selectedValue == index)
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
                                                    color: (_selectedValue ==
                                                            index)
                                                        ? Colors.blueGrey[900]
                                                        : Colors.blueGrey[600],
                                                    fontWeight: FontWeight.w600,
                                                    fontFamily:
                                                        'RalewayRegular',
                                                    letterSpacing: 0.5,
                                                    fontSize: 14.0,
                                                    //height: 2,
                                                  ),
                                                ),
                                              ]),
                                              Utils.isNotNullOrEmpty(
                                                      forms[index].description)
                                                  ? new Text(
                                                      forms[index].description,
                                                      style: TextStyle(
                                                          fontSize: 10,
                                                          color: (_selectedValue ==
                                                                  index)
                                                              ? Colors.indigo
                                                              : Colors.blueGrey[
                                                                  600]),
                                                    )
                                                  : Container(height: 0),
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
                            // if (!widget.forUser)
                            //   MaterialButton(
                            //       minWidth: MediaQuery.of(context).size.width * .4,
                            //       child: Text("Reports"),
                            //       color: Colors.white,
                            //       splashColor: highlightColor.withOpacity(.8),
                            //       shape: RoundedRectangleBorder(
                            //           side: BorderSide(color: Colors.blueGrey[500]),
                            //           borderRadius:
                            //               BorderRadius.all(Radius.circular(5.0))),
                            //       onPressed: () {
                            //         if (_selectedValue == -1) {
                            //           print("Nothing selected");
                            //           Utils.showMyFlushbar(
                            //               context,
                            //               Icons.error,
                            //               Duration(seconds: 5),
                            //               "No Form Selected!!",
                            //               "Please select something..");
                            //         } else {
                            //           if (reportsRoute != null)
                            //             Navigator.of(context).push(
                            //                 PageAnimation.createRoute(
                            //                     reportsRoute));
                            //         }
                            //       }),
                            SizedBox(
                              width: MediaQuery.of(context).size.width * .11,
                            ),
                            MaterialButton(
                                minWidth:
                                    MediaQuery.of(context).size.width * .4,
                                elevation: _selectedValue != -1 ? 8 : 0,
                                shape: RoundedRectangleBorder(
                                    side: BorderSide(color: btnDisabledolor),
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(5.0))),
                                child: (widget.forUser)
                                    ? Row(
                                        children: [
                                          horizontalSpacer,
                                          Text("Next ",
                                              style: TextStyle(
                                                  fontSize: 18,
                                                  color: _selectedValue != -1
                                                      ? Colors.white
                                                      : headerBarColor)),
                                          horizontalSpacer,
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: <Widget>[
                                              Container(
                                                padding: EdgeInsets.fromLTRB(
                                                    0, 0, 0, 0),
                                                transform:
                                                    Matrix4.translationValues(
                                                        4.0, 0, 0),
                                                child: Icon(
                                                  Icons.arrow_forward_ios,
                                                  color: _selectedValue != -1
                                                      ? Colors.white
                                                      : btnDisabledolor,
                                                  size: 20,
                                                  // color: Colors.white38,
                                                ),
                                              ),
                                              Container(
                                                padding: EdgeInsets.fromLTRB(
                                                    0, 0, 0, 0),
                                                transform:
                                                    Matrix4.translationValues(
                                                        -8.0, 0, 0),
                                                child: Icon(
                                                  Icons.arrow_forward_ios,
                                                  color: _selectedValue != -1
                                                      ? Colors.white
                                                      : headerBarColor,
                                                  size: 22,
                                                  // color: Colors.white,
                                                ),
                                              ),
                                            ],
                                          ),
                                          // Icon(Icons.arrow_forward_ios,
                                          //     size: 20,
                                          //     color: _selectedValue != -1
                                          //         ? Colors.white
                                          //         : btnColor),
                                        ],
                                      )
                                    : Text("Dashboard"),
                                color: _selectedValue != -1
                                    ? btnColor
                                    : Colors.white,
                                splashColor: _selectedValue != -1
                                    ? highlightColor
                                    : btnDisabledolor,
                                onPressed: () {
                                  if (_selectedValue == -1) {
                                    print("Nothing selected");
                                    Utils.showMyFlushbar(
                                        context,
                                        Icons.error,
                                        Duration(seconds: 5),
                                        "Please select the Request Form to view it's details.",
                                        "");
                                  } else {
                                    if (dashBoardRoute != null)
                                      Navigator.of(context).push(
                                          new MaterialPageRoute(
                                              builder: (BuildContext context) =>
                                                  dashBoardRoute));
                                  }
                                }),
                          ],
                        )
                      ],
                    ),
                  ),
                )
              : Center(
                  child: Container(child: Text(errStr)),
                ),
        ),
        onWillPop: () async {
          return true;
        },
      );
    } else {
      return WillPopScope(
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
      );
    }
  }
}
