import 'package:LESSs/constants.dart';
import 'package:LESSs/db/db_model/booking_form.dart';
import 'package:LESSs/db/db_service/booking_application_service.dart';
import 'package:auto_size_text/auto_size_text.dart';
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
  final dynamic isFullPermission;
  final dynamic backRoute;
  final bool isReadOnly;
  ManageEntityForms(
      {Key key,
      @required this.metaEntity,
      //  @required this.forms,
      @required this.preferredSlotTime,
      @required this.isFullPermission,
      @required this.backRoute,
      @required this.isReadOnly})
      : super(key: key);

  @override
  _ManageEntityFormsState createState() => _ManageEntityFormsState();
}

class _ManageEntityFormsState extends State<ManageEntityForms> {
  MetaEntity metaEntity;
  List<MetaForm> forms = List<MetaForm>();
  List<MetaForm> selectedForms = [];
  List<BookingForm> newlyAddedForms = [];
  List<String> entityDeletedForms = [];
  List<MetaForm> entityModifiedForms = [];
  GlobalState _gs;
  bool initCompleted = false;
  int _radioValue1 = -1;
  int _selectedValue = -1;
  int index = 0;
  dynamic dashBoardRoute;
  dynamic reportsRoute;
  List<String> listOfVals = [];
  Entity entity;
  List<CheckBoxListTileModel> checkBoxListTileModel;
  bool showLoading = false;
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
        if (!Utils.isNullOrEmpty(entity.forms)) {
          selectedForms.addAll(entity.forms);
        }
        setState(() {
          initCompleted = true;
        });
      });
    });
  }

  Future<void> getGlobalState() async {
    _gs = await GlobalState.getGlobalState();
  }

  // void _handleValueChange(int value) {
  //   setState(() {
  //     _selectedValue = value;
  //     if (!widget.isFullPermission) {
  //       dashBoardRoute = CreateFormFields(
  //         bookingFormId: forms[_selectedValue].id,
  //         metaEntity: widget.metaEntity,
  //         preferredSlotTime: widget.preferredSlotTime,
  //         backRoute: SearchEntityPage(),
  //       );

  //       // fwdRoute = BookingApplicationFormPage(
  //       //   bookingFormId: forms[_selectedValue].id,
  //       //   metaEntity: widget.metaEntity,
  //       //   //TODO: getting null check this - SMITA
  //       //   preferredSlotTime: widget.preferredSlotTime,
  //       //   backRoute: SearchEntityPage(),
  //       // );
  //     } else {
  //       reportsRoute = EntityApplicationListPage(
  //         bookingFormId: forms[_selectedValue].id,
  //         entityId: widget.metaEntity.entityId,
  //         metaEntity: widget.metaEntity,
  //         bookingFormName: forms[_selectedValue].name,
  //       );
  //       //If admin then show overview page as per selected form id
  //       dashBoardRoute = OverviewPage(
  //         bookingFormId: forms[_selectedValue].id,
  //         entityId: widget.metaEntity.entityId,
  //         metaEntity: widget.metaEntity,
  //         bookingFormName: forms[_selectedValue].name,
  //       );
  //     }
  //   });
  // }

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
            child: Stack(
              children: [
                Container(
                  padding: EdgeInsets.all(10),
                  child: new Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      RichText(
                        text: TextSpan(
                          style: TextStyle(
                            color: Colors.blueGrey[700],
                            fontFamily: 'Roboto',
                            letterSpacing: 0.5,
                            fontSize: 12.0,
                          ),
                          children: <TextSpan>[
                            TextSpan(text: "Add from the following "),
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
                                    " which you want to enable for your place. User will be able to select the Form and submit the request after selecting the time-slot."),
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
                                            Container(
                                              margin: EdgeInsets.only(left: 5),
                                              width: MediaQuery.of(context)
                                                      .size
                                                      .width *
                                                  .08,
                                              child: IconButton(
                                                padding: EdgeInsets.zero,
                                                icon: Icon(
                                                  Icons.add_circle,
                                                  color: widget.isReadOnly
                                                      ? Colors.grey[700]
                                                      : Colors.cyan[700],
                                                  size: 30,
                                                ),
                                                onPressed: () {
                                                  if (widget.isReadOnly) {
                                                    Utils.showMyFlushbar(
                                                        context,
                                                        Icons.info,
                                                        Duration(seconds: 3),
                                                        "$noEditPermission Forms",
                                                        "");
                                                    return;
                                                  } else {
                                                    checkBoxListTileModel[index]
                                                        .isCheck = true;

                                                    bool isFormAlreadyAdded =
                                                        false;

                                                    for (MetaForm metaForm
                                                        in selectedForms) {
                                                      String origFormId =
                                                          metaForm.id
                                                              .split('#')[0];
                                                      if (checkBoxListTileModel[
                                                                  index]
                                                              .form
                                                              .id ==
                                                          origFormId) {
                                                        isFormAlreadyAdded =
                                                            true;
                                                      }
                                                    }
                                                    if (isFormAlreadyAdded) {
                                                      Utils.showMyFlushbar(
                                                          context,
                                                          Icons.info,
                                                          Duration(seconds: 3),
                                                          "This Booking Form is already added.",
                                                          "");
                                                    } else {
                                                      _gs
                                                          .getApplicationService()
                                                          .getBookingForm(
                                                              checkBoxListTileModel[
                                                                      index]
                                                                  .form
                                                                  .id)
                                                          .then((value) {
                                                        BookingForm
                                                            bookingForm = value;

                                                        BookingForm cloneForm =
                                                            bookingForm.clone();

                                                        newlyAddedForms
                                                            .add(cloneForm);

                                                        setState(() {
                                                          selectedForms.add(
                                                              cloneForm
                                                                  .getMetaForm());
                                                        });
                                                      });

                                                      // selectedForms.add(
                                                      //     checkBoxListTileModel[
                                                      //             index]
                                                      //         .form);

                                                    }
                                                  }
                                                },
                                              ),
                                            ),
                                            Container(
                                              width: MediaQuery.of(context)
                                                      .size
                                                      .width *
                                                  .68,
                                              child: AutoSizeText(
                                                checkBoxListTileModel[index]
                                                    .form
                                                    .name,
                                                minFontSize: 9,
                                                maxFontSize: 13,
                                                style: TextStyle(
                                                    fontSize: 13,
                                                    fontWeight: FontWeight.w400,
                                                    letterSpacing: 0.5),
                                              ),
                                            ),
                                            Container(
                                              margin: EdgeInsets.only(right: 5),
                                              width: MediaQuery.of(context)
                                                      .size
                                                      .width *
                                                  .08,
                                              child: IconButton(
                                                padding: EdgeInsets.zero,
                                                icon: Icon(
                                                  Icons.preview,
                                                  color: primaryIcon,
                                                ),
                                                onPressed: () {
                                                  Navigator.of(context).push(
                                                      PageAnimation.createRoute(
                                                          EntityForm(
                                                    bookingFormId:
                                                        checkBoxListTileModel[
                                                                index]
                                                            .form
                                                            .id,
                                                    metaEntity:
                                                        widget.metaEntity,
                                                    preferredSlotTime: widget
                                                        .preferredSlotTime,
                                                    backRoute:
                                                        ManageEntityForms(
                                                      isFullPermission: widget
                                                          .isFullPermission,
                                                      metaEntity:
                                                          widget.metaEntity,
                                                      preferredSlotTime: widget
                                                          .preferredSlotTime,
                                                      backRoute:
                                                          widget.backRoute,
                                                      isReadOnly:
                                                          widget.isReadOnly,
                                                    ),
                                                  )));
                                                },
                                              ),
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
                        foregroundDecoration: widget.isReadOnly
                            ? BoxDecoration(
                                color: Colors.grey[50],
                                backgroundBlendMode: BlendMode.saturation,
                              )
                            : BoxDecoration(),
                        decoration: BoxDecoration(
                            color: Colors.cyan[100],
                            border: Border.all(color: Colors.grey[400]),
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
                            borderRadius:
                                BorderRadius.all(Radius.circular(2.0))),
                        child: (!Utils.isNullOrEmpty(selectedForms))
                            ? ListView.builder(

                                // scrollDirection: Axis.horizontal,
                                itemCount: selectedForms.length,
                                itemBuilder: (BuildContext context, int index) {
                                  return new Container(
                                    foregroundDecoration: widget.isReadOnly
                                        ? BoxDecoration(
                                            color: Colors.grey[50],
                                            backgroundBlendMode:
                                                BlendMode.saturation,
                                          )
                                        : BoxDecoration(),
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
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  IconButton(
                                                    alignment:
                                                        Alignment.topCenter,
                                                    icon: Icon(
                                                      Icons.remove_circle,
                                                      color: Colors.cyan[700],
                                                      size: 30,
                                                    ),
                                                    onPressed: () {
                                                      if (widget.isReadOnly) {
                                                        Utils.showMyFlushbar(
                                                            context,
                                                            Icons.info,
                                                            Duration(
                                                                seconds: 3),
                                                            "$noEditPermission Forms",
                                                            "");
                                                        return;
                                                      }

                                                      //If the form being deleted is newly added just delete it
                                                      // else if its old form of entity delete the ref from entity.forms
                                                      int indexToBeRemoved;

                                                      for (int i = 0;
                                                          i <
                                                              newlyAddedForms
                                                                  .length;
                                                          i++) {
                                                        if (newlyAddedForms[i]
                                                                .id ==
                                                            selectedForms[index]
                                                                .id) {
                                                          indexToBeRemoved = i;
                                                          break;
                                                        }
                                                      }

                                                      if (indexToBeRemoved !=
                                                          null)
                                                        newlyAddedForms.removeAt(
                                                            indexToBeRemoved);
                                                      else {
                                                        int indexToBeRemovedForEntityForms;

                                                        for (int i = 0;
                                                            i <
                                                                entity.forms
                                                                    .length;
                                                            i++) {
                                                          if (entity.forms[i]
                                                                  .id ==
                                                              selectedForms[
                                                                      index]
                                                                  .id) {
                                                            indexToBeRemovedForEntityForms =
                                                                i;
                                                            break;
                                                          }
                                                        }

                                                        if (indexToBeRemovedForEntityForms !=
                                                            null) {
                                                          entityDeletedForms
                                                              .add(
                                                                  selectedForms[
                                                                          index]
                                                                      .id);
                                                        }
                                                      }
                                                      selectedForms
                                                          .removeAt(index);

                                                      print(
                                                          selectedForms.length);
                                                      setState(() {});
                                                    },
                                                  ),
                                                  Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Container(
                                                        width: MediaQuery.of(
                                                                    context)
                                                                .size
                                                                .width *
                                                            .74,
                                                        margin:
                                                            EdgeInsets.fromLTRB(
                                                                10, 10, 0, 0),
                                                        child: Text(
                                                          selectedForms[index]
                                                              .name,
                                                          style: TextStyle(
                                                              fontSize: 15,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w400,
                                                              letterSpacing:
                                                                  0.5),
                                                        ),
                                                      ),
                                                      Row(
                                                        children: [
                                                          Checkbox(
                                                            visualDensity:
                                                                VisualDensity
                                                                    .compact,
                                                            value: selectedForms[
                                                                            index]
                                                                        .autoApproved ==
                                                                    null
                                                                ? false
                                                                : selectedForms[
                                                                        index]
                                                                    .autoApproved,
                                                            onChanged: (value) {
                                                              if (widget
                                                                  .isReadOnly) {
                                                                Utils.showMyFlushbar(
                                                                    context,
                                                                    Icons.info,
                                                                    Duration(
                                                                        seconds:
                                                                            4),
                                                                    "Only Admin/Manager can modify the details.",
                                                                    "");
                                                              } else {
//Update entity forms or newlyAddedForms
                                                                bool isFormNew =
                                                                    false;
                                                                for (int i = 0;
                                                                    i <
                                                                        newlyAddedForms
                                                                            .length;
                                                                    i++) {
                                                                  if (newlyAddedForms[
                                                                              i]
                                                                          .id ==
                                                                      selectedForms[
                                                                              index]
                                                                          .id) {
                                                                    newlyAddedForms[i]
                                                                            .autoApproved =
                                                                        value;
                                                                    isFormNew =
                                                                        true;
                                                                    break;
                                                                  }
                                                                }
                                                                if (!isFormNew) {
                                                                  for (var form
                                                                      in entity
                                                                          .forms) {
                                                                    if (form.id ==
                                                                        selectedForms[index]
                                                                            .id) {
                                                                      selectedForms[index]
                                                                              .autoApproved =
                                                                          value;
                                                                      entityModifiedForms.add(
                                                                          selectedForms[
                                                                              index]);
                                                                    }
                                                                  }
                                                                }
                                                                setState(() {
                                                                  selectedForms[
                                                                          index]
                                                                      .autoApproved = value;
                                                                });
                                                              }
                                                            },
                                                            activeColor:
                                                                primaryIcon,
                                                            checkColor:
                                                                primaryAccentColor,
                                                          ),
                                                          Container(
                                                            width: MediaQuery.of(
                                                                        context)
                                                                    .size
                                                                    .width *
                                                                .66,
                                                            child: Text(
                                                              "Automatically issue Token when user submits the request.",
                                                              style: TextStyle(
                                                                  fontSize: 11),
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ],
                                                  ),
                                                ],
                                              ),
                                              //TODO Phase2 - dont delete
//                                             IconButton(
//                                               icon: Icon(
//                                                 Icons.preview,
//                                                 color: primaryIcon,
//                                               ),
//                                               onPressed: () {
// //Open the form in edit mode

//                                                 Navigator.of(context).push(
//                                                     PageAnimation.createRoute(
//                                                         EntityForm(
//                                                   bookingFormId:
//                                                       selectedForms[index].id,
//                                                   metaEntity: widget.metaEntity,
//                                                   preferredSlotTime:
//                                                       widget.preferredSlotTime,
//                                                   backRoute: ManageEntityForms(
//                                                     isAdmin: widget.isAdmin,
//                                                     metaEntity:
//                                                         widget.metaEntity,
//                                                     preferredSlotTime: widget
//                                                         .preferredSlotTime,
//                                                     backRoute: widget.backRoute,
//                                                     isManager: widget.isManager,
//                                                   ),
//                                                 )));
//                                               },
//                                             ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                })
                            : Container(
                                width: MediaQuery.of(context).size.width * .9,
                                alignment: Alignment.center,
                                child: Text(
                                  "No Forms added for your place!",
                                  style: TextStyle(
                                      color: Colors.black,
                                      fontSize: 14,
                                      fontFamily: 'RalewayRegular',
                                      fontWeight: FontWeight.bold),
                                )),
                      )),
                      Container(
                        foregroundDecoration: widget.isReadOnly
                            ? BoxDecoration(
                                color: Colors.grey[50],
                                backgroundBlendMode: BlendMode.saturation,
                              )
                            : BoxDecoration(),
                        width: MediaQuery.of(context).size.width * .92,
                        child: MaterialButton(
                            color: btnColor,
                            elevation: 5,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  "Save Changes ",
                                  style: btnTextStyle,
                                ),
                                SizedBox(
                                  width: 5,
                                ),
                                Icon(
                                  Icons.save,
                                  color: Colors.white,
                                )
                              ],
                            ),
                            splashColor: highlightColor,
                            shape: RoundedRectangleBorder(
                                side: BorderSide(color: Colors.blueGrey[500]),
                                borderRadius:
                                    BorderRadius.all(Radius.circular(5.0))),
                            onPressed: () async {
                              //Save Entity with updated changes.
                              if (widget.isReadOnly) {
                                Utils.showMyFlushbar(
                                    context,
                                    Icons.info,
                                    Duration(seconds: 3),
                                    "$noEditPermission Forms",
                                    "");
                                return;
                              } else {
                                setState(() {
                                  showLoading = true;
                                });

                                if (entity.forms == null) entity.forms = [];
                                bool entityModified = false;
                                //If all pre existing forms for entity are deleted.
                                if (Utils.isNullOrEmpty(selectedForms) &&
                                    (!Utils.isNullOrEmpty(entity.forms))) {
                                  entity.forms.clear();
                                  _gs.putEntity(entity, true).then((value) {
                                    Utils.showMyFlushbar(
                                        context,
                                        Icons.check,
                                        Duration(seconds: 3),
                                        "Saved Application Form Successfully!",
                                        "",
                                        successGreenSnackBar);
                                    setState(() {
                                      showLoading = false;
                                    });

                                    // Navigator.of(context).pop();
                                    Future.delayed(Duration(seconds: 2))
                                        .then((value) {
                                      if (widget.backRoute != null)
                                        Navigator.of(context).push(
                                            PageAnimation.createRoute(
                                                widget.backRoute));
                                    });
                                  });
                                } else {
                                  //Check if any existing forms in entity are modified
                                  for (int i = 0;
                                      i < entityModifiedForms.length;
                                      i++) {
                                    for (int j = 0;
                                        j < entity.forms.length;
                                        j++) {
                                      if (entity.forms[j].id ==
                                          entityModifiedForms[i].id) {
                                        entity.forms[j].autoApproved =
                                            entityModifiedForms[i].autoApproved;
                                        entityModified = true;
                                        BookingForm bf = await _gs
                                            .getApplicationService()
                                            .getBookingForm(entity.forms[j].id);
                                        bf.autoApproved =
                                            entityModifiedForms[i].autoApproved;
                                        bool isFormSaved = await _gs
                                            .getApplicationService()
                                            .saveBookingForm(bf);

                                        if (!isFormSaved) {
                                          Utils.showMyFlushbar(
                                              context,
                                              Icons.info,
                                              Duration(seconds: 5),
                                              "Oho..Could not save the Application Form changes.",
                                              "Please try again.");
                                          setState(() {
                                            showLoading = false;
                                          });
                                        }
                                      }
                                    }

                                    entityModified = true;
                                  }
                                  //Check if any existing forms in entity are deleted
                                  if (!Utils.isNullOrEmpty(
                                      entityDeletedForms)) {
                                    for (int i = 0;
                                        i < entityDeletedForms.length;
                                        i++) {
                                      entity.forms.removeWhere((element) =>
                                          element.id == entityDeletedForms[i]);
                                      entityModified = true;
                                    }
                                  }
                                  if (!Utils.isNullOrEmpty(
                                      entityModifiedForms)) {
                                    for (int i = 0;
                                        i < entityModifiedForms.length;
                                        i++) {
                                      for (var form in entity.forms) {
                                        if (form.id ==
                                            entityModifiedForms[i].id) {
                                          form.autoApproved =
                                              entityModifiedForms[i]
                                                  .autoApproved;
                                        }
                                      }

                                      entityModified = true;
                                    }
                                  }

                                  //Check if any newly added forms are there
                                  if (!Utils.isNullOrEmpty(newlyAddedForms)) {
                                    for (int i = 0;
                                        i < newlyAddedForms.length;
                                        i++) {
                                      bool isFormSaved = await _gs
                                          .getApplicationService()
                                          .saveBookingForm(newlyAddedForms[i]);

                                      if (isFormSaved) {
                                        entity.forms.add(
                                            newlyAddedForms[i].getMetaForm());
                                        entityModified = true;
                                      } else {
                                        Utils.showMyFlushbar(
                                            context,
                                            Icons.info,
                                            Duration(seconds: 5),
                                            "Oho..Could not add the Application Form.",
                                            "Please try again.");
                                        setState(() {
                                          showLoading = false;
                                        });
                                      }
                                    }
                                  }
                                }
                                //SAVE Entity
                                if (entityModified) {
                                  _gs.putEntity(entity, true).then((value) {
                                    Utils.showMyFlushbar(
                                        context,
                                        Icons.check,
                                        Duration(seconds: 2),
                                        "Saved Application Forms.",
                                        "",
                                        successGreenSnackBar,
                                        Colors.white,
                                        true);
                                    setState(() {
                                      showLoading = false;
                                    });
                                    Future.delayed(Duration(seconds: 2))
                                        .then((value) {
                                      // Navigator.of(context).pop();
                                      if (widget.backRoute != null)
                                        Navigator.of(context).push(
                                            PageAnimation.createRoute(
                                                widget.backRoute));
                                    });
                                  });
                                } else {
                                  setState(() {
                                    showLoading = false;
                                  });
                                }
                              }
                            }),
                      )
                    ],
                  ),
                ),
                if (showLoading)
                  Center(
                    child: Padding(
                      padding: EdgeInsets.only(top: 10.0, bottom: 10),
                      child: Container(
                        width: MediaQuery.of(context).size.width,
                        height: MediaQuery.of(context).size.height,
                        color: Colors.black.withOpacity(.5),
                        // decoration: BoxDecoration(
                        //   color: Colors.white,
                        //   backgroundBlendMode: BlendMode.saturation,
                        // ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Container(
                              color: Colors.transparent,
                              padding: EdgeInsets.all(12),
                              width: MediaQuery.of(context).size.width * .15,
                              height: MediaQuery.of(context).size.width * .15,
                              child: CircularProgressIndicator(
                                backgroundColor: Colors.black,
                                valueColor:
                                    AlwaysStoppedAnimation<Color>(Colors.white),
                                strokeWidth: 2,
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                  )
              ],
            ),
          ),
        ),
        onWillPop: () async {
          Navigator.of(context).pop();
          if (widget.backRoute != null)
            Navigator.of(context)
                .push(PageAnimation.createRoute(widget.backRoute));
          return false;
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
          print("going back");
          Navigator.of(context).pop();
          return false;
        },
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
