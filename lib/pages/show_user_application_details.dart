import 'package:LESSs/constants.dart';
import 'package:LESSs/pages/token_alert.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:enum_to_string/enum_to_string.dart';
import 'package:flutter/material.dart';
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
import '../services/qr_code_user_application.dart';
import '../style.dart';
import '../userHomePage.dart';
import '../utils.dart';
import '../widget/appbar.dart';
import '../widget/page_animation.dart';
import '../widget/widgets.dart';

class ShowUserApplicationDetails extends StatefulWidget {
  final BookingApplication bookingApplication;
  final dynamic backRoute;

  ShowUserApplicationDetails({
    Key? key,
    required this.bookingApplication,
    required this.backRoute,
  }) : super(key: key);
  @override
  _ShowUserApplicationDetailsState createState() =>
      _ShowUserApplicationDetailsState();
}

class _ShowUserApplicationDetailsState
    extends State<ShowUserApplicationDetails> {
  bool initCompleted = false;
  GlobalState? _gs;
  List<BookingApplication>? list;
  // TextEditingController notesController = new TextEditingController();
  MetaEntity? metaEntity;
  bool isEnabled = true;
  bool showLoading = false;
  @override
  void initState() {
    super.initState();
    getGlobalState().whenComplete(() {
      //getListOfData();
      if (this.mounted) {
        // if (widget.isAdmin) {
        //   _gs.getEntity(widget.bookingApplication.entityId).then((value) {
        //     if (value != null) {
        //       metaEntity = value.item1.getMetaEntity();
        //     }
        //     setState(() {
        //       initCompleted = true;
        //     });
        //   });
        // } else {
        setState(() {
          initCompleted = true;
        });
        //}
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

  List<Value> idProofTypesStrList = [];
  List<Item> idProofTypes = [];
  List<Value> medConditionsStrList = [];
  List<Item> medConditions = [];
  Map<String?, TextEditingController> listOfControllers =
      new Map<String?, TextEditingController>();

  //File _image; // Used only if you need a single picture
  // String _downloadUrl;
  BookingForm? bookingForm;
  late List<Field?> fields;

  FormInputFieldText? nameInput;
  FormInputFieldDateTime? dobInput;
  FormInputFieldText? primaryPhone;
  FormInputFieldText? alternatePhone;
  String? _idProofType;
  FormInputFieldOptionsWithAttachments? idProofField;
  FormInputFieldOptions? healthDetailsInput;
  FormInputFieldText? healthDetailsDesc;
  FormInputFieldText? latInput;
  FormInputFieldText? lonInput;
  FormInputFieldText? addressInput;
  FormInputFieldText? addresslandmark;
  FormInputFieldText? addressLocality;
  FormInputFieldText? addressCity;
  FormInputFieldText? addressState;
  FormInputFieldText? addressCountry;
  FormInputFieldText? notesInput;
  FormInputFieldText? addressPin;

  initBookingForm() {
    fields = [];
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
    nameInput!.response = "SMITA Agarwal";

    dobInput = FormInputFieldDateTime(
      "Date of Birth",
      true,
      "Please select your Date of Birth",
    );
    dobInput!.responseDateTime =
        DateTime.now().subtract(Duration(days: 365 * 30));

    primaryPhone = FormInputFieldText(
        "Primary Contact Number", true, "Primary Contact Number", 10);
    primaryPhone!.response = "9611009823";

    alternatePhone = FormInputFieldText(
        "Alternate Contact Number", false, "Alternate Contact Number", 10);
    alternatePhone!.response = "9611005523";

    idProofField = FormInputFieldOptionsWithAttachments("Id Proof", true,
        "Please upload Government Id proof", idProofTypesStrList, false);
    idProofField!.responseFilePaths = [];
    idProofField!.responseValues = [];
    idProofField!.responseValues!.add(Value("DL"));

    healthDetailsInput = FormInputFieldOptions(
        "Medical Conditions",
        true,
        "Please select all known medical conditions you have",
        medConditionsStrList,
        true);
    healthDetailsInput!.responseValues = [];
    healthDetailsInput!.responseValues!.add(Value("liver"));
    healthDetailsInput!.responseValues!.add(Value("heart"));

    healthDetailsDesc = FormInputFieldText(
        "Decription of medical conditions (optional)",
        false,
        "Decription of medical conditions (optional)",
        200);
    healthDetailsDesc!.response = "Migraine";

    latInput = FormInputFieldText(
        "Current Location Latitude", false, "Current Location Latitude", 20);
    latInput!.response = "HOMe0023";

    lonInput = FormInputFieldText(
        "Current Location Longitude", false, "Current Location Longitude", 20);
    lonInput!.response = "Lon";

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
    Widget fieldWidget;
    Widget fieldsContainer = Container();
    if (field != null) {
      switch (field.type) {
        case FieldType.TEXT:
          {
            FormInputFieldText newfield = field as FormInputFieldText;
            fieldWidget = SizedBox(
              width: MediaQuery.of(context).size.width * .3,
              //  height: MediaQuery.of(context).size.height * .08,
              child: TextField(
                controller: listOfControllers[field.label],
                readOnly: true,
                maxLines: null,
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
                      borderSide: BorderSide(color: Colors.grey)),
                  focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.orange)),
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
            listOfControllers[field.label]!.text =
                Utils.isStrNullOrEmpty(newfield.response)
                    ? 'No Data'
                    : newfield.response.toString();
          }
          break;
        case FieldType.NUMBER:
          {
            FormInputFieldNumber newfield = field as FormInputFieldNumber;
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
                      borderSide: BorderSide(color: Colors.grey)),
                  focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.orange)),
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
            listOfControllers[field.label]!.text =
                (newfield.response.toString());
          }
          break;
        case FieldType.INT:
          {
            FormInputFieldInt newfield = field as FormInputFieldInt;
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
                      borderSide: BorderSide(color: Colors.grey)),
                  focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.orange)),
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
            listOfControllers[field.label]!.text =
                (newfield.response.toString());
          }
          break;
        case FieldType.PHONE:
          {
            FormInputFieldPhone newfield = field as FormInputFieldPhone;
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
                      borderSide: BorderSide(color: Colors.grey)),
                  focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.orange)),
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
            listOfControllers[field.label]!.text =
                Utils.isNotNullOrEmpty(newfield.responsePhone)
                    ? "+91 ${newfield.responsePhone.toString()}"
                    : "";
          }
          break;

        case FieldType.DATETIME:
          {
            FormInputFieldDateTime newfield = field as FormInputFieldDateTime;
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
                  labelText: newfield.isAge! ? "Age" : newfield.label,
                  labelStyle: TextStyle(
                      fontSize: 13,
                      color: Colors.blueGrey[500],
                      fontWeight: FontWeight.bold,
                      fontFamily: 'RalewayRegular'),
                  enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.grey)),
                  focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.orange)),
                ),
              ),
            );
            listOfControllers[field.label]!.text = newfield.yearOnly!
                ? newfield.responseDateTime!.year.toString()
                : newfield.responseDateTime.toString();
          }
          break;
        case FieldType.OPTIONS:
          {
            FormInputFieldOptions newfield = field as FormInputFieldOptions;
            fieldWidget = Container(
              width: MediaQuery.of(context).size.width * .9,
              // height: MediaQuery.of(context).size.height * .08,
              child: TextField(
                controller: listOfControllers[field.label],
                readOnly: true,
                maxLines: null,
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
                      borderSide: BorderSide(color: Colors.grey)),
                  focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.orange)),
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
            String conds = "";

            if (newfield.isMultiSelect!) {
              if (Utils.isNullOrEmpty(newfield.responseValues)) {
                conds = "None";
              }
              for (int i = 0; i < newfield.responseValues!.length; i++) {
                if (conds != "")
                  conds = conds + "  |  " + newfield.responseValues![i].value;
                else
                  conds = conds + newfield.responseValues![i].value.toString();
              }
            } else {
              if (Utils.isNullOrEmpty(newfield.responseValues)) {
                conds = "None";
              } else {
                conds = newfield.responseValues![0].value.toString();
              }
            }

            listOfControllers[field.label]!.text = conds;
          }
          break;
        case FieldType.ATTACHMENT:
          {
            FormInputFieldAttachment newfield =
                field as FormInputFieldAttachment;

            fieldWidget = Container(
              padding: EdgeInsets.fromLTRB(5, 0, 0, 5),
              // decoration: BoxDecoration(
              //     border: Border.all(color: Colors.indigo[800], width: 1.5)),
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
                            borderSide: BorderSide(color: Colors.grey)),
                        focusedBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: Colors.orange)),
                      ),
                    ),
                  ),
                  (newfield.responseFilePaths!.length > 0)
                      ? Wrap(
                          children: newfield.responseFilePaths!
                              .map((item) => GestureDetector(
                                    onTap: () {
                                      Image? image;
                                      try {
                                        image = Image.network(
                                          item,
                                          loadingBuilder: (BuildContext context,
                                              Widget child,
                                              ImageChunkEvent?
                                                  loadingProgress) {
                                            if (loadingProgress == null)
                                              return child;
                                            return Center(
                                              child: CircularProgressIndicator(
                                                value: loadingProgress
                                                            .expectedTotalBytes !=
                                                        null
                                                    ? loadingProgress
                                                            .cumulativeBytesLoaded /
                                                        loadingProgress
                                                            .expectedTotalBytes!
                                                    : null,
                                              ),
                                            );
                                          },
                                        );
                                        print(image);
                                      } catch (e) {
                                        print(
                                            "ERROR caught in Image from network");
                                      }
                                      Utils.showImagePopUp(context, image);
                                    },
                                    child: Container(
                                        padding: EdgeInsets.all(2),
                                        margin: EdgeInsets.all(2),
                                        // decoration: BoxDecoration(
                                        //     border:
                                        //         Border.all(color: Colors.blueGrey[800])),
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
                                              ImageChunkEvent?
                                                  loadingProgress) {
                                            if (loadingProgress == null)
                                              return child;
                                            return Center(
                                              child: CircularProgressIndicator(
                                                value: loadingProgress
                                                            .expectedTotalBytes !=
                                                        null
                                                    ? loadingProgress
                                                            .cumulativeBytesLoaded /
                                                        loadingProgress
                                                            .expectedTotalBytes!
                                                    : null,
                                              ),
                                            );
                                          },
                                        )),
                                  ))
                              .toList()
                              .cast<Widget>(),
                        )
                      : SizedBox(
                          child: Text(
                            "No attachments found.",
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.blueGrey[600],
                            ),
                          ),
                        ),
                ],
              ),
            );
            //  String conds = "";

            // if (Utils.isNullOrEmpty(newfield.responseValues)) {
            //   conds = "None";
            // } else {
            //   if (newfield.isMultiSelect) {
            //     for (int i = 0; i < newfield.responseValues.length; i++) {
            //       if (conds != "")
            //         conds = conds + "  &  " + newfield.responseValues[i].value;
            //       else
            //         conds = conds + newfield.responseValues[i].value;
            //     }
            //   } else {
            //     if (newfield.responseValues.length > 0)
            //       conds = newfield.responseValues[0].value;
            //   }
            // }
            // listOfControllers[field.label].text = conds;
          }
          break;
        case FieldType.OPTIONS_ATTACHMENTS:
          {
            FormInputFieldOptionsWithAttachments newfield =
                field as FormInputFieldOptionsWithAttachments;

            fieldWidget = Container(
              padding: EdgeInsets.fromLTRB(5, 0, 0, 5),
              // decoration: BoxDecoration(
              //     border: Border.all(color: Colors.indigo[800], width: 1.5)),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  SizedBox(
                    width: MediaQuery.of(context).size.width * .9,
                    height: MediaQuery.of(context).size.height * .08,
                    child: TextField(
                      controller: listOfControllers[field.label],
                      readOnly: true,
                      maxLines: null,
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
                            borderSide: BorderSide(color: Colors.grey)),
                        focusedBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: Colors.orange)),
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
                  (newfield.responseFilePaths!.length > 0)
                      ? Wrap(
                          children: newfield.responseFilePaths!
                              .map((item) => GestureDetector(
                                    onTap: () {
                                      Image? image;
                                      try {
                                        image = Image.network(
                                          item,
                                          loadingBuilder: (BuildContext context,
                                              Widget child,
                                              ImageChunkEvent?
                                                  loadingProgress) {
                                            if (loadingProgress == null)
                                              return child;
                                            return Center(
                                              child: CircularProgressIndicator(
                                                value: loadingProgress
                                                            .expectedTotalBytes !=
                                                        null
                                                    ? loadingProgress
                                                            .cumulativeBytesLoaded /
                                                        loadingProgress
                                                            .expectedTotalBytes!
                                                    : null,
                                              ),
                                            );
                                          },
                                        );
                                        print(image);
                                      } catch (e) {
                                        print(
                                            "ERROR caught in Image from network");
                                      }
                                      Utils.showImagePopUp(context, image);
                                    },
                                    child: Container(
                                        padding: EdgeInsets.all(2),
                                        margin: EdgeInsets.all(2),
                                        // decoration: BoxDecoration(
                                        //     border:
                                        //         Border.all(color: Colors.blueGrey[800])),
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
                                              ImageChunkEvent?
                                                  loadingProgress) {
                                            if (loadingProgress == null)
                                              return child;
                                            return Center(
                                              child: CircularProgressIndicator(
                                                value: loadingProgress
                                                            .expectedTotalBytes !=
                                                        null
                                                    ? loadingProgress
                                                            .cumulativeBytesLoaded /
                                                        loadingProgress
                                                            .expectedTotalBytes!
                                                    : null,
                                              ),
                                            );
                                          },
                                        )),
                                  ))
                              .toList()
                              .cast<Widget>(),
                        )
                      : SizedBox(
                          child: Text("No attachments found."),
                        ),
                ],
              ),
            );
            String? conds = "";

            if (Utils.isNullOrEmpty(newfield.responseValues)) {
              conds = "None";
            } else {
              if (newfield.isMultiSelect!) {
                for (int i = 0; i < newfield.responseValues!.length; i++) {
                  if (conds != "")
                    conds =
                        conds! + "  &  " + newfield.responseValues![i].value;
                  else
                    conds = conds! + newfield.responseValues![i].value;
                }
              } else {
                if (newfield.responseValues!.length > 0)
                  conds = newfield.responseValues![0].value;
              }
            }
            listOfControllers[field.label]!.text = conds!;
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

  Widget _buildItem(BookingApplication ba) {
    return Container(
      padding: EdgeInsets.fromLTRB(8, 8, 8, 0),
      margin: EdgeInsets.all(8),
      child: Card(
        elevation: 8,
        child: Container(
          width: MediaQuery.of(context).size.width,
          //height: MediaQuery.of(context).size.height * .82,
          child: Column(
            children: <Widget>[
              Container(
                padding: EdgeInsets.all(0),
                child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // AutoSizeText(
                      //   "Status : ",
                      //   minFontSize: 10,
                      //   maxFontSize: 12,
                      //   maxLines: 1,
                      //   overflow: TextOverflow.clip,
                      //   style: TextStyle(
                      //       color: Colors.blueGrey[700],
                      //       fontFamily: 'RalewayRegular'),
                      // ),
                      Container(
                        padding: EdgeInsets.all(8),
                        margin: EdgeInsets.all(0),
                        // height: MediaQuery.of(context).size.width * .3,
                        // width: MediaQuery.of(context).size.width * .3,
                        child: IconButton(
                            padding: EdgeInsets.fromLTRB(0, 0, 0, 0),
                            alignment: Alignment.topLeft,
                            highlightColor: Colors.orange[300],
                            icon: ImageIcon(
                              AssetImage('assets/qrcode.png'),
                              size: 30,
                              color: primaryIcon,
                            ),
                            onPressed: () {
                              print(ba.entityId);
                              Navigator.of(context).push(
                                  PageAnimation.createRoute(
                                      GenerateQrUserApplication(
                                baId: ba.id,
                                entityName: ba.entityName,
                                backRoute: "UserAppsList",
                                uniqueTokenIdentifier: null,
                              )));
                            }),
                      ),

                      Container(
                        padding: EdgeInsets.all(4),
                        margin: EdgeInsets.all(0),
                        decoration: BoxDecoration(
                            color: (ba.status == ApplicationStatus.NEW)
                                ? Colors.blue
                                : (ba.status == ApplicationStatus.ONHOLD
                                    ? Colors.yellow[700]
                                    : (ba.status == ApplicationStatus.REJECTED
                                        ? Colors.red
                                        : (ba.status ==
                                                ApplicationStatus.APPROVED
                                            ? Colors.greenAccent[700]
                                            : (ba.status ==
                                                    ApplicationStatus.COMPLETED
                                                ? Colors.purple
                                                : Colors.blueGrey[400])))),
                            shape: BoxShape.rectangle,
                            borderRadius: BorderRadius.only(
                                bottomLeft: Radius.circular(5.0))),
                        child: AutoSizeText(
                            EnumToString.convertToString(ba.status),
                            textAlign: TextAlign.center,
                            minFontSize: 8,
                            maxFontSize: 10,
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1,
                                color: Colors.white,
                                fontFamily: 'RalewayRegular')),
                      ),
                    ]),
              ),
              Expanded(
                child: ListView.builder(
                  padding: EdgeInsets.fromLTRB(
                      MediaQuery.of(context).size.width * .026,
                      0,
                      MediaQuery.of(context).size.width * .026,
                      MediaQuery.of(context).size.width * .026),
                  shrinkWrap: true,
                  //scrollDirection: Axis.vertical,
                  itemBuilder: (BuildContext context, int index) {
                    return Container(
                      padding: EdgeInsets.fromLTRB(5, 5, 5, 0),
                      //  height: MediaQuery.of(context).size.height * .3,
                      child: buildChildItem(
                          ba.responseForm!.getFormFields()[index]),
                    );
                  },
                  itemCount: ba.responseForm!.getFormFields().length,
                ),
              ),
              Container(
                // width: MediaQuery.of(context).size.width * .8,
                margin: EdgeInsets.all(9),
                child: MaterialButton(
                    elevation: 8,
                    color: (ba.status == ApplicationStatus.CANCELLED ||
                            ba.status == ApplicationStatus.REJECTED)
                        ? disabledColor
                        : Colors.yellow[800],
                    onPressed: () {
                      if (widget.bookingApplication.status ==
                              ApplicationStatus.CANCELLED ||
                          ba.status == ApplicationStatus.REJECTED) {
                        return;
                      }
                      setState(() {
                        showLoading = true;
                      });
                      showApplicationStatusDialog(
                              context,
                              "Cancel Application",
                              'Do you want to Cancel this Application?',
                              cancelDialogMsg,
                              'Cancel Application')
                          .then((remarks) {
                        //Update application status change on server.
                        // if (Utils.isNotNullOrEmpty(remarks)) {
                        if ((remarks![1])) {
                          widget.bookingApplication.notesOnCancellation =
                              (Utils.isNotNullOrEmpty(remarks[0])
                                  ? remarks[0]
                                  : "");
                          _gs!
                              .withDrawApplication(
                                  widget.bookingApplication.id, remarks[0])
                              .then((value) {
                            widget.bookingApplication.notesOnCancellation =
                                remarks[0];

                            if (mounted) {
                              setState(() {
                                showLoading = false;
                                widget.bookingApplication.status =
                                    ApplicationStatus.CANCELLED;
                              });
                            }

                            Utils.showMyFlushbar(
                                context,
                                Icons.check,
                                Duration(seconds: 4),
                                "Application Cancelled!!",
                                "",
                                successGreenSnackBar);
                          });
                        } else {
                          if (mounted) {
                            setState(() {
                              showLoading = false;
                            });
                          }
                        }
                        //   }
                      });
                    },
                    child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "Cancel Application",
                            style: TextStyle(
                              fontSize: 15,
                              color: Colors.white,
                            ),
                          ),
                          SizedBox(
                            width: 2,
                          ),
                          Icon(
                            Icons.block,
                            color: Colors.white,
                          )
                        ])),
              ),
            ],
          ),
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
      // notesController.text = widget.bookingApplication.notes;
      return WillPopScope(
        child: Scaffold(
          appBar: CustomAppBarWithBackButton(
            backRoute:
                (widget.backRoute != null) ? widget.backRoute : UserHomePage(),
            titleTxt: "Application Details",
          ),
          body: Stack(children: [
            Center(
              child: Column(
                children: <Widget>[
                  Expanded(child: _buildItem(widget.bookingApplication)),
                  // Row(
                  //   mainAxisAlignment: MainAxisAlignment.center,
                  //   children: [
                  //     // if (!widget.isAdmin)
                  //     if (widget.bookingApplication.status !=
                  //             ApplicationStatus.CANCELLED &&
                  //         widget.bookingApplication.status !=
                  //             ApplicationStatus.REJECTED &&
                  //         widget.bookingApplication.status !=
                  //             ApplicationStatus.COMPLETED)
                  //       Container(
                  //         width: MediaQuery.of(context).size.width * .9,
                  //         margin: EdgeInsets.only(bottom: 15),
                  //         child: MaterialButton(
                  //             elevation: 8,
                  //             color: Colors.yellow[800],
                  //             onPressed: () {
                  //               showApplicationStatusDialog(
                  //                       context,
                  //                       "Cancel Application",
                  //                       'Do you want to Cancel this Application?',
                  //                       cancelDialogMsg,
                  //                       'Cancel Application')
                  //                   .then((remarks) {
                  //                 //Update application status change on server.
                  //                 if (Utils.isNotNullOrEmpty(remarks)) {
                  //                   _gs
                  //                       .getApplicationService()
                  //                       .withDrawApplication(
                  //                           widget.bookingApplication.id,
                  //                           remarks)
                  //                       .then((value) {
                  //                     widget.bookingApplication
                  //                         .notesOnCancellation = remarks;
                  //                     setState(() {
                  //                       widget.bookingApplication.status =
                  //                           ApplicationStatus.CANCELLED;
                  //                     });

                  //                     Utils.showMyFlushbar(
                  //                         context,
                  //                         Icons.check,
                  //                         Duration(seconds: 4),
                  //                         "Application Cancelled!!",
                  //                         "",
                  //                         successGreenSnackBar);
                  //                   });
                  //                 }
                  //               });
                  //             },
                  //             child: Row(
                  //                 mainAxisAlignment: MainAxisAlignment.center,
                  //                 children: [
                  //                   Text(
                  //                     "Cancel Application",
                  //                     style: TextStyle(
                  //                       fontSize: 15,
                  //                       color: Colors.white,
                  //                     ),
                  //                   ),
                  //                   SizedBox(
                  //                     width: 2,
                  //                   ),
                  //                   Icon(
                  //                     Icons.block,
                  //                     color: Colors.white,
                  //                   )
                  //                 ])),
                  //       ),
                  //     // if (widget.isAdmin && metaEntity != null)
                  //     //   Container(
                  //     //     padding: EdgeInsets.all(0),
                  //     //     child: Row(
                  //     //       mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  //     //       children: [
                  //     //         RaisedButton(
                  //     //             elevation: 8,
                  //     //             color: Colors.purple,
                  //     //             onPressed: () {
                  //     //               widget.bookingApplication.notesOnApproval =
                  //     //                   notesController.text;
                  //     //               _gs
                  //     //                   .getApplicationService()
                  //     //                   .updateApplicationStatus(
                  //     //                       widget.bookingApplication.id,
                  //     //                       ApplicationStatus.COMPLETED,
                  //     //                       listOfControllers[widget
                  //     //                               .bookingApplication.id]
                  //     //                           .text,
                  //     //                       metaEntity,
                  //     //                       widget.bookingApplication
                  //     //                           .preferredSlotTiming)
                  //     //                   .then((value) {
                  //     //                 if (value) {
                  //     //                   setState(() {
                  //     //                     widget.bookingApplication.status =
                  //     //                         ApplicationStatus.COMPLETED;
                  //     //                   });
                  //     //                   Utils.showMyFlushbar(
                  //     //                       context,
                  //     //                       Icons.check,
                  //     //                       Duration(seconds: 4),
                  //     //                       "Application Saved!!",
                  //     //                       "",
                  //     //                       successGreenSnackBar);
                  //     //                 } else {
                  //     //                   print(
                  //     //                       "Could not update application status");
                  //     //                   Utils.showMyFlushbar(
                  //     //                       context,
                  //     //                       Icons.info,
                  //     //                       Duration(seconds: 4),
                  //     //                       "Oops! Application could not be saved!!",
                  //     //                       "");
                  //     //                 }
                  //     //               });

                  //     //               print("Complete");
                  //     //             },
                  //     //             child: Row(children: [
                  //     //               // Text(
                  //     //               //   "Complete",
                  //     //               //   style: TextStyle(
                  //     //               //     color: Colors.white,
                  //     //               //   ),
                  //     //               // ),
                  //     //               // SizedBox(
                  //     //               //   width: 2,
                  //     //               // ),
                  //     //               Icon(
                  //     //                 Icons.thumb_up,
                  //     //                 color: Colors.white,
                  //     //               )
                  //     //             ])),
                  //     //         RaisedButton(
                  //     //             elevation: 8,
                  //     //             color: Colors.green[400],
                  //     //             onPressed: () {
                  //     //               widget.bookingApplication.notesOnApproval =
                  //     //                   notesController.text;
                  //     //               _gs
                  //     //                   .getApplicationService()
                  //     //                   .updateApplicationStatus(
                  //     //                       widget.bookingApplication.id,
                  //     //                       ApplicationStatus.APPROVED,
                  //     //                       listOfControllers[widget
                  //     //                               .bookingApplication.id]
                  //     //                           .text,
                  //     //                       metaEntity,
                  //     //                       widget.bookingApplication
                  //     //                           .preferredSlotTiming)
                  //     //                   .then((value) {
                  //     //                 if (value) {
                  //     //                   setState(() {
                  //     //                     widget.bookingApplication.status =
                  //     //                         ApplicationStatus.APPROVED;
                  //     //                   });
                  //     //                   Utils.showMyFlushbar(
                  //     //                       context,
                  //     //                       Icons.check,
                  //     //                       Duration(seconds: 4),
                  //     //                       "Application Saved!!",
                  //     //                       "",
                  //     //                       successGreenSnackBar);
                  //     //                 } else {
                  //     //                   print(
                  //     //                       "Could not update application status");
                  //     //                   Utils.showMyFlushbar(
                  //     //                       context,
                  //     //                       Icons.info,
                  //     //                       Duration(seconds: 4),
                  //     //                       "Oops! Application could not be saved!!",
                  //     //                       "");
                  //     //                 }
                  //     //               });

                  //     //               print("Approved");
                  //     //             },
                  //     //             child: Row(children: [
                  //     //               // Text(
                  //     //               //   "Approve",
                  //     //               //   style: TextStyle(
                  //     //               //     color: Colors.white,
                  //     //               //   ),
                  //     //               // ),
                  //     //               // SizedBox(
                  //     //               //   width: 2,
                  //     //               // ),
                  //     //               Icon(
                  //     //                 Icons.check_circle,
                  //     //                 color: Colors.white,
                  //     //               )
                  //     //             ])),
                  //     //         RaisedButton(
                  //     //           color: Colors.yellow[700],
                  //     //           onPressed: () {
                  //     //             widget.bookingApplication
                  //     //                     .notesOnPuttingOnHold =
                  //     //                 notesController.text;

                  //     //             _gs
                  //     //                 .getApplicationService()
                  //     //                 .updateApplicationStatus(
                  //     //                     widget.bookingApplication.id,
                  //     //                     ApplicationStatus.ONHOLD,
                  //     //                     listOfControllers[
                  //     //                             widget.bookingApplication.id]
                  //     //                         .text,
                  //     //                     metaEntity,
                  //     //                     widget.bookingApplication
                  //     //                         .preferredSlotTiming)
                  //     //                 .then((value) {
                  //     //               if (value) {
                  //     //                 setState(() {
                  //     //                   widget.bookingApplication.status =
                  //     //                       ApplicationStatus.ONHOLD;
                  //     //                 });

                  //     //                 Utils.showMyFlushbar(
                  //     //                     context,
                  //     //                     Icons.check,
                  //     //                     Duration(seconds: 4),
                  //     //                     "Application Saved!!",
                  //     //                     "",
                  //     //                     successGreenSnackBar);
                  //     //               } else {
                  //     //                 print(
                  //     //                     "Could not update application status");
                  //     //                 Utils.showMyFlushbar(
                  //     //                     context,
                  //     //                     Icons.info,
                  //     //                     Duration(seconds: 4),
                  //     //                     "Oops! Application could not be saved!!",
                  //     //                     "");
                  //     //               }
                  //     //             });
                  //     //             print("On-Hold done");
                  //     //           },
                  //     //           child: Row(children: [
                  //     //             // Text(
                  //     //             //   "On-Hold",
                  //     //             //   style: TextStyle(
                  //     //             //     color: Colors.white,
                  //     //             //   ),
                  //     //             //   // style: buttonTextStyle,
                  //     //             // ),
                  //     //             // SizedBox(
                  //     //             //   width: 2,
                  //     //             // ),
                  //     //             Icon(
                  //     //               Icons.pan_tool_rounded,
                  //     //               color: Colors.white,
                  //     //             )
                  //     //           ]),
                  //     //         ),
                  //     //         RaisedButton(
                  //     //           color: Colors.red,
                  //     //           onPressed: () {
                  //     //             widget.bookingApplication.notesOnRejection =
                  //     //                 notesController.text;

                  //     //             _gs
                  //     //                 .getApplicationService()
                  //     //                 .updateApplicationStatus(
                  //     //                     widget.bookingApplication.id,
                  //     //                     ApplicationStatus.REJECTED,
                  //     //                     listOfControllers[
                  //     //                             widget.bookingApplication.id]
                  //     //                         .text,
                  //     //                     metaEntity,
                  //     //                     widget.bookingApplication
                  //     //                         .preferredSlotTiming)
                  //     //                 .then((value) {
                  //     //               if (value) {
                  //     //                 setState(() {
                  //     //                   widget.bookingApplication.status =
                  //     //                       ApplicationStatus.REJECTED;
                  //     //                 });

                  //     //                 Utils.showMyFlushbar(
                  //     //                     context,
                  //     //                     Icons.check,
                  //     //                     Duration(seconds: 4),
                  //     //                     "Application Saved!!",
                  //     //                     "",
                  //     //                     successGreenSnackBar);
                  //     //               } else {
                  //     //                 print(
                  //     //                     "Could not update application status");
                  //     //                 Utils.showMyFlushbar(
                  //     //                     context,
                  //     //                     Icons.info,
                  //     //                     Duration(seconds: 4),
                  //     //                     "Oops! Application could not be saved!!",
                  //     //                     "");
                  //     //               }
                  //     //             });
                  //     //             print("On-Hold done");
                  //     //           },
                  //     //           child: Row(children: [
                  //     //             // Text(
                  //     //             //   "Reject",
                  //     //             //   style: TextStyle(
                  //     //             //     color: Colors.white,
                  //     //             //   ),
                  //     //             // ),
                  //     //             // SizedBox(
                  //     //             //   width: 2,
                  //     //             // ),
                  //     //             Icon(
                  //     //               Icons.cancel_rounded,
                  //     //               color: Colors.white,
                  //     //             )
                  //     //           ]),
                  //     //         ),
                  //     //       ],
                  //     //     ),
                  //     //   )
                  //   ],
                  // )
                ],
              ),
            ),
            if (showLoading)
              Center(
                child: Container(
                  width: MediaQuery.of(context).size.width,
                  height: MediaQuery.of(context).size.height,
                  color: Colors.black.withOpacity(.5),
                  // decoration: BoxDecoration(
                  //   color: Colors.white,
                  //   backgroundBlendMode: BlendMode.saturation,
                  // ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Container(
                        color: Colors.transparent,
                        padding: EdgeInsets.all(12),
                        width: MediaQuery.of(context).size.width * .15,
                        height: MediaQuery.of(context).size.width * .15,
                        child: CircularProgressIndicator(
                          backgroundColor: Colors.black,
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Colors.white),
                          strokeWidth: 2,
                        ),
                      )
                    ],
                  ),
                ),
              )
          ]),
        ),
        onWillPop: () async {
          return true;
        },
      );
    } else {
      return new WillPopScope(
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
      );
    }
  }
}
