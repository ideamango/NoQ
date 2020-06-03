import 'dart:io';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:noq/constants.dart';
import 'package:noq/models/localDB.dart';
import 'package:noq/pages/service_entity.dart';
import 'package:noq/repository/local_db_repository.dart';
import 'package:noq/services/authService.dart';
import 'package:noq/services/qr_code_generate.dart';
import 'package:noq/style.dart';
import 'package:noq/utils.dart';

import 'package:path_provider/path_provider.dart';
import 'package:flutter/foundation.dart';

class ChildEntityDetailsPage extends StatefulWidget {
  final EntityAppData entity;
  ChildEntityDetailsPage({Key key, @required this.entity}) : super(key: key);
  @override
  _ChildEntityDetailsPageState createState() => _ChildEntityDetailsPageState();
}

class _ChildEntityDetailsPageState extends State<ChildEntityDetailsPage> {
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
    entity.childCollection = new List<ChildEntityAppData>();
  }

  void _addNewServiceRow() {
    setState(() {
      servicesList.add(new ChildEntityAppData.cType(_subEntityType));
      _count = _count + 1;
    });
  }

  Widget _buildServiceItem(ChildEntityAppData childEntity) {
    return new ServiceRow(childEntity: childEntity);
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> _contatos = new List.generate(
        _count,
        (int i) => new ServiceRow(
              childEntity: null,
            ));

    final BoxDecoration indigoContainer = new BoxDecoration(
        border: Border.all(color: Colors.indigo),
        shape: BoxShape.rectangle,
        color: Colors.indigo,
        borderRadius: BorderRadius.all(Radius.circular(5.0)));

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
        entity.childCollection.add(new ChildEntityAppData.cType(value));
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
                  onPressed: () => Navigator.of(context).pop(),
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
                                    if (_subEntityType != null) {
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

                  // new Expanded(
                  //   child: new ListView.builder(
                  //     itemBuilder: (BuildContext context, int index) {
                  //       return Container(
                  //         child: new Column(children: _contatos),
                  //         //children: <Widget>[firstRow, secondRow],
                  //       );
                  //     },
                  //     itemCount: 1,
                  //   ),
                  // ),
                  new Expanded(
                    child: ListView.builder(
                      shrinkWrap: true,
                      //scrollDirection: Axis.vertical,
                      itemBuilder: (BuildContext context, int index) {
                        return Container(
                          child: new Column(
                              children:
                                  servicesList.map(_buildServiceItem).toList()),
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
