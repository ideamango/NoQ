import 'dart:ui';

import 'package:flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import 'package:noq/db/db_model/address.dart';
import 'package:noq/db/db_model/employee.dart';
import 'package:noq/db/db_model/entity.dart';
import 'package:noq/db/db_model/entity_private.dart';
import 'package:noq/db/db_model/meta_entity.dart';
import 'package:noq/db/db_model/my_geo_fire_point.dart';
import 'package:noq/db/db_model/user.dart';
import 'package:noq/db/db_service/entity_service.dart';
import 'dart:async';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:noq/constants.dart';
import 'package:noq/db/db_service/user_service.dart';
import 'package:noq/pages/contact_item.dart';
import 'package:noq/pages/entity_services_list_page.dart';
import 'package:noq/repository/StoreRepository.dart';
import 'package:noq/repository/local_db_repository.dart';
import 'package:noq/style.dart';
import 'package:noq/utils.dart';
import 'package:noq/widget/bottom_nav_bar.dart';
import 'package:noq/widget/custom_expansion_tile.dart';
import 'package:noq/widget/weekday_selector.dart';
import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:noq/widget/widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

class ServiceEntityDetailsPage extends StatefulWidget {
  final Entity childEntity;
  ServiceEntityDetailsPage({Key key, @required this.childEntity})
      : super(key: key);
  @override
  _ServiceEntityDetailsPageState createState() =>
      _ServiceEntityDetailsPageState();
}

class _ServiceEntityDetailsPageState extends State<ServiceEntityDetailsPage> {
  bool _autoValidate = false;
  final GlobalKey<FormState> _serviceDetailsFormKey =
      new GlobalKey<FormState>();
  final String title = "Managers Form";
  final Geolocator geolocator = Geolocator()..forceAndroidLocationManager;
  bool validateField = false;
  TextEditingController _nameController = TextEditingController();
  TextEditingController _descController = TextEditingController();
  TextEditingController _regNumController = TextEditingController();
  TextEditingController _closeTimeController = TextEditingController();
  TextEditingController _openTimeController = TextEditingController();
  TextEditingController _breakStartController = TextEditingController();
  TextEditingController _breakEndController = TextEditingController();
  TextEditingController _advBookingInDaysController = TextEditingController();
  TextEditingController _maxPeopleController = TextEditingController();
  TextEditingController _slotDurationController = TextEditingController();
  TextEditingController _whatsappPhoneController = TextEditingController();

  final GlobalKey<FormFieldState> whatsappPhnKey =
      new GlobalKey<FormFieldState>();
  List<String> _closedOnDays = List<String>();
  // TextEditingController _subAreaController = TextEditingController();
  TextEditingController _adrs1Controller = TextEditingController();
  TextEditingController _landController = TextEditingController();
  TextEditingController _localityController = TextEditingController();
  TextEditingController _cityController = TextEditingController();
  TextEditingController _stateController = TextEditingController();
  TextEditingController _countryController = TextEditingController();
  TextEditingController _pinController = TextEditingController();
  // List<String> _addressList = new List<String>();
  TextEditingController _adminItemController = new TextEditingController();

  final GlobalKey<FormFieldState> adminItemKey =
      new GlobalKey<FormFieldState>();
  String _item;

  //ContactPerson Fields
  TextEditingController _ctNameController = TextEditingController();
  TextEditingController _ctEmpIdController = TextEditingController();
  TextEditingController _ctPhn1controller = TextEditingController();
  TextEditingController _ctPhn2controller = TextEditingController();
  TextEditingController _ctAvlFromTimeController = TextEditingController();
  TextEditingController _ctAvlTillTimeController = TextEditingController();

  List<days> _daysOff = List<days>();

  Entity serviceEntity;

  //bool _autoPopulate = false;

  String _currentCity;
  String _postalCode;
  String _country;
  String _subArea;
  String _state;
  String _mainArea;

  String _role;
  String _entityType;
  String state;
  bool isPublic = false;
  bool isActive = false;
  bool isBookable = false;
// ChildEntityAppData serviceEntity;

  List<Employee> contactList = new List<Employee>();
  List<String> adminsList = new List<String>();
  List<Widget> contactRowWidgets = new List<Widget>();
  List<Widget> adminRowWidgets = new List<Widget>();
  int _contactCount = 0;
  String _roleType;

  Flushbar flush;
  bool _wasButtonClicked;
  String flushStatus = "Empty";

  @override
  void initState() {
    super.initState();
    serviceEntity = widget.childEntity;
    _getCurrLocation();
    initializeEntity();
  }

  initializeEntity() async {
    // serviceEntity = await getEntity(_metaEntity.entityId);
    if (serviceEntity != null) {
      isPublic = (serviceEntity.isPublic) ?? false;
      isBookable = (serviceEntity.isBookable) ?? false;
      isActive = (serviceEntity.isActive) ?? false;

      _nameController.text = (serviceEntity.name) ?? "";
      _descController.text = (serviceEntity.description) ?? "";

      //TODO-Smita  add later code for getting reg thru private
      // _regNumController.text = serviceEntity.regNum;
      if (serviceEntity.startTimeHour != null &&
          serviceEntity.startTimeMinute != null)
        _openTimeController.text = serviceEntity.startTimeHour.toString() +
            ':' +
            serviceEntity.startTimeMinute.toString();
      if (serviceEntity.endTimeHour != null &&
          serviceEntity.endTimeMinute != null)
        _closeTimeController.text = serviceEntity.endTimeHour.toString() +
            ':' +
            serviceEntity.endTimeMinute.toString();
      if (serviceEntity.breakStartHour != null &&
          serviceEntity.breakStartMinute != null)
        _breakStartController.text = serviceEntity.breakStartHour.toString() +
            ':' +
            serviceEntity.breakStartMinute.toString();
      if (serviceEntity.breakEndHour != null &&
          serviceEntity.breakEndMinute != null)
        _breakEndController.text = serviceEntity.breakEndHour.toString() +
            ':' +
            serviceEntity.breakEndMinute.toString();

      if (serviceEntity.closedOn != null) {
        if (serviceEntity.closedOn.length != 0)
          _daysOff = Utils.convertStringsToDays(serviceEntity.closedOn);
      }
      if (_daysOff.length == 0) {
        _closedOnDays.add('days.sunday');
        _daysOff = Utils.convertStringsToDays(_closedOnDays);
      }

      _slotDurationController.text = (serviceEntity.slotDuration != null)
          ? serviceEntity.slotDuration.toString()
          : "";
      _advBookingInDaysController.text = (serviceEntity.advanceDays != null)
          ? serviceEntity.advanceDays.toString()
          : "";
      if (serviceEntity.maxAllowed != null)
        _maxPeopleController.text = (serviceEntity.maxAllowed != null)
            ? serviceEntity.maxAllowed.toString()
            : "";
      _whatsappPhoneController.text = serviceEntity.whatsapp != null
          ? serviceEntity.whatsapp.toString().substring(3)
          : "";
      //address
      if (serviceEntity.address != null) {
        _adrs1Controller.text = serviceEntity.address.address;
        _localityController.text = serviceEntity.address.locality;
        _landController.text = serviceEntity.address.landmark;
        _cityController.text = serviceEntity.address.city;
        _stateController.text = serviceEntity.address.state;
        _countryController.text = serviceEntity.address.country;
        _pinController.text = serviceEntity.address.zipcode;
      } else
        serviceEntity.address = new Address();
//contact person
      if (!(Utils.isNullOrEmpty(serviceEntity.managers))) {
        contactList = serviceEntity.managers;
        contactList.forEach((element) {
          contactRowWidgets.insert(0, new ContactRow(contact: element));
        });
      }
      User currUser = await UserService().getCurrentUser();
      Map<String, String> adminMap = Map<String, String>();
      EntityPrivate entityPrivateList;
      entityPrivateList = await fetchAdmins(serviceEntity.entityId);
      if (entityPrivateList != null) {
        adminMap = entityPrivateList.roles;
        if (adminMap != null)
          adminMap.forEach((k, v) {
            if (currUser.ph != k) adminsList.add(k);
          });
        _regNumController.text = entityPrivateList.registrationNumber;
      }
    } else {
      //TODO:do nothing as this metaEntity is just created and will saved in DB only on save
      Map<String, dynamic> entityJSON = <String, dynamic>{
        'type': serviceEntity.type,
        'entityId': serviceEntity.entityId
      };
      serviceEntity = Entity.fromJson(entityJSON);
      serviceEntity.address = (serviceEntity.address) ?? new Address();
      contactList = contactList ?? new List<Employee>();
    }
  }

  String validateText(String value) {
    if (validateField) {
      if (value == null || value == "") {
        return 'Field is empty';
      }
      return null;
    } else
      return null;
  }

  String validateTime(String value) {
    if (validateField) {
      if (value == null || value == "") {
        return 'Field is empty';
      }
      return null;
    } else
      return null;
  }

  void _getCurrLocation() async {
    final Geolocator geolocator = Geolocator()..forceAndroidLocationManager;

    geolocator
        .getCurrentPosition(desiredAccuracy: LocationAccuracy.best)
        .then((Position position) {
      _getAddressFromLatLng(position);
    }).catchError((e) {
      print(e);
    });
  }

  _getAddressFromLatLng(Position position) async {
    try {
      List<Placemark> p = await geolocator.placemarkFromCoordinates(
          position.latitude, position.longitude);

      Placemark place = p[0];

      setState(() {
        // _autoPopulate = true;
        _subArea = place.subAdministrativeArea;
        _state = place.administrativeArea;
        _mainArea = place.subLocality;
        _currentCity = place.locality;
        _postalCode = place.postalCode;
        _country = place.country;

        // _address = new Address(
        //     _subArea, _mainArea, _currentCity, _country, _postalCode);
      });
      print('ghythyt');
      print(_subArea +
          "..." +
          _mainArea +
          "..." +
          _currentCity +
          "..." +
          _postalCode +
          "..." +
          _country +
          "..." +
          place.administrativeArea);
      setState(() {
        _localityController.text = _subArea;
        _cityController.text = _currentCity;
        _stateController.text = _state;
        _countryController.text = _country;
        _pinController.text = _postalCode;
      });

      // _subAreaController.text = _subArea;
      // setState(() {
      //   _textEditingController.text = _address.country;
      // });
    } catch (e) {
      print(e);
    }
  }

  void _addNewAdminRow() {
    bool insert = true;
    String newAdminPh = '+91' + _adminItemController.text;

    setState(() {
      if (adminsList.length != 0) {
        for (int i = 0; i < adminsList.length; i++) {
          if (adminsList[i] == (newAdminPh)) {
            insert = false;
            Utils.showMyFlushbar(context, Icons.info_outline, "Error",
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
    removeAdmin(serviceEntity.entityId, currItem).then((delStatus) {
      if (delStatus)
        setState(() {
          adminsList.remove(currItem);
        });
      else
        Utils.showMyFlushbar(
            context,
            Icons.info_outline,
            'Oops!! There is some trouble deleting that admin.',
            'Please check and try again..');
    });
  }

  Widget _buildServiceItem(String newItem) {
    TextEditingController itemNameController = new TextEditingController();
    itemNameController.text = newItem;
    return Card(
      semanticContainer: true,
      elevation: 15,
      margin: EdgeInsets.fromLTRB(4, 2, 4, 4),
      child: Container(
        height: 25,
        //padding: EdgeInsets.fromLTRB(4, 8, 4, 14),
        margin: EdgeInsets.fromLTRB(4, 8, 4, 6),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Container(
                height: 25,
                width: MediaQuery.of(context).size.width * .5,
                child: TextFormField(
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
                  onChanged: (value) {
                    newItem = value;
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
                  _removeServiceRow(newItem);
                  _adminItemController.text = "";
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  saveDetails() async {
    //TODO Smita: build string to get lat, long from address(UI) and save it in entity.
    String addressStr;
    addressStr = serviceEntity.address.locality +
        ", " +
        serviceEntity.address.city +
        "," +
        serviceEntity.address.state +
        "," +
        serviceEntity.address.country;
    List<Placemark> placemark =
        await Geolocator().placemarkFromAddress(addressStr);

    print(placemark);

    String validationPh1;
    String validationPh2;
    bool isContactValid = true;

    for (int i = 0; i < contactList.length; i++) {
      validationPh1 = (contactList[i].ph != null)
          ? Utils.validateMobileField(contactList[i].ph.substring(3))
          : true;
      validationPh2 = (contactList[i].altPhone != null)
          ? Utils.validateMobileField(contactList[i].altPhone.substring(3))
          : true;

      if (validationPh2 != null || validationPh1 != null) {
        isContactValid = false;
        break;
      }
    }
    print("saving ");

    if (_serviceDetailsFormKey.currentState.validate() && isContactValid) {
      _serviceDetailsFormKey.currentState.save();
      print("Saved formmmmmmm");
      EntityService()
          .upsertChildEntityToParent(
              serviceEntity, serviceEntity.parentId, _regNumController.text)
          .then((value) {
        if (value) {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) =>
                      ChildEntitiesListPage(entity: this.serviceEntity)));
        }
      });
    } else {
      Utils.showMyFlushbar(
          context,
          Icons.info_outline,
          "Seems like you have entered some incorrect details!! ",
          "Please verify the details and try again.");
      setState(() {
        _autoValidate = true;
      });
    }
  }

  void addNewAdminRow() {
    setState(() {
      adminsList.add("Admin");
    });
  }

  void _addNewContactRow() {
    setState(() {
      Employee contact = new Employee();

      contactRowWidgets.insert(0, new ContactRow(contact: contact));

      contactList.add(contact);
      //TODO Smita check the logic for contactList

      serviceEntity.managers = contactList;
      // saveEntityDetails(en);
      //saveEntityDetails();
      _contactCount = _contactCount + 1;
    });
  }

  @override
  Widget build(BuildContext context) {
    final nameField = TextFormField(
      obscureText: false,
      maxLines: 1,
      minLines: 1,
      style: textInputTextStyle,
      controller: _nameController,
      //initialValue: serviceEntity.name,
      keyboardType: TextInputType.text,
      decoration: CommonStyle.textFieldStyle(
          labelTextStr: "Name of Establishment", hintTextStr: ""),
      validator: validateText,
      onChanged: (String value) {
        serviceEntity.name = value;
      },
      onSaved: (String value) {
        serviceEntity.name = value;
      },
    );
    final descField = TextFormField(
      obscureText: false,
      //minLines: 1,
      style: textInputTextStyle,
      controller: _descController,
      decoration: CommonStyle.textFieldStyle(
          labelTextStr: "Description", hintTextStr: ""),
      validator: validateText,
      keyboardType: TextInputType.multiline,
      maxLength: null,
      maxLines: 3,
      onChanged: (String value) {
        serviceEntity.description = value;
      },
      onSaved: (String value) {
        serviceEntity.description = value;
      },
    );
    final regNumField = TextFormField(
      obscureText: false,
      maxLines: 1,
      minLines: 1,
      style: textInputTextStyle,
      keyboardType: TextInputType.text,
      controller: _regNumController,
      decoration: CommonStyle.textFieldStyle(
          labelTextStr: "Registration Number", hintTextStr: ""),
      validator: validateText,
      onChanged: (String value) {
        //serviceEntity.regNum = value;
      },
      onSaved: (String value) {
        //serviceEntity.regNum = value;
      },
    );

    final opensTimeField = TextFormField(
      obscureText: false,
      maxLines: 1,
      readOnly: true,
      minLines: 1,
      style: textInputTextStyle,
      onTap: () {
        DatePicker.showTimePicker(context,
            showTitleActions: true,
            showSecondsColumn: false, onChanged: (date) {
          print('change $date in time zone ' +
              date.timeZoneOffset.inHours.toString());
        }, onConfirm: (date) {
          print('confirm $date');
          //  String time = "${date.hour}:${date.minute} ${date.";

          String time = DateFormat.Hm().format(date);
          print(time);

          _openTimeController.text = time.toLowerCase();
          if (_openTimeController.text != "") {
            List<String> time = _openTimeController.text.split(':');
            serviceEntity.startTimeHour = int.parse(time[0]);
            serviceEntity.startTimeMinute = int.parse(time[1]);
          }
        }, currentTime: DateTime.now());
      },
      controller: _openTimeController,
      keyboardType: TextInputType.text,
      decoration: InputDecoration(
          labelText: "Opening time",
          hintText: "HH:MM 24Hr time format",
          enabledBorder:
              UnderlineInputBorder(borderSide: BorderSide(color: Colors.grey)),
          focusedBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.orange))),
      validator: validateTime,
      onChanged: (String value) {
        //TODO: test the values
        List<String> time = value.split(':');
        serviceEntity.startTimeHour = int.parse(time[0]);
        serviceEntity.startTimeMinute = int.parse(time[1]);
      },
      onSaved: (String value) {
        //TODO: test the values
      },
    );
    final closeTimeField = TextFormField(
      enabled: true,
      obscureText: false,
      readOnly: true,
      maxLines: 1,
      minLines: 1,
      controller: _closeTimeController,
      style: textInputTextStyle,
      onTap: () {
        DatePicker.showTimePicker(context,
            showTitleActions: true,
            showSecondsColumn: false, onChanged: (date) {
          print('change $date in time zone ' +
              date.timeZoneOffset.inHours.toString());
        }, onConfirm: (date) {
          print('confirm $date');
          //  String time = "${date.hour}:${date.minute} ${date.";

          String time = DateFormat.Hm().format(date);
          print(time);

          _closeTimeController.text = time.toLowerCase();
          if (_closeTimeController.text != "") {
            List<String> time = _closeTimeController.text.split(':');
            serviceEntity.endTimeHour = int.parse(time[0]);
            serviceEntity.endTimeMinute = int.parse(time[1]);
          }
        }, currentTime: DateTime.now());
      },
      decoration: InputDecoration(
          labelText: "Closing time",
          hintText: "HH:MM 24Hr time format",
          enabledBorder:
              UnderlineInputBorder(borderSide: BorderSide(color: Colors.grey)),
          focusedBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.orange))),
      validator: validateTime,
      onChanged: (String value) {
        //TODO: test the values
        List<String> time = value.split(':');
        serviceEntity.endTimeHour = int.parse(time[0]);
        serviceEntity.endTimeMinute = int.parse(time[1]);
      },
      onSaved: (String value) {},
    );
    final breakSartTimeField = TextFormField(
      obscureText: false,
      maxLines: 1,
      readOnly: true,
      minLines: 1,
      style: textInputTextStyle,
      onTap: () {
        DatePicker.showTimePicker(context,
            showTitleActions: true,
            showSecondsColumn: false, onChanged: (date) {
          print('change $date in time zone ' +
              date.timeZoneOffset.inHours.toString());
        }, onConfirm: (date) {
          print('confirm $date');
          //  String time = "${date.hour}:${date.minute} ${date.";

          String time = DateFormat.Hm().format(date);
          print(time);

          _breakStartController.text = time.toLowerCase();
          if (_breakStartController.text != "") {
            List<String> time = _breakStartController.text.split(':');
            serviceEntity.breakStartHour = int.parse(time[0]);
            serviceEntity.breakStartMinute = int.parse(time[1]);
          }
        }, currentTime: DateTime.now());
      },
      controller: _breakStartController,
      keyboardType: TextInputType.text,
      decoration: InputDecoration(
          labelText: "Break start at",
          hintText: "HH:MM 24Hr time format",
          enabledBorder:
              UnderlineInputBorder(borderSide: BorderSide(color: Colors.grey)),
          focusedBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.orange))),
      validator: validateTime,
      onChanged: (String value) {
        //TODO: test the values
        List<String> time = value.split(':');
        serviceEntity.breakStartHour = int.parse(time[0]);
        serviceEntity.breakStartMinute = int.parse(time[1]);
      },
      onSaved: (String value) {},
    );
    final breakEndTimeField = TextFormField(
      enabled: true,
      obscureText: false,
      readOnly: true,
      maxLines: 1,
      minLines: 1,
      controller: _breakEndController,
      style: textInputTextStyle,
      onTap: () {
        DatePicker.showTimePicker(context,
            showTitleActions: true,
            showSecondsColumn: false, onChanged: (date) {
          print('change $date in time zone ' +
              date.timeZoneOffset.inHours.toString());
        }, onConfirm: (date) {
          print('confirm $date');
          //  String time = "${date.hour}:${date.minute} ${date.";

          String time = DateFormat.Hm().format(date);
          print(time);

          _breakEndController.text = time.toLowerCase();
          if (_breakEndController.text != "") {
            List<String> time = _breakEndController.text.split(':');
            serviceEntity.breakEndHour = int.parse(time[0]);
            serviceEntity.breakEndMinute = int.parse(time[1]);
          }
        }, currentTime: DateTime.now());
      },
      decoration: InputDecoration(
          labelText: "Break ends at",
          hintText: "HH:MM 24Hr time format",
          enabledBorder:
              UnderlineInputBorder(borderSide: BorderSide(color: Colors.grey)),
          focusedBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.orange))),
      validator: validateTime,
      onChanged: (String value) {
        //TODO: test the values
        List<String> time = value.split(':');
        serviceEntity.breakEndHour = int.parse(time[0]);
        serviceEntity.breakEndMinute = int.parse(time[1]);
      },
      onSaved: (String value) {
        //TODO: test the values
      },
    );
    final daysClosedField = Padding(
      padding: EdgeInsets.only(top: 12, bottom: 8),
      child: Row(
        children: <Widget>[
          Text(
            'Closed on ',
            style: TextStyle(
              color: Colors.grey[600],
              // fontWeight: FontWeight.w800,
              fontFamily: 'Monsterrat',
              letterSpacing: 0.5,
              fontSize: 15.0,
              //height: 2,
            ),
            textAlign: TextAlign.left,
          ),
          new WeekDaySelectorFormField(
            displayDays: [
              days.monday,
              days.tuesday,
              days.wednesday,
              days.thursday,
              days.friday,
              days.saturday,
              days.sunday
            ],
            initialValue: _daysOff,
            borderRadius: 20,
            elevation: 10,
            textStyle: buttonXSmlTextStyle,
            fillColor: Colors.blueGrey[400],
            selectedFillColor: highlightColor,
            boxConstraints: BoxConstraints(
                minHeight: 25, minWidth: 25, maxHeight: 28, maxWidth: 28),
            borderSide: BorderSide(color: Colors.white, width: 0),
            language: lang.en,
            onChange: (days) {
              print("Selected Days: " + days.toString());
              _closedOnDays.clear();
              days.forEach((element) {
                var day = element.toString().substring(5);
                _closedOnDays.add(day);
              });
              serviceEntity.closedOn = _closedOnDays;
              print(_closedOnDays.length);
              print(_closedOnDays.toString());
            },
          ),
        ],
      ),
    );
    final slotDuration = TextFormField(
      obscureText: false,
      maxLines: 1,
      minLines: 1,
      style: textInputTextStyle,
      keyboardType: TextInputType.number,
      controller: _slotDurationController,
      decoration: InputDecoration(
        labelText: 'Duration of time slot (in minutes)',
        enabledBorder:
            UnderlineInputBorder(borderSide: BorderSide(color: Colors.grey)),
        focusedBorder:
            UnderlineInputBorder(borderSide: BorderSide(color: Colors.orange)),
      ),
      validator: validateText,
      onChanged: (value) {
        if (value != "") serviceEntity.slotDuration = int.parse(value);
        print("slot duration saved");
      },
      onSaved: (String value) {
        if (value != "") serviceEntity.slotDuration = int.parse(value);
        print("slot duration saved");
      },
    );
    final advBookingInDays = TextFormField(
      obscureText: false,
      maxLines: 1,
      minLines: 1,
      style: textInputTextStyle,
      keyboardType: TextInputType.number,
      controller: _advBookingInDaysController,
      decoration: InputDecoration(
        labelText: 'Advance Booking Allowed(in days)',
        enabledBorder:
            UnderlineInputBorder(borderSide: BorderSide(color: Colors.grey)),
        focusedBorder:
            UnderlineInputBorder(borderSide: BorderSide(color: Colors.orange)),
      ),
      validator: validateText,
      onChanged: (value) {
        if (value != "") serviceEntity.advanceDays = int.parse(value);
        print("Advance Booking Allowed saved");
      },
      onSaved: (String value) {
        if (value != "") serviceEntity.advanceDays = int.parse(value);
        print("Advance Booking Allowed saved");
      },
    );
    final maxpeopleInASlot = TextFormField(
      obscureText: false,
      maxLines: 1,
      minLines: 1,
      style: textInputTextStyle,
      keyboardType: TextInputType.number,
      controller: _maxPeopleController,
      decoration: InputDecoration(
        labelText: 'Max. people allowed in a given time slot',
        enabledBorder:
            UnderlineInputBorder(borderSide: BorderSide(color: Colors.grey)),
        focusedBorder:
            UnderlineInputBorder(borderSide: BorderSide(color: Colors.orange)),
      ),
      validator: validateText,
      onChanged: (String value) {
        serviceEntity.maxAllowed = int.tryParse(value);
      },
      onSaved: (String value) {
        if (value != "") serviceEntity.maxAllowed = int.parse(value);
        print("saved max people");
        // entity. = value;
      },
    );
    final whatsappPhone = TextFormField(
      obscureText: false,
      key: whatsappPhnKey,
      maxLines: 1,
      minLines: 1,
      style: textInputTextStyle,
      keyboardType: TextInputType.phone,
      controller: _whatsappPhoneController,
      decoration: InputDecoration(
        prefixText: '+91',
        labelText: 'WhatsApp Number',
        enabledBorder:
            UnderlineInputBorder(borderSide: BorderSide(color: Colors.grey)),
        focusedBorder:
            UnderlineInputBorder(borderSide: BorderSide(color: Colors.orange)),
      ),
      validator: Utils.validateMobileField,
      onChanged: (value) {
        whatsappPhnKey.currentState.validate();
        if (value != "") serviceEntity.whatsapp = "+91" + (value);
        print("Whatsapp Number");
      },
      onSaved: (String value) {
        if (value != "") serviceEntity.whatsapp = "+91" + (value);
        print("Whatsapp Number");
      },
    );
//Address fields
    // final adrsField1 = RichText(
    //   text: TextSpan(
    //     style: TextStyle(
    //         color: Colors.blueGrey[700],
    //         // fontWeight: FontWeight.w800,
    //         fontFamily: 'Monsterrat',
    //         letterSpacing: 0.5,
    //         fontSize: 15.0,
    //         decoration: TextDecoration.underline),
    //     children: <TextSpan>[
    //       TextSpan(
    //         text: serviceEntity.address.address,
    //       ),
    //       TextSpan(text: serviceEntity.address.landmark),
    //       TextSpan(text: serviceEntity.address.locality),
    //       TextSpan(text: serviceEntity.address.city),
    //       TextSpan(text: serviceEntity.address.zipcode),
    //       TextSpan(text: serviceEntity.address.state),
    //       TextSpan(text: serviceEntity.address.country),
    //     ],
    //   ),
    // );
    final adrsField1 = TextFormField(
      obscureText: false,
      maxLines: 1,
      minLines: 1,
      style: textInputTextStyle,
      keyboardType: TextInputType.text,
      controller: _adrs1Controller,
      decoration: CommonStyle.textFieldStyle(
          labelTextStr: "Apartment/ House No./ Lane", hintTextStr: ""),
      validator: validateText,
      onChanged: (String value) {
        serviceEntity.address.address = value;
        print("saved address");
      },
      onSaved: (String value) {
        serviceEntity.address.address = value;
        print("saved address");
      },
    );
    final landmarkField2 = TextFormField(
      obscureText: false,
      maxLines: 1,
      minLines: 1,
      style: textInputTextStyle,
      keyboardType: TextInputType.text,
      controller: _landController,
      decoration: InputDecoration(
        labelText: 'Landmark',
        enabledBorder:
            UnderlineInputBorder(borderSide: BorderSide(color: Colors.grey)),
        focusedBorder:
            UnderlineInputBorder(borderSide: BorderSide(color: Colors.orange)),
      ),
      validator: validateText,
      onChanged: (String value) {
        serviceEntity.address.landmark = value;
      },
      onSaved: (String value) {
        serviceEntity.address.landmark = value;
      },
    );
    final localityField = TextFormField(
      obscureText: false,
      maxLines: 1,
      minLines: 1,
      style: textInputTextStyle,
      controller: _localityController,
      keyboardType: TextInputType.text,
      decoration: InputDecoration(
        labelText: 'Locality',
        enabledBorder:
            UnderlineInputBorder(borderSide: BorderSide(color: Colors.grey)),
        focusedBorder:
            UnderlineInputBorder(borderSide: BorderSide(color: Colors.orange)),
      ),
      validator: validateText,
      onSaved: (String value) {
        serviceEntity.address.locality = value;
      },
    );
    final cityField = TextFormField(
      obscureText: false,
      maxLines: 1,
      minLines: 1,
      style: textInputTextStyle,
      keyboardType: TextInputType.text,
      controller: _cityController,
      decoration: InputDecoration(
        labelText: 'City',
        enabledBorder:
            UnderlineInputBorder(borderSide: BorderSide(color: Colors.grey)),
        focusedBorder:
            UnderlineInputBorder(borderSide: BorderSide(color: Colors.orange)),
      ),
      validator: validateText,
      onSaved: (String value) {
        serviceEntity.address.city = value;
      },
    );
    final stateField = TextFormField(
      obscureText: false,
      maxLines: 1,
      minLines: 1,
      style: textInputTextStyle,
      keyboardType: TextInputType.text,
      controller: _stateController,
      decoration: InputDecoration(
        labelText: 'State',
        enabledBorder:
            UnderlineInputBorder(borderSide: BorderSide(color: Colors.grey)),
        focusedBorder:
            UnderlineInputBorder(borderSide: BorderSide(color: Colors.orange)),
      ),
      validator: validateText,
      onSaved: (String value) {
        serviceEntity.address.state = value;
      },
    );
    final countryField = TextFormField(
      obscureText: false,
      maxLines: 1,
      minLines: 1,
      style: textInputTextStyle,
      keyboardType: TextInputType.text,
      controller: _countryController,
      decoration: InputDecoration(
        labelText: 'Country',
        enabledBorder:
            UnderlineInputBorder(borderSide: BorderSide(color: Colors.grey)),
        focusedBorder:
            UnderlineInputBorder(borderSide: BorderSide(color: Colors.orange)),
      ),
      validator: validateText,
      onSaved: (String value) {
        serviceEntity.address.country = value;
      },
    );
    final pinField = TextFormField(
      obscureText: false,
      maxLines: 1,
      minLines: 1,
      style: textInputTextStyle,
      keyboardType: TextInputType.number,
      controller: _pinController,
      decoration: InputDecoration(
        labelText: 'Postal code',
        enabledBorder:
            UnderlineInputBorder(borderSide: BorderSide(color: Colors.grey)),
        focusedBorder:
            UnderlineInputBorder(borderSide: BorderSide(color: Colors.orange)),
      ),
      validator: validateText,
      onSaved: (String value) {
        serviceEntity.address.zipcode = value;
      },
    );
    //Contact person

    void updateModel() {
//Read local file and update the entities.
      print("saving locally");
    }

    TextEditingController _txtController = new TextEditingController();
    bool _delEnabled = false;

    saveRoute() {
      print("saving ");

      String addressStr1;

      addressStr1 =
          (_localityController.text != null) ? _localityController.text : "";
      String addressStr2 =
          (_cityController.text != null) ? _cityController.text : "";

      String addressStr3 =
          _stateController.text != null ? _stateController.text : "";
      String addressStr4 =
          _countryController.text != null ? _countryController.text : "";
      String finalAddressStr;
      if (addressStr2 != "" && addressStr3 != "" && addressStr4 != "")
        finalAddressStr = addressStr1 +
            ", " +
            addressStr2 +
            ", " +
            addressStr3 +
            ", " +
            addressStr4;
      List<Placemark> placemark;
      double lat;
      double long;
      Geolocator().placemarkFromAddress(finalAddressStr).then((value) {
        placemark = value;
        lat = placemark[0].position.latitude;
        print(lat);
        long = placemark[0].position.longitude;
        print(long);
        MyGeoFirePoint geoPoint = new MyGeoFirePoint(lat, long);
        serviceEntity.coordinates = geoPoint;
      });

      print(placemark);

      String validationPh1;
      String validationPh2;
      bool isContactValid = true;

      for (int i = 0; i < contactList.length; i++) {
        validationPh1 = (contactList[i].ph != null)
            ? Utils.validateMobileField(contactList[i].ph.substring(3))
            : null;
        validationPh2 = (contactList[i].altPhone != null)
            ? Utils.validateMobileField(contactList[i].altPhone.substring(3))
            : null;
        print(validationPh1);
        print(validationPh2);
        if (validationPh2 != null || validationPh1 != null) {
          isContactValid = false;
          break;
        }
      }
      if (_serviceDetailsFormKey.currentState.validate() && isContactValid) {
        _serviceDetailsFormKey.currentState.save();

        EntityService()
            .upsertChildEntityToParent(
                serviceEntity, serviceEntity.parentId, _regNumController.text)
            .then((value) {
          print("child entity saved");

          if (value) {
            // Assign admins to newly upserted entity
            assignAdminsFromList(serviceEntity.entityId, adminsList)
                .then((value) {
              if (!value) {
                Utils.showMyFlushbar(
                    context,
                    Icons.info_outline,
                    "Couldn't save the Entity for some reason. ",
                    "Please try again.");
              }
            });
          }
        });
      } else {
        Utils.showMyFlushbar(
            context,
            Icons.info_outline,
            "Seems like you have entered some incorrect details!! ",
            "Please verify the details and try again.");
        setState(() {
          _autoValidate = true;
        });
      }
    }

    processSaveWithTimer() async {
      var duration = new Duration(seconds: 1);
      return new Timer(duration, saveRoute);
    }

    String title = serviceEntity.type;

    String _msg;
    Flushbar flush;
    //bool _wasButtonClicked;
    backRoute() {
      // saveFormDetails();
      // upsertEntity(entity).then((value) {
      //   if (value) {
      Navigator.pop(context);
      //                }
      // });
    }

    processGoBackWithTimer() async {
      var duration = new Duration(seconds: 1);
      return new Timer(duration, backRoute);
    }

    Future<void> showConfirmationDialog() async {
      bool returnVal = await showDialog(
          barrierDismissible: false,
          context: context,
          builder: (_) => AlertDialog(
                titlePadding: EdgeInsets.fromLTRB(5, 10, 0, 0),
                contentPadding: EdgeInsets.all(0),
                actionsPadding: EdgeInsets.all(0),
                //buttonPadding: EdgeInsets.all(0),
                title: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      'Bookable premise means that time-slots can be booked, for eg. Shopping store, Salon. Premises that are not bookable are Apartments, Malls etc.',
                      style: TextStyle(
                        fontSize: 15,
                        color: Colors.blueGrey[600],
                      ),
                    ),
                    verticalSpacer,
                    Text(
                      'Are you sure you make this premise bookable?',
                      style: TextStyle(
                        fontSize: 15,
                        color: Colors.blueGrey[600],
                      ),
                    ),
                    verticalSpacer,
                    // myDivider,
                  ],
                ),
                content: Divider(
                  color: Colors.blueGrey[400],
                  height: 1,
                  //indent: 40,
                  //endIndent: 30,
                ),

                //content: Text('This is my content'),
                actions: <Widget>[
                  SizedBox(
                    height: 24,
                    child: RaisedButton(
                      elevation: 0,
                      color: Colors.transparent,
                      splashColor: highlightColor.withOpacity(.8),
                      textColor: Colors.orange,
                      shape: RoundedRectangleBorder(
                          side: BorderSide(color: Colors.orange)),
                      child: Text('Yes'),
                      onPressed: () {
                        Navigator.of(_).pop(true);
                      },
                    ),
                  ),
                  SizedBox(
                    height: 24,
                    child: RaisedButton(
                      elevation: 20,
                      autofocus: true,
                      focusColor: highlightColor,
                      splashColor: highlightColor,
                      color: Colors.white,
                      textColor: Colors.orange,
                      shape: RoundedRectangleBorder(
                          side: BorderSide(color: Colors.orange)),
                      child: Text('No'),
                      onPressed: () {
                        Navigator.of(_).pop(false);
                      },
                    ),
                  ),
                ],
              ));

      if (returnVal) {
        setState(() {
          isBookable = true;
        });
        serviceEntity.isBookable = true;
      } else {
        setState(() {
          isBookable = false;
        });
        serviceEntity.isBookable = false;
      }
    }

    validateAllFields() {
      bool retVal;
      if (_serviceDetailsFormKey.currentState.validate())
        retVal = true;
      else
        retVal = false;
      return retVal;
    }

    final adminItemField = new TextFormField(
      key: adminItemKey,
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
          hintText: "Enter Admin's Contact number & Click (+)",
          hintStyle: new TextStyle(fontSize: 12, color: Colors.blueGrey[500])),
      validator: Utils.validateMobileField,
      onChanged: (value) {
        adminItemKey.currentState.validate();
        setState(() {
          _item = '+91' + value;
          // _errMsg = "";
        });
      },
      onSaved: (newValue) {
        _item = '+91' + newValue;
      },
    );

    return MaterialApp(
      title: 'Add child entities',
      theme: ThemeData.light().copyWith(),
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
                print("going back");
                //Show flush bar to notify user
                if (flushStatus != "Showing") {
                  flush = Flushbar<bool>(
                    //padding: EdgeInsets.zero,
                    margin: EdgeInsets.zero,
                    flushbarPosition: FlushbarPosition.BOTTOM,
                    flushbarStyle: FlushbarStyle.GROUNDED,
                    reverseAnimationCurve: Curves.decelerate,
                    forwardAnimationCurve: Curves.easeInToLinear,
                    backgroundColor: headerBarColor,
                    boxShadows: [
                      BoxShadow(
                          color: primaryAccentColor,
                          offset: Offset(0.0, 2.0),
                          blurRadius: 3.0)
                    ],
                    isDismissible: false,
                    //duration: Duration(seconds: 4),
                    icon: Icon(
                      Icons.cancel,
                      color: Colors.blueGrey[50],
                    ),
                    showProgressIndicator: true,
                    progressIndicatorBackgroundColor: Colors.blueGrey[800],
                    routeBlur: 10.0,
                    titleText: Text(
                      "Are you sure you want to leave this page?",
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16.0,
                          color: primaryAccentColor,
                          fontFamily: "ShadowsIntoLightTwo"),
                    ),
                    messageText: Text(
                      "The changes you made might be lost.",
                      style: TextStyle(
                          fontSize: 10.0,
                          color: Colors.blueGrey[50],
                          fontFamily: "ShadowsIntoLightTwo"),
                    ),

                    mainButton: Column(
                      children: <Widget>[
                        FlatButton(
                          padding: EdgeInsets.all(0),
                          onPressed: () {
                            flushStatus = "Empty";
                            flush.dismiss(true); // result = true
                          },
                          child: Text(
                            "Yes",
                            style: TextStyle(color: highlightColor),
                          ),
                        ),
                        FlatButton(
                          padding: EdgeInsets.all(0),
                          onPressed: () {
                            flushStatus = "Empty";
                            flush.dismiss(false); // result = true
                          },
                          child: Text(
                            "No",
                            style: TextStyle(color: highlightColor),
                          ),
                        ),
                      ],
                    ),
                  )..onStatusChanged = (FlushbarStatus status) {
                      print("FlushbarStatus-------$status");
                      if (status == FlushbarStatus.IS_APPEARING)
                        flushStatus = "Showing";
                      if (status == FlushbarStatus.DISMISSED)
                        flushStatus = "Empty";
                      print("gfdfgdfg");
                    };

                  flush
                    ..show(context).then((result) {
                      _wasButtonClicked = result;
                      flushStatus = "Empty";
                      if (_wasButtonClicked) processGoBackWithTimer();
                    });
                }

                print("flush already running");
              },
            ),
            title: Text(
              title,
              style: whiteBoldTextStyle1,
              overflow: TextOverflow.ellipsis,
            )),
        body: Center(
          child: SafeArea(
            child: new Form(
              key: _serviceDetailsFormKey,
              autovalidate: _autoValidate,
              child: ListView(
                padding: const EdgeInsets.all(5.0),
                // crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 8),
                    decoration: BoxDecoration(
                        border: Border.all(color: containerColor),
                        color: Colors.grey[50],
                        shape: BoxShape.rectangle,
                        borderRadius: BorderRadius.all(Radius.circular(5.0))),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Row(
                          children: <Widget>[
                            Text('Public'),
                            Container(
                              width: MediaQuery.of(context).size.width * .17,
                              child: Switch(
                                value: isPublic,
                                onChanged: (value) {
                                  setState(() {
                                    if (value) {
                                      validateField = true;
                                      _autoValidate = true;
                                      bool retVal = validateAllFields();
                                      if (!retVal) {
                                        //Show flushbar with info that fields has invalid data
                                        Utils.showMyFlushbar(
                                            context,
                                            Icons.info_outline,
                                            "Missing Information!! Making premises public require the basic details",
                                            "Please check and try again !!");
                                      } else {
                                        validateField = false;
                                        isPublic = value;
                                        serviceEntity.isPublic = value;
                                        print(isPublic);
                                      }
                                    } else {
                                      isPublic = value;
                                      serviceEntity.isPublic = value;
                                      print(isPublic);
                                    }
                                  });
                                },
                                // activeTrackColor: Colors.green,
                                activeColor: highlightColor,
                              ),
                            ),
                          ],
                        ),
                        Row(
                          children: <Widget>[
                            Text('Bookable'),
                            Container(
                              width: MediaQuery.of(context).size.width * .17,
                              child: Switch(
                                value: isBookable,
                                onChanged: (value) {
                                  setState(() {
                                    isBookable = value;
                                    serviceEntity.isBookable = value;
                                    if (value) {
                                      showConfirmationDialog();
                                    }
                                    print(isBookable);
                                  });
                                },
                                // activeTrackColor: Colors.green,
                                activeColor: highlightColor,
                              ),
                            ),
                          ],
                        ),
                        Row(
                          children: <Widget>[
                            Text('Active'),
                            Container(
                              width: MediaQuery.of(context).size.width * .17,
                              child: Switch(
                                value: isActive,
                                onChanged: (value) {
                                  setState(() {
                                    if (value) {
                                      validateField = true;
                                      _autoValidate = true;
                                      bool retVal = validateAllFields();
                                      if (!retVal) {
                                        //Show flushbar with info that fields has invalid data
                                        Utils.showMyFlushbar(
                                            context,
                                            Icons.info_outline,
                                            "Missing Information!! Making premises active require the basic details",
                                            "Please check and try again !!");
                                      } else {
                                        validateField = false;
                                        isActive = value;
                                        serviceEntity.isActive = value;
                                        print(isActive);
                                      }
                                    } else {
                                      isActive = value;
                                      serviceEntity.isActive = value;
                                      print(isActive);
                                    }
                                  });
                                },
                                // activeTrackColor: Colors.green,
                                activeColor: highlightColor,
                              ),
                            ),
                          ],
                        )
                      ],
                    ),
                  ),

                  SizedBox(
                    height: 7,
                  ),

                  Container(
                    decoration: BoxDecoration(
                        border: Border.all(color: borderColor),
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
                                        "Basic Details",
                                        style: TextStyle(
                                            color: Colors.white, fontSize: 15),
                                      ),
                                      SizedBox(width: 5),
                                    ],
                                  ),
                                  backgroundColor: Colors.blueGrey[500],

                                  children: <Widget>[
                                    new Container(
                                      width: MediaQuery.of(context).size.width *
                                          .94,
                                      decoration: darkContainer,
                                      padding: EdgeInsets.all(2.0),
                                      child: Expanded(
                                        child: Text(basicInfoStr,
                                            style: buttonXSmlTextStyle),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            Container(
                              padding: EdgeInsets.only(left: 5.0, right: 5),
                              child: Column(
                                children: <Widget>[
                                  nameField,
                                  descField,
                                  // entityType,
                                  regNumField,
                                  opensTimeField,
                                  closeTimeField,
                                  breakSartTimeField,
                                  breakEndTimeField,
                                  daysClosedField,
                                  slotDuration,
                                  advBookingInDays,
                                  maxpeopleInASlot,
                                  whatsappPhone,
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 7,
                  ),
                  Container(
                    decoration: BoxDecoration(
                        border: Border.all(color: containerColor),
                        color: Colors.grey[50],
                        shape: BoxShape.rectangle,
                        borderRadius: BorderRadius.all(Radius.circular(5.0))),
                    //padding: EdgeInsets.all(5.0),
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
                                        "Address",
                                        style: TextStyle(
                                            color: Colors.white, fontSize: 15),
                                      ),
                                      SizedBox(width: 5),
                                    ],
                                  ),
                                  backgroundColor: Colors.blueGrey[500],

                                  children: <Widget>[
                                    new Container(
                                      width: MediaQuery.of(context).size.width *
                                          .94,
                                      decoration: darkContainer,
                                      padding: EdgeInsets.all(2.0),
                                      child: Expanded(
                                        child: Text(addressInfoStr,
                                            style: buttonXSmlTextStyle),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                        Container(
                          padding: EdgeInsets.only(left: 5.0, right: 5),
                          child: Column(
                            children: <Widget>[
                              RaisedButton(
                                elevation: 20,
                                color: btnColor,
                                splashColor: highlightColor,
                                textColor: Colors.white,
                                // shape: RoundedRectangleBorder(
                                //     side: BorderSide(color: btnColor)),
                                child: Text('Use current location'),
                                onPressed: _getCurrLocation,
                              ),
                              adrsField1,
                              landmarkField2,
                              localityField,
                              cityField,
                              stateField,
                              pinField,
                              countryField,
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 7,
                  ),
                  Container(
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
                                            color: Colors.white, fontSize: 15),
                                      ),
                                      SizedBox(width: 5),
                                    ],
                                  ),
                                  // trailing: IconButton(
                                  //   icon: Icon(Icons.add_circle,
                                  //       color: highlightColor, size: 40),
                                  //   onPressed: () {
                                  //     if (_adminItemController.text == null ||
                                  //         _adminItemController.text.isEmpty) {
                                  //       Utils.showMyFlushbar(
                                  //           context,
                                  //           Icons.info_outline,
                                  //           "Something Missing ..",
                                  //           "Please enter Phone number !!");
                                  //     } else {
                                  //       bool result = adminItemKey.currentState
                                  //           .validate();
                                  //       if (result) {
                                  //         _addNewAdminRow();
                                  //         _adminItemController.text = "";
                                  //       } else {
                                  //         Utils.showMyFlushbar(
                                  //             context,
                                  //             Icons.info_outline,
                                  //             "Oops!! Seems like the phone number is not valid",
                                  //             "Please check and try again !!");
                                  //       }
                                  //     }
                                  //   },
                                  // ),
                                  backgroundColor: Colors.blueGrey[500],
                                  children: <Widget>[
                                    new Container(
                                      width: MediaQuery.of(context).size.width *
                                          .94,
                                      decoration: darkContainer,
                                      padding: EdgeInsets.all(2.0),
                                      child: Row(
                                        children: <Widget>[
                                          Expanded(
                                            child: Text(contactInfoStr,
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
                                      MediaQuery.of(context).size.width * .13,
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
                                        child: adminItemField,
                                      ),
                                      Container(
                                        padding:
                                            EdgeInsets.fromLTRB(0, 0, 0, 0),
                                        width:
                                            MediaQuery.of(context).size.width *
                                                .1,
                                        height:
                                            MediaQuery.of(context).size.width *
                                                .1,
                                        child: IconButton(
                                            padding: EdgeInsets.all(0),
                                            icon: Icon(Icons.add_circle,
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
                                                    "Something Missing ..",
                                                    "Please enter Phone number !!");
                                              } else {
                                                bool result = adminItemKey
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

                  SizedBox(
                    height: 7,
                  ),
                  //THIS CONTAINER
                  Container(
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
                                        "Add a Manager",
                                        style: TextStyle(
                                            color: Colors.white, fontSize: 15),
                                      ),
                                      SizedBox(width: 5),
                                    ],
                                  ),
                                  backgroundColor: Colors.blueGrey[500],

                                  children: <Widget>[
                                    new Container(
                                      width: MediaQuery.of(context).size.width *
                                          .94,
                                      decoration: darkContainer,
                                      padding: EdgeInsets.all(2.0),
                                      child: Row(
                                        children: <Widget>[
                                          Expanded(
                                            child: Text(contactInfoStr,
                                                style: buttonXSmlTextStyle),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.fromLTRB(8.0, 0, 8, 0),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: <Widget>[
                                  // Expanded(
                                  //   child: roleType,
                                  // ),
                                  Container(
                                    child: IconButton(
                                      icon: Icon(Icons.add_circle,
                                          color: highlightColor, size: 40),
                                      onPressed: () {
                                        // if (_roleType != null) {
                                        //   setState(() {
                                        //     _msg = null;
                                        //   });
                                        _addNewContactRow();
                                        // } else {
                                        //   setState(() {
                                        //     _msg = "Select role type";
                                        //   });
                                        // }
                                      },
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            (_msg != null)
                                ? Text(
                                    _msg,
                                    style: errorTextStyle,
                                  )
                                : Container(),
                            if (!Utils.isNullOrEmpty(contactList))
                              Column(children: contactRowWidgets),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // Container(
                  //   decoration: BoxDecoration(
                  //       border: Border.all(color: Colors.indigo),
                  //       color: Colors.grey[50],
                  //       shape: BoxShape.rectangle,
                  //       borderRadius: BorderRadius.all(Radius.circular(5.0))),
                  //   //  padding: EdgeInsets.all(5.0),
                  //   child: Column(
                  //     crossAxisAlignment: CrossAxisAlignment.start,
                  //     children: <Widget>[
                  //       Column(
                  //         children: <Widget>[
                  //           Container(
                  //             decoration: indigoContainer,
                  //             child: Theme(
                  //               data: ThemeData(
                  //                 unselectedWidgetColor: Colors.white,
                  //                 accentColor: Colors.grey[50],
                  //               ),
                  //               child: CustomExpansionTile(
                  //                 //key: PageStorageKey(this.widget.headerTitle),
                  //                 initiallyExpanded: false,
                  //                 title: Row(
                  //                   children: <Widget>[
                  //                     Text(
                  //                       "Contact Person",
                  //                       style: TextStyle(
                  //                           color: Colors.white, fontSize: 15),
                  //                     ),
                  //                     SizedBox(width: 5),
                  //                   ],
                  //                 ),
                  //                 backgroundColor: Colors.blueGrey[500],

                  //                 children: <Widget>[
                  //                   new Container(
                  //                     width: MediaQuery.of(context).size.width *
                  //                         .94,
                  //                     decoration: indigoContainer,
                  //                     padding: EdgeInsets.all(2.0),
                  //                     child: Expanded(
                  //                       child: Text(contactInfoStr,
                  //                           style: buttonXSmlTextStyle),
                  //                     ),
                  //                   ),
                  //                 ],
                  //               ),
                  //             ),
                  //           ),
                  //         ],
                  //       ),
                  //       Container(
                  //           padding: EdgeInsets.only(left: 5.0, right: 5),
                  //           child: Column(
                  //             children: <Widget>[
                  //               ctNameField,
                  //               ctEmpIdField,
                  //               ctPhn1Field,
                  //               ctPhn2Field,
                  //               daysOffField,
                  //               Divider(
                  //                 thickness: .7,
                  //                 color: Colors.grey[600],
                  //               ),
                  //               ctAvlFromTimeField,
                  //               ctAvlTillTimeField,
                  //               new FormField(
                  //                 builder: (FormFieldState state) {
                  //                   return InputDecorator(
                  //                     decoration: InputDecoration(
                  //                       icon: const Icon(Icons.person),
                  //                       labelText: 'Role ',
                  //                     ),
                  //                     child: new DropdownButtonHideUnderline(
                  //                       child: new DropdownButton(
                  //                         value: _role,
                  //                         isDense: true,
                  //                         onChanged: (newValue) {
                  //                           setState(() {
                  //                             // newContact.favoriteColor = newValue;
                  //                             _role = newValue;
                  //                             state.didChange(newValue);
                  //                           });
                  //                         },
                  //                         items: roleTypes.map((role) {
                  //                           return DropdownMenuItem(
                  //                             value: role,
                  //                             child: new Text(
                  //                               role.toString(),
                  //                               style: textInputTextStyle,
                  //                             ),
                  //                           );
                  //                         }).toList(),
                  //                       ),
                  //                     ),
                  //                   );
                  //                 },
                  //               ),
                  //             ],
                  //           )),
                  //     ],
                  //   ),
                  // ),
                  Builder(
                    builder: (context) => RaisedButton(
                        color: btnColor,
                        splashColor: highlightColor,
                        child: Container(
                          // width: MediaQuery.of(context).size.width * .35,
                          child: Column(
                            children: <Widget>[
                              Text(
                                'Save',
                                style: buttonMedTextStyle,
                              ),
                              // Text(
                              //   'Save this service',
                              //   style: buttonXSmlTextStyle,
                              // ),
                            ],
                          ),
                        ),
                        onPressed: () {
                          flush = Flushbar(
                            //padding: EdgeInsets.zero,
                            margin: EdgeInsets.zero,
                            flushbarPosition: FlushbarPosition.BOTTOM,
                            flushbarStyle: FlushbarStyle.GROUNDED,
                            reverseAnimationCurve: Curves.decelerate,
                            forwardAnimationCurve: Curves.easeInToLinear,
                            backgroundColor: headerBarColor,
                            boxShadows: [
                              BoxShadow(
                                  color: primaryAccentColor,
                                  offset: Offset(0.0, 2.0),
                                  blurRadius: 3.0)
                            ],
                            isDismissible: false,
                            //duration: Duration(seconds: 4),
                            icon: Icon(
                              Icons.cancel,
                              color: Colors.orangeAccent[400],
                            ),
                            showProgressIndicator: true,
                            progressIndicatorBackgroundColor:
                                Colors.blueGrey[800],
                            routeBlur: 10.0,
                            titleText: Text(
                              "Saving Details",
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16.0,
                                  color: primaryAccentColor,
                                  fontFamily: "ShadowsIntoLightTwo"),
                            ),
                            messageText: Text(
                              "This will take just a moment !!",
                              style: TextStyle(
                                  fontSize: 12.0,
                                  color: Colors.blueGrey[50],
                                  fontFamily: "ShadowsIntoLightTwo"),
                            ),
                            duration: Duration(seconds: 4),

                            // mainButton: Column(
                            //   children: <Widget>[
                            //     FlatButton(
                            //       padding: EdgeInsets.all(0),
                            //       onPressed: () {
                            //         flush.dismiss(true); // result = true
                            //       },
                            //       child: Text(
                            //         "Yes",
                            //         style: TextStyle(color: highlightColor),
                            //       ),
                            //     ),
                            //     FlatButton(
                            //       padding: EdgeInsets.all(0),
                            //       onPressed: () {
                            //         flush.dismiss(false); // result = true
                            //       },
                            //       child: Text(
                            //         "No",
                            //         style: TextStyle(color: highlightColor),
                            //       ),
                            //     ),
                            //   ],
                            // ),
                          )
                            ..onStatusChanged = (FlushbarStatus status) {
                              print("FlushbarStatus-------$status");
                            }
                            ..show(context);
                          print("FlushbarStatus-------");

                          processSaveWithTimer();

                          //processSaveWithTimer();
                        }),
                  ),
                  Builder(
                    builder: (context) => RaisedButton(
                        color: Colors.blueGrey[400],
                        splashColor: highlightColor,
                        child: Container(
                          //width: MediaQuery.of(context).size.width * .35,
                          child: Column(
                            children: <Widget>[
                              Text(
                                'Delete',
                                style: buttonMedTextStyle,
                              ),
                              Text(
                                'Delete this amenity/service',
                                style: buttonXSmlTextStyle,
                              ),
                            ],
                          ),
                        ),
                        onPressed: () {
                          String _errorMessage;
                          showDialog(
                              context: context,
                              barrierDismissible: true,
                              builder: (BuildContext context) {
                                return StatefulBuilder(
                                    builder: (context, setState) {
                                  return new AlertDialog(
                                    backgroundColor: Colors.grey[200],
                                    // titleTextStyle: inputTextStyle,
                                    elevation: 10.0,
                                    content: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: <Widget>[
                                        RichText(
                                          text: TextSpan(
                                              style: lightSubTextStyle,
                                              children: <TextSpan>[
                                                TextSpan(text: "Enter "),
                                                TextSpan(
                                                    text: "DELETE ",
                                                    style: errorTextStyle),
                                                TextSpan(
                                                    text:
                                                        "to permanently delete this entity and all its services. Once deleted you cannot restore them. "),
                                              ]),
                                        ),
                                        new Row(
                                          children: <Widget>[
                                            new Expanded(
                                              child: new TextField(
                                                style: inputTextStyle,
                                                textCapitalization:
                                                    TextCapitalization
                                                        .characters,
                                                controller: _txtController,
                                                decoration: InputDecoration(
                                                  hintText: 'eg. delete',
                                                  enabledBorder:
                                                      UnderlineInputBorder(
                                                          borderSide:
                                                              BorderSide(
                                                                  color: Colors
                                                                      .grey)),
                                                  focusedBorder:
                                                      UnderlineInputBorder(
                                                          borderSide:
                                                              BorderSide(
                                                                  color: Colors
                                                                      .orange)),
                                                ),
                                                onEditingComplete: () {
                                                  print(_txtController.text);
                                                },
                                                onChanged: (value) {
                                                  if (value.toUpperCase() ==
                                                      "DELETE".toUpperCase())
                                                    setState(() {
                                                      _delEnabled = true;
                                                      _errorMessage = null;
                                                    });
                                                  else
                                                    setState(() {
                                                      _errorMessage =
                                                          "You have to enter DELETE to proceed.";
                                                    });
                                                },
                                                autofocus: false,
                                              ),
                                            )
                                          ],
                                        ),
                                        (_errorMessage != null
                                            ? Text(
                                                _errorMessage,
                                                style: errorTextStyle,
                                              )
                                            : Container()),
                                      ],
                                    ),

                                    contentPadding: EdgeInsets.all(10),
                                    actions: <Widget>[
                                      RaisedButton(
                                        color: (_delEnabled)
                                            ? btnColor
                                            : Colors.blueGrey[200],
                                        elevation: (_delEnabled) ? 20 : 0,
                                        onPressed: () {
                                          if (_delEnabled) {
                                            String parentEntityId =
                                                serviceEntity.parentId;

                                            Entity parentEntity;

                                            //     .deleteEntity(serviceEntity.id)
                                            //     .whenComplete(() {
                                            //   Navigator.pop(context);

                                            //   getEntity(parentEntityId)
                                            //       .then((value) =>
                                            //           parentEntity = value)
                                            //       .whenComplete(() => Navigator.push(
                                            //           context,
                                            //           MaterialPageRoute(
                                            //               builder: (context) =>
                                            //                   EntityServicesListPage(
                                            //                       entity:
                                            //                           parentEntity))));
                                            // });
//TODO: Problem in this method, not deleting entity from list
                                            deleteEntity(serviceEntity.entityId)
                                                .whenComplete(() {
                                              Navigator.pop(context);
                                              //TDOD: Uncomment getEntity method below.

                                              EntityService()
                                                  .getEntity(parentEntityId)
                                                  .then((value) =>
                                                      {parentEntity = value})
                                                  .whenComplete(() => Navigator.push(
                                                      context,
                                                      MaterialPageRoute(
                                                          builder: (context) =>
                                                              ChildEntitiesListPage(
                                                                  entity:
                                                                      parentEntity))));
                                            });
                                          }
                                        },
                                        splashColor: (_delEnabled)
                                            ? highlightColor
                                            : Colors.blueGrey[200],
                                        child: Container(
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              .3,
                                          alignment: Alignment.center,
                                          child: Text("Delete",
                                              style: TextStyle(
                                                  color: Colors.white)),
                                        ),
                                      ),
                                      // (_errorMessage != null
                                      //     ? Text(
                                      //         _errorMessage,
                                      //         style: TextStyle(color: Colors.red),
                                      //       )
                                      //     : Container()),
                                    ],
                                  );
                                });
                              });
                          // final snackBar1 = SnackBar(
                          //   shape: Border.all(
                          //     color: tealIcon,
                          //     width: 2,
                          //   ),
                          //   // action: SnackBarAction(
                          //   //   label: 'Delete!',
                          //   //   onPressed: () {
                          //   //     deleteEntity();
                          //   //   },
                          //   // ),
                          //   backgroundColor: Colors.grey[200],
                          //   content: Container(
                          //     height: MediaQuery.of(context).size.width * .25,
                          //     child: Column(
                          //       children: <Widget>[
                          //         RichText(
                          //           text: TextSpan(
                          //               style: lightSubTextStyle,
                          //               children: <TextSpan>[
                          //                 TextSpan(text: "Enter "),
                          //                 TextSpan(
                          //                     text: "DELETE ",
                          //                     style: homeMsgStyle3),
                          //                 TextSpan(
                          //                     text:
                          //                         "to remove this entity from your managed ones."),
                          //               ]),
                          //         ),
                          //         Row(
                          //           children: <Widget>[
                          //             // TextField(
                          //             //   //   controller: _txtController,
                          //             //   onChanged: (value) {
                          //             //     if (value == "DELETE")
                          //             //       _delEnabled = true;
                          //             //   },
                          //             // ),
                          //             RaisedButton(
                          //               color: (_delEnabled)
                          //                   ? lightIcon
                          //                   : Colors.blueGrey[400],
                          //               disabledColor: Colors.blueGrey[200],
                          //               disabledElevation: 0,
                          //               elevation: 15,
                          //               onPressed: () {
                          //                 deleteEntity();
                          //               },
                          //               splashColor: highlightColor,
                          //               child: Text("Delete",
                          //                   style:
                          //                       TextStyle(color: Colors.white)),
                          //             ),
                          //           ],
                          //         )
                          //       ],
                          //     ),
                          //   ),
                          //   //duration: Duration(seconds: 3),
                          // );
                          // Scaffold.of(context).showSnackBar(snackBar1);
                        }),
                  ),
                ],
              ),
            ),
          ),
        ),
        bottomNavigationBar: CustomBottomBar(
          barIndex: 0,
        ),
      ),
    );
  }
}
