import 'package:flutter/material.dart';
import 'package:noq/constants.dart';
import 'package:noq/models/localDB.dart';
import 'package:noq/pages/entity_item.dart';
import 'package:noq/pages/service_entity.dart';
import 'package:noq/repository/local_db_repository.dart';
import 'package:noq/style.dart';
import 'package:noq/utils.dart';
import 'package:uuid/uuid.dart';

class ManageApartmentsListPage extends StatefulWidget {
  @override
  _ManageApartmentsListPageState createState() =>
      _ManageApartmentsListPageState();
}

class _ManageApartmentsListPageState extends State<ManageApartmentsListPage> {
  String _msg;
  final GlobalKey<FormState> _formKey = new GlobalKey<FormState>();
  List<EntityAppData> entitiesList;
  final String title = "Services Detail Form";

  EntityAppData entity;
  String _entityType;

  int _count = 0;

  @override
  void initState() {
    super.initState();

    // if (entity.childCollection == null)
    //   entity.childCollection = new List<ChildEntityAppData>();
    getEntityList();
  }

  void getEntityList() async {
    await readData().then((fUser) {
      if (Utils.isNullOrEmpty(fUser.managedEntities))
        entitiesList = new List<EntityAppData>();
      else
        setState(() {
          // fUser.managedEntities.clear();
          //   writeData(fUser);
          entitiesList = fUser.managedEntities;

          //  saveEntityDetails(new EntityAppData());
        });
    });
  }

  void _addNewServiceRow() {
    setState(() {
      var uuid = new Uuid();
      String _entityId = uuid.v1();
      EntityAppData en = new EntityAppData.eType(_entityType, _entityId);
      entitiesList.add(en);
      //  entity.childCollection.add(c);
      saveEntityDetails(en);
      //saveEntityDetails();
      _count = _count + 1;
    });
  }

  Widget _buildServiceItem(EntityAppData childEntity) {
    return new EntityRow(entity: childEntity);
  }

  @override
  Widget build(BuildContext context) {
    final BoxDecoration indigoContainer = new BoxDecoration(
        border: Border.all(color: Colors.indigo),
        shape: BoxShape.rectangle,
        color: Colors.indigo,
        borderRadius: BorderRadius.all(Radius.circular(5.0)));

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

    return MaterialApp(
      title: 'Add child entities',
      //theme: ThemeData.light().copyWith(),
      home: Scaffold(
        appBar: AppBar(
            title: Row(
              children: <Widget>[
                IconButton(
                  icon: Icon(Icons.arrow_back),
                  onPressed: () {
                    saveEntityDetails(entity);
                    Navigator.of(context).pop();
                  },
                ),
                Text(
                  'Apartment Amenities',
                ),
              ],
            ),
            backgroundColor: Colors.teal,
            //Theme.of(context).primaryColor,
            actions: <Widget>[]),
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
                      // padding: EdgeInsets.all(5.0),

                      child: Column(
                        children: <Widget>[
                          Container(
                            height: MediaQuery.of(context).size.width * .13,
                            decoration: indigoContainer,
                            child: ListTile(
                              //key: PageStorageKey(this.widget.headerTitle),
                              leading: Padding(
                                padding:
                                    const EdgeInsets.fromLTRB(0, 0, 0, 10.0),
                                child: Icon(
                                  Icons.home,
                                  size: 35,
                                  color: Colors.white,
                                ),
                              ),
                              title: Row(
                                children: <Widget>[
                                  Column(
                                    children: <Widget>[
                                      Text(
                                        //entity.name
                                        "My Home Vihanga",
                                        style: TextStyle(
                                            color: Colors.white, fontSize: 15),
                                      ),
                                      Text(
                                        // entity.adrs.locality +
                                        //     ", " +
                                        //     entity.adrs.city +
                                        //     "."
                                        "Gachibowli, Hyderabad",
                                        style: buttonXSmlTextStyle,
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                          subEntityType,
                          (_msg != null)
                              ? Text(
                                  _msg,
                                  style: errorTextStyle,
                                )
                              : Container(),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: <Widget>[
                              //                           subEntityType,
                              Container(
                                padding: EdgeInsets.fromLTRB(0, 0, 5, 0),
                                decoration: BoxDecoration(
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(5.0))),
                                //height: MediaQuery.of(context).size.width * .2,
                                child: RaisedButton(
                                  color: Colors.amberAccent,
                                  elevation: 20,
                                  splashColor: Colors.orange,
                                  shape: RoundedRectangleBorder(
                                      side: BorderSide(color: highlightColor)),
                                  onPressed: () {
                                    if (_entityType != null) {
                                      setState(() {
                                        _msg = null;
                                      });
                                      if (_formKey.currentState.validate()) {
                                        _formKey.currentState.save();
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
                                  child: Container(
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: <Widget>[
                                        Text(
                                          'Add Amenities',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 16,
                                          ),
                                        ),
                                        Icon(Icons.add_circle,
                                            size: 30, color: Colors.white),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  if (!Utils.isNullOrEmpty(entitiesList))
                    new Expanded(
                      child: ListView.builder(
                        shrinkWrap: true,
                        //scrollDirection: Axis.vertical,
                        itemBuilder: (BuildContext context, int index) {
                          return Container(
                            child: new Column(
                                children: entitiesList
                                    .map(_buildServiceItem)
                                    .toList()),
                            //children: <Widget>[firstRow, secondRow],
                          );
                        },
                        itemCount: 1,
                      ),
                    ),

                  // new Column(
                  //   children: _contatos,
                  // ),
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
