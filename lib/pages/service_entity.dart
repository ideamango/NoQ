import 'package:LESSs/enum/entity_role.dart';
import 'package:LESSs/services/circular_progress.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import '../constants.dart';
import '../db/db_model/entity.dart';
import '../db/db_model/meta_entity.dart';
import '../db/db_service/entity_service.dart';
import '../global_state.dart';
import '../pages/booking_form_selection_page.dart';
import '../pages/entity_token_list_page.dart';
import '../pages/manage_child_entity_details_page.dart';
import '../pages/manage_child_entity_list_page.dart';
import '../pages/manage_employee_page.dart';
import '../pages/manage_entity_forms.dart';
import '../pages/overview_page.dart';
import '../services/qr_code_generate.dart';
import '../style.dart';
import 'package:flutter/foundation.dart';
import '../utils.dart';
import '../widget/page_animation.dart';
import '../widget/widgets.dart';
import 'package:share/share.dart';

class ChildEntityRow extends StatefulWidget {
  final MetaEntity childEntity;

  ChildEntityRow({Key key, @required this.childEntity}) : super(key: key);
  @override
  State<StatefulWidget> createState() => new ChildEntityRowState();
}

class ChildEntityRowState extends State<ChildEntityRow> {
  Entity parentEntity;
  Entity entity;
  MetaEntity _metaEntity;
  GlobalState _gs;
  bool _initCompleted = false;
  // Map<String, Entity> _entityMap;
  bool isExec = false;
  bool isManager = false;
  bool hideAll = false;
  bool isAdmin = false;
  bool readOnly;
  @override
  void initState() {
    super.initState();
    _metaEntity = widget.childEntity;

    GlobalState.getGlobalState().then((value) {
      _gs = value;
      if (_gs.getCurrentUser().entityVsRole.containsKey(_metaEntity.entityId)) {
        if (_gs.getCurrentUser().entityVsRole[_metaEntity.entityId] ==
            EntityRole.Executive) isExec = true;
        if (_gs.getCurrentUser().entityVsRole[_metaEntity.entityId] ==
            EntityRole.Manager) isManager = true;
        if (_gs.getCurrentUser().entityVsRole[_metaEntity.entityId] ==
            EntityRole.Admin) isAdmin = true;
      } else {
        hideAll = true;
      }
      readOnly = isManager || isExec;

      _gs.getEntity(_metaEntity.parentId).then((value) {
        parentEntity = value.item1;
        _gs.getEntity(_metaEntity.entityId).then((value) {
          entity = value.item1;
          if (this.mounted) {
            setState(() {
              _initCompleted = true;
            });
          } else {
            _initCompleted = false;
          }
        });
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    showServiceForm() {
      // if Entity is inentityMap it means its a new entity and is not created yet,
      // else fetch from DB.

      Navigator.of(context).pop();
      Navigator.of(context)
          .push(PageAnimation.createRoute(ManageChildEntityDetailsPage(
        childMetaEntity: _metaEntity,
        isManager: isManager || isExec,
      )));
    }

    generateLinkAndShareWithParams(String entityId, String name) async {
      String msgTitle = name + entityShareByOwnerHeading;
      String msgBody = entityShareMessage;

      Utils.generateLinkAndShare(entityId, msgTitle, msgBody);
    }

    share() {
      Entity en;
      _gs.getEntity(_metaEntity.entityId).then((value) {
        en = value.item1;
        if (en == null) {
          Utils.showMyFlushbar(context, Icons.info, Duration(seconds: 4),
              missingInfoForShareStr, missingInfoForShareSubStr);
        } else
          generateLinkAndShareWithParams(
              _metaEntity.entityId, _metaEntity.name);
      });
    }

    shareQr() {
      Entity en;

      _gs.getEntity(_metaEntity.entityId).then((value) {
        en = value.item1;
        if (en == null) {
          Utils.showMyFlushbar(context, Icons.info, Duration(seconds: 4),
              missingInfoForShareStr, missingInfoForShareSubStr);
        } else
          Navigator.of(context).push(PageAnimation.createRoute(GenerateScreen(
            entityId: _metaEntity.entityId,
            entityName: _metaEntity.name,
            backRoute: ManageChildEntityListPage(
              entity: parentEntity,
            ),
          )));
      });
    }

    var labelGroup = AutoSizeGroup();
    if (_initCompleted)
      return Card(
        elevation: 5,
        child: Container(
          //  height: MediaQuery.of(context).size.width * .55,
          // margin: EdgeInsets.all(5),
          padding: EdgeInsets.all(8),
          decoration: BoxDecoration(
              border: Border.all(color: borderColor),
              color: Colors.white,
              shape: BoxShape.rectangle,
              borderRadius: BorderRadius.all(Radius.circular(5.0))),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              Row(
                //mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Container(
                    //padding: EdgeInsets.fromLTRB(0, 0, 5, 0),
                    width: MediaQuery.of(context).size.width * .5,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          (_metaEntity.name != null)
                              ? _metaEntity.name
                              : "Untitled",
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                              color: Colors.blueGrey[700], fontSize: 17),
                        ),
                        Text(
                          Utils.getEntityTypeDisplayName(_metaEntity.type),
                          style: labelTextStyle,
                        ),
                      ],
                    ),
                  ),
                  Container(
                      padding: EdgeInsets.zero,
                      margin: EdgeInsets.zero,
                      width: MediaQuery.of(context).size.width * .36,
                      //   height: MediaQuery.of(context).size.width * .08,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: <Widget>[
                          Container(
                            padding: EdgeInsets.all(0),
                            margin: EdgeInsets.all(0),
                            height: 32.0,
                            width: 32.0,
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
                              height: 32.0,
                              width: 32.0,
                              child: IconButton(
                                padding: EdgeInsets.fromLTRB(0, 0, 0, 0),
                                alignment: Alignment.center,
                                highlightColor: Colors.orange[300],
                                icon: Icon(Icons.share),
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
                height: MediaQuery.of(context).size.height * .007,
              ),
              Wrap(
                  // mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Card(
                      margin: EdgeInsets.fromLTRB(12, 0, 12, 12),
                      elevation: 8,
                      child: GestureDetector(
                        onTap: () {
                          if (hideAll) {
                            Utils.showMyFlushbar(
                                context,
                                Icons.info_outline,
                                Duration(seconds: 5),
                                "$noViewPermission details of this Place!",
                                contactAdmin);
                          } else {
                            showServiceForm();
                          }
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
                                    color: whiteBtnTextColor,
                                    letterSpacing: 1.1,
                                    fontFamily: 'Roboto'),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    if (!isExec)
                      Card(
                        margin: EdgeInsets.fromLTRB(12, 0, 12, 12),
                        elevation: 8,
                        child: GestureDetector(
                          onTap: () {
                            if (hideAll) {
                              Utils.showMyFlushbar(
                                  context,
                                  Icons.info_outline,
                                  Duration(seconds: 4),
                                  "$noViewPermission Employees!!",
                                  contactAdmin);
                            } else {
                              Navigator.of(context).push(
                                  PageAnimation.createRoute(ManageEmployeePage(
                                metaEntity: _metaEntity,
                                backRoute: ManageChildEntityListPage(
                                  entity: parentEntity,
                                ),
                                defaultDate: null,
                                isManager: isManager,
                              )));
                            }
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
                                  width:
                                      MediaQuery.of(context).size.width * .11,
                                  height:
                                      MediaQuery.of(context).size.width * .11,
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
                                      color: whiteBtnTextColor,
                                      letterSpacing: 1.1,
                                      fontFamily: 'Roboto'),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    Card(
                      margin: EdgeInsets.fromLTRB(12, 0, 12, 12),
                      elevation: 8,
                      child: GestureDetector(
                        onTap: () {
                          if (hideAll) {
                            Utils.showMyFlushbar(
                                context,
                                Icons.info_outline,
                                Duration(seconds: 5),
                                "$noViewPermission forms!!",
                                contactAdmin);
                          } else {
                            print("To Add details page");
                            Navigator.of(context).push(
                                PageAnimation.createRoute(ManageEntityForms(
                              // forms: _metaEntity.forms,
                              metaEntity: _metaEntity,
                              preferredSlotTime: null,
                              isFullPermission: !readOnly,
                              backRoute: ManageChildEntityListPage(
                                entity: parentEntity,
                              ),
                              isReadOnly: readOnly,
                            )));
                          }
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
                                  image: AssetImage('assets/forms.png'),
                                ),
                              ),
                              AutoSizeText(
                                'Forms',
                                group: labelGroup,
                                maxLines: 1,
                                minFontSize: 9,
                                maxFontSize: 11,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    color: whiteBtnTextColor,
                                    letterSpacing: 1.1,
                                    fontFamily: 'Roboto'),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    Card(
                      margin: EdgeInsets.fromLTRB(12, 0, 12, 12),
                      elevation: 8,
                      child: GestureDetector(
                        onTap: () {
                          print("Over To Applications overview page");
                          if (hideAll) {
                            Utils.showMyFlushbar(
                                context,
                                Icons.info_outline,
                                Duration(seconds: 5),
                                "$noViewPermission Applications!!",
                                contactAdmin);
                          } else {
                            if (!Utils.isNullOrEmpty(entity.forms)) {
                              // if (entity.forms.length > 1) {
                              Navigator.of(context).push(
                                  PageAnimation.createRoute(
                                      BookingFormSelection(
                                entityId: entity.entityId,
                                entity: entity,
                                preferredSlotTime: null,
                                isFullAccess: isAdmin || isManager,
                                forUser: false,
                                backRoute: ManageChildEntityListPage(
                                  entity: parentEntity,
                                ),
                                isOnlineToken: null,
                              )));
                              // } else {
                              //   Navigator.of(context).push(
                              //       PageAnimation.createRoute(OverviewPage(
                              //     bookingFormId: _metaEntity.forms[0].id,
                              //     bookingFormName: _metaEntity.forms[0].name,
                              //     entityId: _metaEntity.entityId,
                              //     metaEntity: _metaEntity,
                              //     isExec: isExec,
                              //   )));
                              // }
                            } else {
                              Utils.showMyFlushbar(
                                  context,
                                  Icons.info_outline,
                                  Duration(seconds: 5),
                                  "No Booking Forms found for your place!",
                                  "Click FORMS to manage Forms.");
                            }
                          }
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
                    Card(
                      margin: EdgeInsets.fromLTRB(12, 0, 12, 12),
                      elevation: 8,
                      child: GestureDetector(
                        onTap: () {
                          print("To child list page");
                          if (hideAll) {
                            Utils.showMyFlushbar(
                                context,
                                Icons.info_outline,
                                Duration(seconds: 5),
                                "$noViewPermission Booking Tokens!",
                                contactAdmin);
                          } else {
                            if (_metaEntity.isBookable) {
                              print("To child list page");
                              Navigator.of(context).push(
                                  PageAnimation.createRoute(EntityTokenListPage(
                                metaEntity: _metaEntity,
                                backRoute: ManageChildEntityListPage(
                                  entity: parentEntity,
                                ),
                                defaultDate: null,
                                isReadOnly: isExec,
                              )));
                            } else
                              Utils.showMyFlushbar(
                                  context,
                                  Icons.info_outline,
                                  Duration(seconds: 5),
                                  "It seems this place is not marked as Bookable.",
                                  "Go to Entity Details page and make this Bookable.");
                          }
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
                                    color: whiteBtnTextColor,
                                    letterSpacing: 1.1,
                                    fontFamily: 'Roboto'),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ]),
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
