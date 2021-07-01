import 'dart:async';

import 'package:enum_to_string/enum_to_string.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../constants.dart';
import '../db/db_model/app_user.dart';
import '../db/db_model/employee.dart';
import '../db/db_model/entity.dart';
import '../db/db_model/entity_private.dart';
import '../db/db_model/meta_entity.dart';
import '../enum/entity_type.dart';
import '../events/event_bus.dart';
import '../events/events.dart';
import '../global_state.dart';
import '../pages/contact_item.dart';
import '../pages/manage_entity_list_page.dart';
import '../repository/StoreRepository.dart';
import '../services/circular_progress.dart';
import '../style.dart';
import '../utils.dart';
import '../widget/appbar.dart';
import '../widget/custom_expansion_tile.dart';
import '../widget/page_animation.dart';
import '../widget/widgets.dart';
import 'package:uuid/uuid.dart';
import 'package:eventify/eventify.dart' as Eventify;

import '../enum/entity_role.dart';

class ManageEmployeePage extends StatefulWidget {
  final MetaEntity metaEntity;
  final DateTime defaultDate;
  final dynamic backRoute;
  final bool isManager;
  ManageEmployeePage(
      {Key key,
      @required this.metaEntity,
      @required this.defaultDate,
      @required this.backRoute,
      @required this.isManager})
      : super(key: key);
  @override
  _ManageEmployeePageState createState() => _ManageEmployeePageState();
}

class _ManageEmployeePageState extends State<ManageEmployeePage> {
  List<Employee> managersList = [];
  List<Employee> executiveList = [];
  MetaEntity metaEntity;
  List<Widget> contactRowWidgets = [];
  List<Widget> execRowWidgets = [];
  List<Widget> contactRowWidgetsNew = [];
  bool _initCompleted = false;
  GlobalState _gs;
  Entity entity;
  Eventify.Listener removeManagerListener;
  Eventify.Listener removeExecListener;
  PersistentBottomSheetController bottomSheetController;
  final employeeListPagekey = new GlobalKey<ScaffoldState>();
  TextEditingController _adminItemController = new TextEditingController();
  List<String> adminsList = [];
  final GlobalKey<FormFieldState> adminPhoneKey =
      new GlobalKey<FormFieldState>();
  String _item;
  @override
  void initState() {
    super.initState();
    metaEntity = this.widget.metaEntity;
    getGlobalState().whenComplete(() {
      _gs.getEntity(metaEntity.entityId, true).then((value) {
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
    removeExecListener = EventBus.registerEvent(
        EXECUTIVE_REMOVED_EVENT, null, this.refreshOnExecutiveRemove);
  }

  @override
  void dispose() {
    super.dispose();
    print("dispose called for child entity");
    EventBus.unregisterEvent(removeManagerListener);
  }

  void _addNewAdminRow() {
    bool insert = true;
    String newAdminPh = '+91' + _adminItemController.text;

    setState(() {
      if (adminsList.length != 0) {
        for (int i = 0; i < adminsList.length; i++) {
          if (adminsList[i] == (newAdminPh)) {
            insert = false;
            Utils.showMyFlushbar(
                context,
                Icons.info_outline,
                Duration(
                  seconds: 5,
                ),
                "Error",
                "Phone number already exists !!");
            break;
          }
          print("in for loop $insert");
          print(adminsList[i] == newAdminPh);
          print(newAdminPh);
          print(adminsList[i]);
        }
      }

      if (insert) adminsList.insert(0, newAdminPh);
      print("after foreach");

      //TODO: Smita - Update GS
    });
  }

  void _removeServiceRow(String currItem) {
    removeAdmin(entity.entityId, currItem).then((delStatus) {
      if (delStatus)
        setState(() {
          adminsList.remove(currItem);
        });
      else
        Utils.showMyFlushbar(
            context,
            Icons.info_outline,
            Duration(
              seconds: 5,
            ),
            'Oops!! There is some trouble deleting that admin.',
            'Please check and try again..');
    });
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
    // _phCountryCode = _gs.getConfigurations().phCountryCode;
  }

  void refreshOnManagerRemove(event, args) {
    setState(() {
      //  contactRowWidgets.removeWhere((element) => element)
      print("Inside remove Manage");
      contactRowWidgets.clear();
      contactRowWidgets.add(showCircularProgress());
    });
    //refreshContacts();
    managersList
        .removeWhere((element) => element.id == event.eventData.toString());

    refreshContacts();
  }

  void refreshOnExecutiveRemove(event, args) {
    setState(() {
      execRowWidgets.clear();
      execRowWidgets.add(showCircularProgress());
    });
    managersList
        .removeWhere((element) => element.id == event.eventData.toString());

    refreshExecutives();
  }

  processRefreshContactsWithTimer() async {
    var duration = new Duration(seconds: 1);
    return new Timer(duration, refreshContacts);
  }

  initializeEntity() async {
    if (entity != null) {
      //TODO: get entity
      //AppUser currUser = _gs.getCurrentUser();
      // Map<String, String> adminMap = Map<String, String>();
      // EntityPrivate entityPrivateList;
      // entityPrivateList = await fetchAdmins(entity.entityId);
      // if (entityPrivateList != null) {
      //   adminMap = entityPrivateList.roles;
      //   if (adminMap != null)
      //     adminMap.forEach((k, v) {
      //       if (currUser.ph != k) adminsList.add(k);
      //     });
      //   //_regNumController.text = entityPrivateList.registrationNumber;
      // }

      if (!(Utils.isNullOrEmpty(entity.admins))) {
        entity.admins.forEach((k) {
          adminsList.add(k.ph);
        });
      }

      if (!(Utils.isNullOrEmpty(entity.managers))) {
        managersList = entity.managers;
        managersList.forEach((element) {
          contactRowWidgets.add(new ContactRow(
            contact: element,
            empType: EntityRole.Manager,
            entity: entity,
            list: managersList,
            isManager: widget.isManager,
            existingContact: true,
          ));
        });
      }
      if (!(Utils.isNullOrEmpty(entity.executives))) {
        executiveList = entity.executives;
        executiveList.forEach((element) {
          execRowWidgets.add(new ContactRow(
            contact: element,
            empType: EntityRole.Executive,
            entity: entity,
            list: executiveList,
            isManager: widget.isManager,
            existingContact: true,
          ));
        });
      }
    }
  }

  refreshContacts() {
    List<Widget> newList = new List<Widget>();
    for (int i = 0; i < managersList.length; i++) {
      newList.add(new ContactRow(
        contact: managersList[i],
        empType: EntityRole.Manager,
        entity: entity,
        list: managersList,
        isManager: widget.isManager,
        existingContact: true,
      ));
    }
    setState(() {
      contactRowWidgets.clear();
      contactRowWidgets.addAll(newList);
    });
    entity.managers = managersList;
  }

  refreshExecutives() {
    List<Widget> newList = new List<Widget>();
    for (int i = 0; i < executiveList.length; i++) {
      newList.add(new ContactRow(
        contact: executiveList[i],
        empType: EntityRole.Executive,
        entity: entity,
        list: executiveList,
        isManager: widget.isManager,
        existingContact: true,
      ));
    }
    setState(() {
      execRowWidgets.clear();
      execRowWidgets.addAll(newList);
    });
    entity.executives = executiveList;
  }

  void _addNewContactRow() {
    Employee contact = new Employee();
    var uuid = new Uuid();
    contact.id = uuid.v1();
    managersList.add(contact);

    List<Widget> newList = new List<Widget>();
    // for (int i = 0; i < contactList.length; i++) {
    newList.add(new ContactRow(
      contact: managersList[managersList.length - 1],
      empType: EntityRole.Manager,
      entity: entity,
      list: managersList,
      isManager: widget.isManager,
      existingContact: false,
    ));
    // }
    setState(() {
      //  contactRowWidgets.clear();
      contactRowWidgets.addAll(newList);
      entity.managers = managersList;
      // _contactCount = _contactCount + 1;
    });
  }

  void _addNewExecutiveRow() {
    Employee executive = new Employee();
    var uuid = new Uuid();
    executive.id = uuid.v1();
    executiveList.add(executive);

    List<Widget> newExecList = new List<Widget>();
    for (int i = 0; i < executiveList.length; i++) {
      newExecList.add(new ContactRow(
        contact: executiveList[i],
        empType: EntityRole.Executive,
        entity: entity,
        list: executiveList,
        isManager: widget.isManager,
        existingContact: false,
      ));
    }
    setState(() {
      execRowWidgets.clear();
      execRowWidgets.addAll(newExecList);
      entity.executives = executiveList;
      // _contactCount = _contactCount + 1;
    });
  }

  void saveNewAdminRow(String newAdmPh) {
    setState(() {
      adminsList.forEach((element) {
        if (element.compareTo(newAdmPh) != 0) adminsList.add(newAdmPh);
      });
    });
  }

  bool saveAdmins() {
    adminsList.forEach((phone) {
      Employee emp = new Employee();
      emp.ph = phone;
      _gs
          .getEntityService()
          .upsertEmployee(widget.metaEntity.entityId, emp, EntityRole.Admin)
          .then((retVal) {
        Utils.showMyFlushbar(
            context,
            Icons.check,
            Duration(
              seconds: 4,
            ),
            "Admin Details Saved Successfully!",
            "",
            successGreenSnackBar);
      });
    });
    return true;
  }

  Widget _buildServiceItem(String newAdminRowItem) {
    TextEditingController itemNameController = new TextEditingController();
    itemNameController.text = newAdminRowItem;
    double cardMargin = MediaQuery.of(context).size.width * .03;
    return Container(
      height: 25,
      //padding: EdgeInsets.fromLTRB(4, 8, 4, 14),
      margin: EdgeInsets.fromLTRB(4, 8, 4, 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Container(
              margin: EdgeInsets.fromLTRB(12, 2, 10, 2),
              height: 25,
              width: MediaQuery.of(context).size.width * .5,
              child: TextFormField(
                // key: newAdminRowItemKey,
                //  autovalidate: _autoValidate,
                enabled: false,
                cursorColor: highlightColor,
                keyboardType: TextInputType.phone,
                inputFormatters: [
                  LengthLimitingTextInputFormatter(18),
                ],
                style: TextStyle(fontSize: 14, color: primaryDarkColor),
                controller: itemNameController,
                decoration: InputDecoration(
                  //contentPadding: EdgeInsets.all(12),
                  // labelText: newItem.itemName,

                  hintText: 'Admin\'s phone number',
                  hintStyle: TextStyle(fontSize: 12, color: Colors.grey),
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                ),
                // validator: Utils.validateMobileField,
                onChanged: (value) {
                  //newAdminRowItemKey.currentState.validate();
                  newAdminRowItem = value;
                },
              )

              // Text(
              //   newItem.itemName,ggg

              // ),
              ),
          horizontalSpacer,
          Container(
            height: 25,
            margin: EdgeInsets.fromLTRB(0, 0, 0, 0),
            padding: EdgeInsets.fromLTRB(0, 0, 0, 0),
            width: MediaQuery.of(context).size.width * .1,
            child: IconButton(
              alignment: Alignment.topCenter,
              padding: EdgeInsets.all(0),
              icon: Icon(Icons.delete, color: Colors.blueGrey[300], size: 20),
              onPressed: () {
                if (widget.isManager) {
                  return;
                } else {
                  //do not allow delete if this is the last admin of this place
                  if (adminsList.length == 1) {
                    Utils.showMyFlushbar(
                        context,
                        Icons.info_outline,
                        Duration(seconds: 5),
                        "Assign another Admin, before you move out!",
                        "Because you are the Only Admin here.");
                  } else {
                    _removeServiceRow(newAdminRowItem);
                    _adminItemController.text = "";
                  }
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final adminInputField = new TextFormField(
      key: adminPhoneKey,
      autofocus: true,
      enabled: widget.isManager ? false : true,
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
          prefixText: '+91 ',
          suffixIconConstraints: BoxConstraints(
            maxWidth: 22,
            maxHeight: 22,
          ),
          // contentPadding: EdgeInsets.all(0),
          focusedBorder: InputBorder.none,
          enabledBorder: InputBorder.none,
          hintText: "Enter Admin's Contact number & Press (+)",
          hintMaxLines: 2,
          hintStyle: textInputTextStyle),
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
      return WillPopScope(
        child: Scaffold(
          resizeToAvoidBottomInset: false,
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
          body: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Container(
                  height: MediaQuery.of(context).size.height * .85,
                  child: Scrollbar(
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Container(
                            margin: EdgeInsets.all(5),
                            padding: EdgeInsets.all(0),
                            decoration: BoxDecoration(
                                border: Border.all(color: containerColor),
                                color: Colors.white,
                                shape: BoxShape.rectangle,
                                borderRadius:
                                    BorderRadius.all(Radius.circular(5.0))),
                            // padding: EdgeInsets.all(5.0),
                            child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Column(children: <Widget>[
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
                                                "Add a Manager",
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
                                              width: MediaQuery.of(context)
                                                      .size
                                                      .width *
                                                  .94,
                                              decoration: darkContainer,
                                              padding: EdgeInsets.all(2.0),
                                              child: Row(
                                                children: <Widget>[
                                                  Expanded(
                                                    child: Text(adminInfoStr,
                                                        style:
                                                            buttonXSmlTextStyle),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    Card(
                                      elevation: 3,
                                      margin: EdgeInsets.all(
                                          MediaQuery.of(context).size.width *
                                              .03),
                                      child: Container(
                                        foregroundDecoration: widget.isManager
                                            ? BoxDecoration(
                                                color: Colors.blueGrey[50],
                                                backgroundBlendMode:
                                                    BlendMode.saturation,
                                              )
                                            : BoxDecoration(),
                                        padding: EdgeInsets.all(5),
                                        decoration: BoxDecoration(
                                            border: Border.all(
                                                color: highlightColor),
                                            color: Colors.white,
                                            shape: BoxShape.rectangle,
                                            borderRadius: BorderRadius.all(
                                                Radius.circular(5.0))),
                                        child: InkWell(
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: <Widget>[
                                              Text(" Add a Manager",
                                                  style: textInputTextStyle),
                                              horizontalSpacer,
                                              Icon(Icons.person_add,
                                                  color: highlightColor,
                                                  size: 40),
                                            ],
                                          ),
                                          onTap: () {
                                            if (widget.isManager) {
                                              return;
                                            } else {
                                              print("Tappped");
                                              _addNewContactRow();
                                            }
                                            // showCategorySheet();
                                          },
                                        ),
                                      ),
                                    ),
                                    if (!Utils.isNullOrEmpty(managersList))
                                      ListView.builder(
                                        reverse: true,
                                        physics: ClampingScrollPhysics(),
                                        padding: EdgeInsets.all(0),
                                        scrollDirection: Axis.vertical,
                                        shrinkWrap: true,
                                        itemBuilder:
                                            (BuildContext context, int index) {
                                          return contactRowWidgets[index];
                                        },
                                        itemCount: managersList.length,
                                      ),
                                  ]),
                                ]),
                          ),
                          Container(
                            margin: EdgeInsets.all(5),
                            padding: EdgeInsets.all(0),
                            decoration: BoxDecoration(
                                border: Border.all(color: containerColor),
                                color: Colors.white,
                                shape: BoxShape.rectangle,
                                borderRadius:
                                    BorderRadius.all(Radius.circular(5.0))),
                            // padding: EdgeInsets.all(5.0),
                            child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Column(children: <Widget>[
                                    Container(
                                      //padding: EdgeInsets.only(left: 5),
                                      decoration: darkContainer,
                                      child: Theme(
                                        data: ThemeData(
                                          unselectedWidgetColor: Colors.white,
                                          accentColor: Colors.grey[50],
                                        ),
                                        child: CustomExpansionTile(
                                          initiallyExpanded: false,
                                          title: Row(
                                            children: <Widget>[
                                              Text(
                                                "Add an Executive",
                                                style: TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 15),
                                              ),
                                              SizedBox(width: 5),
                                            ],
                                          ),
                                          backgroundColor: Colors.blueGrey[500],
                                          children: <Widget>[
                                            new Container(
                                              width: MediaQuery.of(context)
                                                      .size
                                                      .width *
                                                  .94,
                                              decoration: darkContainer,
                                              padding: EdgeInsets.all(2.0),
                                              child: Row(
                                                children: <Widget>[
                                                  Expanded(
                                                    child: Text(adminInfoStr,
                                                        style:
                                                            buttonXSmlTextStyle),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    Card(
                                      elevation: 3,
                                      margin: EdgeInsets.all(
                                          MediaQuery.of(context).size.width *
                                              .03),
                                      child: Container(
                                        foregroundDecoration: widget.isManager
                                            ? BoxDecoration(
                                                color: Colors.blueGrey[50],
                                                backgroundBlendMode:
                                                    BlendMode.saturation,
                                              )
                                            : BoxDecoration(),
                                        padding: EdgeInsets.all(5),
                                        decoration: BoxDecoration(
                                            border: Border.all(
                                                color: highlightColor),
                                            color: Colors.white,
                                            shape: BoxShape.rectangle,
                                            borderRadius: BorderRadius.all(
                                                Radius.circular(5.0))),
                                        child: InkWell(
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: <Widget>[
                                              Text(" Add an Executive",
                                                  style: textInputTextStyle),
                                              horizontalSpacer,
                                              Icon(Icons.person_add,
                                                  color: highlightColor,
                                                  size: 40),
                                            ],
                                          ),
                                          onTap: () {
                                            if (widget.isManager) {
                                              return;
                                            } else {
                                              print("Tappped");
                                              _addNewExecutiveRow();
                                            }
                                          },
                                        ),
                                      ),
                                    ),
                                    if (!Utils.isNullOrEmpty(executiveList))
                                      ListView.builder(
                                        physics: ClampingScrollPhysics(),
                                        reverse: true,
                                        padding: EdgeInsets.all(0),
                                        scrollDirection: Axis.vertical,
                                        shrinkWrap: true,
                                        itemBuilder:
                                            (BuildContext context, int index) {
                                          return execRowWidgets[index];
                                        },
                                        itemCount: executiveList.length,
                                      ),
                                  ]),
                                ]),
                          ),
                          Container(
                            margin: EdgeInsets.all(5),
                            padding: EdgeInsets.all(0),
                            decoration: BoxDecoration(
                                border: Border.all(color: containerColor),
                                color: Colors.white,
                                shape: BoxShape.rectangle,
                                borderRadius:
                                    BorderRadius.all(Radius.circular(5.0))),
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
                                              width: MediaQuery.of(context)
                                                      .size
                                                      .width *
                                                  .94,
                                              decoration: darkContainer,
                                              padding: EdgeInsets.all(2.0),
                                              child: Row(
                                                children: <Widget>[
                                                  Expanded(
                                                    child: Text(adminInfoStr,
                                                        style:
                                                            buttonXSmlTextStyle),
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
                                        Card(
                                          margin: EdgeInsets.all(
                                              MediaQuery.of(context)
                                                      .size
                                                      .width *
                                                  .03),
                                          child: Container(
                                            //  padding: EdgeInsets.all(5),
                                            foregroundDecoration: widget
                                                    .isManager
                                                ? BoxDecoration(
                                                    color: Colors.grey[50],
                                                    backgroundBlendMode:
                                                        BlendMode.saturation,
                                                  )
                                                : BoxDecoration(),
                                            decoration: BoxDecoration(
                                                border: Border.all(
                                                    color: highlightColor),
                                                color: Colors.white,
                                                shape: BoxShape.rectangle,
                                                borderRadius: BorderRadius.all(
                                                    Radius.circular(5.0))),
                                            //margin: EdgeInsets.all(4),
                                            // height:
                                            //     MediaQuery.of(context).size.width *
                                            //         .18,
                                            child: Row(
                                              // mainAxisAlignment: MainAxisAlignment.end,
                                              children: <Widget>[
                                                Expanded(
                                                  child: adminInputField,
                                                ),
                                                Container(
                                                  padding: EdgeInsets.fromLTRB(
                                                      0, 0, 0, 0),
                                                  width: MediaQuery.of(context)
                                                          .size
                                                          .width *
                                                      .1,
                                                  height: MediaQuery.of(context)
                                                          .size
                                                          .width *
                                                      .1,
                                                  child: IconButton(
                                                      padding:
                                                          EdgeInsets.all(0),
                                                      icon: Icon(
                                                          Icons.add_circle,
                                                          color: highlightColor,
                                                          size: 38),
                                                      onPressed: () {
                                                        if (widget.isManager) {
                                                          return;
                                                        } else {
                                                          if (_adminItemController
                                                                      .text ==
                                                                  null ||
                                                              _adminItemController
                                                                  .text
                                                                  .isEmpty) {
                                                            Utils.showMyFlushbar(
                                                                context,
                                                                Icons.info_outline,
                                                                Duration(
                                                                  seconds: 4,
                                                                ),
                                                                "Something Missing ..",
                                                                "Please enter Phone number !!");
                                                          } else {
                                                            bool result =
                                                                adminPhoneKey
                                                                    .currentState
                                                                    .validate();
                                                            if (result) {
                                                              _addNewAdminRow();
                                                              _adminItemController
                                                                  .text = "";
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
                                                        }
                                                      }),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                        ListView.builder(
                                          physics: ClampingScrollPhysics(),
                                          shrinkWrap: true,
                                          //scrollDirection: Axis.vertical,
                                          itemBuilder: (BuildContext context,
                                              int index) {
                                            return new Column(
                                                children: adminsList
                                                    .map(_buildServiceItem)
                                                    .toList());
                                          },
                                          itemCount: 1,
                                        ),
                                      ],
                                    ),
                                    (adminsList.length != 0)
                                        ? Container(
                                            width: MediaQuery.of(context)
                                                    .size
                                                    .width *
                                                .9,
                                            child: RaisedButton(
                                              color: widget.isManager
                                                  ? disabledColor
                                                  : btnColor,
                                              child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                  Text(
                                                    "Save Admins",
                                                    style: buttonMedTextStyle,
                                                  ),
                                                  SizedBox(
                                                      width:
                                                          MediaQuery.of(context)
                                                                  .size
                                                                  .width *
                                                              .01),
                                                  Icon(Icons.save,
                                                      color: Colors.white)
                                                ],
                                              ),
                                              onPressed: () {
                                                if (widget.isManager) {
                                                  return;
                                                } else {
                                                  saveAdmins();
                                                }
                                              },
                                            ),
                                          )
                                        : Container(
                                            width: 0,
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
              ]),
        ),
        onWillPop: () async {
          if (bottomSheetController != null) {
            bottomSheetController.close();
            bottomSheetController = null;
            return false;
          } else {
            //Navigator.of(context).pop();
            Navigator.of(context).push(new MaterialPageRoute(
                builder: (BuildContext context) => ManageEntityListPage()));
            return false;
          }
        },
      );
    else
      return new WillPopScope(
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
      );
  }

  saveEntityWithEmployees() {
    //TODO Entity save
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
