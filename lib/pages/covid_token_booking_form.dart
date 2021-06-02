import 'dart:async';

import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
import '../constants.dart';
import '../db/db_model/address.dart';
import '../db/db_model/booking_application.dart';
import '../db/db_model/booking_form.dart';
import '../db/db_model/employee.dart';
import '../db/db_model/entity.dart';
import '../db/db_model/meta_entity.dart';
import '../db/db_model/my_geo_fire_point.dart';
import '../db/db_model/offer.dart';
import '../enum/application_status.dart';
import '../global_state.dart';
import '../pages/search_entity_page.dart';
import '../pages/show_slots_page.dart';
import '../services/circular_progress.dart';
import '../style.dart';
import '../utils.dart';
import '../widget/custom_expansion_tile.dart';
import '../widget/page_animation.dart';
import '../widget/weekday_selector.dart';
import 'package:flutter/foundation.dart';
import 'package:another_flushbar/flushbar.dart';
import '../widget/widgets.dart';
import 'package:path/path.dart';

class CovidTokenBookingFormPage extends StatefulWidget {
  final MetaEntity metaEntity;
  final String bookingFormId;
  final DateTime preferredSlotTime;
  final dynamic backRoute;
  CovidTokenBookingFormPage(
      {Key key,
      @required this.metaEntity,
      @required this.bookingFormId,
      @required this.preferredSlotTime,
      @required this.backRoute})
      : super(key: key);
  @override
  _CovidTokenBookingFormPageState createState() =>
      _CovidTokenBookingFormPageState();
}

class _CovidTokenBookingFormPageState extends State<CovidTokenBookingFormPage>
    with SingleTickerProviderStateMixin {
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
  TextEditingController _medDescController = TextEditingController();
  TextEditingController _regNumController = TextEditingController();

  TextEditingController _primaryPhoneController = TextEditingController();
  TextEditingController _alternatePhoneController = TextEditingController();

  TextEditingController _gpayPhoneController = TextEditingController();
  TextEditingController _paytmPhoneController = TextEditingController();

  TextEditingController _dobController = TextEditingController();
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

  MetaEntity metaEntity;

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

  List<File> _idProofimages = [];
  List<File> _frontLineProofimages = [];
  List<File> _medCondsProofimages = [];
  //File _image; // Used only if you need a single picture
  // String _downloadUrl;
  BookingForm bookingForm;
  List<Field> fields;
  BookingApplication bookingApplication;
  FormInputFieldText nameInput;
  FormInputFieldDateTime dobInput;
  FormInputFieldPhone primaryPhone;
  FormInputFieldText notesInput;

  String _idProofType;
  FormInputFieldOptionsWithAttachments idProofField;
  FormInputFieldOptionsWithAttachments frontlineWorkerField;
  FormInputFieldOptionsWithAttachments medConditionsField;
  List<Item> idProofTypesList = List<Item>();
  List<Item> frontlineTypesList = List<Item>();
  List<Item> medConditionsList = List<Item>();
  // FormInputFieldText healthDetailsDesc;
  // FormInputFieldText latInput;
  // FormInputFieldText lonInput;
  // FormInputFieldText addressInput;
  // FormInputFieldText addresslandmark;
  // FormInputFieldText addressLocality;
  // FormInputFieldText addressCity;
  // FormInputFieldText addressState;
  // FormInputFieldText addressCountry;
  // FormInputFieldText notesInput;
  // FormInputFieldText addressPin;
  String validationErrMsg = "";
  String submissionDoneMsg =
      "Thanks for Submitting application. We will contact you soon";
  int idProofCounter = 0;

  ///end of fields from contact page

  @override
  void initState() {
    super.initState();
    metaEntity = this.widget.metaEntity;

    getGlobalState().whenComplete(() {
      initBookingForm();
    });
  }

  initBookingForm() async {
    _gs
        .getApplicationService()
        .getBookingForm(widget.bookingFormId)
        .then((value) {
      if (value == null) {
        //TODO: return to show slots page

      } else {
        bookingForm = value;
        for (Field f in bookingForm.getFormFields()) {
          if (f.key == "KEY10")
            nameInput = f;
          else if (f.key == "KEY20")
            dobInput = f;
          else if (f.key == "KEY30") {
            medConditionsField = f; //Validate this field
            medConditionsField.responseValues = new List<Value>();
            for (int i = 0; i < medConditionsField.options.length; i++) {
              if (medConditionsField.defaultValueIndex == i)
                medConditionsList
                    .add(Item(medConditionsField.options[i], true));
              else
                medConditionsList
                    .add(Item(medConditionsField.options[i], false));
            }
            medConditionsField.responseFilePaths = new List<String>();
          } else if (f.key == "KEY40") {
            frontlineWorkerField = f;
            frontlineWorkerField.responseValues = new List<Value>();
            for (int i = 0; i < frontlineWorkerField.options.length; i++) {
              if (frontlineWorkerField.defaultValueIndex == i)
                frontlineTypesList
                    .add(Item(frontlineWorkerField.options[i], true));
              else
                frontlineTypesList
                    .add(Item(frontlineWorkerField.options[i], false));
            }
            frontlineWorkerField.responseFilePaths = new List<String>();
          } else if (f.key == "KEY50") {
            idProofField = f;
            idProofField.responseValues = new List<Value>();
            for (Value val in idProofField.options) {
              idProofTypesList.add(Item(val, false));
            }
            idProofField.responseFilePaths = new List<String>();
          } else if (f.key == "KEY60") primaryPhone = f;
        }
        bookingApplication = new BookingApplication();
        //slot
        bookingApplication.preferredSlotTiming = widget.preferredSlotTime;

        //bookingFormId
        bookingApplication.bookingFormId = widget.bookingFormId;
        bookingApplication.entityId = metaEntity.entityId;
        bookingApplication.userId = _gs.getCurrentUser().id;
        bookingApplication.status = ApplicationStatus.NEW;
        bookingApplication.responseForm = bookingForm;
        print("Booking application set");
        setState(() {
          _initCompleted = true;
        });
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
    _nameController.dispose();
    _medDescController.dispose();
    _primaryPhoneController.dispose();
    _alternatePhoneController.dispose();
    _dobController.dispose();
  }

  bool validateAllFields() {
    if (!Utils.isNotNullOrEmpty(_nameController.text))
      validationErrMsg = nameMissingMsg;
    if (!Utils.isNotNullOrEmpty(_dobController.text))
      validationErrMsg = validationErrMsg + '\n' + dobMissingMsg;
    if (!Utils.isNotNullOrEmpty(_idProofType))
      validationErrMsg = validationErrMsg + '\n' + idProofTypeMissingMsg;
    if (Utils.isNullOrEmpty(idProofField.responseFilePaths))
      validationErrMsg = validationErrMsg + '\n' + idProofFileMissingMsg;
    //MedCondTypeMissing
    //TODO CHECK this
    if (!Utils.isNullOrEmpty(medConditionsField.responseFilePaths)) {
      if (Utils.isNullOrEmpty(medConditionsField.responseValues))
        validationErrMsg = validationErrMsg + '\n' + medCondsTypeMissingMsg;
    }
    //MedCOns fILE missing
    if (!Utils.isNullOrEmpty(medConditionsField.responseValues)) {
      if (Utils.isNullOrEmpty(medConditionsField.responseFilePaths))
        validationErrMsg = validationErrMsg + '\n' + medCondsFileMissingMsg;
    }
    //MedCondTypeMissing
    if (!Utils.isNullOrEmpty(frontlineWorkerField.responseFilePaths)) {
      if (Utils.isNullOrEmpty(frontlineWorkerField.responseValues))
        validationErrMsg = validationErrMsg + '\n' + frontLineTypeMissingMsg;
    }
    //MedCOns fILE missing
    if (!Utils.isNullOrEmpty(frontlineWorkerField.responseValues)) {
      if (Utils.isNullOrEmpty(frontlineWorkerField.responseFilePaths))
        validationErrMsg = validationErrMsg + '\n' + frontLineFileMissingMsg;
    }

    if (Utils.isNotNullOrEmpty(validationErrMsg))
      return false;
    else
      return true;
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

  addIdProofFiles(File newImage) {
    _idProofimages.add(newImage);
    idProofField.responseFilePaths.add(newImage.path);
  }

  addFrontlineFiles(File newImage) {
    _frontLineProofimages.add(newImage);
    frontlineWorkerField.responseFilePaths.add(newImage.path);
  }

  addMedCondsFiles(File newImage) {
    _medCondsProofimages.add(newImage);
    medConditionsField.responseFilePaths.add(newImage.path);
  }

  Future<String> uploadFilesToServer(
      String localPath, String targetFileName) async {
    File localImage = File(localPath);

    Reference ref = _gs.firebaseStorage.ref().child('$targetFileName');

    await ref.putFile(localImage);

    return await ref.getDownloadURL();
  }

  Future<void> getGlobalState() async {
    _gs = await GlobalState.getGlobalState();
    _phCountryCode = _gs.getConfigurations().phCountryCode;
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

  _getAddressFromLatLng(Position position) async {
    setState(() {
      _latController.text = position.latitude.toString();
      _lonController.text = position.longitude.toString();
    });
  }

  void clearLocation() {
    _latController.text = "";
    _lonController.text = "";
  }

  Future<DateTime> pickDate(BuildContext context) async {
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
    return date;
  }

  Widget showImageList(
      BuildContext context, File imageUrl, List<File> filesList) {
    return Stack(
      alignment: AlignmentDirectional.topEnd,
      children: [
        Image.file(imageUrl),
        IconButton(
          alignment: Alignment.topRight,
          padding: EdgeInsets.zero,
          icon: Icon(
            Icons.cancel_outlined,
            size: 20,
            color: Colors.red[700],
          ),
          onPressed: () {
            setState(() {
              Utils.showConfirmationDialog(
                      context, "Are you sure you want to delete this image?")
                  .then((value) {
                if (value) {
                  print('REMOVE path in responsePaths $imageUrl');
                  setState(() {
                    filesList.removeWhere((element) => element == imageUrl);

                    // idProofField.responseFilePaths
                    //     .removeWhere((element) => element == imageUrl.path);
                  });
                }
              });
            });
          },
        )
      ],
    );
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
        autovalidateMode: AutovalidateMode.always,
        style: textInputTextStyle,
        controller: _nameController,
        keyboardType: TextInputType.text,
        decoration: CommonStyle.textFieldStyle(
            labelTextStr: nameInput != null ? nameInput.label : "",
            hintTextStr: "Please enter your name as per Government ID proof"),
        validator: validateText,
        onChanged: (String value) {
          nameInput.response = value;
        },
        onSaved: (String value) {
          nameInput.response = value;
        },
      );

      final dobField = TextFormField(
        obscureText: false,
        //minLines: 1,
        readOnly: true,
        autovalidateMode: AutovalidateMode.always,
        style: textInputTextStyle,
        controller: _dobController,
        decoration: CommonStyle.textFieldStyle(
            labelTextStr: dobInput.label, hintTextStr: ""),
        validator: validateText,
        onTap: () {
          setState(() {
            pickDate(context).then((value) {
              if (value != null) {
                setState(() {
                  insertOffer.startDateTime = value;
                  dateString = value.day.toString() +
                      " / " +
                      value.month.toString() +
                      " / " +
                      value.year.toString();
                  _dobController.text = dateString;
                  // checkOfferDetailsFilled();
                  offerFieldStatus = true;
                });
                dobInput.responseDateTime = value;
              }
            });
          });
        },
        maxLength: null,
        maxLines: 1,

        onChanged: (String value) {
          //  checkOfferDetailsFilled();
        },
        onSaved: (String value) {
          //  dobInput.responseDateTime = DateTime.parse(value);
          // checkOfferDetailsFilled();
        },
      );

      final descField = TextFormField(
        obscureText: false,
        //minLines: 1,
        style: textInputTextStyle,
        //controller: _descController,
        decoration: CommonStyle.textFieldStyle(
            labelTextStr: "Notes (optional)", hintTextStr: ""),
        keyboardType: TextInputType.multiline,
        maxLength: null,
        maxLines: 3,
        onSaved: (String value) {
          bookingApplication.notes = value;
        },
      );

      // final prefTimeSlotField = Row(
      //   children: [
      //     Text("Click to choose preferred Time-Slot"),
      //     IconButton(
      //         icon: Icon(Icons.date_range),
      //         onPressed: () {
      //           print("Show time- slots");

      //           pickDate(context).then((value) {
      //             if (value != null) {
      //               showAvailableSlotsPopUp(context, metaEntity, value);
      //             }
      //           });
      //         })
      //   ],
      // );
      final frontlineFieldInput = Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Wrap(
                  children: frontlineTypesList
                      .map((item) => GestureDetector(
                          onTap: () {
                            bool newSelectionValue = !(item.isSelected);
                            if (frontlineWorkerField.isMultiSelect == false) {
                              frontlineTypesList.forEach((element) {
                                element.isSelected = false;
                              });
                            }
                            if (item.isSelected == true)
                              frontlineWorkerField.responseValues
                                  .remove(item.value);
                            else
                              frontlineWorkerField.responseValues
                                  .add(item.value);

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
                              child: Text(item.value.value))))
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

      final idTypeField = Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Wrap(
                  alignment: WrapAlignment.center,
                  children: idProofTypesList
                      .map((item) => GestureDetector(
                          onTap: () {
                            bool newSelectionValue = !(item.isSelected);

                            if (idProofField.isMultiSelect == false) {
                              idProofTypesList.forEach((element) {
                                element.isSelected = false;
                              });
                            }

                            if (item.isSelected == true) {
                              idProofField.responseValues.remove(item.value);
                              _idProofType = null;
                            } else {
                              idProofField.responseValues.add(item.value);
                              _idProofType = item.value.value;
                            }
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
                              child: Text(item.value.value))))
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
      final clickPicForIdProofBtn = IconButton(
          padding: EdgeInsets.zero,
          icon: Icon(
            Icons.camera_alt_rounded,
            color: primaryDarkColor,
          ),
          onPressed: () {
            captureImage(false).then((value) {
              if (value != null) {
                addIdProofFiles(value);
              }
              setState(() {});
            });
          });
      final selectPicForIdProofBtn = IconButton(
          padding: EdgeInsets.zero,
          icon: Icon(
            Icons.attach_file,
            color: primaryDarkColor,
          ),
          onPressed: () {
            captureImage(true).then((value) {
              if (value != null) {
                addIdProofFiles(value);
              }
              setState(() {});
            });
          });
      final clickPicForMedCondsBtn = IconButton(
          padding: EdgeInsets.zero,
          icon: Icon(
            Icons.camera_alt_rounded,
            color: primaryDarkColor,
          ),
          onPressed: () {
            captureImage(false).then((value) {
              if (value != null) {
                addMedCondsFiles(value);
              }
              setState(() {});
            });
          });
      final selectPicsForMedCondsBtn = IconButton(
          padding: EdgeInsets.zero,
          icon: Icon(
            Icons.attach_file,
            color: primaryDarkColor,
          ),
          onPressed: () {
            captureImage(true).then((value) {
              if (value != null) {
                addMedCondsFiles(value);
              }
              setState(() {});
            });
          });
      final clickPicForfrontLineBtn = IconButton(
          padding: EdgeInsets.zero,
          icon: Icon(
            Icons.camera_alt_rounded,
            color: primaryDarkColor,
          ),
          onPressed: () {
            captureImage(false).then((value) {
              if (value != null) {
                addFrontlineFiles(value);
              }
              setState(() {});
            });
          });

      final selectPicForFrontLineBtn = IconButton(
          padding: EdgeInsets.zero,
          icon: Icon(
            Icons.attach_file,
            color: primaryDarkColor,
          ),
          onPressed: () {
            captureImage(true).then((value) {
              if (value != null) {
                addFrontlineFiles(value);
              }
              setState(() {});
            });
          });

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
                  children: medConditionsList
                      .map((item) => GestureDetector(
                          onTap: () {
                            bool newSelectionValue = !(item.isSelected);

                            if (item.value ==
                                medConditionsField.options[
                                    medConditionsField.defaultValueIndex]) {
                              if (!Utils.isNullOrEmpty(
                                      medConditionsField.responseValues) &&
                                  item.isSelected == false) {
                                print("returning");
                                return null;
                              }
                              if (Utils.isNullOrEmpty(
                                  medConditionsField.responseValues)) {
                                setState(() {
                                  item.isSelected = newSelectionValue;
                                });
                              }
                            }

                            if (Utils.isNullOrEmpty(
                                medConditionsField.responseValues)) {
                              medConditionsList.forEach((element) {
                                element.isSelected = false;
                              });
                            }

                            if (medConditionsField.isMultiSelect == false) {
                              medConditionsList.forEach((element) {
                                element.isSelected = false;
                              });
                            }
                            if (item.isSelected == true)
                              medConditionsField.responseValues
                                  .remove(item.value);
                            else {
                              medConditionsField.responseValues.add(item.value);
                            }

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
                              child: Text(item.value.value))))
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
      // final medicalConditionsDescField = TextFormField(
      //   obscureText: false,
      //   //minLines: 1,
      //   style: textInputTextStyle,
      //   controller: _medDescController,
      //   decoration: CommonStyle.textFieldStyle(
      //       labelTextStr: "Description of above condition (optional)",
      //       hintTextStr: ""),
      //   // validator: (String value) {
      //   //   if (!Utils.isNotNullOrEmpty(value)) {
      //   //     validationErrMsg = validationErrMsg + nameMissingMsg;
      //   //     return validationErrMsg;
      //   //   } else
      //   //     return null;
      //   // },
      //   keyboardType: TextInputType.multiline,
      //   maxLength: null,
      //   maxLines: 3,
      //   onChanged: (String value) {
      //     healthDetailsDesc.response = value;
      //   },
      //   onSaved: (String value) {
      //     healthDetailsDesc.response = value;
      //   },
      // );
      final primaryPhoneField = TextFormField(
        obscureText: false,
        maxLines: 1,
        minLines: 1,
        style: textInputTextStyle,
        keyboardType: TextInputType.phone,
        controller: _primaryPhoneController,
        decoration: InputDecoration(
          prefixText: '+91',
          labelText:
              (primaryPhone != null) ? primaryPhone.label : "Name of Applicant",
          enabledBorder:
              UnderlineInputBorder(borderSide: BorderSide(color: Colors.grey)),
          focusedBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.orange)),
        ),
        validator: (value) {
          if (validateField) {
            if (validateText(value) == null) {
              return Utils.validateMobileField(value);
            } else
              return null;
          } else
            return null;
        },
        onChanged: (value) {
          if (value != "")
            primaryPhone.responsePhone = _phCountryCode + (value);
        },
        onSaved: (String value) {
          if (value != "")
            primaryPhone.responsePhone = _phCountryCode + (value);
        },
      );
      // final alternatePhoneField = TextFormField(
      //   obscureText: false,
      //   maxLines: 1,
      //   minLines: 1,
      //   style: textInputTextStyle,
      //   keyboardType: TextInputType.phone,
      //   controller: _alternatePhoneController,
      //   decoration: InputDecoration(
      //     prefixText: '+91',
      //     labelText: 'Alternate Contact Number',
      //     enabledBorder:
      //         UnderlineInputBorder(borderSide: BorderSide(color: Colors.grey)),
      //     focusedBorder: UnderlineInputBorder(
      //         borderSide: BorderSide(color: Colors.orange)),
      //   ),
      //   validator: (value) {
      //     if (validateField) {
      //       if (validateText(value) == null) {
      //         return Utils.validateMobileField(value);
      //       } else
      //         return null;
      //     } else
      //       return null;
      //   },
      //   onChanged: (value) {
      //     if (value != "") alternatePhone.response = _phCountryCode + (value);
      //   },
      //   onSaved: (String value) {
      //     if (value != "") alternatePhone.response = _phCountryCode + (value);
      //   },
      // );

//       final latField = Container(
//           width: MediaQuery.of(context).size.width * .3,
//           child: TextFormField(
//             obscureText: false,
//             maxLines: 1,
//             minLines: 1,
//             enabled: false,
//             style: textInputTextStyle,
//             keyboardType: TextInputType.text,
//             controller: _latController,
//             decoration: CommonStyle.textFieldStyle(
//                 labelTextStr: "Latitude", hintTextStr: ""),
//             validator: (String value) {
//               if (!Utils.isNotNullOrEmpty(value)) {
//                 validationErrMsg = validationErrMsg + currLocMissingMsg;
//                 return validationErrMsg;
//               } else
//                 return null;
//             },
//             onChanged: (String value) {
//               latInput.response = value;
//             },
//             onSaved: (String value) {
//               latInput.response = value;
//             },
//           ));

//       final lonField = Container(
//           width: MediaQuery.of(context).size.width * .3,
//           child: TextFormField(
//             obscureText: false,
//             maxLines: 1,
//             minLines: 1,
//             enabled: false,
//             style: textInputTextStyle,
//             keyboardType: TextInputType.text,
//             controller: _lonController,
//             decoration: CommonStyle.textFieldStyle(
//                 labelTextStr: "Longitude", hintTextStr: ""),
//             validator: (value) {
//               return validateText(value);
//             },
//             onChanged: (String value) {
//               lonInput.response = value;
//             },
//             onSaved: (String value) {
//               lonInput.response = value;
//             },
//           ));
//       final clearBtn = Container(
//           width: MediaQuery.of(context).size.width * .3,
//           child: FlatButton(
//             //elevation: 20,
//             color: Colors.transparent,
//             splashColor: highlightColor,
//             textColor: btnColor,
//             shape: RoundedRectangleBorder(side: BorderSide(color: btnColor)),
//             child: Text(
//               'Clear',
//               textAlign: TextAlign.center,
//             ),
//             onPressed: clearLocation,
//           ));
// //Address fields
//       final adrsField1 = TextFormField(
//         obscureText: false,
//         maxLines: 1,
//         minLines: 1,
//         style: textInputTextStyle,
//         keyboardType: TextInputType.text,
//         controller: _adrs1Controller,
//         decoration: CommonStyle.textFieldStyle(
//             labelTextStr: "Apartment/ House No./ Lane", hintTextStr: ""),
//         // validator: validateText,
//         onChanged: (String value) {
//           addressInput.response = value;
//           print("changed address");
//         },
//         onSaved: (String value) {
//           addressInput.response = value;
//           print("saved address");
//         },
//       );
//       final landmarkField2 = TextFormField(
//         obscureText: false,
//         maxLines: 1,
//         minLines: 1,
//         style: textInputTextStyle,
//         keyboardType: TextInputType.text,
//         controller: _landController,
//         decoration: InputDecoration(
//           labelText: 'Landmark',
//           enabledBorder:
//               UnderlineInputBorder(borderSide: BorderSide(color: Colors.grey)),
//           focusedBorder: UnderlineInputBorder(
//               borderSide: BorderSide(color: Colors.orange)),
//         ),
//         //validator: validateText,
//         onChanged: (String value) {
//           addresslandmark.response = value;
//           print("changed landmark");
//         },
//         onSaved: (String value) {
//           addresslandmark.response = value;
//           print("saved landmark");
//         },
//       );
//       final localityField = TextFormField(
//         obscureText: false,
//         maxLines: 1,
//         minLines: 1,
//         style: textInputTextStyle,
//         controller: _localityController,
//         keyboardType: TextInputType.text,
//         decoration: InputDecoration(
//           labelText: 'Locality',
//           enabledBorder:
//               UnderlineInputBorder(borderSide: BorderSide(color: Colors.grey)),
//           focusedBorder: UnderlineInputBorder(
//               borderSide: BorderSide(color: Colors.orange)),
//         ),
//         // validator: validateText,
//         onSaved: (String value) {
//           addressLocality.response = value;
//           print("saved address");
//         },
//       );
//       final cityField = TextFormField(
//         obscureText: false,
//         maxLines: 1,
//         minLines: 1,
//         style: textInputTextStyle,
//         keyboardType: TextInputType.text,
//         controller: _cityController,
//         decoration: InputDecoration(
//           labelText: 'City',
//           enabledBorder:
//               UnderlineInputBorder(borderSide: BorderSide(color: Colors.grey)),
//           focusedBorder: UnderlineInputBorder(
//               borderSide: BorderSide(color: Colors.orange)),
//         ),
//         // validator: validateText,
//         onSaved: (String value) {
//           addressCity.response = value;
//           print("saved address");
//         },
//       );
//       final stateField = TextFormField(
//         obscureText: false,
//         maxLines: 1,
//         minLines: 1,
//         style: textInputTextStyle,
//         keyboardType: TextInputType.text,
//         controller: _stateController,
//         decoration: InputDecoration(
//           labelText: 'State',
//           enabledBorder:
//               UnderlineInputBorder(borderSide: BorderSide(color: Colors.grey)),
//           focusedBorder: UnderlineInputBorder(
//               borderSide: BorderSide(color: Colors.orange)),
//         ),
//         // validator: validateText,
//         onSaved: (String value) {
//           addressState.response = value;
//           print("saved address");
//         },
//       );
//       final countryField = TextFormField(
//         obscureText: false,
//         maxLines: 1,
//         minLines: 1,
//         style: textInputTextStyle,
//         keyboardType: TextInputType.text,
//         controller: _countryController,
//         decoration: InputDecoration(
//           labelText: 'Country',
//           enabledBorder:
//               UnderlineInputBorder(borderSide: BorderSide(color: Colors.grey)),
//           focusedBorder: UnderlineInputBorder(
//               borderSide: BorderSide(color: Colors.orange)),
//         ),
//         //validator: validateText,
//         onSaved: (String value) {
//           addressCountry.response = value;
//           print("saved address");
//         },
//       );
//       final pinField = TextFormField(
//         obscureText: false,
//         maxLines: 1,
//         minLines: 1,
//         style: textInputTextStyle,
//         keyboardType: TextInputType.number,
//         controller: _pinController,
//         decoration: InputDecoration(
//           labelText: 'Postal code',
//           enabledBorder:
//               UnderlineInputBorder(borderSide: BorderSide(color: Colors.grey)),
//           focusedBorder: UnderlineInputBorder(
//               borderSide: BorderSide(color: Colors.orange)),
//         ),
//         // validator: validateText,

//         onSaved: (String value) {
//           addressPin.response = value;
//           print("saved address");
//         },
//       );
      Flushbar flush;
      bool _wasButtonClicked;

      saveRoute() async {
        setState(() {
          validateField = true;
        });

        validationErrMsg = "";

        if (validateAllFields()) {
          Utils.showMyFlushbar(
              context,
              Icons.info_outline,
              Duration(
                seconds: 4,
              ),
              "Saving details!! ",
              "This would take just a moment.",
              null,
              Colors.white,
              true);

          _tokenBookingDetailsFormKey.currentState.save();

          // bookingApplication.preferredSlotTiming =
          //TODO:Save Files and then submit application with the updated file path
          List<String> idProofTargetPaths = List<String>();
          for (String path in idProofField.responseFilePaths) {
            String fileName = basename(path);
            print(fileName);

            String targetFileName =
                '${bookingApplication.id}#${idProofField.id}#${_gs.getCurrentUser().id}#$fileName';

            String targetPath = await uploadFilesToServer(path, targetFileName);
            print(targetPath);
            idProofTargetPaths.add(targetPath);
          }

          idProofField.responseFilePaths = idProofTargetPaths;

          List<String> medCondsTargetPaths = List<String>();
          for (String path in medConditionsField.responseFilePaths) {
            String fileName = basename(path);
            print(fileName);

            String targetFileName =
                '${bookingApplication.id}#${medConditionsField.id}#${_gs.getCurrentUser().id}#$fileName';

            String targetPath = await uploadFilesToServer(path, targetFileName);
            print(targetPath);
            medCondsTargetPaths.add(targetPath);
          }
          medConditionsField.responseFilePaths = medCondsTargetPaths;

          List<String> frontLineTargetPaths = [];
          for (String path in frontlineWorkerField.responseFilePaths) {
            String fileName = basename(path);
            print(fileName);

            String targetFileName =
                '${bookingApplication.id}#${frontlineWorkerField.id}#${_gs.getCurrentUser().id}#$fileName';

            String targetPath = await uploadFilesToServer(path, targetFileName);
            print(targetPath);
            frontLineTargetPaths.add(targetPath);
          }

          frontlineWorkerField.responseFilePaths = frontLineTargetPaths;

          _gs
              .getApplicationService()
              .submitApplication(bookingApplication, metaEntity)
              .then((value) {
            if (value != null) {
              Utils.showMyFlushbar(
                  context,
                  Icons.check,
                  Duration(
                    seconds: 5,
                  ),
                  "Request submitted successfully!",
                  'Your request is successfuly submitted for the review.',
                  successGreenSnackBar);
            }
          });
        } else {
          print(validationErrMsg);
          Utils.showMyFlushbar(
              context,
              Icons.error,
              Duration(
                seconds: 10,
              ),
              validationErrMsg,
              "Please fill all mandatory fields and save again.",
              Colors.red);
        }
      }

      backRoute() {
        Navigator.of(context).push(PageAnimation.createRoute(widget.backRoute));
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
              title: Text("Booking Request Form",
                  style: TextStyle(color: Colors.white, fontSize: 16)),
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
                                      primaryPhoneField,
                                      // alternatePhoneField,
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
                                            frontlineWorkerField.label,
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
                                    frontlineFieldInput,
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        (Utils.isNullOrEmpty(
                                                frontlineWorkerField
                                                    .responseFilePaths))
                                            ? Container(
                                                child: Text(
                                                "No Image Selected",
                                                style: TextStyle(
                                                    color: (validateField)
                                                        ? Colors.red
                                                        : Colors.black),
                                              ))
                                            : Container(
                                                width: MediaQuery.of(context)
                                                        .size
                                                        .width *
                                                    .6,
                                                child: ListView.builder(
                                                  padding: EdgeInsets.all(
                                                      MediaQuery.of(context)
                                                              .size
                                                              .width *
                                                          .03),
                                                  //  controller: _childScrollController,
                                                  scrollDirection:
                                                      Axis.vertical,

                                                  shrinkWrap: true,
                                                  //   itemExtent: itemSize,
                                                  //scrollDirection: Axis.vertical,
                                                  itemBuilder:
                                                      (BuildContext context,
                                                          int index) {
                                                    return Container(
                                                      padding: EdgeInsets.only(
                                                          bottom: 5),
                                                      child: showImageList(
                                                          context,
                                                          _frontLineProofimages[
                                                              index],
                                                          _frontLineProofimages),
                                                    );
                                                  },
                                                  itemCount:
                                                      _frontLineProofimages
                                                          .length,
                                                ),
                                              ),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.end,
                                          children: [
                                            clickPicForfrontLineBtn,
                                            selectPicForFrontLineBtn
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
                                            idProofField.label,
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
                                                child: Text(
                                                    idProofField.infoMessage,
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
                                        (Utils.isNullOrEmpty(
                                                idProofField.responseFilePaths))
                                            ? Container(
                                                child: Text(
                                                "No Image Selected",
                                                style: TextStyle(
                                                    color: (validateField)
                                                        ? Colors.red
                                                        : Colors.black),
                                              ))
                                            : Container(
                                                width: MediaQuery.of(context)
                                                        .size
                                                        .width *
                                                    .6,
                                                child: ListView.builder(
                                                  padding: EdgeInsets.all(
                                                      MediaQuery.of(context)
                                                              .size
                                                              .width *
                                                          .03),
                                                  //  controller: _childScrollController,
                                                  scrollDirection:
                                                      Axis.vertical,

                                                  shrinkWrap: true,
                                                  //   itemExtent: itemSize,
                                                  //scrollDirection: Axis.vertical,
                                                  itemBuilder:
                                                      (BuildContext context,
                                                          int index) {
                                                    return Container(
                                                      padding: EdgeInsets.only(
                                                          bottom: 5),
                                                      child: showImageList(
                                                          context,
                                                          _idProofimages[index],
                                                          _idProofimages),
                                                    );
                                                  },
                                                  itemCount:
                                                      _idProofimages.length,
                                                ),
                                              ),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.end,
                                          children: [
                                            clickPicForIdProofBtn,
                                            selectPicForIdProofBtn
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
                                            medConditionsField.label,
                                            style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 15),
                                            overflow: TextOverflow.ellipsis,
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
                                                child: Text(
                                                    medConditionsField
                                                        .infoMessage,
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
                                      medicalConditionsField,
                                      //medicalConditionsDescField,

                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          (Utils.isNullOrEmpty(idProofField
                                                  .responseFilePaths))
                                              ? Container(
                                                  child: Text(
                                                  "No Image Selected",
                                                  style: TextStyle(
                                                      color: (validateField)
                                                          ? Colors.red
                                                          : Colors.black),
                                                ))
                                              : Container(
                                                  width: MediaQuery.of(context)
                                                          .size
                                                          .width *
                                                      .6,
                                                  child: ListView.builder(
                                                    padding: EdgeInsets.all(
                                                        MediaQuery.of(context)
                                                                .size
                                                                .width *
                                                            .03),
                                                    //  controller: _childScrollController,
                                                    scrollDirection:
                                                        Axis.vertical,

                                                    shrinkWrap: true,
                                                    //   itemExtent: itemSize,
                                                    //scrollDirection: Axis.vertical,
                                                    itemBuilder:
                                                        (BuildContext context,
                                                            int index) {
                                                      return Container(
                                                        padding:
                                                            EdgeInsets.only(
                                                                bottom: 5),
                                                        child: showImageList(
                                                            context,
                                                            _medCondsProofimages[
                                                                index],
                                                            _medCondsProofimages),
                                                      );
                                                    },
                                                    itemCount:
                                                        _medCondsProofimages
                                                            .length,
                                                  ),
                                                ),
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.end,
                                            children: [
                                              clickPicForMedCondsBtn,
                                              selectPicsForMedCondsBtn,
                                            ],
                                          ),
                                        ],
                                      ),
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
                      //                       "Current Location Details",
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
                      //                           child: Text(locationInfoStr,
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
                      //             Column(children: <Widget>[
                      //               Container(
                      //                 padding: EdgeInsets.all(4),
                      //                 width: MediaQuery.of(context).size.width *
                      //                     .95,
                      //                 child: RichText(
                      //                     text: TextSpan(
                      //                         style: highlightSubTextStyle,
                      //                         children: <TextSpan>[
                      //                       TextSpan(
                      //                           text: pressUseCurrentLocation),
                      //                       TextSpan(
                      //                           text: whyLocationIsRequired),
                      //                     ])),
                      //               ),
                      //               Row(
                      //                 mainAxisAlignment:
                      //                     MainAxisAlignment.spaceAround,
                      //                 children: <Widget>[
                      //                   latField,
                      //                   lonField,
                      //                 ],
                      //               ),
                      //               verticalSpacer,
                      //             ]),
                      //             Row(
                      //               mainAxisAlignment:
                      //                   MainAxisAlignment.spaceAround,
                      //               children: <Widget>[
                      //                 clearBtn,
                      //                 Container(
                      //                   width:
                      //                       MediaQuery.of(context).size.width *
                      //                           .6,
                      //                   child: RaisedButton(
                      //                     elevation: 10,
                      //                     color: btnColor,
                      //                     splashColor: highlightColor,
                      //                     textColor: Colors.white,
                      //                     shape: RoundedRectangleBorder(
                      //                         side:
                      //                             BorderSide(color: btnColor)),
                      //                     child: Text(
                      //                       userCurrentLoc,
                      //                       textAlign: TextAlign.center,
                      //                     ),
                      //                     onPressed: useCurrLocation,
                      //                   ),
                      //                 ),
                      //               ],
                      //             ),
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
                      //                       "Address",
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
                      //                           child: Text(addressInfoStr,
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
                      //             adrsField1,
                      //             landmarkField2,
                      //             localityField,
                      //             cityField,
                      //             stateField,
                      //             pinField,
                      //             countryField,
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
                      //   padding: EdgeInsets.only(left: 5.0, right: 5),
                      //   decoration: BoxDecoration(
                      //       border: Border.all(color: containerColor),
                      //       color: Colors.grey[50],
                      //       shape: BoxShape.rectangle,
                      //       borderRadius:
                      //           BorderRadius.all(Radius.circular(5.0))),
                      //   //padding: EdgeInsets.all(5.0),
                      //   child: prefTimeSlotField,
                      // ),
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
                      (Utils.isNotNullOrEmpty(bookingForm.footerMsg)
                          ? Container(
                              padding: EdgeInsets.only(left: 5.0, right: 5),
                              decoration: BoxDecoration(
                                  border: Border.all(color: containerColor),
                                  color: Colors.grey[50],
                                  shape: BoxShape.rectangle,
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(5.0))),
                              //padding: EdgeInsets.all(5.0),
                              child: Text(
                                bookingForm.footerMsg,
                                // bookingForm.footerMsg,
                                style: TextStyle(
                                    color: Colors.orangeAccent.shade700,
                                    //fontWeight: FontWeight.w600,
                                    fontFamily: 'Montserrat',

                                    // decoration: TextDecoration.underline,
                                    fontSize: 16.0),
                              ),
                            )
                          : Container()),
                      SizedBox(
                        height: 7,
                      ),
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
              title: Text("Booking Request Form",
                  style: TextStyle(color: Colors.white, fontSize: 16)),
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
  Value value;
  bool isSelected;
  String lastSelected;

  Item(this.value, this.isSelected);
}
