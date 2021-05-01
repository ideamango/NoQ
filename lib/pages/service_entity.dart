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
  Entity entity;
  MetaEntity _metaEntity;
  GlobalState _gs;
  bool _initCompleted = false;
  // Map<String, Entity> _entityMap;

  @override
  void initState() {
    super.initState();
    _metaEntity = widget.childEntity;
    // _entityMap = widget.entityMap;
    GlobalState.getGlobalState().then((value) {
      _gs = value;
      _gs.getEntity(_metaEntity.parentId).then((value) {
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
  }

  Future<void> getEntity(String entityId) async {
    // if (_entityMap != null) {
    //   if (_entityMap.length != 0) {
    //     if (_entityMap.containsKey(entityId))
    //       entity = _entityMap[entityId];
    //     else {
    //       entity = await EntityService().getEntity(entityId);
    //     }
    //   }
    // }
    // if (entity == null) {
    //   entity = await EntityService().getEntity(entityId);
    //   print(entity.name);
    // }
  }

  @override
  Widget build(BuildContext context) {
    showServiceForm() {
      //get Entity for this metaEntity
      // if Entity is inentityMap it means its a new entity and is not created yet,
      // else fetch from DB.
      //TODO Sumant - use state for entity get, put
      _gs.getEntity(_metaEntity.entityId).then((value) {
        Navigator.of(context).pop();
        Navigator.of(context).push(PageAnimation.createRoute(
            ManageChildEntityDetailsPage(childEntity: value.item1)));
      });
    }

    generateLinkAndShareWithParams(String entityId, String name) async {
      String msgTitle = name + entityShareByOwnerHeading;
      String msgBody = entityShareMessage;

      Utils.generateLinkAndShare(entityId, msgTitle, msgBody);
      // var dynamicLink =
      //     await Utils.createDynamicLinkWithParams(entityId, msgTitle, msgBody);
      // print("Dynamic Link: $dynamicLink");

      // String _dynamicLink =
      //     Uri.https(dynamicLink.authority, dynamicLink.path).toString();
      // // dynamicLink has been generated. share it with others to use it accordingly.
      // Share.share(dynamicLink.toString());
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
              entity: entity,
            ),
          )));
      });
    }

    var labelGroup = AutoSizeGroup();

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
          //   mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            Row(
              //mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                GestureDetector(
                  onTap: () {
                    print("Opening manage details on container click");
                    showServiceForm();
                  },
                  child: Container(
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
            Row(
                // mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  SizedBox(
                    width: MediaQuery.of(context).size.width * .04,
                  ),
                  Card(
                    elevation: 8,
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
                                  color: whiteBtnTextColor,
                                  letterSpacing: 1.1,
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
                          backRoute: ManageChildEntityListPage(
                            entity: entity,
                          ),
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
                                  color: whiteBtnTextColor,
                                  letterSpacing: 1.1,
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
                        print("To Add details page");
                        Navigator.of(context)
                            .push(PageAnimation.createRoute(ManageEntityForms(
                          // forms: _metaEntity.forms,
                          metaEntity: _metaEntity,
                          preferredSlotTime: null,
                          isAdmin: true,
                          backRoute: ManageChildEntityListPage(
                            entity: entity,
                          ),
                        )));
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
                  SizedBox(
                    width: MediaQuery.of(context).size.width * .04,
                  ),
                ]),
            Row(children: <Widget>[
              SizedBox(
                width: MediaQuery.of(context).size.width * .04,
              ),
              Card(
                elevation: 8,
                child: GestureDetector(
                  onTap: () {
                    print("Over To Applications overview page");
                    if (!Utils.isNullOrEmpty(_metaEntity.forms)) {
                      if (_metaEntity.forms.length > 1) {
                        Navigator.of(context).push(
                            PageAnimation.createRoute(BookingFormSelection(
                          forms: _metaEntity.forms,
                          metaEntity: _metaEntity,
                          preferredSlotTime: null,
                          isAdmin: true,
                          backRoute: ManageChildEntityListPage(
                            entity: null,
                          ),
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
                          "No Applications found as of now!!",
                          "");
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
              SizedBox(
                width: MediaQuery.of(context).size.width * .04,
              ),
              Card(
                elevation: 8,
                child: GestureDetector(
                  onTap: () {
                    print("To child list page");
                    Navigator.of(context)
                        .push(PageAnimation.createRoute(EntityTokenListPage(
                      metaEntity: _metaEntity,
                      backRoute: ManageChildEntityListPage(
                        entity: entity,
                      ),
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
  }
}
