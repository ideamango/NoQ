import 'package:LESSs/constants.dart';
import 'package:LESSs/pages/token_alert.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:enum_to_string/enum_to_string.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../db/db_model/booking_application.dart';
import '../db/db_model/booking_form.dart';
import '../db/db_model/meta_entity.dart';
import '../enum/application_status.dart';
import '../enum/field_type.dart';
import '../global_state.dart';
import '../pages/applications_list.dart';
import '../pages/covid_token_booking_form.dart';
import '../pages/overview_page.dart';
import '../services/circular_progress.dart';
import '../style.dart';
import '../userHomePage.dart';
import '../utils.dart';
import '../widget/appbar.dart';
import '../widget/widgets.dart';

class ShowApplicationDetails extends StatefulWidget {
  final BookingApplication bookingApplication;

  ShowApplicationDetails({
    Key key,
    @required this.bookingApplication,
  }) : super(key: key);
  @override
  _ShowApplicationDetailsState createState() => _ShowApplicationDetailsState();
}

class _ShowApplicationDetailsState extends State<ShowApplicationDetails> {
  bool initCompleted = false;
  GlobalState _gs;
  List<BookingApplication> list;
  TextEditingController notesController = new TextEditingController();
  MetaEntity metaEntity;

  @override
  void initState() {
    super.initState();
    getGlobalState().whenComplete(() {
      //getListOfData();
      if (this.mounted) {
        _gs.getEntity(widget.bookingApplication.entityId).then((value) {
          if (value != null) metaEntity = value.item1.getMetaEntity();
          setState(() {
            initCompleted = true;
          });
        });
      } else
        initCompleted = true;
    });
  }

  Future<void> getGlobalState() async {
    _gs = await GlobalState.getGlobalState();
  }

  // getListOfData() {
  //   list = new List<BookingApplication>();
  //   //TODO: Generate dummy data as of now, later change to actual data

  //   initBookingForm();
  //   list.add(bookingApplication);
  //   return list;
  // }

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
    idProofField.responseValues.add(Value("DL"));

    healthDetailsInput = FormInputFieldOptions(
        "Medical Conditions",
        true,
        "Please select all known medical conditions you have",
        medConditionsStrList,
        true);
    healthDetailsInput.responseValues = new List<Value>();
    healthDetailsInput.responseValues.add(Value("liver"));
    healthDetailsInput.responseValues.add(Value("heart"));

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

    // bookingApplication = new BookingApplication();
    // //slot

    // bookingApplication.preferredSlotTiming = DateTime.now();
    // bookingApplication.status = ApplicationStatus.CANCELLED;
    // //bookingFormId
    // // bookingApplication.bookingFormId = widget.bookingFormId;
    // bookingApplication.entityId = "SELENium Id";
    // bookingApplication.userId = _gs.getCurrentUser().id;
    // bookingApplication.status = ApplicationStatus.NEW;
    // bookingApplication.responseForm = bookingForm;
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

  Widget buildChildItem(Field field) {
    if (!listOfControllers.containsKey(field.label)) {
      listOfControllers[field.label] = new TextEditingController();
    }
    print(field.label);
    Widget fieldWidget = SizedBox();
    Widget fieldsContainer = SizedBox();
    if (field != null) {
      switch (field.type) {
        case FieldType.TEXT:
          {
            FormInputFieldText newfield = field;
            fieldWidget = SizedBox(
              width: MediaQuery.of(context).size.width * .3,
              height: MediaQuery.of(context).size.height * .07,
              child: TextField(
                controller: listOfControllers[field.label],
                readOnly: true,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.indigo[900],
                ),
                decoration: InputDecoration(
                  labelText: newfield.label,
                  labelStyle: TextStyle(
                      fontSize: 13,
                      color: Colors.blueGrey[500],
                      fontWeight: FontWeight.bold,
                      fontFamily: 'RalewayRegular'),
                  enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.grey[300])),
                  focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.orange[300])),
                  // enabledBorder: OutlineInputBorder(
                  //     borderSide: BorderSide(color: Colors.grey)),
                  // focusedBorder: OutlineInputBorder(
                  //     borderSide: BorderSide(color: Colors.orange)),
                  // errorText:
                  //     _validate ? 'Please enter your message' : null,
                ),
                // keyboardType: TextInputType.multiline,
              ),
            );
            listOfControllers[field.label].text = newfield.response.toString();
          }
          break;
        case FieldType.NUMBER:
          {
            FormInputFieldNumber newfield = field;
            fieldWidget = SizedBox(
              width: MediaQuery.of(context).size.width * .3,
              height: MediaQuery.of(context).size.height * .08,
              child: TextField(
                controller: listOfControllers[field.label],
                readOnly: true,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.indigo[900],
                ),
                decoration: InputDecoration(
                  labelText: newfield.label,
                  labelStyle: TextStyle(
                      fontSize: 13,
                      color: Colors.blueGrey[500],
                      fontWeight: FontWeight.bold,
                      fontFamily: 'RalewayRegular'),
                  enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.grey[300])),
                  focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.orange[300])),
                  // enabledBorder: OutlineInputBorder(
                  //     borderSide: BorderSide(color: Colors.grey)),
                  // focusedBorder: OutlineInputBorder(
                  //     borderSide: BorderSide(color: Colors.orange)),
                  // errorText:
                  //     _validate ? 'Please enter your message' : null,
                ),
                // keyboardType: TextInputType.text,
              ),
            );
            listOfControllers[field.label].text =
                (newfield.response.toString());
          }
          break;
        case FieldType.PHONE:
          {
            FormInputFieldPhone newfield = field;
            fieldWidget = SizedBox(
              width: MediaQuery.of(context).size.width * .3,
              height: MediaQuery.of(context).size.height * .08,
              child: TextField(
                controller: listOfControllers[field.label],
                readOnly: true,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.indigo[900],
                ),
                decoration: InputDecoration(
                  labelText: newfield.label,
                  labelStyle: TextStyle(
                      fontSize: 13,
                      color: Colors.blueGrey[500],
                      fontWeight: FontWeight.bold,
                      fontFamily: 'RalewayRegular'),
                  enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.grey[300])),
                  focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.orange[300])),
                  // enabledBorder: OutlineInputBorder(
                  //     borderSide: BorderSide(color: Colors.grey)),
                  // focusedBorder: OutlineInputBorder(
                  //     borderSide: BorderSide(color: Colors.orange)),
                  // errorText:
                  //     _validate ? 'Please enter your message' : null,
                ),
                //keyboardType: TextInputType.multiline,
              ),
            );
            listOfControllers[field.label].text =
                Utils.isNotNullOrEmpty(newfield.responsePhone)
                    ? "+91 " + newfield.responsePhone
                    : "+91 ";
          }
          break;

        case FieldType.DATETIME:
          {
            FormInputFieldDateTime newfield = field;
            fieldWidget = SizedBox(
              width: MediaQuery.of(context).size.width * .9,
              height: MediaQuery.of(context).size.height * .08,
              child: TextField(
                controller: listOfControllers[field.label],
                readOnly: true,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.indigo[900],
                ),
                decoration: InputDecoration(
                  labelText: newfield.label,
                  labelStyle: TextStyle(
                      fontSize: 13,
                      color: Colors.blueGrey[500],
                      fontWeight: FontWeight.bold,
                      fontFamily: 'RalewayRegular'),
                  enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.grey[300])),
                  focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.orange[300])),
                  // enabledBorder: OutlineInputBorder(
                  //     borderSide: BorderSide(color: Colors.grey)),
                  // focusedBorder: OutlineInputBorder(
                  //     borderSide: BorderSide(color: Colors.orange)),
                  // errorText:
                  //     _validate ? 'Please enter your message' : null,
                ),
                //keyboardType: TextInputType.text,
              ),
            );
            listOfControllers[field.label].text = ((newfield.yearOnly)
                    ? newfield.responseDateTime.year.toString()
                    : DateFormat('dd-MM-yyyy')
                        .format(newfield.responseDateTime)
                        .toString()) +
                ((newfield.isAge)
                    ? " (Age - ${((DateTime.now().difference(newfield.responseDateTime).inDays) / 365).toStringAsFixed(0)} years)"
                    : "");
          }
          break;
        case FieldType.OPTIONS:
          {
            FormInputFieldOptions newfield = field;
            fieldWidget = SizedBox(
              width: MediaQuery.of(context).size.width * .9,
              //  height: MediaQuery.of(context).size.height * .08,
              child: TextField(
                controller: listOfControllers[field.label],
                readOnly: true,
                maxLines: 2,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.indigo[900],
                ),
                decoration: InputDecoration(
                  labelText: newfield.label,
                  labelStyle: TextStyle(
                      fontSize: 13,
                      color: Colors.blueGrey[500],
                      fontWeight: FontWeight.bold,
                      fontFamily: 'RalewayRegular'),
                  enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.grey[300])),
                  focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.orange[300])),
                  // enabledBorder: OutlineInputBorder(
                  //     borderSide: BorderSide(color: Colors.grey)),
                  // focusedBorder: OutlineInputBorder(
                  //     borderSide: BorderSide(color: Colors.orange)),
                  // errorText:
                  //     _validate ? 'Please enter your message' : null,
                ),
                // keyboardType: TextInputType.multiline,
              ),
            );
            // String conds = "";

            // if (newfield.isMultiSelect) {
            //   if (Utils.isNullOrEmpty(newfield.responseValues)) {
            //     conds = "None";
            //   }
            //   for (int i = 0; i < newfield.responseValues.length; i++) {
            //     if (conds != "")
            //       conds = conds + "  &  " + newfield.responseValues[i].value;
            //     else
            //       conds = conds + newfield.responseValues[i].toString();
            //   }
            // } else {
            //   conds = Utils.isNullOrEmpty(newfield.responseValues)
            //       ? "None"
            //       : newfield.responseValues[0].value;
            // }

            String responseVals;
            for (Value val in newfield.responseValues) {
              if (!Utils.isNotNullOrEmpty(responseVals)) responseVals = "";
              responseVals = responseVals +
                  ((responseVals != "")
                      ? (' | ' + val.value.toString())
                      : val.value.toString());
            }

            // print(conds);
            listOfControllers[field.label].text = responseVals;
          }
          break;
        case FieldType.ATTACHMENT:
          {
            FormInputFieldAttachment newfield = field;
            fieldWidget = Container(
              padding: EdgeInsets.fromLTRB(5, 0, 0, 5),
              decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey[300], width: 1.5)),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  SizedBox(
                    width: MediaQuery.of(context).size.width * .9,
                    height: MediaQuery.of(context).size.height * .08,
                    child: TextField(
                      controller: listOfControllers[field.label],
                      readOnly: true,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.indigo[900],
                      ),
                      textAlign: TextAlign.start,
                      decoration: InputDecoration(
                        labelText: newfield.label,
                        labelStyle: TextStyle(
                            fontSize: 13,
                            color: Colors.blueGrey[500],
                            fontWeight: FontWeight.bold,
                            fontFamily: 'RalewayRegular'),
                        enabledBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: Colors.grey[300])),
                        focusedBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: Colors.orange[300])),
                      ),
                      //  keyboardType: TextInputType.multiline,
                    ),
                  ),
                  (newfield.responseFilePaths.length > 0)
                      ? Wrap(
                          children: newfield.responseFilePaths
                              .map((item) => GestureDetector(
                                    onTap: () {
                                      Utils.showImagePopUp(
                                          context,
                                          Image.network(
                                            item,
                                            loadingBuilder:
                                                (BuildContext context,
                                                    Widget child,
                                                    ImageChunkEvent
                                                        loadingProgress) {
                                              if (loadingProgress == null)
                                                return child;
                                              return Center(
                                                child:
                                                    CircularProgressIndicator(
                                                  value: loadingProgress
                                                              .expectedTotalBytes !=
                                                          null
                                                      ? loadingProgress
                                                              .cumulativeBytesLoaded /
                                                          loadingProgress
                                                              .expectedTotalBytes
                                                      : null,
                                                ),
                                              );
                                            },
                                          ));
                                    },
                                    child: Container(
                                        padding: EdgeInsets.all(2),
                                        margin: EdgeInsets.all(2),
                                        width:
                                            MediaQuery.of(context).size.width *
                                                .37,
                                        height:
                                            MediaQuery.of(context).size.width *
                                                .4,
                                        child: Image.network(
                                          item,
                                          loadingBuilder: (BuildContext context,
                                              Widget child,
                                              ImageChunkEvent loadingProgress) {
                                            if (loadingProgress == null) {
                                              return child;
                                            }
                                            return Center(
                                              child: CircularProgressIndicator(
                                                value: loadingProgress
                                                            .expectedTotalBytes !=
                                                        null
                                                    ? loadingProgress
                                                            .cumulativeBytesLoaded /
                                                        loadingProgress
                                                            .expectedTotalBytes
                                                    : null,
                                              ),
                                            );
                                          },
                                        )),
                                  ))
                              .toList()
                              .cast<Widget>(),
                        )
                      : SizedBox(),
                ],
              ),
            );
            // String conds = "";

            // if (newfield.isMultiSelect) {
            //   if (Utils.isNullOrEmpty(newfield.responseValues)) {
            //     conds = "None";
            //   } else {
            //     for (int i = 0; i < newfield.responseValues.length; i++) {
            //       if (conds != "")
            //         conds = conds + "  &  " + newfield.responseValues[i].value;
            //       else
            //         conds = conds + newfield.responseValues[i].value;
            //     }
            //   }
            // } else {
            //   conds = Utils.isNullOrEmpty(newfield.responseValues)
            //       ? "None"
            //       : newfield.responseValues[0].value;
            // }
            // listOfControllers[field.label].text = conds;
            listOfControllers[field.label].text = " ";
            break;
          }
        case FieldType.OPTIONS_ATTACHMENTS:
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

            fieldWidget = Container(
              padding: EdgeInsets.fromLTRB(5, 0, 0, 5),
              decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey[200], width: 1.5)),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  SizedBox(
                    width: MediaQuery.of(context).size.width * .9,
                    height: MediaQuery.of(context).size.height * .08,
                    child: TextField(
                      controller: listOfControllers[field.label],
                      readOnly: true,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.indigo[900],
                      ),
                      textAlign: TextAlign.start,
                      decoration: InputDecoration(
                        labelText: newfield.label,
                        labelStyle: TextStyle(
                            fontSize: 13,
                            color: Colors.blueGrey[500],
                            fontWeight: FontWeight.bold,
                            fontFamily: 'RalewayRegular'),
                        enabledBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: Colors.grey[300])),
                        focusedBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: Colors.orange[300])),
                        // enabledBorder: OutlineInputBorder(
                        //     borderSide: BorderSide(color: Colors.grey)),
                        // focusedBorder: OutlineInputBorder(
                        //     borderSide: BorderSide(color: Colors.orange)),
                        // errorText:
                        //     _validate ? 'Please enter your message' : null,
                      ),
                      //  keyboardType: TextInputType.multiline,
                    ),
                  ),
                  (newfield.responseFilePaths.length > 0)
                      ? Wrap(
                          children: newfield.responseFilePaths
                              .map((item) => GestureDetector(
                                    onTap: () {
                                      Utils.showImagePopUp(
                                          context,
                                          Image.network(
                                            item,
                                            loadingBuilder:
                                                (BuildContext context,
                                                    Widget child,
                                                    ImageChunkEvent
                                                        loadingProgress) {
                                              if (loadingProgress == null)
                                                return child;
                                              return Center(
                                                child:
                                                    CircularProgressIndicator(
                                                  value: loadingProgress
                                                              .expectedTotalBytes !=
                                                          null
                                                      ? loadingProgress
                                                              .cumulativeBytesLoaded /
                                                          loadingProgress
                                                              .expectedTotalBytes
                                                      : null,
                                                ),
                                              );
                                            },
                                          ));
                                    },
                                    child: Container(
                                        padding: EdgeInsets.all(2),
                                        margin: EdgeInsets.all(2),
                                        width:
                                            MediaQuery.of(context).size.width *
                                                .37,
                                        height:
                                            MediaQuery.of(context).size.width *
                                                .4,
                                        child: Image.network(
                                          item,
                                          loadingBuilder: (BuildContext context,
                                              Widget child,
                                              ImageChunkEvent loadingProgress) {
                                            if (loadingProgress == null) {
                                              return child;
                                            }
                                            return Center(
                                              child: CircularProgressIndicator(
                                                value: loadingProgress
                                                            .expectedTotalBytes !=
                                                        null
                                                    ? loadingProgress
                                                            .cumulativeBytesLoaded /
                                                        loadingProgress
                                                            .expectedTotalBytes
                                                    : null,
                                              ),
                                            );
                                          },
                                        )),
                                  ))
                              .toList()
                              .cast<Widget>(),
                        )
                      : SizedBox(),
                ],
              ),
            );
            String conds = "";

            if (newfield.isMultiSelect) {
              if (Utils.isNullOrEmpty(newfield.responseValues)) {
                conds = "None";
              } else {
                for (int i = 0; i < newfield.responseValues.length; i++) {
                  if (conds != "")
                    conds = conds + "  &  " + newfield.responseValues[i].value;
                  else
                    conds = conds + newfield.responseValues[i].value;
                }
              }
            } else {
              conds = Utils.isNullOrEmpty(newfield.responseValues)
                  ? "None"
                  : newfield.responseValues[0].value;
            }
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
            child: fieldWidget),
      ]);
    }

    return fieldsContainer;
  }

  // Widget _buildItem(BookingApplication ba) {
  //   return Column(
  //     children: <Widget>[
  //       Expanded(
  //         child:
  //       ),
  //     ],
  //   );
  // }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (initCompleted) {
      notesController.text = widget.bookingApplication.notes;
      return MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData.light().copyWith(),
        home: WillPopScope(
          child: Scaffold(
            appBar: AppBar(
              title: Text(
                "Applicant Details",
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
            body: SingleChildScrollView(
              physics: ScrollPhysics(),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Column(children: [
                    Container(
                      padding: EdgeInsets.all(15),
                      child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Container(
                              padding: EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                  color: (widget.bookingApplication.status ==
                                          ApplicationStatus.NEW)
                                      ? Colors.blue
                                      : (widget.bookingApplication.status ==
                                              ApplicationStatus.ONHOLD
                                          ? Colors.yellow[700]
                                          : (widget.bookingApplication.status ==
                                                  ApplicationStatus.REJECTED
                                              ? Colors.red
                                              : (widget.bookingApplication
                                                          .status ==
                                                      ApplicationStatus.APPROVED
                                                  ? Colors.green[400]
                                                  : Colors.blueGrey))),
                                  shape: BoxShape.rectangle,
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(5.0))),
                              child: Text(
                                EnumToString.convertToString(
                                    widget.bookingApplication.status),
                                style: TextStyle(
                                    fontSize: 10,
                                    letterSpacing: 1,
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontFamily: 'RalewayRegular'),
                              ),
                            ),
                          ]),
                    ),
                    ListView.builder(
                      padding: EdgeInsets.fromLTRB(15, 0, 15, 8),
                      shrinkWrap: true,
                      //scrollDirection: Axis.vertical,
                      physics: new NeverScrollableScrollPhysics(),
                      itemBuilder: (BuildContext context, int index) {
                        return Container(
                          padding: EdgeInsets.fromLTRB(5, 5, 5, 0),
                          //  height: MediaQuery.of(context).size.height * .3,
                          child: buildChildItem(widget
                              .bookingApplication.responseForm
                              .getFormFields()[index]),
                        );
                      },
                      itemCount: widget.bookingApplication.responseForm
                          .getFormFields()
                          .length,
                    ),
                  ]),
                  Container(
                    width: MediaQuery.of(context).size.width * .97,
                    padding: EdgeInsets.fromLTRB(8, 0, 8, 15),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SizedBox(
                          width: MediaQuery.of(context).size.width * .21,
                          child: RaisedButton(
                              elevation: 8,
                              color: (widget.bookingApplication.status !=
                                          ApplicationStatus.COMPLETED &&
                                      widget.bookingApplication.status !=
                                          ApplicationStatus.CANCELLED)
                                  ? Colors.purple
                                  : disabledColor,
                              onPressed: () {
                                if (widget.bookingApplication.status !=
                                        ApplicationStatus.COMPLETED &&
                                    widget.bookingApplication.status !=
                                        ApplicationStatus.CANCELLED) {
                                  showApplicationStatusDialog(
                                          context,
                                          "Complete Application",
                                          'Are you sure you want to mark this application as Completed?',
                                          completeDialogMsg,
                                          'Complete')
                                      .then((remarks) {
                                    //Update application status change on server.
                                    if (Utils.isNotNullOrEmpty(remarks)) {
                                      widget.bookingApplication
                                          .notesOnCompletion = remarks;
                                      _gs
                                          .getApplicationService()
                                          .updateApplicationStatus(
                                              widget.bookingApplication.id,
                                              ApplicationStatus.COMPLETED,
                                              remarks,
                                              metaEntity,
                                              widget.bookingApplication
                                                  .preferredSlotTiming)
                                          .then((value) {
                                        if (value) {
                                          setState(() {
                                            widget.bookingApplication.status =
                                                ApplicationStatus.COMPLETED;
                                          });
                                          Utils.showMyFlushbar(
                                              context,
                                              Icons.check,
                                              Duration(seconds: 2),
                                              "Application is marked completed!!",
                                              "",
                                              Colors.purple[400],
                                              Colors.white);
                                        } else {
                                          print("Could not update application");
                                          Utils.showMyFlushbar(
                                              context,
                                              Icons.error,
                                              Duration(seconds: 4),
                                              "Oops! Application could not be marked Completed!!",
                                              "Try again later.");
                                        }
                                      }).catchError((error) {
                                        Utils.handleUpdateApplicationStatus(
                                            error, context);
                                      });
                                    }
                                  });
                                }
                              },
                              child: Icon(
                                Icons.thumb_up,
                                color: Colors.white,
                              )),
                        ),
                        SizedBox(
                          width: MediaQuery.of(context).size.width * .21,
                          child: MaterialButton(
                              elevation: 8,
                              color: (widget.bookingApplication.status !=
                                          ApplicationStatus.COMPLETED &&
                                      widget.bookingApplication.status !=
                                          ApplicationStatus.CANCELLED)
                                  ? Colors.green[400]
                                  : disabledColor,
                              onPressed: () {
                                if (widget.bookingApplication.status !=
                                        ApplicationStatus.COMPLETED &&
                                    widget.bookingApplication.status !=
                                        ApplicationStatus.CANCELLED) {
                                  showApplicationStatusDialog(
                                          context,
                                          "Approve Application",
                                          'Do you want to proceed with the Approval?',
                                          approveDialogMsg,
                                          'Approve')
                                      .then((remarks) {
                                    //Update application status change on server.
                                    if (Utils.isNotNullOrEmpty(remarks)) {
                                      widget.bookingApplication
                                          .notesOnApproval = remarks;
                                      _gs
                                          .getApplicationService()
                                          .updateApplicationStatus(
                                              widget.bookingApplication.id,
                                              ApplicationStatus.APPROVED,
                                              remarks,
                                              metaEntity,
                                              widget.bookingApplication
                                                  .preferredSlotTiming)
                                          .then((value) {
                                        if (value) {
                                          setState(() {
                                            widget.bookingApplication.status =
                                                ApplicationStatus.APPROVED;
                                          });
                                          Utils.showMyFlushbar(
                                              context,
                                              Icons.check,
                                              Duration(seconds: 2),
                                              "Application is Approved!!",
                                              "",
                                              successGreenSnackBar,
                                              Colors.white);
                                        } else {
                                          print(
                                              "Could not update application status");
                                          Utils.showMyFlushbar(
                                              context,
                                              Icons.error,
                                              Duration(seconds: 4),
                                              "Oops! Application could not be Approved!!",
                                              tryAgainToBook);
                                        }
                                      }).catchError((error) {
                                        Utils.handleUpdateApplicationStatus(
                                            error, context);
                                      });
                                    }
                                  });
                                }
//Update application status change on server.
                              },
                              child: Icon(
                                Icons.check_circle,
                                color: Colors.white,
                              )),
                        ),
                        SizedBox(
                          width: MediaQuery.of(context).size.width * .21,
                          child: RaisedButton(
                            color: (widget.bookingApplication.status !=
                                        ApplicationStatus.COMPLETED &&
                                    widget.bookingApplication.status !=
                                        ApplicationStatus.CANCELLED)
                                ? Colors.yellow[700]
                                : disabledColor,
                            onPressed: () {
                              if (widget.bookingApplication.status !=
                                      ApplicationStatus.COMPLETED &&
                                  widget.bookingApplication.status !=
                                      ApplicationStatus.CANCELLED) {
                                showApplicationStatusDialog(
                                        context,
                                        "On-Hold Application",
                                        'Are you sure you want to put this Application On-Hold?',
                                        onHoldDialogMsg,
                                        'On-Hold')
                                    .then((remarks) {
                                  //Update application status change on server.
                                  if (Utils.isNotNullOrEmpty(remarks)) {
                                    widget.bookingApplication
                                        .notesOnPuttingOnHold = remarks;

                                    _gs
                                        .getApplicationService()
                                        .updateApplicationStatus(
                                            widget.bookingApplication.id,
                                            ApplicationStatus.ONHOLD,
                                            remarks,
                                            metaEntity,
                                            widget.bookingApplication
                                                .preferredSlotTiming)
                                        .then((value) {
                                      if (value) {
                                        setState(() {
                                          widget.bookingApplication.status =
                                              ApplicationStatus.ONHOLD;
                                        });
                                        Utils.showMyFlushbar(
                                            context,
                                            Icons.check,
                                            Duration(seconds: 2),
                                            "Application is put on-hold!!",
                                            "",
                                            Colors.yellow[700],
                                            Colors.white);
                                      } else {
                                        print(
                                            "Could not update application status");
                                        Utils.showMyFlushbar(
                                            context,
                                            Icons.error,
                                            Duration(seconds: 4),
                                            "Oops! Application could not be put On-Hold!!",
                                            tryAgainLater);
                                      }
                                    }).catchError((error) {
                                      Utils.handleUpdateApplicationStatus(
                                          error, context);
                                    });
                                  }
                                });
                              }
                            },
                            child: Icon(
                              Icons.pan_tool_rounded,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        SizedBox(
                          width: MediaQuery.of(context).size.width * .21,
                          child: RaisedButton(
                            color: (widget.bookingApplication.status !=
                                        ApplicationStatus.COMPLETED &&
                                    widget.bookingApplication.status !=
                                        ApplicationStatus.CANCELLED)
                                ? Colors.red
                                : disabledColor,
                            onPressed: () {
                              if (widget.bookingApplication.status !=
                                      ApplicationStatus.COMPLETED &&
                                  widget.bookingApplication.status !=
                                      ApplicationStatus.CANCELLED) {
                                showApplicationStatusDialog(
                                        context,
                                        "Confirm Rejection",
                                        'Are you sure you want to Reject this Application?',
                                        rejectDialogMsg,
                                        'Reject')
                                    .then((remarks) {
                                  //Update application status change on server.
                                  if (Utils.isNotNullOrEmpty(remarks)) {
                                    widget.bookingApplication.notesOnRejection =
                                        remarks;
                                    _gs
                                        .getApplicationService()
                                        .updateApplicationStatus(
                                            widget.bookingApplication.id,
                                            ApplicationStatus.REJECTED,
                                            remarks,
                                            metaEntity,
                                            widget.bookingApplication
                                                .preferredSlotTiming)
                                        .then((value) {
                                      if (value) {
                                        setState(() {
                                          widget.bookingApplication.status =
                                              ApplicationStatus.REJECTED;
                                        });
                                        Utils.showMyFlushbar(
                                            context,
                                            Icons.check,
                                            Duration(seconds: 2),
                                            "Application is rejected!!",
                                            "",
                                            Colors.red,
                                            Colors.white);
                                      } else {
                                        print(
                                            "Could not update application status");
                                        Utils.showMyFlushbar(
                                            context,
                                            Icons.error,
                                            Duration(seconds: 4),
                                            "Oops! Application could not be rejected!!",
                                            "");
                                      }
                                    }).catchError((error) {
                                      Utils.handleUpdateApplicationStatus(
                                          error, context);
                                    });
                                  }
                                });
                              }
                            },
                            child: Icon(
                              Icons.cancel_rounded,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
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
              titleTxt: "Applicant Details",
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
