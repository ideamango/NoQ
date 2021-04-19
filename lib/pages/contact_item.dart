import 'package:flutter/material.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:intl/intl.dart';
import 'package:noq/db/db_model/employee.dart';
import 'package:noq/db/db_model/entity.dart';
import 'package:noq/enum/entity_type.dart';
import 'package:noq/events/event_bus.dart';
import 'package:noq/events/events.dart';
import 'package:noq/global_state.dart';
import 'package:noq/style.dart';
import 'package:flutter/foundation.dart';
import 'package:noq/utils.dart';
import 'package:noq/widget/weekday_selector.dart';

class ContactRow extends StatefulWidget {
  final Entity entity;
  final EntityRole empType;
  final Employee contact;
  final List<Employee> list;
  ContactRow(
      {Key key,
      @required this.entity,
      @required this.empType,
      @required this.contact,
      this.list})
      : super(key: key);
  @override
  State<StatefulWidget> createState() => new ContactRowState();
}

class ContactRowState extends State<ContactRow> {
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

  List<String> _daysOff;
  bool _initCompleted = false;
  List<days> _closedOnDays;
  Entity _entity;
  List<Employee> _list;
  GlobalState _gs;

  @override
  void initState() {
    super.initState();
    contact = widget.contact;
    _entity = widget.entity;
    _list = widget.list;
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
      _daysOff = (contact.daysOff) ?? new List<String>();
    }
    if (_daysOff.length == 0) {
      _daysOff.add('days.sunday');
    }
    _closedOnDays = List<days>();
    _closedOnDays = Utils.convertStringsToDays(_daysOff);
  }

  String validateText(String value) {
    if (value == null) {
      return 'Field is empty';
    }
    return null;
  }

  String validateTime(String value) {
    if (value == null) {
      return 'Field is empty';
    }

    return null;
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
      style: textInputTextStyle,
      keyboardType: TextInputType.text,
      controller: _ctNameController,
      decoration:
          CommonStyle.textFieldStyle(labelTextStr: "Name", hintTextStr: ""),
      validator: validateText,
      onChanged: (String value) {
        contact.name = value;
        setState(() {});
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
            textStyle: buttonXSmlTextStyle,
            fillColor: Colors.blueGrey[400],
            selectedFillColor: highlightColor,
            boxConstraints: BoxConstraints(
                minHeight: 20, minWidth: 20, maxHeight: 24, maxWidth: 24),
            borderSide: BorderSide(color: Colors.white, width: 0),
            language: lang.en,
            onChange: (days) {
              print("Days off: " + days.toString());
              _daysOff.clear();
              days.forEach((element) {
                var day = element.toString().substring(5);
                _daysOff.add(day);
              });
              contact.daysOff = _daysOff;
              print(_daysOff.length);
              print(_daysOff.toString());
            },
          ),
        ],
      ),
    );

    return Container(
      //  padding: EdgeInsets.all(8),
      margin: EdgeInsets.all(12),
      decoration: BoxDecoration(
          border: Border.all(color: headerBarColor),
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
          initiallyExpanded: false,
          title: Text(
            (contact.name != null && contact.name != "")
                ? contact.name
                : (widget.empType == EntityRole.Manager
                    ? "Manager"
                    : "Executive"),
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

              child: new Form(
                //  autovalidate: _autoValidate,
                child: Container(
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
                              width: MediaQuery.of(context).size.width * .37,
                              child: RaisedButton(
                                  color: Colors.white,
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        "Remove",
                                        style: TextStyle(
                                          color: btnColor,
                                          fontWeight: FontWeight.w700,
                                          fontFamily: 'Montserrat',
                                          fontSize: 15,
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
                                    if (widget.empType == EntityRole.Manager) {
                                      String removeThisId;
                                      for (int i = 0;
                                          i < _entity.managers.length;
                                          i++) {
                                        if (_entity.managers[i].id ==
                                            contact.id) {
                                          removeThisId = contact.id;
                                          print(_entity.managers[i].id);
                                          break;
                                        }
                                      }
                                      if (removeThisId != null) {
                                        setState(() {
                                          contact = null;
                                          // _entity.managers.removeWhere(
                                          //     (element) => element.id == removeThisId);
                                          _list.removeWhere((element) =>
                                              element.id == removeThisId);
                                          EventBus.fireEvent(
                                              MANAGER_REMOVED_EVENT,
                                              null,
                                              removeThisId);
                                        });
                                      }
                                    } else if (widget.empType ==
                                        EntityRole.Executive) {
                                      String removeThisId;
                                      for (int i = 0;
                                          i < _entity.executives.length;
                                          i++) {
                                        if (_entity.executives[i].id ==
                                            contact.id) {
                                          removeThisId = contact.id;
                                          print(_entity.executives[i].id);
                                          break;
                                        }
                                      }
                                      if (removeThisId != null) {
                                        setState(() {
                                          contact = null;
                                          // _entity.managers.removeWhere(
                                          //     (element) => element.id == removeThisId);
                                          _list.removeWhere((element) =>
                                              element.id == removeThisId);
                                          EventBus.fireEvent(
                                              EXECUTIVE_REMOVED_EVENT,
                                              null,
                                              removeThisId);
                                        });
                                      }
                                    }
                                  }),
                            ),
                            SizedBox(
                              width: MediaQuery.of(context).size.width * .04,
                            ),
                            SizedBox(
                              width: MediaQuery.of(context).size.width * .37,
                              child: RaisedButton(
                                  color: btnColor,
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
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
                                    _gs
                                        .getEntityService()
                                        .addEmployee(widget.entity.entityId,
                                            contact, widget.empType)
                                        .then((retVal) {
                                      if (retVal) {
                                        print("Success");
                                        Utils.showMyFlushbar(
                                            context,
                                            Icons.check,
                                            Duration(seconds: 3),
                                            "Employee Details Saved",
                                            "");
                                      }
                                    });
                                  }),
                            ),
                          ],
                        )
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
