import 'package:flutter/material.dart';
import 'package:noq/db/db_model/entity.dart';
import 'package:noq/db/db_model/meta_entity.dart';
import 'package:noq/pages/entity_services_details_page.dart';
import 'package:noq/style.dart';
import 'package:flutter/foundation.dart';

class ChildEntityRow extends StatefulWidget {
  final Entity childEntity;
  ChildEntityRow({Key key, @required this.childEntity}) : super(key: key);
  @override
  State<StatefulWidget> createState() => new ChildEntityRowState();
}

class ChildEntityRowState extends State<ChildEntityRow> {
  Entity serviceEntity;

  @override
  void initState() {
    super.initState();
    serviceEntity = widget.childEntity;
  }

  @override
  Widget build(BuildContext context) {
    showServiceForm() {
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => ServiceEntityDetailsPage(
                  serviceMetaEntity: this.serviceEntity)));
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
          isThreeLine: false,
          title: Column(
            children: <Widget>[
              Text(
                serviceEntity.type,
                //  "Swimming Pool",
                style: TextStyle(color: Colors.blueGrey[700], fontSize: 17),
              ),
              if (serviceEntity.name != null)
                Text(
                  serviceEntity.name,
                  style: labelTextStyle,
                ),
            ],
          ),
          // backgroundColor: Colors.white,
          leading: Icon(
            Icons.slow_motion_video,
            color: primaryIcon,
          ),
          trailing: IconButton(
              icon: Icon(Icons.arrow_forward), onPressed: showServiceForm),
        ),
      ),
    );
  }
}
