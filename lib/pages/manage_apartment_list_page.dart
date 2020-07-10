import 'package:flutter/material.dart';
import 'package:noq/constants.dart';
import 'package:noq/db/db_model/entity.dart';
import 'package:noq/db/db_model/meta_entity.dart';
import 'package:noq/global_state.dart';
import 'package:noq/pages/entity_item.dart';
import 'package:noq/style.dart';
import 'package:noq/userHomePage.dart';
import 'package:noq/utils.dart';
import 'package:noq/widget/appbar.dart';
import 'package:noq/widget/bottom_nav_bar.dart';
import 'package:uuid/uuid.dart';

class ManageApartmentsListPage extends StatefulWidget {
  @override
  _ManageApartmentsListPageState createState() =>
      _ManageApartmentsListPageState();
}

class _ManageApartmentsListPageState extends State<ManageApartmentsListPage> {
  String _msg;
  final GlobalKey<FormState> _entityListFormKey = new GlobalKey<FormState>();
  List<MetaEntity> metaEntitiesList;
  Entity entity;
  String _entityType;
  int _count = 0;
  GlobalState _state;
  bool stateInitFinished = false;

  @override
  void dispose() {
    super.dispose();
  }

  @override
  void initState() {
    super.initState();

    getEntityList();
  }

  Future<void> getGlobalState() async {
    _state = await GlobalState.getGlobalState();
  }

  void getEntityList() async {
    await getGlobalState();
    if (!Utils.isNullOrEmpty(_state.currentUser.entities)) {
      metaEntitiesList = _state.currentUser.entities;
    } else
      metaEntitiesList = List<MetaEntity>();

    setState(() {
      stateInitFinished = true;
    });
  }

  void _addNewServiceRow() {
    setState(() {
      var uuid = new Uuid();
      String _entityId = uuid.v1();

      MetaEntity metaEn = MetaEntity.withValues(entityId: _entityId, type: _entityType);
      // TODO: Create Entity with given id and type.

      metaEntitiesList.add(metaEn);
      // saveEntityDetails(en);
      _count = _count + 1;
    });
  }

  Widget _buildServiceItem(MetaEntity childEntity) {
    return new EntityRow(entity: childEntity);
  }

  @override
  Widget build(BuildContext context) {
    final subEntityType = new FormField(
      builder: (FormFieldState state) {
        return InputDecorator(
          decoration: InputDecoration(
            enabledBorder: InputBorder.none,
            focusedBorder: InputBorder.none,
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
        appBar: CustomAppBarWithBackButton(
          backRoute: UserHomePage(),
          titleTxt: title,
        ),
        // appBar: AppBar(
        //     actions: <Widget>[],
        //     flexibleSpace: Container(
        //       decoration: gradientBackground,
        //     ),
        //     leading: IconButton(
        //         padding: EdgeInsets.all(0),
        //         alignment: Alignment.center,
        //         highlightColor: Colors.orange[300],
        //         icon: Icon(Icons.arrow_back),
        //         color: Colors.white,
        //         onPressed: () {
        //           Navigator.of(context).pop();
        //           Navigator.push(context,
        //               MaterialPageRoute(builder: (context) => UserHomePage()));
        //         }),
        //     title: Text(
        //       title,
        //       style: TextStyle(color: Colors.white, fontSize: 16),
        //       overflow: TextOverflow.ellipsis,
        //     )),
        //
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
                if (!Utils.isNullOrEmpty(metaEntitiesList))
                  new Expanded(
                    child: ListView.builder(
                      shrinkWrap: true,
                      itemBuilder: (BuildContext context, int index) {
                        return Container(
                          child: new Column(
                              children: metaEntitiesList
                                  .map(_buildServiceItem)
                                  .toList()),
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
        bottomNavigationBar: CustomBottomBar(
          barIndex: 0,
        ),
      ),
    );
  }
}
