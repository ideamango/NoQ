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
import 'package:noq/db/db_model/booking_form.dart';
import 'package:noq/db/db_model/employee.dart';
import 'package:noq/db/db_model/entity.dart';
import 'package:noq/db/db_model/entity_private.dart';
import 'package:noq/db/db_model/meta_entity.dart';
import 'package:noq/db/db_model/my_geo_fire_point.dart';
import 'package:noq/db/db_model/app_user.dart';
import 'package:noq/db/db_service/user_service.dart';
import 'package:noq/db/db_model/offer.dart';
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
  bool _autoValidateWhatsapp = false;

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
  TextEditingController _closeTimeController = TextEditingController();
  TextEditingController _openTimeController = TextEditingController();
  TextEditingController _breakStartController = TextEditingController();
  TextEditingController _breakEndController = TextEditingController();

  TextEditingController _maxPeopleController = TextEditingController();
  TextEditingController _primaryPhoneController = TextEditingController();
  TextEditingController _alternatePhoneController = TextEditingController();

  TextEditingController _gpayPhoneController = TextEditingController();
  TextEditingController _paytmPhoneController = TextEditingController();

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
  Position pos;
  GlobalState _gState;
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
  List<String> idProofTypesStrList = List<String>();
  List<Item> idProofTypes = List<Item>();
  List<String> medConditionsStrList = List<String>();
  List<Item> medConditions = List<Item>();
  List<File> _images = [];
  File _image; // Used only if you need a single picture
  String _downloadUrl;
  BookingForm bookingForm;
  FormInputFieldText nameInput;

  ///end of fields from contact page

  @override
  void initState() {
    _scrollController = ScrollController();
    super.initState();

    initBookingForm();
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

    entity = this.widget.entity;
    getGlobalState().whenComplete(() {
      initializeEntity().whenComplete(() {
        setState(() {
          _initCompleted = true;
        });
      });
    });

    removeManagerListener = EventBus.registerEvent(
        MANAGER_REMOVED_EVENT, null, this.refreshOnManagerRemove);
  }

  initBookingForm() {
    List<Field> fields = List<Field>();

    nameInput = FormInputFieldText(
        "Name", true, "Please enter your name as per Government ID proof", 50);

    fields.add(nameInput);

    FormInputFieldNumber ageInput =
        FormInputFieldNumber("Age", true, "Please enter your age", 0, 120);

    fields.add(ageInput);

    FormInputFieldOptions healthDetailsInput = FormInputFieldOptions(
        "Medical Conditions",
        true,
        "Please select all known medical conditions you have",
        [
          'Chronic kidney disease',
          'Chronic lung disease',
          'Diabetes',
          'Heart Conditions',
          'Other Cardiovascular and Cerebrovascular Diseases',
          "Hemoglobin disorders",
          "HIV or weakened Immune System",
          "Liver disease",
          "Neurologic conditions such as dementia",
          "Overweight and Severe Obesity",
          "Pregnancy"
        ],
        true);

    fields.add(healthDetailsInput);

    bookingForm = new BookingForm(
        formName: "Covid-19 Vacination Applicant Details",
        headerMsg:
            "You request will be approved based on the information provided by you.",
        footerMsg: "",
        formFields: fields,
        autoApproved: true);
  }

  @override
  void dispose() {
    super.dispose();
    print("dispose called for child entity");
    EventBus.unregisterEvent(removeManagerListener);
  }

  String validateMandatoryFields(String value) {
    String retVal;
    if (value == null || value == "") {
      retVal = 'Field is empty';
    } else
      retVal = null;
    return retVal;
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
    Reference ref = _gState.firebaseStorage.ref().child('idProofs/');

    await ref.putFile(_image);

    print('File Uploaded');

    return await ref.getDownloadURL();
  }
  // variable to hold image to be displayed

//method to load image and update `uploadedImage`

  void refreshOnManagerRemove(event, args) {
    setState(() {
      //  contactRowWidgets.removeWhere((element) => element)
      print("Inside remove Manage");
      contactRowWidgets.clear();
      contactRowWidgets.add(showCircularProgress());
    });
    //refreshContacts();
    processRefreshContactsWithTimer();
    print("printing event.eventData");
    print("In parent page" + event.eventData);
    print(event.eventData);
  }

  processRefreshContactsWithTimer() async {
    var duration = new Duration(seconds: 1);
    return new Timer(duration, refreshContacts);
  }

  refreshContacts() {
    List<Widget> newList = new List<Widget>();
    for (int i = 0; i < contactList.length; i++) {
      newList.add(new ContactRow(
        contact: contactList[i],
        entity: entity,
        list: contactList,
      ));
    }
    setState(() {
      contactRowWidgets.clear();
      contactRowWidgets.addAll(newList);
    });
    entity.managers = contactList;
  }

  ///from contact page
  void initializeContactDetails() {
    if (contact != null) {
      _ctNameController.text = contact.name;
      _ctEmpIdController.text = contact.employeeId;
      _ctPhn1controller.text =
          contact.ph != null ? contact.ph.substring(3) : "";
      _ctPhn2controller.text =
          contact.altPhone != null ? contact.altPhone.substring(3) : "";
      if (contact.shiftStartHour != null && contact.shiftStartMinute != null)
        _ctAvlFromTimeController.text =
            Utils.formatTime(contact.shiftStartHour.toString()) +
                ':' +
                Utils.formatTime(contact.shiftStartMinute.toString());
      if (contact.shiftEndHour != null && contact.shiftEndMinute != null)
        _ctAvlTillTimeController.text =
            Utils.formatTime(contact.shiftEndHour.toString()) +
                ':' +
                Utils.formatTime(contact.shiftEndMinute.toString());
      _ctDaysOff = (contact.daysOff) ?? new List<String>();
    }
    if (_daysOff.length == 0) {
      _ctDaysOff.add('days.sunday');
    }
    _ctClosedOnDays = List<days>();
    _ctClosedOnDays = Utils.convertStringsToDays(_ctDaysOff);

    contact.isManager = true;
  }

  Widget buildContactItem(Employee contact) {
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
      onChanged: (String value) {
        contact.name = value;
      },
      onSaved: (String value) {
        contact.name = value;
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
          labelTextStr: "Employee Id", hintTextStr: ""),
      validator: validateText,
      onChanged: (String value) {
        contact.employeeId = value;
      },
      onSaved: (String value) {
        contact.employeeId = value;
      },
    );
    final ctPhn1Field = TextFormField(
      obscureText: false,
      key: phn1Key,
      maxLines: 1,
      minLines: 1,
      style: textInputTextStyle,
      keyboardType: TextInputType.phone,
      controller: _ctPhn1controller,
      decoration: CommonStyle.textFieldStyle(
          prefixText: '+91', labelTextStr: "Primary Phone", hintTextStr: ""),
      validator: Utils.validateMobileField,
      onChanged: (String value) {
        phn1Key.currentState.validate();
        contact.ph = "+91" + value;
      },
      onSaved: (value) {
        contact.ph = "+91" + value;
      },
    );
    final ctPhn2Field = TextFormField(
      obscureText: false,
      key: phn2Key,
      maxLines: 1,
      minLines: 1,
      style: textInputTextStyle,
      keyboardType: TextInputType.phone,
      controller: _ctPhn2controller,
      decoration: CommonStyle.textFieldStyle(
          prefixText: '+91', labelTextStr: "Alternate Phone", hintTextStr: ""),
      validator: Utils.validateMobileField,
      onChanged: (String value) {
        phn2Key.currentState.validate();
        contact.altPhone = "+91" + value;
      },
      onSaved: (value) {
        contact.altPhone = "+91" + value;
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

          _ctAvlFromTimeController.text = time.toLowerCase();
          if (_ctAvlFromTimeController.text != "") {
            List<String> time = _ctAvlFromTimeController.text.split(':');
            contact.shiftStartHour = int.parse(time[0]);
            contact.shiftStartMinute = int.parse(time[1]);
          }
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
          hintText: "hh:mm 24 hour time format",
          enabledBorder:
              UnderlineInputBorder(borderSide: BorderSide(color: Colors.grey)),
          focusedBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.orange))),
      validator: validateTime,
      onChanged: (String value) {
        //TODO: test the values
        List<String> time = value.split(':');
        contact.shiftStartHour = int.parse(time[0]);
        contact.shiftStartMinute = int.parse(time[1]);
      },
      onSaved: (String value) {
        //TODO: test the values
        List<String> time = value.split(':');
        contact.shiftStartHour = int.parse(time[0]);
        contact.shiftStartMinute = int.parse(time[1]);
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

          _ctAvlTillTimeController.text = time.toLowerCase();
          if (_ctAvlTillTimeController.text != "") {
            List<String> time = _ctAvlTillTimeController.text.split(':');
            contact.shiftEndHour = int.parse(time[0]);
            contact.shiftEndMinute = int.parse(time[1]);
          }
        }, currentTime: DateTime.now());
      },
      decoration: InputDecoration(
          labelText: "Available till",
          hintText: "hr:mm 24 hour time format",
          enabledBorder:
              UnderlineInputBorder(borderSide: BorderSide(color: Colors.grey)),
          focusedBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.orange))),
      validator: validateTime,
      onChanged: (String value) {
        //TODO: test the values
        List<String> time = value.split(':');
        contact.shiftEndHour = int.parse(time[0]);
        contact.shiftEndMinute = int.parse(time[1]);
      },
      onSaved: (String value) {},
    );
    final ctDaysOffField = Padding(
      padding: EdgeInsets.only(top: 12, bottom: 8),
      child: Row(
        children: <Widget>[
          Text(
            'Days off ',
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
            initialValue: _ctClosedOnDays,
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
              _ctDaysOff.clear();
              days.forEach((element) {
                var day = element.toString().substring(5);
                _ctDaysOff.add(day);
              });
              contact.daysOff = _ctDaysOff;
              print(_ctDaysOff.length);
              print(_ctDaysOff.toString());
            },
          ),
        ],
      ),
    );

    return Card(
      child: Theme(
        data: ThemeData(
          unselectedWidgetColor: Colors.black,
          accentColor: highlightColor,
        ),
        child: ExpansionTile(
          //key: PageStorageKey(this.widget.headerTitle),
          initiallyExpanded: false,
          title: Text(
            (contact.name != null && contact.name != "")
                ? contact.name
                : "Manager",
            style: TextStyle(color: Colors.blueGrey[700], fontSize: 17),
          ),

          backgroundColor: Colors.white,
          leading: IconButton(
              icon: Icon(Icons.person, color: Colors.blueGrey[300], size: 20),
              onPressed: () {
                // contact.isManager = false;
              }),
          children: <Widget>[
            Container(
              color: Colors.cyan[50],
              padding: EdgeInsets.only(left: 2.0, right: 2),
              // decoration: BoxDecoration(
              //     // border: Border.all(color: containerColor),
              //     color: Colors.white,
              //     shape: BoxShape.rectangle,
              //     borderRadius: BorderRadius.all(Radius.circular(5.0))),
              // padding: EdgeInsets.all(5.0),

              child: new Form(
                //  autovalidate: _autoValidate,
                child: ListTile(
                  title: Column(
                    children: <Widget>[
                      ctNameField,
                      ctEmpIdField,
                      ctPhn1Field,
                      ctPhn2Field,
                      ctDaysOffField,
                      Divider(
                        thickness: .7,
                        color: Colors.grey[600],
                      ),
                      ctAvlFromTimeField,
                      ctAvlTillTimeField,
                      RaisedButton(
                          color: btnColor,
                          child: Text(
                            "Remove",
                            style: buttonMedTextStyle,
                          ),
                          onPressed: () {
                            String removeThisId;
                            for (int i = 0; i < _entity.managers.length; i++) {
                              if (_entity.managers[i].id == contact.id) {
                                removeThisId = contact.id;
                                print(_entity.managers[i].id);
                                break;
                              }
                            }
                            if (removeThisId != null) {
                              setState(() {
                                contact = null;
                                _entity.managers.removeWhere(
                                    (element) => element.id == removeThisId);
                                _list.removeWhere(
                                    (element) => element.id == removeThisId);
                              });
                            }
                          })
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  ///end from contact page
  ///

  Future<void> getGlobalState() async {
    _gState = await GlobalState.getGlobalState();
    _phCountryCode = _gState.getConfigurations().phCountryCode;
  }

  initializeEntity() async {
    if (entity != null) {
      isPublic = (entity.isPublic) ?? false;
      isBookable = (entity.isBookable) ?? false;
      isActive = (entity.isActive) ?? false;

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
        validateField = true;
        _autoValidate = true;
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
      if (_daysOff.length == 0) {
        _closedOnDays.add('days.sunday');
        _daysOff = Utils.convertStringsToDays(_closedOnDays);
      }
      _slotDurationController.text =
          entity.slotDuration != null ? entity.slotDuration.toString() : "";
      _advBookingInDaysController.text =
          entity.advanceDays != null ? entity.advanceDays.toString() : "";
      if (entity.maxAllowed != null)
        _maxPeopleController.text =
            (entity.maxAllowed != null) ? entity.maxAllowed.toString() : "";
      _primaryPhoneController.text = entity.whatsapp != null
          ? entity.whatsapp.toString().substring(3)
          : "";
      _alternatePhoneController.text =
          entity.phone != null ? entity.phone.toString().substring(3) : "";
      _gpayPhoneController.text =
          entity.gpay != null ? entity.gpay.toString().substring(3) : "";
      _paytmPhoneController.text =
          entity.paytm != null ? entity.paytm.toString().substring(3) : "";

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
      if (!(Utils.isNullOrEmpty(entity.managers))) {
        contactList = entity.managers;
        contactList.forEach((element) {
          contactRowWidgets.add(new ContactRow(
              contact: element, entity: entity, list: contactList));
        });
      }

      AppUser currUser = _gState.getCurrentUser();
      Map<String, String> adminMap = Map<String, String>();
      EntityPrivate entityPrivateList;
      entityPrivateList = await fetchAdmins(entity.entityId);
      if (entityPrivateList != null) {
        adminMap = entityPrivateList.roles;
        if (adminMap != null)
          adminMap.forEach((k, v) {
            if (currUser.ph != k) adminsList.add(k);
          });
        _regNumController.text = entityPrivateList.registrationNumber;
      }
    }

    entity.address = (entity.address) ?? new Address();
    contactList = contactList ?? new List<Employee>();

    //  _ctNameController.text = entity.contactPersons[0].perName;
  }

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

  void _addNewContactRow() {
    Employee contact = new Employee();
    var uuid = new Uuid();
    contact.id = uuid.v1();
    contactList.add(contact);

    List<Widget> newList = new List<Widget>();
    for (int i = 0; i < contactList.length; i++) {
      newList.add(new ContactRow(
        contact: contactList[i],
        entity: entity,
        list: contactList,
      ));
    }
    setState(() {
      contactRowWidgets.clear();
      contactRowWidgets.addAll(newList);
      entity.managers = contactList;
      // _contactCount = _contactCount + 1;
    });
  }

  void addNewAdminRow() {
    setState(() {
      adminsList.add("Admin");
    });
  }

  void saveNewAdminRow(String newAdmPh) {
    setState(() {
      adminsList.forEach((element) {
        if (element.compareTo(newAdmPh) != 0) adminsList.add(newAdmPh);
      });
    });
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
            labelTextStr: "Name of Person", hintTextStr: ""),
        validator: validateText,
        onChanged: (String value) {
          //SAVEDATA
          //  entity.name = value;
        },
        onSaved: (String value) {
          // nameInput.response = value;
        },
      );

      final descField = TextFormField(
        obscureText: false,
        //minLines: 1,
        style: textInputTextStyle,
        controller: _descController,
        decoration: CommonStyle.textFieldStyle(
            labelTextStr: "Notes (optional)", hintTextStr: ""),
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
            _startDateController.text = dateString;
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
        controller: _startDateController,
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

        if (_tokenBookingDetailsFormKey.currentState.validate()) {
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
                                      descField,
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