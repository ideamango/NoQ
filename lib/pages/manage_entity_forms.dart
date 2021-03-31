import 'package:enum_to_string/enum_to_string.dart';
import 'package:flutter/material.dart';
import 'package:noq/db/db_model/configurations.dart';
import 'package:noq/db/db_model/meta_entity.dart';
import 'package:noq/db/db_model/meta_form.dart';
import 'package:noq/global_state.dart';
import 'package:noq/pages/booking_application_form.dart';
import 'package:noq/pages/covid_token_booking_form.dart';
import 'package:noq/pages/entity_applications_list_page.dart';
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

class ManageEntityForms extends StatefulWidget {
  final MetaEntity metaEntity;
  // final List<MetaForm> forms;
  final DateTime preferredSlotTime;
  final dynamic isAdmin;
  final dynamic backRoute;
  ManageEntityForms(
      {Key key,
      @required this.metaEntity,
      //  @required this.forms,
      @required this.preferredSlotTime,
      @required this.isAdmin,
      @required this.backRoute})
      : super(key: key);

  @override
  _ManageEntityFormsState createState() => _ManageEntityFormsState();
}

class _ManageEntityFormsState extends State<ManageEntityForms> {
  MetaEntity metaEntity;
  List<MetaForm> forms = List<MetaForm>();
  GlobalState _gs;
  bool initCompleted = false;
  int _radioValue1 = -1;
  int _selectedValue = -1;
  int index = 0;
  dynamic dashBoardRoute;
  dynamic reportsRoute;
  List<String> listOfVals = new List<String>();

  List<CheckBoxListTileModel> checkBoxListTileModel;
  @override
  void initState() {
    super.initState();

    // metaEntity = this.widget.metaEntity;

    getGlobalState().whenComplete(() {
      Configurations conf = _gs.getConfigurations();

      // List<String> listOfVals = conf.formToEntityTypeMapping.keys.where(
      //     (k) => conf.formToEntityTypeMapping[k] == widget.metaEntity.entityId);
      //
      conf.formToEntityTypeMapping.forEach((k, v) {
        print(v);
        print(EnumToString.convertToString(widget.metaEntity.type));
        if (v == EnumToString.convertToString(widget.metaEntity.type)) {
          listOfVals.add(k);
        }
      });

      listOfVals.forEach((v) {
        forms.add(conf.formMetaData.firstWhere((element) => element.id == v));
      });
      checkBoxListTileModel = CheckBoxListTileModel.getForms(forms);
      print(forms.length);
      print(listOfVals.length);
      setState(() {
        initCompleted = true;
      });
    });
  }

  Future<void> getGlobalState() async {
    _gs = await GlobalState.getGlobalState();
  }

  void _handleValueChange(int value) {
    setState(() {
      _selectedValue = value;
      if (!widget.isAdmin) {
        dashBoardRoute = CreateFormFields(
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
        reportsRoute = EntityApplicationListPage(
          bookingFormId: forms[_selectedValue].id,
          entityId: widget.metaEntity.entityId,
          metaEntity: widget.metaEntity,
          bookingFormName: forms[_selectedValue].name,
        );
        //If admin then show overview page as per selected form id
        dashBoardRoute = OverviewPage(
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
                "Manage Application Forms",
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
                            itemCount: checkBoxListTileModel.length,
                            itemBuilder: (BuildContext context, int index) {
                              return new Card(
                                child: new Container(
                                  padding: new EdgeInsets.all(10.0),
                                  child: Column(
                                    children: <Widget>[
                                      new CheckboxListTile(
                                          controlAffinity:
                                              ListTileControlAffinity.leading,
                                          activeColor: primaryIcon,
                                          checkColor: primaryAccentColor,
                                          dense: true,
                                          //font change
                                          title: new Text(
                                            checkBoxListTileModel[index]
                                                .formName,
                                            style: TextStyle(
                                                fontSize: 12,
                                                fontWeight: FontWeight.w400,
                                                letterSpacing: 0.5),
                                          ),
                                          value: checkBoxListTileModel[index]
                                              .isCheck,
                                          secondary: (Utils.isNotNullOrEmpty(
                                                  checkBoxListTileModel[index]
                                                      .formDesc)
                                              ? Container(
                                                  height: 50,
                                                  width: 50,
                                                  child: Text(
                                                    checkBoxListTileModel[index]
                                                        .formDesc,
                                                  ),
                                                )
                                              : SizedBox()),
                                          onChanged: (bool val) {
                                            setState(() {
                                              checkBoxListTileModel[index]
                                                  .isCheck = val;
                                            });
                                          })
                                    ],
                                  ),
                                ),
                              );
                            }),
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        if (widget.isAdmin)
                          FlatButton(
                              minWidth: MediaQuery.of(context).size.width * .35,
                              child: Text("Reports"),
                              color: Colors.white,
                              splashColor: highlightColor.withOpacity(.8),
                              shape: RoundedRectangleBorder(
                                  side: BorderSide(color: Colors.blueGrey[500]),
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(5.0))),
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
                                  if (reportsRoute != null)
                                    Navigator.of(context).push(
                                        PageAnimation.createRoute(
                                            reportsRoute));
                                }
                              }),
                        FlatButton(
                            minWidth: MediaQuery.of(context).size.width * .35,
                            child: (widget.isAdmin)
                                ? Text("Dashboard")
                                : Icon(Icons.arrow_forward_ios),
                            color: Colors.transparent,
                            splashColor: Colors.blueGrey[300],
                            shape: RoundedRectangleBorder(
                                side: BorderSide(color: Colors.blueGrey[500]),
                                borderRadius:
                                    BorderRadius.all(Radius.circular(5.0))),
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
                                if (dashBoardRoute != null)
                                  Navigator.of(context).push(
                                      PageAnimation.createRoute(
                                          dashBoardRoute));
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

class CheckBoxListTileModel {
  String formName;
  String formDesc;
  bool isCheck;

  CheckBoxListTileModel({this.formName, this.formDesc, this.isCheck});

  static List<CheckBoxListTileModel> getForms(List<MetaForm> forms) {
    List<CheckBoxListTileModel> list = List<CheckBoxListTileModel>();
    for (var form in forms) {
      list.add(CheckBoxListTileModel(
          formName: form.name, formDesc: form.description, isCheck: false));
    }
    return list;
  }
}
