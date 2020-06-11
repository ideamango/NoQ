import 'package:flutter/material.dart';
import 'package:noq/constants.dart';
import 'package:noq/models/localDB.dart';
import 'package:noq/pages/service_entity.dart';
import 'package:noq/repository/local_db_repository.dart';
import 'package:noq/style.dart';
import 'package:flutter/foundation.dart';

class EntityServicesListPage extends StatefulWidget {
  final EntityAppData entity;
  EntityServicesListPage({Key key, @required this.entity}) : super(key: key);
  @override
  _EntityServicesListPageState createState() => _EntityServicesListPageState();
}

class _EntityServicesListPageState extends State<EntityServicesListPage> {
  String _msg;
  final GlobalKey<FormState> _formKey = new GlobalKey<FormState>();
  List<ChildEntityAppData> servicesList = new List<ChildEntityAppData>();
  final String title = "Services Detail Form";

  EntityAppData entity;
  String _subEntityType;

//Add service Row

  int _count = 0;

  @override
  void initState() {
    super.initState();
    entity = widget.entity;
    if (entity.childCollection == null)
      entity.childCollection = new List<ChildEntityAppData>();

    servicesList = entity.childCollection;
  }

  void _addNewServiceRow() {
    setState(() {
      ChildEntityAppData c =
          new ChildEntityAppData.cType(_subEntityType, entity.id, entity.adrs);
      servicesList.add(c);
      //  entity.childCollection.add(c);
      saveEntityDetails(entity);
      _count = _count + 1;
    });
  }

  Widget _buildServiceItem(ChildEntityAppData childEntity) {
    return new ServiceRow(childEntity: childEntity);
  }

  @override
  Widget build(BuildContext context) {
    final BoxDecoration indigoContainer = new BoxDecoration(
        border: Border.all(color: Colors.blueGrey[400]),
        shape: BoxShape.rectangle,
        color: Colors.blueGrey[500],
        borderRadius: BorderRadius.all(Radius.circular(4.0)));

    final subEntityType = new FormField(
      builder: (FormFieldState state) {
        return InputDecorator(
          decoration: InputDecoration(
            //  icon: const Icon(Icons.person),
            labelText: 'Type of Service',
          ),
          child: new DropdownButtonHideUnderline(
            child: new DropdownButton(
              hint: new Text("Select Type of Service"),
              value: _subEntityType,
              isDense: true,
              onChanged: (newValue) {
                setState(() {
                  _subEntityType = newValue;
                  state.didChange(newValue);
                });
              },
              items: subEntityTypes.map((type) {
                return DropdownMenuItem(
                  value: type,
                  child: new Text(
                    type.toString(),
                    style: textInputTextStyle,
                  ),
                );
              }).toList(),
            ),
          ),
        );
      },
      onSaved: (String value) {
        _subEntityType = value;
        setState(() {
          _msg = null;
        });
        // entity.childCollection
        //    .add(new ChildEntityAppData.cType(value, entity.id));
        //   saveEntityDetails(entity);
      },
    );
    String title = "Manage Services in " + ((entity.name) ?? (entity.eType));
    return MaterialApp(
      title: 'Add child entities',
      //theme: ThemeData.light().copyWith(),
      home: Scaffold(
        appBar: AppBar(
            actions: <Widget>[],
            backgroundColor: Colors.teal,
            leading: IconButton(
                padding: EdgeInsets.all(0),
                alignment: Alignment.center,
                highlightColor: Colors.orange[300],
                icon: Icon(Icons.arrow_back),
                color: Colors.white,
                onPressed: () {
                  saveEntityDetails(entity);
                  Navigator.of(context).pop();
                }),
            title: Text(
              title,
              style: TextStyle(color: Colors.white, fontSize: 16),
              overflow: TextOverflow.ellipsis,
            )),
        body: Center(
          child: new Form(
            key: _formKey,
            autovalidate: true,
            child: Padding(
              padding: const EdgeInsets.all(5.0),
              child: Column(
                children: <Widget>[
                  Card(
                    elevation: 20,
                    child: Container(
                      decoration: BoxDecoration(
                          border: Border.all(color: Colors.indigo),
                          color: Colors.white,
                          shape: BoxShape.rectangle,
                          borderRadius: BorderRadius.all(Radius.circular(5.0))),
                      child: Column(
                        children: <Widget>[
                          Container(
                            height: MediaQuery.of(context).size.width * .1,
                            padding: EdgeInsets.fromLTRB(6, 0, 0, 0),
                            decoration: indigoContainer,
                            child: Row(
                              children: <Widget>[
                                Icon(
                                  Icons.business,
                                  size: 35,
                                  color: Colors.white,
                                ),
                                SizedBox(width: 12),
                                Column(
                                  children: <Widget>[
                                    Text(
                                      (entity.name) ?? (entity.eType),
                                      style: TextStyle(
                                          color: Colors.white, fontSize: 15),
                                    ),
                                    Text(
                                      (entity.adrs.locality +
                                              ", " +
                                              entity.adrs.city +
                                              ".") ??
                                          "",
                                      style: buttonXSmlTextStyle,
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          //subEntityType,
                          (_msg != null)
                              ? Text(
                                  _msg,
                                  style: errorTextStyle,
                                )
                              : Container(),
                          Padding(
                            padding: const EdgeInsets.fromLTRB(8.0, 0, 8, 0),
                            child: Row(
                              // mainAxisAlignment: MainAxisAlignment.end,
                              children: <Widget>[
                                Expanded(
                                  child: subEntityType,
                                ),
                                Container(
                                  child: IconButton(
                                    icon: Icon(Icons.add_circle,
                                        color: highlightColor, size: 40),
                                    onPressed: () {
                                      if (_subEntityType != null) {
                                        setState(() {
                                          _msg = null;
                                        });
                                        if (_formKey.currentState.validate()) {
                                          _formKey.currentState.save();
                                          _addNewServiceRow();
                                        }
                                      } else {
                                        setState(() {
                                          _msg = "Select service type";
                                        });
                                      }
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  new Expanded(
                    child: ListView.builder(
                      shrinkWrap: true,
                      //scrollDirection: Axis.vertical,
                      itemBuilder: (BuildContext context, int index) {
                        return Container(
                          child: new Column(
                              children:
                                  servicesList.map(_buildServiceItem).toList()),
                        );
                      },
                      itemCount: 1,
                    ),
                  ),
                ],
              ),
            ),
            // bottomNavigationBar: buildBottomItems()
          ),
        ),
      ),
    );
  }
}
