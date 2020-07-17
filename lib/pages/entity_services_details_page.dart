import 'dart:ui';

import 'package:flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import 'package:noq/db/db_model/address.dart';
import 'package:noq/db/db_model/employee.dart';
import 'package:noq/db/db_model/entity.dart';
import 'package:noq/db/db_model/meta_entity.dart';
import 'package:noq/db/db_service/entity_service.dart';
import 'package:noq/models/localDB.dart';
import 'dart:async';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:noq/constants.dart';
import 'package:noq/pages/contact_item.dart';
import 'package:noq/pages/entity_services_list_page.dart';
import 'package:noq/repository/StoreRepository.dart';
import 'package:noq/repository/local_db_repository.dart';
import 'package:noq/style.dart';
import 'package:noq/utils.dart';
import 'package:noq/widget/bottom_nav_bar.dart';
import 'package:noq/widget/custome_expansion_tile.dart';
import 'package:noq/widget/weekday_selector.dart';
import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:noq/widget/widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

class ServiceEntityDetailsPage extends StatefulWidget {
  final Entity serviceMetaEntity;
  ServiceEntityDetailsPage({Key key, @required this.serviceMetaEntity})
      : super(key: key);
  @override
  _ServiceEntityDetailsPageState createState() =>
      _ServiceEntityDetailsPageState();
}

class _ServiceEntityDetailsPageState extends State<ServiceEntityDetailsPage> {
  final GlobalKey<FormState> _serviceDetailsFormKey =
      new GlobalKey<FormState>();
  final String title = "Managers Form";
  final Geolocator geolocator = Geolocator()..forceAndroidLocationManager;

  TextEditingController _nameController = TextEditingController();
  TextEditingController _regNumController = TextEditingController();
  TextEditingController _closeTimeController = TextEditingController();
  TextEditingController _openTimeController = TextEditingController();
  TextEditingController _breakStartController = TextEditingController();
  TextEditingController _breakEndController = TextEditingController();

  TextEditingController _maxPeopleController = TextEditingController();
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

  //ContactPerson Fields
  TextEditingController _ctNameController = TextEditingController();
  TextEditingController _ctEmpIdController = TextEditingController();
  TextEditingController _ctPhn1controller = TextEditingController();
  TextEditingController _ctPhn2controller = TextEditingController();
  TextEditingController _ctAvlFromTimeController = TextEditingController();
  TextEditingController _ctAvlTillTimeController = TextEditingController();

  List<String> _daysOff = List<String>();

  AddressAppData adrs = new AddressAppData();
  // MetaEntity _metaEntity;

  Entity serviceEntity;

  List<ContactAppData> newList = new List<ContactAppData>();

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
// ChildEntityAppData serviceEntity;

  List<Employee> contactList = new List<Employee>();
  List<Widget> contactRowWidgets = new List<Widget>();
  int _contactCount = 0;
  String _roleType;

  @override
  void initState() {
    super.initState();
    serviceEntity = widget.serviceMetaEntity;
    // var uuid = new Uuid();
    // serviceEntity.id = uuid.v1();
    _getCurrLocation();
    initializeEntity();

    //load the service details
    //loadServiceEntity(serviceEntity.id);

    //  serviceEntity.contactPersons = new List<ContactAppData>();
    serviceEntity.address = new Address();
    // serviceEntity.contactPersons.add(cp1);
    // addPerson();
  }

  initializeEntity() async {
    // serviceEntity = await getEntity(_metaEntity.entityId);
    if (serviceEntity != null) {
      _nameController.text = serviceEntity.name;
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
      if (serviceEntity.closedOn != null) _daysOff = serviceEntity.closedOn;
      if (serviceEntity.maxAllowed != null)
        _maxPeopleController.text = serviceEntity.maxAllowed.toString();
      //address
      if (serviceEntity.address != null) {
        _adrs1Controller.text = serviceEntity.address.address;
        _localityController.text = serviceEntity.address.locality;
        _landController.text = serviceEntity.address.landmark;
        _cityController.text = serviceEntity.address.city;
        _stateController.text = serviceEntity.address.state;
        _countryController.text = serviceEntity.address.country;
        _pinController.text = serviceEntity.address.zipcode;
//contact person
        if (!(Utils.isNullOrEmpty(serviceEntity.managers))) {
          contactList = serviceEntity.managers;
        }
      }
    } else {
      //TODO:do nothing as this metaEntity is just created and will saved in DB only on save
      Map<String, dynamic> entityJSON = <String, dynamic>{
        'type': serviceEntity.type,
        'entityId': serviceEntity.entityId
      };

      serviceEntity = Entity.fromJson(entityJSON);
      // EntityService().upsertEntity(serviceEntity);
    }
    serviceEntity.address = (serviceEntity.address) ?? new Address();
    contactList = contactList ?? new List<Employee>();
  }

  String validateText(String value) {
    if (value == null) {
      return 'Field is empty';
    }
    return null;
  }

  String validateTime(String value) {
    if (value == null) {
      return 'Field is empty';
    }

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

  Future<List> getList() async {
    List<ContactAppData> contactList = new List<ContactAppData>();
    ContactAppData cp =
        new ContactAppData.values('a', 'b', 'c', 'd', "Manager", 'f', 'g', []);
    // ContactPerson cp4 =
    //     new ContactPerson.values('a', 'b', 'c', 'd', 'e', 'f', 'g');
    // contactList.add(cp1);
    // contactList.add(cp2);
    print('list contakajsgdsdfklsjhdk');

    newList.add(cp);
    contactList = newList;
    return contactList;
  }

  void saveFormDetails() async {
    print("saving ");

    if (_serviceDetailsFormKey.currentState.validate()) {
      _serviceDetailsFormKey.currentState.save();
      print("Saved formmmmmmm");
    }
  }

  saveDetails() async {
    // List<Placemark> placemark = await Geolocator().placemarkFromAddress(
    //     "My Home Vihanga, Financial District, Gachibowli, Hyderabad, Telangana, India");

    // print(placemark);
    saveFormDetails();
    EntityService()
        .upsertChildEntityToParent(
            serviceEntity, serviceEntity.parentId, _regNumController.text)
        .then((value) {
      if (value) {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) =>
                    EntityServicesListPage(entity: this.serviceEntity)));
      }
    });
  }

  void _addNewContactRow() {
    setState(() {
      Employee contact = new Employee();

      contactRowWidgets.insert(0, new ContactRow(contact: contact));

      contactList.add(contact);
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

          String time = DateFormat.jm().format(date);
          print(time);

          _openTimeController.text = time.toLowerCase();
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
        if (value != "") {
          List<String> time = value.split(':');
          serviceEntity.startTimeHour = int.parse(time[0]);
          serviceEntity.startTimeMinute = int.parse(time[1]);
        }
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

          String time = DateFormat.jm().format(date);
          print(time);

          _closeTimeController.text = time.toLowerCase();
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
      onSaved: (String value) {
        //TODO: test the values
        if (value != "") {
          List<String> time = value.split(':');
          serviceEntity.endTimeHour = int.parse(time[0]);
          serviceEntity.endTimeMinute = int.parse(time[1]);
        }
      },
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

          String time = DateFormat.jm().format(date);
          print(time);

          _breakStartController.text = time.toLowerCase();
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
      onSaved: (String value) {
        //TODO: test the values
        if (value != "") {
          List<String> time = value.split(':');
          serviceEntity.breakStartHour = int.parse(time[0]);
          serviceEntity.breakStartMinute = int.parse(time[1]);
        }
      },
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

          String time = DateFormat.jm().format(date);
          print(time);

          _breakEndController.text = time.toLowerCase();
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
        if (value != "") {
          List<String> time = value.split(':');
          serviceEntity.breakEndHour = int.parse(time[0]);
          serviceEntity.breakEndMinute = int.parse(time[1]);
        }
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
            initialValue: [days.sunday],
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
        serviceEntity.maxAllowed = int.parse(value);
      },
      onSaved: (String value) {
        if (value != "") serviceEntity.maxAllowed = int.parse(value);
        print("saved max people");
        // entity. = value;
      },
    );
//Address fields
    final adrsField1 = RichText(
      text: TextSpan(
        style: TextStyle(
            color: Colors.blueGrey[700],
            // fontWeight: FontWeight.w800,
            fontFamily: 'Monsterrat',
            letterSpacing: 0.5,
            fontSize: 15.0,
            decoration: TextDecoration.underline),
        children: <TextSpan>[
          TextSpan(
            text: serviceEntity.address.address,
          ),
          TextSpan(text: serviceEntity.address.landmark),
          TextSpan(text: serviceEntity.address.locality),
          TextSpan(text: serviceEntity.address.city),
          TextSpan(text: serviceEntity.address.zipcode),
          TextSpan(text: serviceEntity.address.state),
          TextSpan(text: serviceEntity.address.country),
        ],
      ),
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

    void saveFormDetails() {
      print("saving ");
      if (_serviceDetailsFormKey.currentState.validate()) {
        _serviceDetailsFormKey.currentState.save();
      }
    }

    void updateModel() {
//Read local file and update the entities.
      print("saving locally");
    }

    TextEditingController _txtController = new TextEditingController();
    bool _delEnabled = false;
    saveRoute() {
      saveFormDetails();
      EntityService()
          .upsertChildEntityToParent(
              serviceEntity, serviceEntity.parentId, _regNumController.text)
          .then((value) {
        if (value) {
          EntityService().getEntity(this.serviceEntity.parentId).then((value) =>
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) =>
                          EntityServicesListPage(entity: value))));
        }
      });
      //saveChildEntity(serviceEntity);
      // Navigator.push(
      //     context,
      //     MaterialPageRoute(
      //         builder: (context) =>
      //             EntityServicesListPage(entity: this.entity)));
    }

    processSaveWithTimer() async {
      var duration = new Duration(seconds: 1);
      return new Timer(duration, saveRoute);
    }

    String title = serviceEntity.type;

    String _msg;
    Flushbar flush;
    bool _wasButtonClicked;
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

    final roleType = new FormField(
      builder: (FormFieldState state) {
        return InputDecorator(
          decoration: InputDecoration(
            labelText: 'Role Type',
          ),
          child: new DropdownButtonHideUnderline(
            child: new DropdownButton(
              hint: new Text("Select Role of Person"),
              value: _roleType,
              isDense: true,
              onChanged: (newValue) {
                setState(() {
                  _roleType = newValue;
                  state.didChange(newValue);
                });
              },
              items: roleTypes.map((type) {
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
        _roleType = value;
        // setState(() {
        //   _msg = null;
        // });
        // entity.childCollection
        //    .add(new ChildEntityAppData.cType(value, entity.id));
        //   saveEntityDetails(entity);
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
                //Save form details, then go back.
                // saveFormDetails();
                // updateModel();
                //go back
                Navigator.of(context).pop();
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
              autovalidate: true,
              child: ListView(
                padding: const EdgeInsets.all(5.0),
                // crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
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
                                  // entityType,
                                  regNumField,
                                  opensTimeField,
                                  closeTimeField,
                                  breakSartTimeField,
                                  breakEndTimeField,
                                  daysClosedField,
                                  maxpeopleInASlot,
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
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: <Widget>[
                              // RaisedButton(
                              //   elevation: 20,
                              //   color: btnColor,
                              //   splashColor: highlightColor,
                              //   textColor: Colors.white,
                              //   shape: RoundedRectangleBorder(
                              //       side: BorderSide(color: btnColor)),
                              //   child: Text('Use current location'),
                              //   onPressed: _getCurrLocation,
                              // ),
                              Text("Address:"),

                              adrsField1,

                              Padding(
                                padding:
                                    const EdgeInsets.fromLTRB(0, 0, 0, 8.0),
                                child: TextFormField(
                                  obscureText: false,
                                  maxLines: 1,
                                  minLines: 1,
                                  style: textInputTextStyle,
                                  // controller: _nameController,
                                  //initialValue: serviceEntity.name,
                                  keyboardType: TextInputType.text,
                                  decoration: CommonStyle.textFieldStyle(
                                      labelTextStr: "Add Landmark",
                                      hintTextStr: "e.g. Near Block1 etc"),
                                  validator: validateText,
                                  onChanged: (String value) {
                                    serviceEntity.name = value;
                                  },
                                  onSaved: (String value) {
                                    serviceEntity.name = value;
                                  },
                                ),
                              ),
                              //landmarkField2,
                              // localityField,
                              //cityField,
                              //stateField,
                              //pinField,
                              //countryField,
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
                                        "Contact Person",
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
                                        child: Text(contactInfoStr,
                                            style: buttonXSmlTextStyle),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.fromLTRB(8.0, 0, 8, 0),
                              child: Row(
                                // mainAxisAlignment: MainAxisAlignment.end,
                                children: <Widget>[
                                  Expanded(
                                    child: roleType,
                                  ),
                                  Container(
                                    child: IconButton(
                                      icon: Icon(Icons.add_circle,
                                          color: highlightColor, size: 40),
                                      onPressed: () {
                                        if (_roleType != null) {
                                          setState(() {
                                            _msg = null;
                                          });

                                          _addNewContactRow();
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
                            (_msg != null)
                                ? Text(
                                    _msg,
                                    style: errorTextStyle,
                                  )
                                : Container(),
                          ],
                        ),
                      ],
                    ),
                  ),
                  if (!Utils.isNullOrEmpty(contactList))
                    Column(children: contactRowWidgets),

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
                              Text(
                                'Save this service',
                                style: buttonXSmlTextStyle,
                              ),
                            ],
                          ),
                        ),
                        onPressed: () {
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
                            progressIndicatorBackgroundColor:
                                Colors.blueGrey[800],
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
                                    flush.dismiss(false); // result = true
                                  },
                                  child: Text(
                                    "No",
                                    style: TextStyle(color: highlightColor),
                                  ),
                                ),
                              ],
                            ),
                          )..show(context).then((result) {
                              _wasButtonClicked = result;
                              if (_wasButtonClicked) processGoBackWithTimer();
                            });
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
                                                              EntityServicesListPage(
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
