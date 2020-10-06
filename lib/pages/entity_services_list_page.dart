import 'package:flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import 'package:noq/constants.dart';
import 'package:noq/db/db_model/entity.dart';
import 'package:noq/db/db_model/meta_entity.dart';
import 'package:noq/db/db_service/entity_service.dart';
import 'package:noq/global_state.dart';
import 'package:noq/pages/service_entity.dart';
import 'package:noq/repository/local_db_repository.dart';
import 'package:noq/services/circular_progress.dart';
import 'package:noq/style.dart';
import 'package:flutter/foundation.dart';
import 'package:noq/userHomePage.dart';
import 'package:noq/utils.dart';
import 'package:noq/widget/appbar.dart';
import 'package:noq/widget/bottom_nav_bar.dart';
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
  ScrollController _childScrollController;
  final itemSize = 100.0;
  final String title = "Child Amenities Details Form";
  Map<String, Entity> _entityMap = Map<String, Entity>();

  Entity parentEntity;
  String _subEntityType;
  bool _initCompleted = false;
  List<String> subEntityTypes;
  GlobalState _state;

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
    _childScrollController = ScrollController();
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
    initialize().whenComplete(() {
      setState(() {
        _initCompleted = true;
      });
    });

    // subEntityTypes = new List<String>();
  }

  Future<void> getGlobalState() async {
    _state = await GlobalState.getGlobalState();
  }

  initialize() async {
    await getGlobalState();
    subEntityTypes = _state.conf.entityTypes;
  }

  void _addNewServiceRow() {
    var uuid = new Uuid();
    String serviceId = uuid.v1();
    Entity en = new Entity();
    en.type = _subEntityType;
    en.entityId = serviceId;
    en.parentId = parentEntity.entityId;
    MetaEntity meta;
    setState(() {
      _entityMap[en.entityId] = en;
      meta = en.getMetaEntity();
      servicesList.add(meta);
      _count = _count + 1;
    });
    _state.addEntity(meta);
    if (_childScrollController.hasClients)
      _childScrollController.animateTo(
          _childScrollController.position.maxScrollExtent + itemSize,
          curve: Curves.easeInToLinear,
          duration: Duration(milliseconds: 200));
  }

  // Widget _buildServiceItem(MetaEntity childEntity) {
  //   return new ChildEntityRow(childEntity: childEntity, entityMap: _entityMap);
  // }

  @override
  Widget build(BuildContext context) {
    final subEntityType = new FormField(
      builder: (FormFieldState state) {
        return InputDecorator(
          decoration: InputDecoration(
            enabledBorder: InputBorder.none,
            focusedBorder: InputBorder.none,
            //  icon: const Icon(Icons.person),
            labelText: 'Type of Premise/Amenity',
          ),
          child: new DropdownButtonHideUnderline(
            child: new DropdownButton(
              hint: new Text("Select type of premise/amenity"),
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
    String title = "Manage child premises/amenities";
    if (_initCompleted) {
      return MaterialApp(
        title: 'Add child premises/amenities',
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

                    Navigator.of(context).pop();
                  }),
              title: Text(
                title,
                style: TextStyle(color: Colors.white, fontSize: 16),
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
                            borderRadius:
                                BorderRadius.all(Radius.circular(5.0))),
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
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: <Widget>[
                                      Text(
                                        "Add child premises/amenities",
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
                                            _msg = "Select Entity type";
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
                      child: Align(
                        alignment: Alignment.topCenter,
                        child: ListView.builder(
                          controller: _childScrollController,
                          reverse: true,
                          shrinkWrap: true,
                          itemExtent: itemSize,
                          //scrollDirection: Axis.vertical,
                          itemBuilder: (BuildContext context, int index) {
                            return Container(
                              //  height: MediaQuery.of(context).size.height * .3,
                              child: ChildEntityRow(
                                  childEntity: servicesList[index],
                                  entityMap: _entityMap),
                            );
                          },
                          itemCount: servicesList.length,
                        ),
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
    } else {
      return MaterialApp(
        theme: ThemeData.light().copyWith(),
        home: Scaffold(
          appBar: CustomAppBarWithBackButton(
            backRoute: UserHomePage(),
            titleTxt: title,
          ),

          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                showCircularProgress(),
              ],
            ),
          ),
          //drawer: CustomDrawer(),
          bottomNavigationBar: CustomBottomBar(barIndex: 0),
        ),
      );
    }
  }
}
