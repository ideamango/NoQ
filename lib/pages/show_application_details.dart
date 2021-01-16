import 'package:flutter/material.dart';
import 'package:noq/db/db_model/booking_application.dart';
import 'package:noq/db/db_model/booking_form.dart';
import 'package:noq/enum/application_status.dart';
import 'package:noq/global_state.dart';
import 'package:noq/pages/applications_list.dart';
import 'package:noq/pages/covid_token_booking_form.dart';
import 'package:noq/pages/overview_page.dart';
import 'package:noq/services/circular_progress.dart';
import 'package:noq/style.dart';
import 'package:noq/userHomePage.dart';
import 'package:noq/utils.dart';
import 'package:noq/widget/appbar.dart';
import 'package:noq/widget/widgets.dart';

class ShowApplicationDetails extends StatefulWidget {
  final String entityId;
  final String bookingFormId;
  final ApplicationStatus status;
  ShowApplicationDetails(
      {Key key,
      @required this.entityId,
      @required this.bookingFormId,
      @required this.status})
      : super(key: key);
  @override
  _ShowApplicationDetailsState createState() => _ShowApplicationDetailsState();
}

class _ShowApplicationDetailsState extends State<ShowApplicationDetails> {
  bool initCompleted = false;
  GlobalState _gs;
  List<BookingApplication> list;
  TextEditingController notesController = new TextEditingController();
  TextEditingController nameController = new TextEditingController();

  @override
  void initState() {
    super.initState();
    getGlobalState().whenComplete(() {
      getListOfData();
      if (this.mounted) {
        setState(() {
          initCompleted = true;
        });
      } else
        initCompleted = true;
    });
    notesController.text = "XWLJRVER";
    nameController.text = "SMITA";
  }

  Future<void> getGlobalState() async {
    _gs = await GlobalState.getGlobalState();
  }

  getListOfData() {
    list = new List<BookingApplication>();
    //TODO: Generate dummy data as of now, later change to actual data

    initBookingForm();
    list.add(bookingApplication);
    return list;
  }

  List<Value> idProofTypesStrList = List<Value>();
  List<Item> idProofTypes = List<Item>();
  List<Value> medConditionsStrList = List<Value>();
  List<Item> medConditions = List<Item>();
  Map<String, TextEditingController> listOfControllers =
      new Map<String, TextEditingController>();

  //File _image; // Used only if you need a single picture
  // String _downloadUrl;
  BookingForm bookingForm;
  List<Field> fields;
  BookingApplication bookingApplication;
  FormInputFieldText nameInput;
  FormInputFieldDateTime dobInput;
  FormInputFieldText primaryPhone;
  FormInputFieldText alternatePhone;
  String _idProofType;
  FormInputFieldOptionsWithAttachments idProofField;
  FormInputFieldOptions healthDetailsInput;
  FormInputFieldText healthDetailsDesc;
  FormInputFieldText latInput;
  FormInputFieldText lonInput;
  FormInputFieldText addressInput;
  FormInputFieldText addresslandmark;
  FormInputFieldText addressLocality;
  FormInputFieldText addressCity;
  FormInputFieldText addressState;
  FormInputFieldText addressCountry;
  FormInputFieldText notesInput;
  FormInputFieldText addressPin;

  initBookingForm() {
    fields = List<Field>();
    idProofTypesStrList.add(Value('Passport'));
    idProofTypesStrList.add(Value('Driving License'));
    idProofTypesStrList.add(Value('Aadhar'));
    idProofTypesStrList.add(Value('PAN'));
    idProofTypesStrList.forEach((element) {
      idProofTypes.add(Item(element, false));
    });
    medConditionsStrList.add(Value('Chronic Kidney Disease'));
    medConditionsStrList.add(Value('Liver Disease'));
    medConditionsStrList.add(Value('Overweight and Severe Obesity'));
    medConditionsStrList
        .add(Value('Other Cardiovascular and Cerebrovascular Diseases'));
    medConditionsStrList.add(Value('Haemoglobin Disorders'));
    medConditionsStrList.add(Value('Pregnancy'));
    medConditionsStrList.add(Value('Heart Conditions'));
    medConditionsStrList.add(Value('Chronic Lung Disease'));
    medConditionsStrList.add(Value('HIV or Weakened Immune System'));

    medConditionsStrList.add(Value('Neurologic Conditions such as Dementia'));

    medConditionsStrList.add(Value('Diabetes'));

    medConditionsStrList.add(Value('Others (Specify below)'));

    medConditionsStrList.forEach((element) {
      medConditions.add(Item(element, false));
    });
    nameInput = FormInputFieldText("Name of Person", true,
        "Please enter your name as per Government ID proof", 50);
    nameInput.response = "SMITA Agarwal";

    dobInput = FormInputFieldDateTime(
      "Date of Birth",
      true,
      "Please select your Date of Birth",
    );
    dobInput.responseDateTime =
        DateTime.now().subtract(Duration(days: 365 * 30));

    primaryPhone = FormInputFieldText(
        "Primary Contact Number", true, "Primary Contact Number", 10);
    primaryPhone.response = "9611009823";

    alternatePhone = FormInputFieldText(
        "Alternate Contact Number", false, "Alternate Contact Number", 10);
    alternatePhone.response = "9611005523";

    idProofField = FormInputFieldOptionsWithAttachments("Id Proof", true,
        "Please upload Government Id proof", idProofTypesStrList, false);
    idProofField.responseFilePaths = List<String>();
    idProofField.responseValues = new List<Value>();
    Value dl = Value("DL");
    Value pan = Value("PAN");
    Value liver = Value("Liver Disease");
    Value heart = Value("Heart Disease");
    idProofField.responseValues.add(dl);
    idProofField.responseFilePaths.add(
        "https://firebasestorage.googleapis.com/v0/b/sukoon-india.appspot.com/o/landscape.png?alt=media&token=b3a09803-dda9-4576-a26a-4856cada5c63");
    idProofField.responseFilePaths.add(
        "https://firebasestorage.googleapis.com/v0/b/sukoon-india.appspot.com/o/DL.jpg?alt=media&token=99957a19-7a65-4d80-a107-3ef19036dc34");
    idProofField.options.add(dl);
    idProofField.options.add(pan);

    healthDetailsInput = FormInputFieldOptions(
        "Medical Conditions",
        true,
        "Please select all known medical conditions you have",
        medConditionsStrList,
        true);
    healthDetailsInput.responseValues = new List<Value>();
    healthDetailsInput.responseValues.add(liver);
    healthDetailsInput.responseValues.add(heart);

    healthDetailsDesc = FormInputFieldText(
        "Decription of medical conditions (optional)",
        false,
        "Decription of medical conditions (optional)",
        200);
    healthDetailsDesc.response = "Migraine";

    latInput = FormInputFieldText(
        "Current Location Latitude", false, "Current Location Latitude", 20);
    latInput.response = "HOMe0023";

    lonInput = FormInputFieldText(
        "Current Location Longitude", false, "Current Location Longitude", 20);
    lonInput.response = "Lon";

    fields.add(nameInput);
    fields.add(dobInput);
    fields.add(primaryPhone);
    fields.add(alternatePhone);
    fields.add(idProofField);
    fields.add(healthDetailsInput);
    fields.add(healthDetailsDesc);
    fields.add(latInput);
    fields.add(lonInput);

    addressInput = FormInputFieldText(
        "Apartment/ House No./ Lane", false, "Apartment/ House No./ Lane", 60);
    fields.add(addressInput);
    addresslandmark = FormInputFieldText("Landmark", false, "Landmark", 40);
    fields.add(addresslandmark);
    addressLocality = FormInputFieldText("Locality", false, "Locality", 40);
    fields.add(addressLocality);
    addressCity = FormInputFieldText("City", false, "City", 30);
    fields.add(addressCity);
    addressState = FormInputFieldText("State", false, "State", 30);
    fields.add(addressState);
    addressCountry = FormInputFieldText("Country", false, "Country", 30);
    fields.add(addressCountry);
    addressPin = FormInputFieldText("Pin Code", false, "Pin Code", 30);
    fields.add(addressPin);
    notesInput =
        FormInputFieldText("Notes (optional)", false, "Notes (optional)", 100);
    fields.add(notesInput);

    bookingForm = new BookingForm(
        formName: "Covid-19 Vacination Applicant Details",
        headerMsg:
            "Your request will be approved based on the information provided by you.",
        footerMsg:
            "Please carry same ID proof (uploaded here) to the Vaccination center for verification purpose.",
        autoApproved: false);

    bookingApplication = new BookingApplication();
    //slot

    bookingApplication.preferredSlotTiming = DateTime.now();
    bookingApplication.status = ApplicationStatus.CANCELLED;
    //bookingFormId
    // bookingApplication.bookingFormId = widget.bookingFormId;
    bookingApplication.entityId = "SELENium Id";
    bookingApplication.userId = _gs.getCurrentUser().id;
    bookingApplication.status = ApplicationStatus.NEW;
    bookingApplication.responseForm = bookingForm;
  }

  Widget _emptyPage() {
    return Center(
      child: Container(
        height: MediaQuery.of(context).size.height * .6,
        alignment: Alignment.center,
        child: SingleChildScrollView(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                SizedBox(height: MediaQuery.of(context).size.height * .02),
                Container(
                  color: Colors.transparent,
                  child: Text("No Approved Requests!"),
                  // child: Image(
                  //image: AssetImage('assets/search_home.png'),
                  // )
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  List<Widget> showListOfData() {
    return list.map(_buildItem).toList();
    // return _stores.map((contact) => new ChildItem(contact.name)).toList();
  }

  Widget buildChildItem(Field field) {
    if (!listOfControllers.containsKey(field.label)) {
      listOfControllers[field.label] = new TextEditingController();
    }
    Widget fieldWidget;
    Widget fieldsContainer = Container();
    if (field != null) {
      if (field.isMandatory) {
        switch (field.type) {
          case "TEXT":
            {
              FormInputFieldText newfield = field;
              fieldWidget = TextField(
                controller: listOfControllers[field.label],
                readOnly: true,
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.blueGrey[500],
                ),
                decoration: InputDecoration(
                  labelText: newfield.label,
                  labelStyle: TextStyle(
                      fontSize: 20,
                      color: Colors.indigo[900],
                      fontWeight: FontWeight.bold,
                      fontFamily: 'RalewayRegular'),
                  enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.grey)),
                  focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.orange)),
                  // errorText:
                  //     _validate ? 'Please enter your message' : null,
                ),
                // keyboardType: TextInputType.multiline,
              );
              listOfControllers[field.label].text =
                  newfield.response.toString();
            }
            break;
          case "NUMBER":
            {
              FormInputFieldNumber newfield = field;
              fieldWidget = TextField(
                controller: listOfControllers[field.label],
                readOnly: true,
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.blueGrey[500],
                ),
                decoration: InputDecoration(
                  labelText: newfield.label,
                  labelStyle: TextStyle(
                      fontSize: 20,
                      color: Colors.indigo[900],
                      fontWeight: FontWeight.bold,
                      fontFamily: 'RalewayRegular'),
                  enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.grey)),
                  focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.orange)),
                  // errorText:
                  //     _validate ? 'Please enter your message' : null,
                ),
                // keyboardType: TextInputType.text,
              );
              listOfControllers[field.label].text =
                  (newfield.response.toString());
            }
            break;
          case "PHONE":
            {
              FormInputFieldNumber newfield = field;
              fieldWidget = fieldWidget = TextField(
                controller: listOfControllers[field.label],
                readOnly: true,
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.blueGrey[500],
                ),
                decoration: InputDecoration(
                  labelText: newfield.label,
                  labelStyle: TextStyle(
                      fontSize: 20,
                      color: Colors.indigo[900],
                      fontWeight: FontWeight.bold,
                      fontFamily: 'RalewayRegular'),
                  enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.grey)),
                  focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.orange)),
                  // errorText:
                  //     _validate ? 'Please enter your message' : null,
                ),
                //keyboardType: TextInputType.multiline,
              );
              listOfControllers[field.label].text =
                  "+91 ${newfield.response.toString()}";
            }
            break;

          case "DATETIME":
            {
              FormInputFieldDateTime newfield = field;
              fieldWidget = TextField(
                controller: listOfControllers[field.label],
                readOnly: true,
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.blueGrey[500],
                ),
                decoration: InputDecoration(
                  labelText: (newfield.label == "Date of Birth")
                      ? "Age"
                      : newfield.label,
                  labelStyle: TextStyle(
                      fontSize: 20,
                      color: Colors.indigo[900],
                      fontWeight: FontWeight.bold,
                      fontFamily: 'RalewayRegular'),
                  enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.grey)),
                  focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.orange)),
                  // errorText:
                  //     _validate ? 'Please enter your message' : null,
                ),
                //keyboardType: TextInputType.text,
              );
              listOfControllers[field.label].text =
                  (newfield.label == "Date of Birth")
                      ? ((DateTime.now()
                                  .difference(newfield.responseDateTime)
                                  .inDays) /
                              365)
                          .toStringAsFixed(0)
                      : newfield.label;
            }
            break;
          case "OPTIONS":
            {
              FormInputFieldOptions newfield = field;
              fieldWidget = fieldWidget = TextField(
                controller: listOfControllers[field.label],
                readOnly: true,
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.blueGrey[500],
                ),
                decoration: InputDecoration(
                  labelText: newfield.label,
                  labelStyle: TextStyle(
                      fontSize: 20,
                      color: Colors.indigo[900],
                      fontWeight: FontWeight.bold,
                      fontFamily: 'RalewayRegular'),
                  enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.grey)),
                  focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.orange)),
                  // errorText:
                  //     _validate ? 'Please enter your message' : null,
                ),
                // keyboardType: TextInputType.multiline,
              );
              String conds = "";

              if (newfield.isMultiSelect) {
                if (Utils.isNullOrEmpty(newfield.responseValues)) {
                  conds = "None";
                }
                for (int i = 0; i < newfield.responseValues.length; i++) {
                  if (conds != "")
                    conds = conds + "  |  " + newfield.responseValues[i].value;
                  else
                    conds = conds + newfield.responseValues[i].toString();
                }
              }

              listOfControllers[field.label].text = conds;
            }
            break;
          case "OPTIONS_ATTACHMENTS":
            {
              FormInputFieldOptionsWithAttachments newfield = field;
              // Widget attachmentList = Container(
              //     child: ListView.builder(
              //   itemBuilder: (BuildContext context, int index) {
              //     return Container(
              //       margin: EdgeInsets.fromLTRB(10, 10, 10, 10),
              //       child: Container(

              //         child: Image.network(newfield.responseFilePaths[index])),
              //     );
              //   },
              //   itemCount: newfield.responseFilePaths.length,
              // ));

              fieldWidget = Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  SizedBox(
                    width: MediaQuery.of(context).size.width * .3,
                    child: TextField(
                      controller: listOfControllers[field.label],
                      readOnly: true,
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.blueGrey[500],
                      ),
                      textAlign: TextAlign.start,
                      decoration: InputDecoration(
                        labelText: newfield.label,
                        labelStyle: TextStyle(
                            fontSize: 20,
                            color: Colors.indigo[900],
                            fontWeight: FontWeight.bold,
                            fontFamily: 'RalewayRegular'),
                        enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.grey)),
                        focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.orange)),
                        // errorText:
                        //     _validate ? 'Please enter your message' : null,
                      ),
                      //  keyboardType: TextInputType.multiline,
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      SizedBox(
                          width: MediaQuery.of(context).size.width * .16,
                          height: MediaQuery.of(context).size.width * .16,
                          child: Image.network(
                            newfield.responseFilePaths[0],
                            scale: 5.0,
                          )),
                      horizontalSpacer,
                      (newfield.responseFilePaths.length > 1)
                          ? SizedBox(
                              width: MediaQuery.of(context).size.width * .16,
                              height: MediaQuery.of(context).size.width * .16,
                              child:
                                  Image.network(newfield.responseFilePaths[1]))
                          : SizedBox(),
                    ],
                  ),

                  // Column(
                  //   children: [
                  //     attachmentList,
                  //   ],
                  // )
                ],
              );
              String conds = "";

              if (newfield.isMultiSelect) {
                if (Utils.isNullOrEmpty(newfield.responseValues)) {
                  conds = "None";
                }
                for (int i = 0; i < newfield.responseValues.length; i++) {
                  if (conds != "")
                    conds = conds + "  |  " + newfield.responseValues[i].value;
                  else
                    conds = conds + newfield.responseValues[i].toString();
                }
              } else
                conds = newfield.responseValues[0].toString();
              listOfControllers[field.label].text = conds;
            }
            break;
          default:
            {
              fieldWidget = Text("Could not fetch data");
            }
            break;
        }

        fieldsContainer = Wrap(children: [
          Container(
              width: MediaQuery.of(context).size.width * .9,
              padding: EdgeInsets.all(0),
              // decoration: BoxDecoration(
              //   // border: Border.all(color: Colors.teal[200]),
              //   shape: BoxShape.rectangle,
              //   // color: Colors.cyan[50],
              // ),
              child: fieldWidget),
        ]);
      }
    }
    return fieldsContainer;
  }

  Widget _buildItem(BookingApplication ba) {
    return Card(
      // margin: EdgeInsets.fromLTRB(8, 12, 8, 0),
      elevation: 10,
      child: Container(
        padding: EdgeInsets.all(10),
        margin: EdgeInsets.all(8),
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height * .82,
        child: Column(
          children: <Widget>[
            Expanded(
              child: ListView.builder(
                padding:
                    EdgeInsets.all(MediaQuery.of(context).size.width * .026),
                shrinkWrap: true,
                //scrollDirection: Axis.vertical,
                itemBuilder: (BuildContext context, int index) {
                  return Container(
                    padding: EdgeInsets.all(5),
                    //  height: MediaQuery.of(context).size.height * .3,
                    child: buildChildItem(
                        bookingApplication.responseForm.getFormFields()[index]),
                  );
                },
                itemCount:
                    bookingApplication.responseForm.getFormFields().length,
              ),
            )
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (initCompleted) {
      return MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData.light().copyWith(),
        home: WillPopScope(
          child: Scaffold(
            appBar: AppBar(
              title: Text(
                "Details",
                style: drawerdefaultTextStyle,
              ),
              flexibleSpace: Container(
                decoration: gradientBackground,
              ),
              leading: IconButton(
                  padding: EdgeInsets.all(0),
                  alignment: Alignment.center,
                  highlightColor: Colors.orange[300],
                  icon: Icon(Icons.arrow_back),
                  color: Colors.white,
                  onPressed: () {
                    Navigator.of(context).pop();
                  }),
            ),
            body: Center(
              child: Column(
                children: <Widget>[
                  (!Utils.isNullOrEmpty(list))
                      ? Expanded(
                          child: ListView.builder(
                              itemCount: 1,
                              // reverse: true,
                              itemBuilder: (BuildContext context, int index) {
                                return Container(
                                  margin: EdgeInsets.fromLTRB(10, 0, 10, 50),
                                  child: new Column(
                                    children: showListOfData(),
                                  ),
                                );
                              }),
                        )
                      : _emptyPage(),
                  Container(
                      margin: EdgeInsets.fromLTRB(10, 10, 10, 10),
                      child: TextField(
                        controller: notesController,
                        decoration: InputDecoration(
                          labelText: 'Remarks',
                          enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.grey)),
                          focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.orange)),
                          // errorText:
                          //     _validate ? 'Please enter your message' : null,
                        ),
                        keyboardType: TextInputType.multiline,
                        maxLength: null,
                        maxLines: 2,
                      )),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      RaisedButton(
                          color: Colors.green[400],
                          onPressed: () {
                            bookingApplication.notesOnApproval =
                                notesController.text;
                            bookingApplication.status =
                                ApplicationStatus.APPROVED;
                            Utils.showMyFlushbar(
                                context,
                                Icons.check,
                                Duration(seconds: 4),
                                "Application Saved!!",
                                "");
                            //TODO: Add server code
                          },
                          child: Row(children: [
                            Text(
                              "Approve",
                              // style: TextStyle(),
                            ),
                            Icon(
                              Icons.check_circle,
                            )
                          ])),
                      RaisedButton(
                        color: Colors.yellow[700],
                        onPressed: () {
                          bookingApplication.notesOnPuttingOnHold =
                              notesController.text;
                          bookingApplication.status = ApplicationStatus.ONHOLD;
                          Utils.showMyFlushbar(context, Icons.check,
                              Duration(seconds: 4), "Application Saved!!", "");
                        },
                        child: Row(children: [
                          Text(
                            "On-Hold",
                            // style: buttonTextStyle,
                          ),
                          Icon(
                            Icons.pan_tool_rounded,
                          )
                        ]),
                      ),
                      RaisedButton(
                        color: Colors.red,
                        onPressed: () {
                          bookingApplication.notesOnRejection =
                              notesController.text;
                          bookingApplication.status =
                              ApplicationStatus.REJECTED;
                          Utils.showMyFlushbar(context, Icons.check,
                              Duration(seconds: 4), "Application Saved!!", "");
                        },
                        child: Row(children: [
                          Text(
                            "Reject",
                            //  style: buttonTextStyle,
                          ),
                          Icon(
                            Icons.cancel_rounded,
                            //color: Colors.red,
                          )
                        ]),
                      ),
                    ],
                  )
                ],
              ),
            ),
          ),
          onWillPop: () async {
            return true;
          },
        ),
      );
    } else {
      return MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData.light().copyWith(),
        home: new WillPopScope(
          child: Scaffold(
            appBar: CustomAppBarWithBackButton(
              backRoute: UserHomePage(),
              titleTxt: "Approved Requests",
            ),
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  showCircularProgress(),
                ],
              ),
            ),
          ),
          onWillPop: () async {
            return true;
          },
        ),
      );
    }
  }
}
