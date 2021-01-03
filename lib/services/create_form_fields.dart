import 'package:flutter/material.dart';
import 'package:noq/db/db_model/form.dart';
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
  EntityForm dummyForm;
  final itemSize = 100.0;
  List<String> dumList = new List<String>();

  createDummyData() {
    dummyForm = new EntityForm();
    dummyForm.formName = "Basic Details";
    dummyForm.footerMsg = "Footer";
    dummyForm.headerMsg = "header";
    List<Field> listOfFields = new List<Field>();
    FormInputFieldText f1 = new FormInputFieldText(
        label: "Name",
        isMandatory: true,
        maxLength: 20,
        infoMessage: "Enter name of person");
    FormInputFieldText f2 = new FormInputFieldText(
        label: "Purpose of visit",
        isMandatory: true,
        maxLength: 30,
        infoMessage: "Enter purpose of visit");
    listOfFields.add(f1);
    listOfFields.add(f2);
    dummyForm.formFieldList = listOfFields;

    dumList.add("Smita");
    dumList.add("Sumant");
  }

  Widget buildChildItem(Field field, int index) {
    if (listOfControllers.containsKey(field.label)) {
      
    } else {
      listOfControllers[field.label]= new TextEditingController();
    }

    return Container(
      color: Colors.amber,
      child: TextFormField(
        obscureText: false,
        maxLines: 1,
        minLines: 1,
        style: textInputTextStyle,
        keyboardType: TextInputType.text,
        controller: _controllers[index],
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
                        buildChildItem(dummyForm.formFieldList[index], index),
                  );
                },
                itemCount: dumList.length,
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
