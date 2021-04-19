import 'dart:async';

import 'package:enum_to_string/enum_to_string.dart';
import 'package:flutter/material.dart';
import 'package:noq/constants.dart';
import 'package:noq/db/db_model/employee.dart';
import 'package:noq/db/db_model/entity.dart';
import 'package:noq/db/db_model/meta_entity.dart';
import 'package:noq/enum/entity_type.dart';
import 'package:noq/events/event_bus.dart';
import 'package:noq/events/events.dart';
import 'package:noq/global_state.dart';
import 'package:noq/pages/contact_item.dart';
import 'package:noq/pages/manage_entity_list_page.dart';
import 'package:noq/services/circular_progress.dart';
import 'package:noq/style.dart';
import 'package:noq/utils.dart';
import 'package:noq/widget/appbar.dart';
import 'package:noq/widget/custom_expansion_tile.dart';
import 'package:noq/widget/page_animation.dart';
import 'package:noq/widget/widgets.dart';
import 'package:uuid/uuid.dart';
import 'package:eventify/eventify.dart' as Eventify;

class ManageEmployeePage extends StatefulWidget {
  final MetaEntity metaEntity;
  final DateTime defaultDate;
  final dynamic backRoute;
  ManageEmployeePage(
      {Key key,
      @required this.metaEntity,
      @required this.defaultDate,
      @required this.backRoute})
      : super(key: key);
  @override
  _ManageEmployeePageState createState() => _ManageEmployeePageState();
}

class _ManageEmployeePageState extends State<ManageEmployeePage> {
  List<Employee> contactList = new List<Employee>();
  MetaEntity metaEntity;

  List<Widget> contactRowWidgets = new List<Widget>();
  List<Widget> contactRowWidgetsNew = new List<Widget>();
  bool _initCompleted = false;
  GlobalState _gs;
  String _phCountryCode;
  Entity entity;
  Eventify.Listener removeManagerListener;
  PersistentBottomSheetController bottomSheetController;
  final employeeListPagekey = new GlobalKey<ScaffoldState>();
  @override
  void initState() {
    super.initState();
    metaEntity = this.widget.metaEntity;
    getGlobalState().whenComplete(() {
      _gs.getEntity(metaEntity.entityId).then((value) {
        entity = value.item1;
        initializeEntity().whenComplete(() {
          setState(() {
            _initCompleted = true;
          });
        });
      });
    });

    removeManagerListener = EventBus.registerEvent(
        MANAGER_REMOVED_EVENT, null, this.refreshOnManagerRemove);
  }

  @override
  void dispose() {
    super.dispose();
    print("dispose called for child entity");
    EventBus.unregisterEvent(removeManagerListener);
  }

  Widget getImageForRole(EntityRole role) {
    switch (role) {
      case EntityRole.Admin:
        //Icon(Icons.person)
        break;
      case EntityRole.Manager:
        break;
      case EntityRole.Executive:
        break;
      default:
        Icon(Icons.person);

        break;
    }
    return Icon(Icons.person);
  }

  Widget _buildCategoryItem(BuildContext context, EntityRole type) {
    String name = EnumToString.convertToString(type);
    Widget image = getImageForRole(type);

    return GestureDetector(
        onTap: () {
          // categoryType = type;
          bottomSheetController.close();
          bottomSheetController = null;
          //   Navigator.of(context).pop();
          // setState(() {
          //   _entityType = type;
          // });
          //If user has selected any type then add a row else show msg to user
          // if (_entityType != null) {
          _addNewContactRow();
          //  } else {
          //Utils.showMyFlushbar(context, icon, duration, title, msg)
          print("Select sth ");
          // }
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

  Future<void> getGlobalState() async {
    _gs = await GlobalState.getGlobalState();
    _phCountryCode = _gs.getConfigurations().phCountryCode;
  }

  void refreshOnManagerRemove(event, args) {
    setState(() {
      //  contactRowWidgets.removeWhere((element) => element)
      print("Inside remove Manage");
      contactRowWidgets.clear();
      contactRowWidgets.add(showCircularProgress());
    });
    //refreshContacts();
    processRefreshContactsWithTimer();
    print("printing event.eventData");
    print("In parent page" + event.eventData);
    print(event.eventData);
  }

  processRefreshContactsWithTimer() async {
    var duration = new Duration(seconds: 1);
    return new Timer(duration, refreshContacts);
  }

  initializeEntity() async {
    if (entity != null) {
      //TODO: get entity

      if (!(Utils.isNullOrEmpty(entity.managers))) {
        contactList = entity.managers;
        contactList.forEach((element) {
          contactRowWidgets.add(new ContactRow(
              contact: element, entity: entity, list: contactList));
        });
      }
    }
  }

  refreshContacts() {
    List<Widget> newList = new List<Widget>();
    for (int i = 0; i < contactList.length; i++) {
      newList.add(new ContactRow(
        contact: contactList[i],
        entity: entity,
        list: contactList,
      ));
    }
    setState(() {
      contactRowWidgets.clear();
      contactRowWidgets.addAll(newList);
    });
    entity.managers = contactList;
  }

  void _addNewContactRow() {
    Employee contact = new Employee();
    var uuid = new Uuid();
    contact.id = uuid.v1();
    contactList.add(contact);

    List<Widget> newList = new List<Widget>();
    for (int i = 0; i < contactList.length; i++) {
      newList.add(new ContactRow(
        contact: contactList[i],
        entity: entity,
        list: contactList,
      ));
    }
    setState(() {
      contactRowWidgets.clear();
      contactRowWidgets.addAll(newList);
      entity.managers = contactList;
      // _contactCount = _contactCount + 1;
    });
  }

  @override
  Widget build(BuildContext context) {
    final adminInputField = new TextFormField(
      key: adminPhoneKey,
      autofocus: true,
      inputFormatters: [
        LengthLimitingTextInputFormatter(18),
      ],
      keyboardType: TextInputType.phone,

      controller: _adminItemController,
      cursorColor: highlightColor,
      //cursorWidth: 1,
      style: textInputTextStyle,
      decoration: new InputDecoration(
          contentPadding: EdgeInsets.fromLTRB(5, 7, 5, 7),
          isDense: true,
          prefixStyle: textInputTextStyle,
          // hintStyle: hintTextStyle,
          prefixText: '+91',
          suffixIconConstraints: BoxConstraints(
            maxWidth: 22,
            maxHeight: 22,
          ),
          // contentPadding: EdgeInsets.all(0),
          focusedBorder: InputBorder.none,
          enabledBorder: InputBorder.none,
          hintText: "Enter Admin's Contact number & press (+) (optional)",
          hintStyle: new TextStyle(fontSize: 12, color: Colors.blueGrey[500])),
      validator: Utils.validateMobileField,
      onChanged: (value) {
        adminPhoneKey.currentState.validate();

        setState(() {
          _item = '+91' + value;
          // _errMsg = "";
        });
      },
      onSaved: (newValue) {
        _item = '+91' + newValue;
      },
    );
    if (_initCompleted)
      return MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData.light().copyWith(),
        home: WillPopScope(
          child: Scaffold(
            key: employeeListPagekey,
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
                  print("going back");
                  Navigator.of(context).pop();
                },
              ),
              title: Text(Utils.getEntityTypeDisplayName(entity.type),
                  style: whiteBoldTextStyle1),
            ),
            body: Scrollbar(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Card(
                      elevation: 8,
                      margin: EdgeInsets.all(
                          MediaQuery.of(context).size.width * .03),
                      child: Container(
                        padding: EdgeInsets.all(5),
                        decoration: BoxDecoration(
                            border: Border.all(color: highlightColor),
                            color: Colors.white,
                            shape: BoxShape.rectangle,
                            borderRadius:
                                BorderRadius.all(Radius.circular(5.0))),
                        child: InkWell(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              Text(" Add an Employee",
                                  style: TextStyle(
                                      fontSize: 18,
                                      color: Colors.blueGrey[700])),
                              horizontalSpacer,
                              Icon(Icons.person_add,
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
                    // (_msg != null)
                    //     ? Text(
                    //         _msg,
                    //         style: errorTextStyle,
                    //       )
                    //     : Container(),
                    if (!Utils.isNullOrEmpty(contactList))
                      Column(children: contactRowWidgets),
                    Container(
                      margin: EdgeInsets.all(5),
                      padding: EdgeInsets.all(0),
                      decoration: BoxDecoration(
                          border: Border.all(color: containerColor),
                          color: Colors.grey[50],
                          shape: BoxShape.rectangle,
                          borderRadius: BorderRadius.all(Radius.circular(5.0))),
                      // padding: EdgeInsets.all(5.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Column(
                            children: <Widget>[
                              Container(
                                //padding: EdgeInsets.only(left: 5),
                                decoration: darkContainer,
                                child: Theme(
                                  data: ThemeData(
                                    unselectedWidgetColor: Colors.white,
                                    accentColor: Colors.grey[50],
                                  ),
                                  child: CustomExpansionTile(
                                    //key: PageStorageKey(this.widget.headerTitle),
                                    initiallyExpanded: false,
                                    title: Row(
                                      children: <Widget>[
                                        Text(
                                          "Assign an Admin",
                                          style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 15),
                                        ),
                                        SizedBox(width: 5),
                                      ],
                                    ),
                                    // trailing: IconButton(
                                    //   icon: Icon(Icons.add_circle,
                                    //       color: highlightColor, size: 40),
                                    //   onPressed: () {
                                    //     addNewAdminRow();
                                    //   },
                                    // ),
                                    backgroundColor: Colors.blueGrey[500],
                                    children: <Widget>[
                                      new Container(
                                        width:
                                            MediaQuery.of(context).size.width *
                                                .94,
                                        decoration: darkContainer,
                                        padding: EdgeInsets.all(2.0),
                                        child: Row(
                                          children: <Widget>[
                                            Expanded(
                                              child: Text(adminInfoStr,
                                                  style: buttonXSmlTextStyle),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              //Add Admins list
                              Column(
                                children: <Widget>[
                                  Container(
                                    margin: EdgeInsets.all(4),
                                    padding: EdgeInsets.fromLTRB(0, 0, 4, 0),
                                    height:
                                        MediaQuery.of(context).size.width * .18,
                                    decoration: BoxDecoration(
                                        border: Border.all(color: borderColor),
                                        color: Colors.white,
                                        shape: BoxShape.rectangle,
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(5.0))),
                                    child: Row(
                                      // mainAxisAlignment: MainAxisAlignment.end,
                                      children: <Widget>[
                                        Expanded(
                                          child: adminInputField,
                                        ),
                                        Container(
                                          padding:
                                              EdgeInsets.fromLTRB(0, 0, 0, 0),
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              .1,
                                          height: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              .1,
                                          child: IconButton(
                                              padding: EdgeInsets.all(0),
                                              icon: Icon(Icons.person_add,
                                                  color: highlightColor,
                                                  size: 38),
                                              onPressed: () {
                                                if (_adminItemController.text ==
                                                        null ||
                                                    _adminItemController
                                                        .text.isEmpty) {
                                                  Utils.showMyFlushbar(
                                                      context,
                                                      Icons.info_outline,
                                                      Duration(
                                                        seconds: 4,
                                                      ),
                                                      "Something Missing ..",
                                                      "Please enter Phone number !!");
                                                } else {
                                                  bool result = adminPhoneKey
                                                      .currentState
                                                      .validate();
                                                  if (result) {
                                                    _addNewAdminRow();
                                                    _adminItemController.text =
                                                        "";
                                                  } else {
                                                    Utils.showMyFlushbar(
                                                        context,
                                                        Icons.info_outline,
                                                        Duration(
                                                          seconds: 5,
                                                        ),
                                                        "Oops!! Seems like the phone number is not valid",
                                                        "Please check and try again !!");
                                                  }
                                                }
                                              }),
                                        ),
                                      ],
                                    ),
                                  ),
                                  ListView.builder(
                                    shrinkWrap: true,
                                    //scrollDirection: Axis.vertical,
                                    itemBuilder:
                                        (BuildContext context, int index) {
                                      return new Column(
                                          children: adminsList
                                              .map(_buildServiceItem)
                                              .toList());
                                    },
                                    itemCount: 1,
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
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
                  .push(PageAnimation.createRoute(ManageEntityListPage()));
              return false;
            }
          },
        ),
      );
    else
      return MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData.light().copyWith(),
        home: new WillPopScope(
          child: Scaffold(
            appBar: CustomAppBarWithBackButton(
              backRoute: ManageEntityListPage(),
              titleTxt: "Booking Tokens Overview ",
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

  showCategorySheet() {
    bottomSheetController =
        employeeListPagekey.currentState.showBottomSheet<Null>(
      (context) => Container(
        color: Colors.cyan[50],
        height: MediaQuery.of(context).size.height * .4,
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
                        SELECT_ROLE_OF_PERSON,
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
                  itemCount: EntityRole.values.length,
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
                              context, EntityRole.values[index]),
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
