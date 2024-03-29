import 'package:LESSs/constants.dart';
import 'package:LESSs/db/exceptions/access_denied_exception.dart';
import 'package:LESSs/db/exceptions/cant_remove_admin_with_one_admin_exception.dart';
import 'package:LESSs/db/exceptions/entity_does_not_exists_exception.dart';
import 'package:LESSs/db/exceptions/existing_user_role_update_exception.dart';
import 'package:enum_to_string/enum_to_string.dart';
import 'package:flutter/material.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:intl/intl.dart';
import '../db/db_model/employee.dart';
import '../db/db_model/entity.dart';
import '../enum/entity_type.dart';
import '../events/event_bus.dart';
import '../events/events.dart';
import '../global_state.dart';
import '../style.dart';
import 'package:flutter/foundation.dart';
import '../utils.dart';
import '../widget/weekday_selector.dart';
import 'package:uuid/uuid.dart';
import '../enum/entity_role.dart';

class ContactRow extends StatefulWidget {
  final Entity? entity;
  final EntityRole empType;
  final Employee contact;
  final List<Employee>? list;
  final bool isManager;
  final bool existingContact;
  ContactRow(
      {Key? key,
      required this.entity,
      required this.empType,
      required this.contact,
      required this.isManager,
      required this.existingContact,
      this.list})
      : super(key: key);
  @override
  State<StatefulWidget> createState() => new ContactRowState();
}

class ContactRowState extends State<ContactRow> {
  bool _isValid = false;
  Employee? contact;
  TextEditingController _ctNameController = TextEditingController();
  TextEditingController _ctEmpIdController = TextEditingController();
  TextEditingController _ctPhn1controller = TextEditingController();
  TextEditingController _ctPhn2controller = TextEditingController();
  TextEditingController _ctAvlFromTimeController = TextEditingController();
  TextEditingController _ctAvlTillTimeController = TextEditingController();

  final GlobalKey<FormFieldState> phn1Key = new GlobalKey<FormFieldState>();
  final GlobalKey<FormFieldState> phn2Key = new GlobalKey<FormFieldState>();

  List<String>? _daysOff = [];
  bool _initCompleted = false;
  List<days>? _closedOnDays;
  Entity? _entity;
  List<Employee>? _list;
  GlobalState? _gs;
  bool showLoading = false;
  bool existingContact = false;

  @override
  void initState() {
    super.initState();
    contact = widget.contact;
    _entity = widget.entity;
    _list = widget.list;
    existingContact = widget.existingContact;
    GlobalState.getGlobalState().then((value) {
      _gs = value;
    });
    initializeContactDetails();
  }

  @override
  void dispose() {
    super.dispose();
  }

  void initializeContactDetails() {
    //this called for adding new executive
    if (contact?.id != null) {
      _ctNameController.text = contact!.name!;
      _ctEmpIdController.text = contact!.employeeId!;
      _ctPhn1controller.text =
          contact!.ph != null ? contact!.ph!.substring(3) : "";
      _ctPhn2controller.text =
          contact!.altPhone != null ? contact!.altPhone!.substring(3) : "";
      if (contact!.shiftStartHour != null && contact!.shiftStartMinute != null)
        _ctAvlFromTimeController.text =
            Utils.formatTime(contact!.shiftStartHour.toString()) +
                ':' +
                Utils.formatTime(contact!.shiftStartMinute.toString());
      if (contact!.shiftEndHour != null && contact!.shiftEndMinute != null)
        _ctAvlTillTimeController.text =
            Utils.formatTime(contact!.shiftEndHour.toString()) +
                ':' +
                Utils.formatTime(contact!.shiftEndMinute.toString());
      _daysOff = (contact!.daysOff) ?? [];
    }
    var uuid = new Uuid();
    contact?.id = uuid.v1();

    // if (_daysOff.length == 0) {
    //   _daysOff.add('days.sunday');
    // }
    _closedOnDays =
        _daysOff != null ? Utils.convertStringsToDays(_daysOff!) : [];
  }

  String? validateText(String? value) {
    if (value == null) {
      return 'Field is empty';
    }
    return null;
  }

  String? validateTime(String? value) {
    if (value == null) {
      return 'Field is empty';
    }

    return null;
  }

  handleRemoveEmployee(dynamic error) {
    switch (error.runtimeType) {
      case AccessDeniedException:
        Utils.showMyFlushbar(context, Icons.error, Duration(seconds: 6),
            "Could not Remove the Employee", error.cause, Colors.red);
        break;
      case CantRemoveAdminWithOneAdminException:
        Utils.showMyFlushbar(context, Icons.error, Duration(seconds: 6),
            "Could not Remove the Employee", error.cause, Colors.red);
        break;
      case EntityDoesNotExistsException:
        Utils.showMyFlushbar(context, Icons.error, Duration(seconds: 6),
            "Could not Remove the Employee", error.cause, Colors.red);
        break;
      default:
        Utils.showMyFlushbar(context, Icons.error, Duration(seconds: 8),
            "Could not Remove the Employee", error.toString(), Colors.red);
        break;
    }
  }

  handleUpsertEmployeeErrors(dynamic error, String? phone) {
    switch (error.runtimeType) {
      case AccessDeniedException:
        Utils.showMyFlushbar(context, Icons.error, Duration(seconds: 6),
            error.cause, "Could not Update the Employee records", Colors.red);
        break;
      case ExistingUserRoleUpdateException:
        Utils.showMyFlushbar(
            context,
            Icons.error,
            Duration(seconds: 6),
            error.cause,
            "If you wish to add in this role, then remove the other user.",
            Colors.red);
        break;
      case CantRemoveAdminWithOneAdminException:
        Utils.showMyFlushbar(context, Icons.error, Duration(seconds: 6),
            error.cause, "Could not Update the Employee records", Colors.red);
        break;
      default:
        Utils.showMyFlushbar(
            context,
            Icons.error,
            Duration(seconds: 8),
            "Could not Update the Employee records",
            error.toString(),
            Colors.red);
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    // showServiceForm() {
    //   Navigator.push(
    //       context,
    //       MaterialPageRoute(
    //           builder: (context) => ManageApartmentPage(entity: this.entity)));
    // }

    final ctNameField = TextFormField(
      obscureText: false,
      maxLines: 1,
      minLines: 1,
      enabled: (widget.isManager ? false : true),
      style: textInputTextStyle,
      keyboardType: TextInputType.text,
      controller: _ctNameController,
      decoration:
          CommonStyle.textFieldStyle(labelTextStr: "Name*", hintTextStr: ""),
      validator: validateText,
      onChanged: (String value) {
        contact!.name = value;
        setState(() {});
      },
      onSaved: (String? value) {
        contact!.name = value;
      },
    );
    final ctEmpIdField = TextFormField(
      obscureText: false,
      maxLines: 1,
      minLines: 1,
      enabled: (widget.isManager ? false : true),
      style: textInputTextStyle,
      keyboardType: TextInputType.text,
      controller: _ctEmpIdController,
      decoration: CommonStyle.textFieldStyle(
          labelTextStr: "Employee Id", hintTextStr: ""),
      validator: validateText,
      onChanged: (String value) {
        contact!.employeeId = value;
      },
      onSaved: (String? value) {
        contact!.employeeId = value;
      },
    );
    final ctPhn1Field = TextFormField(
      obscureText: false,
      key: phn1Key,
      maxLines: 1,
      minLines: 1,
      readOnly: existingContact ? true : false,
      enabled: (widget.isManager ? false : true),
      style: existingContact ? disabledTextStyle : textInputTextStyle,
      keyboardType: TextInputType.phone,
      controller: _ctPhn1controller,
      decoration: CommonStyle.textFieldStyle(
          prefixText: '+91', labelTextStr: "Primary Phone*", hintTextStr: ""),
      validator: Utils.validateMobileField,
      onChanged: (String value) {
        phn1Key.currentState!.validate();
        contact!.ph = "+91" + value;
      },
      onTap: () {
        if (existingContact)
          Utils.showMyFlushbar(
              context,
              Icons.info,
              Duration(seconds: 7),
              "The primary phone number cannot be changed",
              "Remove this employee and add another employee with different phone number");
      },
      onSaved: (value) {
        contact!.ph = "+91" + value!;
      },
    );
    final ctPhn2Field = TextFormField(
      obscureText: false,
      key: phn2Key,
      maxLines: 1,
      minLines: 1,
      enabled: (widget.isManager ? false : true),
      style: textInputTextStyle,
      keyboardType: TextInputType.phone,
      controller: _ctPhn2controller,
      decoration: CommonStyle.textFieldStyle(
          prefixText: '+91', labelTextStr: "Alternate Phone", hintTextStr: ""),
      validator: Utils.validateMobileField,
      onChanged: (String value) {
        phn2Key.currentState!.validate();
        contact!.altPhone = "+91" + value;
      },
      onSaved: (value) {
        contact!.altPhone = "+91" + value!;
      },
    );
    final ctAvlFromTimeField = TextFormField(
      obscureText: false,
      maxLines: 1,
      readOnly: true,
      minLines: 1,
      enabled: (widget.isManager ? false : true),
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
            contact!.shiftStartHour = int.parse(time[0]);
            contact!.shiftStartMinute = int.parse(time[1]);
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
        contact!.shiftStartHour = int.parse(time[0]);
        contact!.shiftStartMinute = int.parse(time[1]);
      },
      onSaved: (String? value) {
        //TODO: test the values
        List<String> time = value!.split(':');
        contact!.shiftStartHour = int.parse(time[0]);
        contact!.shiftStartMinute = int.parse(time[1]);
      },
    );
    final ctAvlTillTimeField = TextFormField(
      obscureText: false,
      readOnly: true,
      maxLines: 1,
      minLines: 1,
      enabled: (widget.isManager ? false : true),
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
            contact!.shiftEndHour = int.parse(time[0]);
            contact!.shiftEndMinute = int.parse(time[1]);
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
        contact!.shiftEndHour = int.parse(time[0]);
        contact!.shiftEndMinute = int.parse(time[1]);
      },
      onSaved: (String? value) {},
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
          SizedBox(width: 2),
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
            initialValue: _closedOnDays,
            borderRadius: 20,
            elevation: 10,
            enabled: (widget.isManager ? false : true),
            textStyle: buttonXSmlTextStyle,
            fillColor: Colors.blueGrey[400],
            selectedFillColor: highlightColor,
            boxConstraints: BoxConstraints(
                minHeight: 20, minWidth: 20, maxHeight: 24, maxWidth: 24),
            borderSide: BorderSide(color: Colors.white, width: 0),
            language: lang.en,
            onChange: (days) {
              if (widget.isManager) {
                return;
              } else {
                print("Days off: " + days.toString());
                _daysOff?.clear();

                days!.forEach((element) {
                  var day = element.toString().substring(5);
                  _daysOff!.add(day);
                });
                contact?.daysOff = _daysOff;
                print(_daysOff?.length);
                print(_daysOff.toString());
              }
            },
          ),
        ],
      ),
    );

    return Container(
      margin: EdgeInsets.all(12),
      decoration: BoxDecoration(
          border: Border.all(color: headerBarColor!),
          color: Colors.white,
          shape: BoxShape.rectangle,
          borderRadius: BorderRadius.all(Radius.circular(5.0))),
      // padding: EdgeInsets.all(5.0),

      child: Theme(
        data: ThemeData(
          unselectedWidgetColor: Colors.black,
          accentColor: highlightColor,
        ),
        child: ExpansionTile(
          //key: PageStorageKey(this.widget.headerTitle),
          initiallyExpanded: widget.existingContact ? false : true,
          //Check if contact is not yet saved, CONTACT would be null, check before accessing.
          title: Text(
            Utils.isNotNullOrEmpty(contact!.name)
                ? contact!.name!
                : EnumToString.convertToString(widget.empType),
            style: TextStyle(color: Colors.blueGrey[700], fontSize: 17),
          ),

          backgroundColor: Colors.white,
          leading: IconButton(
              icon: Icon(Icons.person, color: Colors.blueGrey[300], size: 30),
              onPressed: () {
                // contact.isManager = false;
              }),
          children: <Widget>[
            Container(
              //  margin: EdgeInsets.all(MediaQuery.of(context).size.width * .026),
              //padding: EdgeInsets.all(MediaQuery.of(context).size.width * .026),
              // padding: EdgeInsets.all(MediaQuery.of(context).size.width * .026),
              color: Colors.cyan[50],
              // padding: EdgeInsets.only(left: 2.0, right: 2),
              // decoration: BoxDecoration(
              //     // border: Border.all(color: containerColor),
              //     color: Colors.white,
              //     shape: BoxShape.rectangle,
              //     borderRadius: BorderRadius.all(Radius.circular(5.0))),
              // padding: EdgeInsets.all(5.0),
              foregroundDecoration: widget.isManager
                  ? BoxDecoration(
                      color: Colors.grey[50],
                      backgroundBlendMode: BlendMode.saturation,
                    )
                  : BoxDecoration(),
              child: new Form(
                //  autovalidate: _autoValidate,
                child: Stack(
                  children: [
                    Container(
                      child: ListTile(
                        title: Column(
                          children: <Widget>[
                            ctNameField,
                            ctEmpIdField,
                            ctPhn1Field,
                            ctPhn2Field,
                            daysOffField,
                            Divider(
                              thickness: .7,
                              color: Colors.grey[600],
                            ),
                            ctAvlFromTimeField,
                            ctAvlTillTimeField,
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                SizedBox(
                                  width:
                                      MediaQuery.of(context).size.width * .34,
                                  child: RaisedButton(
                                      color: Colors.white,
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Text(
                                            "Remove",
                                            style: TextStyle(
                                              color: btnColor,
                                              fontWeight: FontWeight.w500,
                                              fontFamily: 'Montserrat',
                                              letterSpacing: 1.3,
                                              fontSize: 17,
                                            ),
                                          ),
                                          SizedBox(
                                              width: MediaQuery.of(context)
                                                      .size
                                                      .width *
                                                  .01),
                                          Icon(Icons.delete, color: btnColor)
                                        ],
                                      ),
                                      onPressed: () {
                                        if (widget.isManager) {
                                          Utils.showMyFlushbar(
                                              context,
                                              Icons.info,
                                              Duration(seconds: 3),
                                              "$noEditPermission Employees",
                                              "");
                                          return;
                                        } else {
                                          setState(() {
                                            showLoading = true;
                                          });
                                          if (widget.empType ==
                                              EntityRole.Manager) {
                                            String? removeThisId;
                                            for (int i = 0;
                                                i < _list!.length;
                                                i++) {
                                              if (_list![i].id == contact!.id) {
                                                removeThisId = contact!.id;
                                                print(_list![i].id);
                                                break;
                                              }
                                            }
                                            if (removeThisId != null) {
                                              if (existingContact) {
                                                _gs!
                                                    .removeEmployee(
                                                  widget.entity!.entityId,
                                                  contact!.ph,
                                                )
                                                    .then((retVal) {
                                                  // setState(() {
                                                  //   showLoading = false;
                                                  // });
                                                  if (retVal) {
                                                    print("Success");
                                                    Utils.showMyFlushbar(
                                                        context,
                                                        Icons.check,
                                                        Duration(seconds: 3),
                                                        "Manager Removed Successfully!",
                                                        "",
                                                        successGreenSnackBar);
                                                  } else {
                                                    Utils.showMyFlushbar(
                                                        context,
                                                        Icons.info,
                                                        Duration(seconds: 3),
                                                        "Oho! Could not Remove Manager.",
                                                        "");
                                                  }

                                                  setState(() {
                                                    // contact = null;
                                                    showLoading = false;
                                                    // _entity.managers.removeWhere(
                                                    //     (element) => element.id == removeThisId);
                                                    _list!.removeWhere(
                                                        (element) =>
                                                            element.id ==
                                                            removeThisId);
                                                    EventBus.fireEvent(
                                                        MANAGER_REMOVED_EVENT,
                                                        null,
                                                        removeThisId);
                                                  });
                                                }).onError((dynamic error,
                                                        stackTrace) {
                                                  handleRemoveEmployee(error);
                                                });
                                              } else {
                                                setState(() {
                                                  showLoading = false;
                                                });
                                                Utils.showMyFlushbar(
                                                    context,
                                                    Icons.check,
                                                    Duration(seconds: 3),
                                                    "Manager Removed Successfully!",
                                                    "",
                                                    successGreenSnackBar);
                                                // _entity.managers.removeWhere(
                                                //     (element) => element.id == removeThisId);
                                                _list!.removeWhere((element) =>
                                                    element.id == removeThisId);
                                                // _entity.managers.removeWhere(
                                                //     (element) =>
                                                //         element.id ==
                                                //         removeThisId);
                                                EventBus.fireEvent(
                                                    MANAGER_REMOVED_EVENT,
                                                    null,
                                                    removeThisId);
                                              }
                                            } else {
                                              Utils.showMyFlushbar(
                                                  context,
                                                  Icons.info,
                                                  Duration(seconds: 3),
                                                  "Oho! Could not Remove Manager.",
                                                  tryAgainLater);
                                              setState(() {
                                                showLoading = false;
                                              });
                                            }
                                          } else if (widget.empType ==
                                              EntityRole.Executive) {
                                            String? removeThisId;
                                            for (int i = 0;
                                                i < _list!.length;
                                                i++) {
                                              if (_list![i].id == contact!.id) {
                                                removeThisId = contact!.id;
                                                print(_list![i].id);
                                                break;
                                              }
                                            }

                                            if (removeThisId != null) {
                                              if (existingContact) {
                                                //TODO call remove employee from Global state
                                                _gs!
                                                    .removeEmployee(
                                                  widget.entity!.entityId,
                                                  contact!.ph,
                                                )
                                                    .then((retVal) {
                                                  if (retVal) {
                                                    print("Success");
                                                    Utils.showMyFlushbar(
                                                        context,
                                                        Icons.check,
                                                        Duration(seconds: 3),
                                                        "Executive Removed Successfully!",
                                                        "",
                                                        successGreenSnackBar);
                                                  } else {
                                                    Utils.showMyFlushbar(
                                                        context,
                                                        Icons.info,
                                                        Duration(seconds: 3),
                                                        "Oho! Could not Remove Executive.",
                                                        "");
                                                  }
                                                  setState(() {
                                                    //   contact = null;
                                                    // _entity.managers.removeWhere(
                                                    //     (element) => element.id == removeThisId);
                                                    _list!.removeWhere(
                                                        (element) =>
                                                            element.id ==
                                                            removeThisId);
                                                    EventBus.fireEvent(
                                                        EXECUTIVE_REMOVED_EVENT,
                                                        null,
                                                        removeThisId);
                                                  });
                                                }).onError((dynamic error,
                                                        stackTrace) {
                                                  handleRemoveEmployee(error);
                                                });
                                              } else {
                                                // _entity.executives.removeWhere(
                                                //     (element) =>
                                                //         element.id ==
                                                //         removeThisId);
                                                Utils.showMyFlushbar(
                                                    context,
                                                    Icons.check,
                                                    Duration(seconds: 3),
                                                    "Executive Removed Successfully!",
                                                    "",
                                                    successGreenSnackBar);
                                                _list!.removeWhere((element) =>
                                                    element.id == removeThisId);
                                                setState(() {
                                                  showLoading = false;
                                                });
                                                EventBus.fireEvent(
                                                    EXECUTIVE_REMOVED_EVENT,
                                                    null,
                                                    removeThisId);

                                                //case where this is a new contact but not Saved.
//Just remove from _list collection and entity.executives.

                                                //case where this is a new contact and Saved.

                                              }
                                            }
                                          }
                                        }
                                      }),
                                ),
                                SizedBox(
                                  width:
                                      MediaQuery.of(context).size.width * .04,
                                ),
                                SizedBox(
                                  width:
                                      MediaQuery.of(context).size.width * .34,
                                  child: RaisedButton(
                                      color: btnColor,
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Text(
                                            "Save",
                                            style: buttonMedTextStyle,
                                          ),
                                          SizedBox(
                                              width: MediaQuery.of(context)
                                                      .size
                                                      .width *
                                                  .01),
                                          Icon(Icons.save, color: Colors.white)
                                        ],
                                      ),
                                      onPressed: () {
                                        // String removeThisId;
                                        // for (int i = 0;
                                        //     i < _entity.managers.length;
                                        //     i++) {
                                        //   if (_entity.managers[i].id == contact.id) {
                                        //     removeThisId = contact.id;
                                        //     print(_entity.managers[i].id);
                                        //     break;
                                        //   }
                                        // }
                                        // if (removeThisId != null) {
                                        //   setState(() {
                                        //     contact = null;
                                        //     // _entity.managers.removeWhere(
                                        //     //     (element) => element.id == removeThisId);
                                        //     _list.removeWhere(
                                        //         (element) => element.id == removeThisId);
                                        //     EventBus.fireEvent(MANAGER_REMOVED_EVENT,
                                        //         null, removeThisId);
                                        //   });
                                        // }
                                        //
                                        //
                                        //TODO: Add validation for Phone number
                                        if (widget.isManager) {
                                          Utils.showMyFlushbar(
                                              context,
                                              Icons.info,
                                              Duration(seconds: 3),
                                              "$noEditPermission Employees",
                                              "");
                                          return;
                                        } else {
                                          //CHECK whether name and primary phone is entered.
                                          if (Utils.isStrNullOrEmpty(
                                                  contact!.name) ||
                                              Utils.isStrNullOrEmpty(
                                                  contact!.ph)) {
                                            Utils.showMyFlushbar(
                                                context,
                                                Icons.info,
                                                Duration(seconds: 3),
                                                "Employee Name and Primary Phone number are mandatory",
                                                "");
                                            return;
                                          }
//Check if same phone is added for another profile as well, Since phone is primary key
// Another employee with same number is not allowed

                                          int count = 0;
                                          _list!.forEach((element) {
                                            if (element.ph == contact!.ph) {
                                              count++;
                                            }
                                          });
                                          if (count > 1) {
                                            Utils.showMyFlushbar(
                                                context,
                                                Icons.info,
                                                Duration(seconds: 5),
                                                "An Employee with SAME Phone number already exists",
                                                "");
                                            return;
                                          }

                                          setState(() {
                                            showLoading = true;
                                          });

                                          _gs!
                                              .addEmployee(
                                                  widget.entity!.entityId!,
                                                  contact!,
                                                  widget.empType)
                                              .then((retVal) {
                                            if (retVal) {
                                              print("Success");
                                              existingContact = true;
                                              setState(() {
                                                showLoading = false;
                                              });

                                              Utils.showMyFlushbar(
                                                  context,
                                                  Icons.check,
                                                  Duration(seconds: 3),
                                                  "Employee Details Saved",
                                                  "",
                                                  successGreenSnackBar);
                                            }
                                          }).onError(
                                                  (dynamic error, stackTrace) {
                                            setState(() {
                                              showLoading = false;
                                            });
                                            handleUpsertEmployeeErrors(
                                                error, contact!.ph);
                                          });
                                        }
                                      }),
                                ),
                              ],
                            )
                          ],
                        ),
                      ),
                    ),
                    if (showLoading)
                      Center(
                        child: Padding(
                          padding: EdgeInsets.only(top: 10.0, bottom: 10),
                          child: Container(
                            width: MediaQuery.of(context).size.width,
                            height: MediaQuery.of(context).size.height,
                            color: Colors.black.withOpacity(.5),
                            // decoration: BoxDecoration(
                            //   color: Colors.white,
                            //   backgroundBlendMode: BlendMode.saturation,
                            // ),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                Container(
                                  color: Colors.transparent,
                                  padding: EdgeInsets.all(12),
                                  width:
                                      MediaQuery.of(context).size.width * .15,
                                  height:
                                      MediaQuery.of(context).size.width * .15,
                                  child: CircularProgressIndicator(
                                    backgroundColor: Colors.black,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                        Colors.white),
                                    strokeWidth: 2,
                                  ),
                                )
                              ],
                            ),
                          ),
                        ),
                      )
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
