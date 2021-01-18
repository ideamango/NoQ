import 'package:auto_size_text/auto_size_text.dart';
import 'package:enum_to_string/enum_to_string.dart';
import 'package:flutter/material.dart';
import 'package:noq/constants.dart';
import 'package:noq/db/db_model/booking_application.dart';
import 'package:noq/db/db_model/booking_form.dart';
import 'package:noq/enum/application_status.dart';
import 'package:noq/enum/field_type.dart';
import 'package:noq/global_state.dart';
import 'package:noq/pages/covid_token_booking_form.dart';
import 'package:noq/pages/overview_page.dart';
import 'package:noq/pages/show_application_details.dart';
import 'package:noq/services/circular_progress.dart';
import 'package:noq/style.dart';
import 'package:noq/userHomePage.dart';
import 'package:noq/utils.dart';
import 'package:noq/widget/appbar.dart';
import 'package:noq/widget/page_animation.dart';
import 'package:noq/widget/widgets.dart';

class ApplicationsList extends StatefulWidget {
  final String entityId;
  final String bookingFormId;
  final ApplicationStatus status;
  final String titleText;
  ApplicationsList(
      {Key key,
      @required this.entityId,
      @required this.bookingFormId,
      @required this.status,
      @required this.titleText})
      : super(key: key);
  @override
  _ApplicationsListState createState() => _ApplicationsListState();
}

class _ApplicationsListState extends State<ApplicationsList> {
  bool initCompleted = false;
  GlobalState _gs;

  List<BookingApplication> listOfBa;
  Map<String, TextEditingController> listOfControllers =
      new Map<String, TextEditingController>();

  @override
  void initState() {
    super.initState();
    getGlobalState().whenComplete(() {
      //******gettinmg dummy data -remove this afterwards */
      //  getListOfData();

      _gs
          .getTokenApplicationService()
          .getApplications(widget.bookingFormId, widget.entityId, widget.status,
              null, null, null, null, null, null, null, null)
          .then((value) {
        listOfBa = value;
        if (this.mounted) {
          setState(() {
            initCompleted = true;
          });
        } else
          initCompleted = true;
      });
    });
  }

  Future<void> getGlobalState() async {
    _gs = await GlobalState.getGlobalState();
  }

  getListOfData() async {
    //TODO: Generate dummy data as of now, later change to actual data

    listOfBa = initBookingFormDummy();
  }

  initBookingFormDummy() {
    BookingForm bookingForm;
    List<Field> fields;
    BookingApplication bookingApplication1;
    List<Value> idProofTypesStrList = List<Value>();
    List<Item> idProofTypes = List<Item>();
    List<Value> medConditionsStrList = List<Value>();
    List<Item> medConditions = List<Item>();
    FormInputFieldText nameInput;
    FormInputFieldDateTime dobInput;
    FormInputFieldText primaryPhone;
    FormInputFieldText alternatePhone;
    String _idProofType;
    FormInputFieldOptionsWithAttachments idProofField;
    FormInputFieldOptionsWithAttachments flWorkerField;

    FormInputFieldOptionsWithAttachments healthDetailsInput;
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
    nameInput.isMeta = true;

    dobInput = FormInputFieldDateTime(
      "Date of Birth",
      true,
      "Please select your Date of Birth",
    );
    dobInput.isMeta = true;
    dobInput.responseDateTime =
        DateTime.now().subtract(Duration(days: 365 * 30));

    primaryPhone = FormInputFieldText(
        "Primary Contact Number", true, "Primary Contact Number", 10);
    primaryPhone.response = "9611009823";
    primaryPhone.isMeta = true;

    alternatePhone = FormInputFieldText(
        "Alternate Contact Number", false, "Alternate Contact Number", 10);
    alternatePhone.response = "9611005523";
    alternatePhone.isMeta = false;

    idProofField = FormInputFieldOptionsWithAttachments("Photo ID Proof", true,
        "Please upload Government Id proof", idProofTypesStrList, false);
    idProofField.responseFilePaths = List<String>();
    idProofField.responseValues = new List<Value>();
    idProofField.responseValues.add(Value("DL"));
    idProofField.options.add(Value("DL"));
    idProofField.responseFilePaths.add(
        "https://firebasestorage.googleapis.com/v0/b/sukoon-india.appspot.com/o/fe3de7b0-567e-11eb-ae5b-5772ee4a0592%23fe3c12f0-567e-11eb-a11e-7f5c09f04575%23O72Pv6XakoRlxNKYbZLruYaMlwi1%23scaled_323f121e-f284-4d7f-8d58-95c81a3d6f2d5266208110146393983.jpg?alt=media&token=3415fa17-fc43-42fe-8e97-55cffea2f368");
    idProofField.responseFilePaths.add(
        "https://firebasestorage.googleapis.com/v0/b/sukoon-india.appspot.com/o/a457b240-5682-11eb-96bc-cb6bbe64022a%23a455b670-5682-11eb-9a03-7fcd37495df5%23O72Pv6XakoRlxNKYbZLruYaMlwi1%23scaled_38c1ed3d-38bb-45c4-9d22-93c1309be86c3402775137232538653.jpg?alt=media&token=4bb71a03-87c9-4056-9309-ab52d34d73c9");

    idProofField.isMeta = false;
//**************Frontline workers****** */
    flWorkerField = FormInputFieldOptionsWithAttachments(
        "Is Frontline Worker",
        true,
        "Please upload supporting documents",
        [Value("MP"), Value("MLA"), Value("DOCTOR"), Value("NURSE")],
        false);
    flWorkerField.responseFilePaths = List<String>();
    flWorkerField.responseValues = new List<Value>();
    flWorkerField.responseValues.add(Value("MP"));
    flWorkerField.responseFilePaths.add(
        "https://firebasestorage.googleapis.com/v0/b/sukoon-india.appspot.com/o/fe3de7b0-567e-11eb-ae5b-5772ee4a0592%23fe3c12f0-567e-11eb-a11e-7f5c09f04575%23O72Pv6XakoRlxNKYbZLruYaMlwi1%23scaled_323f121e-f284-4d7f-8d58-95c81a3d6f2d5266208110146393983.jpg?alt=media&token=3415fa17-fc43-42fe-8e97-55cffea2f368");
    flWorkerField.responseFilePaths.add(
        "https://firebasestorage.googleapis.com/v0/b/sukoon-india.appspot.com/o/a457b240-5682-11eb-96bc-cb6bbe64022a%23a455b670-5682-11eb-9a03-7fcd37495df5%23O72Pv6XakoRlxNKYbZLruYaMlwi1%23scaled_38c1ed3d-38bb-45c4-9d22-93c1309be86c3402775137232538653.jpg?alt=media&token=4bb71a03-87c9-4056-9309-ab52d34d73c9");

    flWorkerField.isMeta = true;
//**************Frontline workers****** */

//**************Medical Conditionss****** */

    healthDetailsInput = FormInputFieldOptionsWithAttachments(
        "Any Medical Conditions",
        true,
        "Please select all known medical conditions you have",
        medConditionsStrList,
        true);
    healthDetailsInput.isMeta = true;
    healthDetailsInput.responseFilePaths = List<String>();
    healthDetailsInput.responseValues = new List<Value>();
    healthDetailsInput.responseValues.add(Value("Heart Conditions"));
    healthDetailsInput.responseValues
        .add(Value("Other Cardiovascular and Cerebrovascular Diseases"));
    healthDetailsInput.isMultiSelect = true;
    healthDetailsInput.responseFilePaths.add(
        "https://firebasestorage.googleapis.com/v0/b/sukoon-india.appspot.com/o/fe3de7b0-567e-11eb-ae5b-5772ee4a0592%23fe3c12f0-567e-11eb-a11e-7f5c09f04575%23O72Pv6XakoRlxNKYbZLruYaMlwi1%23scaled_323f121e-f284-4d7f-8d58-95c81a3d6f2d5266208110146393983.jpg?alt=media&token=3415fa17-fc43-42fe-8e97-55cffea2f368");
    healthDetailsInput.responseFilePaths.add(
        "https://firebasestorage.googleapis.com/v0/b/sukoon-india.appspot.com/o/appstore.png?alt=media&token=d0bb835d-e569-4f38-ad6e-fa0fed822cc7");

    healthDetailsInput.responseFilePaths.add(
        "https://firebasestorage.googleapis.com/v0/b/sukoon-india.appspot.com/o/a457b240-5682-11eb-96bc-cb6bbe64022a%23a455b670-5682-11eb-9a03-7fcd37495df5%23O72Pv6XakoRlxNKYbZLruYaMlwi1%23scaled_38c1ed3d-38bb-45c4-9d22-93c1309be86c3402775137232538653.jpg?alt=media&token=4bb71a03-87c9-4056-9309-ab52d34d73c9");
    healthDetailsDesc = FormInputFieldText(
        "Decription of medical conditions (optional)",
        true,
        "Decription of medical conditions (optional)",
        200);
    healthDetailsDesc.response = "Migraine";

    //**************Medical Conditionss****** */

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
    fields.add(flWorkerField);
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
    for (var field in fields) {
      bookingForm.addField(field);
    }
    bookingApplication1 = new BookingApplication();
    //slot

    bookingApplication1.preferredSlotTiming = DateTime.now();
    bookingApplication1.status = ApplicationStatus.CANCELLED;
    //bookingFormId
    // bookingApplication.bookingFormId = widget.bookingFormId;
    bookingApplication1.entityId = "SELENium Id";
    bookingApplication1.userId = _gs.getCurrentUser().id;
    bookingApplication1.status = ApplicationStatus.INPROCESS;
    bookingApplication1.responseForm = bookingForm;

    BookingApplication bookingApplication2 = new BookingApplication();
    //slot

    bookingApplication2.preferredSlotTiming = DateTime.now();
    bookingApplication2.status = ApplicationStatus.CANCELLED;
    //bookingFormId
    // bookingApplication.bookingFormId = widget.bookingFormId;
    bookingApplication2.entityId = "SELENium Id";
    bookingApplication2.userId = _gs.getCurrentUser().id;
    bookingApplication2.status = ApplicationStatus.NEW;
    bookingApplication2.responseForm = bookingForm;
    BookingApplication bookingApplication3 = new BookingApplication();
    //slot

    bookingApplication3.preferredSlotTiming = DateTime.now();
    bookingApplication3.status = ApplicationStatus.CANCELLED;
    //bookingFormId
    // bookingApplication.bookingFormId = widget.bookingFormId;
    bookingApplication3.entityId = "SELENium Id";
    bookingApplication3.userId = _gs.getCurrentUser().id;
    bookingApplication3.status = ApplicationStatus.INPROCESS;
    bookingApplication3.responseForm = bookingForm;
    BookingApplication bookingApplication4 = new BookingApplication();
    //slot

    bookingApplication4.preferredSlotTiming = DateTime.now();
    bookingApplication4.status = ApplicationStatus.NEW;
    //bookingFormId
    // bookingApplication.bookingFormId = widget.bookingFormId;
    bookingApplication4.entityId = "SELENium Id";
    bookingApplication4.userId = _gs.getCurrentUser().id;
    bookingApplication4.status = ApplicationStatus.INPROCESS;
    bookingApplication4.responseForm = bookingForm;

    List<BookingApplication> list = new List<BookingApplication>();
    list.add(bookingApplication1);
    list.add(bookingApplication2);
    list.add(bookingApplication3);
    list.add(bookingApplication4);

    return list;
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
    Widget fieldWidget;
    Widget fieldsContainer = Container();
    if (field != null) {
      if (field.isMandatory) {
        switch (field.type) {
          case FieldType.TEXT:
            {
              FormInputFieldText newfield = field;
              fieldWidget = Text(newfield.response);
            }
            break;
          case FieldType.NUMBER:
            {
              FormInputFieldNumber newfield = field;
              fieldWidget = Text(newfield.response.toString());
            }
            break;
          case FieldType.PHONE:
            {
              FormInputFieldNumber newfield = field;
              fieldWidget = Text("+91 ${newfield.response.toString()}");
            }
            break;

          case FieldType.DATETIME:
            {
              FormInputFieldDateTime newfield = field;
              fieldWidget = Text(newfield.responseDateTime.toString());
            }
            break;
          case FieldType.OPTIONS:
            {
              FormInputFieldOptions newfield = field;
              fieldWidget = Text(newfield.responseValues.toString());
            }
            break;
          case FieldType.OPTIONS_ATTACHMENTS:
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
    List<Field> listOfMeta = new List<Field>();
    if (!listOfControllers.containsKey(ba.id)) {
      listOfControllers[ba.id] = new TextEditingController();
    }

    String name;
    String age;
    bool isFrontlineWorker = false;
    String fwImg1;

    bool isMedicalMorbidities = false;
    String mbImg1;
    String mbImg2;
    String medConds;
    TextEditingController notesController = new TextEditingController();

    listOfMeta.addAll(ba.responseForm
        .getFormFields()
        .where((element) => element.isMeta == true));

    for (var element in listOfMeta) {
      switch (element.label) {
        case "Name of the Applicant":
          name = (element as FormInputFieldText).response;
          break;
        case "Date of Birth of the Applicant":
          FormInputFieldDateTime newfield = element;
          age = ((DateTime.now().difference(newfield.responseDateTime).inDays) /
                  365)
              .toStringAsFixed(0);
          break;
        case "Only for Frontline workers":
          FormInputFieldOptionsWithAttachments newfield = element;
          isFrontlineWorker = !Utils.isNullOrEmpty(newfield.responseValues);
          if (isFrontlineWorker) {
            fwImg1 = newfield.responseValues[0].value;
          }
          break;
        case "Pre-existing Medical Conditions":
          FormInputFieldOptionsWithAttachments newfield = element;
          isMedicalMorbidities = !Utils.isNullOrEmpty(newfield.responseValues);
          if (isMedicalMorbidities) {
            for (Value val in newfield.responseValues) {
              if (!Utils.isNotNullOrEmpty(medConds)) medConds = "";
              medConds = medConds + val.value.toString();
            }
            // mbImg1 = newfield.responseValues[0].value;
            // if (newfield.responseValues.length > 1)
            //   mbImg2 = newfield.responseValues[1].value;
          }
          break;
        default:
          break;
      }
    }

    double cardHeight = MediaQuery.of(context).size.height * .2;
    double cardWidth = MediaQuery.of(context).size.width * .95;
    var medCondGroup = AutoSizeGroup();
    var labelGroup = AutoSizeGroup();
    Iterable<String> autoHints = [
      "Documents Incomplete",
      "Not priority now",
      "No Slots available"
    ];

    // String medConds =
    //    Utils.isNotNullOrEmpty(mbImg1)? mbImg1 + (Utils.isNotNullOrEmpty(mbImg2) ? " & $mbImg2" : "");

    return GestureDetector(
      onTap: () {
        Navigator.of(context)
            .push(PageAnimation.createRoute(ShowApplicationDetails(
          bookingApplication: ba,
        )));
      },
      child: Card(
        elevation: 8,
        child: Container(
          decoration: BoxDecoration(border: Border.all(color: Colors.blueGrey)),
          // color: Colors.orange,
          width: cardWidth,
          height: cardHeight,

          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(8, 10, 8, 4),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Row(
                          children: [
                            SizedBox(
                              width: cardWidth * .12,
                              child: AutoSizeText(
                                "Name : ",
                                group: labelGroup,
                                minFontSize: 10,
                                maxFontSize: 12,
                                maxLines: 1,
                                overflow: TextOverflow.clip,
                                style: TextStyle(
                                    color: Colors.blueGrey[700],
                                    fontFamily: 'RalewayRegular'),
                              ),
                            ),
                            SizedBox(
                              width: cardWidth * .3,
                              //height: cardHeight * .1,
                              child: AutoSizeText(
                                name,
                                minFontSize: 12,
                                maxFontSize: 14,
                                maxLines: 1,
                                overflow: TextOverflow.clip,
                                style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.indigo[900],
                                    fontWeight: FontWeight.bold,
                                    fontFamily: 'RalewayRegular'),
                              ),
                            ),
                          ],
                        ),
                        Row(children: [
                          SizedBox(
                            width: cardWidth * .083,
                            child: AutoSizeText(
                              "Age : ",
                              group: labelGroup,
                              minFontSize: 10,
                              maxFontSize: 12,
                              maxLines: 1,
                              overflow: TextOverflow.clip,
                              style: TextStyle(
                                  color: Colors.blueGrey[700],
                                  fontFamily: 'RalewayRegular'),
                            ),
                          ),
                          SizedBox(
                            width: cardWidth * .08,
                            child: Text(
                              age,
                              style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.indigo[900],
                                  fontWeight: FontWeight.bold,
                                  fontFamily: 'RalewayRegular'),
                            ),
                          ),
                        ]),
                      ],
                    ),
                    Row(children: [
                      SizedBox(
                        width: cardWidth * .12,
                        child: AutoSizeText(
                          "Status : ",
                          group: labelGroup,
                          minFontSize: 10,
                          maxFontSize: 12,
                          maxLines: 1,
                          overflow: TextOverflow.clip,
                          style: TextStyle(
                              color: Colors.blueGrey[700],
                              fontFamily: 'RalewayRegular'),
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.all(2),
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
                                            ? Colors.green[400]
                                            : Colors.blueGrey))),
                            shape: BoxShape.rectangle,
                            borderRadius:
                                BorderRadius.all(Radius.circular(5.0))),
                        child: SizedBox(
                          width: cardWidth * .2,
                          height: cardHeight * .11,
                          child: Center(
                            child: AutoSizeText(
                                EnumToString.convertToString(ba.status),
                                textAlign: TextAlign.center,
                                minFontSize: 7,
                                maxFontSize: 9,
                                style: TextStyle(
                                    fontSize: 9,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 1,
                                    color: Colors.white,
                                    fontFamily: 'RalewayRegular')),
                          ),
                        ),
                      ),
                    ]),
                  ],
                ),
              ),
              Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 2.0, horizontal: 8),
                child: Row(
                  children: [
                    AutoSizeText(
                      "Is a FrontLine Worker",
                      group: labelGroup,
                      minFontSize: 10,
                      maxFontSize: 12,
                      maxLines: 1,
                      overflow: TextOverflow.clip,
                      style: TextStyle(
                          color: Colors.blueGrey[700],
                          fontFamily: 'RalewayRegular'),
                    ),
                    horizontalSpacer,
                    (isFrontlineWorker)
                        ? Text(fwImg1,
                            style: TextStyle(
                                fontSize: 14,
                                color: Colors.indigo[900],
                                fontWeight: FontWeight.bold,
                                fontFamily: 'RalewayRegular'))
                        : Text("Not Applicable"),
                  ],
                ),
              ),
              Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 2.0, horizontal: 8),
                child: Row(
                  children: [
                    SizedBox(
                        width: cardWidth * .25,
                        child: Wrap(
                          children: [
                            AutoSizeText(
                              "Medical Issues",
                              group: labelGroup,
                              minFontSize: 10,
                              maxFontSize: 12,
                              maxLines: 1,
                              overflow: TextOverflow.clip,
                              style: TextStyle(
                                  color: Colors.blueGrey[700],
                                  fontFamily: 'RalewayRegular'),
                            ),
                          ],
                        )),
                    Wrap(children: [
                      SizedBox(
                        width: cardWidth * .63,
                        child: AutoSizeText(medConds,
                            group: medCondGroup,
                            minFontSize: 12,
                            maxFontSize: 14,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                                color: Colors.indigo[900],
                                fontWeight: FontWeight.bold,
                                fontFamily: 'RalewayRegular')),
                      ),
                    ]),
                  ],
                ),
              ),
              // Divider(
              //   indent: 5,
              //   thickness: 1,
              //   height: 5,
              //   color: Colors.blueGrey[300],
              // ),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                      margin: EdgeInsets.zero,
                      padding: EdgeInsets.only(left: 8, top: 0),
                      width: cardWidth * .5,
                      height: cardHeight * .35,
                      child: TextFormField(
                        controller: listOfControllers[ba.id],
                        style: TextStyle(
                            fontSize: 12,
                            color: Colors.blueGrey[700],
                            fontFamily: 'RalewayRegular'),
                        decoration: InputDecoration(
                          labelText: 'Remarks',
                          enabledBorder: UnderlineInputBorder(
                              borderSide: BorderSide(color: Colors.grey)),
                          focusedBorder: UnderlineInputBorder(
                              borderSide: BorderSide(color: Colors.orange)),
                        ),
                        maxLines: 2,
                        keyboardType: TextInputType.text,
                      )),
                  Container(
                    width: cardWidth * .42,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        IconButton(
                            alignment: Alignment.bottomCenter,
                            //    visualDensity: VisualDensity.compact,
                            padding: const EdgeInsets.fromLTRB(8, 2, 8, 0),
                            color: Colors.green[400],
                            onPressed: () {
                              ba.notesOnApproval =
                                  listOfControllers[ba.id].text;
                              setState(() {
                                ba.status = ApplicationStatus.APPROVED;
                              });
                            },
                            icon: Icon(
                              Icons.check_circle,
                              size: 30,
                            )),
                        IconButton(
                          alignment: Alignment.bottomCenter,
                          //    visualDensity: VisualDensity.compact,
                          padding: const EdgeInsets.fromLTRB(8, 2, 8, 0),
                          visualDensity: VisualDensity.compact,

                          color: Colors.yellow[700],
                          onPressed: () {
                            ba.notesOnPuttingOnHold =
                                listOfControllers[ba.id].text;
                            setState(() {
                              ba.status = ApplicationStatus.ONHOLD;
                            });
                          },
                          icon: Icon(
                            Icons.pan_tool_rounded,
                            size: 30,
                          ),
                        ),
                        IconButton(
                          // visualDensity: VisualDensity.compact,
                          alignment: Alignment.bottomCenter,
                          //    visualDensity: VisualDensity.compact,
                          padding: const EdgeInsets.fromLTRB(8, 2, 8, 0),
                          color: Colors.red,
                          onPressed: () {
                            ba.notesOnRejection = listOfControllers[ba.id].text;
                            setState(() {
                              ba.status = ApplicationStatus.REJECTED;
                            });
                          },
                          icon: Icon(
                            Icons.cancel,
                            size: 30,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

//       Column(
//         children: <Widget>[
//           Expanded(
//             child: Container(
//               height: 200,
//               padding: EdgeInsets.all(5),
//               child: Card(
//                 child: Row(
//                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                     children: [
// //Container that holds fields from response form where isMeta is true.

//                       Container(
//                         child: ListView.builder(
//                           itemBuilder: (BuildContext context, int index) {
//                             return Container(
//                               margin: EdgeInsets.fromLTRB(10, 0, 10, 50),
//                               child: new Column(
//                                 children: [
//                                   Text(listOfMeta[index].label),
//                                 ],
//                               ),
//                             );
//                           },
//                           itemCount: listOfMeta.length,
//                         ),
//                       ),

//                       Row(
//                         mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//                         children: [
//                           IconButton(
//                               color: Colors.green[400],
//                               onPressed: () {
//                                 ba.notesOnApproval = notesController.text;
//                                 ba.status = ApplicationStatus.APPROVED;
//                               },
//                               icon: Icon(Icons.check_circle)),
//                           IconButton(
//                             color: Colors.yellow[700],
//                             onPressed: () {
//                               ba.notesOnPuttingOnHold = notesController.text;
//                               ba.status = ApplicationStatus.ONHOLD;
//                             },
//                             icon: Icon(Icons.pan_tool_rounded),
//                           ),
//                           IconButton(
//                             color: Colors.red,
//                             onPressed: () {
//                               ba.notesOnRejection = notesController.text;
//                               ba.status = ApplicationStatus.REJECTED;
//                             },
//                             icon: Icon(Icons.cancel),
//                           ),
//                         ],
//                       )
//                     ]),
//               ),
//             ),
//           )
//         ],
//       ),
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
                widget.titleText,
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
                  (!Utils.isNullOrEmpty(listOfBa))
                      ? Expanded(
                          child: ListView.builder(
                            itemCount: listOfBa.length,
                            // reverse: true,
                            itemBuilder: (BuildContext context, int index) {
                              return Container(
                                margin: EdgeInsets.fromLTRB(10, 10, 10, 0),
                                child: new Column(
                                  children: [
                                    //  Text('dfhgd'),
                                    _buildItem(listOfBa[index])
                                  ],
                                ),
                              );
                            },
                          ),
                        )
                      : _emptyPage(),
                  // Container(
                  //     margin: EdgeInsets.fromLTRB(10, 10, 10, 10),
                  //     child: TextField(
                  //       readOnly: true,
                  //       controller: notesController,
                  //       decoration: InputDecoration(
                  //         labelText: 'Remarks',
                  //         enabledBorder: OutlineInputBorder(
                  //             borderSide: BorderSide(color: Colors.grey)),
                  //         focusedBorder: OutlineInputBorder(
                  //             borderSide: BorderSide(color: Colors.orange)),
                  //         // errorText:
                  //         //     _validate ? 'Please enter your message' : null,
                  //       ),
                  //       keyboardType: TextInputType.multiline,
                  //       maxLength: null,
                  //       maxLines: 2,
                  //     )),
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
              titleTxt: widget.titleText,
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
