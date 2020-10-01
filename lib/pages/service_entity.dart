import 'package:flutter/material.dart';
import 'package:noq/db/db_model/entity.dart';
import 'package:noq/db/db_model/meta_entity.dart';
import 'package:noq/db/db_service/entity_service.dart';
import 'package:noq/pages/entity_services_details_page.dart';
import 'package:noq/style.dart';
import 'package:flutter/foundation.dart';
import 'package:noq/utils.dart';
import 'package:noq/widget/widgets.dart';

class ChildEntityRow extends StatefulWidget {
  final MetaEntity childEntity;
  final Map<String, Entity> entityMap;
  ChildEntityRow(
      {Key key, @required this.childEntity, @required this.entityMap})
      : super(key: key);
  @override
  State<StatefulWidget> createState() => new ChildEntityRowState();
}

class ChildEntityRowState extends State<ChildEntityRow> {
  Entity entity;
  MetaEntity _metaEntity;
  Map<String, Entity> _entityMap;

  @override
  void initState() {
    super.initState();
    _metaEntity = widget.childEntity;
    _entityMap = widget.entityMap;
  }

  Future<void> getEntity(String entityId) async {
    if (_entityMap != null) {
      if (_entityMap.length != 0) {
        if (_entityMap.containsKey(entityId))
          entity = _entityMap[entityId];
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
      //get Entity for this metaEntity
      // if Entity is inentityMap it means its a new entity and is not created yet,
      // else fetch from DB.
      getEntity(_metaEntity.entityId).then((value) {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) =>
                    ServiceEntityDetailsPage(childEntity: this.entity)));
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
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
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
          Container(
            height: 30,
            width: MediaQuery.of(context).size.width * .4,
            child: RaisedButton(
              elevation: 7,
              color: Colors.white,
              splashColor: highlightColor.withOpacity(.8),
              shape: RoundedRectangleBorder(
                  side: BorderSide(color: Colors.blueGrey[500]),
                  borderRadius: BorderRadius.all(Radius.circular(5.0))),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Text(
                    'Manage details',
                    style: TextStyle(color: primaryDarkColor, fontSize: 13),
                  ),
                  Icon(
                    Icons.arrow_forward_ios,
                    color: primaryDarkColor,
                    size: 15,
                  )
                ],
              ),
              onPressed: () {
                print("To Add details page");
                showServiceForm();
              },
            ),
          )
          // backgroundColor: Colors.white,
        ],
      ),
    );
  }
}
