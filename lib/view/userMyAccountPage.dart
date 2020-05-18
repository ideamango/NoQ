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

  Position _currentPosition;
  String _currentAddress;

  String _color = '';
  String state;

  @override
  void initState() {
    super.initState();
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
      setState(() {
        _currentPosition = position;
      });
      _getAddressFromLatLng();
    }).catchError((e) {
      print(e);
    });
  }

  _getAddressFromLatLng() async {
    try {
      List<Placemark> p = await geolocator.placemarkFromCoordinates(
          _currentPosition.latitude, _currentPosition.longitude);

      Placemark place = p[0];

      setState(() {
        _currentAddress =
            "${place.locality}, ${place.postalCode}, ${place.country}";
      });
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    final nameField = TextFormField(
      obscureText: false,
      maxLines: 1,
      minLines: 1,
      style: inputTextStyle,
      keyboardType: TextInputType.text,
      decoration: InputDecoration(
        labelText: 'Name',
        enabledBorder:
            UnderlineInputBorder(borderSide: BorderSide(color: Colors.grey)),
        focusedBorder:
            UnderlineInputBorder(borderSide: BorderSide(color: Colors.orange)),
      ),
      validator: validateText,
    );
    final adrsField = TextFormField(
      obscureText: false,
      maxLines: 1,
      minLines: 1,
      style: inputTextStyle,
      keyboardType: TextInputType.text,
      decoration: InputDecoration(
        labelText: 'Address',
        enabledBorder:
            UnderlineInputBorder(borderSide: BorderSide(color: Colors.grey)),
        focusedBorder:
            UnderlineInputBorder(borderSide: BorderSide(color: Colors.orange)),
      ),
      validator: validateText,
    );

    return new SafeArea(
        top: false,
        bottom: false,
        child: new Form(
            key: _formKey,
            autovalidate: true,
            child: new ListView(
              padding: const EdgeInsets.symmetric(horizontal: 5.0),
              children: <Widget>[
                nameField,
                adrsField,
                Row(
                  children: <Widget>[
                    if (_currentPosition != null)
                      Column(
                        children: <Widget>[
                          Text(
                              "LAT: ${_currentPosition.latitude}, LNG: ${_currentPosition.longitude}"),
                          if (_currentAddress != null) Text(_currentAddress),
                        ],
                      ),
                    RaisedButton(
                      child: const Text('GetLocation'),
                      onPressed: _getCurrLocation,
                    )
                  ],
                ),
                new TextFormField(
                  decoration: const InputDecoration(
                    icon: const Icon(Icons.phone),
                    hintText: 'Enter a phone number',
                    labelText: 'Phone',
                  ),
                  keyboardType: TextInputType.phone,
                  inputFormatters: [
                    WhitelistingTextInputFormatter.digitsOnly,
                  ],
                ),
                new TextFormField(
                  decoration: const InputDecoration(
                    icon: const Icon(Icons.email),
                    hintText: 'Enter a email address',
                    labelText: 'Email',
                  ),
                  keyboardType: TextInputType.emailAddress,
                ),
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
                new Container(
                    padding: const EdgeInsets.only(left: 40.0, top: 20.0),
                    child: new RaisedButton(
                      child: const Text('Submit'),
                      onPressed: null,
                    )),
              ],
            )));
  }
}
