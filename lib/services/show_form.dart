import 'dart:async';
import 'dart:io';
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

class EntityForm extends StatefulWidget {
  final MetaEntity metaEntity;
  final String bookingFormId;
  final DateTime preferredSlotTime;
  final dynamic backRoute;
  EntityForm(
      {Key key,
      @required this.metaEntity,
      @required this.bookingFormId,
      @required this.preferredSlotTime,
      @required this.backRoute})
      : super(key: key);

  @override
  _EntityFormState createState() => _EntityFormState();
}

class _EntityFormState extends State<EntityForm> {
  TextEditingController _fieldController = new TextEditingController();
  Map<String, TextEditingController> listOfControllers =
      new Map<String, TextEditingController>();

  final GlobalKey<FormState> _bookingFormKey = new GlobalKey<FormState>();
  List<TextEditingController> _controllers = new List();
  BookingForm dummyForm;
  final itemSize = 100.0;
  List<String> dumList = new List<String>();

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
        bookingApplication.userId = _gs.getCurrentUser().id;
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
      if (!listOfControllers.containsKey(field.label)) {
        listOfControllers[field.label] = new TextEditingController();
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
                border: Border.all(color: containerColor),
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
                          unselectedWidgetColor: Colors.grey[400],
                          accentColor: Colors.black,
                        ),
                        child: CustomExpansionTile(
                          //key: PageStorageKey(this.widget.headerTitle),
                          initiallyExpanded: false,
                          title: Row(
                            children: <Widget>[
                              Text(
                                field.label,
                                style: TextStyle(
                                    color: Colors.white, fontSize: 15),
                              ),
                              SizedBox(width: 5),
                            ],
                          ),
                          backgroundColor: Colors.blueGrey[500],

                          children: <Widget>[
                            new Container(
                              width: MediaQuery.of(context).size.width * .94,
                              decoration: darkContainer,
                              padding: EdgeInsets.all(2.0),
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
                                String valText = validateText(value);
                                if (textField.isEmail) {
                                  return (valText == null)
                                      ? (EmailValidator.validate(value)
                                          ? null
                                          : "Please enter a valid email")
                                      : valText;
                                } else
                                  return valText;
                              },
                              //validator: validateText,
                              style: textInputTextStyle,
                              keyboardType: TextInputType.text,
                              controller: listOfControllers[field.label],
                              decoration: CommonStyle.textFieldStyle(
                                labelTextStr: field.label,
                                // hintTextStr: field.infoMessage
                              ),
                              onChanged: (String value) {
                                return;
                              },
                              onSaved: (String value) {},
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
                                field.label,
                                style: TextStyle(
                                    color: Colors.white, fontSize: 15),
                              ),
                              SizedBox(width: 5),
                            ],
                          ),
                          backgroundColor: Colors.blueGrey[500],

                          children: <Widget>[
                            new Container(
                              width: MediaQuery.of(context).size.width * .94,
                              decoration: darkContainer,
                              padding: EdgeInsets.all(2.0),
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
                              validator: validateText,
                              style: textInputTextStyle,
                              keyboardType: TextInputType.text,
                              controller: listOfControllers[newDateField.label],
                              decoration: CommonStyle.textFieldStyle(
                                  labelTextStr: newDateField.label,
                                  hintTextStr: newDateField.label),
                              onTap: () {
                                setState(() {
                                  pickDate(context).then((value) {
                                    if (value != null) {
                                      setState(() {
                                        dateString = value.day.toString() +
                                            " / " +
                                            value.month.toString() +
                                            " / " +
                                            value.year.toString();
                                        listOfControllers[newDateField.label]
                                            .text = dateString;
                                      });
                                      newDateField.responseDateTime = value;
                                    }
                                  });
                                });
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
                          Text(
                            phone.label,
                            style: TextStyle(color: Colors.white, fontSize: 15),
                          ),
                          SizedBox(width: 5),
                        ],
                      ),
                      backgroundColor: Colors.blueGrey[500],

                      children: <Widget>[
                        new Container(
                          width: MediaQuery.of(context).size.width * .94,
                          decoration: darkContainer,
                          padding: EdgeInsets.all(2.0),
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
                            controller: listOfControllers[phone.label],
                            decoration: InputDecoration(
                              prefixText: '+91',
                              labelText: phone.label,
                              enabledBorder: UnderlineInputBorder(
                                  borderSide: BorderSide(color: Colors.grey)),
                              focusedBorder: UnderlineInputBorder(
                                  borderSide: BorderSide(color: Colors.orange)),
                            ),
                            validator: (value) {
                              if (validateText(value) == null) {
                                return Utils.validateMobileField(value);
                              } else
                                return null;
                            },
                            onChanged: (value) {
                              if (value != "")
                                phone.responsePhone = _phCountryCode + (value);
                            },
                            onSaved: (String value) {
                              if (value != "")
                                phone.responsePhone = _phCountryCode + (value);
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
                              Text(
                                field.label,
                                style: TextStyle(
                                    color: Colors.white, fontSize: 15),
                              ),
                              SizedBox(width: 5),
                            ],
                          ),
                          backgroundColor: Colors.blueGrey[500],

                          children: <Widget>[
                            new Container(
                              width: MediaQuery.of(context).size.width * .94,
                              decoration: darkContainer,
                              padding: EdgeInsets.all(2.0),
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
                              controller: listOfControllers[field.label],
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
                          Text(
                            newOptionsField.label,
                            style: TextStyle(color: Colors.white, fontSize: 15),
                          ),
                          SizedBox(width: 5),
                        ],
                      ),
                      backgroundColor: Colors.blueGrey[500],

                      children: <Widget>[
                        new Container(
                          width: MediaQuery.of(context).size.width * .94,
                          decoration: darkContainer,
                          padding: EdgeInsets.all(2.0),
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
                          Text(
                            attsField.label,
                            style: TextStyle(color: Colors.white, fontSize: 15),
                          ),
                          SizedBox(width: 5),
                        ],
                      ),
                      backgroundColor: Colors.blueGrey[500],

                      children: <Widget>[
                        new Container(
                          width: MediaQuery.of(context).size.width * .94,
                          decoration: darkContainer,
                          padding: EdgeInsets.all(2.0),
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
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          (Utils.isNullOrEmpty(attsField.responseFilePaths))
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
                                        padding: EdgeInsets.only(bottom: 5),
                                        child: showImageList(
                                            context,
                                            attsField.responseFilePaths[index],
                                            attsField.responseFilePaths),
                                      );
                                    },
                                    itemCount:
                                        attsField.responseFilePaths.length,
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
                                    captureImage(false).then((value) {
                                      if (value != null) {
                                        // _medCondsProofimages.add(value);
                                        attsField.responseFilePaths
                                            .add(value.path);
                                      }
                                      setState(() {});
                                    });
                                  }),
                              IconButton(
                                  padding: EdgeInsets.zero,
                                  icon: Icon(
                                    Icons.attach_file,
                                    color: primaryDarkColor,
                                  ),
                                  onPressed: () {
                                    captureImage(true).then((value) {
                                      if (value != null) {
                                        // _medCondsProofimages.add(value);
                                        attsField.responseFilePaths
                                            .add(value.path);
                                      }
                                      setState(() {});
                                    });
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
                          Text(
                            optsAttsField.label,
                            style: TextStyle(color: Colors.white, fontSize: 15),
                          ),
                          SizedBox(width: 5),
                        ],
                      ),
                      backgroundColor: Colors.blueGrey[500],

                      children: <Widget>[
                        new Container(
                          width: MediaQuery.of(context).size.width * .94,
                          decoration: darkContainer,
                          padding: EdgeInsets.all(2.0),
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
                                        padding: EdgeInsets.only(bottom: 5),
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
                                    captureImage(false).then((value) {
                                      if (value != null) {
                                        //  _medCondsProofimages.add(value);
                                        optsAttsField.responseFilePaths
                                            .add(value.path);
                                      }
                                      setState(() {});
                                    });
                                  }),
                              IconButton(
                                  padding: EdgeInsets.zero,
                                  icon: Icon(
                                    Icons.attach_file,
                                    color: primaryDarkColor,
                                  ),
                                  onPressed: () {
                                    captureImage(true).then((value) {
                                      if (value != null) {
                                        //  _medCondsProofimages.add(value);
                                        optsAttsField.responseFilePaths
                                            .add(value.path);
                                      }
                                      setState(() {});
                                    });
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
                              Text(
                                field.label,
                                style: TextStyle(
                                    color: Colors.white, fontSize: 15),
                              ),
                              SizedBox(width: 5),
                            ],
                          ),
                          backgroundColor: Colors.blueGrey[500],

                          children: <Widget>[
                            new Container(
                              width: MediaQuery.of(context).size.width * .94,
                              decoration: darkContainer,
                              padding: EdgeInsets.all(2.0),
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
                            controller: listOfControllers[field.label],
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
      if (listOfFields[i].isMandatory) {
        if (!Utils.isNotNullOrEmpty(
            listOfControllers[listOfFields[i].label].text)) {
          validationErrMsg =
              validationErrMsg + "\n ${listOfFields[i].label} cannot be empty.";
        }
      }
    }
    if (Utils.isNotNullOrEmpty(validationErrMsg))
      return false;
    else
      return true;
  }

  saveRoute() async {
    setState(() {
      validateField = true;
    });

    validationErrMsg = "";

    if (_bookingFormKey.currentState.validate()) {
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

//TODO SMITA - Check AGAIN if selected slot is stil available else prompt user to select another one.

      _bookingFormKey.currentState.save();

      //TODO : Smita - Upload all images to firebase storage.
      List<Field> listOfFields =
          bookingApplication.responseForm.getFormFields();

      for (int i = 0; i < listOfFields.length; i++) {
        switch (listOfFields[i].type) {
          case FieldType.ATTACHMENT:
            List<String> targetPaths = List<String>();
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

            break;
          case FieldType.OPTIONS_ATTACHMENTS:
            print("df");
            List<String> targetPaths = List<String>();
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
            break;
          default:
            break;
        }
      }

      //   List<String> frontLineTargetPaths = List<String>();
      //   for (String path in frontlineWorkerField.responseFilePaths) {
      //     String fileName = basename(path);
      //     print(fileName);

      //     String targetFileName =
      //         '${bookingApplication.id}#${frontlineWorkerField.id}#${_gs.getCurrentUser().id}#$fileName';

      //     String targetPath = await uploadFilesToServer(path, targetFileName);
      //     print(targetPath);
      //     frontLineTargetPaths.add(targetPath);
      //   }

      //   frontlineWorkerField.responseFilePaths = frontLineTargetPaths;

      _gs
          .getApplicationService()
          .submitApplication(bookingApplication, widget.metaEntity)
          .then((value) {
        if (value != null) {
          Utils.showMyFlushbar(
              context,
              Icons.check,
              Duration(
                seconds: 5,
              ),
              "Request submitted successfully!",
              'We will contact you as soon as slot opens up. Stay Safe!',
              successGreenSnackBar);
        } else {
          print("Error in generating SLot for user");
          Utils.showMyFlushbar(context, Icons.error, Duration(seconds: 5),
              couldNotSubmitApplication, tryAgainToBook);
        }
      }).catchError((error) {
        print("Error in generating SLot for user");
        print("Error in token booking" + error.toString());

        //TODO Smita - Not going in any of if bcoz exception is wrapped in type platform exception.
        if (error is SlotFullException) {
          Utils.showMyFlushbar(context, Icons.error, Duration(seconds: 5),
              couldNotBookToken, slotsAlreadyBooked);
        }
        // else if (error is TokenAlreadyExistsException) {
        //   Utils.showMyFlushbar(context, Icons.error, Duration(seconds: 5),
        //       couldNotBookToken, tokenAlreadyExists);
        //}
        else {
          Utils.showMyFlushbar(context, Icons.error, Duration(seconds: 5),
              couldNotBookToken, tryAgainToBook);
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
          "Please fill all mandatory fields and Save again.",
          "",
          Colors.red);
    }
  }

  processSaveWithTimer() async {
    var duration = new Duration(seconds: 0);
    return new Timer(duration, saveRoute);
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
                  // if (flushStatus != "Showing") {
                  //   flush = Flushbar<bool>(
                  //     //padding: EdgeInsets.zero,
                  //     margin: EdgeInsets.zero,
                  //     flushbarPosition: FlushbarPosition.BOTTOM,
                  //     flushbarStyle: FlushbarStyle.GROUNDED,
                  //     reverseAnimationCurve: Curves.decelerate,
                  //     forwardAnimationCurve: Curves.easeInToLinear,
                  //     backgroundColor: Colors.cyan[200],
                  //     boxShadows: [
                  //       BoxShadow(
                  //           color: Colors.cyan,
                  //           offset: Offset(0.0, 2.0),
                  //           blurRadius: 3.0)
                  //     ],
                  //     isDismissible: true,
                  //     //duration: Duration(seconds: 4),
                  //     icon: Icon(
                  //       Icons.cancel,
                  //       color: Colors.blueGrey[90],
                  //     ),
                  //     showProgressIndicator: true,
                  //     progressIndicatorBackgroundColor: Colors.blueGrey[900],
                  //     progressIndicatorValueColor:
                  //         new AlwaysStoppedAnimation<Color>(Colors.cyan[500]),
                  //     routeBlur: 10.0,
                  //     titleText: Text(
                  //       "Are you sure you want to leave this page?",
                  //       style: TextStyle(
                  //           fontWeight: FontWeight.bold,
                  //           fontSize: 16.0,
                  //           color: Colors.blueGrey[700],
                  //           fontFamily: "ShadowsIntoLightTwo"),
                  //     ),
                  //     messageText: Text(
                  //       "The changes you made might be lost, if not saved.",
                  //       style: TextStyle(
                  //           fontSize: 12.0,
                  //           color: Colors.blueGrey[800],
                  //           fontFamily: "ShadowsIntoLightTwo"),
                  //     ),

                  //     mainButton: Column(
                  //       children: <Widget>[
                  //         FlatButton(
                  //           padding: EdgeInsets.all(0),
                  //           onPressed: () {
                  //             flushStatus = "Empty";
                  //             flush.dismiss(false); // result = true
                  //           },
                  //           child: Text(
                  //             "No",
                  //             style: TextStyle(
                  //                 color: Colors.black,
                  //                 fontWeight: FontWeight.bold),
                  //           ),
                  //         ),
                  //         FlatButton(
                  //           padding: EdgeInsets.all(0),
                  //           onPressed: () {
                  //             flushStatus = "Empty";
                  //             flush.dismiss(true); // result = true
                  //           },
                  //           child: Text(
                  //             "Yes",
                  //             style: TextStyle(color: Colors.blueGrey[700]),
                  //           ),
                  //         ),
                  //       ],
                  //     ),
                  //   )..onStatusChanged = (FlushbarStatus status) {
                  //       print("FlushbarStatus-------$status");
                  //       if (status == FlushbarStatus.IS_APPEARING)
                  //         flushStatus = "Showing";
                  //       if (status == FlushbarStatus.DISMISSED)
                  //         flushStatus = "Empty";
                  //       print("gfdfgdfg");
                  //     };

                  //   flush
                  //     ..show(context).then((result) {
                  //       _wasButtonClicked = result;
                  //       flushStatus = "Empty";
                  //       if (_wasButtonClicked) Navigator.of(context).pop();
                  //     });
                  // }
                  Navigator.of(context).pop();
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
                  child: Column(
                    children: [
                      // Container(
                      //   margin: EdgeInsets.fromLTRB(0, 12, 0, 0),
                      //   width: MediaQuery.of(context).size.width * .913,
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
                      //                       "Selected Time Slot",
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
                      //                           child: Text(
                      //                               "Time of your appointment for this place",
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
                      //             padding: EdgeInsets.fromLTRB(5, 8, 5, 5),
                      //             child: Column(
                      //               children: <Widget>[
                      //                 Column(
                      //                   children: [
                      //                     Row(
                      //                       children: [
                      //                         SizedBox(
                      //                             // width: cardWidth * .45,
                      //                             child: Wrap(
                      //                           children: [
                      //                             AutoSizeText(
                      //                               "Current time-slot :",
                      //                               //group: labelGroup,
                      //                               minFontSize: 15,
                      //                               maxFontSize: 15,
                      //                               maxLines: 2,
                      //                               overflow: TextOverflow.clip,
                      //                               style: fieldLabelTextStyle,
                      //                             ),
                      //                           ],
                      //                         )),
                      //                         Wrap(children: [
                      //                           Container(
                      //                             padding:
                      //                                 EdgeInsets.only(left: 5),
                      //                             child: AutoSizeText(
                      //                                 ((bookingApplication
                      //                                             .preferredSlotTiming !=
                      //                                         null)
                      //                                     ? DateFormat(
                      //                                             'yyyy-MM-dd – kk:mm')
                      //                                         .format(bookingApplication
                      //                                             .preferredSlotTiming)
                      //                                     : "None"),
                      //                                 // group: medCondGroup,
                      //                                 minFontSize: 12,
                      //                                 maxFontSize: 14,
                      //                                 maxLines: 1,
                      //                                 overflow:
                      //                                     TextOverflow.ellipsis,
                      //                                 style: TextStyle(
                      //                                   color: btnColor,
                      //                                   fontWeight:
                      //                                       FontWeight.bold,
                      //                                 )),
                      //                           ),
                      //                         ]),
                      //                       ],
                      //                     ),
                      //                     Row(
                      //                       mainAxisAlignment:
                      //                           MainAxisAlignment.start,
                      //                       children: [
                      //                         AutoSizeText(
                      //                           "Click to choose another Time-Slot",
                      //                           // group: labelGroup,
                      //                           minFontSize: 15,
                      //                           maxFontSize: 15,
                      //                           maxLines: 2,
                      //                           overflow: TextOverflow.clip,
                      //                           style: fieldLabelTextStyle,
                      //                         ),
                      //                         IconButton(
                      //                             icon: Icon(
                      //                               Icons.date_range,
                      //                               color: btnColor,
                      //                             ),
                      //                             onPressed: () async {
                      //                               final result =
                      //                                   await Navigator.push(
                      //                                       context,
                      //                                       MaterialPageRoute(
                      //                                           builder:
                      //                                               (context) =>
                      //                                                   SlotSelectionPage(
                      //                                                     metaEntity:
                      //                                                         widget.metaEntity,
                      //                                                     dateTime:
                      //                                                         bookingApplication.preferredSlotTiming,
                      //                                                     forPage:
                      //                                                         "ApplicationList",
                      //                                                   )));

                      //                               print(result);
                      //                               setState(() {
                      //                                 if (result != null)
                      //                                   bookingApplication
                      //                                           .preferredSlotTiming =
                      //                                       result;
                      //                               });
                      //                             })
                      //                       ],
                      //                     ),
                      //                   ],
                      //                 ),

                      //                 // alternatePhoneField,
                      //               ],
                      //             ),
                      //           ),
                      //         ],
                      //       ),
                      //     ],
                      //   ),
                      // ),
                      Expanded(
                        child: ListView.builder(
                          padding: EdgeInsets.all(
                              MediaQuery.of(context).size.width * .026),
                          shrinkWrap: true,
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
                      ),
                      RaisedButton(
                          color: btnColor,
                          splashColor: highlightColor,
                          child: Container(
                            padding: EdgeInsets.all(10),
                            // margin: EdgeInsets.all(10),
                            width: MediaQuery.of(context).size.width * .84,
                            child: Column(
                              children: <Widget>[
                                Text(
                                  'Save Details & Request Token',
                                  style: buttonMedTextStyle,
                                ),
                              ],
                            ),
                          ),
                          onPressed: () {
                            print("FlushbarStatus-------");
                            // processSaveWithTimer();
                            return;
                          }),
                    ],
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
