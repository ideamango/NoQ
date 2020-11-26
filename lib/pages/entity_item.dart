import 'package:flutter/material.dart';
import 'package:noq/constants.dart';
import 'package:noq/db/db_model/entity.dart';
import 'package:noq/db/db_model/meta_entity.dart';
import 'package:noq/db/db_service/entity_service.dart';
import 'package:noq/pages/manage_child_entity_details_page.dart';
import 'package:noq/pages/manage_entity_details_page.dart';
import 'package:noq/services/circular_progress.dart';
import 'package:noq/services/qr_code_generate.dart';
import 'package:noq/style.dart';
import 'package:flutter/foundation.dart';
import 'package:noq/pages/manage_child_entity_list_page.dart';
import 'package:noq/utils.dart';
import 'package:noq/widget/widgets.dart';
import 'package:share/share.dart';

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
        entity = value.item1;
        if (entity == null) {
          Utils.showMyFlushbar(context, Icons.info, Duration(seconds: 2),
              "Couldnt fetch details of this entity. Try again later.", "");
        } else {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) =>
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
      _state.getEntity(_metaEntity.entityId).then((value) {
        bool isSavedOnServer = false;
        Entity ent;
        if (value != null) {
          isSavedOnServer = value.item2;
          ent = value.item1;
        }

        if (isSavedOnServer) {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) =>
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
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => GenerateScreen(
                      entityId: _metaEntity.entityId,
                      entityName: _metaEntity.name)));
      });
    }

    if (_initCompleted)
      return Container(
        margin: EdgeInsets.all(5),
        padding: EdgeInsets.all(8),
        decoration: BoxDecoration(
            border: Border.all(color: borderColor),
            color: Colors.white,
            shape: BoxShape.rectangle,
            borderRadius: BorderRadius.all(Radius.circular(5.0))),
        // padding: EdgeInsets.all(5.0),

        child: Column(
          //  mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                              color: Colors.blueGrey[700], fontSize: 17),
                        ),
                        Text(
                          _metaEntity.type,
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
                    // height: MediaQuery.of(context).size.width * .08,
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
                              color: primaryDarkColor,
                              iconSize: 25,
                              onPressed: () {
                                share();
                              },
                            )),
                      ],
                    )),
              ],
            ),
            horizontalSpacer,
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Container(
                  width: MediaQuery.of(context).size.width * .42,
                  height: 30,
                  child: RaisedButton(
                    elevation: 7,
                    color: Colors.white,
                    splashColor: highlightColor.withOpacity(.8),
                    shape: RoundedRectangleBorder(
                        side: BorderSide(color: Colors.blueGrey[500]),
                        borderRadius: BorderRadius.all(Radius.circular(5.0))),
                    child: Text(
                      'Child Places',
                      style: TextStyle(color: primaryDarkColor, fontSize: 13),
                    ),
                    onPressed: () {
                      print("To child list page");
                      showChildListPage();
                    },
                  ),
                ),
                verticalSpacer,
                Container(
                  height: 30,
                  width: MediaQuery.of(context).size.width * .42,
                  child: RaisedButton(
                    elevation: 7,
                    color: btnColor,
                    textColor: Colors.white,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(5.0))),
                    splashColor: highlightColor,
                    child: Text(
                      'Manage Details',
                      style: TextStyle(color: Colors.white, fontSize: 13),
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
              ],
            )
            // backgroundColor: Colors.white,
          ],
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
