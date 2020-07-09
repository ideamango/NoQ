import 'package:flutter/material.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:intl/intl.dart';
import 'package:noq/db/db_model/employee.dart';
import 'package:noq/models/localDB.dart';
import 'package:noq/pages/entity_services_details_page.dart';
import 'package:noq/pages/manage_apartment_page.dart';
import 'package:noq/style.dart';
import 'package:flutter/foundation.dart';
import 'package:noq/utils.dart';
import 'package:noq/widget/weekday_selector.dart';

class ContactRow extends StatefulWidget {
  final Employee contact;
  ContactRow({Key key, @required this.contact}) : super(key: key);
  @override
  State<StatefulWidget> createState() => new ContactRowState();
}

class ContactRowState extends State<ContactRow> {
  Employee contact;
  TextEditingController _ctNameController = TextEditingController();
  TextEditingController _ctEmpIdController = TextEditingController();
  TextEditingController _ctPhn1controller = TextEditingController();
  TextEditingController _ctPhn2controller = TextEditingController();
  TextEditingController _ctAvlFromTimeController = TextEditingController();
  TextEditingController _ctAvlTillTimeController = TextEditingController();

  List<String> _daysOff = List<String>();

  @override
  void initState() {
    super.initState();
    contact = widget.contact;
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
          labelTextStr: "Person Id", hintTextStr: ""),
      validator: validateText,
      onChanged: (String value) {
        contact.id = value;
      },
      onSaved: (String value) {
        contact.id = value;
      },
    );
    final ctPhn1Field = TextFormField(
      obscureText: false,
      maxLines: 1,
      minLines: 1,
      style: textInputTextStyle,
      keyboardType: TextInputType.phone,
      controller: _ctPhn1controller,
      decoration: CommonStyle.textFieldStyle(
          prefixText: '+91', labelTextStr: "Primary Phone", hintTextStr: ""),
      validator: Utils.validateMobile,
      onChanged: (String value) {
        contact.ph = value;
      },
      onSaved: (value) {
        value = "+91" + value;
        contact.ph = value;
      },
    );
    final ctPhn2Field = TextFormField(
      obscureText: false,
      maxLines: 1,
      minLines: 1,
      style: textInputTextStyle,
      keyboardType: TextInputType.phone,
      controller: _ctPhn2controller,
      decoration: CommonStyle.textFieldStyle(
          prefixText: '+91', labelTextStr: "Alternate Phone", hintTextStr: ""),
      validator: Utils.validateMobile,
      onChanged: (String value) {
        contact.altPhone = value;
      },
      onSaved: (value) {
        value = "+91" + value;
        contact.altPhone = value;
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
        DatePicker.showTime12hPicker(context, showTitleActions: true,
            onChanged: (date) {
          print('change $date in time zone ' +
              date.timeZoneOffset.inHours.toString());
        }, onConfirm: (date) {
          print('confirm $date');
          //  String time = "${date.hour}:${date.minute} ${date.";

          String time = DateFormat.jm().format(date);
          print(time);

          _ctAvlFromTimeController.text = time.toLowerCase();
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
          hintText: "HH:MM am/pm",
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
        DatePicker.showTime12hPicker(context, showTitleActions: true,
            onChanged: (date) {
          print('change $date in time zone ' +
              date.timeZoneOffset.inHours.toString());
        }, onConfirm: (date) {
          print('confirm $date');
          //  String time = "${date.hour}:${date.minute} ${date.";

          String time = DateFormat.jm().format(date);
          print(time);

          _ctAvlTillTimeController.text = time.toLowerCase();
        }, currentTime: DateTime.now());
      },
      decoration: InputDecoration(
          labelText: "Available till",
          hintText: "HH:MM am/pm",
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
      onSaved: (String value) {
        //TODO: test the values
        List<String> time = value.split(':');
        contact.shiftEndHour = int.parse(time[0]);
        contact.shiftEndMinute = int.parse(time[1]);
      },
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
            initialValue: [days.sunday],
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
      padding: EdgeInsets.only(left: 5.0, right: 5),
      decoration: BoxDecoration(
          border: Border.all(color: containerColor),
          color: Colors.white,
          shape: BoxShape.rectangle,
          borderRadius: BorderRadius.all(Radius.circular(5.0))),
      // padding: EdgeInsets.all(5.0),

      child: new Form(
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
            ],
          ),
        ),
      ),

      // ListTile(
      //   title: Column(
      //     children: <Widget>[
      //       Text(
      //         contact.role.toString(),
      //         //  "Swimming Pool",
      //         style: TextStyle(color: Colors.blueGrey[700], fontSize: 17),
      //       ),
      //       if (contact.perName != null)
      //         Text(
      //           contact.perName,
      //           style: labelTextStyle,
      //         ),
      //     ],
      //   ),
      //   // backgroundColor: Colors.white,
      //   leading: Icon(
      //     Icons.slow_motion_video,
      //     color: lightIcon,
      //   ),
      //   trailing: IconButton(icon: Icon(Icons.arrow_forward), onPressed: () {}
      //       //showServiceForm
      //       ),
      // ),
    );
  }
}
