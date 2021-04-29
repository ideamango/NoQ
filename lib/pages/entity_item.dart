import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import '../constants.dart';
import '../db/db_model/entity.dart';
import '../db/db_model/meta_entity.dart';
import '../db/db_model/meta_form.dart';
import '../pages/booking_form_selection_page.dart';
import '../pages/business_info_page.dart';
import '../pages/entity_token_list_page.dart';
import '../pages/manage_employee_page.dart';

import '../pages/manage_entity_details_page.dart';
import '../pages/manage_entity_forms.dart';
import '../pages/manage_entity_list_page.dart';
import '../pages/overview_page.dart';
import '../services/circular_progress.dart';
import '../services/qr_code_generate.dart';
import '../style.dart';
import 'package:flutter/foundation.dart';
import '../pages/manage_child_entity_list_page.dart';
import '../utils.dart';
import '../widget/page_animation.dart';
import '../widget/widgets.dart';

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

    var labelGroup = AutoSizeGroup();
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
                            style: TextStyle(
                                color: Colors.black,
                                fontSize: 18,
                                fontFamily: 'RalewayRegular'),
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
                SizedBox(
                  width: MediaQuery.of(context).size.width * .04,
                ),
                Card(
                  elevation: 10,
                  child: GestureDetector(
                    onTap: () {
                      showServiceForm();
                    },
                    child: Container(
                      margin: EdgeInsets.all(0),
                      padding: EdgeInsets.all(0),
                      width: MediaQuery.of(context).size.width * .21,
                      height: MediaQuery.of(context).size.width * .21,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          SizedBox(
                            width: MediaQuery.of(context).size.width * .11,
                            height: MediaQuery.of(context).size.width * .11,
                            child: Image(
                              image: AssetImage('assets/settings.png'),
                            ),
                          ),
                          AutoSizeText(
                            'Details',
                            group: labelGroup,
                            maxLines: 1,
                            minFontSize: 9,
                            maxFontSize: 11,
                            style: TextStyle(
                                letterSpacing: 1.1,
                                color: whiteBtnTextColor,
                                fontSize: 12,
                                fontFamily: 'Roboto'),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  width: MediaQuery.of(context).size.width * .04,
                ),
                Card(
                  elevation: 10,
                  child: GestureDetector(
                    onTap: () {
                      if (Utils.isNullOrEmpty(
                          _state.getActiveChildEntityTypes(_metaEntity.type)))
                        return;
                      print("To child list page");
                      showChildListPage();
                    },
                    child: Container(
                      margin: EdgeInsets.all(0),
                      padding: EdgeInsets.all(0),
                      width: MediaQuery.of(context).size.width * .21,
                      height: MediaQuery.of(context).size.width * .21,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          SizedBox(
                            width: MediaQuery.of(context).size.width * .11,
                            height: MediaQuery.of(context).size.width * .11,
                            child: Image(
                              image: AssetImage('assets/places.png'),
                            ),
                          ),
                          AutoSizeText(
                            'Places',
                            group: labelGroup,
                            maxLines: 1,
                            minFontSize: 9,
                            maxFontSize: 11,
                            style: TextStyle(
                                letterSpacing: 1.1,
                                color: Utils.isNullOrEmpty(
                                        _state.getActiveChildEntityTypes(
                                            _metaEntity.type))
                                    ? disabledColor
                                    : whiteBtnTextColor,
                                fontFamily: 'Roboto'),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  width: MediaQuery.of(context).size.width * .04,
                ),
                Card(
                  elevation: 8,
                  child: GestureDetector(
                    onTap: () {
                      Navigator.of(context)
                          .push(PageAnimation.createRoute(ManageEmployeePage(
                        metaEntity: _metaEntity,
                        backRoute: ManageEntityListPage(),
                        defaultDate: null,
                      )));
                    },
                    child: Container(
                      margin: EdgeInsets.all(0),
                      padding: EdgeInsets.all(0),
                      width: MediaQuery.of(context).size.width * .21,
                      height: MediaQuery.of(context).size.width * .21,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          SizedBox(
                            width: MediaQuery.of(context).size.width * .11,
                            height: MediaQuery.of(context).size.width * .11,
                            child: Image(
                              image: AssetImage('assets/employee.png'),
                            ),
                          ),
                          AutoSizeText(
                            'Employees',
                            group: labelGroup,
                            maxLines: 1,
                            minFontSize: 9,
                            maxFontSize: 11,
                            style: TextStyle(
                                letterSpacing: 1.1,
                                color: whiteBtnTextColor,
                                fontFamily: 'Roboto'),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  width: MediaQuery.of(context).size.width * .04,
                ),
              ]),
              SizedBox(
                height: MediaQuery.of(context).size.height * .008,
              ),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  SizedBox(
                    width: MediaQuery.of(context).size.width * .04,
                  ),
                  Card(
                    elevation: 10,
                    child: GestureDetector(
                      onTap: () {
                        print("Over To overview page");
                        if (!Utils.isNullOrEmpty(_metaEntity.forms)) {
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
                      child: Container(
                        margin: EdgeInsets.all(0),
                        padding: EdgeInsets.all(0),
                        width: MediaQuery.of(context).size.width * .21,
                        height: MediaQuery.of(context).size.width * .21,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            SizedBox(
                              width: MediaQuery.of(context).size.width * .11,
                              height: MediaQuery.of(context).size.width * .11,
                              child: Image(
                                image: AssetImage('assets/applications.png'),
                              ),
                            ),
                            AutoSizeText(
                              'Applications',
                              group: labelGroup,
                              maxLines: 1,
                              minFontSize: 9,
                              maxFontSize: 11,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  letterSpacing: 1.1,
                                  color: _metaEntity.isBookable
                                      ? whiteBtnTextColor
                                      : disabledColor,
                                  fontFamily: 'Roboto'),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    width: MediaQuery.of(context).size.width * .04,
                  ),
                  Card(
                    elevation: 10,
                    child: GestureDetector(
                      onTap: () {
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
                      child: Container(
                        margin: EdgeInsets.all(0),
                        padding: EdgeInsets.all(2),
                        width: MediaQuery.of(context).size.width * .21,
                        height: MediaQuery.of(context).size.width * .21,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            SizedBox(
                              width: MediaQuery.of(context).size.width * .11,
                              height: MediaQuery.of(context).size.width * .11,
                              child: Image(
                                image: AssetImage('assets/tokens.png'),
                              ),
                            ),
                            AutoSizeText(
                              'Tokens',
                              group: labelGroup,
                              maxLines: 1,
                              minFontSize: 9,
                              maxFontSize: 11,
                              style: TextStyle(
                                  letterSpacing: 1.1,
                                  color: _metaEntity.isBookable
                                      ? whiteBtnTextColor
                                      : disabledColor,
                                  fontFamily: 'Roboto'),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    width: MediaQuery.of(context).size.width * .04,
                  ),
                  Card(
                    elevation: 10,
                    child: GestureDetector(
                      onTap: () {
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
                      child: Container(
                        margin: EdgeInsets.all(0),
                        padding: EdgeInsets.all(0),
                        width: MediaQuery.of(context).size.width * .21,
                        height: MediaQuery.of(context).size.width * .21,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            SizedBox(
                              width: MediaQuery.of(context).size.width * .11,
                              height: MediaQuery.of(context).size.width * .11,
                              child: Image(
                                image: AssetImage('assets/forms.png'),
                              ),
                            ),
                            AutoSizeText(
                              'Forms',
                              group: labelGroup,
                              maxLines: 1,
                              minFontSize: 9,
                              maxFontSize: 11,
                              style: TextStyle(
                                  letterSpacing: 1.1,
                                  color: _metaEntity.isBookable
                                      ? whiteBtnTextColor
                                      : disabledColor,
                                  fontFamily: 'Roboto'),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    width: MediaQuery.of(context).size.width * .04,
                  ),
                ],
              ),

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
