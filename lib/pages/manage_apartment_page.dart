import 'dart:io';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:noq/constants.dart';
import 'package:noq/models/localDB.dart';
import 'package:noq/pages/entity_services_list_page.dart';

import 'package:noq/repository/local_db_repository.dart';
import 'package:noq/services/authService.dart';
import 'package:noq/services/qr_code_generate.dart';
import 'package:noq/style.dart';
import 'package:noq/utils.dart';
import 'package:noq/widget/custome_expansion_tile.dart';
import 'package:noq/widget/weekday_selector.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:uuid/uuid.dart';

class ManageApartmentPage extends StatefulWidget {
  final EntityAppData entity;
  ManageApartmentPage({Key key, @required this.entity}) : super(key: key);
  @override
  _ManageApartmentPageState createState() => _ManageApartmentPageState();
}

class _ManageApartmentPageState extends State<ManageApartmentPage> {
  final GlobalKey<FormState> _formKey = new GlobalKey<FormState>();
  final String title = "Managers Form";
  final Geolocator geolocator = Geolocator()..forceAndroidLocationManager;

//Basic Details
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
  ContactAppData cp1 = new ContactAppData();
  AddressAppData adrs = new AddressAppData();
  EntityAppData entity;

  List<ContactAppData> newList = new List<ContactAppData>();

  bool _addPerson = false;

  bool _isPositionSet = false;
  //bool _autoPopulate = false;

  String _currentCity;
  String _postalCode;
  String _country;
  String _subArea;
  String _state;
  String _mainArea;

  String _role;
//  String _entityType;
  String state;

  bool addNewClicked = false;

  @override
  void initState() {
    super.initState();
    _getCurrLocation();
    entity = this.widget.entity;

    //  getEntityDetails();
    initializeEntity();
    entity.contactPersons = new List<ContactAppData>();
    entity.adrs = new AddressAppData();
    entity.contactPersons.add(cp1);
    // addPerson();
  }

  initializeEntity() {
    _nameController.text = entity.name;
    // _entityType = entity.eType;
    _regNumController.text = entity.regNum;
    _openTimeController.text = entity.opensAt;
    _closeTimeController.text = entity.closesAt;
    _breakStartController.text = entity.breakTimeFrom;
    _breakEndController.text = entity.breakTimeTo;
    if (entity.daysClosed != null) _daysOff = entity.daysClosed;
    _maxPeopleController.text = entity.maxPeopleAllowed;
    //address
    if (entity.adrs != null) {
      _adrs1Controller.text = entity.adrs.addressLine1;
      _localityController.text = entity.adrs.locality;
      _landController.text = entity.adrs.landmark;
      _cityController.text = entity.adrs.city;
      _stateController.text = entity.adrs.state;
      _countryController.text = entity.adrs.country;
      _pinController.text = entity.adrs.postalCode;
    }
//contact person
    //  _ctNameController.text = entity.contactPersons[0].perName;
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
    ContactAppData cp = new ContactAppData.values(
        'a', 'b', 'c', 'd', Role.Employee, 'f', 'g', []);
    // ContactPerson cp4 =
    //     new ContactPerson.values('a', 'b', 'c', 'd', 'e', 'f', 'g');
    // contactList.add(cp1);
    // contactList.add(cp2);
    print('list contakajsgdsdfklsjhdk');

    newList.add(cp);
    contactList = newList;
    return contactList;
  }

  getEntityDetails() {
    if (entity == null) {
      //if new entity then generate guid and assign.
      entity = new EntityAppData();
      var uuid = new Uuid();
      entity.id = uuid.v1();
    } else
      //if already existing entity load details from server
      getEntity(entity.id).then((en) => entity = en);
  }

  saveDetails() async {
    List<Placemark> placemark = await Geolocator().placemarkFromAddress(
        "My Home Vihanga, Financial District, Gachibowli, Hyderabad, Telangana, India");

    print(placemark);
    saveEntityDetails(entity);
  }

  deleteEntity() {
    deleteEntityFromDb(entity);
  }

  @override
  Widget build(BuildContext context) {
    //Basic details field
    final nameField = TextFormField(
      obscureText: false,
      maxLines: 1,
      minLines: 1,
      style: textInputTextStyle,
      controller: _nameController,
      keyboardType: TextInputType.text,
      decoration: CommonStyle.textFieldStyle(
          labelTextStr: "Name of Establishment", hintTextStr: ""),
      validator: validateText,
      onSaved: (String value) {
        entity.name = value;
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
      onSaved: (String value) {
        entity.regNum = value;
      },
    );
    // final entityType = new FormField(
    //   builder: (FormFieldState state) {
    //     return InputDecorator(
    //       decoration: InputDecoration(
    //         //  icon: const Icon(Icons.person),
    //         labelText: 'Type of Establishment',
    //       ),
    //       child: new DropdownButtonHideUnderline(
    //         child: new DropdownButton(
    //           value: _entityType,
    //           isDense: true,
    //           onChanged: (newValue) {
    //             setState(() {
    //               // newContact.favoriteColor = newValue;
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
    //     entity.eType = value;
    //   },
    // );

    final opensTimeField = TextFormField(
      obscureText: false,
      maxLines: 1,
      readOnly: true,
      minLines: 1,
      style: textInputTextStyle,
      onTap: () {
        DatePicker.showTime12hPicker(context, showTitleActions: true,
            onChanged: (date) {
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
          // suffixIcon: IconButton(
          //   icon: Icon(Icons.schedule),
          //   onPressed: () {
          //     DatePicker.showTime12hPicker(context, showTitleActions: true,
          //         onChanged: (date) {
          //       print('change $date in time zone ' +
          //           date.timeZoneOffset.inHours.toString());
          //     }, onConfirm: (date) {
          //       print('confirm $date');
          //       //  String time = "${date.hour}:${date.minute} ${date.";

          //       String time = DateFormat.jm().format(date);
          //       print(time);

          //       _openTimeController.text = time.toLowerCase();
          //     }, currentTime: DateTime.now());
          //   },
          // ),
          labelText: "Opening time",
          hintText: "HH:MM am/pm",
          enabledBorder:
              UnderlineInputBorder(borderSide: BorderSide(color: Colors.grey)),
          focusedBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.orange))),
      validator: validateTime,
      onSaved: (String value) {
        entity.opensAt = value;
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
        DatePicker.showTime12hPicker(context, showTitleActions: true,
            onChanged: (date) {
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
          hintText: "HH:MM am/pm",
          enabledBorder:
              UnderlineInputBorder(borderSide: BorderSide(color: Colors.grey)),
          focusedBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.orange))),
      validator: validateTime,
      onSaved: (String value) {
        entity.closesAt = value;
      },
    );
    final breakSartTimeField = TextFormField(
      obscureText: false,
      maxLines: 1,
      readOnly: true,
      minLines: 1,
      style: textInputTextStyle,
      onTap: () {
        DatePicker.showTime12hPicker(context, showTitleActions: true,
            onChanged: (date) {
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
          // suffixIcon: IconButton(
          //   icon: Icon(Icons.schedule),
          //   onPressed: () {
          //     DatePicker.showTime12hPicker(context, showTitleActions: true,
          //         onChanged: (date) {
          //       print('change $date in time zone ' +
          //           date.timeZoneOffset.inHours.toString());
          //     }, onConfirm: (date) {
          //       print('confirm $date');
          //       //  String time = "${date.hour}:${date.minute} ${date.";

          //       String time = DateFormat.jm().format(date);
          //       print(time);

          //       _openTimeController.text = time.toLowerCase();
          //     }, currentTime: DateTime.now());
          //   },
          // ),
          labelText: "Break start at",
          hintText: "HH:MM am/pm",
          enabledBorder:
              UnderlineInputBorder(borderSide: BorderSide(color: Colors.grey)),
          focusedBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.orange))),
      validator: validateTime,
      onSaved: (String value) {
        entity.opensAt = value;
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
        DatePicker.showTime12hPicker(context, showTitleActions: true,
            onChanged: (date) {
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
          hintText: "HH:MM am/pm",
          enabledBorder:
              UnderlineInputBorder(borderSide: BorderSide(color: Colors.grey)),
          focusedBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.orange))),
      validator: validateTime,
      onSaved: (String value) {
        entity.closesAt = value;
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
              entity.daysClosed = _closedOnDays;
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
      onSaved: (String value) {
        entity.maxPeopleAllowed = value;
      },
    );

//Address fields
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
      onSaved: (String value) {
        entity.adrs.addressLine1 = value;
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
      onSaved: (String value) {
        entity.adrs.landmark = value;
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
        entity.adrs.locality = value;
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
        entity.adrs.city = value;
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
        entity.adrs.state = value;
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
        entity.adrs.country = value;
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
        entity.adrs.postalCode = value;
      },
    );
    //Contact person
    final ctNameField = TextFormField(
      obscureText: false,
      maxLines: 1,
      minLines: 1,
      style: textInputTextStyle,
      keyboardType: TextInputType.text,
      controller: _ctNameController,
      decoration:
          CommonStyle.textFieldStyle(labelTextStr: "Name", hintTextStr: ""),
      validator: validateText,
      onSaved: (String value) {
        cp1.perName = value;
      },
    );
    final ctEmpIdField = TextFormField(
      obscureText: false,
      maxLines: 1,
      minLines: 1,
      style: textInputTextStyle,
      keyboardType: TextInputType.text,
      controller: _ctEmpIdController,
      decoration: CommonStyle.textFieldStyle(
          labelTextStr: "Person Id", hintTextStr: ""),
      validator: validateText,
      onSaved: (String value) {
        cp1.empId = value;
      },
    );
    final ctPhn1Field = TextFormField(
      obscureText: false,
      maxLines: 1,
      minLines: 1,
      style: textInputTextStyle,
      keyboardType: TextInputType.phone,
      controller: _ctPhn1controller,
      decoration: CommonStyle.textFieldStyle(
          prefixText: '+91', labelTextStr: "Primary Phone", hintTextStr: ""),
      validator: Utils.validateMobile,
      onSaved: (value) {
        value = "+91" + value;
        cp1.perPhone1 = value;
      },
    );
    final ctPhn2Field = TextFormField(
      obscureText: false,
      maxLines: 1,
      minLines: 1,
      style: textInputTextStyle,
      keyboardType: TextInputType.phone,
      controller: _ctPhn2controller,
      decoration: CommonStyle.textFieldStyle(
          prefixText: '+91', labelTextStr: "Alternate Phone", hintTextStr: ""),
      validator: Utils.validateMobile,
      onSaved: (value) {
        value = "+91" + value;
        cp1.perPhone2 = value;
      },
    );
    final ctAvlFromTimeField = TextFormField(
      obscureText: false,
      maxLines: 1,
      readOnly: true,
      minLines: 1,
      style: textInputTextStyle,
      controller: _ctAvlFromTimeController,
      keyboardType: TextInputType.text,
      onTap: () {
        DatePicker.showTime12hPicker(context, showTitleActions: true,
            onChanged: (date) {
          print('change $date in time zone ' +
              date.timeZoneOffset.inHours.toString());
        }, onConfirm: (date) {
          print('confirm $date');
          //  String time = "${date.hour}:${date.minute} ${date.";

          String time = DateFormat.jm().format(date);
          print(time);

          _ctAvlFromTimeController.text = time.toLowerCase();
        }, currentTime: DateTime.now());
      },
      decoration: InputDecoration(
          // suffixIcon: IconButton(
          //   icon: Icon(Icons.schedule),
          //   onPressed: () {
          //     DatePicker.showTime12hPicker(context, showTitleActions: true,
          //         onChanged: (date) {
          //       print('change $date in time zone ' +
          //           date.timeZoneOffset.inHours.toString());
          //     }, onConfirm: (date) {
          //       print('confirm $date');
          //       //  String time = "${date.hour}:${date.minute} ${date.";

          //       String time = DateFormat.jm().format(date);
          //       print(time);

          //       _openTimeController.text = time.toLowerCase();
          //     }, currentTime: DateTime.now());
          //   },
          // ),
          labelText: "Available from",
          hintText: "HH:MM am/pm",
          enabledBorder:
              UnderlineInputBorder(borderSide: BorderSide(color: Colors.grey)),
          focusedBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.orange))),
      validator: validateTime,
      onSaved: (String value) {
        cp1.avlFromTime = value;
      },
    );
    final ctAvlTillTimeField = TextFormField(
      enabled: true,
      obscureText: false,
      readOnly: true,
      maxLines: 1,
      minLines: 1,
      controller: _ctAvlTillTimeController,
      style: textInputTextStyle,
      onTap: () {
        DatePicker.showTime12hPicker(context, showTitleActions: true,
            onChanged: (date) {
          print('change $date in time zone ' +
              date.timeZoneOffset.inHours.toString());
        }, onConfirm: (date) {
          print('confirm $date');
          //  String time = "${date.hour}:${date.minute} ${date.";

          String time = DateFormat.jm().format(date);
          print(time);

          _ctAvlTillTimeController.text = time.toLowerCase();
        }, currentTime: DateTime.now());
      },
      decoration: InputDecoration(
          labelText: "Available till",
          hintText: "HH:MM am/pm",
          enabledBorder:
              UnderlineInputBorder(borderSide: BorderSide(color: Colors.grey)),
          focusedBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.orange))),
      validator: validateTime,
      onSaved: (String value) {
        cp1.avlTillTime = value;
      },
    );
    final daysOffField = Padding(
      padding: EdgeInsets.only(top: 12, bottom: 8),
      child: Row(
        children: <Widget>[
          Text(
            'Days off: ',
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
          SizedBox(width: 5),
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
              print("Days off: " + days.toString());
              _daysOff.clear();
              days.forEach((element) {
                var day = element.toString().substring(5);
                _daysOff.add(day);
              });
              cp1.daysOff = _daysOff;
              print(_daysOff.length);
              print(_daysOff.toString());
            },
          ),
        ],
      ),
    );
    TextEditingController _txtController = new TextEditingController();
    bool _delEnabled = false;
    saveRoute() {
      _formKey.currentState.save();
      saveDetails();
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) =>
                  EntityServicesListPage(entity: this.entity)));
    }

    processSaveWithTimer() async {
      var duration = new Duration(seconds: 1);
      return new Timer(duration, saveRoute);
    }

    return MaterialApp(
      // title: 'Add child entities',
      theme: ThemeData.light().copyWith(),
      home: Scaffold(
        appBar: AppBar(
            actions: <Widget>[],
            backgroundColor: Colors.teal,
            leading: IconButton(
                padding: EdgeInsets.all(0),
                alignment: Alignment.center,
                highlightColor: highlightColor,
                icon: Icon(Icons.arrow_back),
                color: Colors.white,
                onPressed: () => Navigator.of(context).pop()),
            title: Text(entity.eType)),
        body: Center(
          child: new SafeArea(
            top: true,
            bottom: true,
            child: new Form(
              key: _formKey,
              autovalidate: true,
              child: new ListView(
                padding: const EdgeInsets.all(5.0),
                children: <Widget>[
                  Container(
                    decoration: BoxDecoration(
                        border: Border.all(color: Colors.indigo),
                        color: Colors.grey[50],
                        shape: BoxShape.rectangle,
                        borderRadius: BorderRadius.all(Radius.circular(5.0))),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Column(
                          children: <Widget>[
                            Container(
                              //padding: EdgeInsets.only(left: 5),
                              decoration: indigoContainer,
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
                                      decoration: indigoContainer,
                                      padding: EdgeInsets.all(2.0),
                                      child: Expanded(
                                        child: Text(
                                            'The basic detail description.',
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
                                  //entityType,
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
                        border: Border.all(color: Colors.indigo),
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
                              decoration: indigoContainer,
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
                                      decoration: indigoContainer,
                                      padding: EdgeInsets.all(2.0),
                                      child: Expanded(
                                        child: Text(
                                            'The address is using the current location, and same will be used by customers when searching your location.',
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
                                color: lightIcon,
                                splashColor: highlightColor,
                                textColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                    side: BorderSide(color: lightIcon)),
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
                        border: Border.all(color: Colors.indigo),
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
                              decoration: indigoContainer,
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
                                      decoration: indigoContainer,
                                      padding: EdgeInsets.all(2.0),
                                      child: Expanded(
                                        child: Text(
                                            'The perosn who can be contacted for any queries regarding your services.',
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
                                ctNameField,
                                ctEmpIdField,
                                ctPhn1Field,
                                ctPhn2Field,
                                daysOffField,
                                Divider(
                                  thickness: .7,
                                  color: Colors.grey[600],
                                ),
                                ctAvlFromTimeField,
                                ctAvlTillTimeField,
                                new FormField(
                                  builder: (FormFieldState state) {
                                    return InputDecorator(
                                      decoration: InputDecoration(
                                        icon: const Icon(Icons.person),
                                        labelText: 'Role ',
                                      ),
                                      child: new DropdownButtonHideUnderline(
                                        child: new DropdownButton(
                                          value: _role,
                                          isDense: true,
                                          onChanged: (newValue) {
                                            setState(() {
                                              // newContact.favoriteColor = newValue;
                                              _role = newValue;
                                              state.didChange(newValue);
                                            });
                                          },
                                          items: roleTypes.map((role) {
                                            return DropdownMenuItem(
                                              value: role,
                                              child: new Text(
                                                role.toString(),
                                                style: textInputTextStyle,
                                              ),
                                            );
                                          }).toList(),
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ],
                            )),

                        // Column(children: <Widget>[
                        //   Center(
                        //     child: FloatingActionButton(
                        //       backgroundColor: highlightColor,
                        //       child: Icon(Icons.add, color: Colors.white),
                        //       splashColor: highlightColor,
                        //       onPressed: () {
                        //         // addPerson();
                        //       },
                        //     ),
                        //   ),
                        //   // _createChildren(),
                        //   // Expanded(
                        //   //     child: new ListView.builder(
                        //   //         itemCount: contactList.length,
                        //   //         itemBuilder: (BuildContext ctxt, int index) {
                        //   //           return new Text(contactList[index].perName);
                        //   //         })),
                        // ]),
                      ],
                    ),
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
                                'Delete this entity and all its amenities/services',
                                style: buttonXSmlTextStyle,
                              ),
                            ],
                          ),
                        ),
                        onPressed: () {
                          showDialog(
                              context: context,
                              barrierDismissible: true,
                              builder: (BuildContext context) {
                                return StatefulBuilder(
                                    builder: (context, setState) {
                                  return new AlertDialog(
                                    title: RichText(
                                      text: TextSpan(
                                          style: lightSubTextStyle,
                                          children: <TextSpan>[
                                            TextSpan(text: "Enter "),
                                            TextSpan(
                                                text: "DELETE ",
                                                style: errorTextStyle),
                                            TextSpan(
                                                text:
                                                    "to remove this entity from your managed ones."),
                                          ]),
                                    ),
                                    backgroundColor: Colors.grey[200],
                                    // titleTextStyle: inputTextStyle,
                                    elevation: 10.0,
                                    content: new Row(
                                      children: <Widget>[
                                        new Expanded(
                                          child: new TextField(
                                            style: inputTextStyle,
                                            controller: _txtController,
                                            onChanged: (value) {
                                              if (value == "DELETE")
                                                setState(() {
                                                  _delEnabled = true;
                                                });
                                            },
                                            autofocus: true,
                                            decoration: new InputDecoration(
                                                hintText: 'eg. DELETE'),
                                          ),
                                        )
                                      ],
                                    ),
                                    // content: Container(
                                    //   height: 50,
                                    //   child: Column(
                                    //     mainAxisSize: MainAxisSize.max,
                                    //     children: <Widget>[
                                    //       Container(
                                    //         //color: Colors.black,
                                    //         //margin: EdgeInsets.all(5),
                                    //         // padding: EdgeInsets.all(0),
                                    //         child: Row(
                                    //           children: <Widget>[
                                    //             TextField(
                                    //               controller: _txtController,
                                    //               onChanged: (value) {
                                    //                 if (value == "DELETE")
                                    //                   setState(() {
                                    //                     _delEnabled = true;
                                    //                   });
                                    //               },
                                    //             ),
                                    //             RaisedButton(
                                    //               color: (_delEnabled)
                                    //                   ? lightIcon
                                    //                   : Colors.blueGrey[400],
                                    //               disabledColor:
                                    //                   Colors.blueGrey[200],
                                    //               disabledElevation: 0,
                                    //               elevation: 15,
                                    //               onPressed: () {
                                    //                 deleteEntity();
                                    //               },
                                    //               splashColor: highlightColor,
                                    //               child: Text("Delete",
                                    //                   style: TextStyle(
                                    //                       color: Colors.white)),
                                    //             ),
                                    //           ],
                                    //         ),
                                    //       ),
                                    //       // SizedBox(height: 10),
                                    //       //Divider(),
                                    //     ],
                                    //   ),
                                    // ),

                                    contentPadding: EdgeInsets.all(10),
                                    actions: <Widget>[
                                      RaisedButton(
                                        color: (_delEnabled)
                                            ? lightIcon
                                            : Colors.blueGrey[400],
                                        elevation: (_delEnabled) ? 15 : 0,
                                        onPressed: () {
                                          deleteEntity();
                                          Navigator.pop(context);
                                        },
                                        splashColor: highlightColor,
                                        child: Text("Delete",
                                            style:
                                                TextStyle(color: Colors.white)),
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
                  Builder(
                    builder: (context) => RaisedButton(
                        color: lightIcon,
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
                                'Details of amenities/services',
                                style: buttonXSmlTextStyle,
                              ),
                            ],
                          ),
                        ),
                        onPressed: () {
                          final snackBar = SnackBar(
                            // shape: Border.all(
                            //   color: tealIcon,
                            //   width: 2,
                            // ),
                            backgroundColor:
                                Colors.blueGrey[500].withOpacity(.95),
                            content: Container(
                              alignment: Alignment.center,
                              height: MediaQuery.of(context).size.width * .25,
                              child: Text("Saving details ... ",
                                  style: buttonTextStyle),
                              // Column(
                              //   children: <Widget>[
                              //     RichText(
                              //       text: TextSpan(
                              //           style: highlightBoldTextStyle,
                              //           children: <TextSpan>[
                              //             TextSpan(
                              //               text: "Saving details ... ",
                              //             ),
                              //           ]),
                              //     ),
                              //   ],
                              // ),
                            ),
                            duration: Duration(seconds: 1),
                          );

                          Scaffold.of(context).showSnackBar(snackBar);
                          processSaveWithTimer();
                        }),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
