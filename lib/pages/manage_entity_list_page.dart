import 'dart:ffi';

import 'package:flutter/material.dart';
import 'package:noq/constants.dart';
import 'package:noq/db/db_model/entity.dart';
import 'package:noq/db/db_model/meta_entity.dart';
import 'package:noq/enum/entity_type.dart';
import 'package:noq/events/event_bus.dart';
import 'package:noq/events/events.dart';
import 'package:noq/global_state.dart';
import 'package:noq/pages/entity_item.dart';
import 'package:noq/repository/StoreRepository.dart';
import 'package:noq/services/circular_progress.dart';
import 'package:noq/style.dart';
import 'package:noq/userHomePage.dart';
import 'package:noq/utils.dart';
import 'package:noq/widget/appbar.dart';
import 'package:noq/widget/page_animation.dart';
import 'package:noq/widget/widgets.dart';
import 'package:uuid/uuid.dart';
import 'package:eventify/eventify.dart' as Eventify;

class ManageEntityListPage extends StatefulWidget {
  @override
  _ManageEntityListPageState createState() => _ManageEntityListPageState();
}

class _ManageEntityListPageState extends State<ManageEntityListPage> {
  List<MetaEntity> metaEntitiesList;
  Entity entity;
  EntityType _entityType;
  ScrollController _scrollController;
  double itemSize;
  List<String> entityTypes;
  GlobalState _gs;
  bool stateInitFinished = false;

  bool _initCompleted = false;
  EntityType categoryType;
  PersistentBottomSheetController bottomSheetController;
  final manageEntityListPagekey = new GlobalKey<ScaffoldState>();
  //Eventify.Listener _eventListener;

  Widget _buildCategoryItem(BuildContext context, EntityType type) {
    String name = Utils.getEntityTypeDisplayName(type);
    Widget image = Utils.getEntityTypeImage(type, 30);

    return GestureDetector(
        onTap: () {
          categoryType = type;
          bottomSheetController.close();
          bottomSheetController = null;
          //   Navigator.of(context).pop();
          setState(() {
            _entityType = type;
          });
          //If user has selected any type then add a row else show msg to user
          if (_entityType != null) {
            _addNewServiceRow();
          } else {
            //Utils.showMyFlushbar(context, icon, duration, title, msg)
            print("Select sth ");
          }
          // EventBus.fireEvent(SEARCH_CATEGORY_SELECTED, null, categoryType);
        },
        child: Container(
            width: MediaQuery.of(context).size.width * .2,
            child: Column(
              children: <Widget>[
                Container(
                    padding: EdgeInsets.all(8),
                    margin: EdgeInsets.all(0),
                    width: MediaQuery.of(context).size.width * .15,
                    height: MediaQuery.of(context).size.width * .12,
                    child: image),
                Text(
                  name,
                  textAlign: TextAlign.center,
                  style: textBotSheetTextStyle,
                ),
              ],
            )));
  }

  // void registerCategorySelectEvent() {
  //   _eventListener =
  //       EventBus.registerEvent(SEARCH_CATEGORY_SELECTED, null, (event, arg) {
  //     if (event == null) {
  //       return;
  //     }
  //     String categoryType = event.eventData;
  //     setState(() {
  //       _entityType = categoryType;
  //     });
  //     //If user has selected any type then add a row else show msg to user
  //     if (_entityType != null) {
  //       _addNewServiceRow();
  //     } else {
  //       //Utils.showMyFlushbar(context, icon, duration, title, msg)
  //       print("Select sth ");
  //     }
  //   });
  // }

  @override
  void dispose() {
    super.dispose();
    //EventBus.unregisterEvent(_eventListener);
  }

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    initialize().whenComplete(() {
      setState(() {
        _initCompleted = true;
        itemSize = MediaQuery.of(context).size.height * .28;
        // itemSize = MediaQuery.of(context).size.height * .3 + 200;

        // _scrollController.animateTo(0.0,
        //     curve: Curves.easeInToLinear,
        //     duration: Duration(milliseconds: 200));
      });

      // _scrollController.animateTo(500,
      //     curve: Curves.easeInToLinear, duration: Duration(milliseconds: 200));
      // setState(() {});
    });
    entityTypes = new List<String>();
    // registerCategorySelectEvent();
  }

  Future<void> getGlobalState() async {
    _gs = await GlobalState.getGlobalState();
  }

  initialize() async {
    await getGlobalState();
    metaEntitiesList = List<MetaEntity>();
    if (!Utils.isNullOrEmpty(_gs.getCurrentUser().entities)) {
      //Check if entity is child and parent os same entity is also enlisted in entities then dont show child.
      // Show only first level entities to user.
      for (MetaEntity m in _gs.getCurrentUser().entities) {
        bool isAdminOfParent = false;
        if (m.parentId != null) {
          for (MetaEntity parent in _gs.getCurrentUser().entities) {
            if (parent.entityId == m.parentId) {
              isAdminOfParent = true;
              break;
            }
          }
        }
        if (!isAdminOfParent) {
          metaEntitiesList.add(m);
        }
      }
    }

    entityTypes = _gs.getConfigurations().entityTypes;
    setState(() {
      stateInitFinished = true;
    });
  }

  void _addNewServiceRow() {
    Entity entity = Utils.createEntity(_entityType);
    _gs.putEntity(entity, false);
    MetaEntity metaEn = entity.getMetaEntity();
    //itemSize = MediaQuery.of(context).size.height * .29;
    setState(() {
      metaEntitiesList.add(metaEn);
    });

    if (_scrollController.hasClients)
      _scrollController.animateTo(
          _scrollController.position.maxScrollExtent + itemSize,
          curve: Curves.easeInToLinear,
          duration: Duration(milliseconds: 200));
  }

  @override
  Widget build(BuildContext context) {
    // final subEntityType = new FormField(
    //   builder: (FormFieldState state) {
    //     return InputDecorator(
    //       decoration: InputDecoration(
    //         enabledBorder: InputBorder.none,
    //         focusedBorder: InputBorder.none,
    //         labelText: 'Type of Place',
    //       ),
    //       child: new DropdownButtonHideUnderline(
    //         child: new DropdownButton(
    //           hint: new Text("Select Type of Place"),
    //           value: _entityType,
    //           isDense: true,
    //           onChanged: (newValue) {
    //             setState(() {
    //               _entityType = newValue;
    //               state.didChange(newValue);
    //             });
    //           },
    //           items: entityTypes.map((type) {
    //             return DropdownMenuItem(
    //               value: type,
    //               child: new Text(
    //                 type.toString(),
    //                 style: textInputTextStyle,
    //               ),
    //             );
    //           }).toList(),
    //         ),
    //       ),
    //     );
    //   },
    //   onSaved: (String value) {
    //     _entityType = value;
    //   },
    // );

    String title = pageTitleManageEntityList;
    if (_initCompleted) {
      return MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData.light().copyWith(),
        home: new WillPopScope(
          child: Scaffold(
            key: manageEntityListPagekey,
            appBar: CustomAppBarWithBackButton(
              backRoute: UserHomePage(),
              titleTxt: title,
            ),
            body: Center(
              child: Column(
                children: <Widget>[
                  Card(
                    elevation: 8,
                    margin:
                        EdgeInsets.all(MediaQuery.of(context).size.width * .03),
                    child: Container(
                      padding: EdgeInsets.all(5),
                      decoration: BoxDecoration(
                          border: Border.all(color: highlightColor),
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
                  if (!Utils.isNullOrEmpty(metaEntitiesList))
                    Expanded(
                      child: Align(
                        alignment: Alignment.topCenter,
                        child: ListView.builder(
                          padding: EdgeInsets.all(
                              MediaQuery.of(context).size.width * .026),
                          controller: _scrollController,
                          reverse: true,
                          shrinkWrap: true,
                          itemExtent: itemSize,
                          itemBuilder: (BuildContext context, int index) {
                            return Container(
                              margin: EdgeInsets.only(bottom: 5),
                              child: EntityRow(
                                entity: metaEntitiesList[index],
                              ),
                            );
                          },
                          itemCount: metaEntitiesList.length,
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
            if (bottomSheetController != null) {
              bottomSheetController.close();
              bottomSheetController = null;
              return false;
            } else {
              //Navigator.of(context).pop();
              Navigator.of(context)
                  .push(PageAnimation.createRoute(UserHomePage()));
              return false;
            }
          },
        ),
      );
    } else {
      return MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData.light().copyWith(),
        home: new WillPopScope(
          child: Scaffold(
            key: manageEntityListPagekey,
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
          ),
          onWillPop: () async {
            return true;
          },
        ),
      );
    }
  }

  showCategorySheet() {
    bottomSheetController =
        manageEntityListPagekey.currentState.showBottomSheet<Null>(
      (context) => Container(
        color: Colors.cyan[50],
        height: MediaQuery.of(context).size.height * .7,
        child: Column(
          children: <Widget>[
            Container(
              color: Colors.cyan[200],
              child: Row(
                children: <Widget>[
                  Container(
                    padding: EdgeInsets.all(0),
                    width: MediaQuery.of(context).size.width * .1,
                    height: MediaQuery.of(context).size.width * .1,
                    child: IconButton(
                        padding: EdgeInsets.all(0),
                        icon: Icon(
                          Icons.cancel,
                          color: headerBarColor,
                        ),
                        onPressed: () {
                          bottomSheetController.close();
                          bottomSheetController = null;
                          // Navigator.of(context).pop();
                        }),
                  ),
                  Container(
                      alignment: Alignment.center,
                      width: MediaQuery.of(context).size.width * .8,
                      child: Text(
                        SELECT_TYPE_OF_PLACE,
                        style: TextStyle(
                            color: Colors.blueGrey[800],
                            fontFamily: 'RalewayRegular',
                            fontSize: 19.0),
                      )),
                ],
              ),
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
                  itemCount: _gs.getActiveEntityTypes().length,
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
                          child: _buildCategoryItem(
                              context, _gs.getActiveEntityTypes()[index]),
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
