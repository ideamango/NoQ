import 'package:enum_to_string/enum_to_string.dart';
import 'package:flutter/material.dart';
import '../db/db_model/configurations.dart';
import '../db/db_model/entity.dart';
import '../db/db_model/meta_entity.dart';
import '../db/db_model/meta_form.dart';
import '../global_state.dart';
import '../pages/booking_application_form.dart';
import '../pages/covid_token_booking_form.dart';
import '../pages/entity_applications_list_page.dart';
import '../pages/manage_entity_list_page.dart';
import '../pages/overview_page.dart';
import '../pages/search_entity_page.dart';
import '../repository/StoreRepository.dart';
import '../services/circular_progress.dart';
import '../services/create_form_fields.dart';
import '../services/show_form.dart';
import '../style.dart';
import '../utils.dart';
import '../widget/appbar.dart';
import '../widget/header.dart';
import '../widget/page_animation.dart';

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
  List<MetaForm> selectedForms = List<MetaForm>();
  GlobalState _gs;
  bool initCompleted = false;
  int _radioValue1 = -1;
  int _selectedValue = -1;
  int index = 0;
  dynamic dashBoardRoute;
  dynamic reportsRoute;
  List<String> listOfVals = new List<String>();
  Entity entity;
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

      _gs.getEntity(widget.metaEntity.entityId).then((value) {
        entity = value.item1;
        selectedForms.addAll(entity.forms);
        setState(() {
          initCompleted = true;
        });
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
                    RichText(
                      text: TextSpan(
                        style: TextStyle(
                          color: Colors.blueGrey[700],
                          fontFamily: 'RalewayRegular',
                          letterSpacing: 0.5,
                          fontSize: 12.0,
                        ),
                        children: <TextSpan>[
                          TextSpan(text: "Add from these "),
                          TextSpan(
                            text: 'Sample Application Forms',
                            style: new TextStyle(
                                color: Colors.blueGrey[900],
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                decorationColor: primaryDarkColor),
                          ),
                          TextSpan(
                              text:
                                  " which are required to request booking of token and submitting applications by the user."),
                        ],
                      ),
                    ),
                    Expanded(
                      child: (!Utils.isNullOrEmpty(checkBoxListTileModel))
                          ? ListView.builder(
                              // scrollDirection: Axis.horizontal,
                              itemCount: checkBoxListTileModel.length,
                              itemBuilder: (BuildContext context, int index) {
                                return new Card(
                                  elevation: 2,
                                  color: Colors.cyan[100],
                                  margin: new EdgeInsets.fromLTRB(0, 5, 0, 5),
                                  child: Column(
                                    children: <Widget>[
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Row(
                                            children: [
                                              IconButton(
                                                icon: Icon(
                                                  Icons.add_circle,
                                                  color: Colors.cyan[700],
                                                  size: 30,
                                                ),
                                                onPressed: () {
                                                  checkBoxListTileModel[index]
                                                      .isCheck = true;

                                                  selectedForms.add(
                                                      checkBoxListTileModel[
                                                              index]
                                                          .form);

                                                  setState(() {});
                                                },
                                              ),
                                              Text(
                                                checkBoxListTileModel[index]
                                                    .form
                                                    .name,
                                                style: TextStyle(
                                                    fontSize: 13,
                                                    fontWeight: FontWeight.w400,
                                                    letterSpacing: 0.5),
                                              ),
                                            ],
                                          ),
                                          IconButton(
                                            icon: Icon(
                                              Icons.preview,
                                              color: primaryIcon,
                                            ),
                                            onPressed: () {
                                              Navigator.of(context).push(
                                                  PageAnimation.createRoute(
                                                      EntityForm(
                                                bookingFormId:
                                                    checkBoxListTileModel[index]
                                                        .form
                                                        .id,
                                                metaEntity: widget.metaEntity,
                                                preferredSlotTime:
                                                    widget.preferredSlotTime,
                                                backRoute: ManageEntityForms(
                                                  isAdmin: widget.isAdmin,
                                                  metaEntity: widget.metaEntity,
                                                  preferredSlotTime:
                                                      widget.preferredSlotTime,
                                                  backRoute: widget.backRoute,
                                                ),
                                              )));
                                            },
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                );
                              })
                          : Container(
                              alignment: Alignment.center,
                              child: Text(
                                "No Application Templates.!!",
                                style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 14,
                                    fontFamily: 'RalewayRegular',
                                    fontWeight: FontWeight.bold),
                              )),
                    ),
                    Container(
                      // color: Colors.blue,
                      decoration: BoxDecoration(
                          color: Colors.cyan[100],
                          border: Border.all(color: Colors.grey[400]),
                          // border: Border(
                          //   top: BorderSide(width: 3.0, color: Colors.amber),
                          //   bottom:
                          //       BorderSide(width: 16.0, color: Colors.amber),
                          // ),
                          borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(4.0),
                              topRight: Radius.circular(4.0))),
                      width: MediaQuery.of(context).size.width * .92,
                      padding: EdgeInsets.all(8),
                      child: RichText(
                        text: TextSpan(
                          style: TextStyle(
                            color: Colors.blueGrey[700],
                            fontFamily: 'RalewayRegular',
                            letterSpacing: 0.5,
                            fontSize: 12.0,
                          ),
                          children: <TextSpan>[
                            TextSpan(
                              text: 'Application forms added',
                              style: new TextStyle(
                                  color: Colors.blueGrey[900],
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                  decorationColor: primaryDarkColor),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Expanded(
                        child: Container(
                      width: MediaQuery.of(context).size.width * .92,
                      decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey[400]),
                          color: Colors.white,
                          shape: BoxShape.rectangle,
                          borderRadius: BorderRadius.all(Radius.circular(2.0))),
                      child: (!Utils.isNullOrEmpty(selectedForms))
                          ? ListView.builder(

                              // scrollDirection: Axis.horizontal,
                              itemCount: selectedForms.length,
                              itemBuilder: (BuildContext context, int index) {
                                return new Container(
                                  padding: EdgeInsets.zero,
                                  margin: EdgeInsets.zero,
                                  child: Column(
                                    children: <Widget>[
                                      Container(
                                        padding:
                                            EdgeInsets.fromLTRB(0, 0, 0, 0),
                                        margin: EdgeInsets.zero,
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Row(
                                              children: [
                                                IconButton(
                                                  icon: Icon(
                                                    Icons.remove_circle,
                                                    color: Colors.cyan[700],
                                                    size: 30,
                                                  ),
                                                  onPressed: () {
                                                    selectedForms
                                                        .removeAt(index);
                                                    print(selectedForms.length);
                                                    setState(() {});
                                                  },
                                                ),
                                                Text(
                                                  selectedForms[index].name,
                                                  style: TextStyle(
                                                      fontSize: 13,
                                                      fontWeight:
                                                          FontWeight.w400,
                                                      letterSpacing: 0.5),
                                                ),
                                              ],
                                            ),
                                            IconButton(
                                              icon: Icon(
                                                Icons.preview,
                                                color: primaryIcon,
                                              ),
                                              onPressed: () {
//Open the form in edit mode

                                                Navigator.of(context).push(
                                                    PageAnimation.createRoute(
                                                        EntityForm(
                                                  bookingFormId:
                                                      selectedForms[index].id,
                                                  metaEntity: widget.metaEntity,
                                                  preferredSlotTime:
                                                      widget.preferredSlotTime,
                                                  backRoute: ManageEntityForms(
                                                    isAdmin: widget.isAdmin,
                                                    metaEntity:
                                                        widget.metaEntity,
                                                    preferredSlotTime: widget
                                                        .preferredSlotTime,
                                                    backRoute: widget.backRoute,
                                                  ),
                                                )));
                                              },
                                            ),
                                          ],
                                        ),
                                      )
                                    ],
                                  ),
                                );
                              })
                          : Container(
                              width: MediaQuery.of(context).size.width * .9,
                              alignment: Alignment.center,
                              child: Text(
                                "No forms selected yet!!",
                                style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 14,
                                    fontFamily: 'RalewayRegular',
                                    fontWeight: FontWeight.bold),
                              )),
                    )),
                    Container(
                      width: MediaQuery.of(context).size.width * .92,
                      child: RaisedButton(
                          color: btnColor,
                          elevation: 5,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                "Save Changes ",
                                style: TextStyle(fontSize: 17),
                              ),
                              SizedBox(
                                width: 5,
                              ),
                              Icon(Icons.save)
                            ],
                          ),
                          splashColor: highlightColor,
                          shape: RoundedRectangleBorder(
                              side: BorderSide(color: Colors.blueGrey[500]),
                              borderRadius:
                                  BorderRadius.all(Radius.circular(5.0))),
                          onPressed: () {
                            //Save Entity with updated changes.

                            entity.forms.clear();
                            entity.forms.addAll(selectedForms);
                            _gs.putEntity(entity, true);
                          }),
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
  MetaForm form;

  bool isCheck;

  CheckBoxListTileModel({this.form, this.isCheck});

  static List<CheckBoxListTileModel> getForms(List<MetaForm> forms) {
    List<CheckBoxListTileModel> list = List<CheckBoxListTileModel>();
    for (var form in forms) {
      list.add(CheckBoxListTileModel(form: form, isCheck: false));
    }
    return list;
  }
}
