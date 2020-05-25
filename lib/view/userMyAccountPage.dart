import 'dart:io';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:noq/models/localDB.dart';
import 'package:noq/repository/local_db_repository.dart';
import 'package:noq/services/authService.dart';
import 'package:noq/services/qr_code_generate.dart';
import 'package:noq/style.dart';
import 'package:noq/utils.dart';
import 'package:noq/widget/weekday_selector.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';

class UserMyAccountPage extends StatefulWidget {
  @override
  _UserMyAccountPageState createState() => _UserMyAccountPageState();
}

class _UserMyAccountPageState extends State<UserMyAccountPage> {
  final GlobalKey<FormState> _formKey = new GlobalKey<FormState>();
  List<String> _colors = <String>['', 'red', 'green', 'blue', 'orange'];
  final String title = "Managers Form";
  final Geolocator geolocator = Geolocator()..forceAndroidLocationManager;

  // TextEditingController _subAreaController = TextEditingController();
  TextEditingController _adrs1Controller = TextEditingController();
  TextEditingController _landController = TextEditingController();
  TextEditingController _localityController = TextEditingController();
  TextEditingController _cityController = TextEditingController();
  TextEditingController _stateController = TextEditingController();
  TextEditingController _countryController = TextEditingController();
  TextEditingController _pinController = TextEditingController();
  // List<String> _addressList = new List<String>();

  TextEditingController _closeTimeController = TextEditingController();
  TextEditingController _openTimeController = TextEditingController();
  List<String> _closedOnDays = List<String>();

  //ContactPerson Fields
  TextEditingController _ctNameController = TextEditingController();
  TextEditingController _ctEmpIdController = TextEditingController();
  TextEditingController _ctPhn1controller = TextEditingController();
  TextEditingController _ctPhn2controller = TextEditingController();
  TextEditingController _ctRoleTypecontroller = TextEditingController();
  TextEditingController _ctAvlFromTimeController = TextEditingController();
  TextEditingController _ctAvlTillTimeController = TextEditingController();

  List<String> _daysOff = List<String>();
  ContactAppData cp1 = new ContactAppData();
  EntityAppData entity = new EntityAppData();

  List<ContactAppData> newList = new List<ContactAppData>();

  bool _addPerson = false;

  bool _isPositionSet = false;
  //bool _autoPopulate = false;
  bool _isEditPressed = false;
  // Address _address = new Address('', '', '', '', '');
  String _currentCity;
  String _postalCode;
  String _country;
  String _subArea;
  String _state;
  String _mainArea;

  String _color = '';
  String state;

  bool addNewClicked = false;

  @override
  void initState() {
    super.initState();
    _getCurrLocation();
    // addPerson();
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
        _isPositionSet = true;

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

  void _editLocation() {
    setState(() {
      _isEditPressed = true;
      // _autoPopulate = false;
    });
  }

  // void initializePersonList() {
  //   ContactPerson cp1 =
  //       new ContactPerson.values('a', 'b', 'c', 'd', 'e', 'f', 'g');
  //   // ContactPerson cp2 =
  //   //     new ContactPerson.values('a', 'b', 'c', 'd', 'e', 'f', 'g');

  //   newList.add(cp1);
  //   //newList.add(cp2);
  // }

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

  Widget _buildContactPerson(ContactAppData contactPerson) {
    return Container(
        width: MediaQuery.of(context).size.width * .94,
        decoration: BoxDecoration(
            border: Border.all(color: highlightColor),
            color: Colors.grey[50],
            shape: BoxShape.rectangle,
            borderRadius: BorderRadius.all(Radius.circular(5.0))),
        padding: EdgeInsets.all(5.0),
        child: Column(
          children: <Widget>[
            TextFormField(
              obscureText: false,
              maxLines: 1,
              minLines: 1,
              style: textInputTextStyle,
              keyboardType: TextInputType.text,
              //   controller: _ctNameController,
              decoration: InputDecoration(
                labelText: 'Name',
                enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey)),
                focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.orange)),
              ),
              // validator: (String value) {

              // },
              onSaved: (String value) {
                contactPerson.perName = value;
              },
            )
          ],
        ));
  }

  // Widget _buildAddress(String add) {
  //   print("Sumant");
  //   return Text(add);
  // }

  @override
  Widget build(BuildContext context) {
    final BoxDecoration indigoContainer = new BoxDecoration(
        border: Border.all(color: Colors.indigo),
        shape: BoxShape.rectangle,
        color: Colors.indigo,
        borderRadius: BorderRadius.all(Radius.circular(5.0)));
    //Basic details field
    final nameField = TextFormField(
      obscureText: false,
      maxLines: 1,
      minLines: 1,
      style: textInputTextStyle,
      keyboardType: TextInputType.text,
      decoration:
          CommonStyle.textFieldStyle(labelTextStr: "Name", hintTextStr: ""),
      validator: validateText,
    );
    final regNumField = TextFormField(
      obscureText: false,
      maxLines: 1,
      minLines: 1,
      style: textInputTextStyle,
      keyboardType: TextInputType.text,
      decoration: CommonStyle.textFieldStyle(
          labelTextStr: "Registration Number", hintTextStr: ""),
      validator: validateText,
    );
    final entityType = TextFormField(
      obscureText: false,
      maxLines: 1,
      minLines: 1,
      style: textInputTextStyle,
      keyboardType: TextInputType.text,
      decoration: CommonStyle.textFieldStyle(
          labelTextStr: "Type of Establishment", hintTextStr: ""),
      validator: validateText,
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
            textStyle: buttonMedTextStyle,
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
              print(_closedOnDays.length);
              print(_closedOnDays.toString());
            },
          ),
        ],
      ),
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

    final ctRoleType = TextFormField(
      obscureText: false,
      maxLines: 1,
      minLines: 1,
      style: textInputTextStyle,
      keyboardType: TextInputType.text,
      controller: _ctRoleTypecontroller,
      decoration: CommonStyle.textFieldStyle(
          labelTextStr: "Role Type", hintTextStr: ""),
      validator: validateText,
      onSaved: (String value) {
        // cp1.role = value;
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
            textStyle: buttonMedTextStyle,
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

    return new SafeArea(
      // top: true,
      // bottom: true,
      child: new Form(
        key: _formKey,
        autovalidate: true,
        child: new ListView(
          padding: const EdgeInsets.symmetric(horizontal: 5.0),
          children: <Widget>[
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
                                width: MediaQuery.of(context).size.width * .94,
                                decoration: BoxDecoration(
                                    border: Border.all(color: Colors.indigo),
                                    color: Colors.grey[50],
                                    shape: BoxShape.rectangle,
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(5.0))),
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
                      entityType,
                      regNumField,
                      opensTimeField,
                      closeTimeField,
                      daysClosedField,
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
                                width: MediaQuery.of(context).size.width * .94,
                                decoration: BoxDecoration(
                                    border: Border.all(color: Colors.indigo),
                                    color: Colors.grey[50],
                                    shape: BoxShape.rectangle,
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(5.0))),
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
                        color: Colors.teal,
                        splashColor: highlightColor,
                        textColor: Colors.white,
                        // shape: RoundedRectangleBorder(
                        //     side: BorderSide(color: Colors.orange)),
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
                                width: MediaQuery.of(context).size.width * .94,
                                decoration: BoxDecoration(
                                    border: Border.all(color: Colors.indigo),
                                    color: Colors.grey[50],
                                    shape: BoxShape.rectangle,
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(5.0))),
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
                      ctRoleType,
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
                              icon: const Icon(Icons.color_lens),
                              labelText: 'Color',
                            ),
                            isEmpty: _color == '',
                            child: new DropdownButtonHideUnderline(
                              child: new DropdownButton(
                                value: _color,
                                isDense: true,
                                onChanged: (String newValue) {
                                  setState(() {
                                    // newContact.favoriteColor = newValue;
                                    _color = newValue;
                                    state.didChange(newValue);
                                  });
                                },
                                items: _colors.map((String value) {
                                  return new DropdownMenuItem(
                                    value: value,
                                    child: new Text(value),
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
            SizedBox(
              height: 7,
            ),
            Container(
              alignment: Alignment.center,
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.all(Radius.circular(5.0))),
              width: MediaQuery.of(context).size.width,
              child: Material(
                elevation: 20.0,
                color: highlightColor,
                //  isButtonPressed
                //     ? Theme.of(context).primaryColor
                //     : Theme.of(context).accentColor,
                child: MaterialButton(
                  minWidth: MediaQuery.of(context).size.width,
                  // padding: EdgeInsets.fromLTRB(10.0, 7.5, 10.0, 7.5),
                  onPressed: () {
                    if (_formKey.currentState.validate()) {
                      _formKey.currentState.save();
                      saveEntityDetails(entity);
                      // Navigator.push(
                      //     context,
                      //     MaterialPageRoute(
                      //         builder: (context) =>
                      //             Result(model: this.model)));
                    }
                  },
                  child: Text(
                    'Save & Submit',
                    style: buttonTextStyle,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );

    //         new Container(
    //             padding: const EdgeInsets.only(left: 40.0, top: 20.0),
    //             child: new RaisedButton(
    //               child: const Text('Submit'),
    //               onPressed: null,
    //             )),
    //       ],
    //       //     ),
    //       //   ),
    //       // ],
    //     ),
    //   ),
    // );
  }

  Widget _buildItem(ContactAppData person) {
    return Card(
      //  margin: EdgeInsets.all(10.0),

      color: Colors.white,
      elevation: 10,
      child: new Column(
        children: <Widget>[
          Text(person.empId),
        ],
      ),
    );
  }
}
