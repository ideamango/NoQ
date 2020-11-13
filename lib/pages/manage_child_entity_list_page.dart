import 'package:flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import 'package:noq/constants.dart';
import 'package:noq/db/db_model/entity.dart';
import 'package:noq/db/db_model/meta_entity.dart';
import 'package:noq/db/db_service/entity_service.dart';
import 'package:noq/global_state.dart';
import 'package:noq/pages/manage_entity_list_page.dart';
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
import 'package:noq/events/event_bus.dart';
import 'package:noq/events/events.dart';
import 'package:eventify/eventify.dart' as Eventify;
import 'package:noq/widget/widgets.dart';

import '../tuple.dart';

class ManageChildEntityListPage extends StatefulWidget {
  final Entity entity;
  ManageChildEntityListPage({Key key, @required this.entity}) : super(key: key);
  @override
  _ManageChildEntityListPageState createState() =>
      _ManageChildEntityListPageState();
}

class _ManageChildEntityListPageState extends State<ManageChildEntityListPage> {
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
  String categoryType;
  PersistentBottomSheetController childBottomSheetController;
  final manageChildEntityListPagekey = new GlobalKey<ScaffoldState>();
  Eventify.Listener _eventListener;

  Widget _buildCategoryItem(BuildContext context, int index) {
    String name = subEntityTypes[index];
    Widget image = Utils.getEntityTypeImage(name, 30);

    return GestureDetector(
        onTap: () {
          categoryType = name;
          childBottomSheetController.close();
          childBottomSheetController = null;
          //   Navigator.of(context).pop();
          EventBus.fireEvent(SEARCH_CATEGORY_SELECTED, null, categoryType);
        },
        child: Column(
          children: <Widget>[
            Container(
                padding: EdgeInsets.all(0),
                width: MediaQuery.of(context).size.width * .15,
                height: MediaQuery.of(context).size.width * .15,
                child: image),
            Text(
              name,
              textAlign: TextAlign.center,
              style: textBotSheetTextStyle,
            ),
          ],
        ));
  }

  void registerCategorySelectEvent() {
    _eventListener =
        EventBus.registerEvent(SEARCH_CATEGORY_SELECTED, null, (event, arg) {
      if (event == null) {
        return;
      }
      String categoryType = event.eventData;
      setState(() {
        _subEntityType = categoryType;
      });
      //If user has selected any type then add a row else show msg to user
      if (_subEntityType != null) {
        _addNewServiceRow();
      } else {
        //Utils.showMyFlushbar(context, icon, duration, title, msg)
        print("Select sth ");
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
    EventBus.unregisterEvent(_eventListener);
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
    registerCategorySelectEvent();
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
    _state
        .createEntity(serviceId, _subEntityType, parentEntity.entityId)
        .then((value) {
      Entity en = value;
      // en.type = _subEntityType;
      // en.entityId = serviceId;
      // en.parentId = parentEntity.entityId;
      MetaEntity meta;
      setState(() {
        _entityMap[en.entityId] = en;
        meta = en.getMetaEntity();
        servicesList.add(meta);
        _count = _count + 1;
      });
      _state.addEntityToCurrentUser(en, false);
      if (_childScrollController.hasClients)
        _childScrollController.animateTo(
            _childScrollController.position.maxScrollExtent + itemSize,
            curve: Curves.easeInToLinear,
            duration: Duration(milliseconds: 200));
    });
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
            labelText: 'Type of Place',
          ),
          child: new DropdownButtonHideUnderline(
            child: new DropdownButton(
              hint: new Text("Select type of Place"),
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
        // setState(() {
        //   _msg = null;
        // });
        // entity.childCollection
        //    .add(new ChildEntityAppData.cType(value, entity.id));
        //   saveEntityDetails(entity);
      },
    );
    String title = "Manage child Places";
    if (_initCompleted) {
      return MaterialApp(
        title: 'Add a child Place',
        //theme: ThemeData.light().copyWith(),
        home: WillPopScope(
          child: Scaffold(
            key: manageChildEntityListPagekey,
            appBar: CustomAppBarWithBackButton(
              backRoute: ManageEntityListPage(),
              titleTxt: title,
            ),
            body: Center(
              child: Column(
                children: <Widget>[
                  Card(
                    elevation: 20,
                    margin:
                        EdgeInsets.all(MediaQuery.of(context).size.width * .03),
                    child: Container(
                      padding: EdgeInsets.all(5),
                      decoration: BoxDecoration(
                          border: Border.all(color: borderColor),
                          color: Colors.white,
                          shape: BoxShape.rectangle,
                          borderRadius: BorderRadius.all(Radius.circular(5.0))),
                      child: InkWell(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            Text(" Add a new Place",
                                style: TextStyle(
                                    fontSize: 18, color: Colors.blueGrey[700])),
                            horizontalSpacer,
                            Icon(Icons.add_circle,
                                color: highlightColor, size: 40),
                          ],
                        ),
                        onTap: () {
                          print("Tappped");
                          showCategorySheet();
                        },
                      ),
                    ),
                  ),
                  if (!Utils.isNullOrEmpty(servicesList))
                    new Expanded(
                      child: Align(
                        alignment: Alignment.topCenter,
                        child: ListView.builder(
                          padding: EdgeInsets.all(
                              MediaQuery.of(context).size.width * .026),
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
                  verticalSpacer,
                  verticalSpacer,
                ],
              ),
            ),
          ),
          onWillPop: () async {
            if (childBottomSheetController != null) {
              childBottomSheetController.close();
              childBottomSheetController = null;
              return false;
            } else {
              //Navigator.of(context).pop();
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => ManageEntityListPage()));
              return false;
            }
          },
        ),
      );
    } else {
      return MaterialApp(
        theme: ThemeData.light().copyWith(),
        home: WillPopScope(
          child: Scaffold(
            key: manageChildEntityListPagekey,
            appBar: CustomAppBarWithBackButton(
              backRoute: ManageEntityListPage(),
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
          onWillPop: () async {
            return true;
          },
        ),
      );
    }
  }

  showCategorySheet() {
    childBottomSheetController =
        manageChildEntityListPagekey.currentState.showBottomSheet<Null>(
      (context) => Container(
        color: Colors.cyan[50],
        height: MediaQuery.of(context).size.height * .7,
        child: Column(
          children: <Widget>[
            Row(
              children: <Widget>[
                Container(
                  padding: EdgeInsets.all(0),
                  width: MediaQuery.of(context).size.width * .1,
                  height: MediaQuery.of(context).size.width * .1,
                  child: IconButton(
                      padding: EdgeInsets.all(0),
                      icon: Icon(
                        Icons.cancel,
                        color: btnDisabledolor,
                      ),
                      onPressed: () {
                        childBottomSheetController.close();
                        childBottomSheetController = null;
                        // Navigator.of(context).pop();
                      }),
                ),
                Container(
                    alignment: Alignment.center,
                    width: MediaQuery.of(context).size.width * .8,
                    child: Text(
                      SELECT_TYPE_OF_PLACE,
                      style: textInputTextStyle,
                    )),
              ],
            ),
            Divider(
              height: 1,
              color: primaryDarkColor,
            ),
            Expanded(
              child: Container(
                padding: EdgeInsets.all(0),
                child: new GridView.builder(
                  padding: EdgeInsets.all(0),
                  scrollDirection: Axis.vertical,
                  shrinkWrap: true,
                  itemCount: subEntityTypes.length,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 4,
                      crossAxisSpacing: 10.0,
                      mainAxisSpacing: 10),
                  itemBuilder: (BuildContext context, int index) {
                    return new GridTile(
                      child: Container(
                        height: MediaQuery.of(context).size.height * .25,
                        padding: EdgeInsets.all(0),
                        // decoration:
                        //     BoxDecoration(border: Border.all(color: Colors.black, width: 0.5)),
                        child: Center(
                          child: _buildCategoryItem(context, index),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
      elevation: 30,
      clipBehavior: Clip.hardEdge,
      shape: RoundedRectangleBorder(
          side: BorderSide(color: Colors.blueGrey[200]),
          borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20.0), topRight: Radius.circular(20.0))),
    );
  }
}
