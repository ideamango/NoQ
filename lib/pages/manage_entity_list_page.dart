import 'package:flutter/material.dart';
import 'package:noq/db/db_model/entity.dart';
import 'package:noq/db/db_model/meta_entity.dart';
import 'package:noq/global_state.dart';
import 'package:noq/pages/entity_item.dart';
import 'package:noq/repository/StoreRepository.dart';
import 'package:noq/services/circular_progress.dart';
import 'package:noq/style.dart';
import 'package:noq/userHomePage.dart';
import 'package:noq/utils.dart';
import 'package:noq/widget/appbar.dart';
import 'package:uuid/uuid.dart';

class ManageEntityListPage extends StatefulWidget {
  @override
  _ManageEntityListPageState createState() => _ManageEntityListPageState();
}

class _ManageEntityListPageState extends State<ManageEntityListPage> {
  String _msg;
  final GlobalKey<FormState> _entityListFormKey = new GlobalKey<FormState>();
  List<MetaEntity> metaEntitiesList;
  Entity entity;
  String _entityType;
  ScrollController _scrollController;
  final itemSize = 100.0;
  List<String> entityTypes;

  GlobalState _state;
  bool stateInitFinished = false;
  Map<String, Entity> _parentEntityMap = Map<String, Entity>();
  bool _initCompleted = false;
  @override
  void dispose() {
    super.dispose();
  }

  @override
  void initState() {
    _scrollController = ScrollController();
    super.initState();
    initialize().whenComplete(() {
      setState(() {
        _initCompleted = true;
      });
    });
    entityTypes = new List<String>();
  }

  Future<void> getGlobalState() async {
    _state = await GlobalState.getGlobalState();
  }

  initialize() async {
    await getGlobalState();
    metaEntitiesList = List<MetaEntity>();
    if (!Utils.isNullOrEmpty(_state.currentUser.entities)) {
//Check if entity is child and parent os same entity is also enlisted in entities then dont show child.
// Show only first level entities to user.
      for (int i = 0; i < _state.currentUser.entities.length; i++) {
        MetaEntity m = _state.currentUser.entities[i];
        // print(m.name + '::' + parentName);

        bool isAdminOfParent = false;
        if (m.parentId != null) {
          for (MetaEntity parent in _state.currentUser.entities) {
            if (parent.entityId == m.parentId) {
              isAdminOfParent = true;
              continue;
            }
          }
        }

        if (!isAdminOfParent) {
          metaEntitiesList.add(m);
        }
      }
      // metaEntitiesList = _state.currentUser.entities;
    }

    entityTypes = _state.conf.entityTypes;
    setState(() {
      stateInitFinished = true;
    });
  }

  void _addNewServiceRow() {
    var uuid = new Uuid();
    String _entityId = uuid.v1();
    entity = createEntity(_entityId, _entityType);

    MetaEntity metaEn = entity.getMetaEntity();

    setState(() {
      metaEntitiesList.add(metaEn);
    });
    _state.addEntity(metaEn);

    _parentEntityMap[metaEn.entityId] = entity;
    if (_scrollController.hasClients)
      _scrollController.animateTo(
          _scrollController.position.maxScrollExtent + itemSize,
          curve: Curves.easeInToLinear,
          duration: Duration(milliseconds: 200));
  }

  @override
  Widget build(BuildContext context) {
    final subEntityType = new FormField(
      builder: (FormFieldState state) {
        return InputDecorator(
          decoration: InputDecoration(
            enabledBorder: InputBorder.none,
            focusedBorder: InputBorder.none,
            labelText: 'Type of Place',
          ),
          child: new DropdownButtonHideUnderline(
            child: new DropdownButton(
              hint: new Text("Select Type of Place"),
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
    String title = "Manage your Places";
    if (_initCompleted) {
      return MaterialApp(
        theme: ThemeData.light().copyWith(),
        home: Scaffold(
          appBar: CustomAppBarWithBackButton(
            backRoute: UserHomePage(),
            titleTxt: title,
          ),
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
                                Text(
                                  "Add Places to manage",
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
                                          _entityListFormKey.currentState
                                              .save();
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
                  if (!Utils.isNullOrEmpty(metaEntitiesList))
                    Expanded(
                      child: Align(
                        alignment: Alignment.topCenter,
                        child: ListView.builder(
                          controller: _scrollController,
                          reverse: true,
                          shrinkWrap: true,
                          itemExtent: itemSize,
                          // shrinkWrap: true,
                          itemBuilder: (BuildContext context, int index) {
                            return Container(
                              child: EntityRow(
                                  entity: metaEntitiesList[index],
                                  parentEntityMap: _parentEntityMap),
                            );
                          },
                          itemCount: metaEntitiesList.length,
                        ),
                      ),
                    ),
                ],
              ),
              // bottomNavigationBar: buildBottomItems()
            ),
          ),
          // bottomNavigationBar: CustomBottomBar(
          //   barIndex: 0,
          // ),
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
          // bottomNavigationBar: CustomBottomBar(barIndex: 0),
        ),
      );
    }
  }
}