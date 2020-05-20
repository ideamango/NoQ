import 'dart:io';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:noq/services/authService.dart';
import 'package:noq/services/qr_code_generate.dart';
import 'package:noq/style.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';

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

  TextEditingController _ctNameController = TextEditingController();

  List<ContactPerson> contactList = new List<ContactPerson>();
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
  }

  String validateText(String value) {
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

  void addPerson() {
    ContactPerson cp = new ContactPerson();
    contactList.add(cp);
    setState(() {
      _addPerson = true;
    });
  }

  Widget _buildContactPerson(ContactPerson contactPerson) {
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
      minLines: 1,
      style: textInputTextStyle,
      keyboardType: TextInputType.text,
      decoration: CommonStyle.textFieldStyle(
          labelTextStr: "Opening Time", hintTextStr: ""),
      validator: validateText,
    );
    final closeTimeField = TextFormField(
      obscureText: false,
      maxLines: 1,
      minLines: 1,
      style: textInputTextStyle,
      keyboardType: TextInputType.text,
      decoration: CommonStyle.textFieldStyle(
          labelTextStr: "Closing Time", hintTextStr: ""),
      validator: validateText,
    );
    final daysClosedField = TextFormField(
      obscureText: false,
      maxLines: 1,
      minLines: 1,
      style: textInputTextStyle,
      keyboardType: TextInputType.text,
      decoration: CommonStyle.textFieldStyle(
          labelTextStr: "Weekly Closure Days", hintTextStr: ""),
      validator: validateText,
    );

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
    final _msgText = Text('This is the message');
    return new SafeArea(
      // top: true,
      // bottom: true,
      child: new Form(
        key: _formKey,
        autovalidate: true,
        child: new ListView(
          padding: const EdgeInsets.symmetric(horizontal: 5.0),
          children: <Widget>[
            nameField,
            entityType,
            regNumField,
            opensTimeField,
            closeTimeField,
            daysClosedField,
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
                      ExpansionTile(
                        //key: PageStorageKey(this.widget.headerTitle),
                        initiallyExpanded: false,
                        title: Text(
                          "Address",
                          style: TextStyle(
                              color: Colors.blueGrey[700], fontSize: 17),
                        ),
                        backgroundColor: Colors.white,
                        trailing: Icon(
                          Icons.info,
                          color: tealIcon,
                        ),
                        children: <Widget>[
                          new Container(
                            width: MediaQuery.of(context).size.width * .94,
                            decoration: BoxDecoration(
                                border: Border.all(color: highlightColor),
                                color: Colors.grey[50],
                                shape: BoxShape.rectangle,
                                borderRadius:
                                    BorderRadius.all(Radius.circular(5.0))),
                            padding: EdgeInsets.all(5.0),
                            child: Expanded(
                              child: Text(
                                  'The address is using the current location, and same will be used by customers when searching your location.',
                                  style: textInputTextStyle),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),

                  // new Container(
                  //     width: MediaQuery.of(context).size.width * .94,
                  //     decoration: BoxDecoration(
                  //         border: Border.all(color: highlightColor),
                  //         color: Colors.grey[50],
                  //         shape: BoxShape.rectangle,
                  //         borderRadius: BorderRadius.all(Radius.circular(5.0))),
                  //     padding: EdgeInsets.all(5.0),
                  //     child: Row(
                  //       children: <Widget>[
                  //         SizedBox(
                  //           width: 3,
                  //         ),
                  //         Expanded(
                  //           child: Text(
                  //               'The address is auto-populated using the current location, and same will be used by customers when searching your location.',
                  //               style: textInputTextStyle),
                  //         ),
                  //         // RichText(
                  //         //   text: TextSpan(children: [
                  //         //     TextSpan(
                  //         //         text: 'The address is populated using the  ',
                  //         //         style: textInputTextStyle),
                  //         //     TextSpan(
                  //         //         text: 'location, and same will be used by ',
                  //         //         style: textInputTextStyle),
                  //         //     TextSpan(
                  //         //         text:
                  //         //             'customers when searching your location.',
                  //         //         style: textInputTextStyle),
                  //         //   ]),
                  //         // ),
                  //       ],
                  //     )

                  //     // padding: const EdgeInsets.only(left: 5.0, right: 5.0),
                  //     //   Row(
                  //     // mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  //     // children: <Widget>[
                  //     //   FlatButton(
                  //     //     color: (_isEditPressed)
                  //     //         ? highlightColor
                  //     //         : Colors.transparent,
                  //     //     splashColor: Colors.teal,
                  //     //     textColor:
                  //     //         (_isEditPressed) ? Colors.white : Colors.orange,
                  //     //     shape: RoundedRectangleBorder(
                  //     //         side: BorderSide(color: Colors.orange)),
                  //     //     child: Text('Auto-fill using current location'),
                  //     //     onPressed: _getCurrLocation,
                  //     //   ),
                  //     //   FlatButton(
                  //     //     color: (_isEditPressed)
                  //     //         ? highlightColor
                  //     //         : Colors.transparent,
                  //     //     splashColor: Colors.teal,
                  //     //     textColor:
                  //     //         (_isEditPressed) ? Colors.white : Colors.orange,
                  //     //     shape: RoundedRectangleBorder(
                  //     //         side: BorderSide(color: Colors.orange)),
                  //     //     child: Text('Edit location'),
                  //     //     onPressed: () => _editLocation,
                  //     //   ),
                  //     //],
                  //     //)
                  //     ),
                  // //if (_autoPopulate == false)
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
                      ExpansionTile(
                        //key: PageStorageKey(this.widget.headerTitle),
                        initiallyExpanded: false,
                        title: Text(
                          "Contact Person",
                          style: TextStyle(
                              color: Colors.blueGrey[700], fontSize: 16),
                        ),
                        backgroundColor: Colors.white,
                        trailing: Icon(
                          Icons.info,
                          color: tealIcon,
                        ),
                        children: <Widget>[
                          new Container(
                            width: MediaQuery.of(context).size.width * .94,
                            decoration: BoxDecoration(
                                border: Border.all(color: highlightColor),
                                color: Colors.grey[50],
                                shape: BoxShape.rectangle,
                                borderRadius:
                                    BorderRadius.all(Radius.circular(5.0))),
                            padding: EdgeInsets.all(5.0),
                            child: Expanded(
                              child: Text(
                                  'The perosn who can be contacted for any queries regarding your services.',
                                  style: textInputTextStyle),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  Column(children: <Widget>[
                    FloatingActionButton(
                      backgroundColor: highlightColor,
                      child: Icon(Icons.add, color: Colors.white),
                      splashColor: highlightColor,
                      onPressed: () {
                        addPerson();
                      },
                    ),
                    if (_addPerson == true)
                      Center(
                        child: Container(
                          margin: EdgeInsets.fromLTRB(10, 10, 10, 10),
                          child: ListView.builder(
                              itemCount: contactList.length,
                              itemBuilder: (BuildContext context, int index) {
                                return Container(
                                  child: Card(
                                    //  margin: EdgeInsets.all(10.0),

                                    color: Colors.white,
                                    elevation: 10,
                                    child: new Column(
                                      children: <Widget>[
                                        _buildItem(contactList[index]),
                                      ],
                                    ),
                                  ),
                                  // contactList.map(_buildItem).toList()),
                                  //children: <Widget>[firstRow, secondRow],
                                );
                              }),
                        ),
                      )
                  ]),
                ],
              ),
            ),
          ],
        ),
      ),
    );

    //         new FormField(
    //           builder: (FormFieldState state) {
    //             return InputDecorator(
    //               decoration: InputDecoration(
    //                 icon: const Icon(Icons.color_lens),
    //                 labelText: 'Color',
    //               ),
    //               isEmpty: _color == '',
    //               child: new DropdownButtonHideUnderline(
    //                 child: new DropdownButton(
    //                   value: _color,
    //                   isDense: true,
    //                   onChanged: (String newValue) {
    //                     setState(() {
    //                       // newContact.favoriteColor = newValue;
    //                       _color = newValue;
    //                       state.didChange(newValue);
    //                     });
    //                   },
    //                   items: _colors.map((String value) {
    //                     return new DropdownMenuItem(
    //                       value: value,
    //                       child: new Text(value),
    //                     );
    //                   }).toList(),
    //                 ),
    //               ),
    //             );
    //           },
    //         ),
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

  Widget _buildItem(ContactPerson person) {
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

class ContactPerson {
  String perName;
  String empId;
  String perPhone1;
  String perPhone2;
  String role;
  String shiftStartTime;
  String shiftEndTime;
  ContactPerson();
}
