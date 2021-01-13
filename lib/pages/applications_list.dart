import 'package:flutter/material.dart';
import 'package:noq/db/db_model/booking_application.dart';
import 'package:noq/db/db_model/booking_form.dart';
import 'package:noq/enum/application_status.dart';
import 'package:noq/global_state.dart';
import 'package:noq/pages/covid_token_booking_form.dart';
import 'package:noq/pages/overview_page.dart';
import 'package:noq/services/circular_progress.dart';
import 'package:noq/style.dart';
import 'package:noq/userHomePage.dart';
import 'package:noq/utils.dart';
import 'package:noq/widget/appbar.dart';

class ApplicationsList extends StatefulWidget {
  final String entityId;
  final String bookingFormId;
  final ApplicationStatus status;
  ApplicationsList(
      {Key key,
      @required this.entityId,
      @required this.bookingFormId,
      @required this.status})
      : super(key: key);
  @override
  _ApplicationsListState createState() => _ApplicationsListState();
}

class _ApplicationsListState extends State<ApplicationsList> {
  bool initCompleted = false;
  GlobalState _gs;
  List<BookingApplication> list;
  TextEditingController notesController = new TextEditingController();

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

  List<String> idProofTypesStrList = List<String>();
  List<Item> idProofTypes = List<Item>();
  List<String> medConditionsStrList = List<String>();
  List<Item> medConditions = List<Item>();

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
    idProofTypesStrList.add('Passport');
    idProofTypesStrList.add('Driving License');
    idProofTypesStrList.add('Aadhar');
    idProofTypesStrList.add('PAN');
    idProofTypesStrList.forEach((element) {
      idProofTypes.add(Item(element, false));
    });
    medConditionsStrList.add('Chronic Kidney Disease');
    medConditionsStrList.add('Liver Disease');
    medConditionsStrList.add('Overweight and Severe Obesity');
    medConditionsStrList
        .add('Other Cardiovascular and Cerebrovascular Diseases');
    medConditionsStrList.add('Haemoglobin Disorders');
    medConditionsStrList.add('Pregnancy');
    medConditionsStrList.add('Heart Conditions');
    medConditionsStrList.add('Chronic Lung Disease');
    medConditionsStrList.add('HIV or Weakened Immune System');

    medConditionsStrList.add('Neurologic Conditions such as Dementia');

    medConditionsStrList.add('Diabetes');

    medConditionsStrList.add('Others (Specify below)');

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

    idProofField = FormInputFieldOptionsWithAttachments("Id Proof File Url",
        true, "Please upload Government Id proof", idProofTypesStrList, false);
    idProofField.responseFilePaths = List<String>();
    idProofField.responseValues = new List<String>();
    idProofField.responseValues.add("x.com");
    idProofField.responseValues.add("y.com");
    idProofField.options.add("DL");

    healthDetailsInput = FormInputFieldOptions(
        "Medical Conditions",
        true,
        "Please select all known medical conditions you have",
        medConditionsStrList,
        true);

    healthDetailsDesc = FormInputFieldText(
        "Decription of medical conditions (optional)",
        true,
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
        formFields: fields,
        autoApproved: false);

    bookingApplication = new BookingApplication();
    //slot

    bookingApplication.preferredSlotTiming = DateTime.now();
    bookingApplication.status = ApplicationStatus.CANCELLED;
    //bookingFormId
    // bookingApplication.bookingFormId = widget.bookingFormId;
    bookingApplication.entityId = "SELENium Id";
    bookingApplication.userId = _gs.getCurrentUser().id;
    bookingApplication.status = ApplicationStatus.INPROCESS;
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
    Widget fieldWidget;
    Widget fieldsContainer = Container();
    if (field != null) {
      if (field.isMandatory) {
        switch (field.type) {
          case "TEXT":
            {
              FormInputFieldText newfield = field;
              fieldWidget = Text(newfield.response);
            }
            break;
          case "NUMBER":
            {
              FormInputFieldNumber newfield = field;
              fieldWidget = Text(newfield.response.toString());
            }
            break;
          case "PHONE":
            {
              FormInputFieldNumber newfield = field;
              fieldWidget = Text("+91 ${newfield.response.toString()}");
            }
            break;

          case "DATETIME":
            {
              FormInputFieldDateTime newfield = field;
              fieldWidget = Text(newfield.responseDateTime.toString());
            }
            break;
          case "OPTIONS":
            {
              FormInputFieldOptions newfield = field;
              fieldWidget = Text(newfield.responseValues.toString());
            }
            break;
          case "OPTIONS_ATTACHMENTS":
            {
              FormInputFieldOptionsWithAttachments newfield = field;
              fieldWidget = Column(
                children: [
                  Text(newfield.responseValues.toString()),
                  Text("Show attachments please"),
                  //TODO : show images from response file path
                ],
              );
            }
            break;
          default:
            {
              fieldWidget = Text("Could not fetch data");
            }
            break;
        }

        fieldsContainer = Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Wrap(children: [
              Container(
                width: MediaQuery.of(context).size.width * .3,
                child: Text(
                  field.label,
                ),
              )
            ]),
            Wrap(children: [
              Container(
                  width: MediaQuery.of(context).size.width * .4,
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.teal[200]),
                    shape: BoxShape.rectangle,
                    color: Colors.cyan[50],
                  ),
                  child: fieldWidget),
            ]),
          ],
        );
      }
    }
    return fieldsContainer;
  }

  Widget _buildItem(BookingApplication ba) {
    return Container(
      padding: EdgeInsets.all(10),
      margin: EdgeInsets.all(8),
      width: MediaQuery.of(context).size.width * .9,
      height: MediaQuery.of(context).size.height * .82,
      child: Column(
        children: <Widget>[
          Expanded(
            child: ListView.builder(
              padding: EdgeInsets.all(MediaQuery.of(context).size.width * .026),
              shrinkWrap: true,
              //scrollDirection: Axis.vertical,
              itemBuilder: (BuildContext context, int index) {
                return Container(
                  padding: EdgeInsets.all(5),
                  //  height: MediaQuery.of(context).size.height * .3,
                  child: Card(
                    child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // Container(
                          //   height: 40,
                          //   margin: EdgeInsets.fromLTRB(0, 0, 0, 0),
                          //   width: MediaQuery.of(context).size.width * .06,
                          //   child: Checkbox(
                          //     value: false,
                          //     onChanged: (value) {
                          //       setState(() {
                          //         value = !value;
                          //       });
                          //     },
                          //     activeColor: primaryIcon,
                          //     checkColor: primaryAccentColor,
                          //   ),
                          // ),
                          Text(
                            'SMita',
                            style: linkTextStyle,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              IconButton(
                                  color: Colors.purple[200],
                                  onPressed: () {
                                    bookingApplication.notesOnApproval =
                                        notesController.text;
                                    bookingApplication.status =
                                        ApplicationStatus.APPROVED;
                                  },
                                  icon: Icon(Icons.check_circle)),
                              IconButton(
                                color: Colors.greenAccent,
                                onPressed: () {
                                  bookingApplication.notesOnPuttingOnHold =
                                      notesController.text;
                                  bookingApplication.status =
                                      ApplicationStatus.ONHOLD;
                                },
                                icon: Icon(Icons.pan_tool),
                              ),
                              IconButton(
                                color: Colors.orange,
                                onPressed: () {
                                  bookingApplication.notesOnRejection =
                                      notesController.text;
                                  bookingApplication.status =
                                      ApplicationStatus.REJECTED;
                                },
                                icon: Icon(Icons.cancel),
                              ),
                            ],
                          )
                        ]),
                  ),
                );
              },
              itemCount: 1,
            ),
          )
        ],
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
            appBar: CustomAppBarWithBackButton(
              backRoute: OverviewPage(
                entityId: widget.entityId,
              ),
              titleTxt: "Applications In-Process",
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
                        readOnly: true,
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
