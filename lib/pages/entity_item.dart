import 'package:flutter/material.dart';
import 'package:noq/constants.dart';
import 'package:noq/db/db_model/entity.dart';
import 'package:noq/db/db_model/meta_entity.dart';
import 'package:noq/db/db_model/meta_form.dart';
import 'package:noq/pages/booking_form_selection_page.dart';
import 'package:noq/pages/business_info_page.dart';
import 'package:noq/pages/entity_token_list_page.dart';
import 'package:noq/pages/manage_employee_page.dart';

import 'package:noq/pages/manage_entity_details_page.dart';
import 'package:noq/pages/manage_entity_forms.dart';
import 'package:noq/pages/manage_entity_list_page.dart';
import 'package:noq/pages/overview_page.dart';
import 'package:noq/services/circular_progress.dart';
import 'package:noq/services/qr_code_generate.dart';
import 'package:noq/style.dart';
import 'package:flutter/foundation.dart';
import 'package:noq/pages/manage_child_entity_list_page.dart';
import 'package:noq/utils.dart';
import 'package:noq/widget/page_animation.dart';
import 'package:noq/widget/widgets.dart';

import '../global_state.dart';

class EntityRow extends StatefulWidget {
  final MetaEntity entity;

  EntityRow({Key key, @required this.entity}) : super(key: key);
  @override
  State<StatefulWidget> createState() => new EntityRowState();
}

class EntityRowState extends State<EntityRow> {
  MetaEntity _metaEntity;
  Entity entity;
  bool getEntityDone = false;

  GlobalState _state;
  bool _initCompleted = false;

  @override
  void initState() {
    super.initState();
    GlobalState.getGlobalState().then((value) {
      _state = value;
      _metaEntity = widget.entity;

      if (this.mounted) {
        setState(() {
          _initCompleted = true;
        });
      } else {
        _initCompleted = false;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    showServiceForm() {
      _state.getEntity(_metaEntity.entityId).then((value) {
        entity = value?.item1;
        if (entity == null) {
          Utils.showMyFlushbar(
              context,
              Icons.info,
              Duration(seconds: 4),
              "Oops! Couldn't fetch details of this entity now. Please try again later.",
              "");
        } else {
          Navigator.of(context).push(PageAnimation.createRoute(
              ManageEntityDetailsPage(entity: entity)));
        }
      });
    }

    generateLinkAndShareWithParams(String entityId, String name) async {
      String msgTitle = entityShareByOwnerHeading + " - " + name;
      String msgBody = entityShareMessage;
      Utils.generateLinkAndShare(entityId, msgTitle, msgBody);
    }

    showChildListPage() {
      _state.getEntity(_metaEntity.entityId, true).then((value) {
        bool isSavedOnServer = false;
        Entity ent;
        if (value != null) {
          isSavedOnServer = value.item2;
          ent = value.item1;
        }

        if (isSavedOnServer) {
          Navigator.of(context).push(PageAnimation.createRoute(
              ManageChildEntityListPage(entity: ent)));
        } else {
          //No entity created yet.. show msg to create entity first.

          Utils.showMyFlushbar(
              context,
              Icons.info_outline,
              Duration(
                seconds: 6,
              ),
              "Important details about your place are missing or unsaved ",
              "Please SAVE before adding child places.");
        }
      });
    }

    share() {
      Entity en;
      _state.getEntity(_metaEntity.entityId, false).then((value) {
        bool isSavedOnServer = true;
        if (value != null) {
          en = value.item1;
          isSavedOnServer = value.item2;
        }

        if (!isSavedOnServer) {
          Utils.showMyFlushbar(
              context,
              Icons.info,
              Duration(seconds: 4),
              "Important details are missing in entity, Please fill those first.",
              "Save Entity and then Share!!");
        } else
          generateLinkAndShareWithParams(
              _metaEntity.entityId, _metaEntity.name);
      });
    }

    shareQr() {
      Entity en;
      _state.getEntity(_metaEntity.entityId, false).then((value) {
        bool isSavedOnServer = true;
        if (value != null) {
          en = value.item1;
          isSavedOnServer = value.item2;
        }

        if (!isSavedOnServer) {
          Utils.showMyFlushbar(
              context,
              Icons.info,
              Duration(seconds: 4),
              "Important details are missing in entity, Please fill those first.",
              "Save Entity and then Share!!");
        } else
          Navigator.of(context).push(PageAnimation.createRoute(GenerateScreen(
            entityId: _metaEntity.entityId,
            entityName: _metaEntity.name,
            backRoute: "EntityList",
          )));
      });
    }

    if (_initCompleted)
      return Card(
        elevation: 5,
        child: Container(
          //height: MediaQuery.of(context).size.height * .3,
          // margin: EdgeInsets.all(5),
          padding: EdgeInsets.all(8),
          decoration: BoxDecoration(
              border: Border.all(color: borderColor),
              color: Colors.white,
              shape: BoxShape.rectangle,
              borderRadius: BorderRadius.all(Radius.circular(5.0))),
          // padding: EdgeInsets.all(5.0),

          child: Column(
            //  mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              // Icon(
              //   Icons.business,
              //   color: primaryIcon,
              // ),
              Row(
                children: <Widget>[
                  GestureDetector(
                    onTap: () {
                      print("Opening manage details on container click");
                      showServiceForm();
                    },
                    child: Container(
                      height: MediaQuery.of(context).size.height * .058,
                      width: MediaQuery.of(context).size.width * .5,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            (_metaEntity?.name != null)
                                ? _metaEntity.name
                                : "Untitled",
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(color: Colors.black, fontSize: 17),
                          ),
                          Text(
                            Utils.getEntityTypeDisplayName(_metaEntity.type),
                            style: labelTextStyle,
                          ),
                        ],
                      ),
                    ),
                  ),
                  Container(
                      padding: EdgeInsets.zero,
                      margin: EdgeInsets.zero,
                      width: MediaQuery.of(context).size.width * .36,
                      height: MediaQuery.of(context).size.height * .058,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: <Widget>[
                          Container(
                            padding: EdgeInsets.all(0),
                            margin: EdgeInsets.all(5),
                            height: 28.0,
                            width: 28.0,
                            child: IconButton(
                                padding: EdgeInsets.fromLTRB(0, 0, 0, 0),
                                alignment: Alignment.center,
                                highlightColor: Colors.orange[300],
                                icon: ImageIcon(
                                  AssetImage('assets/qrcode.png'),
                                  size: 25,
                                  color: primaryIcon,
                                ),
                                onPressed: () {
                                  shareQr();
                                }),
                          ),
                          horizontalSpacer,
                          Container(
                              padding: EdgeInsets.fromLTRB(0, 0, 0, 0),
                              margin: EdgeInsets.fromLTRB(0, 0, 0, 0),
                              height: 25.0,
                              width: 28.0,
                              child: IconButton(
                                padding: EdgeInsets.fromLTRB(0, 0, 0, 0),
                                alignment: Alignment.center,
                                highlightColor: Colors.orange[300],
                                icon: Icon(Icons.share),
                                color: Colors.black,
                                iconSize: 25,
                                onPressed: () {
                                  share();
                                },
                              )),
                        ],
                      )),
                ],
              ),
              SizedBox(
                height: MediaQuery.of(context).size.height * .008,
              ),
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: <
                  Widget>[
                Container(
                  margin: EdgeInsets.all(0),
                  padding: EdgeInsets.all(0),
                  width: MediaQuery.of(context).size.width * .42,
                  height: MediaQuery.of(context).size.height * .05,
                  child: FlatButton(
                    padding: EdgeInsets.all(0),
                    color: Colors.white,
                    textColor: Colors.white,
                    shape: RoundedRectangleBorder(
                        side: BorderSide(color: Colors.blueGrey[300]),
                        borderRadius: BorderRadius.all(Radius.circular(5.0))),
                    splashColor: highlightColor,
                    child: Text(
                      'Manage Details',
                      style: TextStyle(color: whiteBtnTextColor, fontSize: 13),
                    ),
                    // Text(
                    //   (_metaEntity.name != null)
                    //       ? (_metaEntity.name)
                    //       : (_metaEntity.type),
                    //   style: labelTextStyle,
                    // ),

                    //Icon(Icons.arrow_forward),

                    onPressed: () {
                      print("To Add details page");
                      showServiceForm();
                    },
                  ),
                ),
                Container(
                  width: MediaQuery.of(context).size.width * .42,
                  height: MediaQuery.of(context).size.height * .05,
                  child: FlatButton(
                    // elevation: 7,
                    color: Colors.white,
                    splashColor: Utils.isNullOrEmpty(
                            _state.getActiveChildEntityTypes(_metaEntity.type))
                        ? Colors.transparent
                        : highlightColor.withOpacity(.8),
                    shape: RoundedRectangleBorder(
                        side: BorderSide(
                            color: Utils.isNullOrEmpty(
                                    _state.getActiveChildEntityTypes(
                                        _metaEntity.type))
                                ? Colors.blueGrey[100]
                                : Colors.blueGrey[300]),
                        borderRadius: BorderRadius.all(Radius.circular(5.0))),
                    child: Text(
                      'Child Places',
                      style: TextStyle(
                          color: Utils.isNullOrEmpty(_state
                                  .getActiveChildEntityTypes(_metaEntity.type))
                              ? disabledColor
                              : whiteBtnTextColor,
                          fontSize: 13),
                    ),
                    onPressed: () {
                      if (Utils.isNullOrEmpty(
                          _state.getActiveChildEntityTypes(_metaEntity.type)))
                        return;
                      print("To child list page");
                      showChildListPage();
                    },
                  ),
                ),
              ]),
              SizedBox(
                height: MediaQuery.of(context).size.height * .008,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Container(
                    width: MediaQuery.of(context).size.width * .42,
                    height: MediaQuery.of(context).size.height * .05,
                    child: FlatButton(
                      // elevation: 7,
                      color: Colors.white,
                      splashColor: _metaEntity.isBookable
                          ? highlightColor.withOpacity(.8)
                          : Colors.transparent,
                      shape: RoundedRectangleBorder(
                          side: BorderSide(
                              color: _metaEntity.isBookable
                                  ? Colors.blueGrey[300]
                                  : Colors.blueGrey[100]),
                          borderRadius: BorderRadius.all(Radius.circular(5.0))),
                      child: Align(
                        alignment: Alignment.center,
                        child: Text(
                          'Booking Applications',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              color: _metaEntity.isBookable
                                  ? whiteBtnTextColor
                                  : disabledColor,
                              fontSize: 13),
                        ),
                      ),
                      onPressed: () {
                        print("Over To overview page");
                        if (!Utils.isNullOrEmpty(_metaEntity.forms)) {
//TODO: Show popup for differen available forms, admin selects a form then show corresponding overview page
//TODO: Testing code Dummy remove later - Start
                          // MetaForm m1 = new MetaForm(
                          //     description: "Dummy formgfh",
                          //     id: "StrGuid1",
                          //     name: "Dummy Frgghm name");
                          // MetaForm m2 = new MetaForm(
                          //     description: "Dummy fordfgm",
                          //     id: "StrGuid2",
                          //     name: "Dummy Frhgyutym name");
                          // MetaForm m3 = new MetaForm(
                          //     description: "Dummy formdfg",
                          //     id: "StrGuid3",
                          //     name: "Dummy Frm dfgname");
                          // _metaEntity.forms.add(m1);
                          // _metaEntity.forms.add(m2);
                          // _metaEntity.forms.add(m3);
                          //TODO: Testing code Dummy remove later - End
                          if (_metaEntity.forms.length > 1) {
                            Navigator.of(context).push(
                                PageAnimation.createRoute(BookingFormSelection(
                              forms: _metaEntity.forms,
                              metaEntity: _metaEntity,
                              preferredSlotTime: null,
                              isAdmin: true,
                              backRoute: ManageEntityListPage(),
                            )));
                          } else {
                            Navigator.of(context)
                                .push(PageAnimation.createRoute(OverviewPage(
                              bookingFormId: _metaEntity.forms[0].id,
                              bookingFormName: _metaEntity.forms[0].name,
                              entityId: _metaEntity.entityId,
                              metaEntity: _metaEntity,
                            )));
                          }
                        } else {
                          Utils.showMyFlushbar(
                              context,
                              Icons.info_outline,
                              Duration(seconds: 5),
                              "No Bookings found as of now!!",
                              "");
                        }

                        // Navigator.of(context)
                        //     .push(PageAnimation.createRoute(ManageBookings(
                        //   metaEntity: _metaEntity,
                        // )));
                      },
                    ),
                  ),
                  Container(
                    width: MediaQuery.of(context).size.width * .42,
                    height: MediaQuery.of(context).size.height * .05,
                    child: FlatButton(
                      // elevation: 7,
                      color: Colors.white,
                      splashColor: _metaEntity.isBookable
                          ? highlightColor.withOpacity(.8)
                          : Colors.transparent,
                      shape: RoundedRectangleBorder(
                          side: BorderSide(
                              color: _metaEntity.isBookable
                                  ? Colors.blueGrey[300]
                                  : Colors.blueGrey[100]),
                          borderRadius: BorderRadius.all(Radius.circular(5.0))),
                      child: Text(
                        'Booking Tokens',
                        style: TextStyle(
                            color: _metaEntity.isBookable
                                ? whiteBtnTextColor
                                : disabledColor,
                            fontSize: 13),
                      ),
                      onPressed: () {
                        if (_metaEntity.isBookable) {
                          print("To child list page");
                          Navigator.of(context).push(
                              PageAnimation.createRoute(EntityTokenListPage(
                            metaEntity: _metaEntity,
                            backRoute: ManageEntityListPage(),
                            defaultDate: null,
                          )));
                        } else
                          return;
                      },
                    ),
                  ),
                ],
              ),
              SizedBox(
                height: MediaQuery.of(context).size.height * .008,
              ),
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: <
                  Widget>[
                Container(
                  margin: EdgeInsets.all(0),
                  padding: EdgeInsets.all(0),
                  width: MediaQuery.of(context).size.width * .42,
                  height: MediaQuery.of(context).size.height * .05,
                  child: FlatButton(
                    padding: EdgeInsets.all(0),
                    color: Colors.white,
                    textColor: Colors.white,
                    shape: RoundedRectangleBorder(
                        side: BorderSide(
                            color: _metaEntity.isBookable
                                ? Colors.blueGrey[300]
                                : Colors.blueGrey[100]),
                        borderRadius: BorderRadius.all(Radius.circular(5.0))),
                    splashColor: _metaEntity.isBookable
                        ? highlightColor.withOpacity(.8)
                        : Colors.transparent,
                    child: Text(
                      'Manage Forms',
                      style: TextStyle(
                          color: _metaEntity.isBookable
                              ? whiteBtnTextColor
                              : disabledColor,
                          fontSize: 13),
                    ),
                    // Text(
                    //   (_metaEntity.name != null)
                    //       ? (_metaEntity.name)
                    //       : (_metaEntity.type),
                    //   style: labelTextStyle,
                    // ),

                    //Icon(Icons.arrow_forward),

                    onPressed: () {
                      print("To Add details page");
                      Navigator.of(context)
                          .push(PageAnimation.createRoute(ManageEntityForms(
                        // forms: _metaEntity.forms,
                        metaEntity: _metaEntity,
                        preferredSlotTime: null,
                        isAdmin: true,
                        backRoute: ManageEntityListPage(),
                      )));
                    },
                  ),
                ),
                // Container(
                //   width: MediaQuery.of(context).size.width * .42,
                //   height: MediaQuery.of(context).size.height * .05,
                //   child: FlatButton(
                //     // elevation: 7,
                //     color: Colors.white,
                //     splashColor: highlightColor.withOpacity(.8),
                //     shape: RoundedRectangleBorder(
                //         side: BorderSide(color: Colors.blueGrey[500]),
                //         borderRadius: BorderRadius.all(Radius.circular(5.0))),
                //     child: Text(
                //       'Child Places',
                //       style: TextStyle(color: primaryDarkColor, fontSize: 13),
                //     ),
                //     onPressed: () {
                //       print("To child list page");
                //       showChildListPage();
                //     },
                //   ),
                // ),
                Container(
                  width: MediaQuery.of(context).size.width * .42,
                  height: MediaQuery.of(context).size.height * .05,
                  child: FlatButton(
                    // elevation: 7,
                    color: Colors.white,
                    splashColor: highlightColor.withOpacity(.8),
                    shape: RoundedRectangleBorder(
                        side: BorderSide(color: Colors.blueGrey[300]),
                        borderRadius: BorderRadius.all(Radius.circular(5.0))),
                    child: Text(
                      'Manage Employees',
                      style: TextStyle(color: whiteBtnTextColor, fontSize: 13),
                    ),
                    onPressed: () {
                      Navigator.of(context)
                          .push(PageAnimation.createRoute(ManageEmployeePage(
                        metaEntity: _metaEntity,
                        backRoute: ManageEntityListPage(),
                        defaultDate: null,
                      )));
                    },
                  ),
                ),
              ]),

              // backgroundColor: Colors.white,
            ],
          ),
        ),
      );
    else
      return Container(
        margin: EdgeInsets.all(5),
        padding: EdgeInsets.all(8),
        decoration: BoxDecoration(
            border: Border.all(color: borderColor),
            color: Colors.white,
            shape: BoxShape.rectangle,
            borderRadius: BorderRadius.all(Radius.circular(5.0))),
        // padding: EdgeInsets.all(5.0),

        child: showCircularProgress(),
      );
  }
}
