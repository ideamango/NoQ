import 'dart:async';
import 'dart:io';
import 'package:LESSs/db/exceptions/MaxTokenReachedByUserPerDayException.dart';
import 'package:LESSs/db/exceptions/MaxTokenReachedByUserPerSlotException.dart';
import 'package:LESSs/pages/search_entity_page.dart';
import 'package:LESSs/pages/token_alert.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:another_flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import '../SlotSelectionPage.dart';
import '../constants.dart';
import '../db/db_model/booking_application.dart';
import '../db/db_model/booking_form.dart';
import '../db/db_model/meta_entity.dart';
import '../db/exceptions/slot_full_exception.dart';
import '../db/exceptions/token_already_exists_exception.dart';
import '../enum/application_status.dart';
import '../enum/field_type.dart';
import '../global_state.dart';
import '../services/circular_progress.dart';

import '../style.dart';
import '../utils.dart';
import '../widget/custom_expansion_tile.dart';
import 'package:email_validator/email_validator.dart';
import 'package:path/path.dart' as pathfile;

class CreateFormFields extends StatefulWidget {
  final MetaEntity metaEntity;
  final String bookingFormId;
  final DateTime preferredSlotTime;
  final bool isOnlineToken;
  final dynamic backRoute;
  CreateFormFields(
      {Key key,
      @required this.metaEntity,
      @required this.bookingFormId,
      @required this.preferredSlotTime,
      @required this.isOnlineToken,
      @required this.backRoute})
      : super(key: key);

  @override
  _CreateFormFieldsState createState() => _CreateFormFieldsState();
}

class _CreateFormFieldsState extends State<CreateFormFields> {
  TextEditingController _fieldController = new TextEditingController();
  Map<String, TextEditingController> listOfFieldControllers =
      new Map<String, TextEditingController>();

  final GlobalKey<FormState> _bookingFormKey = new GlobalKey<FormState>();
  List<TextEditingController> _controllers = [];
  BookingForm dummyForm;
  final itemSize = 100.0;
  List<String> dumList = [];

  bool _initCompleted = false;

  //List<File> _medCondsProofimages = [];
  bool validateField = false;
  Map<String, Widget> listOfWidgets = new Map<String, Widget>();
  Map<String, List> listOfFieldTypes = new Map<String, List>();
  String dateString = "Start Date";
  String validationErrMsg;
  List<Field> listOfFields;
  String _phCountryCode;
  String flushStatus = "Empty";
  Flushbar flush;
  bool _wasButtonClicked;
  BookingApplication bookingApplication;
  GlobalState _gs;
  ScrollController yearController =
      new ScrollController(initialScrollOffset: 0);
  int _radioBookingPref = -1;
  @override
  void initState() {
    super.initState();
    getGlobalState().whenComplete(() {
      _gs
          .getApplicationService()
          .getBookingForm(widget.bookingFormId)
          .then((value) {
        dummyForm = value;
        bookingApplication = new BookingApplication();
        //slot
        bookingApplication.preferredSlotTiming = widget.preferredSlotTime;

        //bookingFormId
        bookingApplication.bookingFormId = widget.bookingFormId;
        bookingApplication.entityId = widget.metaEntity.entityId;
        // bookingApplication.userId = _gs.getCurrentUser().ph;
        bookingApplication.status = ApplicationStatus.NEW;
        bookingApplication.responseForm = dummyForm;
        print("Booking application set");
        initPage();
        setState(() {
          _initCompleted = true;
        });
      });
    });
  }

  void initPage() {
    listOfFields = dummyForm.getFormFields();
    Widget newField;
    for (int i = 0; i < listOfFields.length; i++) {
      Field field = listOfFields[i];
      newField = buildChildItem(field, i, true);
      listOfWidgets[field.label] = newField;
    }
  }

  Future<void> getGlobalState() async {
    _gs = await GlobalState.getGlobalState();
    _phCountryCode = _gs.getConfigurations().phCountryCode;
  }

  Future<DateTime> pickAnyYear(BuildContext context, DateTime date) async {
    int fromYear = date.year - 100;
    List<int> displayYears = [];
    for (int i = 100; i >= 0; i--) {
      displayYears.add(fromYear + i);
    }

    DateTime returnVal = await showDialog(
        context: context,
        builder: (BuildContext context) {
          DateTime selectedYear = date;
          return StatefulBuilder(builder: (context, setState) {
            return AlertDialog(
              titlePadding: EdgeInsets.all(5),
              contentPadding: EdgeInsets.fromLTRB(5, 20, 5, 20),
              title: Container(
                height: MediaQuery.of(context).size.height * .08,
                alignment: Alignment.centerLeft,
                padding: EdgeInsets.fromLTRB(15, 15, 15, 10),
                color: Colors.cyan,
                child: Text("Year ${selectedYear.year.toString()}",
                    style: TextStyle(
                        color: Colors.white, fontWeight: FontWeight.normal)),
              ),
              content: SingleChildScrollView(
                child: Container(
                    height: MediaQuery.of(context).size.height * .5,
                    width: MediaQuery.of(context).size.width * .4,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          // color: Colors.blue,
                          height: MediaQuery.of(context).size.height * .45,
                          width: MediaQuery.of(context).size.width * .45,
                          child: ListView.builder(
                              itemCount: displayYears.length,
                              controller: yearController,
                              scrollDirection: Axis.vertical,
                              itemBuilder: (BuildContext ctxt, int index) {
                                return new Container(
                                  margin: EdgeInsets.all(10),
                                  height: 47,
                                  child: MaterialButton(
                                    elevation: 5,
                                    visualDensity: VisualDensity.compact,
                                    padding: EdgeInsets.zero,
                                    color: (selectedYear.year ==
                                            displayYears[index])
                                        ? Colors.cyan
                                        : Colors.white,
                                    textColor: (selectedYear.year ==
                                            displayYears[index])
                                        ? Colors.white
                                        : Colors.blueGrey[600],
                                    shape: CircleBorder(
                                      side: BorderSide(
                                          color: (selectedYear.year ==
                                                  displayYears[index])
                                              ? Colors.cyan[300]
                                              : Colors.cyan[300]),
                                    ),
                                    child: Text(
                                      displayYears[index].toString(),
                                      style: TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.normal),
                                    ),
                                    onPressed: () {
                                      setState(() {
                                        selectedYear = DateTime(
                                            (displayYears[index]), 01, 01);
                                      });
                                    },
                                  ),
                                );
                              }),
                        ),
                        //   SizedBox(
                        //     height: 47,
                        //     child: MaterialButton(
                        //       visualDensity: VisualDensity.compact,
                        //       padding: EdgeInsets.zero,
                        //       color: (selectedYear.year == date.year - 1)
                        //           ? Colors.cyan
                        //           : Colors.transparent,
                        //       textColor: (selectedYear.year == date.year - 1)
                        //           ? Colors.white
                        //           : Colors.blueGrey[600],
                        //       shape: CircleBorder(
                        //         side: BorderSide(
                        //             color: (selectedYear.year == date.year - 1)
                        //                 ? Colors.white
                        //                 : Colors.transparent),
                        //       ),
                        //       child: Text(
                        //         (date.year - 1).toString(),
                        //         style: TextStyle(
                        //             fontSize: 15, fontWeight: FontWeight.normal),
                        //       ),
                        //       onPressed: () {
                        //         setState(() {
                        //           yearStr = (date.year - 1).toString();
                        //           selectedYear =
                        //               DateTime(date.year - 1, date.month, date.day);
                        //         });
                        //       },
                        //     ),
                        //   ),
                        //   SizedBox(
                        //     height: 47,
                        //     child: FlatButton(
                        //       visualDensity: VisualDensity.compact,
                        //       padding: EdgeInsets.zero,
                        //       color: (selectedYear.year == date.year)
                        //           ? Colors.cyan
                        //           : Colors.transparent,
                        //       textColor: (selectedYear.year == date.year)
                        //           ? Colors.white
                        //           : Colors.blueGrey[600],
                        //       shape: CircleBorder(
                        //         side: BorderSide(
                        //             color: (selectedYear.year == date.year - 1)
                        //                 ? Colors.white
                        //                 : Colors.transparent),
                        //       ),
                        //       child: Text(
                        //         (date.year).toString(),
                        //         style: TextStyle(
                        //             fontSize: 15, fontWeight: FontWeight.normal),
                        //       ),
                        //       onPressed: () {
                        //         setState(() {
                        //           yearStr = (date.year).toString();
                        //           selectedYear = date;
                        //         });
                        //       },
                        //     ),
                        //   ),
                        //   SizedBox(
                        //     height: 47,
                        //     child: FlatButton(
                        //       visualDensity: VisualDensity.compact,
                        //       padding: EdgeInsets.zero,
                        //       color: (selectedYear.year == date.year + 1)
                        //           ? Colors.cyan
                        //           : Colors.transparent,
                        //       textColor: (selectedYear.year == date.year + 1)
                        //           ? Colors.white
                        //           : Colors.blueGrey[600],
                        //       shape: CircleBorder(
                        //         side: BorderSide(
                        //             color: (selectedYear.year == date.year - 1)
                        //                 ? Colors.white
                        //                 : Colors.transparent),
                        //       ),
                        //       child: Text(
                        //         (date.year + 1).toString(),
                        //         style: TextStyle(
                        //             fontSize: 15, fontWeight: FontWeight.normal),
                        //       ),
                        //       onPressed: () {
                        //         setState(() {
                        //           yearStr = (date.year + 1).toString();
                        //           selectedYear =
                        //               DateTime(date.year + 1, date.month, date.day);
                        //         });
                        //       },
                        //     ),
                        //   ),
                        //
                      ],
                    )),
              ),
              actions: <Widget>[
                SizedBox(
                  height: 30,
                  child: FlatButton(
                    color: Colors.transparent,
                    textColor: btnColor,
                    // shape: RoundedRectangleBorder(
                    //     side: BorderSide(color: btnColor),
                    //     borderRadius: BorderRadius.all(Radius.circular(3.0))),
                    child: Text(
                      'CANCEL',
                      style: TextStyle(fontSize: 14),
                    ),
                    onPressed: () {
                      Navigator.of(context).pop(date);
                    },
                  ),
                ),
                SizedBox(
                  height: 30,
                  child: FlatButton(
                    color: Colors.transparent,
                    textColor: btnColor,
                    // shape: RoundedRectangleBorder(
                    //     side: BorderSide(color: btnColor),
                    //     borderRadius: BorderRadius.all(Radius.circular(3.0))),
                    child: Text(
                      'OK',
                      style: TextStyle(fontSize: 14),
                    ),
                    onPressed: () {
                      Navigator.of(context).pop(selectedYear);
                    },
                  ),
                ),
              ],
            );
          });
        });

    return returnVal;
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
                primary: Colors.cyanAccent.shade700,
                primaryVariant: Colors.amber,
                onSecondary: Colors.cyan),
            dialogBackgroundColor: Colors.white,
          ),
          child: child,
        );
      },
    );
    return date;
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

  Widget buildChildItem(Field field, int index, bool isInit) {
    if (isInit) {
      //If field has text controller add to listOfFieldControllers
      //If options field add to listOfOptionsField
      if (field.type != FieldType.OPTIONS &&
          field.type != FieldType.ATTACHMENT &&
          field.type != FieldType.OPTIONS_ATTACHMENTS) {
        if (!listOfFieldControllers.containsKey(field.label)) {
          listOfFieldControllers[field.label] = new TextEditingController();
        }
      }
    }
    Widget newField;
    switch (field.type) {
      case FieldType.TEXT:
        {
          FormInputFieldText textField = field;
          newField = Container(
            margin: EdgeInsets.fromLTRB(5, 5, 5, 5),
            decoration: BoxDecoration(
                border: Border.all(color: Colors.black),
                color: Colors.grey[50],
                shape: BoxShape.rectangle,
                borderRadius: BorderRadius.all(Radius.circular(5.0))),
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Column(children: <Widget>[
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
                          title: Container(
                            width: MediaQuery.of(context).size.width * .8,
                            child: AutoSizeText(
                              (field.isMandatory)
                                  ? field.label + ' (mandatory)'
                                  : field.label + ' (optional)',
                              maxLines: 2,
                              minFontSize: 8,
                              maxFontSize: 14,
                              style: TextStyle(
                                color: Colors.white,
                              ),
                            ),
                          ),
                          backgroundColor: Colors.blueGrey[500],

                          children: <Widget>[
                            new Container(
                              width: MediaQuery.of(context).size.width * .94,
                              //decoration: darkContainer,
                              color: containerColor,
                              padding: EdgeInsets.only(left: 7),
                              child: Row(
                                children: <Widget>[
                                  Expanded(
                                    child: Text(field.infoMessage,
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
                        children: [
                          Container(
                            //   margin: EdgeInsets.fromLTRB(10, 5, 10, 5),
                            padding: EdgeInsets.all(10),
                            child: TextFormField(
                              obscureText: false,
                              maxLines: 1,
                              minLines: 1,
                              autovalidateMode: validateField
                                  ? AutovalidateMode.always
                                  : AutovalidateMode.disabled,
                              validator: (value) {
                                if (Utils.isNotNullOrEmpty(value)) {
                                  if (textField.isEmail) {
                                    return EmailValidator.validate(value)
                                        ? null
                                        : "Please enter a valid Email";
                                  }
                                } else if (field.isMandatory &&
                                    validateField &&
                                    Utils.isStrNullOrEmpty(value)) {
                                  return "Field is empty";
                                }
                                return null;

                                // String valText = validateText(value);
                                // if (textField.isEmail) {
                                //   return (valText == null)
                                //       ? (EmailValidator.validate(value)
                                //           ? null
                                //           : "Please enter a valid email")
                                //       : valText;
                                // } else
                                //   return valText;
                              },
                              //validator: validateText,
                              style: textInputTextStyle,
                              keyboardType: TextInputType.text,
                              controller: listOfFieldControllers[field.label],
                              decoration: CommonStyle.textFieldStyle(
                                labelTextStr: field.label,
                                // hintTextStr: field.infoMessage
                              ),
                              onChanged: (String value) {
                                textField.response = value;
                                print(value);
                              },
                              onSaved: (String value) {
                                textField.response = value;
                                print(value);
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ]),
                ]),
          );
        }
        break;
      case FieldType.DATETIME:
        {
          FormInputFieldDateTime newDateField = field;
          newField = Container(
            margin: EdgeInsets.fromLTRB(5, 5, 5, 5),
            decoration: BoxDecoration(
                border: Border.all(color: containerColor),
                color: Colors.grey[50],
                shape: BoxShape.rectangle,
                borderRadius: BorderRadius.all(Radius.circular(5.0))),
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: <
                    Widget>[
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
                          AutoSizeText(
                            (field.isMandatory)
                                ? field.label + ' (mandatory)'
                                : field.label + ' (optional)',
                            maxLines: 2,
                            minFontSize: 11,
                            maxFontSize: 14,
                            style: TextStyle(color: Colors.white),
                          ),
                          SizedBox(width: 5),
                        ],
                      ),
                      backgroundColor: Colors.blueGrey[500],

                      children: <Widget>[
                        new Container(
                          padding: EdgeInsets.only(left: 7),
                          width: MediaQuery.of(context).size.width * .94,
                          //decoration: darkContainer,
                          color: containerColor,
                          //padding: EdgeInsets.all(2.0),
                          child: Row(
                            children: <Widget>[
                              Expanded(
                                child: Text(field.infoMessage,
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
                    children: [
                      Container(
                        //   margin: EdgeInsets.fromLTRB(10, 5, 10, 5),
                        padding: EdgeInsets.all(10),
                        child: TextFormField(
                          obscureText: false,
                          readOnly: true,
                          maxLines: 1,
                          minLines: 1,
                          autovalidateMode: AutovalidateMode.always,
                          validator: (value) {
                            if (validateField &&
                                newDateField.isMandatory &&
                                Utils.isStrNullOrEmpty(value)) {
                              return "Field is empty";
                            } else
                              return null;
                          },
                          style: textInputTextStyle,
                          keyboardType: TextInputType.text,
                          controller:
                              listOfFieldControllers[newDateField.label],
                          decoration: CommonStyle.textFieldStyle(
                              labelTextStr: newDateField.label,
                              hintTextStr: newDateField.label),
                          onTap: () {
                            if (newDateField.yearOnly) {
                              setState(() {
                                pickAnyYear(context, DateTime.now())
                                    .then((value) {
                                  if (value != null) {
                                    print(value);

                                    listOfFieldControllers[newDateField.label]
                                        .text = value.year.toString();

                                    setState(() {
                                      newDateField.responseDateTime = value;
                                    });
                                  }
                                });
                              });
                            } else {
                              pickDate(context).then((value) {
                                if (value != null) {
                                  setState(() {
                                    dateString = value.day.toString() +
                                        " / " +
                                        value.month.toString() +
                                        " / " +
                                        value.year.toString();
                                    listOfFieldControllers[newDateField.label]
                                        .text = dateString;
                                  });
                                  newDateField.responseDateTime = value;
                                }
                              });
                            }
                          },
                          maxLength: null,
                          onChanged: (String value) {
                            print(value);
                          },
                          onSaved: (String value) {
                            print(value);
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ]),
            ]),
          );
        }
        break;

      // case FieldType.EMAIL:
      //   {
      //     FormInputFieldPhone emailField = field;
      //     newField = Container(
      //       margin: EdgeInsets.fromLTRB(5, 5, 5, 5),
      //       decoration: BoxDecoration(
      //           border: Border.all(color: containerColor),
      //           color: Colors.grey[50],
      //           shape: BoxShape.rectangle,
      //           borderRadius: BorderRadius.all(Radius.circular(5.0))),
      //       child:
      //           Column(crossAxisAlignment: CrossAxisAlignment.start, children: <
      //               Widget>[
      //         Column(children: <Widget>[
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
      //                       emailField.label,
      //                       style: TextStyle(color: Colors.white, fontSize: 15),
      //                     ),
      //                     SizedBox(width: 5),
      //                   ],
      //                 ),
      //                 backgroundColor: Colors.blueGrey[500],

      //                 children: <Widget>[
      //                   new Container(
      //                     width: MediaQuery.of(context).size.width * .94,
      //                     decoration: darkContainer,
      //                     padding: EdgeInsets.all(2.0),
      //                     child: Row(
      //                       children: <Widget>[
      //                         Expanded(
      //                           child: Text(emailField.infoMessage,
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
      //               children: [
      //                 Container(
      //                     margin: EdgeInsets.fromLTRB(10, 5, 10, 5),
      //                     child: TextFormField(
      //                       obscureText: false,
      //                       maxLines: 1,
      //                       autovalidateMode: AutovalidateMode.always,
      //                       minLines: 1,
      //                       style: textInputTextStyle,
      //                       keyboardType: TextInputType.emailAddress,
      //                       controller: listOfControllers[emailField.label],
      //                       decoration: InputDecoration(
      //                         prefixText: '+91',
      //                         labelText: emailField.label,
      //                         enabledBorder: UnderlineInputBorder(
      //                             borderSide: BorderSide(color: Colors.grey)),
      //                         focusedBorder: UnderlineInputBorder(
      //                             borderSide: BorderSide(color: Colors.orange)),
      //                       ),
      //                       validator: (value) => EmailValidator.validate(value)
      //                           ? null
      //                           : "Please enter a valid email",
      //                       onChanged: (value) {
      //                         if (value != "") emailField.response = (value);
      //                       },
      //                       onSaved: (String value) {
      //                         if (value != "") emailField.response = (value);
      //                       },
      //                     )),
      //               ],
      //             ),
      //           ),
      //         ]),
      //       ]),
      //     );
      //   }
      //   break;
      case FieldType.PHONE:
        {
          FormInputFieldPhone phone = field;
          newField = Container(
            margin: EdgeInsets.fromLTRB(5, 5, 5, 5),
            decoration: BoxDecoration(
                border: Border.all(color: containerColor),
                color: Colors.grey[50],
                shape: BoxShape.rectangle,
                borderRadius: BorderRadius.all(Radius.circular(5.0))),
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
                              AutoSizeText(
                                (field.isMandatory)
                                    ? field.label + ' (mandatory)'
                                    : field.label + ' (optional)',
                                maxLines: 2,
                                minFontSize: 11,
                                maxFontSize: 14,
                                style: TextStyle(color: Colors.white),
                              ),
                              SizedBox(width: 5),
                            ],
                          ),
                          backgroundColor: Colors.blueGrey[500],

                          children: <Widget>[
                            new Container(
                              width: MediaQuery.of(context).size.width * .94,
                              color: containerColor,
                              padding: EdgeInsets.only(left: 7),
                              child: Row(
                                children: <Widget>[
                                  Expanded(
                                    child: Text(phone.infoMessage,
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
                        children: [
                          Container(
                              margin: EdgeInsets.fromLTRB(10, 5, 10, 5),
                              child: TextFormField(
                                obscureText: false,
                                maxLines: 1,
                                autovalidateMode: AutovalidateMode.always,
                                minLines: 1,
                                style: textInputTextStyle,
                                keyboardType: TextInputType.phone,
                                controller: listOfFieldControllers[phone.label],
                                decoration: InputDecoration(
                                  prefixText: '+91',
                                  labelText: phone.label,
                                  enabledBorder: UnderlineInputBorder(
                                      borderSide:
                                          BorderSide(color: Colors.grey)),
                                  focusedBorder: UnderlineInputBorder(
                                      borderSide:
                                          BorderSide(color: Colors.orange)),
                                ),
                                validator: (value) {
                                  if (Utils.isNotNullOrEmpty(value)) {
                                    return Utils.validateMobileField(value);
                                  } else if (validateField &&
                                      phone.isMandatory &&
                                      Utils.isStrNullOrEmpty(value)) {
                                    return "Field is empty";
                                  }
                                  return null;
                                },
                                onChanged: (value) {
                                  if (value != "")
                                    phone.responsePhone =
                                        _phCountryCode + (value);
                                },
                                onSaved: (String value) {
                                  if (value != "")
                                    phone.responsePhone =
                                        _phCountryCode + (value);
                                },
                              )),
                        ],
                      ),
                    ),
                  ]),
                ]),
          );
        }
        break;
      case FieldType.NUMBER:
        {
          newField = Container(
            margin: EdgeInsets.fromLTRB(5, 5, 5, 5),
            decoration: BoxDecoration(
                border: Border.all(color: containerColor),
                color: Colors.grey[50],
                shape: BoxShape.rectangle,
                borderRadius: BorderRadius.all(Radius.circular(5.0))),
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
                              AutoSizeText(
                                (field.isMandatory)
                                    ? field.label + ' (mandatory)'
                                    : field.label + ' (optional)',
                                maxLines: 2,
                                minFontSize: 11,
                                maxFontSize: 14,
                                style: TextStyle(
                                  color: Colors.white,
                                ),
                              ),
                              SizedBox(width: 5),
                            ],
                          ),
                          backgroundColor: Colors.blueGrey[500],

                          children: <Widget>[
                            new Container(
                              width: MediaQuery.of(context).size.width * .94,
                              color: containerColor,
                              padding: EdgeInsets.only(left: 7),
                              child: Row(
                                children: <Widget>[
                                  Expanded(
                                    child: Text(field.infoMessage,
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
                        children: [
                          Container(
                            margin: EdgeInsets.fromLTRB(10, 5, 10, 5),
                            child: TextFormField(
                              obscureText: false,
                              maxLines: 1,
                              minLines: 1,
                              validator: validateText,
                              style: textInputTextStyle,
                              keyboardType: TextInputType.number,
                              controller: listOfFieldControllers[field.label],
                              decoration: CommonStyle.textFieldStyle(
                                  labelTextStr: field.label,
                                  hintTextStr: field.label),
                              onChanged: (String value) {
                                print(value);
                              },
                              onSaved: (String value) {
                                print(value);
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ]),
                ]),
          );
        }
        break;
      case FieldType.OPTIONS:
        {
          FormInputFieldOptions newOptionsField = field;

          newField = Container(
            margin: EdgeInsets.fromLTRB(5, 5, 5, 5),
            decoration: BoxDecoration(
                border: Border.all(color: containerColor),
                color: Colors.grey[50],
                shape: BoxShape.rectangle,
                borderRadius: BorderRadius.all(Radius.circular(5.0))),
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: <
                    Widget>[
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
                          AutoSizeText(
                              (newOptionsField.isMandatory)
                                  ? newOptionsField.label + ' (mandatory)'
                                  : newOptionsField.label + ' (optional)',
                              maxLines: 2,
                              minFontSize: 11,
                              maxFontSize: 14,
                              style: TextStyle(
                                color: Colors.white,
                              )),
                          SizedBox(width: 5),
                        ],
                      ),
                      backgroundColor: Colors.blueGrey[500],

                      children: <Widget>[
                        new Container(
                          width: MediaQuery.of(context).size.width * .94,
                          color: containerColor,
                          padding: EdgeInsets.only(left: 7),
                          child: Row(
                            children: <Widget>[
                              Expanded(
                                child: Text(newOptionsField.infoMessage,
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
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Wrap(
                              children: newOptionsField.options
                                  .map((item) => GestureDetector(
                                      onTap: () {
                                        if (newOptionsField.responseValues
                                            .contains(item)) {
                                          newOptionsField.responseValues
                                              .remove(item);
                                        } else {
                                          if (newOptionsField.isMultiSelect ==
                                              false) {
                                            newOptionsField.responseValues
                                                .clear();
                                          }
                                          newOptionsField.responseValues
                                              .add(item);
                                        }

                                        setState(() {});
                                      },
                                      child: Container(
                                          decoration: new BoxDecoration(
                                              border: Border.all(
                                                  color: Colors.blueGrey[200]),
                                              shape: BoxShape.rectangle,
                                              color: (newOptionsField
                                                      .responseValues
                                                      .contains(item))
                                                  ? highlightColor
                                                  : Colors.cyan[50],
                                              borderRadius: BorderRadius.all(
                                                  Radius.circular(30.0))),
                                          padding:
                                              EdgeInsets.fromLTRB(8, 5, 8, 5),
                                          margin: EdgeInsets.all(8),
                                          // color: Colors.orange,
                                          child: Text(item.value))))
                                  .toList()
                                  .cast<Widget>(),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ]),
            ]),
          );
        }
        break;
      case FieldType.ATTACHMENT:
        {
          FormInputFieldAttachment attsField = field;

          newField = Container(
            margin: EdgeInsets.fromLTRB(5, 5, 5, 5),
            decoration: BoxDecoration(
                border: Border.all(color: containerColor),
                color: Colors.grey[50],
                shape: BoxShape.rectangle,
                borderRadius: BorderRadius.all(Radius.circular(5.0))),
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: <
                    Widget>[
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
                          AutoSizeText(
                            (attsField.isMandatory)
                                ? attsField.label + ' (mandatory)'
                                : attsField.label + ' (optional)',
                            maxLines: 2,
                            minFontSize: 11,
                            maxFontSize: 14,
                            style: TextStyle(
                              color: Colors.white,
                            ),
                          ),
                          SizedBox(width: 5),
                        ],
                      ),
                      backgroundColor: Colors.blueGrey[500],

                      children: <Widget>[
                        new Container(
                          width: MediaQuery.of(context).size.width * .94,
                          color: containerColor,
                          padding: EdgeInsets.only(left: 7),
                          child: Row(
                            children: <Widget>[
                              Expanded(
                                child: Text(attsField.infoMessage,
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
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      (Utils.isNullOrEmpty(attsField.responseFilePaths))
                          ? Container(
                              child: Text(
                              "No Image Selected",
                              style: TextStyle(
                                  color:
                                      (validateField && attsField.isMandatory)
                                          ? Colors.red
                                          : Colors.black),
                            ))
                          : Container(
                              width: MediaQuery.of(context).size.width * .6,
                              child: ListView.builder(
                                padding: EdgeInsets.all(
                                    MediaQuery.of(context).size.width * .03),
                                //  controller: _childScrollController,
                                scrollDirection: Axis.vertical,

                                shrinkWrap: true,
                                //   itemExtent: itemSize,
                                //scrollDirection: Axis.vertical,
                                itemBuilder: (BuildContext context, int index) {
                                  return Container(
                                    margin: EdgeInsets.symmetric(vertical: 3),
                                    decoration: BoxDecoration(
                                        border:
                                            Border.all(color: containerColor),
                                        color: Colors.grey[50],
                                        shape: BoxShape.rectangle,
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(5.0))),
                                    padding: EdgeInsets.all(5),
                                    child: showImageList(
                                        context,
                                        attsField.responseFilePaths[index],
                                        attsField.responseFilePaths),
                                  );
                                },
                                itemCount: attsField.responseFilePaths.length,
                              ),
                            ),
                      Container(
                        alignment: Alignment.bottomCenter,
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            IconButton(
                                padding: EdgeInsets.zero,
                                icon: Icon(
                                  Icons.camera_alt_rounded,
                                  color: primaryDarkColor,
                                ),
                                onPressed: () {
                                  if (attsField.responseFilePaths.length <
                                      attsField.maxAttachments) {
                                    captureImage(false).then((value) {
                                      if (value != null) {
                                        // _medCondsProofimages.add(value);
                                        attsField.responseFilePaths
                                            .add(value.path);
                                      }
                                      setState(() {});
                                    });
                                  } else {
                                    Utils.showMyFlushbar(
                                        context,
                                        Icons.info,
                                        Duration(
                                          seconds: 5,
                                        ),
                                        "Only ${attsField.maxAttachments} files at max could be attached.",
                                        '');
                                  }
                                }),
                            IconButton(
                                padding: EdgeInsets.zero,
                                icon: Icon(
                                  Icons.attach_file,
                                  color: primaryDarkColor,
                                ),
                                onPressed: () {
                                  if (attsField.responseFilePaths.length <
                                      attsField.maxAttachments) {
                                    captureImage(true).then((value) {
                                      if (value != null) {
                                        // _medCondsProofimages.add(value);
                                        attsField.responseFilePaths
                                            .add(value.path);
                                      }
                                      setState(() {});
                                    });
                                  } else {
                                    Utils.showMyFlushbar(
                                        context,
                                        Icons.info,
                                        Duration(
                                          seconds: 5,
                                        ),
                                        "Only ${attsField.maxAttachments} files at max could be attached.",
                                        '');
                                  }
                                }),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ]),
            ]),
          );
        }
        break;
      case FieldType.OPTIONS_ATTACHMENTS:
        {
          FormInputFieldOptionsWithAttachments optsAttsField = field;

          newField = Container(
            margin: EdgeInsets.fromLTRB(5, 5, 5, 5),
            decoration: BoxDecoration(
                border: Border.all(color: containerColor),
                color: Colors.grey[50],
                shape: BoxShape.rectangle,
                borderRadius: BorderRadius.all(Radius.circular(5.0))),
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: <
                    Widget>[
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
                          Container(
                            width: MediaQuery.of(context).size.width * .74,
                            child: AutoSizeText(
                              (optsAttsField.isMandatory)
                                  ? optsAttsField.label + ' (mandatory)'
                                  : optsAttsField.label + ' (optional)',
                              maxLines: 2,
                              minFontSize: 8,
                              maxFontSize: 14,
                              style: TextStyle(
                                color: Colors.white,
                              ),
                            ),
                          ),
                          SizedBox(width: 5),
                        ],
                      ),
                      backgroundColor: Colors.blueGrey[500],

                      children: <Widget>[
                        new Container(
                          width: MediaQuery.of(context).size.width * .94,
                          color: containerColor,
                          padding: EdgeInsets.only(left: 7),
                          child: Row(
                            children: <Widget>[
                              Expanded(
                                child: Text(optsAttsField.infoMessage,
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
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Wrap(
                              children: optsAttsField.options
                                  .map((item) => GestureDetector(
                                      onTap: () {
                                        if (optsAttsField.responseValues
                                            .contains(item)) {
                                          optsAttsField.responseValues
                                              .remove(item);
                                        } else {
                                          if (optsAttsField.isMultiSelect ==
                                              false) {
                                            optsAttsField.responseValues
                                                .clear();
                                          }
                                          optsAttsField.responseValues
                                              .add(item);
                                        }

                                        setState(() {});
                                      },
                                      child: Container(
                                          decoration: new BoxDecoration(
                                              border: Border.all(
                                                  color: Colors.blueGrey[200]),
                                              shape: BoxShape.rectangle,
                                              color: (optsAttsField
                                                      .responseValues
                                                      .contains(item))
                                                  ? highlightColor
                                                  : Colors.cyan[50],
                                              borderRadius: BorderRadius.all(
                                                  Radius.circular(30.0))),
                                          padding:
                                              EdgeInsets.fromLTRB(8, 5, 8, 5),
                                          margin: EdgeInsets.all(8),
                                          // color: Colors.orange,
                                          child: Text(item.value))))
                                  .toList()
                                  .cast<Widget>(),
                            ),
                          ),
                        ],
                      ),
                      Divider(
                        thickness: 1.5,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          (Utils.isNullOrEmpty(optsAttsField.responseFilePaths))
                              ? Container(
                                  child: Text(
                                  "No Image Selected",
                                  style: TextStyle(
                                      color: (validateField)
                                          ? Colors.red
                                          : Colors.black),
                                ))
                              : Container(
                                  width: MediaQuery.of(context).size.width * .6,
                                  child: ListView.builder(
                                    padding: EdgeInsets.all(
                                        MediaQuery.of(context).size.width *
                                            .03),
                                    //  controller: _childScrollController,
                                    scrollDirection: Axis.vertical,

                                    shrinkWrap: true,
                                    //   itemExtent: itemSize,
                                    //scrollDirection: Axis.vertical,
                                    itemBuilder:
                                        (BuildContext context, int index) {
                                      return Container(
                                        margin:
                                            EdgeInsets.symmetric(vertical: 3),
                                        decoration: BoxDecoration(
                                            border: Border.all(
                                                color: containerColor),
                                            color: Colors.grey[50],
                                            shape: BoxShape.rectangle,
                                            borderRadius: BorderRadius.all(
                                                Radius.circular(5.0))),
                                        child: showImageList(
                                            context,
                                            optsAttsField
                                                .responseFilePaths[index],
                                            optsAttsField.responseFilePaths),
                                      );
                                    },
                                    itemCount:
                                        optsAttsField.responseFilePaths.length,
                                  ),
                                ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              IconButton(
                                  padding: EdgeInsets.zero,
                                  icon: Icon(
                                    Icons.camera_alt_rounded,
                                    color: primaryDarkColor,
                                  ),
                                  onPressed: () {
                                    if (optsAttsField.responseFilePaths.length <
                                        optsAttsField.maxAttachments) {
                                      captureImage(false).then((value) {
                                        if (value != null) {
                                          //  _medCondsProofimages.add(value);
                                          optsAttsField.responseFilePaths
                                              .add(value.path);
                                        }
                                        setState(() {});
                                      });
                                    } else {
                                      Utils.showMyFlushbar(
                                          context,
                                          Icons.info,
                                          Duration(
                                            seconds: 5,
                                          ),
                                          "Only ${optsAttsField.maxAttachments} files at max could be attached.",
                                          '');
                                    }
                                  }),
                              IconButton(
                                  padding: EdgeInsets.zero,
                                  icon: Icon(
                                    Icons.attach_file,
                                    color: primaryDarkColor,
                                  ),
                                  onPressed: () {
                                    if (optsAttsField.responseFilePaths.length <
                                        optsAttsField.maxAttachments) {
                                      captureImage(true).then((value) {
                                        if (value != null) {
                                          //  _medCondsProofimages.add(value);
                                          optsAttsField.responseFilePaths
                                              .add(value.path);
                                        }
                                        setState(() {});
                                      });
                                    } else {
                                      Utils.showMyFlushbar(
                                          context,
                                          Icons.info,
                                          Duration(
                                            seconds: 5,
                                          ),
                                          "Only ${optsAttsField.maxAttachments} files at max could be attached.",
                                          '');
                                    }
                                  }),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ]),
            ]),
          );
        }
        break;
      default:
        {
          newField = Container(
            margin: EdgeInsets.fromLTRB(5, 5, 5, 5),
            decoration: BoxDecoration(
                border: Border.all(color: containerColor),
                color: Colors.grey[50],
                shape: BoxShape.rectangle,
                borderRadius: BorderRadius.all(Radius.circular(5.0))),
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
                              AutoSizeText(
                                (field.isMandatory)
                                    ? field.label + ' (mandatory)'
                                    : field.label + ' (optional)',
                                maxLines: 2,
                                minFontSize: 11,
                                maxFontSize: 14,
                                style: TextStyle(
                                  color: Colors.white,
                                ),
                              ),
                              SizedBox(width: 5),
                            ],
                          ),
                          backgroundColor: Colors.blueGrey[500],

                          children: <Widget>[
                            new Container(
                              width: MediaQuery.of(context).size.width * .94,
                              color: containerColor,
                              padding: EdgeInsets.only(left: 7),
                              child: Row(
                                children: <Widget>[
                                  Expanded(
                                    child: Text(field.infoMessage,
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
                        children: [
                          TextFormField(
                            obscureText: false,
                            maxLines: 1,
                            minLines: 1,
                            style: textInputTextStyle,
                            validator: validateText,
                            keyboardType: TextInputType.text,
                            controller: listOfFieldControllers[field.label],
                            decoration: CommonStyle.textFieldStyle(
                                labelTextStr: field.label,
                                hintTextStr: field.label),
                            onChanged: (String value) {
                              print(value);
                            },
                            onSaved: (String value) {
                              print(value);
                            },
                          ),
                        ],
                      ),
                    ),
                  ]),
                ]),
          );
        }
        break;
    }

    return Container(
      color: Colors.white70,
      child: newField,
    );
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

  Widget showImageList(
      BuildContext context, String imageUrl, List<String> filesList) {
    File image = File(imageUrl);
    return Stack(
      alignment: AlignmentDirectional.topEnd,
      children: [
        Image.file(image),
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

  Future<String> uploadFilesToServer(
      String localPath, String targetFileName) async {
    File localImage = File(localPath);

    Reference ref = _gs.firebaseStorage.ref().child('$targetFileName');

    await ref.putFile(localImage);

    return await ref.getDownloadURL();
  }

  bool validateMandatoryFields() {
    for (int i = 0; i < listOfFields.length; i++) {
      if (listOfFields[i].type != FieldType.OPTIONS &&
          listOfFields[i].type != FieldType.ATTACHMENT &&
          listOfFields[i].type != FieldType.OPTIONS_ATTACHMENTS) {
        if (listOfFields[i].isMandatory) {
          if (!Utils.isNotNullOrEmpty(
              listOfFieldControllers[listOfFields[i].label].text)) {
            validationErrMsg = validationErrMsg +
                (Utils.isNotNullOrEmpty(validationErrMsg)
                    ? ", ${listOfFields[i].label}"
                    : "${listOfFields[i].label}");
          }
        }
      }
    }
    if (Utils.isNotNullOrEmpty(validationErrMsg)) {
      validationErrMsg =
          'Please provide all mandatory information like $validationErrMsg.';
      return false;
    } else
      return true;
  }

  saveRoute() async {
    ///**Validation Starts */
    validationErrMsg = "";
    setState(() {
      validateField = true;
    });
    if (_bookingFormKey.currentState.validate()) {
      if (!validateMandatoryFields()) {
        Utils.showMyFlushbar(
            context,
            Icons.error,
            Duration(
              seconds: 8,
            ),
            validationErrMsg,
            '',
            Colors.red,
            Colors.white);
        return;
      }
      //***Handle the Options and Attachments field.****
      List<Field> listOfFields =
          bookingApplication.responseForm.getFormFields();
      for (int i = 0; i < listOfFields.length; i++) {
        switch (listOfFields[i].type) {
          case FieldType.OPTIONS:
            FormInputFieldOptions f = listOfFields[i] as FormInputFieldOptions;
            if (f.isMandatory && f.responseValues.length == 0) {
              validationErrMsg = '${f.label} is empty.';
              Utils.showMyFlushbar(
                  context,
                  Icons.error,
                  Duration(
                    seconds: 5,
                  ),
                  validationErrMsg,
                  'Please provide all mandatory information and try again.',
                  Colors.red,
                  Colors.white);
              return;
            }
            break;
          case FieldType.ATTACHMENT:
            FormInputFieldAttachment f =
                listOfFields[i] as FormInputFieldAttachment;
            if (f.isMandatory && f.responseFilePaths.length == 0) {
              validationErrMsg = '${f.label} is empty.';
              Utils.showMyFlushbar(
                  context,
                  Icons.error,
                  Duration(
                    seconds: 5,
                  ),
                  validationErrMsg,
                  'Please provide all mandatory information and try again.',
                  Colors.red,
                  Colors.white);
              return;
            } else {
              List<String> targetPaths = [];
              for (String path in (listOfFields[i] as FormInputFieldAttachment)
                  .responseFilePaths) {
                String fileName = pathfile.basename(path);
                print(fileName);

                String targetFileName =
                    '${bookingApplication.id}#${(listOfFields[i] as FormInputFieldAttachment).id}#${_gs.getCurrentUser().id}#$fileName';

                String targetPath =
                    await uploadFilesToServer(path, targetFileName);
                print(targetPath);
                targetPaths.add(targetPath);
                (bookingApplication.responseForm.getFormFields()[i]
                        as FormInputFieldAttachment)
                    .responseFilePaths = targetPaths;
              }
            }

            break;
          case FieldType.OPTIONS_ATTACHMENTS:
            FormInputFieldOptionsWithAttachments f =
                listOfFields[i] as FormInputFieldOptionsWithAttachments;
            if (f.isMandatory &&
                (f.responseFilePaths.length == 0 ||
                    f.responseValues.length == 0)) {
              validationErrMsg = '${f.label} is empty.';
              Utils.showMyFlushbar(
                  context,
                  Icons.error,
                  Duration(
                    seconds: 5,
                  ),
                  validationErrMsg,
                  'Please provide all mandatory information and try again.',
                  Colors.red,
                  Colors.white);
              return;
            } else {
              print("df");
              List<String> targetPaths = [];
              for (String path
                  in (listOfFields[i] as FormInputFieldOptionsWithAttachments)
                      .responseFilePaths) {
                String fileName = pathfile.basename(path);
                print(fileName);

                String targetFileName =
                    '${bookingApplication.id}#${(listOfFields[i] as FormInputFieldOptionsWithAttachments).id}#${_gs.getCurrentUser().id}#$fileName';

                String targetPath =
                    await uploadFilesToServer(path, targetFileName);
                print(targetPath);
                targetPaths.add(targetPath);
                (bookingApplication.responseForm.getFormFields()[i]
                        as FormInputFieldOptionsWithAttachments)
                    .responseFilePaths = targetPaths;
              }
            }
            break;
          default:
            break;
        }
      }

      ///**Validation Ends */

      Utils.showMyFlushbar(
          context,
          Icons.info,
          Duration(
            seconds: 5,
          ),
          "Processing your Request..",
          '');
      if (Utils.isStrNullOrEmpty(validationErrMsg)) {
        _bookingFormKey.currentState.save();
        _gs
            .getApplicationService()
            .submitApplication(
                bookingApplication, widget.metaEntity, widget.isOnlineToken)
            .then((token) {
          if (token != null) {
            final dtFormat = new DateFormat(dateDisplayFormat);
            String _dateFormatted =
                dtFormat.format(bookingApplication.preferredSlotTiming);
            String time =
                " ${Utils.formatTime(bookingApplication.preferredSlotTiming.hour.toString())} : ${Utils.formatTime(bookingApplication.preferredSlotTiming.minute.toString())}";
            Future.delayed(Duration(seconds: 2)).then((value) {
              showTokenAlert(
                      context,
                      token.parent.isOnlineAppointment
                          ? tokenTextH2Online
                          : tokenTextH2Walkin,
                      token.getDisplayName(),
                      widget.metaEntity.name,
                      _dateFormatted,
                      time)
                  .then((value) {
                Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                        builder: (context) => SearchEntityPage()));
              });
            });
          } else {
            //The application could not be submitted, Show appropriate msg to User.

            showMessageDialog(
                    context,
                    "Request submitted successfully!",
                    'We will contact you as soon as slot opens up. Stay Safe!',
                    'Ok')
                .then((value) => Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                        builder: (context) => SearchEntityPage())));
          }
        }).catchError((error) {
          switch (error.runtimeType) {
            case MaxTokenReachedByUserPerDayException:
              print("max token reached");
              Utils.showMyFlushbar(context, Icons.error, Duration(seconds: 6),
                  maxTokenLimitReached, maxTokenLimitReachedSub);
              break;
            case MaxTokenReachedByUserPerSlotException:
              Utils.showMyFlushbar(context, Icons.error, Duration(seconds: 6),
                  maxTokenForTimeReached, maxTokenLimitReachedSub);
              print("max per slot reached");
              break;
            case TokenAlreadyExistsException:
              Utils.showMyFlushbar(context, Icons.error, Duration(seconds: 6),
                  tokenAlreadyExists, selectDateSub);
              print("token exists");
              break;
            case SlotFullException:
              Utils.showMyFlushbar(context, Icons.error, Duration(seconds: 6),
                  slotsAlreadyBooked, selectDateSub);
              print("slot full ");
              break;
            default:
              break;
          }
        });
      }
    } else {
      print("Fields not vbalid");
      Utils.showMyFlushbar(
          context,
          Icons.error,
          Duration(
            seconds: 5,
          ),
          validationErrMsg,
          'Please provide all mandatory information and try again.',
          Colors.red,
          Colors.white);
    }
  }

  processSaveWithTimer() async {
    var duration = new Duration(seconds: 0);
    return new Timer(duration, saveRoute);
  }

  void _handleBookingPrefChange(int value) {
    setState(() {
      _radioBookingPref = value;
      //set values in application
      switch (_radioBookingPref) {
        case 0:
          break;
        case 1:
          break;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_initCompleted)
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
                        if (_wasButtonClicked) Navigator.of(context).pop();
                      });
                  }

                  print("flush already running");
                },
              ),
              title: Text(dummyForm.formName,
                  style: TextStyle(color: Colors.white, fontSize: 16)),
            ),
            body: Center(
              child: SafeArea(
                child: Form(
                  key: _bookingFormKey,
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        Container(
                          margin: EdgeInsets.fromLTRB(0, 12, 0, 0),
                          width: MediaQuery.of(context).size.width * .913,
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
                                              "Selected Time Slot",
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
                                            color: containerColor,
                                            padding: EdgeInsets.only(left: 7),
                                            child: Row(
                                              children: <Widget>[
                                                Expanded(
                                                  child: Text(
                                                      "Time of your appointment for this place",
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
                                    padding: EdgeInsets.fromLTRB(5, 8, 5, 5),
                                    child: Column(
                                      children: <Widget>[
                                        Column(
                                          children: [
                                            Row(
                                              children: [
                                                SizedBox(
                                                    // width: cardWidth * .45,
                                                    child: AutoSizeText(
                                                  "Current time-slot :",
                                                  //group: labelGroup,
                                                  minFontSize: 15,
                                                  maxFontSize: 15,
                                                  maxLines: 2,
                                                  overflow: TextOverflow.clip,
                                                  style: fieldLabelTextStyle,
                                                )),
                                                Wrap(children: [
                                                  Container(
                                                    padding: EdgeInsets.only(
                                                        left: 5),
                                                    child: AutoSizeText(
                                                        ((bookingApplication
                                                                    .preferredSlotTiming !=
                                                                null)
                                                            ? DateFormat(
                                                                    'yyyy-MM-dd – HH:mm')
                                                                .format(bookingApplication
                                                                    .preferredSlotTiming)
                                                            : "None"),
                                                        // group: medCondGroup,
                                                        minFontSize: 12,
                                                        maxFontSize: 14,
                                                        maxLines: 1,
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                        style: TextStyle(
                                                          color: btnColor,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                        )),
                                                  ),
                                                ]),
                                              ],
                                            ),
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.start,
                                              children: [
                                                AutoSizeText(
                                                  "Click to choose another Time-Slot",
                                                  // group: labelGroup,
                                                  minFontSize: 15,
                                                  maxFontSize: 15,
                                                  maxLines: 2,
                                                  overflow: TextOverflow.clip,
                                                  style: fieldLabelTextStyle,
                                                ),
                                                IconButton(
                                                    icon: Icon(
                                                      Icons.date_range,
                                                      color: btnColor,
                                                    ),
                                                    onPressed: () async {
                                                      final result =
                                                          await Navigator.push(
                                                              context,
                                                              MaterialPageRoute(
                                                                  builder:
                                                                      (context) =>
                                                                          SlotSelectionPage(
                                                                            metaEntity:
                                                                                widget.metaEntity,
                                                                            dateTime:
                                                                                bookingApplication.preferredSlotTiming,
                                                                            forPage:
                                                                                "ApplicationList",
                                                                          )));

                                                      print(result);
                                                      setState(() {
                                                        if (result != null)
                                                          bookingApplication
                                                                  .preferredSlotTiming =
                                                              result;
                                                      });
                                                    })
                                              ],
                                            ),
                                          ],
                                        ),

                                        // alternatePhoneField,
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        ListView.builder(
                          padding: EdgeInsets.all(
                              MediaQuery.of(context).size.width * .026),
                          shrinkWrap: true,
                          physics: ClampingScrollPhysics(),
                          itemBuilder: (BuildContext context, int index) {
                            _controllers.add(new TextEditingController());
                            return Container(
                              //color: Colors.grey,
                              //   height: MediaQuery.of(context).size.height * .55,
                              width: MediaQuery.of(context).size.width * .95,
                              child: buildChildItem(
                                  dummyForm.getFormFields()[index],
                                  index,
                                  false),
                            );
                          },
                          itemCount: dummyForm.getFormFields().length,
                        ),
                        Container(
                          margin: EdgeInsets.fromLTRB(10, 10, 10, 14),
                          child: Column(
                            children: [
                              //********TODO Phase2 : DONT DELETE *********************
                              //       Container(
                              //         padding: EdgeInsets.all(0),
                              //         height:
                              //             MediaQuery.of(context).size.height * .05,
                              //         child: Row(
                              //           children: [
                              //             new Radio(
                              //               value: 0,
                              //               visualDensity: VisualDensity.compact,
                              //               activeColor: Colors.cyan,
                              //               groupValue: _radioBookingPref,
                              //               onChanged: _handleBookingPrefChange,
                              //             ),
                              //             new Text(
                              //               "Book only if selected Time-Slot is available.",
                              //               style: new TextStyle(fontSize: 12.0),
                              //             ),
                              //           ],
                              //         ),
                              //       ),
                              //       Row(
                              //         children: [
                              //           new Radio(
                              //             value: 1,
                              //             visualDensity: VisualDensity.compact,
                              //             activeColor: Colors.cyan,
                              //             groupValue: _radioBookingPref,
                              //             onChanged: _handleBookingPrefChange,
                              //           ),
                              //           new Text(
                              //             "Book next available Time-Slot.",
                              //             style: new TextStyle(fontSize: 12.0),
                              //           ),
                              //         ],
                              //       ),
                              //********TODO Phase2 : DONT DELETE *********************
                              MaterialButton(
                                  elevation: 8,
                                  color: btnColor,
                                  splashColor: highlightColor,
                                  child: Container(
                                    padding: EdgeInsets.all(10),
                                    // margin: EdgeInsets.all(10),
                                    width:
                                        MediaQuery.of(context).size.width * .84,
                                    child: Column(
                                      children: <Widget>[
                                        Text(
                                          'Save Details & Request Token',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.w500,
                                            fontFamily: 'Montserrat',
                                            letterSpacing: 1.3,
                                            fontSize: MediaQuery.of(context)
                                                    .size
                                                    .width *
                                                .04,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  onPressed: () {
                                    print("FlushbarStatus-------");
                                    processSaveWithTimer();
                                  }),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          onWillPop: () async {
            return true;
          },
        ),
      );
    else {
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
}
