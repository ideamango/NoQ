import 'package:flutter/material.dart';
import 'package:noq/db/db_model/entity.dart';
import 'package:noq/db/db_model/meta_entity.dart';
import 'package:noq/db/db_service/entity_service.dart';
import 'package:noq/pages/entity_services_details_page.dart';
import 'package:noq/pages/manage_apartment_page.dart';
import 'package:noq/services/circular_progress.dart';
import 'package:noq/style.dart';
import 'package:flutter/foundation.dart';

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
                builder: (context) =>
                    ManageApartmentPage(entity: entity)));
      });
    }

    return new Card(
      elevation: 20,
      child: Container(
        decoration: BoxDecoration(
            border: Border.all(color: borderColor),
            color: Colors.white,
            shape: BoxShape.rectangle,
            borderRadius: BorderRadius.all(Radius.circular(5.0))),
        // padding: EdgeInsets.all(5.0),

        child: ListTile(
          title: Column(
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
          // backgroundColor: Colors.white,
          leading: Icon(
            Icons.business,
            color: primaryIcon,
          ),
          trailing: IconButton(
              icon: Icon(Icons.arrow_forward),
              onPressed: () {
                showServiceForm();
              }),
        ),
      ),
    );
  }
}
