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
  List<Item> selectedList = new List<Item>();
  Map<String, List<Item>> mapOfOptionsFields = Map<String, List<Item>>();
  List<Item> listf3 = new List<Item>();
  List<Item> listf4 = new List<Item>();

  @override
  void initState() {
    super.initState();
    createDummyData();
    selectedList = List();
    // list.add(Item("Diabetes1", true));
    // list.add(Item("Diabetes2", true));
    // list.add(Item("Diabetes3", true));
    // list.add(Item("Heart", true));
    // list.add(Item("Lungs", false));
    // list.add(Item("Kidney", false));
    // list.add(Item("Asthma", true));
    // list.add(Item("Blood Pressure", false));
    // list.add(Item("Hyper Tension", false));
    // list.add(Item("Thyroid", false));
  }

  // double _height = 0;
  // double _width = 0;
  // bool _isExpanded = false;
  createDummyData() {
    List<Field> listOfFields = new List<Field>();
    FormInputFieldText f1 =
        new FormInputFieldText("Name", true, "Enter name of person", 20);
    FormInputFieldNumber f2 = new FormInputFieldNumber(
        "Duration of visit", true, "Enter purpose of visit", 0, 1000);
    FormInputFieldNumber f5 = new FormInputFieldNumber(
        "Address", true, "Address for Communication", 0, 1000);
    List<Value> list = new List<Value>();
    list.add(Value("Diabetes"));
    list.add(Value("Asthma"));
    list.add(Value("Blood Pressure"));
    list.add(Value("Allergy"));
    list.add(Value("Hyper Tension"));
    list.add(Value("Thyroid"));

    FormInputFieldOptions f3 = new FormInputFieldOptions("Medical Conditions",
        true, "Medical COnditions(Select any)", list, true);

    list.forEach((element) {
      listf3.add(Item(element.value, false));
    });
    mapOfOptionsFields[f3.label] = listf3;

    List<Value> list2 = new List<Value>();
    list2.add(Value("Diabetesiii"));
    list2.add(Value("Asthmayyyyy"));
    list2.add(Value("Blood Pressurebbbb"));
    list2.add(Value("Allergyxxxx"));

    FormInputFieldOptions f4 = new FormInputFieldOptions(
        "Surgeries, if any", true, "Surgery(Select any)", list, false);
    for (int i = 0; i < list2.length; i++) {
      listf4.add(Item(list2[i].value, false));
    }
    mapOfOptionsFields[f4.label] = listf4;

    listOfFields.add(f1);
    listOfFields.add(f2);
    listOfFields.add(f3);
    listOfFields.add(f4);
    listOfFields.add(f5);

    dummyForm = new BookingForm(
        formName: "Token Allocation form",
        footerMsg: "Footer",
        headerMsg: "header",
        autoApproved: true);
  }

  Widget buildChildItem(Field field, int index) {
    if (!listOfControllers.containsKey(field.label)) {
      listOfControllers[field.label] = new TextEditingController();
    }
    Widget newField;
    switch (field.type) {
      case "TEXT":
        {
          newField = TextFormField(
            obscureText: false,
            maxLines: 1,
            minLines: 1,
            style: textInputTextStyle,
            keyboardType: TextInputType.text,
            controller: listOfControllers[field.label],
            decoration: CommonStyle.textFieldStyle(
                labelTextStr: field.label, hintTextStr: field.label),
            onChanged: (String value) {
              print(value);
            },
            onSaved: (String value) {
              print(value);
            },
          );
        }
        break;
      case "NUMBER":
        {
          newField = TextFormField(
            obscureText: false,
            maxLines: 1,
            minLines: 1,
            style: textInputTextStyle,
            keyboardType: TextInputType.number,
            controller: listOfControllers[field.label],
            decoration: CommonStyle.textFieldStyle(
                labelTextStr: field.label, hintTextStr: field.label),
            onChanged: (String value) {
              print(value);
            },
            onSaved: (String value) {
              print(value);
            },
          );
        }
        break;
      case "OPTIONS":
        {
          // list.add("Diabetes");
          // list.add("Asthma");
          // list.add("Blood Pressure");
          // list.add("Allergy");
          // list.add("Hyper Tension");
          // list.add("Thyroid");
          //Implicit type cast of type Field to  type Options field
          //  FormInputFieldOptions optionField = field;

          newField = Column(
            children: [
              Row(
                children: [
                  Container(
                      width: MediaQuery.of(context).size.width * .2,
                      child: Text(
                        field.label,
                        style: textInputTextStyle,
                      )),
                  Expanded(
                    child: Wrap(
                      children: mapOfOptionsFields[field.label]
                          .map((item) => GestureDetector(
                              onTap: () {
                                bool newSelectionValue = !(item.isSelected);

                                mapOfOptionsFields[field.label]
                                    .forEach((element) {
                                  element.isSelected = false;
                                });

                                setState(() {
                                  item.isSelected = newSelectionValue;
                                });
                              },
                              child: Container(
                                  decoration: new BoxDecoration(
                                      border: Border.all(
                                          color: Colors.blueGrey[200]),
                                      shape: BoxShape.rectangle,
                                      color: (!item.isSelected)
                                          ? Colors.cyan[50]
                                          : highlightColor,
                                      borderRadius: BorderRadius.all(
                                          Radius.circular(15.0))),
                                  padding: EdgeInsets.all(8),
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
        }
        break;
      default:
        {
          newField = TextFormField(
            obscureText: false,
            maxLines: 1,
            minLines: 1,
            style: textInputTextStyle,
            keyboardType: TextInputType.text,
            controller: listOfControllers[field.label],
            decoration: CommonStyle.textFieldStyle(
                labelTextStr: field.label, hintTextStr: field.label),
            onChanged: (String value) {
              print(value);
            },
            onSaved: (String value) {
              print(value);
            },
          );
        }
        break;
    }

    return Container(
      color: Colors.white70,
      child: newField,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SafeArea(
        child: Form(
          key: _bookingFormKey,
          child: Column(
            children: [
              Expanded(
                child: ListView.builder(
                  padding:
                      EdgeInsets.all(MediaQuery.of(context).size.width * .026),
                  // itemExtent: itemSize,
                  // reverse: true,
                  shrinkWrap: true,
                  //scrollDirection: Axis.vertical,
                  itemBuilder: (BuildContext context, int index) {
                    _controllers.add(new TextEditingController());
                    return Container(
                      //color: Colors.grey,
                      //   height: MediaQuery.of(context).size.height * .55,
                      width: MediaQuery.of(context).size.width * .95,
                      child: buildChildItem(dummyForm.getFormFields()[index], index),
                    );
                  },
                  itemCount: dummyForm.getFormFields().length,
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  SizedBox(
                    width: MediaQuery.of(context).size.width * .8,
                    height: MediaQuery.of(context).size.height * .06,
                    child: RaisedButton(
                      elevation: 10.0,
                      color: highlightColor,
                      splashColor: Colors.orangeAccent[700],
                      textColor: Colors.white,
                      child: Text(
                        'Save Details & Book Slot',
                        style: TextStyle(fontSize: 20),
                      ),
                      onPressed: () {
                        print('Save please');
                      },
                    ),
                  ),
                ],
              ),

              // Text(dummyForm.formName),
              //  Text(dummyForm.headerMsg),
              // Container(
              //   child: TextFormField(
              //     obscureText: false,
              //     maxLines: 1,
              //     minLines: 1,
              //     style: textInputTextStyle,
              //     keyboardType: TextInputType.text,
              //     controller: _fieldController,
              //     decoration: CommonStyle.textFieldStyle(
              //         labelTextStr: "you", hintTextStr: ""),
              //     onChanged: (String value) {
              //       print(value);
              //     },
              //     onSaved: (String value) {
              //       print(value);
              //     },
              //   ),
              // ),
            ],
          ),
        ),
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
