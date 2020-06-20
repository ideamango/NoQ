import 'package:flutter/material.dart';
import 'package:noq/constants.dart';
import 'package:noq/models/localDB.dart';
import 'package:noq/pages/entity_item.dart';
import 'package:noq/pages/service_entity.dart';
import 'package:noq/repository/local_db_repository.dart';
import 'package:noq/style.dart';
import 'package:noq/utils.dart';
import 'package:noq/widget/appbar.dart';
import 'package:uuid/uuid.dart';

class ManageApartmentsListPage extends StatefulWidget {
  @override
  _ManageApartmentsListPageState createState() =>
      _ManageApartmentsListPageState();
}

class _ManageApartmentsListPageState extends State<ManageApartmentsListPage> {
  String _msg;
  final GlobalKey<FormState> _entityListFormKey = new GlobalKey<FormState>();
  List<EntityAppData> entitiesList;
  EntityAppData entity;
  String _entityType;
  int _count = 0;

  @override
  void dispose() {
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    getEntityList();
  }

  void getEntityList() async {
    await readData().then((fUser) {
      if (Utils.isNullOrEmpty(fUser.managedEntities))
        entitiesList = new List<EntityAppData>();

      setState(() {
// //TODO: Hack to clear list manually , remove later
//           fUser.managedEntities.clear();
//           writeData(fUser);
// //TODO:End
        entitiesList = fUser.managedEntities;
      });
    });
  }

  void _addNewServiceRow() {
    setState(() {
      var uuid = new Uuid();
      String _entityId = uuid.v1();
      EntityAppData en = new EntityAppData.eType(_entityType, _entityId);
      entitiesList.add(en);
      saveEntityDetails(en);
      _count = _count + 1;
    });
  }

  Widget _buildServiceItem(EntityAppData childEntity) {
    return new EntityRow(entity: childEntity);
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
            labelText: 'Type of Entity',
          ),
          child: new DropdownButtonHideUnderline(
            child: new DropdownButton(
              hint: new Text("Select Type of Entity"),
              value: _entityType,
              isDense: true,
              onChanged: (newValue) {
                setState(() {
                  _entityType = newValue;
                  state.didChange(newValue);
                });
              },
              items: entityTypes.map((type) {
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
        _entityType = value;
        setState(() {
          _msg = null;
        });
        // entity.childCollection
        //    .add(new ChildEntityAppData.cType(value, entity.id));
        //   saveEntityDetails(entity);
      },
    );
    String title = "Manage Entities";
    return MaterialApp(
      theme: ThemeData.light().copyWith(),
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
                  //saveEntityDetails(entity);
                  Navigator.of(context).pop();
                }),
            title: Text(
              title,
              style: TextStyle(color: Colors.white, fontSize: 16),
              overflow: TextOverflow.ellipsis,
            )),
        body: Center(
          child: new Form(
            key: _entityListFormKey,
            autovalidate: true,
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
                        // Container(
                        //   height: MediaQuery.of(context).size.width * .13,
                        //   decoration: indigoContainer,
                        //   child: ListTile(
                        //     //key: PageStorageKey(this.widget.headerTitle),
                        //     leading: Padding(
                        //       padding:
                        //           const EdgeInsets.fromLTRB(0, 0, 0, 10.0),
                        //       child: Icon(
                        //         Icons.home,
                        //         size: 35,
                        //         color: Colors.white,
                        //       ),
                        //     ),
                        //     title: Row(
                        //       children: <Widget>[
                        //         Column(
                        //           children: <Widget>[
                        //             Text(
                        //               //entity.name
                        //               "My Home Vihanga",
                        //               style: TextStyle(
                        //                   color: Colors.white, fontSize: 15),
                        //             ),
                        //             Text(
                        //               // entity.adrs.locality +
                        //               //     ", " +
                        //               //     entity.adrs.city +
                        //               //     "."
                        //               "Gachibowli, Hyderabad",
                        //               style: buttonXSmlTextStyle,
                        //             ),
                        //           ],
                        //         ),
                        //       ],
                        //     ),
                        //   ),
                        // ),
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
                              Text(
                                "Add Entities to manage",
                                style: TextStyle(
                                    color: Colors.white, fontSize: 15),
                              ),
                            ],
                          ),
                        ),
                        // subEntityType,
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
                                    if (_entityType != null) {
                                      setState(() {
                                        _msg = null;
                                      });
                                      if (_entityListFormKey.currentState
                                          .validate()) {
                                        _entityListFormKey.currentState.save();
                                        _addNewServiceRow();
                                        //   _subEntityType = "Select";
                                        // } else {
                                        //   _msg = "Select service type";
                                        // }
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
                if (!Utils.isNullOrEmpty(entitiesList))
                  new Expanded(
                    child: ListView.builder(
                      shrinkWrap: true,
                      itemBuilder: (BuildContext context, int index) {
                        return Container(
                          child: new Column(
                              children:
                                  entitiesList.map(_buildServiceItem).toList()),
                        );
                      },
                      itemCount: 1,
                    ),
                  ),
              ],
            ),
            // bottomNavigationBar: buildBottomItems()
          ),
        ),
      ),
    );
  }
}
