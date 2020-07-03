import 'package:flutter/material.dart';
import 'package:noq/models/localDB.dart';
import 'package:noq/pages/entity_services_details_page.dart';
import 'package:noq/pages/manage_apartment_page.dart';
import 'package:noq/style.dart';
import 'package:flutter/foundation.dart';

class EntityRow extends StatefulWidget {
  final EntityAppData entity;
  EntityRow({Key key, @required this.entity}) : super(key: key);
  @override
  State<StatefulWidget> createState() => new EntityRowState();
}

class EntityRowState extends State<EntityRow> {
  EntityAppData entity;

  @override
  void initState() {
    super.initState();
    entity = widget.entity;
  }

  @override
  Widget build(BuildContext context) {
    showServiceForm() {
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => ManageApartmentPage(entity: this.entity)));
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
                entity.eType,
                //  "Swimming Pool",
                style: TextStyle(color: Colors.blueGrey[700], fontSize: 17),
              ),
              if (entity.name != null)
                Text(
                  entity.name,
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
              icon: Icon(Icons.arrow_forward), onPressed: showServiceForm),
        ),
      ),
    );
  }
}
