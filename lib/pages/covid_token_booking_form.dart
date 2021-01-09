import 'dart:async';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:noq/constants.dart';
import 'package:noq/db/db_model/address.dart';
import 'package:noq/db/db_model/booking_application.dart';
import 'package:noq/db/db_model/booking_form.dart';
import 'package:noq/db/db_model/employee.dart';
import 'package:noq/db/db_model/entity.dart';
import 'package:noq/db/db_model/entity_private.dart';
import 'package:noq/db/db_model/meta_entity.dart';
import 'package:noq/db/db_model/my_geo_fire_point.dart';
import 'package:noq/db/db_model/app_user.dart';
import 'package:noq/db/db_service/user_service.dart';
import 'package:noq/db/db_model/offer.dart';
import 'package:noq/enum/application_status.dart';
import 'package:noq/enum/entity_type.dart';
import 'package:noq/events/event_bus.dart';
import 'package:noq/events/events.dart';
import 'package:noq/global_state.dart';
import 'package:noq/pages/contact_item.dart';
import 'package:noq/pages/manage_entity_list_page.dart';
import 'package:noq/pages/search_entity_page.dart';
import 'package:noq/repository/StoreRepository.dart';
import 'package:noq/services/circular_progress.dart';
import 'package:noq/style.dart';
import 'package:noq/utils.dart';
import 'package:noq/widget/bottom_nav_bar.dart';
import 'package:noq/widget/custom_expansion_tile.dart';
import 'package:noq/widget/page_animation.dart';
import 'package:noq/widget/weekday_selector.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:flushbar/flushbar.dart';
import 'package:noq/widget/widgets.dart';
import 'package:uuid/uuid.dart';
import 'package:eventify/eventify.dart' as Eventify;

class CovidTokenBookingFormPage extends StatefulWidget {
  final Entity entity;
  CovidTokenBookingFormPage({Key key, @required this.entity}) : super(key: key);
  @override
  _CovidTokenBookingFormPageState createState() =>
      _CovidTokenBookingFormPageState();
}

class _CovidTokenBookingFormPageState extends State<CovidTokenBookingFormPage> {
  bool _autoValidate = false;
  final GlobalKey<FormState> _tokenBookingDetailsFormKey =
      new GlobalKey<FormState>();

  final GlobalKey<FormFieldState> whatsappPhoneKey =
      new GlobalKey<FormFieldState>();
  final GlobalKey<FormFieldState> contactPhoneKey =
      new GlobalKey<FormFieldState>();
  List<String> saveData = List<String>();

  //Fields used in info - animated container
  double _width = 0;
  double _height = 0;
  EdgeInsets _margin = EdgeInsets.fromLTRB(0, 0, 0, 0);
  Widget _text;
  bool _isExpanded = false;
  bool _publicExpandClick = false;
  bool _activeExpandClick = false;
  bool _bookExpandClick = false;
  // Color _color = Colors.green;
  BorderRadiusGeometry _borderRadius = BorderRadius.circular(5);

  final String title = "Managers Form";

  String flushStatus = "Empty";

  String dateString = "Start Date";
  Offer insertOffer = new Offer();
  bool offerFieldStatus = false;

//Basic Details
  bool validateField = false;
  TextEditingController _nameController = TextEditingController();
  TextEditingController _descController = TextEditingController();
  TextEditingController _regNumController = TextEditingController();

  TextEditingController _primaryPhoneController = TextEditingController();
  TextEditingController _alternatePhoneController = TextEditingController();

  TextEditingController _gpayPhoneController = TextEditingController();
  TextEditingController _paytmPhoneController = TextEditingController();

  TextEditingController _dateOfBirthController = TextEditingController();
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

  //ContactPerson Fields

  Employee cp1 = new Employee();
  Address adrs = new Address();

  Entity entity;

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
  Position pos;
  GlobalState _gs;
  String _phCountryCode;
  bool setActive = false;
  //final Geolocator geolocator = Geolocator()..forceAndroidLocationManager;

  ///from contact page
  bool _isValid = false;
  Employee contact;

  final GlobalKey<FormFieldState> phn1Key = new GlobalKey<FormFieldState>();
  final GlobalKey<FormFieldState> phn2Key = new GlobalKey<FormFieldState>();

  Eventify.Listener removeManagerListener;
  List<String> idProofTypesStrList = List<String>();
  List<Item> idProofTypes = List<Item>();
  List<String> medConditionsStrList = List<String>();
  List<Item> medConditions = List<Item>();
  List<File> _images = [];
  File _image; // Used only if you need a single picture
  String _downloadUrl;
  BookingForm bookingForm;
  List<Field> fields;
  BookingApplication bookingApplication;
  FormInputFieldText nameInput;

  ///end of fields from contact page

  @override
  void initState() {
    _scrollController = ScrollController();
    super.initState();
    entity = this.widget.entity;

    getGlobalState().whenComplete(() {
      initializeEntity().whenComplete(() {
        initBookingForm();
        setState(() {
          _initCompleted = true;
        });
      });
    });
  }

  initBookingForm() {
    fields = List<Field>();
    idProofTypesStrList.add('Passport');
    idProofTypesStrList.add('Driving License');
    idProofTypesStrList.add('Aadhar');
    idProofTypesStrList.add('PAN');
    idProofTypesStrList.forEach((element) {
      idProofTypes.add(Item(element, false));
    });
    medConditionsStrList.add('Chronic Kidney Disease');
    medConditionsStrList.add('Liver Disease');
    medConditionsStrList.add('Overweight and Severe Obesity');
    medConditionsStrList
        .add('Other Cardiovascular and Cerebrovascular Diseases');
    medConditionsStrList.add('Haemoglobin Disorders');
    medConditionsStrList.add('Pregnancy');
    medConditionsStrList.add('Heart Conditions');
    medConditionsStrList.add('Chronic Lung Disease');
    medConditionsStrList.add('HIV or Weakened Immune System');

    medConditionsStrList.add('Neurologic Conditions such as Dementia');

    medConditionsStrList.add('Diabetes');

    medConditionsStrList.add('Others (Specify below)');

    medConditionsStrList.forEach((element) {
      medConditions.add(Item(element, false));
    });
    nameInput = FormInputFieldText("Name of Person", true,
        "Please enter your name as per Government ID proof", 50);
    fields.add(nameInput);
    // FormInputFieldDate dobInput = FormInputFieldDate(
    //   "Select Date of Birth",
    //   true,
    //   "Please select your Date of Birth",
    // );
    // fields.add(dobInput);
    FormInputFieldText primaryPhone = FormInputFieldText(
        "Primary Contact Number", true, "Primary Contact Number", 10);
    fields.add(primaryPhone);
    FormInputFieldText alternatePhone = FormInputFieldText(
        "Primary Contact Number", false, "Primary Contact Number", 10);
    fields.add(alternatePhone);
    FormInputFieldOptions idProofTypeInput = FormInputFieldOptions(
        "Id Proof Type",
        true,
        "Please select a Government Id proof",
        idProofTypesStrList,
        false);
    fields.add(idProofTypeInput);
    FormInputFieldText idProofUrlInput = FormInputFieldText(
        "Id Proof File Url", true, "Please upload Government Id proof", 200);
    fields.add(idProofUrlInput);
    FormInputFieldOptions healthDetailsInput = FormInputFieldOptions(
        "Medical Conditions",
        true,
        "Please select all known medical conditions you have",
        medConditionsStrList,
        true);
    fields.add(healthDetailsInput);
    FormInputFieldText healthDetailsDesc = FormInputFieldText(
        "Decription of medical conditions (optional)",
        true,
        "Decription of medical conditions (optional)",
        200);
    fields.add(healthDetailsDesc);
    FormInputFieldText latInput = FormInputFieldText(
        "Current Location Latitude", false, "Current Location Latitude", 20);
    fields.add(latInput);
    FormInputFieldText lonInput = FormInputFieldText(
        "Current Location Longitude", false, "Current Location Longitude", 20);
    fields.add(lonInput);
    FormInputFieldText addressInput = FormInputFieldText(
        "Apartment/ House No./ Lane", false, "Apartment/ House No./ Lane", 60);
    fields.add(addressInput);
    FormInputFieldText addresslandmark =
        FormInputFieldText("Landmark", false, "Landmark", 40);
    fields.add(addresslandmark);
    FormInputFieldText addressLocality =
        FormInputFieldText("Locality", false, "Locality", 40);
    fields.add(addressLocality);
    FormInputFieldText addressCity =
        FormInputFieldText("City", false, "City", 30);
    fields.add(addressCity);
    FormInputFieldText addressState =
        FormInputFieldText("State", false, "State", 30);
    fields.add(addressState);
    FormInputFieldText addressCountry =
        FormInputFieldText("Country", false, "Country", 30);
    fields.add(addressCountry);
    FormInputFieldText notesInput =
        FormInputFieldText("Notes (optional)", false, "Notes (optional)", 100);
    fields.add(notesInput);

    bookingForm = new BookingForm(
        formName: "Covid-19 Vacination Applicant Details",
        headerMsg:
            "You request will be approved based on the information provided by you.",
        footerMsg: "",
        formFields: fields,
        autoApproved: true);

    bookingApplication = new BookingApplication();
    bookingApplication.entityId = entity.entityId;
    bookingApplication.userId = _gs.getCurrentUser().id;
    bookingApplication.status = ApplicationStatus.NEW;
    bookingApplication.responseForm = bookingForm;
  }

  @override
  void dispose() {
    super.dispose();
    _nameController.dispose();
    _descController.dispose();
    _primaryPhoneController.dispose();
    _alternatePhoneController.dispose();
    _dateOfBirthController.dispose();
    _primaryPhoneController.dispose();
    _primaryPhoneController.dispose();
  }

  String validateMandatoryFields(String value) {
    String retVal;
    if (value == null || value == "") {
      retVal = 'Field is empty';
    } else
      retVal = null;
    return retVal;
  }

  bool validateIdProof() {
    if (_downloadUrl == null)
      return false;
    else
      return true;
  }

  Future getImage(bool gallery) async {
    ImagePicker picker = ImagePicker();
    PickedFile pickedFile;
    // Let user select photo from gallery
    if (gallery) {
      pickedFile = await picker.getImage(
        source: ImageSource.gallery,
      );
    }
    // Otherwise open camera to get new photo
    else {
      pickedFile = await picker.getImage(
        source: ImageSource.camera,
      );
    }

    setState(() {
      if (pickedFile != null) {
        //_images.add(File(pickedFile.path));
        _image = File(pickedFile.path);
        uploadFile(_image).then((value) {
          print(value);
          setState(() {
            _downloadUrl = value;
          });
        });
        print("before i think");
      } else {
        print('No image selected.');
      }
    });
  }

  Future<String> uploadFile(File image) async {
    Reference ref = _gs.firebaseStorage.ref().child('idProofs/');

    await ref.putFile(_image);

    print('File Uploaded');

    return await ref.getDownloadURL();
  }

  Future<void> getGlobalState() async {
    _gs = await GlobalState.getGlobalState();
    _phCountryCode = _gs.getConfigurations().phCountryCode;
  }

  initializeEntity() async {}

  String validateText(String value) {
    if (validateField) {
      if (value == null || value == "") {
        return 'Field is empty';
      } else
        return null;
    } else
      return null;
  }

  String validateTime(String value) {
    if (validateField) {
      if (value == null || value == "") {
        return 'Field is empty';
      } else
        return null;
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
          "If you really want to clear location, deselect ACTIVE on top of the page.");
    } else {
      _latController.text = "";
      _lonController.text = "";
      entity.coordinates = null;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_initCompleted) {
      //Basic details field
      final nameField = TextFormField(
        obscureText: false,
        //TODO: Add maxlength = 50
        maxLines: 1,
        minLines: 1,
        style: textInputTextStyle,
        controller: _nameController,
        keyboardType: TextInputType.text,
        decoration: CommonStyle.textFieldStyle(
            labelTextStr: "Name of Person",
            hintTextStr: "Please enter your name as per Government ID proof"),
        validator: validateMandatoryFields,
        onChanged: (String value) {
          //SAVEDATA
          //  entity.name = value;
        },
        onSaved: (String value) {
          nameInput.response = value;
        },
      );

      final descField = TextFormField(
        obscureText: false,
        //minLines: 1,
        style: textInputTextStyle,
        controller: _descController,
        decoration: CommonStyle.textFieldStyle(
            labelTextStr: "Notes (optional)", hintTextStr: ""),
        //No validation required, nonmandatory field
        // validator: (value) {
        //   if (!validateField)
        //     return validateText(value);
        //   else
        //     return null;
        // },
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
      final idTypeField = Column(
        children: [
          Row(
            children: [
              // Container(
              //     width: MediaQuery.of(context).size.width * .2,
              //     child: Text(
              //       "Type of ID Proof",
              //       style: textInputTextStyle,
              //     )),
              Expanded(
                child: Wrap(
                  children: idProofTypes
                      .map((item) => GestureDetector(
                          onTap: () {
                            bool newSelectionValue = !(item.isSelected);

                            idProofTypes.forEach((element) {
                              element.isSelected = false;
                            });

                            setState(() {
                              item.isSelected = newSelectionValue;
                            });
                          },
                          child: Container(
                              decoration: new BoxDecoration(
                                  border:
                                      Border.all(color: Colors.blueGrey[200]),
                                  shape: BoxShape.rectangle,
                                  color: (!item.isSelected)
                                      ? Colors.cyan[50]
                                      : highlightColor,
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(30.0))),
                              padding: EdgeInsets.fromLTRB(8, 5, 8, 5),
                              margin: EdgeInsets.all(8),
                              // color: Colors.orange,
                              child: Text(item.text))))
                      .toList()
                      .cast<Widget>(),
                ),
              ),
            ],
          ),
          Divider(
            thickness: 1.5,
          )
        ],
      );
      final selectFileBtn = IconButton(
          padding: EdgeInsets.zero,
          icon: Icon(
            Icons.camera_alt_rounded,
            color: primaryDarkColor,
          ),
          onPressed: () {
            getImage(false);
          });

      final clickPicForUploadBtn = IconButton(
          padding: EdgeInsets.zero,
          icon: Icon(
            Icons.attach_file,
            color: primaryDarkColor,
          ),
          onPressed: () {
            getImage(true);
          });
      //  fillColor: Theme.of(context).accentColor,

      final medicalConditionsField = Column(
        children: [
          Row(
            children: [
              // Container(
              //     width: MediaQuery.of(context).size.width * .2,
              //     child: Text(
              //       "Medical Conditions (If any)",
              //       style: textInputTextStyle,
              //     )),
              Expanded(
                child: Wrap(
                  alignment: WrapAlignment.center,
                  children: medConditions
                      .map((item) => GestureDetector(
                          onTap: () {
                            bool newSelectionValue = !(item.isSelected);

                            // medConditions.forEach((element) {
                            //   element.isSelected = false;
                            // });

                            setState(() {
                              item.isSelected = newSelectionValue;
                            });
                          },
                          child: Container(
                              decoration: new BoxDecoration(
                                  border:
                                      Border.all(color: Colors.blueGrey[200]),
                                  shape: BoxShape.rectangle,
                                  color: (!item.isSelected)
                                      ? Colors.cyan[50]
                                      : highlightColor,
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(30.0))),
                              padding: EdgeInsets.fromLTRB(8, 5, 8, 5),
                              margin: EdgeInsets.all(8),
                              // color: Colors.orange,
                              child: Text(item.text))))
                      .toList()
                      .cast<Widget>(),
                ),
              ),
            ],
          ),
          Divider(
            thickness: 1.5,
          )
        ],
      );
      final medicalConditionsDescField = TextFormField(
        obscureText: false,
        //minLines: 1,
        style: textInputTextStyle,
        controller: _descController,
        decoration: CommonStyle.textFieldStyle(
            labelTextStr: "Description of above condition (optional)",
            hintTextStr: ""),
        validator: (value) {
          if (!validateField)
            return validateText(value);
          else
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

      Future<Null> pickDate(BuildContext context) async {
        DateTime date = await showDatePicker(
          context: context,
          firstDate: DateTime.now().subtract(Duration(days: 365 * 100)),
          lastDate: DateTime.now(),
          initialDate: DateTime.now(),
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
            _dateOfBirthController.text = dateString;
            // checkOfferDetailsFilled();
            offerFieldStatus = true;
          });
        }
      }

      final dobField = TextFormField(
        obscureText: false,
        //minLines: 1,
        readOnly: true,
        style: textInputTextStyle,
        controller: _dateOfBirthController,
        decoration: CommonStyle.textFieldStyle(
            labelTextStr: "Select Date of Birth", hintTextStr: ""),
        validator: validateMandatoryFields,
        onTap: () {
          setState(() {
            pickDate(context);
          });
        },
        maxLength: null,
        maxLines: 1,
        onChanged: (String value) {
          //  checkOfferDetailsFilled();
        },
        onSaved: (String value) {
          // checkOfferDetailsFilled();
        },
      );
      final whatsappPhone = TextFormField(
        obscureText: false,
        maxLines: 1,
        minLines: 1,
        key: whatsappPhoneKey,
        style: textInputTextStyle,
        keyboardType: TextInputType.phone,
        controller: _primaryPhoneController,
        decoration: InputDecoration(
          prefixText: '+91',
          labelText: 'Primary Contact Number',
          enabledBorder:
              UnderlineInputBorder(borderSide: BorderSide(color: Colors.grey)),
          focusedBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.orange)),
        ),
        validator: (value) {
          if (!validateField)
            return Utils.validateMobileField(value);
          else
            return null;
        },
        onChanged: (value) {
          //_autoValidateWhatsapp = true;
          whatsappPhoneKey.currentState.validate();
          if (value != "") entity.whatsapp = _phCountryCode + (value);
        },
        onSaved: (String value) {
          if (value != "") entity.whatsapp = _phCountryCode + (value);
        },
      );
      final callingPhone = TextFormField(
        obscureText: false,
        maxLines: 1,
        minLines: 1,
        key: contactPhoneKey,
        style: textInputTextStyle,
        keyboardType: TextInputType.phone,
        controller: _alternatePhoneController,
        decoration: InputDecoration(
          prefixText: '+91',
          labelText: 'Alternate Contact Number',
          enabledBorder:
              UnderlineInputBorder(borderSide: BorderSide(color: Colors.grey)),
          focusedBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.orange)),
        ),
        validator: Utils.validateMobileField,
        onChanged: (value) {
          contactPhoneKey.currentState.validate();
          if (value != "") entity.phone = _phCountryCode + (value);
        },
        onSaved: (String value) {
          if (value != "") entity.phone = _phCountryCode + (value);
        },
      );

      final latField = Container(
          width: MediaQuery.of(context).size.width * .3,
          child: TextFormField(
            obscureText: false,
            maxLines: 1,
            minLines: 1,
            enabled: false,
            style: textInputTextStyle,
            keyboardType: TextInputType.text,
            controller: _latController,
            decoration: CommonStyle.textFieldStyle(
                labelTextStr: "Latitude", hintTextStr: ""),
            validator: validateMandatoryFields,
            onChanged: (String value) {},
            onSaved: (String value) {},
          ));

      final lonField = Container(
          width: MediaQuery.of(context).size.width * .3,
          child: TextFormField(
            obscureText: false,
            maxLines: 1,
            minLines: 1,
            enabled: false,
            style: textInputTextStyle,
            keyboardType: TextInputType.text,
            controller: _lonController,
            decoration: CommonStyle.textFieldStyle(
                labelTextStr: "Longitude", hintTextStr: ""),
            validator: (value) {
              return validateText(value);
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
            onPressed: clearLocation,
          ));
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
      Flushbar flush;
      bool _wasButtonClicked;

      saveRoute() {
        if (isActive)
          validateField = true;
        else
          validateField = false;

        if (_tokenBookingDetailsFormKey.currentState.validate() &&
            validateIdProof()) {
          Utils.showMyFlushbar(
              context,
              Icons.info_outline,
              Duration(
                seconds: 3,
              ),
              "Saving details!! ",
              "This would take just a moment.",
              Colors.white,
              true);

          _tokenBookingDetailsFormKey.currentState.save();
          //TODO:Server call to save data
          _gs
              .getTokenApplicationService()
              .submitApplication(bookingApplication);

          upsertEntity(entity, _regNumController.text).then((value) {
            if (value) {
              Utils.showMyFlushbar(
                  context,
                  Icons.check,
                  Duration(
                    seconds: 5,
                  ),
                  "Request submitted successfully!",
                  'We will contact you as soon as slot opens up. Stay Safe.');
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
      }

      backRoute() {
        Navigator.of(context)
            .push(PageAnimation.createRoute(SearchEntityPage()));
      }

      processSaveWithTimer() async {
        var duration = new Duration(seconds: 0);
        return new Timer(duration, saveRoute);
      }

      processGoBackWithTimer() async {
        var duration = new Duration(seconds: 1);
        return new Timer(duration, backRoute);
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
        if (_latController.text == null || _latController.text == "")
          retVal = false;
        else
          retVal = true;
        return retVal;
      }

      validateAllFields() {
        bool retVal;
        if (_tokenBookingDetailsFormKey.currentState.validate())
          retVal = true;
        else
          retVal = false;
        return retVal;
      }

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
                        "The changes you made might be lost, if not saved.",
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
              title: Text(Utils.getEntityTypeDisplayName(entity.type),
                  style: whiteBoldTextStyle1),
            ),
            body: Center(
              child: new SafeArea(
                top: true,
                bottom: true,
                child: new Form(
                  key: _tokenBookingDetailsFormKey,
                  autovalidate: _autoValidate,
                  child: new ListView(
                    padding: const EdgeInsets.all(5.0),
                    children: <Widget>[
                      Container(
                        width: MediaQuery.of(context).size.width * .9,
                        margin: EdgeInsets.all(0),
                        padding: EdgeInsets.all(0),
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
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              mainAxisSize: MainAxisSize.max,
                              children: <Widget>[
                                Container(
                                  width:
                                      MediaQuery.of(context).size.width * .15,
                                  child: FlatButton(
                                      visualDensity: VisualDensity.compact,
                                      padding: EdgeInsets.all(0),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: <Widget>[
                                          Text('Public',
                                              style: TextStyle(fontSize: 12)),
                                          SizedBox(
                                            width: MediaQuery.of(context)
                                                    .size
                                                    .width *
                                                .05,
                                            height: MediaQuery.of(context)
                                                    .size
                                                    .height *
                                                .02,
                                            child: Icon(
                                              Icons.info,
                                              color: Colors.blueGrey[600],
                                              size: 14,
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
                                                EdgeInsets.fromLTRB(0, 0, 0, 8);
                                            _width = MediaQuery.of(context)
                                                    .size
                                                    .width *
                                                .9;
                                            _text = RichText(
                                                text: TextSpan(
                                                    style: subHeadingTextStyle,
                                                    children: <TextSpan>[
                                                  TextSpan(
                                                      text: publicInfo,
                                                      style:
                                                          buttonXSmlTextStyle)
                                                ]));

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
                                              _width = MediaQuery.of(context)
                                                      .size
                                                      .width *
                                                  .9;
                                              _text = RichText(
                                                  text: TextSpan(
                                                      style:
                                                          subHeadingTextStyle,
                                                      children: <TextSpan>[
                                                    TextSpan(
                                                        text: publicInfo,
                                                        style:
                                                            buttonXSmlTextStyle)
                                                  ]));

                                              _height = 60;
                                            });
                                          }
                                        }
                                      }),
                                ),
                                SizedBox(
                                  height:
                                      MediaQuery.of(context).size.height * .08,
                                  width:
                                      MediaQuery.of(context).size.width * .14,
                                  child: Transform.scale(
                                    scale: 0.6,
                                    alignment: Alignment.centerLeft,
                                    child: Switch(
                                      materialTapTargetSize:
                                          MaterialTapTargetSize.shrinkWrap,
                                      value: isPublic,
                                      onChanged: (value) {
                                        setState(() {
                                          isPublic = value;
                                          entity.isPublic = value;
                                          print(isPublic);
                                          //}
                                        });
                                      },
                                      // activeTrackColor: Colors.green,
                                      activeColor: highlightColor,
                                      inactiveThumbColor: Colors.grey[300],
                                    ),
                                  ),
                                ),
                                Container(
                                  width: MediaQuery.of(context).size.width * .2,
                                  child: FlatButton(
                                      visualDensity: VisualDensity.compact,
                                      padding: EdgeInsets.all(0),
                                      child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: <Widget>[
                                            Text('Bookable',
                                                style: TextStyle(fontSize: 12)),
                                            SizedBox(
                                              width: MediaQuery.of(context)
                                                      .size
                                                      .width *
                                                  .05,
                                              height: MediaQuery.of(context)
                                                      .size
                                                      .height *
                                                  .02,
                                              child: Icon(Icons.info,
                                                  color: Colors.blueGrey[600],
                                                  size: 14),
                                            ),
                                          ]),
                                      onPressed: () {
                                        if (!_isExpanded) {
                                          setState(() {
                                            _bookExpandClick = true;
                                            _isExpanded = true;
                                            _margin =
                                                EdgeInsets.fromLTRB(0, 0, 0, 8);
                                            _width = MediaQuery.of(context)
                                                    .size
                                                    .width *
                                                .9;
                                            _text = RichText(
                                                text: TextSpan(
                                                    style: subHeadingTextStyle,
                                                    children: <TextSpan>[
                                                  TextSpan(
                                                      text: bookableInfo,
                                                      style:
                                                          buttonXSmlTextStyle)
                                                ]));
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
                                              _width = MediaQuery.of(context)
                                                      .size
                                                      .width *
                                                  .9;
                                              _text = RichText(
                                                  text: TextSpan(
                                                      style:
                                                          subHeadingTextStyle,
                                                      children: <TextSpan>[
                                                    TextSpan(
                                                        text: bookableInfo,
                                                        style:
                                                            buttonXSmlTextStyle)
                                                  ]));

                                              _height = 60;
                                            });
                                          }
                                        }
                                      }),
                                ),
                                SizedBox(
                                  height:
                                      MediaQuery.of(context).size.height * .08,
                                  width:
                                      MediaQuery.of(context).size.width * .14,
                                  child: Transform.scale(
                                    scale: 0.6,
                                    alignment: Alignment.centerLeft,
                                    child: Switch(
                                      materialTapTargetSize:
                                          MaterialTapTargetSize.shrinkWrap,
                                      value: isBookable,
                                      onChanged: (value) {
                                        setState(() {
                                          isBookable = value;
                                          entity.isBookable = value;

                                          if (value) {
                                            showConfirmationDialog();
                                            //TODO: SMita - show msg with info, yes/no
                                          }
                                          print(isBookable);
                                        });
                                      },
                                      // activeTrackColor: Colors.green,
                                      activeColor: highlightColor,
                                      inactiveThumbColor: Colors.grey[300],
                                    ),
                                  ),
                                ),
                                Container(
                                  width:
                                      MediaQuery.of(context).size.width * .15,
                                  child: FlatButton(
                                    visualDensity: VisualDensity.compact,
                                    padding: EdgeInsets.all(0),
                                    child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: <Widget>[
                                          Text('Active',
                                              style: TextStyle(fontSize: 12)),
                                          SizedBox(
                                            width: MediaQuery.of(context)
                                                    .size
                                                    .width *
                                                .05,
                                            height: MediaQuery.of(context)
                                                    .size
                                                    .height *
                                                .02,
                                            child: Icon(Icons.info,
                                                color: Colors.blueGrey[600],
                                                size: 15),
                                          ),
                                        ]),
                                    onPressed: () {
                                      if (!_isExpanded) {
                                        setState(() {
                                          _activeExpandClick = true;
                                          _isExpanded = true;
                                          _margin =
                                              EdgeInsets.fromLTRB(0, 0, 0, 8);
                                          _width = MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              .9;
                                          _text = RichText(
                                              text: TextSpan(
                                                  style: subHeadingTextStyle,
                                                  children: <TextSpan>[
                                                TextSpan(
                                                    text: activeDef,
                                                    style: buttonXSmlTextStyle)
                                              ]));

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
                                            _margin =
                                                EdgeInsets.fromLTRB(0, 0, 0, 8);
                                            _width = MediaQuery.of(context)
                                                    .size
                                                    .width *
                                                .9;
                                            _text = RichText(
                                                text: TextSpan(
                                                    style: subHeadingTextStyle,
                                                    children: <TextSpan>[
                                                  TextSpan(
                                                      text: activeDef,
                                                      style:
                                                          buttonXSmlTextStyle)
                                                ]));

                                            _height = 60;
                                          });
                                        }
                                      }
                                    },
                                  ),
                                ),
                                SizedBox(
                                  height:
                                      MediaQuery.of(context).size.height * .08,
                                  width:
                                      MediaQuery.of(context).size.width * .14,
                                  child: Transform.scale(
                                    scale: 0.6,
                                    alignment: Alignment.centerLeft,
                                    child: Switch(
                                      materialTapTargetSize:
                                          MaterialTapTargetSize.shrinkWrap,
                                      value: isActive,
                                      onChanged: (value) {
                                        setState(() {
                                          if (value) {
                                            validateField = true;
                                            _autoValidate = true;
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
                                              validateField = false;
                                              isActive = value;
                                              entity.isActive = value;
                                              print(isActive);
                                            }
                                          } else {
                                            isActive = value;
                                            validateField = false;
                                            _autoValidate = false;
                                            entity.isActive = value;
                                            print(isActive);
                                          }
                                        });
                                      },
                                      // activeTrackColor: Colors.green,
                                      activeColor: highlightColor,
                                      inactiveThumbColor: Colors.grey[300],
                                    ),
                                  ),
                                )
                              ],
                            ),
                            AnimatedContainer(
                              padding: EdgeInsets.all(2),
                              margin: _margin,
                              // Use the properties stored in the State class.
                              width: _width,
                              height: _height,
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color: Colors.blueGrey[500],
                                border: Border.all(color: primaryAccentColor),
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
                                      //   descField,
                                      dobField,
                                      whatsappPhone,
                                      callingPhone,
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
                            borderRadius:
                                BorderRadius.all(Radius.circular(5.0))),
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Column(children: <Widget>[
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
                                            "ID Proof Details",
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
                                  child: Column(children: <Widget>[
                                    idTypeField,
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        (_downloadUrl == null)
                                            ? Container(
                                                child:
                                                    Text("No Image Selected"))
                                            : Container(
                                                width: MediaQuery.of(context)
                                                        .size
                                                        .width *
                                                    .2,
                                                child: Stack(
                                                  alignment:
                                                      AlignmentDirectional
                                                          .topEnd,
                                                  children: [
                                                    Image.network(_downloadUrl),
                                                    Icon(Icons.cancel)
                                                  ],
                                                ),
                                              ),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.end,
                                          children: [
                                            selectFileBtn,
                                            clickPicForUploadBtn
                                          ],
                                        ),
                                      ],
                                    ),
                                  ]),
                                ),
                              ]),
                            ]),
                      ),

                      SizedBox(
                        height: 7,
                      ),
                      Container(
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
                                            "Medical History",
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
                                      // nameField,

                                      medicalConditionsField,
                                      medicalConditionsDescField,
                                      // opensTimeField,
                                      // closeTimeField,
                                      // breakSartTimeField,
                                      // breakEndTimeField,
                                      // daysClosedField,
                                      //  slotDuration,
                                      // advBookingInDays,
                                      // maxpeopleInASlot,
                                      // startDateField,
                                      // whatsappPhone,
                                      // callingPhone,
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
                      // Container(
                      //   decoration: BoxDecoration(
                      //       border: Border.all(color: containerColor),
                      //       color: Colors.grey[50],
                      //       shape: BoxShape.rectangle,
                      //       borderRadius:
                      //           BorderRadius.all(Radius.circular(5.0))),
                      //   //padding: EdgeInsets.all(5.0),
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
                      //                       "Payment Details",
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
                      //                           child: Text(paymentInfoStr,
                      //                               style: buttonXSmlTextStyle),
                      //                         ),
                      //                       ],
                      //                     ),
                      //                   ),
                      //                 ],
                      //               ),
                      //             ),
                      //           ),
                      //         ],
                      //       ),
                      //       Container(
                      //         padding: EdgeInsets.only(left: 5.0, right: 5),
                      //         child: Column(
                      //           children: <Widget>[
                      //             gPayPhone,
                      //             paytmPhone,
                      //           ],
                      //         ),
                      //       ),
                      //     ],
                      //   ),
                      // ),
                      // SizedBox(
                      //   height: 7,
                      // ),
                      // Container(
                      //   decoration: BoxDecoration(
                      //       border: Border.all(color: containerColor),
                      //       color: Colors.grey[50],
                      //       shape: BoxShape.rectangle,
                      //       borderRadius:
                      //           BorderRadius.all(Radius.circular(5.0))),
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
                      //                       "Offer Details",
                      //                       style: TextStyle(
                      //                           color: Colors.white,
                      //                           fontSize: 15),
                      //                     ),
                      //                     SizedBox(
                      //                         width: MediaQuery.of(context)
                      //                                 .size
                      //                                 .width *
                      //                             0.5),
                      //                     InkWell(
                      //                       child: Text(
                      //                         "Clear",
                      //                         style:
                      //                             offerClearTextStyleWithUnderLine,
                      //                       ),
                      //                       onTap: () {
                      //                         setState(() {
                      //                           clearOfferDetail();
                      //                         });
                      //                       },
                      //                     ),
                      //                     // RaisedButton.icon(
                      //                     //   onPressed: clearOfferDetail,
                      //                     //   icon: Icon(Icons.clear_sharp,
                      //                     //       size: 15.0),
                      //                     //   label: Text("Clear"),
                      //                     // )
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
                      //                           child: Text(offerInfoStr,
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
                      //             padding: EdgeInsets.only(left: 5.0, right: 5),
                      //             child: Column(
                      //               children: <Widget>[
                      //                 messageField,
                      //                 couponField,
                      //                 Row(
                      //                   children: <Widget>[
                      //                     Expanded(child: startDateField),
                      //                     Expanded(child: endDateField),
                      //                   ],
                      //                 ),
                      //               ],
                      //             ),
                      //           ),
                      //         ],
                      //       ),
                      //     ],
                      //   ),
                      // ),
                      // SizedBox(
                      //   height: 7,
                      // ),
                      Container(
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
                                        width:
                                            MediaQuery.of(context).size.width *
                                                .6,
                                        child: RaisedButton(
                                          elevation: 10,
                                          color: btnColor,
                                          splashColor: highlightColor,
                                          textColor: Colors.white,
                                          shape: RoundedRectangleBorder(
                                              side:
                                                  BorderSide(color: btnColor)),
                                          child: Text(
                                            userCurrentLoc,
                                            textAlign: TextAlign.center,
                                          ),
                                          onPressed: useCurrLocation,
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
                      Container(
                        padding: EdgeInsets.only(left: 5.0, right: 5),
                        decoration: BoxDecoration(
                            border: Border.all(color: containerColor),
                            color: Colors.grey[50],
                            shape: BoxShape.rectangle,
                            borderRadius:
                                BorderRadius.all(Radius.circular(5.0))),
                        //padding: EdgeInsets.all(5.0),
                        child: descField,
                      ),
                      SizedBox(
                        height: 7,
                      ),
                      //THIS CONTAINER
                      // Container(
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
                      //                         .13,
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
                      // //THIS CONTAINER
                      // Container(
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
                      Builder(
                        builder: (context) => RaisedButton(
                            color: btnColor,
                            splashColor: highlightColor,
                            child: Container(
                              // width: MediaQuery.of(context).size.width * .35,
                              child: Column(
                                children: <Widget>[
                                  Text(
                                    'Save Details & Request Token',
                                    style: buttonMedTextStyle,
                                  ),
                                  // Text(
                                  //   'Details of amenities/services',
                                  //   style: buttonXSmlTextStyle,
                                  // ),
                                ],
                              ),
                            ),
                            onPressed: () {
                              print("FlushbarStatus-------");
                              processSaveWithTimer();
                            }),
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

class Item {
  String text;
  bool isSelected;
  String lastSelected;

  Item(this.text, this.isSelected);
}
