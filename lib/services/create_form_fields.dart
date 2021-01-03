import 'package:flutter/material.dart';
import 'package:noq/db/db_model/booking_form.dart';

import 'package:noq/style.dart';

class CreateFormFields extends StatefulWidget {
  @override
  _CreateFormFieldsState createState() => _CreateFormFieldsState();
}

class _CreateFormFieldsState extends State<CreateFormFields> {
  TextEditingController _fieldController = new TextEditingController();
  Map<String, TextEditingController> listOfControllers =
      new Map<String, TextEditingController>();

  final GlobalKey<FormState> _bookingFormKey = new GlobalKey<FormState>();
  List<TextEditingController> _controllers = new List();
  BookingForm dummyForm;
  final itemSize = 100.0;
  List<String> dumList = new List<String>();

  createDummyData() {
    List<Field> listOfFields = new List<Field>();
    FormInputFieldText f1 =
        new FormInputFieldText("Name", true, "Enter name of person", 20);
    FormInputFieldText f2 = new FormInputFieldText(
        "Purpose of visit", true, "Enter purpose of visit", 30);
    listOfFields.add(f1);
    listOfFields.add(f2);
    dummyForm = new BookingForm(
        formName: "Basic Details",
        footerMsg: "Footer",
        headerMsg: "header",
        formFields: listOfFields,
        autoApproved: true);
  }

  Widget buildChildItem(Field field, int index) {
    if (!listOfControllers.containsKey(field.label)) {
      listOfControllers[field.label] = new TextEditingController();
    }
    switch (field.type) {
      case "TEXT":
        {}
        break;
      case "NUMBER":
        {}
        break;
      case "OPTIONS":
        {}
        break;
      default:
        {}
        break;
    }

    return Container(
      color: Colors.amber,
      child: TextFormField(
        obscureText: false,
        maxLines: 1,
        minLines: 1,
        style: textInputTextStyle,
        keyboardType: TextInputType.text,
        controller: listOfControllers[field.label],
        decoration:
            CommonStyle.textFieldStyle(labelTextStr: "you", hintTextStr: ""),
        onChanged: (String value) {
          print(value);
        },
        onSaved: (String value) {
          print(value);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    createDummyData();
    return Center(
      child: SafeArea(
        child: Form(
          key: _bookingFormKey,
          child: Column(
            children: [
              ListView.builder(
                padding:
                    EdgeInsets.all(MediaQuery.of(context).size.width * .026),
                itemExtent: itemSize,
                // reverse: true,
                shrinkWrap: true,
                //scrollDirection: Axis.vertical,
                itemBuilder: (BuildContext context, int index) {
                  _controllers.add(new TextEditingController());
                  return Container(
                    color: Colors.grey,
                    height: MediaQuery.of(context).size.height * .15,
                    width: MediaQuery.of(context).size.width * .9,
                    // child: TextFormField(
                    //   obscureText: false,
                    //   maxLines: 1,
                    //   minLines: 1,
                    //   style: textInputTextStyle,
                    //   keyboardType: TextInputType.text,
                    //   controller: _controllers[index],
                    //   decoration: CommonStyle.textFieldStyle(
                    //       labelTextStr: "you", hintTextStr: ""),
                    //   // validator: validateText,
                    //   // onChanged: (String value) {
                    //   //   contact.employeeId = value;
                    //   // },
                    //   // onSaved: (String value) {
                    //   //   contact.employeeId = value;
                    //   // },
                    // ),
                    child:
                        buildChildItem(dummyForm.formFields[index], index),
                  );
                },
                itemCount: dummyForm.formFields.length,
              ),
              Text(dummyForm.formName),
              Text(dummyForm.headerMsg),
              Container(
                child: TextFormField(
                  obscureText: false,
                  maxLines: 1,
                  minLines: 1,
                  style: textInputTextStyle,
                  keyboardType: TextInputType.text,
                  controller: _fieldController,
                  decoration: CommonStyle.textFieldStyle(
                      labelTextStr: "you", hintTextStr: ""),
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
      ),
    );
  }
}
