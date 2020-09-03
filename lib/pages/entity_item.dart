import 'package:flutter/material.dart';
import 'package:noq/db/db_model/entity.dart';
import 'package:noq/db/db_model/meta_entity.dart';
import 'package:noq/db/db_service/entity_service.dart';
import 'package:noq/pages/entity_services_details_page.dart';
import 'package:noq/pages/manage_apartment_page.dart';
import 'package:noq/services/circular_progress.dart';
import 'package:noq/style.dart';
import 'package:flutter/foundation.dart';
import 'package:noq/pages/entity_services_list_page.dart';
import 'package:noq/utils.dart';
import 'package:noq/widget/widgets.dart';

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

    return Container(
      margin: EdgeInsets.all(5),
      padding: EdgeInsets.all(8),
      decoration: BoxDecoration(
          border: Border.all(color: borderColor),
          color: Colors.white,
          shape: BoxShape.rectangle,
          borderRadius: BorderRadius.all(Radius.circular(5.0))),
      // padding: EdgeInsets.all(5.0),

      child: Row(
        //  mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          // Icon(
          //   Icons.business,
          //   color: primaryIcon,
          // ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                _metaEntity.type,
                //  "Swimming Pool",
                style: TextStyle(color: Colors.blueGrey[700], fontSize: 17),
              ),
              if (_metaEntity.name != null)
                Text(
                  _metaEntity.name,
                  style: labelTextStyle,
                ),
            ],
          ),
          horizontalSpacer,
          Column(
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
                    'Manage Child Places',
                    style: TextStyle(color: Colors.white, fontSize: 13),
                  ),
                  // Text(
                  //   (_metaEntity.name != null)
                  //       ? (_metaEntity.name)
                  //       : (_metaEntity.type),
                  //   style: buttonSmlTextStyle,
                  // ),

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
