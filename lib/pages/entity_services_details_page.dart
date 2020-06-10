import 'package:flutter/material.dart';
import 'package:noq/models/localDB.dart';
import 'dart:async';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:noq/constants.dart';
import 'package:noq/repository/local_db_repository.dart';
import 'package:noq/style.dart';
import 'package:noq/utils.dart';
import 'package:noq/widget/weekday_selector.dart';
import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

class ServiceEntityDetailsPage extends StatefulWidget {
  final ChildEntityAppData serviceEntity;
  ServiceEntityDetailsPage({Key key, @required this.serviceEntity})
      : super(key: key);
  @override
  _ServiceEntityDetailsPageState createState() =>
      _ServiceEntityDetailsPageState();
}

class _ServiceEntityDetailsPageState extends State<ServiceEntityDetailsPage> {
  final GlobalKey<FormState> _form2Key = new GlobalKey<FormState>();
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
  ContactAppData cp1 = new ContactAppData();
  AddressAppData adrs = new AddressAppData();
  ChildEntityAppData serviceEntity;

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

  SharedPreferences _prefs;
  UserAppData _userProfile;

  @override
  void initState() {
    super.initState();
    serviceEntity = widget.serviceEntity;
    var uuid = new Uuid();
    serviceEntity.id = uuid.v1();
    _getCurrLocation();
    initializeEntity();

    //load the service details
    //loadServiceEntity(serviceEntity.id);

    serviceEntity.contactPersons = new List<ContactAppData>();
    serviceEntity.adrs = new AddressAppData();
    serviceEntity.contactPersons.add(cp1);
    // addPerson();
  }

  initializeEntity() {
    _nameController.text = serviceEntity.name;
    _regNumController.text = serviceEntity.regNum;
    _openTimeController.text = serviceEntity.opensAt;
    _closeTimeController.text = serviceEntity.closesAt;
    _breakStartController.text = serviceEntity.breakTimeFrom;
    _breakEndController.text = serviceEntity.breakTimeTo;
    if (serviceEntity.daysClosed != null) _daysOff = serviceEntity.daysClosed;
    _maxPeopleController.text = serviceEntity.maxPeopleAllowed;
    //address

    _adrs1Controller.text = serviceEntity.adrs.addressLine1;
    _localityController.text = serviceEntity.adrs.locality;
    _landController.text = serviceEntity.adrs.landmark;
    _cityController.text = serviceEntity.adrs.city;
    _stateController.text = serviceEntity.adrs.state;
    _countryController.text = serviceEntity.adrs.country;
    _pinController.text = serviceEntity.adrs.postalCode;
//contact person
    //  _ctNameController.text = serviceEntity.contactPersons[0].perName;
  }

  loadServiceEntity(String serviceEntityId) {
    // serviceEntity = getEntity(serviceEntityId);
  }

  Future<void> getPrefInstance() async {
    _prefs = await SharedPreferences.getInstance();
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

  saveDetails() async {
    List<Placemark> placemark = await Geolocator().placemarkFromAddress(
        "My Home Vihanga, Financial District, Gachibowli, Hyderabad, Telangana, India");

    print(placemark);
    //saveEntityDetails(childEntity);
  }

  @override
  Widget build(BuildContext context) {
    final BoxDecoration indigoContainer = new BoxDecoration(
        border: Border.all(color: Colors.indigo),
        shape: BoxShape.rectangle,
        color: Colors.indigo,
        borderRadius: BorderRadius.all(Radius.circular(5.0)));
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
      onSaved: (String value) {
        serviceEntity.regNum = value;
      },
    );

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
          labelText: "Opening time",
          hintText: "HH:MM am/pm",
          enabledBorder:
              UnderlineInputBorder(borderSide: BorderSide(color: Colors.grey)),
          focusedBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.orange))),
      validator: validateTime,
      onSaved: (String value) {
        serviceEntity.opensAt = value;
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
        serviceEntity.closesAt = value;
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
        // entity.opensAt = value;
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
        serviceEntity.closesAt = value;
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
              serviceEntity.daysClosed = _closedOnDays;
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
        // entity. = value;
      },
    );
//Address fields
    final adrsField1 = RichText(
      text: TextSpan(
        // style: textInputTextStyle,
        children: <TextSpan>[
          TextSpan(text: serviceEntity.adrs.addressLine1),
          TextSpan(text: serviceEntity.adrs.landmark),
          TextSpan(text: serviceEntity.adrs.locality),
          TextSpan(text: serviceEntity.adrs.city),
          TextSpan(text: serviceEntity.adrs.postalCode),
          TextSpan(text: serviceEntity.adrs.state),
          TextSpan(text: serviceEntity.adrs.country),
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
        serviceEntity.adrs.landmark = value;
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
        serviceEntity.adrs.locality = value;
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
        serviceEntity.adrs.city = value;
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
        serviceEntity.adrs.state = value;
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
        serviceEntity.adrs.country = value;
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
        serviceEntity.adrs.postalCode = value;
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

    void saveFormDetails() {
      print("saving ");
      if (_form2Key.currentState.validate()) {
        _form2Key.currentState.save();
      }
      saveChildEntity(serviceEntity);
    }

    void updateModel() {
//Read local file and update the entities.
      print("saving locally");
    }

    return MaterialApp(
      title: 'Add child entities',
      //theme: ThemeData.light().copyWith(),
      home: Scaffold(
        // appBar: AppBar(
        //     title: Row(
        //       children: <Widget>[
        //         Text(
        //           serviceEntity.cType,
        //         ),
        //       ],
        //     ),
        //     backgroundColor: Colors.teal,
        //     //Theme.of(context).primaryColor,
        //     actions: <Widget>[]),
        body: SafeArea(
          child: new Form(
            key: _form2Key,
            autovalidate: true,
            child: ListView(
              // crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Row(
                  children: <Widget>[
                    IconButton(
                      icon:
                          Icon(Icons.arrow_back, color: Colors.teal, size: 40),
                      onPressed: () {
                        print("going back");
                        //Save form details, then go back.
                        saveFormDetails();
                        updateModel();
                        //go back
                        Navigator.of(context).pop();
                      },
                    ),
                  ],
                ),
                Container(
                  decoration: BoxDecoration(
                      border: Border.all(color: Colors.indigo),
                      color: Colors.grey[50],
                      shape: BoxShape.rectangle,
                      borderRadius: BorderRadius.all(Radius.circular(5.0))),
                  padding: EdgeInsets.all(5.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Column(
                        children: <Widget>[
                          Container(
                            decoration: indigoContainer,
                            child: Theme(
                              data: ThemeData(
                                unselectedWidgetColor: Colors.white,
                                accentColor: Colors.grey[50],
                              ),
                              child: ExpansionTile(
                                //   key: PageStorageKey(this.widget.headerTitle),
                                initiallyExpanded: false,
                                title: Row(
                                  children: <Widget>[
                                    Text(
                                      "Basic Details",
                                      style: TextStyle(
                                          color: Colors.white, fontSize: 15),
                                    ),
                                    SizedBox(width: 5),
                                    Icon(
                                      Icons.info,
                                      color: Colors.white,
                                    ),
                                  ],
                                ),
                                backgroundColor: Colors.indigo,
                                children: <Widget>[
                                  new Container(
                                    width:
                                        MediaQuery.of(context).size.width * .94,
                                    decoration: BoxDecoration(
                                        border:
                                            Border.all(color: Colors.indigo),
                                        color: Colors.grey[50],
                                        shape: BoxShape.rectangle,
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(5.0))),
                                    padding: EdgeInsets.all(2.0),
                                    child: Expanded(
                                      child: Text(
                                          'These are important details of the establishment, Same will be shown to customer while search.',
                                          style: lightSubTextStyle),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
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
                  padding: EdgeInsets.all(5.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Column(
                        children: <Widget>[
                          Container(
                            decoration: indigoContainer,
                            child: Theme(
                              data: ThemeData(
                                unselectedWidgetColor: Colors.white,
                                accentColor: Colors.grey[50],
                              ),
                              child: ExpansionTile(
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
                                    Icon(
                                      Icons.info,
                                      color: Colors.white,
                                    ),
                                  ],
                                ),
                                backgroundColor: Colors.indigo,

                                children: <Widget>[
                                  new Container(
                                    width:
                                        MediaQuery.of(context).size.width * .94,
                                    decoration: BoxDecoration(
                                        border:
                                            Border.all(color: Colors.indigo),
                                        color: Colors.grey[50],
                                        shape: BoxShape.rectangle,
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(5.0))),
                                    padding: EdgeInsets.all(2.0),
                                    child: Expanded(
                                      child: Text(
                                          'The address is using the current location, and same will be used by customers when searching your location.',
                                          style: lightSubTextStyle),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                      Column(
                        children: <Widget>[
                          RaisedButton(
                            elevation: 20,
                            color: highlightColor,
                            splashColor: Colors.orange,
                            textColor: Colors.white,
                            shape: RoundedRectangleBorder(
                                side: BorderSide(color: Colors.orange)),
                            child: Text('Use current location'),
                            onPressed: _getCurrLocation,
                          ),
                          Text("sdgfsfgdf"),
                          adrsField1,

                          Text("aaaaaaaa"),
                          //landmarkField2,
                          // localityField,
                          //cityField,
                          //stateField,
                          //pinField,
                          //countryField,
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
                  padding: EdgeInsets.all(5.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Column(
                        children: <Widget>[
                          Container(
                            decoration: indigoContainer,
                            child: Theme(
                              data: ThemeData(
                                unselectedWidgetColor: Colors.white,
                                accentColor: Colors.grey[50],
                              ),
                              child: ExpansionTile(
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
                                    Icon(
                                      Icons.info,
                                      color: Colors.white,
                                    ),
                                  ],
                                ),
                                backgroundColor: Colors.indigo,

                                children: <Widget>[
                                  new Container(
                                    width:
                                        MediaQuery.of(context).size.width * .94,
                                    decoration: BoxDecoration(
                                        border:
                                            Border.all(color: Colors.indigo),
                                        color: Colors.grey[50],
                                        shape: BoxShape.rectangle,
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(5.0))),
                                    padding: EdgeInsets.all(2.0),
                                    child: Expanded(
                                      child: Text(
                                          'The perosn who can be contacted for any queries regarding your services.',
                                          style: lightSubTextStyle),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                      Container(
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
                    ],
                  ),
                ),
                Container(
                  padding: EdgeInsets.all(8),
                  alignment: Alignment.center,
                  // decoration: BoxDecoration(
                  //     borderRadius: BorderRadius.all(Radius.circular(5.0))),
                  //height: MediaQuery.of(context).size.width * .2,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      RaisedButton(
                        color: highlightColor,
                        splashColor: Colors.orange,
                        onPressed: () {
                          // if (_formKey.currentState.validate()) {
                          _form2Key.currentState.save();
                          //  saveDetails();
                          // Navigator.push(
                          //     context,
                          //     MaterialPageRoute(
                          //         builder: (context) =>
                          //             ChildEntityDetailsPage(
                          //                 entity: this.entity)));
                          // }
                        },
                        child: Container(
                          width: MediaQuery.of(context).size.width * .8,
                          child: Column(
                            children: <Widget>[
                              Text(
                                'Add Amenities',
                                style: buttonMedTextStyle,
                              ),
                              Text(
                                'Details of amenities/services',
                                style: buttonXSmlTextStyle,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}