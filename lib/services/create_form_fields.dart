import 'package:flutter/material.dart';
import 'package:noq/db/db_model/booking_form.dart';
import 'package:noq/db/db_model/meta_entity.dart';
import 'package:noq/enum/field_type.dart';
import 'package:noq/global_state.dart';
import 'package:noq/services/circular_progress.dart';

import 'package:noq/style.dart';

class CreateFormFields extends StatefulWidget {
  final MetaEntity metaEntity;
  final String bookingFormId;
  final DateTime preferredSlotTime;
  final dynamic backRoute;
  CreateFormFields(
      {Key key,
      @required this.metaEntity,
      @required this.bookingFormId,
      @required this.preferredSlotTime,
      @required this.backRoute})
      : super(key: key);

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
  Map<String, List<Item>> mapOfOptionsFields = Map<String, List<Item>>();
  List<Item> listf3 = new List<Item>();
  List<Item> listf4 = new List<Item>();
  bool _initCompleted = false;

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
        setState(() {
          _initCompleted = true;
        });
      });
    });
  }

  Future<void> getGlobalState() async {
    _gs = await GlobalState.getGlobalState();
  }

  Widget buildChildItem(Field field, int index) {
    if (!listOfControllers.containsKey(field.label)) {
      listOfControllers[field.label] = new TextEditingController();
    }
    Widget newField;
    switch (field.type) {
      case FieldType.TEXT:
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
      case FieldType.NUMBER:
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
      case FieldType.OPTIONS:
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
                  Navigator.of(context).pop();
                },
              ),
              title: Text("Booking Request Form",
                  style: TextStyle(color: Colors.white, fontSize: 16)),
            ),
            body: Center(
              child: SafeArea(
                child: Form(
                  key: _bookingFormKey,
                  child: Column(
                    children: [
                      Expanded(
                        child: ListView.builder(
                          padding: EdgeInsets.all(
                              MediaQuery.of(context).size.width * .026),
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
                              child: buildChildItem(
                                  dummyForm.getFormFields()[index], index),
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

class Item {
  String text;
  bool isSelected;
  String lastSelected;

  Item(this.text, this.isSelected);
}
