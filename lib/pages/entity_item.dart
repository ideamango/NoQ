import 'package:flutter/material.dart';
import 'package:noq/db/db_model/entity.dart';
import 'package:noq/db/db_model/meta_entity.dart';
import 'package:noq/db/db_service/entity_service.dart';
import 'package:noq/pages/entity_services_details_page.dart';
import 'package:noq/pages/manage_apartment_page.dart';
import 'package:noq/services/circular_progress.dart';
import 'package:noq/services/qr_code_generate.dart';
import 'package:noq/style.dart';
import 'package:flutter/foundation.dart';
import 'package:noq/pages/entity_services_list_page.dart';
import 'package:noq/utils.dart';
import 'package:noq/widget/widgets.dart';
import 'package:share/share.dart';

class EntityRow extends StatefulWidget {
  final MetaEntity entity;
  final Map<String, Entity> parentEntityMap;
  EntityRow({Key key, @required this.entity, this.parentEntityMap})
      : super(key: key);
  @override
  State<StatefulWidget> createState() => new EntityRowState();
}

class EntityRowState extends State<EntityRow> {
  MetaEntity _metaEntity;
  Entity entity;
  bool getEntityDone = false;
  Map<String, Entity> _parentEntityMap;

  @override
  void initState() {
    super.initState();
    _metaEntity = widget.entity;
    _parentEntityMap = widget.parentEntityMap;
  }

  Future<void> getEntity(String entityId) async {
    if (_parentEntityMap != null) {
      if (_parentEntityMap.length != 0) {
        if (_parentEntityMap.containsKey(entityId))
          entity = _parentEntityMap[entityId];
        else {
          entity = await EntityService().getEntity(entityId);
        }
      }
    }
    if (entity == null) {
      entity = await EntityService().getEntity(entityId);
    }
  }

  @override
  Widget build(BuildContext context) {
    showServiceForm() {
      getEntity(_metaEntity.entityId).then((value) {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => ManageApartmentPage(entity: entity)));
      });
    }

    generateLinkAndShareWithParams(String entityId) async {
      var dynamicLink =
          await Utils.createDynamicLinkWithParams(entityId: entityId);
      print("Dynamic Link: $dynamicLink");

      String _dynamicLink =
          Uri.https(dynamicLink.authority, dynamicLink.path).toString();
      // dynamicLink has been generated. share it with others to use it accordingly.
      Share.share(_dynamicLink.toString());
    }

    showChildListPage() {
      EntityService().getEntity(_metaEntity.entityId).then((value) {
        //If no entity in DB then it means no entity created yet, only meta.
        //So then msg to user to create entity first before adding children.
        // Else Entity is present then take to child list page
        if (value != null) {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => ChildEntitiesListPage(entity: value)));
        } else {
          //No entity created yet.. show msg to create entity first.

          Utils.showMyFlushbar(
              context,
              Icons.info_outline,
              Duration(
                seconds: 6,
              ),
              "Important premises details are missing, Click on 'Add details' to add now!",
              "You need to add those before adding children.");
        }
      });
    }

    share() {
      Entity en;
      EntityService().getEntity(_metaEntity.entityId).then((value) {
        en = value;
        if (en == null) {
          Utils.showMyFlushbar(
              context,
              Icons.info,
              Duration(seconds: 4),
              "Important details are missing in entity, Please fill those first.",
              "Save Entity and then Share!!");
        } else
          generateLinkAndShareWithParams(_metaEntity.entityId);
      });
    }

    shareQr() {
      Entity en;
      EntityService().getEntity(_metaEntity.entityId).then((value) {
        en = value;
        if (en == null) {
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
                      )));
      });
    }

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
              Container(
                width: MediaQuery.of(context).size.width * .5,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      (_metaEntity.name != null)
                          ? _metaEntity.name
                          : "Untitled",
                      style:
                          TextStyle(color: Colors.blueGrey[700], fontSize: 17),
                    ),
                    Text(
                      _metaEntity.type,
                      style: labelTextStyle,
                    ),
                  ],
                ),
              ),
              Container(
                  padding: EdgeInsets.zero,
                  margin: EdgeInsets.zero,
                  width: MediaQuery.of(context).size.width * .4,
                  height: MediaQuery.of(context).size.width * .05,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: <Widget>[
                      Container(
                        padding: EdgeInsets.fromLTRB(0, 0, 0, 0),
                        margin: EdgeInsets.fromLTRB(0, 0, 0, 0),
                        height: 25.0,
                        width: 28.0,
                        child: IconButton(
                            padding: EdgeInsets.fromLTRB(0, 0, 0, 0),
                            alignment: Alignment.center,
                            highlightColor: Colors.orange[300],
                            icon: ImageIcon(
                              AssetImage('assets/qrcode.png'),
                              size: 20,
                              //color: primaryIcon,
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
                            iconSize: 20,
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
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: <Widget>[
              Container(
                width: MediaQuery.of(context).size.width * .45,
                height: 30,
                child: RaisedButton(
                  elevation: 20,
                  color: btnColor,
                  textColor: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(5.0))),
                  splashColor: highlightColor,
                  child: Text(
                    'Manage child amenities',
                    style: TextStyle(color: Colors.white, fontSize: 13),
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
                width: MediaQuery.of(context).size.width * .45,
                child: RaisedButton(
                  elevation: 10,
                  color: Colors.white,
                  splashColor: highlightColor.withOpacity(.8),

                  shape: RoundedRectangleBorder(
                      side: BorderSide(color: Colors.blueGrey[500]),
                      borderRadius: BorderRadius.all(Radius.circular(5.0))),
                  child: Text(
                    'Manage details',
                    style: TextStyle(color: primaryDarkColor, fontSize: 13),
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
  }
}
