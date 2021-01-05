import 'package:flutter/material.dart';
import 'package:noq/db/db_model/booking_form.dart';

import 'package:noq/style.dart';
import 'package:noq/widget/griditem.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

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
  List<Item> list = List();

  @override
  void initState() {
    super.initState();
    selectedList = List();
    list.add(Item("Diabetes1", true));
    list.add(Item("Diabetes2", true));
    list.add(Item("Diabetes3", true));
    list.add(Item("Heart", true));
    list.add(Item("Lungs", false));
    list.add(Item("Kidney", false));
    list.add(Item("Asthma", true));
    list.add(Item("Blood Pressure", false));
    list.add(Item("Hyper Tension", false));
    list.add(Item("Thyroid", false));
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
    List<String> list = new List<String>();
    list.add("Diabetes");
    list.add("Asthma");
    list.add("Blood Pressure");
    list.add("Allergy");
    list.add("Hyper Tension");
    list.add("Thyroid");

    FormInputFieldOptions f3 = new FormInputFieldOptions("Medical Conditions",
        true, "Medical COnditions(Select any)", list, true);
    List<String> list2 = new List<String>();
    list2.add("Diabetes");
    list2.add("Asthma");
    list2.add("Blood Pressure");
    list2.add("Allergy");
    list2.add("Hyper Tension");
    list2.add("Thyroid");

    FormInputFieldOptions f4 = new FormInputFieldOptions("Medical Conditions",
        true, "Medical COnditions(Select any)", list2, true);
    listOfFields.add(f1);
    listOfFields.add(f2);
    listOfFields.add(f3);
    // listOfFields.add(f4);

    dummyForm = new BookingForm(
        formName: "Token Allocation form",
        footerMsg: "Footer",
        headerMsg: "header",
        formFields: listOfFields,
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
              Wrap(
                children: list
                    .map((item) => GestureDetector(
                        onTap: () {
                          setState(() {
                            item.isSelected = !item.isSelected;
                          });
                        },
                        child: Container(
                            decoration: new BoxDecoration(
                                border: Border.all(color: Colors.blueGrey[200]),
                                shape: BoxShape.rectangle,
                                color: (item.isSelected)
                                    ? Colors.cyan[50]
                                    : highlightColor,
                                borderRadius:
                                    BorderRadius.all(Radius.circular(15.0))),
                            padding: EdgeInsets.all(8),
                            margin: EdgeInsets.all(8),
                            // color: Colors.orange,
                            child: Text(item.text))))
                    .toList()
                    .cast<Widget>(),
              ),
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
                    child: buildChildItem(dummyForm.formFields[index], index),
                  );
                },
                itemCount: dummyForm.formFields.length,
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
  Item(this.text, this.isSelected);
}
