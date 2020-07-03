import 'dart:io';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:noq/constants.dart';
import 'package:noq/models/localDB.dart';
import 'package:noq/pages/entity_services_details_page.dart';
import 'package:noq/repository/local_db_repository.dart';
import 'package:noq/services/authService.dart';
import 'package:noq/services/qr_code_generate.dart';
import 'package:noq/style.dart';
import 'package:noq/utils.dart';
import 'package:noq/widget/weekday_selector.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';

class ServiceRow extends StatefulWidget {
  final ChildEntityAppData childEntity;
  ServiceRow({Key key, @required this.childEntity}) : super(key: key);
  @override
  State<StatefulWidget> createState() => new ServiceRowState();
}

class ServiceRowState extends State<ServiceRow> {
  ChildEntityAppData serviceEntity;

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
              builder: (context) =>
                  ServiceEntityDetailsPage(serviceEntity: this.serviceEntity)));
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
                serviceEntity.cType,
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
