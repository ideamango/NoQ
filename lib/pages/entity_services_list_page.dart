import 'package:flutter/material.dart';
import 'package:noq/constants.dart';
import 'package:noq/models/localDB.dart';
import 'package:noq/pages/service_entity.dart';
import 'package:noq/repository/local_db_repository.dart';
import 'package:noq/style.dart';
import 'package:flutter/foundation.dart';
import 'package:noq/utils.dart';
import 'package:uuid/uuid.dart';

class EntityServicesListPage extends StatefulWidget {
  final EntityAppData entity;
  EntityServicesListPage({Key key, @required this.entity}) : super(key: key);
  @override
  _EntityServicesListPageState createState() => _EntityServicesListPageState();
}

class _EntityServicesListPageState extends State<EntityServicesListPage> {
  String _msg;
  final GlobalKey<FormState> _servicesListFormKey = new GlobalKey<FormState>();
  List<ChildEntityAppData> servicesList = new List<ChildEntityAppData>();
  final String title = "Services Detail Form";

  EntityAppData parentEntity;
  String _subEntityType;

//Add service Row

  int _count = 0;
  @override
  void dispose() {
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    parentEntity = widget.entity;
    if (Utils.isNullOrEmpty(parentEntity.childCollection))
      parentEntity.childCollection = new List<ChildEntityAppData>();
// //TODO: Hack to clear list manually , remove later
    // parentEntity.childCollection.clear();
    // saveEntityDetails(parentEntity);
// //TODO:End
    setState(() {
      servicesList = parentEntity.childCollection;
    });
  }

  void _addNewServiceRow() {
    setState(() {
      var uuid = new Uuid();
      String _serviceId = uuid.v1();
      ChildEntityAppData c = new ChildEntityAppData.cType(
          _serviceId, _subEntityType, parentEntity.id, parentEntity.adrs);
      servicesList.add(c);
      //  entity.childCollection.add(c);
      saveChildEntity(c);
      _count = _count + 1;
    });
  }

  Widget _buildServiceItem(ChildEntityAppData childEntity) {
    return new ServiceRow(childEntity: childEntity);
  }

  @override
  Widget build(BuildContext context) {
    final subEntityType = new FormField(
      builder: (FormFieldState state) {
        return InputDecorator(
          decoration: InputDecoration(
            enabledBorder: InputBorder.none,
            focusedBorder: InputBorder.none,
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
    String title = "Manage Services in " +
        ((parentEntity.name).isEmpty
            ? (parentEntity.eType)
            : (parentEntity.name));
    return MaterialApp(
      title: 'Add child entities',
      //theme: ThemeData.light().copyWith(),
      home: Scaffold(
        appBar: AppBar(
            actions: <Widget>[],
            flexibleSpace: Container(
              decoration: gradientBackground,
            ),
            leading: IconButton(
                padding: EdgeInsets.all(0),
                alignment: Alignment.center,
                highlightColor: highlightColor,
                icon: Icon(Icons.arrow_back),
                color: Colors.white,
                onPressed: () {
                  saveEntityDetails(parentEntity);
                  Navigator.of(context).pop();
                }),
            title: Text(
              title,
              style: drawerdefaultTextStyle,
              overflow: TextOverflow.ellipsis,
            )),
        body: Center(
          child: new Form(
            key: _servicesListFormKey,
            autovalidate: true,
            child: Padding(
              padding: const EdgeInsets.all(5.0),
              child: Column(
                children: <Widget>[
                  Card(
                    elevation: 20,
                    child: Container(
                      decoration: BoxDecoration(
                          border: Border.all(color: borderColor),
                          color: Colors.white,
                          shape: BoxShape.rectangle,
                          borderRadius: BorderRadius.all(Radius.circular(5.0))),
                      child: Column(
                        children: <Widget>[
                          Container(
                            height: MediaQuery.of(context).size.width * .1,
                            padding: EdgeInsets.fromLTRB(6, 0, 0, 0),
                            decoration: darkContainer,
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
                                      (parentEntity.name) ??
                                          (parentEntity.eType),
                                      style: TextStyle(
                                          color: Colors.white, fontSize: 15),
                                    ),
                                    Text(
                                      (parentEntity.adrs.locality +
                                              ", " +
                                              parentEntity.adrs.city +
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
                                        if (_servicesListFormKey.currentState
                                            .validate()) {
                                          _servicesListFormKey.currentState
                                              .save();
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
