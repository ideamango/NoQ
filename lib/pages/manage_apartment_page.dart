import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:noq/constants.dart';
import 'package:noq/db/db_model/address.dart';
import 'package:noq/db/db_model/employee.dart';
import 'package:noq/db/db_model/entity.dart';
import 'package:noq/db/db_model/meta_entity.dart';
import 'package:noq/db/db_service/entity_service.dart';

import 'package:noq/pages/contact_item.dart';
import 'package:noq/pages/entity_services_list_page.dart';
import 'package:noq/pages/manage_apartment_list_page.dart';
import 'package:noq/repository/StoreRepository.dart';
import 'package:noq/services/circular_progress.dart';

import 'package:noq/style.dart';
import 'package:noq/utils.dart';
import 'package:noq/widget/bottom_nav_bar.dart';
import 'package:noq/widget/custom_expansion_tile.dart';
import 'package:noq/widget/weekday_selector.dart';

import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:flushbar/flushbar.dart';

class ManageApartmentPage extends StatefulWidget {
  final Entity entity;
  ManageApartmentPage({Key key, @required this.entity}) : super(key: key);
  @override
  _ManageApartmentPageState createState() => _ManageApartmentPageState();
}

class _ManageApartmentPageState extends State<ManageApartmentPage> {
  final GlobalKey<FormState> _entityDetailsFormKey = new GlobalKey<FormState>();
  final String title = "Managers Form";
  final Geolocator geolocator = Geolocator()..forceAndroidLocationManager;

//Basic Details
  TextEditingController _nameController = TextEditingController();
  TextEditingController _descController = TextEditingController();
  TextEditingController _regNumController = TextEditingController();
  TextEditingController _closeTimeController = TextEditingController();
  TextEditingController _openTimeController = TextEditingController();
  TextEditingController _breakStartController = TextEditingController();
  TextEditingController _breakEndController = TextEditingController();

  TextEditingController _maxPeopleController = TextEditingController();
  TextEditingController _whatsappPhoneController = TextEditingController();

  TextEditingController _slotDurationController = TextEditingController();

  List<String> _closedOnDays = List<String>();
  List<String> _daysOff = List<String>();

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

  Employee cp1 = new Employee();
  Address adrs = new Address();
  MetaEntity _metaEntity;
  Entity entity;

  List<Employee> contactList = new List<Employee>();
  List<Widget> contactRowWidgets = new List<Widget>();
  int _contactCount = 0;

  //bool _autoPopulate = false;

  String _currentCity;
  String _postalCode;
  String _country;
  String _subArea;
  String _state;
  String _mainArea;

//  String _entityType;
  String state;

  bool addNewClicked = false;
  String _roleType;

  bool getEntityDone = false;
  bool _initCompleted = false;

  @override
  void initState() {
    super.initState();
    _getCurrLocation();
    entity = this.widget.entity;
    initializeEntity().whenComplete(() {
      _initCompleted = true;
    });
  }

  initializeEntity() async {
    if (entity != null) {
      _nameController.text = entity.name;
      // _entityType = entity.eType;
      // _regNumController.text = entity.regNum;
      if (entity.startTimeHour != null && entity.startTimeMinute != null)
        _openTimeController.text = entity.startTimeHour.toString() +
            ':' +
            entity.startTimeMinute.toString();
      if (entity.endTimeHour != null && entity.endTimeMinute != null)
        _closeTimeController.text = entity.endTimeHour.toString() +
            ':' +
            entity.endTimeMinute.toString();
      if (entity.breakStartHour != null && entity.breakStartMinute != null)
        _breakStartController.text = entity.breakStartHour.toString() +
            ':' +
            entity.breakStartMinute.toString();
      if (entity.breakEndHour != null && entity.breakEndMinute != null)
        _breakEndController.text = entity.breakEndHour.toString() +
            ':' +
            entity.breakEndMinute.toString();
      if (entity.closedOn != null) _daysOff = entity.closedOn;
      if (entity.maxAllowed != null)
        _maxPeopleController.text =
            (entity.maxAllowed != null) ? entity.maxAllowed.toString() : "";
      //address
      if (entity.address != null) {
        _adrs1Controller.text = entity.address.address;
        _localityController.text = entity.address.locality;
        _landController.text = entity.address.landmark;
        _cityController.text = entity.address.city;
        _stateController.text = entity.address.state;
        _countryController.text = entity.address.country;
        _pinController.text = entity.address.zipcode;
      }
//contact person
      if (!(Utils.isNullOrEmpty(entity.managers))) {
        contactList = entity.managers;
      }
    }
    //  else {
    //   entity = createEntity(_metaEntity.entityId, _metaEntity.type);
    //   print(entity.entityId.toString());
    //   //TODO: Smita - check if we insert object at SAVE.
    //   //  EntityService().upsertEntity(entity);
    // }

    entity.address = (entity.address) ?? new Address();
    contactList = contactList ?? new List<Employee>();

    //  _ctNameController.text = entity.contactPersons[0].perName;
  }

  String validateText(String value) {
    if (value == null) {
      return 'Field is empty';
    } else
      return null;
  }

  String validateTime(String value) {
    if (value == null) {
      return 'Field is empty';
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
      print('get Address From LantLong');
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

  getEntityDetails() {
    // if (entity == null) {
    //   //if new entity then generate guid and assign.
    //   entity = new Entity();
    //   var uuid = new Uuid();
    //   entity.entityId = uuid.v1();
    // } else
    //   //if already existing entity load details from server
    //   getEntity(entity.entityId).then((en) => entity = en);
  }

  void _addNewContactRow() {
    setState(() {
      Employee contact = new Employee();

      contactRowWidgets.insert(0, new ContactRow(contact: contact));

      contactList.add(contact);
      if (Utils.isNullOrEmpty(entity.managers)) {
        entity.managers = new List<Employee>();
      }
      entity.managers = contactList;
      // saveEntityDetails(en);
      //saveEntityDetails();
      _contactCount = _contactCount + 1;
    });
  }

  Widget _buildContactItem(Employee contact) {
    return new ContactRow(contact: contact);
  }

  @override
  Widget build(BuildContext context) {
    if (_initCompleted) {
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
        onChanged: (String value) {
          entity.name = value;
        },
        onSaved: (String value) {
          entity.name = value;
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
          entity.description = value;
        },
        onSaved: (String value) {
          entity.description = value;
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
          //TODO: test if regNum is getting saved
          //entity.regNum = value;
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
              entity.startTimeHour = int.parse(time[0]);

              entity.startTimeMinute = int.parse(time[1]);
            }
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

            //       String time = DateFormat.Hm().format(date);
            //       print(time);

            //       _openTimeController.text = time.toLowerCase();
            //     }, currentTime: DateTime.now());
            //   },
            // ),
            labelText: "Opening time",
            hintText: "hh:mm 24 hour time format",
            enabledBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: Colors.grey)),
            focusedBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: Colors.orange))),
        validator: validateTime,
        onChanged: (String value) {
          //TODO: test the values
          if (value != "") {
            List<String> time = value.split(':');
            entity.startTimeHour = int.parse(time[0]);

            entity.startTimeMinute = int.parse(time[1]);
          }
        },
        onSaved: (String value) {},
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
              entity.endTimeHour = int.parse(time[0]);

              entity.endTimeMinute = int.parse(time[1]);
            }
          }, currentTime: DateTime.now());
        },
        decoration: InputDecoration(
            labelText: "Closing time",
            hintText: "hh:mm 24 hour time format",
            enabledBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: Colors.grey)),
            focusedBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: Colors.orange))),
        validator: validateTime,
        onChanged: (String value) {
          //TODO: test the values
          if (value != "") {
            List<String> time = value.split(':');
            entity.endTimeHour = int.parse(time[0]);

            entity.endTimeMinute = int.parse(time[1]);
          }
        },
        onSaved: (String value) {
          //TODO: test the values
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

            String time = DateFormat.Hm().format(date);
            print(time);

            _breakStartController.text = time.toLowerCase();
            if (_breakStartController.text != "") {
              List<String> time = _breakStartController.text.split(':');
              entity.breakStartHour = int.parse(time[0]);

              entity.breakStartMinute = int.parse(time[1]);
            }
          }, currentTime: DateTime.now());
        },
        controller: _breakStartController,
        keyboardType: TextInputType.text,
        decoration: InputDecoration(
            labelText: "Break starts at",
            hintText: "hh:mm 24 hour time format",
            enabledBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: Colors.grey)),
            focusedBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: Colors.orange))),
        validator: validateTime,
        onChanged: (value) {
          if (value != "") {
            List<String> time = value.split(':');
            entity.breakStartHour = int.parse(time[0]);
            entity.breakStartMinute = int.parse(time[1]);
          }
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
              entity.breakEndHour = int.parse(time[0]);
              entity.breakEndMinute = int.parse(time[1]);
            }
          }, currentTime: DateTime.now());
        },
        decoration: InputDecoration(
            labelText: "Break ends at",
            hintText: "hh:mm 24 hour time format",
            enabledBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: Colors.grey)),
            focusedBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: Colors.orange))),
        validator: validateTime,
        onChanged: (value) {
          if (value != "") {
            List<String> time = value.split(':');
            entity.breakEndHour = int.parse(time[0]);
            entity.breakEndMinute = int.parse(time[1]);
          }
        },
        onSaved: (String value) {},
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
                entity.closedOn = _closedOnDays;
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
          focusedBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.orange)),
        ),
        validator: validateText,
        onChanged: (value) {
          if (value != "") entity.slotDuration = int.parse(value);
          print("slot duration saved");
        },
        onSaved: (String value) {
          if (value != "") entity.slotDuration = int.parse(value);
          print("slot duration saved");
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
          focusedBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.orange)),
        ),
        validator: validateText,
        onChanged: (value) {
          if (value != "") entity.maxAllowed = int.parse(value);
          print("saved max people");
        },
        onSaved: (String value) {
          if (value != "") entity.maxAllowed = int.parse(value);
          print("saved max people");
        },
      );
      final whatsappPhone = TextFormField(
        obscureText: false,
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
          focusedBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.orange)),
        ),
        validator: Utils.validateMobile,
        onChanged: (value) {
          if (value != "") entity.whatsapp = "+91" + (value);
          print("Whatsapp Number");
        },
        onSaved: (String value) {
          if (value != "") entity.whatsapp = "+91" + (value);
          print("Whatsapp Number");
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
          entity.address.address = value;
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
          focusedBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.orange)),
        ),
        validator: validateText,
        onSaved: (String value) {
          entity.address.landmark = value;
          print("saved address");
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
          focusedBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.orange)),
        ),
        validator: validateText,
        onSaved: (String value) {
          entity.address.locality = value;
          print("saved address");
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
          focusedBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.orange)),
        ),
        validator: validateText,
        onSaved: (String value) {
          entity.address.city = value;
          print("saved address");
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
          focusedBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.orange)),
        ),
        validator: validateText,
        onSaved: (String value) {
          entity.address.state = value;
          print("saved address");
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
          focusedBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.orange)),
        ),
        validator: validateText,
        onSaved: (String value) {
          entity.address.country = value;
          print("saved address");
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
          focusedBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.orange)),
        ),
        validator: validateText,
        onChanged: (String value) {
          entity.address.zipcode = value;
          print("saved address");
        },
        onSaved: (String value) {
          entity.address.zipcode = value;
          print("saved address");
        },
      );
      TextEditingController _txtController = new TextEditingController();
      bool _delEnabled = false;
      Flushbar flush;
      bool _wasButtonClicked;

      void saveFormDetails() {
        print("saving ");

        if (_entityDetailsFormKey.currentState.validate()) {
          print("Saved formmmmmmm");
        }
        _entityDetailsFormKey.currentState.save();
        // String address = entity.adrs.addressLine1 ??
        //     entity.adrs.addressLine1 +
        //         entity.adrs.locality +
        //         entity.adrs.city +
        //         entity.adrs.state +
        //         entity.adrs.country;
        // List<Placemark> placemark =
        //     await Geolocator().placemarkFromAddress(address);

        // print(placemark);
        // entity.lat = placemark[0].position.latitude;
        // entity.long = placemark[0].position.longitude;
      }

      saveRoute() {
        saveFormDetails();
        upsertEntity(entity, _regNumController.text).then((value) {
          if (value) {
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) =>
                        ChildEntitiesListPage(entity: this.entity)));
          }
        });
      }

      backRoute() {
        // saveFormDetails();
        // upsertEntity(entity).then((value) {
        //   if (value) {
        Navigator.pop(context);
        //                }
        // });
      }

      processSaveWithTimer() async {
        var duration = new Duration(seconds: 2);
        return new Timer(duration, saveRoute);
      }

      processGoBackWithTimer() async {
        var duration = new Duration(seconds: 1);
        return new Timer(duration, backRoute);
      }

      String _msg;

      final roleType = new FormField(
        builder: (FormFieldState state) {
          return InputDecorator(
            decoration: InputDecoration(
              labelText: 'Role Type',
              focusedBorder: InputBorder.none,
              enabledBorder: InputBorder.none,
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
        // title: 'Add child entities',
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

                //go back
                //Navigator.of(context).pop();
                print("gone");
              },
            ),
            title: Text(entity.type, style: whiteBoldTextStyle1),
          ),
          body: Center(
            child: new SafeArea(
              top: true,
              bottom: true,
              child: new Form(
                key: _entityDetailsFormKey,
                autovalidate: true,
                child: new ListView(
                  padding: const EdgeInsets.all(5.0),
                  children: <Widget>[
                    Container(
                      decoration: BoxDecoration(
                          border: Border.all(color: containerColor),
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
                                              color: Colors.white,
                                              fontSize: 15),
                                        ),
                                        SizedBox(width: 5),
                                      ],
                                    ),
                                    backgroundColor: Colors.blueGrey[500],

                                    children: <Widget>[
                                      new Container(
                                        width:
                                            MediaQuery.of(context).size.width *
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
                                    regNumField,
                                    opensTimeField,
                                    closeTimeField,
                                    breakSartTimeField,
                                    breakEndTimeField,
                                    daysClosedField,
                                    slotDuration,
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
                                              color: Colors.white,
                                              fontSize: 15),
                                        ),
                                        SizedBox(width: 5),
                                      ],
                                    ),
                                    backgroundColor: Colors.blueGrey[500],

                                    children: <Widget>[
                                      new Container(
                                        width:
                                            MediaQuery.of(context).size.width *
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
                                  shape: RoundedRectangleBorder(
                                      side: BorderSide(color: btnColor)),
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
                                          "Person",
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
                                        width:
                                            MediaQuery.of(context).size.width *
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
                                padding:
                                    const EdgeInsets.fromLTRB(8.0, 0, 8, 0),
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
                                  'Details of amenities/services',
                                  style: buttonXSmlTextStyle,
                                ),
                              ],
                            ),
                          ),
                          onPressed: () {
                            // final snackBar = SnackBar(
                            //   elevation: 20,
                            //   // behavior: SnackBarBehavior.floating,
                            //   // shape: Border.all(
                            //   //   color: lightIcon,
                            //   //   width: 2,
                            //   // ),
                            //   //  backgroundColor: Colors.white,
                            //   content: Container(
                            //     padding: EdgeInsets.all(0),
                            //     // decoration: BoxDecoration(
                            //     //   border: Border.all(color: Colors.indigo),
                            //     // color: Colors.white,
                            //     // shape: BoxShape.rectangle,
                            //     // borderRadius:
                            //     //     BorderRadius.all(Radius.circular(5.0))),
                            //     alignment: Alignment.center,
                            //     height: MediaQuery.of(context).size.width * .1,
                            //     child: Text("Saving details..",
                            //         style: TextStyle(color: Colors.white)),
                            //     // Column(
                            //     //   children: <Widget>[
                            //     //     RichText(
                            //     //       text: TextSpan(
                            //     //           style: highlightBoldTextStyle,
                            //     //           children: <TextSpan>[
                            //     //             TextSpan(
                            //     //               text: "Saving details ... ",
                            //     //             ),
                            //     //           ]),
                            //     //     ),
                            //     //   ],
                            //     // ),
                            //   ),
                            //   duration: Duration(seconds: 2),
                            // );

                            // Scaffold.of(context).showSnackBar(snackBar);
                            // processSaveWithTimer();

                            Flushbar(
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
                              // backgroundGradient: new LinearGradient(
                              //     colors: [
                              //       Colors.blueGrey,
                              //       Colors.black,
                              //     ],
                              //     begin: const FractionalOffset(0.0, 0.0),
                              //     end: const FractionalOffset(1.0, 0.0),
                              //     stops: [0.0, 1.0],
                              //     tileMode: TileMode.repeated),
                              isDismissible: false,
                              duration: Duration(seconds: 4),
                              icon: Icon(
                                Icons.save,
                                color: Colors.blueGrey[50],
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
                                " Loading the services offered!!",
                                style: TextStyle(
                                    fontSize: 12.0,
                                    color: Colors.blueGrey[50],
                                    fontFamily: "ShadowsIntoLightTwo"),
                              ),
                            )..show(context);
                            processSaveWithTimer();
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
                                    'Delete this entity and all its amenities/services',
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
                                                              borderSide: BorderSide(
                                                                  color: Colors
                                                                      .grey)),
                                                      focusedBorder:
                                                          UnderlineInputBorder(
                                                              borderSide: BorderSide(
                                                                  color: Colors
                                                                      .orange)),
                                                    ),
                                                    onEditingComplete: () {
                                                      print(
                                                          _txtController.text);
                                                    },
                                                    onChanged: (value) {
                                                      if (value.toUpperCase() ==
                                                          "DELETE"
                                                              .toUpperCase())
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
                                                deleteEntity(entity.entityId)
                                                    .whenComplete(() {
                                                  Navigator.pop(context);
                                                  Navigator.push(
                                                      context,
                                                      MaterialPageRoute(
                                                          builder: (context) =>
                                                              ManageApartmentsListPage()));
                                                });
                                              } else {
                                                setState(() {
                                                  _errorMessage =
                                                      "You have to enter DELETE to proceed.";
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
                            })),
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
                    //         // Scaffold.of(context).showSnackBar(snackBar1);
                    //       }),),
                  ],
                ),
              ),
            ),
          ),
          bottomNavigationBar: CustomBottomBar(barIndex: 0),
        ),
      );
    } else
      return MaterialApp(
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
                // Flushbar(
                //   //padding: EdgeInsets.zero,
                //   margin: EdgeInsets.zero,
                //   flushbarPosition: FlushbarPosition.TOP,
                //   flushbarStyle: FlushbarStyle.FLOATING,
                //   reverseAnimationCurve: Curves.decelerate,
                //   forwardAnimationCurve: Curves.easeInToLinear,
                //   backgroundColor: headerBarColor,
                //   boxShadows: [
                //     BoxShadow(
                //         color: primaryAccentColor,
                //         offset: Offset(0.0, 2.0),
                //         blurRadius: 3.0)
                //   ],
                //   isDismissible: false,
                //   duration: Duration(seconds: 4),
                //   icon: Icon(
                //     Icons.save,
                //     color: Colors.blueGrey[50],
                //   ),
                //   showProgressIndicator: true,
                //   progressIndicatorBackgroundColor: Colors.blueGrey[800],
                //   routeBlur: 10.0,
                //   titleText: Text(
                //     "Go Back to Home",
                //     style: TextStyle(
                //         fontWeight: FontWeight.bold,
                //         fontSize: 16.0,
                //         color: primaryAccentColor,
                //         fontFamily: "ShadowsIntoLightTwo"),
                //   ),
                //   messageText: Text(
                //     "The changes you made will not be saved. To Save now, click Cancel.",
                //     style: TextStyle(
                //         fontSize: 12.0,
                //         color: Colors.blueGrey[50],
                //         fontFamily: "ShadowsIntoLightTwo"),
                //   ),
                // )..show(context);

                //go back
                Navigator.of(context).pop();
              },
            ),
            title: Text(entity.type, style: whiteBoldTextStyle1),
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
