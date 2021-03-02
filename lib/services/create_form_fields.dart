import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:noq/db/db_model/booking_form.dart';
import 'package:noq/db/db_model/meta_entity.dart';
import 'package:noq/enum/field_type.dart';
import 'package:noq/global_state.dart';
import 'package:noq/services/circular_progress.dart';

import 'package:noq/style.dart';
import 'package:noq/utils.dart';
import 'package:noq/widget/custom_expansion_tile.dart';

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

  List<File> _medCondsProofimages = [];
  bool validateField = false;
  Map<String, Widget> listOfWidgets = new Map<String, Widget>();
  Map<String, List> listOfFieldTypes = new Map<String, List>();

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
        initPage();
        setState(() {
          _initCompleted = true;
        });
      });
    });
  }

  void initPage() {
    List<Field> listOfFields = dummyForm.getFormFields();
    Widget newField;
    for (int i = 0; i < listOfFields.length; i++) {
      Field field = listOfFields[i];
      newField = buildChildItem(field, i, true);
      listOfWidgets[field.label] = newField;
    }
  }

  Future<void> getGlobalState() async {
    _gs = await GlobalState.getGlobalState();
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
          FormInputFieldOptions newOptionsField = field;
          if (isInit) {
            List<Item> newOptionsFieldTypesList = List<Item>();
            for (Value val in newOptionsField.options) {
              newOptionsFieldTypesList.add(Item(val, false));
            }
            listOfFieldTypes[field.label] = newOptionsFieldTypesList;
          }
          newField = Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: Wrap(
                      children: listOfFieldTypes[field.label]
                          .map((item) => GestureDetector(
                              onTap: () {
                                bool newSelectionValue = !(item.isSelected);
                                if (newOptionsField.isMultiSelect == false) {
                                  listOfFieldTypes[field.label]
                                      .forEach((element) {
                                    element.isSelected = false;
                                  });
                                }
                                if (item.isSelected == true)
                                  newOptionsField.responseValues
                                      .remove(item.value);
                                else
                                  newOptionsField.responseValues
                                      .add(item.value);

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
                                          Radius.circular(30.0))),
                                  padding: EdgeInsets.fromLTRB(8, 5, 8, 5),
                                  margin: EdgeInsets.all(8),
                                  // color: Colors.orange,
                                  child: Text(item.value.value))))
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
      case FieldType.OPTIONS_ATTACHMENTS:
        {
          // list.add("Diabetes");
          // list.add("Asthma");
          // list.add("Blood Pressure");
          // list.add("Allergy");
          // list.add("Hyper Tension");
          // list.add("Thyroid");
          //Implicit type cast of type Field to  type Options field
          //  FormInputFieldOptions optionField = field;
          FormInputFieldOptionsWithAttachments optsAttsField = field;
          if (isInit) {
            List<Item> newfieldOptionsTypesList = List<Item>();
            for (Value val in optsAttsField.options) {
              newfieldOptionsTypesList.add(Item(val, false));
            }
            listOfFieldTypes[field.label] = newfieldOptionsTypesList;
          }

          newField = Container(
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
                              children: listOfFieldTypes[field.label]
                                  .map((item) => GestureDetector(
                                      onTap: () {
                                        bool newSelectionValue =
                                            !(item.isSelected);
                                        if (optsAttsField.isMultiSelect ==
                                            false) {
                                          listOfFieldTypes[field.label]
                                              .forEach((element) {
                                            element.isSelected = false;
                                          });
                                        }
                                        if (item.isSelected == true)
                                          optsAttsField.responseValues
                                              .remove(item.value);
                                        else
                                          optsAttsField.responseValues
                                              .add(item.value);

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
                                                  Radius.circular(30.0))),
                                          padding:
                                              EdgeInsets.fromLTRB(8, 5, 8, 5),
                                          margin: EdgeInsets.all(8),
                                          // color: Colors.orange,
                                          child: Text(item.value.value))))
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
                                            _medCondsProofimages[index],
                                            _medCondsProofimages),
                                      );
                                    },
                                    itemCount: _medCondsProofimages.length,
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
                                        _medCondsProofimages.add(value);
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
                                        _medCondsProofimages.add(value);
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
      BuildContext context, File imageUrl, List<File> filesList) {
    return Stack(
      alignment: AlignmentDirectional.topEnd,
      children: [
        Image.file(imageUrl),
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

  saveRoute() async {
    setState(() {
      validateField = true;
    });

    // validationErrMsg = "";

    // if (validateAllFields()) {
    //   Utils.showMyFlushbar(
    //       context,
    //       Icons.info_outline,
    //       Duration(
    //         seconds: 4,
    //       ),
    //       "Saving details!! ",
    //       "This would take just a moment.",
    //       Colors.white,
    //       true);

    //   _tokenBookingDetailsFormKey.currentState.save();

    //   // bookingApplication.preferredSlotTiming =
    //   //TODO:Save Files and then submit application with the updated file path
    //   List<String> idProofTargetPaths = List<String>();
    //   for (String path in idProofField.responseFilePaths) {
    //     String fileName = basename(path);
    //     print(fileName);

    //     String targetFileName =
    //         '${bookingApplication.id}#${idProofField.id}#${_gs.getCurrentUser().id}#$fileName';

    //     String targetPath = await uploadFilesToServer(path, targetFileName);
    //     print(targetPath);
    //     idProofTargetPaths.add(targetPath);
    //   }

    //   idProofField.responseFilePaths = idProofTargetPaths;

    //   List<String> medCondsTargetPaths = List<String>();
    //   for (String path in medConditionsField.responseFilePaths) {
    //     String fileName = basename(path);
    //     print(fileName);

    //     String targetFileName =
    //         '${bookingApplication.id}#${medConditionsField.id}#${_gs.getCurrentUser().id}#$fileName';

    //     String targetPath = await uploadFilesToServer(path, targetFileName);
    //     print(targetPath);
    //     medCondsTargetPaths.add(targetPath);
    //   }
    //   medConditionsField.responseFilePaths = medCondsTargetPaths;

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

    //   _gs
    //       .getApplicationService()
    //       .submitApplication(bookingApplication, metaEntity)
    //       .then((value) {
    //     if (value) {
    //       Utils.showMyFlushbar(
    //           context,
    //           Icons.check,
    //           Duration(
    //             seconds: 5,
    //           ),
    //           "Request submitted successfully!",
    //           'We will contact you as soon as slot opens up. Stay Safe!');
    //     }
    //   });
    // } else {
    //   print(validationErrMsg);
    //   Utils.showMyFlushbar(
    //       context,
    //       Icons.error,
    //       Duration(
    //         seconds: 10,
    //       ),
    //       validationErrMsg,
    //       "Please fill all mandatory fields and save again.",
    //       Colors.red);
    // }
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
                                  dummyForm.getFormFields()[index],
                                  index,
                                  false),
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
  Value value;
  bool isSelected;
  String lastSelected;

  Item(this.value, this.isSelected);
}
