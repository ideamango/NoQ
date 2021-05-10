import 'dart:async';
import 'dart:io';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import '../constants.dart';
import '../db/db_model/address.dart';
import '../db/db_model/employee.dart';
import '../db/db_model/entity.dart';
import '../db/db_model/entity_private.dart';
import '../db/db_model/meta_entity.dart';
import '../db/db_model/meta_form.dart';
import '../db/db_model/my_geo_fire_point.dart';
import '../db/db_model/app_user.dart';
import '../db/db_model/offer.dart';
import '../enum/entity_type.dart';
import '../events/event_bus.dart';
import '../global_state.dart';
import '../location.dart';
import '../pages/manage_entity_list_page.dart';
import '../repository/StoreRepository.dart';
import '../services/circular_progress.dart';
import '../style.dart';
import '../utils.dart';
import '../widget/custom_expansion_tile.dart';
import '../widget/page_animation.dart';
import '../widget/weekday_selector.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:another_flushbar/flushbar.dart';
import '../widget/widgets.dart';
import 'package:eventify/eventify.dart' as Eventify;

class ManageEntityDetailsPage extends StatefulWidget {
  final Entity entity;
  final bool isManager;
  ManageEntityDetailsPage(
      {Key key, @required this.entity, @required this.isManager})
      : super(key: key);
  @override
  _ManageEntityDetailsPageState createState() =>
      _ManageEntityDetailsPageState();
}

class _ManageEntityDetailsPageState extends State<ManageEntityDetailsPage> {
  bool _autoValidate = false;
  final GlobalKey<FormState> _entityDetailsFormKey = new GlobalKey<FormState>();
  final GlobalKey<FormFieldState> adminPhoneKey =
      new GlobalKey<FormFieldState>();
  final GlobalKey<FormFieldState> whatsappPhoneKey =
      new GlobalKey<FormFieldState>();
  final GlobalKey<FormFieldState> contactPhoneKey =
      new GlobalKey<FormFieldState>();
  final GlobalKey<FormFieldState> upiIdPhoneKey =
      new GlobalKey<FormFieldState>();
  final GlobalKey<FormFieldState> upiPhoneKey = new GlobalKey<FormFieldState>();
  final GlobalKey<FormFieldState> newAdminRowItemKey =
      new GlobalKey<FormFieldState>();
// keys for bookable mandatory fields
  final GlobalKey<FormFieldState> openDayTimeKey =
      new GlobalKey<FormFieldState>();
  final GlobalKey<FormFieldState> endDayTimeKey =
      new GlobalKey<FormFieldState>();
  final GlobalKey<FormFieldState> slotDurationKey =
      new GlobalKey<FormFieldState>();
  final GlobalKey<FormFieldState> maxPeopleKey =
      new GlobalKey<FormFieldState>();
  final GlobalKey<FormFieldState> maxTokenUserKey =
      new GlobalKey<FormFieldState>();
  final GlobalKey<FormFieldState> advDaysKey = new GlobalKey<FormFieldState>();
  final GlobalKey<FormFieldState> latKey = new GlobalKey<FormFieldState>();
  final GlobalKey<FormFieldState> lonKey = new GlobalKey<FormFieldState>();

// keys for bookable mandatory fields

  //Fields used in info - animated container
  double _width = 0;
  double _height = 0;
  double _videoWidth = 0;
  double _videoHeight = 0;
  bool _isVideoExpanded = false;
  EdgeInsets _margin = EdgeInsets.fromLTRB(5, 0, 5, 0);
  Widget _text;
  Widget _videoText;
  bool _isExpanded = false;
  bool _publicExpandClick = false;
  bool _activeExpandClick = false;
  bool _bookExpandClick = false;
  // Color _color = Colors.green;
  BorderRadiusGeometry _borderRadius = BorderRadius.circular(5);
  bool _autoValidateWhatsapp = false;

  final String title = "Managers Form";

  String flushStatus = "Empty";

  String dateString = "Start Date";
  Offer insertOffer = new Offer();
  bool offerFieldStatus = false;

//Basic Details
  bool isActiveValidation = false;
  TextEditingController _nameController = TextEditingController();
  TextEditingController _descController = TextEditingController();
  TextEditingController _regNumController = TextEditingController();
  TextEditingController _closeTimeController = TextEditingController();
  TextEditingController _openTimeController = TextEditingController();
  TextEditingController _breakStartController = TextEditingController();
  TextEditingController _breakEndController = TextEditingController();

  TextEditingController _maxPeopleController = TextEditingController();
  TextEditingController _maxBookingsInDayForUserController =
      TextEditingController();

  TextEditingController _whatsappPhoneController = TextEditingController();
  TextEditingController _contactPhoneController = TextEditingController();
  TextEditingController _emailIdController = TextEditingController();
  TextEditingController _upiIdController = TextEditingController();
  TextEditingController _upiPhoneController = TextEditingController();
  TextEditingController _upiQrCodeController = TextEditingController();
  TextEditingController _offerMessageController = TextEditingController();
  TextEditingController _offerCouponController = TextEditingController();
  TextEditingController _startDateController = TextEditingController();
  TextEditingController _endDateController = TextEditingController();

  TextEditingController _slotDurationController = TextEditingController();
  TextEditingController _advBookingInDaysController = TextEditingController();

  List<String> _closedOnDays = List<String>();
  List<days> _daysOff = List<days>();
  TextEditingController _latController = TextEditingController();
  TextEditingController _lonController = TextEditingController();
  // TextEditingController _subAreaController = TextEditingController();
  TextEditingController _adrs1Controller = TextEditingController();
  TextEditingController _landController = TextEditingController();
  TextEditingController _localityController = TextEditingController();
  TextEditingController _cityController = TextEditingController();
  TextEditingController _stateController = TextEditingController();
  TextEditingController _countryController = TextEditingController();
  TextEditingController _pinController = TextEditingController();
  // List<String> _addressList = new List<String>();
  //TextEditingController _ctPhn1controller = TextEditingController();

  TextEditingController _adminItemController = new TextEditingController();
  String _item;
  String qrCodeFilePath;

  //ContactPerson Fields

  Employee cp1 = new Employee();
  Address adrs = new Address();
  MetaEntity _metaEntity;
  Entity entity;

  List<Employee> contactList = new List<Employee>();
  List<String> adminsList = new List<String>();
  List<Widget> contactRowWidgets = new List<Widget>();
  List<Widget> contactRowWidgetsNew = new List<Widget>();
  List<Widget> adminRowWidgets = new List<Widget>();

  ScrollController _scrollController;
  final itemSize = 80.0;

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

  bool isPublic = false;
  bool isActive = false;
  bool isBookable = false;
  bool isVideoChatEnabled = false;
  Position pos;
  GlobalState _gs;
  String _phCountryCode;
  bool setActive = false;
  //final Geolocator geolocator = Geolocator()..forceAndroidLocationManager;

  ///from contact page
  bool _isValid = false;
  Employee contact;
  TextEditingController _ctNameController = TextEditingController();
  TextEditingController _ctEmpIdController = TextEditingController();
  TextEditingController _ctPhn1controller = TextEditingController();
  TextEditingController _ctPhn2controller = TextEditingController();
  TextEditingController _ctAvlFromTimeController = TextEditingController();
  TextEditingController _ctAvlTillTimeController = TextEditingController();

  final GlobalKey<FormFieldState> phn1Key = new GlobalKey<FormFieldState>();
  final GlobalKey<FormFieldState> phn2Key = new GlobalKey<FormFieldState>();

  List<String> _ctDaysOff;

  List<days> _ctClosedOnDays;
  Entity _entity;
  List<Employee> _list;
  Eventify.Listener removeManagerListener;

  ///end of fields from contact page

  @override
  void initState() {
    _scrollController = ScrollController();
    super.initState();
    entity = this.widget.entity;
    getGlobalState().whenComplete(() {
      initializeEntity().whenComplete(() {
        setState(() {
          _initCompleted = true;
        });
      });
    });
  }

  @override
  void dispose() {
    super.dispose();
    print("dispose called for child entity");
    EventBus.unregisterEvent(removeManagerListener);
  }

  Future<void> getGlobalState() async {
    _gs = await GlobalState.getGlobalState();
    _phCountryCode = _gs.getConfigurations().phCountryCode;
  }

  initializeEntity() async {
    if (entity != null) {
      isPublic = (entity.isPublic) ?? false;
      isBookable = (entity.isBookable) ?? false;
      isActive = (entity.isActive) ?? false;
      isVideoChatEnabled = entity.enableVideoChat ?? false;

      if (entity.offer != null) {
        insertOffer = entity.offer;
        _offerMessageController.text =
            entity.offer.message != null ? entity.offer.message.toString() : "";
        _offerCouponController.text =
            entity.offer.coupon != null ? entity.offer.coupon.toString() : "";

        _startDateController.text = entity.offer.startDateTime != null
            ? entity.offer.startDateTime.day.toString() +
                " / " +
                entity.offer.startDateTime.month.toString() +
                " / " +
                entity.offer.startDateTime.year.toString()
            : "";
        _endDateController.text = entity.offer.endDateTime != null
            ? entity.offer.endDateTime.day.toString() +
                " / " +
                entity.offer.endDateTime.month.toString() +
                " / " +
                entity.offer.endDateTime.year.toString()
            : "";
      }

      if (isActive) {
        isActiveValidation = true;
      }
      if (isBookable) {
        validateMandatoryFieldsForBookable();
      }
      _nameController.text = entity.name;
      _descController.text = (entity.description);

      if (entity.startTimeHour != null && entity.startTimeMinute != null)
        _openTimeController.text =
            Utils.formatTime(entity.startTimeHour.toString()) +
                ':' +
                Utils.formatTime(entity.startTimeMinute.toString());
      if (entity.endTimeHour != null && entity.endTimeMinute != null)
        _closeTimeController.text =
            Utils.formatTime(entity.endTimeHour.toString()) +
                ':' +
                Utils.formatTime(entity.endTimeMinute.toString());
      if (entity.breakStartHour != null && entity.breakStartMinute != null)
        _breakStartController.text =
            Utils.formatTime(entity.breakStartHour.toString()) +
                ':' +
                Utils.formatTime(entity.breakStartMinute.toString());
      if (entity.breakEndHour != null && entity.breakEndMinute != null)
        _breakEndController.text =
            Utils.formatTime(entity.breakEndHour.toString()) +
                ':' +
                Utils.formatTime(entity.breakEndMinute.toString());

      if (entity.closedOn != null) {
        if (entity.closedOn.length != 0)
          _daysOff = Utils.convertStringsToDays(entity.closedOn);
      }
      // if (_daysOff.length == 0) {
      //   _closedOnDays.add('days.sunday');
      //   _daysOff = Utils.convertStringsToDays(_closedOnDays);
      // }
      _slotDurationController.text =
          entity.slotDuration != null ? entity.slotDuration.toString() : "";
      _advBookingInDaysController.text =
          entity.advanceDays != null ? entity.advanceDays.toString() : "";

      _maxPeopleController.text =
          (entity.maxAllowed != null) ? entity.maxAllowed.toString() : "";
      _maxBookingsInDayForUserController.text =
          (entity.maxPeoplePerToken != null)
              ? entity.maxPeoplePerToken.toString()
              : "";

      _whatsappPhoneController.text = entity.whatsapp != null
          ? entity.whatsapp.toString().substring(3)
          : "";
      _contactPhoneController.text = Utils.isNotNullOrEmpty(entity.phone)
          ? entity.phone.toString().substring(3)
          : "";
      _emailIdController.text = Utils.isNotNullOrEmpty(entity.supportEmail)
          ? entity.supportEmail
          : "";

      _upiIdController.text =
          Utils.isNotNullOrEmpty(entity.upiId) ? entity.upiId : "";
      // _upiPhoneController.text = Utils.isNotNullOrEmpty(entity.upiPhoneNumber)
      //     ? entity.upiPhoneNumber.toString().substring(3)
      //     : "";

      if (entity.coordinates != null) {
        _latController.text = entity.coordinates.geopoint.latitude.toString();
        _lonController.text = entity.coordinates.geopoint.longitude.toString();
      }

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
      // if (!(Utils.isNullOrEmpty(entity.managers))) {
      //   contactList = entity.managers;
      //   contactList.forEach((element) {
      //     contactRowWidgets.add(new ContactRow(
      //         contact: element, entity: entity, list: contactList));
      //   });
      // }

      AppUser currUser = _gs.getCurrentUser();
      // Map<String, String> adminMap = Map<String, String>();
      EntityPrivate entityPrivateList;
      entityPrivateList = await fetchAdmins(entity.entityId);
      if (entityPrivateList != null) {
        //   adminMap = entityPrivateList.roles;
        //   if (adminMap != null)
        //     adminMap.forEach((k, v) {
        //       if (currUser.ph != k) adminsList.add(k);
        //     });
        _regNumController.text = entityPrivateList.registrationNumber;
      }
    }
    Location lc = _gs.getLocation();
    Address defaultAdrs = new Address();
    if (lc != null) {
      defaultAdrs.state = lc.region;
      defaultAdrs.zipcode = lc.zip;
      defaultAdrs.city = lc.city;
      defaultAdrs.country = lc.country;
    }
    entity.address = (entity.address) ?? defaultAdrs;

    _cityController.text = entity.address.city;
    _stateController.text = entity.address.state;
    _countryController.text = entity.address.country;
    _pinController.text = entity.address.zipcode;
    contactList = contactList ?? [];

    //  _ctNameController.text = entity.contactPersons[0].perName;
  }

  String validateText(String value) {
    if (value == null || value == "") {
      return 'Field is empty';
    } else
      return null;
  }

  String validateNumber(String value) {
    if (value == null || value == "") {
      return 'Field is empty';
    } else if (int.tryParse(value) == null) {
      return '$value is not a valid number';
    } else
      return null;
  }

  String validateAdvanceBookingDays(String value) {
    if (value == null || value == "") {
      return 'Field is empty';
    } else if (int.tryParse(value) == null) {
      return '$value is not a valid number of Days';
    } else if (int.parse(value) > 7) {
      return 'Number of Days should be less than 7.';
    } else
      return null;
  }

  String validateTime(String value) {
    if (value == null || value == "") {
      return 'Field is empty';
    } else
      return null;
  }

  String validateTimeFields() {
    if ((entity.breakEndHour != null && entity.breakStartHour == null) ||
        (entity.breakEndHour == null && entity.breakStartHour != null)) {
      return "Both Break Start and Break End time should be specified.";
    }
    if ((entity.startTimeHour != null && entity.endTimeHour == null) ||
        (entity.startTimeHour == null && entity.endTimeHour != null)) {
      return "Both Day Start and Day End time should be specified.";
    }
    return null;
  }

  _getAddressFromLatLng(Position position) async {
    setState(() {
      entity.coordinates =
          new MyGeoFirePoint(position.latitude, position.longitude);
      _latController.text = position.latitude.toString();
      _lonController.text = position.longitude.toString();
    });
  }

  void clearLocation() {
//If entity is Public or entity is active, latitude, longitude must be given.
    if (entity.isActive) {
      Utils.showMyFlushbar(
          context,
          Icons.info_outline,
          Duration(
            seconds: 6,
          ),
          "CURRENT LOCATION is must if entity is ACTIVE.",
          "If you really want to clear location, deselect ACTIVE at bottom of the page.");
    } else {
      _latController.text = "";
      _lonController.text = "";
      entity.coordinates = null;
    }
  }

  Future<File> captureImage(bool gallery) async {
    ImagePicker picker = ImagePicker();
    PickedFile pickedFile;
    File newImageFile;

    if (gallery) {
      pickedFile = await picker.getImage(
          source: ImageSource.gallery,
          maxHeight: 600,
          maxWidth: 600,
          imageQuality: 50);
    }
    // Otherwise open camera to get new photo
    else {
      pickedFile = await picker.getImage(
          source: ImageSource.camera,
          maxHeight: 600,
          maxWidth: 600,
          imageQuality: 50);
    }

    if (pickedFile != null) {
      newImageFile = File(pickedFile.path);
    }
    return newImageFile;
  }

  Future<String> uploadFilesToServer(
      String localPath, String targetFileName) async {
    File localImage = File(localPath);

    Reference ref = _gs.firebaseStorage.ref().child('$targetFileName');

    await ref.putFile(localImage);

    return await ref.getDownloadURL();
  }

  String validateMandatoryFieldsForBookable() {
    String msg;
    bool error = false;
    if (isBookable) {
      if (openDayTimeKey.currentState != null) {
        error = (openDayTimeKey.currentState.validate());
      }
      if (endDayTimeKey.currentState != null) {
        error = (endDayTimeKey.currentState.validate());
      }
      if (slotDurationKey.currentState != null) {
        error = (slotDurationKey.currentState.validate());
      }
      if (advDaysKey.currentState != null) {
        error = (advDaysKey.currentState.validate());
      }
      if (maxPeopleKey.currentState != null) {
        error = (maxPeopleKey.currentState.validate());
      }
      if (maxTokenUserKey.currentState != null) {
        error = (maxTokenUserKey.currentState.validate());
      }
      if (latKey.currentState != null) {
        error = (latKey.currentState.validate());
      }
      if (lonKey.currentState != null) {
        error = (lonKey.currentState.validate());
      }

      if (!error) {
        msg =
            "Current Location, Slot duration, Max. People allowed etc are missing.";
      }
    }

    return msg;
  }

  String validateFieldsForOnlineConsultation() {
    //Whatsapp number should be given
    String msg;
    if (Utils.isStrNullOrEmpty(_whatsappPhoneController.text)) {
      msg =
          "WhatsApp phone number should be provided, for enabling Online Consultation.";
    }
    return msg;
  }

  @override
  Widget build(BuildContext context) {
    if (_initCompleted) {
      //Basic details field
      final nameField = TextFormField(
        obscureText: false,
        maxLines: 1,
        minLines: 1,
        enabled: widget.isManager ? false : true,
        style: textInputTextStyle,
        controller: _nameController,
        keyboardType: TextInputType.text,
        autovalidateMode: AutovalidateMode.always,
        decoration: CommonStyle.textFieldStyle(
            labelTextStr: "Name of Establishment", hintTextStr: ""),
        validator: (value) {
          return validateText(value);
        },
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
        enabled: widget.isManager ? false : true,
        decoration: CommonStyle.textFieldStyle(
            labelTextStr: "Description (optional)", hintTextStr: ""),
        validator: (value) {
          // if (!isActiveValidation)
          //   return validateText(value);
          // else
          return null;
        },
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
        enabled: widget.isManager ? false : true,
        keyboardType: TextInputType.text,
        controller: _regNumController,
        decoration: CommonStyle.textFieldStyle(
            labelTextStr: "Registration Number", hintTextStr: ""),
        onSaved: (String value) {
          //TODO: test if regNum is getting saved
          //entity.regNum = value;
        },
      );
      bool dayStartClearClicked = false;
      bool dayEndClearClicked = false;
      bool breakStartClearClicked = false;
      bool breakEndClearClicked = false;
      final opensTimeField = TextFormField(
        key: openDayTimeKey,
        obscureText: false,
        maxLines: 1,
        readOnly: true,
        enabled: widget.isManager ? false : true,
        minLines: 1,
        style: textInputTextStyle,
        onTap: () {
          if (!dayStartClearClicked) {
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
          }
        },
        controller: _openTimeController,
        autovalidateMode: AutovalidateMode.always,
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
            suffixIconConstraints: BoxConstraints(
              maxWidth: 25,
              maxHeight: 22,
            ),
            suffixIcon: new IconButton(
                //constraints: BoxConstraints.tight(Size(15, 15)),
                alignment: Alignment.centerLeft,
                padding: EdgeInsets.all(0),
                icon: new Icon(
                  Icons.cancel,
                  size: 25,
                  color: Colors.blueGrey[500],
                ),
                onPressed: () {
                  dayStartClearClicked = true;
                  _openTimeController.text = "";
                  entity.startTimeHour = null;
                  entity.startTimeMinute = null;
                  setState(() {});
                }),
            labelText: "Opening time",
            hintText: "hh:mm 24 hour time format",
            enabledBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: Colors.grey)),
            focusedBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: Colors.orange))),
        validator: (value) {
          if (isBookable || isActiveValidation) {
            if (value == null || value == "") {
              return 'Field is empty';
            } else
              return null;
          }
          return null;
        },
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
        key: endDayTimeKey,
        obscureText: false,
        readOnly: true,
        enabled: widget.isManager ? false : true,
        maxLines: 1,
        minLines: 1,
        controller: _closeTimeController,
        autovalidateMode: AutovalidateMode.always,
        style: textInputTextStyle,
        onTap: () {
          if (!dayEndClearClicked) {
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
          }
        },
        decoration: InputDecoration(
            labelText: "Closing time",
            hintText: "hh:mm 24 hour time format",
            suffixIconConstraints: BoxConstraints(
              maxWidth: 25,
              maxHeight: 22,
            ),
            suffixIcon: new IconButton(
                //constraints: BoxConstraints.tight(Size(15, 15)),
                alignment: Alignment.centerLeft,
                padding: EdgeInsets.all(0),
                icon: new Icon(
                  Icons.cancel,
                  size: 25,
                  color: Colors.blueGrey[500],
                ),
                onPressed: () {
                  dayEndClearClicked = true;
                  _closeTimeController.text = "";
                  entity.endTimeHour = null;
                  entity.endTimeMinute = null;
                  setState(() {});
                }),
            enabledBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: Colors.grey)),
            focusedBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: Colors.orange))),
        validator: (value) {
          if (isBookable || isActiveValidation) {
            if (value == null || value == "") {
              return 'Field is empty';
            } else
              return null;
          }
          return null;
        },
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
        enabled: widget.isManager ? false : true,
        minLines: 1,
        style: textInputTextStyle,
        onTap: () {
          if (!breakStartClearClicked) {
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
          }
        },
        controller: _breakStartController,
        keyboardType: TextInputType.text,
        decoration: InputDecoration(
            labelText: "Break starts at",
            hintText: "hh:mm 24 hour time format",
            suffixIconConstraints: BoxConstraints(
              maxWidth: 25,
              maxHeight: 22,
            ),
            suffixIcon: new IconButton(
                //constraints: BoxConstraints.tight(Size(15, 15)),
                alignment: Alignment.centerLeft,
                padding: EdgeInsets.all(0),
                icon: new Icon(
                  Icons.cancel,
                  size: 25,
                  color: Colors.blueGrey[500],
                ),
                onPressed: () {
                  breakStartClearClicked = true;
                  _breakStartController.text = "";
                  entity.breakStartHour = null;
                  entity.breakStartMinute = null;
                  setState(() {});
                }),
            enabledBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: Colors.grey)),
            focusedBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: Colors.orange))),
        validator: (value) {
          return null;
        },
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
        obscureText: false,
        readOnly: true,
        enabled: widget.isManager ? false : true,
        maxLines: 1,
        minLines: 1,
        controller: _breakEndController,
        style: textInputTextStyle,
        onTap: () {
          if (!breakEndClearClicked) {
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
          }
        },
        decoration: InputDecoration(
            labelText: "Break ends at",
            hintText: "hh:mm 24 hour time format",
            suffixIconConstraints: BoxConstraints(
              maxWidth: 25,
              maxHeight: 22,
            ),
            suffixIcon: new IconButton(
                //constraints: BoxConstraints.tight(Size(15, 15)),
                alignment: Alignment.centerLeft,
                padding: EdgeInsets.all(0),
                icon: new Icon(
                  Icons.cancel,
                  size: 25,
                  color: Colors.blueGrey[500],
                ),
                onPressed: () {
                  breakEndClearClicked = true;
                  _breakEndController.text = "";
                  entity.breakEndHour = null;
                  entity.breakEndMinute = null;
                  setState(() {});
                }),
            enabledBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: Colors.grey)),
            focusedBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: Colors.orange))),
        validator: (value) {
          return null;
        },
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
              enabled: widget.isManager ? false : true,
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
                entity.closedOn = _closedOnDays;
                print(_closedOnDays.length);
                print(_closedOnDays.toString());
              },
            ),
          ],
        ),
      );
      final slotDuration = TextFormField(
        key: slotDurationKey,
        obscureText: false,
        maxLines: 1,
        minLines: 1,
        enabled: widget.isManager ? false : true,
        style: textInputTextStyle,
        keyboardType: TextInputType.number,
        autovalidateMode: AutovalidateMode.always,
        controller: _slotDurationController,
        decoration: InputDecoration(
          labelText: 'Duration of time slot (in minutes)',
          enabledBorder:
              UnderlineInputBorder(borderSide: BorderSide(color: Colors.grey)),
          focusedBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.orange)),
        ),
        validator: (value) {
          if (isBookable) {
            return validateText(value);
          }
          return null;
        },
        onChanged: (value) {
          if (value != "") entity.slotDuration = int.parse(value);
          print("slot duration saved");
        },
        onSaved: (String value) {
          if (value != "") entity.slotDuration = int.parse(value);
          print("slot duration saved");
        },
      );
      final advBookingInDays = TextFormField(
        key: advDaysKey,
        obscureText: false,
        maxLines: 1,
        minLines: 1,
        autovalidateMode: AutovalidateMode.always,
        enabled: widget.isManager ? false : true,
        style: textInputTextStyle,
        keyboardType: TextInputType.number,
        controller: _advBookingInDaysController,
        decoration: InputDecoration(
          labelText: 'Advance Booking Allowed(in days)',
          enabledBorder:
              UnderlineInputBorder(borderSide: BorderSide(color: Colors.grey)),
          focusedBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.orange)),
        ),
        validator: (value) {
          if (isBookable) {
            return validateAdvanceBookingDays(value);
          }
          return null;
        },
        onChanged: (value) {
          if (value != "") {
            entity.advanceDays = int.parse(value);
          }
          print("Advance Booking Allowed saved");
        },
        onSaved: (String value) {
          if (value != "") entity.advanceDays = int.parse(value);
          print("Advance Booking Allowed saved");
        },
      );
      final maxpeopleInASlot = TextFormField(
        key: maxPeopleKey,
        obscureText: false,
        maxLines: 1,
        minLines: 1,
        autovalidateMode: AutovalidateMode.always,
        enabled: widget.isManager ? false : true,
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
        validator: (value) {
          if (isBookable) {
            return validateNumber(value);
          }
          return null;
        },
        onChanged: (value) {
          if (value != "") entity.maxAllowed = int.parse(value);
          print("saved max people");
        },
        onSaved: (String value) {
          if (value != "") entity.maxAllowed = int.parse(value);
          print("saved max people");
        },
      );
      final maxTokenPerDay = TextFormField(
        key: maxTokenUserKey,
        obscureText: false,
        maxLines: 1,
        minLines: 1,
        autovalidateMode: AutovalidateMode.always,
        enabled: widget.isManager ? false : true,
        style: textInputTextStyle,
        keyboardType: TextInputType.number,
        controller: _maxBookingsInDayForUserController,
        decoration: InputDecoration(
          labelText: 'Max. bookings allowed for a user per day',
          enabledBorder:
              UnderlineInputBorder(borderSide: BorderSide(color: Colors.grey)),
          focusedBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.orange)),
        ),
        validator: (value) {
          if (isBookable) {
            return validateText(value);
          }
          return null;
        },
        onChanged: (value) {
          if (value != "") entity.maxTokensByUserInDay = int.parse(value);
        },
        onSaved: (String value) {
          if (value != "") entity.maxTokensByUserInDay = int.parse(value);
        },
      );

      final whatsappPhone = TextFormField(
        obscureText: false,
        maxLines: 1,
        minLines: 1,
        enabled: widget.isManager ? false : true,
        key: whatsappPhoneKey,
        style: textInputTextStyle,
        keyboardType: TextInputType.phone,
        controller: _whatsappPhoneController,
        autovalidateMode: AutovalidateMode.always,
        decoration: InputDecoration(
          prefixText: '+91',
          labelText: 'WhatsApp Number (optional)',
          enabledBorder:
              UnderlineInputBorder(borderSide: BorderSide(color: Colors.grey)),
          focusedBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.orange)),
        ),
        validator: (value) {
          if (isVideoChatEnabled) {
            if (Utils.isStrNullOrEmpty(value)) {
              return "Field is empty.";
            }
          }
          return Utils.validateMobileField(value);
        },
        onChanged: (value) {
          entity.whatsapp = _phCountryCode + (value);
        },
        onSaved: (String value) {
          entity.whatsapp = _phCountryCode + (value);
        },
      );
      final callingPhone = TextFormField(
        obscureText: false,
        maxLines: 1,
        minLines: 1,
        enabled: widget.isManager ? false : true,
        key: contactPhoneKey,
        style: textInputTextStyle,
        keyboardType: TextInputType.phone,
        autovalidateMode: AutovalidateMode.always,
        controller: _contactPhoneController,
        decoration: InputDecoration(
          prefixText: '+91',
          labelText: 'Contact Phone Number (recommended)',
          enabledBorder:
              UnderlineInputBorder(borderSide: BorderSide(color: Colors.grey)),
          focusedBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.orange)),
        ),
        validator: (value) {
          if (isBookable || isActiveValidation) {
            return Utils.validateMobileField(value);
          }
          return null;
        },
        onChanged: (value) {
          if (value != "") entity.phone = _phCountryCode + (value);
        },
        onSaved: (String value) {
          if (value != "") entity.phone = _phCountryCode + (value);
        },
      );
      final emailId = TextFormField(
        obscureText: false,
        maxLines: 1,
        minLines: 1,
        enabled: widget.isManager ? false : true,
        style: textInputTextStyle,
        keyboardType: TextInputType.emailAddress,
        controller: _emailIdController,
        decoration: InputDecoration(
          // prefixText: '+91',
          labelText: 'Contact Email Id (recommended)',
          enabledBorder:
              UnderlineInputBorder(borderSide: BorderSide(color: Colors.grey)),
          focusedBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.orange)),
        ),
        validator: Utils.validateEmail,
        onChanged: (value) {
          if (value != "") entity.supportEmail = value;
        },
        onSaved: (String value) {
          if (value != "") entity.supportEmail = value;
        },
      );
      final upiIdField = TextFormField(
        obscureText: false,
        maxLines: 1,
        minLines: 1,
        enabled: widget.isManager ? false : true,
        style: textInputTextStyle,
        keyboardType: TextInputType.text,
        controller: _upiIdController,
        decoration: InputDecoration(
          //prefixText: '+91',
          labelText: 'UPI Id in format ******@*** (optional)',
          enabledBorder:
              UnderlineInputBorder(borderSide: BorderSide(color: Colors.grey)),
          focusedBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.orange)),
        ),
        validator: Utils.validateUpiAddress,
        onChanged: (value) {
          if (value != "") entity.upiId = (value);
        },
        onSaved: (String value) {
          if (value != "") entity.upiId = (value);
        },
      );

      // final upiPhone = TextFormField(
      //   obscureText: false,
      //   maxLines: 1,
      //   minLines: 1,
      //   key: upiPhoneKey,
      //   style: textInputTextStyle,
      //   keyboardType: TextInputType.phone,
      //   controller: _upiPhoneController,
      //   decoration: InputDecoration(
      //     prefixText: '+91',
      //     labelText: 'UPI Phone Number (optional)',
      //     enabledBorder:
      //         UnderlineInputBorder(borderSide: BorderSide(color: Colors.grey)),
      //     focusedBorder: UnderlineInputBorder(
      //         borderSide: BorderSide(color: Colors.orange)),
      //   ),
      //   validator: Utils.validateMobileField,
      //   onChanged: (value) {
      //     //_autoValidateWhatsapp = true;
      //     upiPhoneKey.currentState.validate();
      //     if (value != "") entity.upiPhoneNumber = _phCountryCode + (value);
      //   },
      //   onSaved: (String value) {
      //     if (value != "") entity.upiPhoneNumber = _phCountryCode + (value);
      //   },
      // );
      // final upiQrCodeField = Column(
      //   children: [
      //     TextFormField(
      //       obscureText: false,
      //       maxLines: 1,
      //       minLines: 1,
      //       style: textInputTextStyle,
      //       controller: _upiQrCodeController,
      //       decoration: InputDecoration(
      //         suffix: Row(
      //           mainAxisAlignment: MainAxisAlignment.end,
      //           children: [
      //             IconButton(
      //                 padding: EdgeInsets.zero,
      //                 icon: Icon(
      //                   Icons.camera_alt_rounded,
      //                   color: primaryDarkColor,
      //                 ),
      //                 onPressed: () {
      //                   captureImage(false).then((value) {
      //                     if (value != null) {
      //                       qrCodeFilePath = value.path;
      //                       _upiQrCodeController.text = value.path;
      //                       //attsField.responseFilePaths.add(value.path);
      //                     }
      //                     setState(() {});
      //                   });
      //                 }),
      //             IconButton(
      //                 padding: EdgeInsets.zero,
      //                 icon: Icon(
      //                   Icons.attach_file,
      //                   color: primaryDarkColor,
      //                 ),
      //                 onPressed: () {
      //                   captureImage(true).then((value) {
      //                     if (value != null) {
      //                       // _medCondsProofimages.add(value);
      //                       qrCodeFilePath = value.path;
      //                       _upiQrCodeController.text = value.path;
      //                     }
      //                     setState(() {});
      //                   });
      //                 }),
      //           ],
      //         ),
      //         labelText: 'Upload UPI Payment Qr Code (optional)',
      //         enabledBorder: UnderlineInputBorder(
      //             borderSide: BorderSide(color: Colors.grey)),
      //         focusedBorder: UnderlineInputBorder(
      //             borderSide: BorderSide(color: Colors.orange)),
      //       ),
      //       // validator: Utils.validateMobileField,
      //       onChanged: (value) {
      //         //_autoValidateWhatsapp = true;
      //         upiPhoneKey.currentState.validate();
      //         if (value != "") entity.qrCodeImagePath = (value);
      //       },
      //       onSaved: (String value) {
      //         if (value != "") entity.qrCodeImagePath = (value);
      //       },
      //     ),
      //   ],
      // );

      checkOfferDetailsFilled() {
        if (insertOffer.message != null && insertOffer.message.isNotEmpty ||
            insertOffer.coupon != null && insertOffer.coupon.isNotEmpty ||
            insertOffer.startDateTime != null ||
            insertOffer.endDateTime != null) {
          entity.offer = insertOffer;
        } else
          entity.offer = null;
      }

      clearOfferDetail() {
        insertOffer = new Offer();
        entity.offer = null;
        offerFieldStatus = false;
        _offerCouponController.text = "";
        _offerMessageController.text = "";
        _startDateController.text = "";
        _endDateController.text = "";
      }

      final messageField = TextFormField(
        obscureText: false,
        //minLines: 1,
        enabled: widget.isManager ? false : true,
        style: textInputTextStyle,
        controller: _offerMessageController,
        decoration: CommonStyle.textFieldStyle(
          labelTextStr: "Offer Message",
        ),
        validator: (value) {
          if (offerFieldStatus) {
            if (value == null || value == "") {
              return 'Field is empty';
            } else
              return null;
          } else
            return null;
        },
        keyboardType: TextInputType.multiline,
        maxLength: null,
        maxLines: 1,
        onChanged: (String value) {
          if (Utils.isNotNullOrEmpty(value)) {
            insertOffer.message = value;
            offerFieldStatus = true;
            checkOfferDetailsFilled();
          }
        },
        onSaved: (String value) {
          if (Utils.isNotNullOrEmpty(value)) {
            insertOffer.message = value;
            offerFieldStatus = true;
            checkOfferDetailsFilled();
          }
        },
      );

      final couponField = TextFormField(
        obscureText: false,
        //minLines: 1,
        style: textInputTextStyle,
        enabled: widget.isManager ? false : true,
        controller: _offerCouponController,
        decoration: CommonStyle.textFieldStyle(labelTextStr: "Coupon"),
        validator: (value) {
          if (offerFieldStatus) {
            if (value == null || value == "") {
              return 'Field is empty';
            } else
              return null;
          } else
            return null;
        },
        keyboardType: TextInputType.multiline,
        maxLength: null,
        maxLines: 1,
        onChanged: (String value) {
          if (Utils.isNotNullOrEmpty(value)) {
            insertOffer.coupon = value;
            offerFieldStatus = true;
            checkOfferDetailsFilled();
          }
        },
        onSaved: (String value) {
          if (Utils.isNotNullOrEmpty(value)) {
            insertOffer.coupon = value;
            offerFieldStatus = true;
            checkOfferDetailsFilled();
          }
        },
      );

      Future<Null> startPickDate(BuildContext context) async {
        DateTime date = await showDatePicker(
          context: context,
          firstDate: DateTime.now(),
          lastDate: DateTime(DateTime.now().year + 2, DateTime.now().month,
              DateTime.now().day),
          initialDate: insertOffer.startDateTime != null
              ? insertOffer.startDateTime.isBefore(DateTime.now())
                  ? DateTime.now()
                  : insertOffer.startDateTime
              : DateTime.now(),
          builder: (BuildContext context, Widget child) {
            return Theme(
              data: ThemeData.dark().copyWith(
                colorScheme: ColorScheme.light(
                  primary: Colors.cyan,
                ),
                dialogBackgroundColor: Colors.white,
              ),
              child: child,
            );
          },
        );
        if (date != null) {
          setState(() {
            insertOffer.startDateTime = date;
            dateString = date.day.toString() +
                " / " +
                date.month.toString() +
                " / " +
                date.year.toString();
            _startDateController.text = dateString;
            checkOfferDetailsFilled();
            offerFieldStatus = true;
          });
        }
      }

      Future<Null> endPickDate(BuildContext context) async {
        DateTime date = await showDatePicker(
          context: context,
          firstDate: insertOffer.startDateTime != null
              ? insertOffer.startDateTime.isBefore(DateTime.now())
                  ? DateTime.now()
                  : insertOffer.startDateTime
              : DateTime.now(),
          lastDate: DateTime(DateTime.now().year + 2, DateTime.now().month,
              DateTime.now().day),
          initialDate: insertOffer.endDateTime != null
              ? insertOffer.endDateTime.isBefore(DateTime.now()) &&
                      insertOffer.startDateTime.isBefore(DateTime.now())
                  ? DateTime.now()
                  : insertOffer.endDateTime.isAfter(insertOffer.startDateTime)
                      ? insertOffer.endDateTime
                      : insertOffer.startDateTime
              : insertOffer.startDateTime != null
                  ? insertOffer.startDateTime
                  : DateTime.now(),
          builder: (BuildContext context, Widget child) {
            return Theme(
              data: ThemeData.dark().copyWith(
                colorScheme: ColorScheme.light(
                  primary: Colors.cyan,
                ),
                dialogBackgroundColor: Colors.white,
              ),
              child: child,
            );
          },
        );
        if (date != null) {
          setState(() {
            insertOffer.endDateTime = date;
            dateString = date.day.toString() +
                " / " +
                date.month.toString() +
                " / " +
                date.year.toString();
            _endDateController.text = dateString;
            checkOfferDetailsFilled();
            offerFieldStatus = true;
          });
        }
      }

      final startDateField = TextFormField(
        obscureText: false,
        //minLines: 1,
        style: textInputTextStyle,
        enabled: widget.isManager ? false : true,
        controller: _startDateController,
        decoration: CommonStyle.textFieldStyle(
            labelTextStr: "Start Date", hintTextStr: ""),
        validator: (value) {
          if (offerFieldStatus) {
            if (value != null && value != "") {
              if (insertOffer.endDateTime == null)
                return "End Date field is empty";
              else
                return null;
            } else
              return "Field is Empty";
          } else
            return null;
        },
        onTap: () {
          setState(() {
            startPickDate(context);
          });
        },
        maxLength: null,
        maxLines: 1,
        onChanged: (String value) {
          checkOfferDetailsFilled();
        },
        onSaved: (String value) {
          checkOfferDetailsFilled();
        },
      );

      final endDateField = TextFormField(
        obscureText: false,
        //minLines: 1,
        enabled: widget.isManager ? false : true,
        style: textInputTextStyle,
        controller: _endDateController,
        decoration: CommonStyle.textFieldStyle(
            labelTextStr: "End Date", hintTextStr: ""),
        validator: (value) {
          if (offerFieldStatus) {
            if (value != null && value != "") {
              if (insertOffer.startDateTime == null)
                return "Start Date Field is empty";
              else
                return null;
            } else
              return "Field is Empty";
          } else
            return null;
        },
        onTap: () {
          setState(() {
            endPickDate(context);
          });
        },
        maxLength: null,
        maxLines: 1,
        onChanged: (String value) {
          checkOfferDetailsFilled();
        },
        onSaved: (String value) {
          checkOfferDetailsFilled();
        },
      );

      final latField = Container(
          width: MediaQuery.of(context).size.width * .3,
          child: TextFormField(
            key: latKey,
            obscureText: false,
            maxLines: 1,
            minLines: 1,
            // enabled: false,
            style: textInputTextStyle,
            keyboardType: TextInputType.text,
            controller: _latController,
            autovalidateMode: AutovalidateMode.always,
            decoration: CommonStyle.textFieldStyle(
                labelTextStr: "Latitude", hintTextStr: ""),
            validator: (value) {
              if (isBookable || isActiveValidation) {
                return validateText(value);
              }
              return null;
            },
            onChanged: (String value) {},
            onSaved: (String value) {},
          ));

      final lonField = Container(
          width: MediaQuery.of(context).size.width * .3,
          child: TextFormField(
            key: lonKey,
            obscureText: false,
            maxLines: 1,
            minLines: 1,
            // enabled: false,
            autovalidateMode: AutovalidateMode.always,
            style: textInputTextStyle,
            keyboardType: TextInputType.text,
            controller: _lonController,
            decoration: CommonStyle.textFieldStyle(
                labelTextStr: "Longitude", hintTextStr: ""),
            validator: (value) {
              if (isBookable || isActiveValidation) {
                return validateText(value);
              }
              return null;
            },
            onChanged: (String value) {},
            onSaved: (String value) {},
          ));
      final clearBtn = Container(
          width: MediaQuery.of(context).size.width * .3,
          child: FlatButton(
              //elevation: 20,
              color: Colors.transparent,
              splashColor: highlightColor,
              textColor: btnColor,
              shape: RoundedRectangleBorder(side: BorderSide(color: btnColor)),
              child: Text(
                'Clear',
                textAlign: TextAlign.center,
              ),
              onPressed: () {
                if (widget.isManager) {
                  return;
                } else {
                  clearLocation();
                }
              }));
//Address fields
      final adrsField1 = TextFormField(
        obscureText: false,
        enabled: widget.isManager ? false : true,
        maxLines: 1,
        minLines: 1,
        style: textInputTextStyle,
        keyboardType: TextInputType.text,
        autovalidateMode: AutovalidateMode.always,
        controller: _adrs1Controller,
        decoration: CommonStyle.textFieldStyle(
            labelTextStr: "Apartment/ House No./ Lane", hintTextStr: ""),
        validator: (value) {
          if (isBookable || isActiveValidation) {
            return validateText(value);
          } else
            return null;
        },
        onChanged: (String value) {
          entity.address.address = value;
          print("changed address");
        },
        onSaved: (String value) {
          entity.address.address = value;
          print("saved address");
        },
      );
      final landmarkField2 = TextFormField(
        obscureText: false,
        enabled: widget.isManager ? false : true,
        maxLines: 1,
        minLines: 1,
        style: textInputTextStyle,
        keyboardType: TextInputType.text,
        autovalidateMode: AutovalidateMode.always,
        controller: _landController,
        decoration: InputDecoration(
          labelText: 'Landmark',
          enabledBorder:
              UnderlineInputBorder(borderSide: BorderSide(color: Colors.grey)),
          focusedBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.orange)),
        ),
        onChanged: (String value) {
          entity.address.landmark = value;
          print("changed landmark");
        },
        onSaved: (String value) {
          entity.address.landmark = value;
          print("saved landmark");
        },
      );
      final localityField = TextFormField(
        obscureText: false,
        enabled: widget.isManager ? false : true,
        maxLines: 1,
        minLines: 1,
        style: textInputTextStyle,
        controller: _localityController,
        autovalidateMode: AutovalidateMode.always,
        keyboardType: TextInputType.text,
        decoration: InputDecoration(
          labelText: 'Locality',
          enabledBorder:
              UnderlineInputBorder(borderSide: BorderSide(color: Colors.grey)),
          focusedBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.orange)),
        ),
        validator: (value) {
          if (isBookable || isActiveValidation)
            return validateText(value);
          else
            return null;
        },
        onSaved: (String value) {
          entity.address.locality = value;
          print("saved address");
        },
      );
      final cityField = TextFormField(
        obscureText: false,
        enabled: widget.isManager ? false : true,
        maxLines: 1,
        minLines: 1,
        style: textInputTextStyle,
        keyboardType: TextInputType.text,
        autovalidateMode: AutovalidateMode.always,
        controller: _cityController,
        decoration: InputDecoration(
          labelText: 'City',
          enabledBorder:
              UnderlineInputBorder(borderSide: BorderSide(color: Colors.grey)),
          focusedBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.orange)),
        ),
        validator: (value) {
          if (isBookable || isActiveValidation)
            return validateText(value);
          else
            return null;
        },
        onSaved: (String value) {
          entity.address.city = value;
          print("saved address");
        },
      );
      final stateField = TextFormField(
        obscureText: false,
        enabled: widget.isManager ? false : true,
        maxLines: 1,
        minLines: 1,
        style: textInputTextStyle,
        keyboardType: TextInputType.text,
        autovalidateMode: AutovalidateMode.always,
        controller: _stateController,
        decoration: InputDecoration(
          labelText: 'State',
          enabledBorder:
              UnderlineInputBorder(borderSide: BorderSide(color: Colors.grey)),
          focusedBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.orange)),
        ),
        validator: (value) {
          if (isBookable || isActiveValidation)
            return validateText(value);
          else
            return null;
        },
        onSaved: (String value) {
          entity.address.state = value;
          print("saved address");
        },
      );
      final countryField = TextFormField(
        obscureText: false,
        enabled: widget.isManager ? false : true,
        maxLines: 1,
        minLines: 1,
        style: textInputTextStyle,
        keyboardType: TextInputType.text,
        autovalidateMode: AutovalidateMode.always,
        controller: _countryController,
        decoration: InputDecoration(
          labelText: 'Country',
          enabledBorder:
              UnderlineInputBorder(borderSide: BorderSide(color: Colors.grey)),
          focusedBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.orange)),
        ),
        validator: (value) {
          if (isBookable || isActiveValidation)
            return validateText(value);
          else
            return null;
        },
        onSaved: (String value) {
          entity.address.country = value;
          print("saved address");
        },
      );
      final pinField = TextFormField(
        obscureText: false,
        enabled: widget.isManager ? false : true,
        maxLines: 1,
        minLines: 1,
        style: textInputTextStyle,
        keyboardType: TextInputType.number,
        autovalidateMode: AutovalidateMode.always,
        controller: _pinController,
        decoration: InputDecoration(
          labelText: 'Postal code',
          enabledBorder:
              UnderlineInputBorder(borderSide: BorderSide(color: Colors.grey)),
          focusedBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.orange)),
        ),
        validator: (value) {
          if (isBookable || isActiveValidation)
            return validateText(value);
          else
            return null;
        },
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
      // void _addNewAdminRow() {
      //   bool insert = true;
      //   String newAdminPh = '+91' + _adminItemController.text;

      //   setState(() {
      //     if (adminsList.length != 0) {
      //       for (int i = 0; i < adminsList.length; i++) {
      //         if (adminsList[i] == (newAdminPh)) {
      //           insert = false;
      //           Utils.showMyFlushbar(
      //               context,
      //               Icons.info_outline,
      //               Duration(
      //                 seconds: 5,
      //               ),
      //               "Error",
      //               "Phone number already exists !!");
      //           break;
      //         }
      //         print("in for loop $insert");
      //         print(adminsList[i] == newAdminPh);
      //         print(newAdminPh);
      //         print(adminsList[i]);
      //       }
      //     }

      //     if (insert) adminsList.insert(0, newAdminPh);
      //     print("after foreach");

      //     //TODO: Smita - Update GS
      //   });
      // }

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

      saveRoute() {
        print("saving ");

        // String addressStr1;
        // addressStr1 =
        //     (_localityController.text != null) ? _localityController.text : "";
        // String addressStr2 =
        //     (_cityController.text != null) ? _cityController.text : "";
        // String addressStr3 =
        //     _stateController.text != null ? _stateController.text : "";
        // String addressStr4 =
        //     _countryController.text != null ? _countryController.text : "";

        String validationPh1;
        String validationPh2;
        bool isContactValid = true;
        bool timeFieldsValid = true;
        String errTimeFields;
        String errContactPhone;
        String errBookablePlace;
        if (isBookable) {
          errBookablePlace = validateMandatoryFieldsForBookable();
          if (Utils.isNotNullOrEmpty(errBookablePlace)) {
            Utils.showMyFlushbar(
                context,
                Icons.info_outline,
                Duration(
                  seconds: 4,
                ),
                errBookablePlace,
                "Please fill all mandatory details to allow Booking.");
            return;
          }
        }

        for (int i = 0; i < contactList.length; i++) {
          validationPh1 = (contactList[i].ph != null)
              ? Utils.validateMobileField(contactList[i].ph.substring(3))
              : null;
          validationPh2 = (contactList[i].altPhone != null)
              ? Utils.validateMobileField(contactList[i].altPhone.substring(3))
              : null;

          if (validationPh2 != null || validationPh1 != null) {
            isContactValid = false;
            errContactPhone =
                "The Contact information for managers is not valid.";
            break;
          }
        }
        errTimeFields = validateTimeFields();
        timeFieldsValid = (errTimeFields == null) ? true : false;
        if (_entityDetailsFormKey.currentState.validate() &&
            isContactValid &&
            timeFieldsValid) {
          Utils.showMyFlushbar(
              context,
              Icons.info_outline,
              Duration(
                seconds: 3,
              ),
              "Saving details!! ",
              "This would take just a moment.",
              null,
              Colors.white,
              true);

          _entityDetailsFormKey.currentState.save();

          //TODO: this hardcoding is to be removed, BookingFORM should be assigned dynamically by the Admin (either create or choose existing form)
          if (entity.type == EntityType.PLACE_TYPE_COVID19_VACCINATION_CENTER &&
              Utils.isNullOrEmpty(entity.forms)) {
            MetaForm mForm = MetaForm(
                id: COVID_VACCINATION_BOOKING_FORM_ID,
                name: COVID_BOOKING_FORM_NAME);
            if (entity.forms == null) {
              entity.forms = List<MetaForm>();
            }
            entity.forms.add(mForm);
          }

          upsertEntity(entity, _regNumController.text).then((value) {
            if (value) {
              // Assign admins to newly upserted entity
              assignAdminsFromList(entity.entityId, adminsList).then((value) {
                if (!value) {
                  Utils.showMyFlushbar(
                      context,
                      Icons.error,
                      Duration(
                        seconds: 4,
                      ),
                      "Admin details could not be saved!! ",
                      "Please verify the details and try again.",
                      Colors.red);
                } else {
                  //Update gs
                  _gs.updateMetaEntity(entity.getMetaEntity());

                  Utils.showMyFlushbar(
                      context,
                      Icons.check,
                      Duration(
                        seconds: 5,
                      ),
                      "Place details saved!",
                      'Be found by the customers, by marking it "ACTIVE".');
                }
              });
            } else {
              Utils.showMyFlushbar(
                  context,
                  Icons.error,
                  Duration(
                    seconds: 5,
                  ),
                  entityUpsertErrStr,
                  entityUpsertErrSubStr,
                  Colors.red);
            }
          });
        } else {
          Utils.showMyFlushbar(
              context,
              Icons.error,
              Duration(
                seconds: 10,
              ),
              ((errContactPhone == null) ? "" : (errContactPhone + "\n")) +
                  ((errTimeFields == null) ? "" : (errTimeFields + "\n")) +
                  missingInfoStr,
              missingInfoSubStr,
              Colors.red);
          setState(() {});
        }
      }

      backRoute() {
        Navigator.of(context)
            .push(PageAnimation.createRoute(ManageEntityListPage()));
      }

      processSaveWithTimer() async {
        var duration = new Duration(seconds: 0);
        return new Timer(duration, saveRoute);
      }

      processGoBackWithTimer() async {
        var duration = new Duration(seconds: 1);
        return new Timer(duration, backRoute);
      }

      // Future<void> showLocationAccessDialog() async {
      //   bool returnVal = await showDialog(
      //       barrierDismissible: false,
      //       context: context,
      //       builder: (_) => AlertDialog(
      //             titlePadding: EdgeInsets.fromLTRB(5, 10, 0, 0),
      //             contentPadding: EdgeInsets.all(0),
      //             actionsPadding: EdgeInsets.all(0),
      //             //buttonPadding: EdgeInsets.all(0),
      //             title: Column(
      //               crossAxisAlignment: CrossAxisAlignment.start,
      //               children: <Widget>[
      //                 Text(
      //                   locationPermissionMsg,
      //                   style: TextStyle(
      //                     fontSize: 15,
      //                     color: Colors.blueGrey[600],
      //                   ),
      //                 ),
      //                 verticalSpacer,

      //                 // myDivider,
      //               ],
      //             ),
      //             content: Divider(
      //               color: Colors.blueGrey[400],
      //               height: 1,
      //               //indent: 40,
      //               //endIndent: 30,
      //             ),

      //             //content: Text('This is my content'),
      //             actions: <Widget>[
      //               SizedBox(
      //                 height: 24,
      //                 child: RaisedButton(
      //                   elevation: 5,
      //                   autofocus: true,
      //                   focusColor: highlightColor,
      //                   splashColor: highlightColor,
      //                   color: Colors.white,
      //                   textColor: Colors.orange,
      //                   shape: RoundedRectangleBorder(
      //                       side: BorderSide(color: Colors.orange)),
      //                   child: Text('No'),
      //                   onPressed: () {
      //                     Utils.showMyFlushbar(
      //                         context,
      //                         Icons.info,
      //                         Duration(seconds: 3),
      //                         locationAccessDeniedStr,
      //                         locationAccessDeniedSubStr);
      //                     Navigator.of(_).pop(false);
      //                   },
      //                 ),
      //               ),
      //               SizedBox(
      //                 height: 24,
      //                 child: RaisedButton(
      //                   elevation: 10,
      //                   color: btnColor,
      //                   splashColor: highlightColor.withOpacity(.8),
      //                   textColor: Colors.white,
      //                   shape: RoundedRectangleBorder(
      //                     side: BorderSide(color: Colors.orange),
      //                   ),
      //                   child: Text('Yes'),
      //                   onPressed: () {
      //                     Navigator.of(_).pop(true);
      //                   },
      //                 ),
      //               ),
      //             ],
      //           ));

      //   if (returnVal) {
      //     print("in true, opening app settings");
      //     Utils.openAppSettings();
      //   } else {
      //     print("nothing to do, user denied location access");
      //     print(returnVal);
      //   }
      // }

      void useCurrLocation() {
        Position pos;
        Utils.getCurrLocation().then((value) {
          pos = value;
          if (pos == null)
            Utils.showLocationAccessDialog(context, locationPermissionMsg);
          _getAddressFromLatLng(pos);
        });
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
                        bookable,
                        style: TextStyle(
                          fontSize: 15,
                          color: Colors.blueGrey[600],
                        ),
                      ),
                      verticalSpacer,
                      Text(
                        'Are you sure you make the Place "Bookable"?',
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
          entity.isBookable = true;
        } else {
          setState(() {
            isBookable = false;
          });
          entity.isBookable = false;
        }
      }

      validateLatLon() {
        bool retVal;
        if (Utils.isStrNullOrEmpty(_latController.text))
          retVal = false;
        else
          retVal = true;
        return retVal;
      }

      validateAllFields() {
        bool retVal;
        if (_entityDetailsFormKey.currentState.validate())
          retVal = true;
        else
          retVal = false;
        return retVal;
      }

      String _msg;

      double rowWidth = MediaQuery.of(context).size.width * .9;
      return MaterialApp(
        debugShowCheckedModeBanner: false,
        // title: 'Add child entities',
        theme: ThemeData.light().copyWith(),
        home: WillPopScope(
          child: Scaffold(
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
                      backgroundColor: Colors.cyan[200],
                      boxShadows: [
                        BoxShadow(
                            color: Colors.cyan,
                            offset: Offset(0.0, 2.0),
                            blurRadius: 3.0)
                      ],
                      isDismissible: true,
                      //duration: Duration(seconds: 4),
                      icon: Icon(
                        Icons.cancel,
                        color: Colors.blueGrey[90],
                      ),
                      showProgressIndicator: true,
                      progressIndicatorBackgroundColor: Colors.blueGrey[900],
                      progressIndicatorValueColor:
                          new AlwaysStoppedAnimation<Color>(Colors.cyan[500]),
                      routeBlur: 10.0,
                      titleText: Text(
                        "Are you sure you want to leave this page?",
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16.0,
                            color: Colors.blueGrey[700],
                            fontFamily: "ShadowsIntoLightTwo"),
                      ),
                      messageText: Text(
                        "The changes you made might be lost, if not saved.",
                        style: TextStyle(
                            fontSize: 12.0,
                            color: Colors.blueGrey[800],
                            fontFamily: "ShadowsIntoLightTwo"),
                      ),

                      mainButton: Column(
                        children: <Widget>[
                          FlatButton(
                            padding: EdgeInsets.all(0),
                            onPressed: () {
                              flushStatus = "Empty";
                              flush.dismiss(false); // result = true
                            },
                            child: Text(
                              "No",
                              style: TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                          FlatButton(
                            padding: EdgeInsets.all(0),
                            onPressed: () {
                              flushStatus = "Empty";
                              flush.dismiss(true); // result = true
                            },
                            child: Text(
                              "Yes",
                              style: TextStyle(color: Colors.blueGrey[700]),
                            ),
                          ),
                        ],
                      ),
                    );
                    // ..onStatusChanged = (FlushbarStatus status) {
                    //     print("FlushbarStatus-------$status");
                    //     if (status == FlushbarStatus.IS_APPEARING)
                    //       flushStatus = "Showing";
                    //     if (status == FlushbarStatus.DISMISSED)
                    //       flushStatus = "Empty";
                    //     print("gfdfgdfg");
                    //   };

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
              title: Text(Utils.getEntityTypeDisplayName(entity.type),
                  style: drawerdefaultTextStyle),
            ),
            body: Center(
              child: new SafeArea(
                top: true,
                bottom: true,
                child: new Form(
                  key: _entityDetailsFormKey,
                  child: new ListView(
                    padding: const EdgeInsets.all(8.0),
                    children: <Widget>[
                      Container(
                        decoration: BoxDecoration(
                            border: Border.all(color: containerColor),
                            color: Colors.grey[50],
                            shape: BoxShape.rectangle,
                            borderRadius:
                                BorderRadius.all(Radius.circular(5.0))),
                        foregroundDecoration: widget.isManager
                            ? BoxDecoration(
                                color: Colors.grey[50],
                                backgroundBlendMode: BlendMode.saturation,
                              )
                            : BoxDecoration(),
                        margin: EdgeInsets.all(5),
                        padding: EdgeInsets.all(0),
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
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              .94,
                                          decoration: darkContainer,
                                          padding: EdgeInsets.all(2.0),
                                          child: Row(
                                            children: <Widget>[
                                              Expanded(
                                                child: Text(basicInfoStr,
                                                    style: buttonXSmlTextStyle),
                                              ),
                                            ],
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
                                      advBookingInDays,
                                      maxpeopleInASlot,
                                      maxTokenPerDay,
                                      whatsappPhone,
                                      callingPhone,
                                      emailId,
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
                        margin: EdgeInsets.all(5),
                        padding: EdgeInsets.all(0),
                        decoration: BoxDecoration(
                            border: Border.all(color: containerColor),
                            color: Colors.grey[50],
                            shape: BoxShape.rectangle,
                            borderRadius:
                                BorderRadius.all(Radius.circular(5.0))),
                        foregroundDecoration: widget.isManager
                            ? BoxDecoration(
                                color: Colors.grey[50],
                                backgroundBlendMode: BlendMode.saturation,
                              )
                            : BoxDecoration(),
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
                                            "Payment Details",
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
                                                child: Text(paymentInfoStr,
                                                    style: buttonXSmlTextStyle),
                                              ),
                                            ],
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
                                  upiIdField,
                                  //  upiPhone,
                                  // upiQrCodeField,
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
                        margin: EdgeInsets.all(5),
                        padding: EdgeInsets.all(0),
                        foregroundDecoration: widget.isManager
                            ? BoxDecoration(
                                color: Colors.grey[50],
                                backgroundBlendMode: BlendMode.saturation,
                              )
                            : BoxDecoration(),
                        decoration: BoxDecoration(
                            border: Border.all(color: containerColor),
                            color: Colors.grey[50],
                            shape: BoxShape.rectangle,
                            borderRadius:
                                BorderRadius.all(Radius.circular(5.0))),
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
                                            "Offer Details",
                                            style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 15),
                                          ),
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
                                                child: Text(offerInfoStr,
                                                    style: buttonXSmlTextStyle),
                                              ),
                                            ],
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
                                      messageField,
                                      couponField,
                                      Row(
                                        children: <Widget>[
                                          Expanded(child: startDateField),
                                          Expanded(child: endDateField),
                                        ],
                                      ),
                                      Row(
                                        children: [
                                          Container(
                                              width: MediaQuery.of(context)
                                                      .size
                                                      .width *
                                                  .3,
                                              child: FlatButton(
                                                //elevation: 20,
                                                color: Colors.transparent,
                                                splashColor: highlightColor,
                                                textColor: btnColor,
                                                shape: RoundedRectangleBorder(
                                                    side: BorderSide(
                                                        color: btnColor)),
                                                child: Text(
                                                  'Clear',
                                                  textAlign: TextAlign.center,
                                                ),
                                                onPressed: clearOfferDetail,
                                              )),
                                        ],
                                      )
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
                        margin: EdgeInsets.all(5),
                        padding: EdgeInsets.all(0),
                        foregroundDecoration: widget.isManager
                            ? BoxDecoration(
                                color: Colors.grey[50],
                                backgroundBlendMode: BlendMode.saturation,
                              )
                            : BoxDecoration(),
                        decoration: BoxDecoration(
                            border: Border.all(color: containerColor),
                            color: Colors.grey[50],
                            shape: BoxShape.rectangle,
                            borderRadius:
                                BorderRadius.all(Radius.circular(5.0))),
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
                                            "Current Location Details",
                                            style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 15),
                                          ),
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
                                                child: Text(locationInfoStr,
                                                    style: buttonXSmlTextStyle),
                                              ),
                                            ],
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
                                  Column(children: <Widget>[
                                    Container(
                                      padding: EdgeInsets.all(4),
                                      width: MediaQuery.of(context).size.width *
                                          .95,
                                      child: RichText(
                                          text: TextSpan(
                                              style: highlightSubTextStyle,
                                              children: <TextSpan>[
                                            TextSpan(
                                                text: pressUseCurrentLocation),
                                            TextSpan(
                                                text: whyLocationIsRequired),
                                          ])),
                                    ),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceAround,
                                      children: <Widget>[
                                        latField,
                                        lonField,
                                      ],
                                    ),
                                    verticalSpacer,
                                  ]),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceAround,
                                    children: <Widget>[
                                      clearBtn,
                                      Container(
                                        width: rowWidth * .58,
                                        child: RaisedButton(
                                            elevation: 10,
                                            color: btnColor,
                                            splashColor: highlightColor,
                                            textColor: Colors.white,
                                            shape: RoundedRectangleBorder(
                                                side: BorderSide(
                                                    color: btnColor)),
                                            child: Text(
                                              userCurrentLoc,
                                              textAlign: TextAlign.center,
                                            ),
                                            onPressed: () {
                                              if (widget.isManager) {
                                                return;
                                              } else {
                                                useCurrLocation();
                                              }
                                            }),
                                      ),
                                    ],
                                  ),
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
                        margin: EdgeInsets.all(5),
                        padding: EdgeInsets.all(0),
                        foregroundDecoration: widget.isManager
                            ? BoxDecoration(
                                color: Colors.grey[50],
                                backgroundBlendMode: BlendMode.saturation,
                              )
                            : BoxDecoration(),
                        decoration: BoxDecoration(
                            border: Border.all(color: containerColor),
                            color: Colors.grey[50],
                            shape: BoxShape.rectangle,
                            borderRadius:
                                BorderRadius.all(Radius.circular(5.0))),
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
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              .94,
                                          decoration: darkContainer,
                                          padding: EdgeInsets.all(2.0),
                                          child: Row(
                                            children: <Widget>[
                                              Expanded(
                                                child: Text(addressInfoStr,
                                                    style: buttonXSmlTextStyle),
                                              ),
                                            ],
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
                      // Container(
                      //   margin: EdgeInsets.all(5),
                      //   padding: EdgeInsets.all(0),
                      //   decoration: BoxDecoration(
                      //       border: Border.all(color: containerColor),
                      //       color: Colors.grey[50],
                      //       shape: BoxShape.rectangle,
                      //       borderRadius:
                      //           BorderRadius.all(Radius.circular(5.0))),
                      //   // padding: EdgeInsets.all(5.0),
                      //   child: Column(
                      //     crossAxisAlignment: CrossAxisAlignment.start,
                      //     children: <Widget>[
                      //       Column(
                      //         children: <Widget>[
                      //           Container(
                      //             //padding: EdgeInsets.only(left: 5),
                      //             decoration: darkContainer,
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
                      //                       "Assign an Admin",
                      //                       style: TextStyle(
                      //                           color: Colors.white,
                      //                           fontSize: 15),
                      //                     ),
                      //                     SizedBox(width: 5),
                      //                   ],
                      //                 ),
                      //                 // trailing: IconButton(
                      //                 //   icon: Icon(Icons.add_circle,
                      //                 //       color: highlightColor, size: 40),
                      //                 //   onPressed: () {
                      //                 //     addNewAdminRow();
                      //                 //   },
                      //                 // ),
                      //                 backgroundColor: Colors.blueGrey[500],
                      //                 children: <Widget>[
                      //                   new Container(
                      //                     width: MediaQuery.of(context)
                      //                             .size
                      //                             .width *
                      //                         .94,
                      //                     decoration: darkContainer,
                      //                     padding: EdgeInsets.all(2.0),
                      //                     child: Row(
                      //                       children: <Widget>[
                      //                         Expanded(
                      //                           child: Text(adminInfoStr,
                      //                               style: buttonXSmlTextStyle),
                      //                         ),
                      //                       ],
                      //                     ),
                      //                   ),
                      //                 ],
                      //               ),
                      //             ),
                      //           ),
                      //           //Add Admins list
                      //           Column(
                      //             children: <Widget>[
                      //               Container(
                      //                 margin: EdgeInsets.all(4),
                      //                 padding: EdgeInsets.fromLTRB(0, 0, 4, 0),
                      //                 height:
                      //                     MediaQuery.of(context).size.width *
                      //                         .18,
                      //                 decoration: BoxDecoration(
                      //                     border:
                      //                         Border.all(color: borderColor),
                      //                     color: Colors.white,
                      //                     shape: BoxShape.rectangle,
                      //                     borderRadius: BorderRadius.all(
                      //                         Radius.circular(5.0))),
                      //                 child: Row(
                      //                   // mainAxisAlignment: MainAxisAlignment.end,
                      //                   children: <Widget>[
                      //                     Expanded(
                      //                       child: adminInputField,
                      //                     ),
                      //                     Container(
                      //                       padding:
                      //                           EdgeInsets.fromLTRB(0, 0, 0, 0),
                      //                       width: MediaQuery.of(context)
                      //                               .size
                      //                               .width *
                      //                           .1,
                      //                       height: MediaQuery.of(context)
                      //                               .size
                      //                               .width *
                      //                           .1,
                      //                       child: IconButton(
                      //                           padding: EdgeInsets.all(0),
                      //                           icon: Icon(Icons.person_add,
                      //                               color: highlightColor,
                      //                               size: 38),
                      //                           onPressed: () {
                      //                             if (_adminItemController
                      //                                         .text ==
                      //                                     null ||
                      //                                 _adminItemController
                      //                                     .text.isEmpty) {
                      //                               Utils.showMyFlushbar(
                      //                                   context,
                      //                                   Icons.info_outline,
                      //                                   Duration(
                      //                                     seconds: 4,
                      //                                   ),
                      //                                   "Something Missing ..",
                      //                                   "Please enter Phone number !!");
                      //                             } else {
                      //                               bool result = adminPhoneKey
                      //                                   .currentState
                      //                                   .validate();
                      //                               if (result) {
                      //                                 _addNewAdminRow();
                      //                                 _adminItemController
                      //                                     .text = "";
                      //                               } else {
                      //                                 Utils.showMyFlushbar(
                      //                                     context,
                      //                                     Icons.info_outline,
                      //                                     Duration(
                      //                                       seconds: 5,
                      //                                     ),
                      //                                     "Oops!! Seems like the phone number is not valid",
                      //                                     "Please check and try again !!");
                      //                               }
                      //                             }
                      //                           }),
                      //                     ),
                      //                   ],
                      //                 ),
                      //               ),
                      //               ListView.builder(
                      //                 shrinkWrap: true,
                      //                 //scrollDirection: Axis.vertical,
                      //                 itemBuilder:
                      //                     (BuildContext context, int index) {
                      //                   return new Column(
                      //                       children: adminsList
                      //                           .map(_buildServiceItem)
                      //                           .toList());
                      //                 },
                      //                 itemCount: 1,
                      //               ),
                      //             ],
                      //           ),
                      //         ],
                      //       ),
                      //     ],
                      //   ),
                      // ),

                      // SizedBox(
                      //   height: 7,
                      // ),
                      //THIS CONTAINER
                      // Container(
                      //   margin: EdgeInsets.all(5),
                      //   padding: EdgeInsets.all(0),
                      //   decoration: BoxDecoration(
                      //       border: Border.all(color: containerColor),
                      //       color: Colors.white,
                      //       shape: BoxShape.rectangle,
                      //       borderRadius:
                      //           BorderRadius.all(Radius.circular(5.0))),
                      //   // padding: EdgeInsets.all(5.0),
                      //   child: Column(
                      //     crossAxisAlignment: CrossAxisAlignment.start,
                      //     children: <Widget>[
                      //       Column(
                      //         children: <Widget>[
                      //           Container(
                      //             //padding: EdgeInsets.only(left: 5),
                      //             decoration: darkContainer,
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
                      //                       "Add a Manager",
                      //                       style: TextStyle(
                      //                           color: Colors.white,
                      //                           fontSize: 15),
                      //                     ),
                      //                     SizedBox(width: 5),
                      //                   ],
                      //                 ),
                      //                 backgroundColor: Colors.blueGrey[500],

                      //                 children: <Widget>[
                      //                   new Container(
                      //                     width: MediaQuery.of(context)
                      //                             .size
                      //                             .width *
                      //                         .94,
                      //                     decoration: darkContainer,
                      //                     padding: EdgeInsets.all(2.0),
                      //                     child: Row(
                      //                       children: <Widget>[
                      //                         Expanded(
                      //                           child: Text(contactInfoStr,
                      //                               style: buttonXSmlTextStyle),
                      //                         ),
                      //                       ],
                      //                     ),
                      //                   ),
                      //                 ],
                      //               ),
                      //             ),
                      //           ),
                      //           Container(
                      //             color: Colors.grey[100],
                      //             padding:
                      //                 const EdgeInsets.fromLTRB(8.0, 0, 8, 0),
                      //             child: Row(
                      //               mainAxisAlignment: MainAxisAlignment.end,
                      //               children: <Widget>[
                      //                 // Expanded(
                      //                 //   child: roleType,
                      //                 // ),
                      //                 Container(
                      //                   child: IconButton(
                      //                     icon: Icon(Icons.person_add,
                      //                         color: highlightColor, size: 40),
                      //                     onPressed: () {
                      //                       _addNewContactRow();
                      //                     },
                      //                   ),
                      //                 ),
                      //               ],
                      //             ),
                      //           ),
                      //           (_msg != null)
                      //               ? Text(
                      //                   _msg,
                      //                   style: errorTextStyle,
                      //                 )
                      //               : Container(),
                      //           if (!Utils.isNullOrEmpty(contactList))
                      //             Column(children: contactRowWidgets),
                      //           // Expanded(
                      //           //   child: ListView.builder(
                      //           //       itemCount: contactList.length,
                      //           //       itemBuilder:
                      //           //           (BuildContext context, int index) {
                      //           //         return Column(
                      //           //             children: contactList
                      //           //                 .map(buildContactItem)
                      //           //                 .toList());
                      //           //       }),
                      //           // ),
                      //           // Column(
                      //           //   children: <Widget>[
                      //           //     new Expanded(
                      //           //       child: ListView.builder(
                      //           //         //  controller: _childScrollController,
                      //           //         reverse: true,
                      //           //         shrinkWrap: true,
                      //           //         // itemExtent: itemSize,
                      //           //         //scrollDirection: Axis.vertical,
                      //           //         itemBuilder:
                      //           //             (BuildContext context, int index) {
                      //           //           return ContactRow(
                      //           //             contact: contactList[index],
                      //           //             entity: entity,
                      //           //             list: contactList,
                      //           //           );
                      //           //         },
                      //           //         itemCount: contactList.length,
                      //           //       ),
                      //           //     ),
                      //           //   ],
                      //           // ),
                      //           //
                      //         ],
                      //       ),
                      //     ],
                      //   ),
                      // ),

                      Container(
                        width: MediaQuery.of(context).size.width * .9,
                        margin: EdgeInsets.all(5),
                        padding: EdgeInsets.all(0),
                        foregroundDecoration: widget.isManager
                            ? BoxDecoration(
                                color: Colors.grey[50],
                                backgroundBlendMode: BlendMode.saturation,
                              )
                            : BoxDecoration(),
                        // padding: EdgeInsets.symmetric(horizontal: 8, vertical: 0),
                        decoration: BoxDecoration(
                            border: Border.all(color: containerColor),
                            color: Colors.grey[50],
                            shape: BoxShape.rectangle,
                            borderRadius:
                                BorderRadius.all(Radius.circular(5.0))),
                        child: Column(
                          mainAxisSize: MainAxisSize.max,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Column(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              mainAxisSize: MainAxisSize.max,
                              children: <Widget>[
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Container(
                                      alignment: Alignment.centerLeft,
                                      padding:
                                          EdgeInsets.fromLTRB(10, 0, 10, 0),
                                      width: rowWidth * .4,
                                      child: FlatButton(
                                          visualDensity: VisualDensity.compact,
                                          padding: EdgeInsets.all(0),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: <Widget>[
                                              Text('Public',
                                                  style:
                                                      TextStyle(fontSize: 14)),
                                              SizedBox(
                                                width: MediaQuery.of(context)
                                                        .size
                                                        .width *
                                                    .1,
                                                // height: MediaQuery.of(context)
                                                //         .size
                                                //         .height *
                                                //     .02,
                                                child: Icon(
                                                  Icons.info,
                                                  color: Colors.blueGrey[600],
                                                  size: 17,
                                                ),
                                              ),
                                            ],
                                          ),
                                          onPressed: () {
                                            if (!_isExpanded) {
                                              setState(() {
                                                _publicExpandClick = true;
                                                _isExpanded = true;
                                                _margin = EdgeInsets.fromLTRB(
                                                    0, 0, 0, 8);
                                                _width = MediaQuery.of(context)
                                                        .size
                                                        .width *
                                                    .9;
                                                _text = AutoSizeText(publicInfo,
                                                    minFontSize: 8,
                                                    maxFontSize: 14,
                                                    style:
                                                        textBotSheetTextStyle);

                                                _height = 60;
                                              });
                                            } else {
                                              //if bookable info is being shown
                                              if (_publicExpandClick) {
                                                setState(() {
                                                  _width = 0;
                                                  _height = 0;
                                                  _isExpanded = false;
                                                  _publicExpandClick = false;
                                                });
                                              } else {
                                                setState(() {
                                                  _publicExpandClick = true;
                                                  _activeExpandClick = false;
                                                  _bookExpandClick = false;
                                                  _isExpanded = true;
                                                  _margin = EdgeInsets.fromLTRB(
                                                      0, 0, 0, 8);
                                                  _width =
                                                      MediaQuery.of(context)
                                                              .size
                                                              .width *
                                                          .9;
                                                  _text = AutoSizeText(
                                                      publicInfo,
                                                      minFontSize: 8,
                                                      maxFontSize: 14,
                                                      style:
                                                          textBotSheetTextStyle);

                                                  _height = 60;
                                                });
                                              }
                                            }
                                          }),
                                    ),
                                    SizedBox(
                                      height:
                                          MediaQuery.of(context).size.height *
                                              .08,
                                      width: MediaQuery.of(context).size.width *
                                          .2,
                                      child: Transform.scale(
                                        scale: .7,
                                        alignment: Alignment.centerRight,
                                        child: Switch(
                                          materialTapTargetSize:
                                              MaterialTapTargetSize.shrinkWrap,
                                          value: isPublic,

                                          onChanged: (value) {
                                            if (widget.isManager) {
                                              return;
                                            } else {
                                              setState(() {
                                                isPublic = value;
                                                entity.isPublic = value;
                                                print(isPublic);
                                                //}
                                              });
                                            }
                                          },
                                          // activeTrackColor: Colors.green,
                                          activeColor: Colors.green,
                                          inactiveThumbColor: Colors.grey[300],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Container(
                                      alignment: Alignment.centerLeft,
                                      padding:
                                          EdgeInsets.fromLTRB(10, 0, 10, 0),
                                      width: rowWidth * .4,
                                      child: FlatButton(
                                          visualDensity: VisualDensity.compact,
                                          padding: EdgeInsets.all(0),
                                          child: Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: <Widget>[
                                                Text('Bookable',
                                                    style: TextStyle(
                                                        fontSize: 14)),
                                                SizedBox(
                                                  width: MediaQuery.of(context)
                                                          .size
                                                          .width *
                                                      .1,
                                                  // height: MediaQuery.of(context)
                                                  //         .size
                                                  //         .height *
                                                  //     .02,
                                                  child: Icon(Icons.info,
                                                      color:
                                                          Colors.blueGrey[600],
                                                      size: 17),
                                                ),
                                              ]),
                                          onPressed: () {
                                            if (!_isExpanded) {
                                              setState(() {
                                                _bookExpandClick = true;
                                                _isExpanded = true;
                                                _margin = EdgeInsets.fromLTRB(
                                                    0, 0, 0, 8);
                                                _width = MediaQuery.of(context)
                                                        .size
                                                        .width *
                                                    .9;
                                                _text = AutoSizeText(
                                                    bookableInfo,
                                                    minFontSize: 8,
                                                    maxFontSize: 14,
                                                    style:
                                                        textBotSheetTextStyle);
                                                _height = 60;
                                              });
                                            } else {
                                              //if bookable info is being shown
                                              if (_bookExpandClick) {
                                                setState(() {
                                                  _width = 0;
                                                  _height = 0;
                                                  _isExpanded = false;
                                                  _bookExpandClick = false;
                                                });
                                              } else {
                                                setState(() {
                                                  _publicExpandClick = false;
                                                  _activeExpandClick = false;
                                                  _bookExpandClick = true;
                                                  _isExpanded = true;
                                                  _margin = EdgeInsets.fromLTRB(
                                                      0, 0, 0, 8);
                                                  _width =
                                                      MediaQuery.of(context)
                                                              .size
                                                              .width *
                                                          .9;
                                                  _text = AutoSizeText(
                                                      bookableInfo,
                                                      minFontSize: 8,
                                                      maxFontSize: 14,
                                                      style:
                                                          textBotSheetTextStyle);

                                                  _height = 60;
                                                });
                                              }
                                            }
                                          }),
                                    ),
                                    SizedBox(
                                      height:
                                          MediaQuery.of(context).size.height *
                                              .08,
                                      width: MediaQuery.of(context).size.width *
                                          .2,
                                      child: Transform.scale(
                                        scale: .7,
                                        alignment: Alignment.centerRight,
                                        child: Switch(
                                          materialTapTargetSize:
                                              MaterialTapTargetSize.shrinkWrap,
                                          value: isBookable,
                                          onChanged: (value) {
                                            if (widget.isManager) {
                                              return;
                                            } else {
                                              isBookable = value;
                                              if (value) {
                                                showConfirmationDialog();
                                                //Check if all mandatory fields for being bookable are not empty.
                                                String errMsg =
                                                    validateMandatoryFieldsForBookable();
                                                if (Utils.isNotNullOrEmpty(
                                                    errMsg)) {
                                                  Utils.showMyFlushbar(
                                                      context,
                                                      Icons.info_outline,
                                                      Duration(
                                                        seconds: 4,
                                                      ),
                                                      errMsg,
                                                      "Please fill all mandatory details to allow Booking.");
                                                  isBookable = !value;
                                                  return;
                                                }
                                              }

                                              entity.isBookable = value;

                                              setState(() {});
                                            }
                                          },
                                          // activeTrackColor: Colors.green,
                                          activeColor: Colors.green,
                                          inactiveThumbColor: Colors.grey[300],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Container(
                                      alignment: Alignment.centerLeft,
                                      padding:
                                          EdgeInsets.fromLTRB(10, 0, 10, 0),
                                      width: rowWidth * .4,
                                      child: FlatButton(
                                        visualDensity: VisualDensity.compact,
                                        padding: EdgeInsets.all(0),
                                        child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: <Widget>[
                                              Text('Active',
                                                  style:
                                                      TextStyle(fontSize: 14)),
                                              SizedBox(
                                                width: MediaQuery.of(context)
                                                        .size
                                                        .width *
                                                    .1,
                                                // height: MediaQuery.of(context)
                                                //         .size
                                                //         .height *
                                                //     .02,
                                                child: Icon(Icons.info,
                                                    color: Colors.blueGrey[600],
                                                    size: 17),
                                              ),
                                            ]),
                                        onPressed: () {
                                          if (!_isExpanded) {
                                            setState(() {
                                              _activeExpandClick = true;
                                              _isExpanded = true;
                                              _margin = EdgeInsets.fromLTRB(
                                                  0, 0, 0, 8);
                                              _width = MediaQuery.of(context)
                                                      .size
                                                      .width *
                                                  .9;
                                              _text = AutoSizeText(activeDef,
                                                  minFontSize: 8,
                                                  maxFontSize: 14,
                                                  style: textBotSheetTextStyle);

                                              _height = 60;
                                            });
                                          } else {
                                            //if bookable info is being shown
                                            if (_activeExpandClick) {
                                              setState(() {
                                                _width = 0;
                                                _height = 0;
                                                _isExpanded = false;
                                                _activeExpandClick = false;
                                              });
                                            } else {
                                              setState(() {
                                                _publicExpandClick = false;
                                                _activeExpandClick = true;
                                                _bookExpandClick = false;
                                                _isExpanded = true;
                                                _margin = EdgeInsets.fromLTRB(
                                                    0, 0, 0, 8);
                                                _width = MediaQuery.of(context)
                                                        .size
                                                        .width *
                                                    .9;
                                                _text = AutoSizeText(activeDef,
                                                    minFontSize: 8,
                                                    maxFontSize: 14,
                                                    style:
                                                        textBotSheetTextStyle);

                                                _height = 60;
                                              });
                                            }
                                          }
                                        },
                                      ),
                                    ),
                                    SizedBox(
                                      height:
                                          MediaQuery.of(context).size.height *
                                              .08,
                                      width: MediaQuery.of(context).size.width *
                                          .2,
                                      child: Transform.scale(
                                        scale: .7,
                                        alignment: Alignment.centerRight,
                                        child: Switch(
                                          materialTapTargetSize:
                                              MaterialTapTargetSize.shrinkWrap,
                                          value: isActive,
                                          onChanged: (value) {
                                            setState(() {
                                              if (widget.isManager) {
                                                return;
                                              } else {
                                                if (value) {
                                                  isActiveValidation = true;
                                                  bool retVal = false;
                                                  bool locValid = false;
                                                  if (validateAllFields())
                                                    retVal = true;
                                                  if (validateLatLon())
                                                    locValid = true;

                                                  if (!locValid || !retVal) {
                                                    if (!locValid) {
                                                      Utils.showMyFlushbar(
                                                          context,
                                                          Icons.info_outline,
                                                          Duration(
                                                            seconds: 6,
                                                          ),
                                                          shouldSetLocation,
                                                          pressUseCurrentLocation);
                                                    } else if (!retVal) {
                                                      //Show flushbar with info that fields has invalid data
                                                      Utils.showMyFlushbar(
                                                          context,
                                                          Icons.info_outline,
                                                          Duration(
                                                            seconds: 6,
                                                          ),
                                                          "Missing Information!!",
                                                          'Making a place "ACTIVE" requires all mandatory information to be filled in. Please provide the details and Save.');
                                                    }
                                                  } else {
                                                    isActiveValidation = false;
                                                    isActive = value;
                                                    entity.isActive = value;
                                                    print(isActive);
                                                  }
                                                } else {
                                                  isActive = value;
                                                  isActiveValidation = false;
                                                  entity.isActive = value;
                                                  print(isActive);
                                                }
                                              }
                                            });
                                          },
                                          // activeTrackColor: Colors.green,
                                          activeColor: Colors.green,
                                          inactiveThumbColor: Colors.grey[300],
                                        ),
                                      ),
                                    )
                                  ],
                                ),
                              ],
                            ),
                            AnimatedContainer(
                              padding: EdgeInsets.all(5),
                              margin: EdgeInsets.all(5),
                              // Use the properties stored in the State class.
                              width: _width,
                              height: _height,
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color: Colors.transparent,
                                border: Border.all(color: Colors.blueGrey),
                                borderRadius: _borderRadius,
                              ),
                              // Define how long the animation should take.
                              duration: Duration(seconds: 1),
                              // Provide an optional curve to make the animation feel smoother.
                              curve: Curves.easeInOutCirc,
                              child: Center(child: _text),
                            ),
                          ],
                        ),
                      ),

                      SizedBox(
                        height: 7,
                      ),
                      Container(
                        width: MediaQuery.of(context).size.width * .9,
                        margin: EdgeInsets.all(5),
                        padding: EdgeInsets.all(0),
                        foregroundDecoration: widget.isManager
                            ? BoxDecoration(
                                color: Colors.grey[50],
                                backgroundBlendMode: BlendMode.saturation,
                              )
                            : BoxDecoration(),
                        // padding: EdgeInsets.symmetric(horizontal: 8, vertical: 0),
                        decoration: BoxDecoration(
                            border: Border.all(color: containerColor),
                            color: Colors.grey[50],
                            shape: BoxShape.rectangle,
                            borderRadius:
                                BorderRadius.all(Radius.circular(5.0))),
                        child: Column(
                          mainAxisSize: MainAxisSize.max,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Column(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              mainAxisSize: MainAxisSize.max,
                              children: <Widget>[
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Container(
                                      alignment: Alignment.centerLeft,
                                      padding:
                                          EdgeInsets.fromLTRB(10, 0, 10, 0),
                                      width: rowWidth * .7,
                                      child: MaterialButton(
                                          visualDensity: VisualDensity.compact,
                                          padding: EdgeInsets.all(0),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: <Widget>[
                                              Container(
                                                //  width: rowWidth * .5,
                                                child: Text(
                                                    'Online Consultation',
                                                    style: TextStyle(
                                                        fontSize: 14)),
                                              ),
                                              SizedBox(
                                                width: rowWidth * .1,
                                                child: Icon(
                                                  Icons.info,
                                                  color: Colors.blueGrey[600],
                                                  size: 17,
                                                ),
                                              ),
                                            ],
                                          ),
                                          onPressed: () {
                                            if (!_isVideoExpanded) {
                                              setState(() {
                                                _margin = EdgeInsets.fromLTRB(
                                                    0, 0, 0, 8);
                                                _videoWidth =
                                                    MediaQuery.of(context)
                                                            .size
                                                            .width *
                                                        .9;
                                                _videoText = AutoSizeText(
                                                    videoInfo,
                                                    minFontSize: 8,
                                                    maxFontSize: 14,
                                                    style:
                                                        textBotSheetTextStyle);

                                                _videoHeight = 60;
                                              });
                                            } else {
                                              setState(() {
                                                _isVideoExpanded = false;
                                                _videoWidth = 0;
                                                _videoHeight = 0;
                                              });
                                            }
                                          }),
                                    ),
                                    SizedBox(
                                      height:
                                          MediaQuery.of(context).size.height *
                                              .08,
                                      width: MediaQuery.of(context).size.width *
                                          .2,
                                      child: Transform.scale(
                                        scale: .7,
                                        alignment: Alignment.centerRight,
                                        child: Switch(
                                          materialTapTargetSize:
                                              MaterialTapTargetSize.shrinkWrap,
                                          value: isVideoChatEnabled,

                                          onChanged: (value) {
                                            if (widget.isManager) {
                                              return;
                                            } else {
                                              isVideoChatEnabled = value;
                                              entity.enableVideoChat = value;
                                              if (value) {
                                                String msg =
                                                    validateFieldsForOnlineConsultation();
                                                if (Utils.isNotNullOrEmpty(
                                                    msg)) {
                                                  if (whatsappPhoneKey
                                                          .currentState !=
                                                      null) {
                                                    whatsappPhoneKey
                                                        .currentState
                                                        .validate();
                                                  }
                                                  Utils.showMyFlushbar(
                                                      context,
                                                      Icons.info_outline,
                                                      Duration(
                                                        seconds: 6,
                                                      ),
                                                      msg,
                                                      "");
                                                  isVideoChatEnabled = !value;
                                                  entity.enableVideoChat =
                                                      !value;
                                                }
                                              }

                                              setState(() {});
                                            }
                                          },
                                          // activeTrackColor: Colors.green,
                                          activeColor: Colors.green,
                                          inactiveThumbColor: Colors.grey[300],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            AnimatedContainer(
                              // Use the properties stored in the State class.
                              width: _videoWidth,
                              height: _videoHeight,
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color: Colors.transparent,
                                border: Border.all(color: Colors.blueGrey),
                                borderRadius: _borderRadius,
                              ),
                              // Define how long the animation should take.
                              duration: Duration(seconds: 1),
                              // Provide an optional curve to make the animation feel smoother.
                              curve: Curves.easeInOutCirc,
                              child: Center(child: _videoText),
                            ),
                          ],
                        ),
                      ),

                      SizedBox(
                        height: 7,
                      ),
                      Builder(
                        builder: (context) => Card(
                          elevation: 8,
                          child: GestureDetector(
                            onTap: () {
                              if (widget.isManager) {
                                return;
                              } else {
                                print("FlushbarStatus-------");
                                processSaveWithTimer();
                              }
                            },
                            child: Container(
                              foregroundDecoration: widget.isManager
                                  ? BoxDecoration(
                                      color: Colors.grey[50],
                                      backgroundBlendMode: BlendMode.saturation,
                                    )
                                  : BoxDecoration(),
                              padding: EdgeInsets.zero,
                              margin: EdgeInsets.zero,
                              height: 40,
                              decoration: new BoxDecoration(
                                  gradient: new LinearGradient(
                                      colors: [
                                        Colors.cyan[400],
                                        Colors.cyan[700]
                                      ],
                                      begin: const FractionalOffset(0.0, 0.0),
                                      end: const FractionalOffset(1.0, 0.0),
                                      stops: [0.0, 1.0],
                                      tileMode: TileMode.clamp),
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(5))),
                              // width: MediaQuery.of(context).size.width * .35,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: <Widget>[
                                  Icon(
                                    Icons.save,
                                    size: 25,
                                    color: Colors.white,
                                  ),
                                  SizedBox(
                                    width: 10,
                                  ),
                                  Text(
                                    'Save',
                                    style: buttonMedTextStyle,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),

                      Builder(
                        builder: (context) => Container(
                            margin: EdgeInsets.fromLTRB(6, 15, 6, 15),
                            height: 40,
                            foregroundDecoration: widget.isManager
                                ? BoxDecoration(
                                    color: Colors.grey[50],
                                    backgroundBlendMode: BlendMode.saturation,
                                  )
                                : BoxDecoration(),
                            decoration: new BoxDecoration(
                                border: Border.all(color: Colors.teal[200]),
                                borderRadius:
                                    BorderRadius.all(Radius.circular(5))),
                            //width: MediaQuery.of(context).size.width * .35,
                            child: MaterialButton(
                                child: Column(
                                  children: <Widget>[
                                    Text(
                                      'Delete',
                                      style: TextStyle(
                                        color: btnColor,
                                        fontWeight: FontWeight.w500,
                                        fontFamily: 'Montserrat',
                                        letterSpacing: 1.3,

                                        fontSize: 17,
                                        //height: 2,
                                      ),
                                    ),
                                    Text(
                                      'Delete this entity and all places/amenities/services',
                                      style: TextStyle(
                                        color: btnColor,
                                        fontWeight: FontWeight.w500,
                                        fontFamily: 'Montserrat',
                                        fontSize: 11,
                                      ),
                                    ),
                                  ],
                                ),
                                onPressed: () {
                                  if (widget.isManager) {
                                    return;
                                  } else {
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
                                                        style:
                                                            lightSubTextStyle,
                                                        children: <TextSpan>[
                                                          TextSpan(
                                                              text: "Enter "),
                                                          TextSpan(
                                                              text: "DELETE ",
                                                              style:
                                                                  errorTextStyle),
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
                                                          controller:
                                                              _txtController,
                                                          decoration:
                                                              InputDecoration(
                                                            hintText:
                                                                'eg. delete',
                                                            enabledBorder: UnderlineInputBorder(
                                                                borderSide: BorderSide(
                                                                    color: Colors
                                                                        .grey)),
                                                            focusedBorder: UnderlineInputBorder(
                                                                borderSide: BorderSide(
                                                                    color: Colors
                                                                        .orange)),
                                                          ),
                                                          onEditingComplete:
                                                              () {
                                                            print(_txtController
                                                                .text);
                                                          },
                                                          onChanged: (value) {
                                                            if (value
                                                                    .toUpperCase() ==
                                                                "DELETE"
                                                                    .toUpperCase())
                                                              setState(() {
                                                                _delEnabled =
                                                                    true;
                                                                _errorMessage =
                                                                    null;
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

                                              contentPadding:
                                                  EdgeInsets.all(10),
                                              actions: <Widget>[
                                                RaisedButton(
                                                  color: (_delEnabled)
                                                      ? btnColor
                                                      : Colors.blueGrey[200],
                                                  elevation:
                                                      (_delEnabled) ? 20 : 0,
                                                  onPressed: () {
                                                    if (_delEnabled) {
                                                      deleteEntity(
                                                              entity.entityId)
                                                          .whenComplete(() {
                                                        _gs.removeEntity(
                                                            entity.entityId);
                                                        Navigator.pop(context);
                                                        Navigator.of(context)
                                                            .push(PageAnimation
                                                                .createRoute(
                                                                    ManageEntityListPage()));
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
                                                    width:
                                                        MediaQuery.of(context)
                                                                .size
                                                                .width *
                                                            .3,
                                                    alignment: Alignment.center,
                                                    child: Text("Delete",
                                                        style: TextStyle(
                                                            color:
                                                                Colors.white)),
                                                  ),
                                                ),
                                              ],
                                            );
                                          });
                                        });
                                  }
                                })),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            // bottomNavigationBar: CustomBottomBar(barIndex: 0),
          ),
          onWillPop: () async {
            return true;
          },
        ),
      );
    } else
      return MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData.light().copyWith(),
        home: WillPopScope(
          child: Scaffold(
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

            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  showCircularProgress(),
                ],
              ),
            ),
            //drawer: CustomDrawer(),
            //bottomNavigationBar: CustomBottomBar(barIndex: 0),
          ),
          onWillPop: () async {
            return true;
          },
        ),
      );
  }
}
