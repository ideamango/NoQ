import 'package:flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import 'package:noq/constants.dart';
import 'package:noq/db/db_model/entity.dart';
import 'package:noq/db/db_model/meta_entity.dart';
import 'package:noq/db/db_service/entity_service.dart';
import 'package:noq/pages/service_entity.dart';
import 'package:noq/repository/local_db_repository.dart';
import 'package:noq/style.dart';
import 'package:flutter/foundation.dart';
import 'package:noq/utils.dart';
import 'package:uuid/uuid.dart';

class ChildEntitiesListPage extends StatefulWidget {
  final Entity entity;
  ChildEntitiesListPage({Key key, @required this.entity}) : super(key: key);
  @override
  _ChildEntitiesListPageState createState() => _ChildEntitiesListPageState();
}

class _ChildEntitiesListPageState extends State<ChildEntitiesListPage> {
  String _msg;
  final GlobalKey<FormState> _servicesListFormKey = new GlobalKey<FormState>();
  List<MetaEntity> servicesList = new List<MetaEntity>();
  final String title = "Child Entities Detail Form";
  Map<String, Entity> _entityMap = Map<String, Entity>();

  Entity parentEntity;
  String _subEntityType;
  bool _initCompleted = false;

//Add service Row

  int _count = 0;
  @override
  void dispose() {
    super.dispose();
  }

  Future<Entity> getEntityById(String id) async {
    Entity e = await EntityService().getEntity(id);
    return e;
  }

  @override
  void initState() {
    super.initState();
    parentEntity = widget.entity;
    if (parentEntity == null)
      servicesList = List<MetaEntity>();
    else {
      if (!Utils.isNullOrEmpty(parentEntity.childEntities))
        setState(() {
          servicesList = parentEntity.childEntities;
          // for (int i = 0; i < servicesList.length; i++) {
          //   _entityMap[servicesList[i].entityId] = servicesList[i];
          // }
        });
    }
  }

  void _addNewServiceRow() {
    setState(() {
      var uuid = new Uuid();
      String serviceId = uuid.v1();
      Entity en = new Entity();
      en.type = _subEntityType;
      en.entityId = serviceId;
      en.parentId = parentEntity.entityId;

      _entityMap[en.entityId] = en;

      MetaEntity meta = en.getMetaEntity();
      servicesList.add(meta);
      _count = _count + 1;
    });
  }

  Widget _buildServiceItem(MetaEntity childEntity) {
    return new ChildEntityRow(childEntity: childEntity, entityMap: _entityMap);
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
        ((parentEntity != null)
            ? ((parentEntity.name == null)
                ? parentEntity.type
                : parentEntity.name)
            : 'XXX');
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
                  // saveEntityDetails(parentEntity);
                  print("going back");
                  //Show flush bar to notify user
                  // Flushbar(
                  //   //padding: EdgeInsets.zero,
                  //   margin: EdgeInsets.zero,
                  //   flushbarPosition: FlushbarPosition.BOTTOM,
                  //   flushbarStyle: FlushbarStyle.FLOATING,
                  //   reverseAnimationCurve: Curves.decelerate,
                  //   forwardAnimationCurve: Curves.easeInToLinear,
                  //   backgroundColor: headerBarColor,
                  //   boxShadows: [
                  //     BoxShadow(
                  //         color: primaryAccentColor,
                  //         offset: Offset(0.0, 2.0),
                  //         blurRadius: 3.0)
                  //   ],
                  //   isDismissible: false,
                  //   duration: Duration(seconds: 4),
                  //   icon: Icon(
                  //     Icons.save,
                  //     color: Colors.blueGrey[50],
                  //   ),
                  //   showProgressIndicator: true,
                  //   progressIndicatorBackgroundColor: Colors.blueGrey[800],
                  //   routeBlur: 10.0,
                  //   titleText: Text(
                  //     "Go Back to Home",
                  //     style: TextStyle(
                  //         fontWeight: FontWeight.bold,
                  //         fontSize: 16.0,
                  //         color: primaryAccentColor,
                  //         fontFamily: "ShadowsIntoLightTwo"),
                  //   ),
                  //   messageText: Text(
                  //     "The changes you made will not be saved. To Save now, click Cancel.",
                  //     style: TextStyle(
                  //         fontSize: 12.0,
                  //         color: Colors.blueGrey[50],
                  //         fontFamily: "ShadowsIntoLightTwo"),
                  //   ),
                  // )..show(context);

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
                                          (parentEntity.type),
                                      style: TextStyle(
                                          color: Colors.white, fontSize: 15),
                                    ),
                                    //TODO: Smita- uncomment after adding null check
                                    // Text(

                                    //   (parentEntity.address.locality +
                                    //           ", " +
                                    //           parentEntity.address.city +
                                    //           ".") ??
                                    //       "",
                                    //   style: buttonXSmlTextStyle,
                                    // ),
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
