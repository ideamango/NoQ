import 'package:flutter/material.dart';
import 'package:noq/constants.dart';
import 'package:noq/db/db_model/entity.dart';
import 'package:noq/db/db_model/meta_entity.dart';
import 'package:noq/db/db_service/entity_service.dart';
import 'package:noq/global_state.dart';
import 'package:noq/pages/booking_form_selection_page.dart';
import 'package:noq/pages/entity_token_list_page.dart';
import 'package:noq/pages/manage_child_entity_details_page.dart';
import 'package:noq/pages/manage_child_entity_list_page.dart';
import 'package:noq/pages/manage_entity_forms.dart';
import 'package:noq/pages/overview_page.dart';
import 'package:noq/services/qr_code_generate.dart';
import 'package:noq/style.dart';
import 'package:flutter/foundation.dart';
import 'package:noq/utils.dart';
import 'package:noq/widget/page_animation.dart';
import 'package:noq/widget/widgets.dart';
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
            backRoute: "ChildList",
          )));
      });
    }

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
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                              iconSize: 25,
                              onPressed: () {
                                share();
                              },
                            )),
                      ],
                    )),
              ],
            ),
            verticalSpacer,
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Container(
                  //margin: EdgeInsets.fromLTRB(0, 0, 5, 0),
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
                      'Manage Forms',
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
                  ),
                ),
              ],
            ),
            SizedBox(height: 5),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
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
                    child: Align(
                      alignment: Alignment.center,
                      child: Text(
                        'Booking Applications',
                        textAlign: TextAlign.center,
                        style:
                            TextStyle(color: whiteBtnTextColor, fontSize: 13),
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
                    splashColor: highlightColor.withOpacity(.8),
                    shape: RoundedRectangleBorder(
                        side: BorderSide(color: Colors.blueGrey[300]),
                        borderRadius: BorderRadius.all(Radius.circular(5.0))),
                    child: Text(
                      'Booking Tokens',
                      style: TextStyle(color: whiteBtnTextColor, fontSize: 13),
                    ),
                    onPressed: () {
                      print("To child list page");
                      Navigator.of(context)
                          .push(PageAnimation.createRoute(EntityTokenListPage(
                        metaEntity: _metaEntity,
                        backRoute: ManageChildEntityListPage(
                          entity: entity,
                        ),
                      )));
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
