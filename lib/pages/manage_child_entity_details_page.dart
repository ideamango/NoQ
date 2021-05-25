import 'dart:ui';

import 'package:LESSs/enum/entity_role.dart';
import 'package:LESSs/services/handle_exceptions.dart';
import 'package:LESSs/tuple.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:another_flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import '../db/db_model/address.dart';
import '../db/db_model/employee.dart';
import '../db/db_model/entity.dart';
import '../db/db_model/entity_private.dart';
import '../db/db_model/meta_entity.dart';
import '../db/db_model/my_geo_fire_point.dart';
import '../db/db_model/app_user.dart';
import '../db/db_model/offer.dart';
import '../db/db_service/entity_service.dart';
import 'dart:async';
import 'package:flutter/services.dart';
import '../constants.dart';
import 'package:intl/intl.dart';
import '../constants.dart';
import '../db/db_service/user_service.dart';
import '../events/event_bus.dart';
import '../events/events.dart';

import '../global_state.dart';
import '../location.dart';

import '../pages/contact_item.dart';
import '../pages/manage_child_entity_list_page.dart';
import '../pages/manage_entity_list_page.dart';
import '../repository/StoreRepository.dart';
import '../repository/local_db_repository.dart';
import '../services/circular_progress.dart';
import '../style.dart';
import '../utils.dart';
import '../widget/bottom_nav_bar.dart';
import '../widget/custom_expansion_tile.dart';
import '../widget/page_animation.dart';
import '../widget/weekday_selector.dart';
import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import '../widget/widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import 'package:geolocator/geolocator.dart';
import 'package:eventify/eventify.dart' as Eventify;

class ManageChildEntityDetailsPage extends StatefulWidget {
  final MetaEntity childMetaEntity;
  final bool isManager;
  ManageChildEntityDetailsPage(
      {Key key, @required this.childMetaEntity, @required this.isManager})
      : super(key: key);
  @override
  _ManageChildEntityDetailsPageState createState() =>
      _ManageChildEntityDetailsPageState();
}

class _ManageChildEntityDetailsPageState
    extends State<ManageChildEntityDetailsPage> {
  bool _autoValidate = false;
  final GlobalKey<FormState> _serviceDetailsFormKey =
      new GlobalKey<FormState>();
  final GlobalKey<FormFieldState> adminPhoneKey =
      new GlobalKey<FormFieldState>();
  final GlobalKey<FormFieldState> whatsappPhoneKey =
      new GlobalKey<FormFieldState>();
  final GlobalKey<FormFieldState> contactPhoneKey =
      new GlobalKey<FormFieldState>();
  final GlobalKey<FormFieldState> newAdminRowItemKey =
      new GlobalKey<FormFieldState>();
  final GlobalKey<FormFieldState> gpayPhoneKey =
      new GlobalKey<FormFieldState>();
  final GlobalKey<FormFieldState> paytmPhoneKey =
      new GlobalKey<FormFieldState>();
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
  final GlobalKey<FormFieldState> maxTokenUserInSlotKey =
      new GlobalKey<FormFieldState>();
  final GlobalKey<FormFieldState> maxPeoplePerTokenKey =
      new GlobalKey<FormFieldState>();

  final GlobalKey<FormFieldState> advDaysKey = new GlobalKey<FormFieldState>();
  final GlobalKey<FormFieldState> latKey = new GlobalKey<FormFieldState>();
  final GlobalKey<FormFieldState> lonKey = new GlobalKey<FormFieldState>();

  //Fields used in info - animated container
  double _width = 0;
  double _height = 0;
  EdgeInsets _videoMargin = EdgeInsets.all(0);
  double _videoWidth = 0;
  double _videoHeight = 0;
  bool _isVideoExpanded = false;
  bool isOnlineEnabled = false;
  bool isOfflineEnabled = false;
  Widget _videoText;
  EdgeInsets _margin = EdgeInsets.fromLTRB(0, 0, 0, 0);
  Widget _text;
  bool _isExpanded = false;
  bool _publicExpandClick = false;
  bool _activeExpandClick = false;
  bool _isBookExpanded = false;
  EdgeInsets _bookMargin = EdgeInsets.all(0);
  double _bookWidth = 0;
  double _bookHeight = 0;
  Widget _bookText;

  String title = "Managers Form";

  String dateString = "Start Date";
  Offer insertOffer = new Offer();
  bool offerFieldStatus = false;
  BorderRadiusGeometry _borderRadius = BorderRadius.circular(5);
  bool isActiveValidation = false;
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
  TextEditingController _maxBookingsInDayForUserController =
      TextEditingController();
  TextEditingController _maxBookingsInTimeSlotForUserController =
      TextEditingController();
  TextEditingController _maxPeoplePerTokenController = TextEditingController();

  TextEditingController _slotDurationController = TextEditingController();

  TextEditingController _whatsappPhoneController = TextEditingController();
  TextEditingController _contactPhoneController = TextEditingController();
  TextEditingController _emailIdController = TextEditingController();
  TextEditingController _upiIdController = TextEditingController();
  final GlobalKey<FormFieldState> whatsappPhnKey =
      new GlobalKey<FormFieldState>();
  List<String> _closedOnDays = List<String>();

  TextEditingController _offerMessageController = TextEditingController();
  TextEditingController _offerCouponController = TextEditingController();
  TextEditingController _startDateController = TextEditingController();
  TextEditingController _endDateController = TextEditingController();

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
  bool isAnythingChanged = false;
  Position pos;
  bool _initCompleted = false;
  GlobalState _gs;
  String _phCountryCode;

  final itemSize = 80.0;

  Eventify.Listener removeManagerListener;
  FocusNode whatsappFocus;

  @override
  void initState() {
    print("CHILD INIT");
    super.initState();

    getGlobalState().whenComplete(() {
      initializeEntity().whenComplete(() {
        whatsappFocus = new FocusNode();
        title = Utils.getEntityTypeDisplayName(serviceEntity.type);
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
    // serviceEntity = await getEntity(_metaEntity.entityId);

    Tuple<Entity, bool> entityTuple =
        await _gs.getEntity(widget.childMetaEntity.entityId);
    serviceEntity = entityTuple.item1;

    if (serviceEntity != null) {
      isPublic = (serviceEntity.isPublic) ?? false;
      isBookable = (serviceEntity.isBookable) ?? false;
      isActive = (serviceEntity.isActive) ?? false;

      isOnlineEnabled = serviceEntity.allowOnlineAppointment ?? false;
      isOfflineEnabled = serviceEntity.allowWalkinAppointment ?? false;

      if (isActive) {
        isActiveValidation = true;
      }
      if (isBookable) {
        validateMandatoryFieldsForBookable();
      }

      if (serviceEntity.offer != null) {
        insertOffer = serviceEntity.offer;
        _offerMessageController.text = serviceEntity.offer.message != null
            ? serviceEntity.offer.message.toString()
            : "";
        _offerCouponController.text = serviceEntity.offer.coupon != null
            ? serviceEntity.offer.coupon.toString()
            : "";

        _startDateController.text = serviceEntity.offer.startDateTime != null
            ? serviceEntity.offer.startDateTime.day.toString() +
                " / " +
                serviceEntity.offer.startDateTime.month.toString() +
                " / " +
                serviceEntity.offer.startDateTime.year.toString()
            : "";
        _endDateController.text = serviceEntity.offer.endDateTime != null
            ? serviceEntity.offer.endDateTime.day.toString() +
                " / " +
                serviceEntity.offer.endDateTime.month.toString() +
                " / " +
                serviceEntity.offer.endDateTime.year.toString()
            : "";
      }

      _nameController.text = (serviceEntity.name);
      _descController.text = (serviceEntity.description);

      if (serviceEntity.startTimeHour != null &&
          serviceEntity.startTimeMinute != null)
        _openTimeController.text =
            Utils.formatTime(serviceEntity.startTimeHour.toString()) +
                ':' +
                Utils.formatTime(serviceEntity.startTimeMinute.toString());
      if (serviceEntity.endTimeHour != null &&
          serviceEntity.endTimeMinute != null)
        _closeTimeController.text =
            Utils.formatTime(serviceEntity.endTimeHour.toString()) +
                ':' +
                Utils.formatTime(serviceEntity.endTimeMinute.toString());
      if (serviceEntity.breakStartHour != null &&
          serviceEntity.breakStartMinute != null)
        _breakStartController.text =
            Utils.formatTime(serviceEntity.breakStartHour.toString()) +
                ':' +
                Utils.formatTime(serviceEntity.breakStartMinute.toString());
      if (serviceEntity.breakEndHour != null &&
          serviceEntity.breakEndMinute != null)
        _breakEndController.text =
            Utils.formatTime(serviceEntity.breakEndHour.toString()) +
                ':' +
                Utils.formatTime(serviceEntity.breakEndMinute.toString());

      if (serviceEntity.closedOn != null) {
        if (serviceEntity.closedOn.length != 0)
          _daysOff = Utils.convertStringsToDays(serviceEntity.closedOn);
      }

      _slotDurationController.text = (serviceEntity.slotDuration != null)
          ? serviceEntity.slotDuration.toString()
          : "";
      _advBookingInDaysController.text = (serviceEntity.advanceDays != null)
          ? serviceEntity.advanceDays.toString()
          : "";
//Max People
      _maxPeopleController.text = (serviceEntity.maxAllowed != null)
          ? serviceEntity.maxAllowed.toString()
          : "";
//Max bookings by User in a Day
      _maxBookingsInDayForUserController.text =
          (serviceEntity.maxTokensByUserInDay != null)
              ? serviceEntity.maxTokensByUserInDay.toString()
              : "";
//Max Bookings in a slot by User
      // _maxBookingsInTimeSlotForUserController.text =
      //     (serviceEntity.maxTokensPerSlotByUser != null)
      //         ? serviceEntity.maxTokensPerSlotByUser.toString()
      //         : "";
//Max People in a token by User
      // _maxPeoplePerTokenController.text =
      //     (serviceEntity.maxPeoplePerToken != null)
      //         ? serviceEntity.maxPeoplePerToken.toString()
      //         : "";

      _whatsappPhoneController.text =
          Utils.isNotNullOrEmpty(serviceEntity.whatsapp)
              ? serviceEntity.whatsapp.toString().substring(3)
              : "";
      _contactPhoneController.text = Utils.isNotNullOrEmpty(serviceEntity.phone)
          ? serviceEntity.phone.toString().substring(3)
          : "";
      _emailIdController.text =
          Utils.isNotNullOrEmpty(serviceEntity.supportEmail)
              ? serviceEntity.supportEmail
              : "";
      _upiIdController.text = Utils.isNotNullOrEmpty(serviceEntity.upiId)
          ? serviceEntity.upiId
          : "";

      if (serviceEntity.offer != null) {
        _offerMessageController.text =
            Utils.isNotNullOrEmpty(serviceEntity.offer.message)
                ? serviceEntity.offer.message.toString()
                : "";
        _offerCouponController.text =
            Utils.isNotNullOrEmpty(serviceEntity.offer.coupon)
                ? serviceEntity.offer.coupon.toString()
                : "";

        _startDateController.text = serviceEntity.offer.startDateTime != null
            ? serviceEntity.offer.startDateTime.day.toString() +
                " / " +
                serviceEntity.offer.startDateTime.month.toString() +
                " / " +
                serviceEntity.offer.startDateTime.year.toString()
            : "";
        _endDateController.text = serviceEntity.offer.endDateTime != null
            ? serviceEntity.offer.endDateTime.day.toString() +
                " / " +
                serviceEntity.offer.endDateTime.month.toString() +
                " / " +
                serviceEntity.offer.endDateTime.year.toString()
            : "";
      }

      if (serviceEntity.coordinates != null) {
        _latController.text =
            serviceEntity.coordinates.geopoint.latitude.toString();
        _lonController.text =
            serviceEntity.coordinates.geopoint.longitude.toString();
      }
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
      Location lc = _gs.getLocation();
      Address defaultAdrs = new Address();
      if (lc != null) {
        defaultAdrs.state = lc.region;
        defaultAdrs.zipcode = lc.zip;
        defaultAdrs.city = lc.city;
        defaultAdrs.country = lc.country;
      }
      serviceEntity.address = (serviceEntity.address) ?? defaultAdrs;

      _cityController.text = serviceEntity.address.city;
      _stateController.text = serviceEntity.address.state;
      _countryController.text = serviceEntity.address.country;
      _pinController.text = serviceEntity.address.zipcode;

      AppUser currUser = _gs.getCurrentUser();

      EntityPrivate entityPrivateList;
      entityPrivateList = await fetchAdmins(serviceEntity.entityId);
      if (entityPrivateList != null) {
        _regNumController.text = entityPrivateList.registrationNumber;
      }
    }
  }

  String validateText(String value) {
    if (value == null || value == "") {
      return 'Field is empty';
    }
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
    }
    return null;
  }

  String validateTimeFields() {
    if ((serviceEntity.breakEndHour != null &&
            serviceEntity.breakStartHour == null) ||
        (serviceEntity.breakEndHour == null &&
            serviceEntity.breakStartHour != null)) {
      return "Both Break Start and Break End time should be specified.";
    }
    if ((serviceEntity.startTimeHour != null &&
            serviceEntity.endTimeHour == null) ||
        (serviceEntity.startTimeHour == null &&
            serviceEntity.endTimeHour != null)) {
      return "Both Day Start and Day End time should be specified.";
    }
    return null;
  }

  void useCurrLocation() {
    Position pos;
    Utils.getCurrLocation().then((value) {
      pos = value;
      if (pos == null)
        Utils.showLocationAccessDialog(context, locationPermissionMsg);
      _getAddressFromLatLng(pos);
    });
  }

  void clearLocation() {
    if (serviceEntity.isActive) {
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
      serviceEntity.coordinates = null;
    }
  }

  _getAddressFromLatLng(Position position) async {
    setState(() {
      serviceEntity.coordinates =
          new MyGeoFirePoint(position.latitude, position.longitude);
      _latController.text = position.latitude.toString();
      _lonController.text = position.longitude.toString();
    });
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
                  seconds: 3,
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
    removeAdmin(serviceEntity.entityId, currItem).then((delStatus) {
      if (delStatus)
        setState(() {
          adminsList.remove(currItem);
        });
      else
        Utils.showMyFlushbar(
            context,
            Icons.info_outline,
            Duration(
              seconds: 3,
            ),
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
    // List<Placemark> placemark =
    //     await Geolocator().placemarkFromAddress(addressStr);

    // print(placemark);

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
      serviceEntity.regNum = _regNumController.text;

      _gs.putEntity(serviceEntity, true, serviceEntity.parentId).then((value) {
        if (value) {
          Navigator.of(context).push(PageAnimation.createRoute(
              ManageChildEntityListPage(entity: this.serviceEntity)));
        }
      });
    } else {
      Utils.showMyFlushbar(
          context,
          Icons.info_outline,
          Duration(
            seconds: 4,
          ),
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

  String validateMandatoryFieldsForBookable() {
    String msg;
    bool error;
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
      //TODO : Phase2
      // if (maxTokenUserInSlotKey.currentState != null) {
      //   error = (maxTokenUserInSlotKey.currentState.validate());
      // }
      // if (maxPeoplePerTokenKey.currentState != null) {
      //   error = (maxPeoplePerTokenKey.currentState.validate());
      // }

      if (latKey.currentState != null) {
        error = (latKey.currentState.validate());
      }
      if (lonKey.currentState != null) {
        error = (lonKey.currentState.validate());
      }

      if (error != null) {
        msg = error
            ? null
            : "Current Location, Slot duration, Max. People allowed etc are missing.";
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

  String validateFieldsForOfflineConsultation() {
    //Whatsapp number should be given
    String msg;
    //TODO: SMita
    // if (Utils.isStrNullOrEmpty(_whatsappPhoneController.text)) {
    //   msg =
    //       "WhatsApp phone number should be provided, for enabling Online Consultation.";
    // }
    return msg;
  }

  @override
  Widget build(BuildContext context) {
    final nameField = TextFormField(
      obscureText: false,
      maxLines: 1,
      minLines: 1,
      enabled: widget.isManager ? false : true,
      style: textInputTextStyle,
      controller: _nameController,
      //initialValue: serviceEntity.name,
      keyboardType: TextInputType.text,
      autovalidateMode: AutovalidateMode.always,
      decoration: CommonStyle.textFieldStyle(
          labelTextStr: "Name of Establishment", hintTextStr: ""),
      validator: (value) {
        return validateText(value);
      },
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
      enabled: widget.isManager ? false : true,
      decoration: CommonStyle.textFieldStyle(
          labelTextStr: "Description", hintTextStr: ""),

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
      enabled: widget.isManager ? false : true,
      style: textInputTextStyle,
      keyboardType: TextInputType.text,
      controller: _regNumController,
      decoration: CommonStyle.textFieldStyle(
          labelTextStr: "Registration Number", hintTextStr: ""),
      onChanged: (String value) {
        isAnythingChanged = true;
        //serviceEntity.regNum = value;
      },
      onSaved: (String value) {
        //serviceEntity.regNum = value;
      },
    );
    bool dayStartClearClicked = false;
    bool dayEndClearClicked = false;
    bool breakStartClearClicked = false;
    bool breakEndClearClicked = false;
    final opensTimeField = TextFormField(
      obscureText: false,
      maxLines: 1,
      readOnly: true,
      minLines: 1,
      enabled: widget.isManager ? false : true,
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
              serviceEntity.startTimeHour = int.parse(time[0]);
              serviceEntity.startTimeMinute = int.parse(time[1]);
            }
          }, currentTime: DateTime.now());
        }
      },
      controller: _openTimeController,
      autovalidateMode: AutovalidateMode.always,
      keyboardType: TextInputType.text,
      decoration: InputDecoration(
          labelText: "Opening time",
          hintText: "HH:MM 24Hr time format",
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
                serviceEntity.startTimeHour = null;
                serviceEntity.startTimeMinute = null;
                setState(() {});
              }),
          enabledBorder:
              UnderlineInputBorder(borderSide: BorderSide(color: Colors.grey)),
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
        List<String> time = value.split(':');
        serviceEntity.startTimeHour = int.parse(time[0]);
        serviceEntity.startTimeMinute = int.parse(time[1]);
      },
      onSaved: (String value) {},
    );
    final closeTimeField = TextFormField(
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
              serviceEntity.endTimeHour = int.parse(time[0]);
              serviceEntity.endTimeMinute = int.parse(time[1]);
            }
          }, currentTime: DateTime.now());
        }
      },
      decoration: InputDecoration(
          labelText: "Closing time",
          hintText: "HH:MM 24Hr time format",
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
                serviceEntity.endTimeHour = null;
                serviceEntity.endTimeMinute = null;
                setState(() {});
              }),
          enabledBorder:
              UnderlineInputBorder(borderSide: BorderSide(color: Colors.grey)),
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
              serviceEntity.breakStartHour = int.parse(time[0]);
              serviceEntity.breakStartMinute = int.parse(time[1]);
            }
          }, currentTime: DateTime.now());
        }
      },
      controller: _breakStartController,
      keyboardType: TextInputType.text,
      decoration: InputDecoration(
          labelText: "Break start at",
          hintText: "HH:MM 24Hr time format",
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
                serviceEntity.breakStartHour = null;
                serviceEntity.breakStartMinute = null;
                setState(() {});
              }),
          enabledBorder:
              UnderlineInputBorder(borderSide: BorderSide(color: Colors.grey)),
          focusedBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.orange))),
      validator: (value) {
        return null;
      },
      onChanged: (String value) {
        List<String> time = value.split(':');
        serviceEntity.breakStartHour = int.parse(time[0]);
        serviceEntity.breakStartMinute = int.parse(time[1]);
      },
      onSaved: (String value) {},
    );
    final breakEndTimeField = TextFormField(
      obscureText: false,
      readOnly: true,
      maxLines: 1,
      enabled: widget.isManager ? false : true,
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
              serviceEntity.breakEndHour = int.parse(time[0]);
              serviceEntity.breakEndMinute = int.parse(time[1]);
            }
          }, currentTime: DateTime.now());
        }
      },
      decoration: InputDecoration(
          labelText: "Break ends at",
          hintText: "HH:MM 24Hr time format",
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
                serviceEntity.breakEndHour = null;
                serviceEntity.breakEndMinute = null;
                setState(() {});
              }),
          enabledBorder:
              UnderlineInputBorder(borderSide: BorderSide(color: Colors.grey)),
          focusedBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.orange))),
      validator: (value) {
        return null;
      },
      onChanged: (String value) {
        if (value != "") {
          List<String> time = value.split(':');
          serviceEntity.breakEndHour = int.parse(time[0]);
          serviceEntity.breakEndMinute = int.parse(time[1]);
        }
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
              isAnythingChanged = true;
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
        focusedBorder:
            UnderlineInputBorder(borderSide: BorderSide(color: Colors.orange)),
      ),
      validator: (value) {
        if (isBookable) {
          return validateNumber(value);
        }
        return null;
      },
      onChanged: (value) {
        serviceEntity.slotDuration = int.tryParse(value);
      },
      onSaved: (String value) {
        serviceEntity.slotDuration = int.tryParse(value);
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
        focusedBorder:
            UnderlineInputBorder(borderSide: BorderSide(color: Colors.orange)),
      ),
      validator: (value) {
        if (isBookable) {
          return validateAdvanceBookingDays(value);
        }
        return null;
      },
      onChanged: (value) {
        serviceEntity.advanceDays = int.tryParse(value);
      },
      onSaved: (String value) {
        serviceEntity.advanceDays = int.tryParse(value);
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
        labelText: 'Max. People allowed in a given Time-Slot',
        enabledBorder:
            UnderlineInputBorder(borderSide: BorderSide(color: Colors.grey)),
        focusedBorder:
            UnderlineInputBorder(borderSide: BorderSide(color: Colors.orange)),
      ),
      validator: (value) {
        if (isBookable) {
          return validateNumber(value);
        }
        return null;
      },
      onChanged: (String value) {
        serviceEntity.maxAllowed = int.tryParse(value);
      },
      onSaved: (String value) {
        serviceEntity.maxAllowed = int.tryParse(value);
        print("saved max people");
        // entity. = value;
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
        focusedBorder:
            UnderlineInputBorder(borderSide: BorderSide(color: Colors.orange)),
      ),
      validator: (value) {
        if (isBookable) {
          return validateText(value);
        }
        return null;
      },
      onChanged: (value) {
        serviceEntity.maxTokensByUserInDay = int.tryParse(value);
      },
      onSaved: (String value) {
        serviceEntity.maxTokensByUserInDay = int.tryParse(value);
      },
    );
    final maxTokenPerSlotInDay = TextFormField(
      key: maxTokenUserInSlotKey,
      obscureText: false,
      maxLines: 1,
      minLines: 1,
      autovalidateMode: AutovalidateMode.always,
      enabled: widget.isManager ? false : true,
      style: textInputTextStyle,
      keyboardType: TextInputType.number,
      controller: _maxBookingsInTimeSlotForUserController,
      decoration: InputDecoration(
        labelText: 'Max. bookings allowed for a user in a Time-Slot',
        enabledBorder:
            UnderlineInputBorder(borderSide: BorderSide(color: Colors.grey)),
        focusedBorder:
            UnderlineInputBorder(borderSide: BorderSide(color: Colors.orange)),
      ),
      validator: (value) {
        if (isBookable) {
          return validateText(value);
        }
        return null;
      },
      onChanged: (value) {
        serviceEntity.maxTokensPerSlotByUser = int.tryParse(value);
      },
      onSaved: (String value) {
        serviceEntity.maxTokensPerSlotByUser = int.tryParse(value);
      },
    );

    final maxPeopleInAToken = TextFormField(
      key: maxPeoplePerTokenKey,
      obscureText: false,
      maxLines: 1,
      minLines: 1,
      autovalidateMode: AutovalidateMode.always,
      enabled: widget.isManager ? false : true,
      style: textInputTextStyle,
      keyboardType: TextInputType.number,
      controller: _maxPeoplePerTokenController,
      decoration: InputDecoration(
        labelText: 'Max. people allowed with a user per Token',
        enabledBorder:
            UnderlineInputBorder(borderSide: BorderSide(color: Colors.grey)),
        focusedBorder:
            UnderlineInputBorder(borderSide: BorderSide(color: Colors.orange)),
      ),
      validator: (value) {
        if (isBookable) {
          return validateText(value);
        }
        return null;
      },
      onChanged: (value) {
        serviceEntity.maxPeoplePerToken = int.tryParse(value);
      },
      onSaved: (String value) {
        serviceEntity.maxPeoplePerToken = int.tryParse(value);
      },
    );
    final whatsappPhone = TextFormField(
      focusNode: whatsappFocus,
      obscureText: false,
      key: whatsappPhnKey,
      maxLines: 1,
      minLines: 1,
      enabled: widget.isManager ? false : true,
      style: textInputTextStyle,
      keyboardType: TextInputType.phone,
      controller: _whatsappPhoneController,
      autovalidateMode: AutovalidateMode.always,
      decoration: InputDecoration(
        prefixText: '+91',
        labelText: 'WhatsApp Number',
        enabledBorder:
            UnderlineInputBorder(borderSide: BorderSide(color: Colors.grey)),
        focusedBorder:
            UnderlineInputBorder(borderSide: BorderSide(color: Colors.orange)),
      ),
      validator: (value) {
        if (isOnlineEnabled) {
          if (Utils.isStrNullOrEmpty(value)) {
            return "Field is empty.";
          }
        }
        return Utils.validateMobileField(value);
      },
      onChanged: (value) {
        serviceEntity.whatsapp = _phCountryCode + (value);
      },
      onSaved: (String value) {
        serviceEntity.whatsapp = _phCountryCode + (value);
        print("Whatsapp Number");
      },
    );
    final callingPhone = TextFormField(
      obscureText: false,
      maxLines: 1,
      minLines: 1,
      enabled: widget.isManager ? false : true,
      key: contactPhoneKey,
      autovalidateMode: AutovalidateMode.always,
      style: textInputTextStyle,
      keyboardType: TextInputType.phone,
      controller: _contactPhoneController,
      decoration: InputDecoration(
        prefixText: _phCountryCode,
        labelText: 'Contact Phone Number (recommended)',
        enabledBorder:
            UnderlineInputBorder(borderSide: BorderSide(color: Colors.grey)),
        focusedBorder:
            UnderlineInputBorder(borderSide: BorderSide(color: Colors.orange)),
      ),
      validator: (value) {
        if (isBookable || isActiveValidation) {
          return Utils.validateMobileField(value);
        }
        return null;
      },
      onChanged: (value) {
        serviceEntity.phone = _phCountryCode + (value);
      },
      onSaved: (String value) {
        serviceEntity.phone = _phCountryCode + (value);
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
        focusedBorder:
            UnderlineInputBorder(borderSide: BorderSide(color: Colors.orange)),
      ),
      validator: Utils.validateEmail,
      onChanged: (value) {
        serviceEntity.supportEmail = value;
      },
      onSaved: (String value) {
        serviceEntity.supportEmail = value;
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
        focusedBorder:
            UnderlineInputBorder(borderSide: BorderSide(color: Colors.orange)),
      ),
      validator: Utils.validateUpiAddress,
      onChanged: (value) {
        serviceEntity.upiId = (value);
      },
      onSaved: (String value) {
        serviceEntity.upiId = (value);
      },
    );

    checkOfferDetailsFilled() {
      if (insertOffer.message != null && insertOffer.message.isNotEmpty ||
          insertOffer.coupon != null && insertOffer.coupon.isNotEmpty ||
          insertOffer.startDateTime != null ||
          insertOffer.endDateTime != null) {
        serviceEntity.offer = insertOffer;
      } else
        serviceEntity.offer = null;
    }

    clearOfferDetail() {
      insertOffer = new Offer();
      serviceEntity.offer = null;
      offerFieldStatus = false;
      _offerCouponController.text = "";
      _offerMessageController.text = "";
      _startDateController.text = "";
      _endDateController.text = "";
    }

    final messageField = TextFormField(
      obscureText: false,
      //minLines: 1,
      style: textInputTextStyle,
      enabled: widget.isManager ? false : true,
      controller: _offerMessageController,
      decoration: CommonStyle.textFieldStyle(
        labelTextStr: "Offer Message",
      ),
      validator: (value) {
        if (offerFieldStatus) {
          if (Utils.isStrNullOrEmpty(value)) {
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
          if (Utils.isStrNullOrEmpty(value)) {
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
        lastDate: DateTime(
            DateTime.now().year + 2, DateTime.now().month, DateTime.now().day),
        initialDate: insertOffer.startDateTime != null
            ? insertOffer.startDateTime.isBefore(DateTime.now())
                ? DateTime.now()
                : insertOffer.startDateTime
            : DateTime.now(),
        builder: (BuildContext context, Widget child) {
          return Theme(
            data: ThemeData.dark().copyWith(
              colorScheme: ColorScheme.light(
                primary: Colors.cyanAccent.shade700,
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
        lastDate: DateTime(
            DateTime.now().year + 2, DateTime.now().month, DateTime.now().day),
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
                primary: Colors.cyanAccent.shade700,
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
      style: textInputTextStyle,
      enabled: widget.isManager ? false : true,
      controller: _endDateController,
      decoration:
          CommonStyle.textFieldStyle(labelTextStr: "End Date", hintTextStr: ""),
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
          //enabled: false,
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
    final adrsField1 = TextFormField(
      obscureText: false,
      maxLines: 1,
      minLines: 1,
      enabled: widget.isManager ? false : true,
      style: textInputTextStyle,
      keyboardType: TextInputType.text,
      controller: _adrs1Controller,
      decoration: CommonStyle.textFieldStyle(
          labelTextStr: "Apartment/ House No./ Lane", hintTextStr: ""),
      autovalidateMode: AutovalidateMode.always,
      validator: (value) {
        if (isBookable || isActiveValidation) {
          return validateText(value);
        } else
          return null;
      },
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
      enabled: widget.isManager ? false : true,
      style: textInputTextStyle,
      keyboardType: TextInputType.text,
      autovalidateMode: AutovalidateMode.always,
      controller: _landController,
      decoration: InputDecoration(
        labelText: 'Landmark',
        enabledBorder:
            UnderlineInputBorder(borderSide: BorderSide(color: Colors.grey)),
        focusedBorder:
            UnderlineInputBorder(borderSide: BorderSide(color: Colors.orange)),
      ),
      // validator: validateText,
      onChanged: (String value) {
        serviceEntity.address.landmark = value;
      },
      onSaved: (String value) {
        serviceEntity.address.landmark = value;
      },
    );
    final localityField = TextFormField(
      autovalidateMode: AutovalidateMode.always,
      obscureText: false,
      maxLines: 1,
      minLines: 1,
      enabled: widget.isManager ? false : true,
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
      onChanged: (String value) {
        isAnythingChanged = true;
        serviceEntity.address.locality = value;
      },
      validator: (value) {
        if (isBookable || isActiveValidation)
          return validateText(value);
        else
          return null;
      },
      onSaved: (String value) {
        serviceEntity.address.locality = value;
      },
    );
    final cityField = TextFormField(
      obscureText: false,
      maxLines: 1,
      minLines: 1,
      enabled: widget.isManager ? false : true,
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
      autovalidateMode: AutovalidateMode.always,
      validator: (value) {
        if (isBookable || isActiveValidation)
          return validateText(value);
        else
          return null;
      },
      onChanged: (String value) {
        serviceEntity.address.city = value;
      },
      onSaved: (String value) {
        serviceEntity.address.city = value;
      },
    );
    final stateField = TextFormField(
      obscureText: false,
      maxLines: 1,
      minLines: 1,
      enabled: widget.isManager ? false : true,
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
      autovalidateMode: AutovalidateMode.always,
      validator: (value) {
        if (isBookable || isActiveValidation)
          return validateText(value);
        else
          return null;
      },
      onChanged: (String value) {
        isAnythingChanged = true;
        serviceEntity.address.state = value;
      },
      onSaved: (String value) {
        serviceEntity.address.state = value;
      },
    );
    final countryField = TextFormField(
      obscureText: false,
      maxLines: 1,
      minLines: 1,
      enabled: widget.isManager ? false : true,
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
      autovalidateMode: AutovalidateMode.always,
      validator: (value) {
        if (isBookable || isActiveValidation)
          return validateText(value);
        else
          return null;
      },
      onSaved: (String value) {
        serviceEntity.address.country = value;
      },
    );
    final pinField = TextFormField(
      obscureText: false,
      maxLines: 1,
      minLines: 1,
      enabled: widget.isManager ? false : true,
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
      autovalidateMode: AutovalidateMode.always,
      validator: (value) {
        if (isBookable || isActiveValidation)
          return validateNumber(value);
        else
          return null;
      },
      onChanged: (String value) {
        serviceEntity.address.zipcode = value;
      },
      onSaved: (String value) {
        serviceEntity.address.zipcode = value;
      },
    );

    TextEditingController _txtController = new TextEditingController();
    bool _delEnabled = false;

    saveRoute() {
      print("saving ");

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
        print(validationPh1);
        print(validationPh2);
        if (validationPh2 != null || validationPh1 != null) {
          isContactValid = false;
          errContactPhone =
              "The Contact information for managers is not valid.";
          break;
        }
      }
      errTimeFields = validateTimeFields();
      timeFieldsValid = (errTimeFields == null) ? true : false;
      if (_serviceDetailsFormKey.currentState.validate() &&
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

        _serviceDetailsFormKey.currentState.save();
        serviceEntity.regNum = _regNumController.text;
        _gs
            .putEntity(serviceEntity, true, serviceEntity.parentId)
            .then((value) {
          if (value) {
            // Assign admins to newly upserted entity
            assignAdminsFromList(serviceEntity.entityId, adminsList)
                .then((value) {
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
                _gs.updateMetaEntity(serviceEntity.getMetaEntity());
                Utils.showMyFlushbar(
                    context,
                    Icons.check,
                    Duration(
                      seconds: 5,
                    ),
                    'Place details saved!',
                    'Be found, by marking it "ACTIVE".',
                    successGreenSnackBar);
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
        setState(() {
          _autoValidate = true;
        });
      }
    }

    processSaveWithTimer() async {
      var duration = new Duration(seconds: 0);
      return new Timer(duration, saveRoute);
    }

    String msg;
    Flushbar flush;
    //bool _wasButtonClicked;
    backRoute() {
      //Navigator.of(context).pop();
      Entity parentEn;
      _gs.getEntity(serviceEntity.parentId, true).then((value) {
        parentEn = value.item1;
        if (parentEn != null)
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) =>
                      ManageChildEntityListPage(entity: parentEn)));
      });
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
                titlePadding: EdgeInsets.all(10),
                contentPadding: EdgeInsets.all(8),
                actionsPadding: EdgeInsets.all(0),
                //buttonPadding: EdgeInsets.all(0),
                title: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      bookable,
                      style: TextStyle(
                        fontSize: 15,
                        fontFamily: 'Roboto',
                        color: Colors.blueGrey[600],
                      ),
                    ),
                    verticalSpacer,
                    Text(
                      'Are you sure, you want to mark this place as "Bookable"?',
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

    validateLatLon() {
      bool retVal;
      if (_latController.text == null || _latController.text == "")
        retVal = false;
      else
        retVal = true;
      return retVal;
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
    double rowWidth = MediaQuery.of(context).size.width * .9;
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Add child entities',
      theme: ThemeData.light().copyWith(),
      home: WillPopScope(
        child: WillPopScope(
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
                  child: ListView(padding: const EdgeInsets.all(8.0),
                      // crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Container(
                          width: MediaQuery.of(context).size.width * .9,
                          margin: EdgeInsets.all(5),
                          padding: EdgeInsets.all(0),
                          decoration: BoxDecoration(
                              border: Border.all(color: borderColor),
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
                                    padding:
                                        EdgeInsets.only(left: 5.0, right: 5),
                                    child: Column(
                                      children: <Widget>[
                                        nameField,
                                        descField,
                                        regNumField,
                                        callingPhone,
                                        emailId
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
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                mainAxisSize: MainAxisSize.min,
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
                                        child: FlatButton(
                                            visualDensity:
                                                VisualDensity.compact,
                                            padding: EdgeInsets.all(0),
                                            child: Row(
                                                mainAxisSize: MainAxisSize.min,
                                                children: <Widget>[
                                                  Text('Allow Bookings',
                                                      style: TextStyle(
                                                          fontSize: 14)),
                                                  SizedBox(
                                                    width:
                                                        MediaQuery.of(context)
                                                                .size
                                                                .width *
                                                            .1,
                                                    child: Icon(Icons.info,
                                                        color: Colors
                                                            .blueGrey[600],
                                                        size: 17),
                                                  ),
                                                ]),
                                            onPressed: () {
                                              if (!_isBookExpanded) {
                                                setState(() {
                                                  _isBookExpanded = true;
                                                  _bookMargin = EdgeInsets.only(
                                                      bottom: 5);
                                                  _bookWidth =
                                                      MediaQuery.of(context)
                                                              .size
                                                              .width *
                                                          .9;
                                                  _bookText = AutoSizeText(
                                                      bookableInfo,
                                                      minFontSize: 10,
                                                      maxFontSize: 14,
                                                      style: TextStyle(
                                                          color:
                                                              primaryDarkColor,
                                                          // fontWeight: FontWeight.w800,
                                                          fontFamily:
                                                              'Monsterrat',
                                                          letterSpacing: 0.5,
                                                          height: 1.5));

                                                  _bookHeight = 60;
                                                });
                                              } else {
                                                setState(() {
                                                  _isBookExpanded = false;
                                                  _bookWidth = 0;
                                                  _bookHeight = 0;
                                                });
                                              }
                                            }),
                                      ),
                                      SizedBox(
                                        height:
                                            MediaQuery.of(context).size.height *
                                                .08,
                                        width:
                                            MediaQuery.of(context).size.width *
                                                .2,
                                        child: Transform.scale(
                                          scale: .7,
                                          alignment: Alignment.centerRight,
                                          child: Switch(
                                            materialTapTargetSize:
                                                MaterialTapTargetSize
                                                    .shrinkWrap,
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

                                                serviceEntity.isBookable =
                                                    value;

                                                setState(() {});
                                              }
                                            },
                                            // activeTrackColor: Colors.green,
                                            activeColor: Colors.green,
                                            inactiveThumbColor:
                                                Colors.grey[300],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  AnimatedContainer(
                                    // Use the properties stored in the State class.
                                    margin: _bookMargin,
                                    padding: EdgeInsets.all(8),
                                    width: _bookWidth,
                                    height: _bookHeight,
                                    alignment: Alignment.center,
                                    decoration: BoxDecoration(
                                      color: Colors.transparent,
                                      border:
                                          Border.all(color: primaryDarkColor),
                                      borderRadius: _borderRadius,
                                    ),
                                    // Define how long the animation should take.
                                    duration: Duration(seconds: 1),
                                    // Provide an optional curve to make the animation feel smoother.
                                    curve: Curves.easeInOutCirc,
                                    child: Center(child: _bookText),
                                  ),
                                  if (isBookable)
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Container(
                                          alignment: Alignment.centerLeft,
                                          padding:
                                              EdgeInsets.fromLTRB(10, 0, 10, 0),
                                          width: rowWidth * .8,
                                          child: MaterialButton(
                                              visualDensity:
                                                  VisualDensity.compact,
                                              padding: EdgeInsets.all(0),
                                              child: Row(
                                                mainAxisSize: MainAxisSize.min,
                                                children: <Widget>[
                                                  Container(
                                                    //  width: rowWidth * .5,
                                                    child: Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        Row(
                                                          children: [
                                                            Text(
                                                                'Enable Online Booking mode',
                                                                style: TextStyle(
                                                                    fontSize:
                                                                        14)),
                                                            SizedBox(
                                                              width:
                                                                  rowWidth * .1,
                                                              child: Icon(
                                                                Icons.info,
                                                                color: Colors
                                                                        .blueGrey[
                                                                    600],
                                                                size: 17,
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                        Container(
                                                          width: rowWidth * .7,
                                                          child: Text(
                                                              '(Booking refers to the Service provided upon an In-person visit of the person to your place.)',
                                                              style: TextStyle(
                                                                  fontSize:
                                                                      10)),
                                                        )
                                                      ],
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              onPressed: () {
                                                if (!_isVideoExpanded) {
                                                  setState(() {
                                                    _isVideoExpanded = true;
                                                    _videoMargin =
                                                        EdgeInsets.fromLTRB(
                                                            0, 0, 0, 5);
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
                                          height: MediaQuery.of(context)
                                                  .size
                                                  .height *
                                              .08,
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              .2,
                                          child: Transform.scale(
                                            scale: .7,
                                            alignment: Alignment.centerRight,
                                            child: Switch(
                                              materialTapTargetSize:
                                                  MaterialTapTargetSize
                                                      .shrinkWrap,
                                              value: isOnlineEnabled,

                                              onChanged: (value) {
                                                if (widget.isManager) {
                                                  return;
                                                } else {
                                                  isOnlineEnabled = value;
                                                  serviceEntity
                                                          .allowOnlineAppointment =
                                                      value;
                                                  if (value) {
                                                    String msg =
                                                        validateFieldsForOnlineConsultation();
                                                    FocusScope.of(context)
                                                        .requestFocus(
                                                            whatsappFocus);
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
                                                      isOnlineEnabled = !value;
                                                      serviceEntity
                                                              .allowOnlineAppointment =
                                                          !value;
                                                    }
                                                  } else {
                                                    if (!isOnlineEnabled &&
                                                        !isOfflineEnabled) {
                                                      Utils.showMyFlushbar(
                                                          context,
                                                          Icons.info_outline,
                                                          Duration(
                                                            seconds: 6,
                                                          ),
                                                          onlineOfflineMsg,
                                                          "");
                                                      isOnlineEnabled = !value;
                                                      serviceEntity
                                                              .allowOnlineAppointment =
                                                          !value;
                                                    }
                                                  }

                                                  setState(() {});
                                                }
                                              },
                                              // activeTrackColor: Colors.green,
                                              activeColor: Colors.green,
                                              inactiveThumbColor:
                                                  Colors.grey[300],
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  if (isBookable)
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Container(
                                          alignment: Alignment.centerLeft,
                                          padding:
                                              EdgeInsets.fromLTRB(10, 0, 10, 0),
                                          width: rowWidth * .8,
                                          child: MaterialButton(
                                              visualDensity:
                                                  VisualDensity.compact,
                                              padding: EdgeInsets.all(0),
                                              child: Row(
                                                mainAxisSize: MainAxisSize.min,
                                                children: <Widget>[
                                                  Container(
                                                    // width: rowWidth * .7,
                                                    child: Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        Row(
                                                          children: [
                                                            Text(
                                                                'Enable Offline Booking mode',
                                                                style: TextStyle(
                                                                    fontSize:
                                                                        14)),
                                                            SizedBox(
                                                              width:
                                                                  rowWidth * .1,
                                                              child: Icon(
                                                                Icons.info,
                                                                color: Colors
                                                                        .blueGrey[
                                                                    600],
                                                                size: 17,
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                        Container(
                                                          width: rowWidth * .7,
                                                          child: Text(
                                                              '(Booking refers to the Service provided upon an In-person visit of the person to your place.)',
                                                              style: TextStyle(
                                                                  fontSize:
                                                                      10)),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              onPressed: () {
                                                if (!_isVideoExpanded) {
                                                  setState(() {
                                                    _isVideoExpanded = true;
                                                    _videoMargin =
                                                        EdgeInsets.fromLTRB(
                                                            0, 0, 0, 5);
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
                                          height: MediaQuery.of(context)
                                                  .size
                                                  .height *
                                              .08,
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              .2,
                                          child: Transform.scale(
                                            scale: .7,
                                            alignment: Alignment.centerRight,
                                            child: Switch(
                                              materialTapTargetSize:
                                                  MaterialTapTargetSize
                                                      .shrinkWrap,
                                              value: isOfflineEnabled,

                                              onChanged: (value) {
                                                if (widget.isManager) {
                                                  return;
                                                } else {
                                                  isOfflineEnabled = value;
                                                  serviceEntity
                                                          .allowWalkinAppointment =
                                                      value;
                                                  if (value) {
                                                    String msg =
                                                        validateFieldsForOfflineConsultation();
                                                    if (Utils.isNotNullOrEmpty(
                                                        msg)) {
                                                      // if (whatsappPhoneKey
                                                      //         .currentState !=
                                                      //     null) {
                                                      //   whatsappPhoneKey
                                                      //       .currentState
                                                      //       .validate();
                                                      // }
                                                      Utils.showMyFlushbar(
                                                          context,
                                                          Icons.info_outline,
                                                          Duration(
                                                            seconds: 6,
                                                          ),
                                                          msg,
                                                          "");
                                                      isOfflineEnabled = !value;
                                                      serviceEntity
                                                              .allowWalkinAppointment =
                                                          !value;
                                                    }
                                                  } else {
                                                    if (!isOnlineEnabled &&
                                                        !isOfflineEnabled) {
                                                      Utils.showMyFlushbar(
                                                          context,
                                                          Icons.info_outline,
                                                          Duration(
                                                            seconds: 6,
                                                          ),
                                                          onlineOfflineMsg,
                                                          "");
                                                      isOfflineEnabled = !value;
                                                      serviceEntity
                                                              .allowWalkinAppointment =
                                                          !value;
                                                    }
                                                  }

                                                  setState(() {});
                                                }
                                              },
                                              // activeTrackColor: Colors.green,
                                              activeColor: Colors.green,
                                              inactiveThumbColor:
                                                  Colors.grey[300],
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                ],
                              ),
                              AnimatedContainer(
                                // Use the properties stored in the State class.
                                margin: _videoMargin,
                                padding: EdgeInsets.symmetric(horizontal: 5),
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
                        if (isBookable)
                          Container(
                            width: MediaQuery.of(context).size.width * .9,
                            margin: EdgeInsets.all(5),
                            padding: EdgeInsets.all(0),
                            decoration: BoxDecoration(
                                border: Border.all(color: borderColor),
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
                                                "Booking Details",
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
                                      padding:
                                          EdgeInsets.only(left: 5.0, right: 5),
                                      child: Column(
                                        children: <Widget>[
                                          whatsappPhone,
                                          opensTimeField,
                                          closeTimeField,
                                          breakSartTimeField,
                                          breakEndTimeField,
                                          daysClosedField,
                                          slotDuration,
                                          advBookingInDays,
                                          maxpeopleInASlot,
                                          maxTokenPerDay,
                                          // maxTokenPerSlotInDay,
                                          //  maxPeopleInAToken,
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
                          width: MediaQuery.of(context).size.width * .9,
                          margin: EdgeInsets.all(5),
                          foregroundDecoration: widget.isManager
                              ? BoxDecoration(
                                  color: Colors.grey[50],
                                  backgroundBlendMode: BlendMode.saturation,
                                )
                              : BoxDecoration(),
                          padding: EdgeInsets.all(0),
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
                                                  child: Text(addressInfoStr,
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
                                ],
                              ),
                              Container(
                                padding: EdgeInsets.only(left: 5.0, right: 5),
                                child: Column(
                                  children: <Widget>[
                                    upiIdField,
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
                          width: MediaQuery.of(context).size.width * .9,
                          margin: EdgeInsets.all(5),
                          foregroundDecoration: widget.isManager
                              ? BoxDecoration(
                                  color: Colors.grey[50],
                                  backgroundBlendMode: BlendMode.saturation,
                                )
                              : BoxDecoration(),
                          padding: EdgeInsets.all(0),
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

                                            // RaisedButton.icon(
                                            //   onPressed: clearOfferDetail,
                                            //   icon: Icon(Icons.clear_sharp,
                                            //       size: 15.0),
                                            //   label: Text("Clear"),
                                            // )
                                          ],
                                        ),
                                        backgroundColor: Colors.blueGrey[500],

                                        children: <Widget>[
                                          new Container(
                                            width: MediaQuery.of(context)
                                                    .size
                                                    .width *
                                                .9,
                                            decoration: darkContainer,
                                            padding: EdgeInsets.all(2.0),
                                            child: Row(
                                              children: <Widget>[
                                                Expanded(
                                                  child: Text(offerInfoStr,
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
                                  Container(
                                    padding:
                                        EdgeInsets.only(left: 5.0, right: 5),
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
                                                  onPressed: () {
                                                    setState(() {
                                                      clearOfferDetail();
                                                    });
                                                  },
                                                ))
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
                          width: MediaQuery.of(context).size.width * .9,
                          margin: EdgeInsets.all(5),
                          foregroundDecoration: widget.isManager
                              ? BoxDecoration(
                                  color: Colors.grey[50],
                                  backgroundBlendMode: BlendMode.saturation,
                                )
                              : BoxDecoration(),

                          padding: EdgeInsets.all(0),
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
                                                  child: Text(locationInfoStr,
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
                                ],
                              ),
                              Container(
                                padding: EdgeInsets.only(left: 5.0, right: 5),
                                child: Column(
                                  children: <Widget>[
                                    Column(children: <Widget>[
                                      Container(
                                        padding: EdgeInsets.all(4),
                                        width:
                                            MediaQuery.of(context).size.width *
                                                .95,
                                        child: RichText(
                                            text: TextSpan(
                                                style: highlightSubTextStyle,
                                                children: <TextSpan>[
                                              TextSpan(
                                                  text:
                                                      pressUseCurrentLocation +
                                                          '\r\n'),
                                              TextSpan(
                                                  text:
                                                      locationMarkingActiveInfo),
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
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              .57,
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
                                            },
                                          ),
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
                          width: MediaQuery.of(context).size.width * .9,
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
                          width: MediaQuery.of(context).size.width * .9,
                          margin: EdgeInsets.all(5),
                          padding: EdgeInsets.all(5),
                          // padding: EdgeInsets.symmetric(horizontal: 8, vertical: 0),
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
                          child: Column(
                              mainAxisSize: MainAxisSize.max,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                Column(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
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
                                              visualDensity:
                                                  VisualDensity.compact,
                                              padding: EdgeInsets.all(0),
                                              child: Row(
                                                mainAxisSize: MainAxisSize.min,
                                                children: <Widget>[
                                                  Text('Public',
                                                      style: TextStyle(
                                                          fontSize: 14)),
                                                  SizedBox(
                                                    width:
                                                        MediaQuery.of(context)
                                                                .size
                                                                .width *
                                                            .1,
                                                    // height: MediaQuery.of(context)
                                                    //         .size
                                                    //         .height *
                                                    //     .02,
                                                    child: Icon(
                                                      Icons.info,
                                                      color:
                                                          Colors.blueGrey[600],
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
                                                    _margin =
                                                        EdgeInsets.fromLTRB(
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
                                                } else {
                                                  //if bookable info is being shown
                                                  if (_publicExpandClick) {
                                                    setState(() {
                                                      _width = 0;
                                                      _height = 0;
                                                      _isExpanded = false;
                                                      _publicExpandClick =
                                                          false;
                                                    });
                                                  } else {
                                                    setState(() {
                                                      _publicExpandClick = true;
                                                      _activeExpandClick =
                                                          false;

                                                      _isExpanded = true;
                                                      _margin =
                                                          EdgeInsets.fromLTRB(
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
                                          height: MediaQuery.of(context)
                                                  .size
                                                  .height *
                                              .06,
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              .2,
                                          child: Transform.scale(
                                            scale: .7,
                                            alignment: Alignment.centerRight,
                                            child: Switch(
                                              materialTapTargetSize:
                                                  MaterialTapTargetSize
                                                      .shrinkWrap,
                                              value: isPublic,
                                              onChanged: (value) {
                                                if (widget.isManager) {
                                                  return;
                                                } else {
                                                  setState(() {
                                                    isPublic = value;
                                                    serviceEntity.isPublic =
                                                        value;
                                                    print(isPublic);
                                                    //}
                                                  });
                                                }
                                              },
                                              // activeTrackColor: Colors.green,
                                              activeColor: Colors.green,
                                              inactiveThumbColor:
                                                  Colors.grey[300],
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
                                            visualDensity:
                                                VisualDensity.compact,
                                            padding: EdgeInsets.all(0),
                                            child: Row(
                                                mainAxisSize: MainAxisSize.min,
                                                children: <Widget>[
                                                  Text('Active',
                                                      style: TextStyle(
                                                          fontSize: 14)),
                                                  SizedBox(
                                                    width:
                                                        MediaQuery.of(context)
                                                                .size
                                                                .width *
                                                            .1,
                                                    // height: MediaQuery.of(context)
                                                    //         .size
                                                    //         .height *
                                                    //     .02,
                                                    child: Icon(Icons.info,
                                                        color: Colors
                                                            .blueGrey[600],
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
                                                  _width =
                                                      MediaQuery.of(context)
                                                              .size
                                                              .width *
                                                          .9;
                                                  _text = AutoSizeText(
                                                      activeDef,
                                                      minFontSize: 8,
                                                      maxFontSize: 14,
                                                      style:
                                                          textBotSheetTextStyle);

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

                                                    _isExpanded = true;
                                                    _margin =
                                                        EdgeInsets.fromLTRB(
                                                            0, 0, 0, 8);
                                                    _width =
                                                        MediaQuery.of(context)
                                                                .size
                                                                .width *
                                                            .9;
                                                    _text = AutoSizeText(
                                                        activeDef,
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
                                          height: MediaQuery.of(context)
                                                  .size
                                                  .height *
                                              .06,
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              .2,
                                          child: Transform.scale(
                                            scale: .7,
                                            alignment: Alignment.centerRight,
                                            child: Switch(
                                              materialTapTargetSize:
                                                  MaterialTapTargetSize
                                                      .shrinkWrap,
                                              value: isActive,
                                              onChanged: (value) {
                                                if (widget.isManager) {
                                                  return;
                                                } else {
                                                  setState(() {
                                                    if (value) {
                                                      isActiveValidation = true;
                                                      bool retVal = false;
                                                      bool locValid = false;
                                                      if (validateAllFields())
                                                        retVal = true;
                                                      if (validateLatLon())
                                                        locValid = true;

                                                      if (!locValid ||
                                                          !retVal) {
                                                        if (!locValid) {
                                                          Utils.showMyFlushbar(
                                                              context,
                                                              Icons
                                                                  .info_outline,
                                                              Duration(
                                                                seconds: 6,
                                                              ),
                                                              shouldSetLocation,
                                                              pressUseCurrentLocation);
                                                        } else if (!retVal) {
                                                          //Show flushbar with info that fields has invalid data
                                                          Utils.showMyFlushbar(
                                                              context,
                                                              Icons
                                                                  .info_outline,
                                                              Duration(
                                                                seconds: 6,
                                                              ),
                                                              "Missing Information!!",
                                                              'Making a place "ACTIVE" requires all mandatory information to be filled in. Please provide the details and Save.');
                                                        }
                                                      } else {
                                                        isActiveValidation =
                                                            false;
                                                        isActive = value;
                                                        serviceEntity.isActive =
                                                            value;
                                                        print(isActive);
                                                      }
                                                    } else {
                                                      isActive = value;
                                                      isActiveValidation =
                                                          false;

                                                      serviceEntity.isActive =
                                                          value;
                                                      print(isActive);
                                                    }
                                                  });
                                                }
                                              },
                                              // activeTrackColor: Colors.green,
                                              activeColor: Colors.green,
                                              inactiveThumbColor:
                                                  Colors.grey[300],
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
                              ]),
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
                                        backgroundBlendMode:
                                            BlendMode.saturation,
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
                            decoration: new BoxDecoration(
                                border: Border.all(color: Colors.teal[200]),
                                borderRadius:
                                    BorderRadius.all(Radius.circular(5))),
                            foregroundDecoration: widget.isManager
                                ? BoxDecoration(
                                    color: Colors.grey[50],
                                    backgroundBlendMode: BlendMode.saturation,
                                  )
                                : BoxDecoration(),
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
                                              builder: (_, setState) {
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
                                                MaterialButton(
                                                  color: Colors.white,
                                                  elevation: 0,
                                                  shape: RoundedRectangleBorder(
                                                      side: BorderSide(
                                                          color: Colors
                                                              .blueGrey[500]),
                                                      borderRadius:
                                                          BorderRadius.all(
                                                              Radius.circular(
                                                                  5.0))),
                                                  onPressed: () {
                                                    Navigator.of(_).pop(false);
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
                                                    child: Text("Cancel",
                                                        style: TextStyle(
                                                            color: btnColor)),
                                                  ),
                                                ),
                                                MaterialButton(
                                                  color: (_delEnabled)
                                                      ? btnColor
                                                      : Colors.blueGrey[200],
                                                  elevation:
                                                      (_delEnabled) ? 20 : 0,
                                                  onPressed: () {
                                                    if (_delEnabled) {
                                                      Navigator.of(_).pop(true);
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
                                                // (_errorMessage != null
                                                //     ? Text(
                                                //         _errorMessage,
                                                //         style: TextStyle(color: Colors.red),
                                                //       )
                                                //     : Container()),
                                              ],
                                            );
                                          });
                                        }).then((returnVal) {
                                      if (returnVal != null) {
                                        if (returnVal) {
                                          String parentEntityId =
                                              serviceEntity.parentId;
                                          Entity parentEntity;

                                          _gs
                                              .removeEntity(
                                                  serviceEntity.entityId)
                                              .then((value) {
                                            if (value) {
                                              Navigator.pop(context);
                                              _gs
                                                  .getEntity(parentEntityId)
                                                  .then((value) {
                                                parentEntity = value.item1;
                                                Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                        builder: (context) =>
                                                            ManageChildEntityListPage(
                                                                entity:
                                                                    parentEntity)));
                                              });
                                            } else {
                                              //Entity not deleted.
                                              Utils.showMyFlushbar(
                                                  context,
                                                  Icons.error,
                                                  Duration(seconds: 5),
                                                  'Could not Delete this place',
                                                  "Please try again.",
                                                  Colors.red);
                                            }
                                          }).catchError((error) {
                                            ErrorsUtil.handleDeleteEntityErrors(
                                                context, error);
                                          });
                                        }
                                      }
                                    });
                                  }
                                }),
                          ),
                        ),
                      ]),
                ),
              ),
            ),
          ),
          onWillPop: () async {
            return true;
          },
        ),
        onWillPop: () async {
          return true;
        },
      ),
    );
  }
}
