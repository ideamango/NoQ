import 'package:LESSs/db/db_model/user_token.dart';
import 'package:LESSs/pages/token_alert.dart';
import 'package:LESSs/services/url_services.dart';
import 'package:LESSs/slot_selection_admin.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:enum_to_string/enum_to_string.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../SlotSelectionPage.dart';
import '../constants.dart';
import '../db/db_model/booking_application.dart';
import '../db/db_model/booking_form.dart';
import '../db/db_model/meta_entity.dart';

import '../enum/application_status.dart';
import '../enum/field_type.dart';
import '../global_state.dart';
import '../pages/covid_token_booking_form.dart';

import '../pages/show_application_details.dart';

import '../services/circular_progress.dart';
import '../style.dart';
import '../userHomePage.dart';
import '../utils.dart';
import '../widget/appbar.dart';
import '../widget/page_animation.dart';
import '../widget/widgets.dart';

import '../tuple.dart';

class ApplicationsList extends StatefulWidget {
  final MetaEntity? metaEntity;
  final String? bookingFormId;
  final ApplicationStatus status;
  final String titleText;
  final bool isReadOnly;
  ApplicationsList(
      {Key? key,
      required this.metaEntity,
      required this.bookingFormId,
      required this.status,
      required this.titleText,
      required this.isReadOnly})
      : super(key: key);
  @override
  _ApplicationsListState createState() => _ApplicationsListState();
}

class _ApplicationsListState extends State<ApplicationsList> {
  bool initCompleted = false;
  GlobalState? _gs;
  DocumentSnapshot? firstDocOfPage;
  DocumentSnapshot? lastDocOfPage;
  DateTime? selectedTimeSlot;
  bool errorInapplicationApproval = false;
  ScrollController? _childScrollControllerAppls;
  String? loadMoreMsg;

  List<Tuple<BookingApplication, QueryDocumentSnapshot>>? listOfBa;
  Map<String, TextEditingController> listOfControllers =
      new Map<String, TextEditingController>();
  TokenCounter? tokenCounterForEntity;

  Map<String?, DateTime> applicationNewSlotMap = Map<String?, DateTime>();
  bool showLoading = false;
  Tuple<String, bool>? defaultSortOrder;
  @override
  void initState() {
    super.initState();
    _childScrollControllerAppls = ScrollController();
    getGlobalState().whenComplete(() {
      //******gettinmg dummy data -remove this afterwards */
      //  getListOfData();

      _gs!
          .getTokenService()!
          .getTokenCounterForEntity(
              widget.metaEntity!.entityId!, DateTime.now().year.toString())
          .then((tokenCounter) {
        tokenCounterForEntity = tokenCounter;
      });

      defaultSortOrder = Utils.getDefaultApplicationSortOrder(widget.status);

      _gs!
          .getApplicationService()!
          .getApplications(
              widget.bookingFormId,
              widget.metaEntity!.entityId,
              widget.status,
              null,
              null,
              null,
              null,
              defaultSortOrder!.item1,
              defaultSortOrder!.item2,
              null,
              lastDocOfPage,
              2)
          .then((value) {
        listOfBa = value as List<Tuple<BookingApplication, QueryDocumentSnapshot>>?;
        lastDocOfPage =
            Utils.isNullOrEmpty(listOfBa) ? null : listOfBa!.last.item2;
        if (this.mounted) {
          setState(() {
            initCompleted = true;
          });
        } else
          initCompleted = true;
      });
    });
  }

  Future<bool> refreshTokenCounter() async {
    _gs!
        .getTokenService()!
        .getTokenCounterForEntity(
            widget.metaEntity!.entityId!, DateTime.now().year.toString())
        .then((tokenCounter) {
      tokenCounterForEntity = tokenCounter;
      return true;
    });
    return false;
  }

  Future<void> getGlobalState() async {
    _gs = await GlobalState.getGlobalState();
  }

  void loadMoreApplications() {
    showLoading = true;
    _gs!
        .getApplicationService()!
        .getApplications(
            widget.bookingFormId,
            widget.metaEntity!.entityId,
            widget.status,
            null,
            null,
            null,
            null,
            defaultSortOrder!.item1,
            defaultSortOrder!.item2,
            null,
            listOfBa![listOfBa!.length - 1].item2,
            1)
        .then((value) {
      if (Utils.isNullOrEmpty(value)) {
        loadMoreMsg = 'Thats all.';
      } else {
        value.forEach((element) {
          listOfBa!.add(element as Tuple<BookingApplication, QueryDocumentSnapshot>);
        });
        //listOfBa.addAll(value);
      }
      setState(() {
        showLoading = false;
      });
    });
  }

  initBookingFormDummy() {
    BookingForm bookingForm;
    List<Field> fields;
    BookingApplication bookingApplication1;
    List<Value> idProofTypesStrList = [];
    List<Item> idProofTypes = [];
    List<Value> medConditionsStrList = [];
    List<Item> medConditions = [];
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
    idProofField.responseFilePaths = [];
    idProofField.responseValues = [];
    idProofField.responseValues!.add(Value("DL"));
    idProofField.options!.add(Value("DL"));
    idProofField.responseFilePaths!.add(
        "https://firebasestorage.googleapis.com/v0/b/sukoon-india.appspot.com/o/fe3de7b0-567e-11eb-ae5b-5772ee4a0592%23fe3c12f0-567e-11eb-a11e-7f5c09f04575%23O72Pv6XakoRlxNKYbZLruYaMlwi1%23scaled_323f121e-f284-4d7f-8d58-95c81a3d6f2d5266208110146393983.jpg?alt=media&token=3415fa17-fc43-42fe-8e97-55cffea2f368");
    idProofField.responseFilePaths!.add(
        "https://firebasestorage.googleapis.com/v0/b/sukoon-india.appspot.com/o/a457b240-5682-11eb-96bc-cb6bbe64022a%23a455b670-5682-11eb-9a03-7fcd37495df5%23O72Pv6XakoRlxNKYbZLruYaMlwi1%23scaled_38c1ed3d-38bb-45c4-9d22-93c1309be86c3402775137232538653.jpg?alt=media&token=4bb71a03-87c9-4056-9309-ab52d34d73c9");

    idProofField.isMeta = false;
//**************Frontline workers****** */
    flWorkerField = FormInputFieldOptionsWithAttachments(
        "Is Frontline Worker",
        true,
        "Please upload supporting documents",
        [Value("MP"), Value("MLA"), Value("DOCTOR"), Value("NURSE")],
        false);
    flWorkerField.responseFilePaths = [];
    flWorkerField.responseValues = [];
    flWorkerField.responseValues!.add(Value("MP"));
    flWorkerField.responseFilePaths!.add(
        "https://firebasestorage.googleapis.com/v0/b/sukoon-india.appspot.com/o/fe3de7b0-567e-11eb-ae5b-5772ee4a0592%23fe3c12f0-567e-11eb-a11e-7f5c09f04575%23O72Pv6XakoRlxNKYbZLruYaMlwi1%23scaled_323f121e-f284-4d7f-8d58-95c81a3d6f2d5266208110146393983.jpg?alt=media&token=3415fa17-fc43-42fe-8e97-55cffea2f368");
    flWorkerField.responseFilePaths!.add(
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
    healthDetailsInput.responseFilePaths = [];
    healthDetailsInput.responseValues = [];
    healthDetailsInput.responseValues!.add(Value("Heart Conditions"));
    healthDetailsInput.responseValues!
        .add(Value("Other Cardiovascular and Cerebrovascular Diseases"));
    healthDetailsInput.isMultiSelect = true;
    healthDetailsInput.responseFilePaths!.add(
        "https://firebasestorage.googleapis.com/v0/b/sukoon-india.appspot.com/o/fe3de7b0-567e-11eb-ae5b-5772ee4a0592%23fe3c12f0-567e-11eb-a11e-7f5c09f04575%23O72Pv6XakoRlxNKYbZLruYaMlwi1%23scaled_323f121e-f284-4d7f-8d58-95c81a3d6f2d5266208110146393983.jpg?alt=media&token=3415fa17-fc43-42fe-8e97-55cffea2f368");
    healthDetailsInput.responseFilePaths!.add(
        "https://firebasestorage.googleapis.com/v0/b/sukoon-india.appspot.com/o/appstore.png?alt=media&token=d0bb835d-e569-4f38-ad6e-fa0fed822cc7");

    healthDetailsInput.responseFilePaths!.add(
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
    bookingApplication1.userId = _gs!.getCurrentUser()!.id;
    bookingApplication1.status = ApplicationStatus.INPROCESS;
    bookingApplication1.responseForm = bookingForm;

    BookingApplication bookingApplication2 = new BookingApplication();
    //slot

    bookingApplication2.preferredSlotTiming = DateTime.now();
    bookingApplication2.status = ApplicationStatus.CANCELLED;
    //bookingFormId
    // bookingApplication.bookingFormId = widget.bookingFormId;
    bookingApplication2.entityId = "SELENium Id";
    bookingApplication2.userId = _gs!.getCurrentUser()!.id;
    bookingApplication2.status = ApplicationStatus.NEW;
    bookingApplication2.responseForm = bookingForm;
    BookingApplication bookingApplication3 = new BookingApplication();
    //slot

    bookingApplication3.preferredSlotTiming = DateTime.now();
    bookingApplication3.status = ApplicationStatus.CANCELLED;
    //bookingFormId
    // bookingApplication.bookingFormId = widget.bookingFormId;
    bookingApplication3.entityId = "SELENium Id";
    bookingApplication3.userId = _gs!.getCurrentUser()!.id;
    bookingApplication3.status = ApplicationStatus.INPROCESS;
    bookingApplication3.responseForm = bookingForm;
    BookingApplication bookingApplication4 = new BookingApplication();
    //slot

    bookingApplication4.preferredSlotTiming = DateTime.now();
    bookingApplication4.status = ApplicationStatus.NEW;
    //bookingFormId
    // bookingApplication.bookingFormId = widget.bookingFormId;
    bookingApplication4.entityId = "SELENium Id";
    bookingApplication4.userId = _gs!.getCurrentUser()!.id;
    bookingApplication4.status = ApplicationStatus.INPROCESS;
    bookingApplication4.responseForm = bookingForm;

    List<BookingApplication> list = [];
    list.add(bookingApplication1);
    list.add(bookingApplication2);
    list.add(bookingApplication3);
    list.add(bookingApplication4);

    return list;
  }

  bool isAvailable(DateTime date) {
    String slotIdForDate = DateFormat('yyyy~M~d').format(date).toString() +
        '#' +
        date.hour.toString() +
        '~' +
        date.minute.toString();
    print(slotIdForDate);
    if (tokenCounterForEntity != null) {
      if (tokenCounterForEntity!.slotWiseStats!.containsKey(slotIdForDate)) {
        if ((tokenCounterForEntity!
                    .slotWiseStats![slotIdForDate]!.numberOfTokensCreated! -
                tokenCounterForEntity!
                    .slotWiseStats![slotIdForDate]!.numberOfTokensCancelled!) <
            widget.metaEntity!.maxAllowed!) {
          return true;
        } else
          return false;
      }
    }
    return true;
  }

  Widget _emptyPage() {
    return Center(
      child: Container(
        height: MediaQuery.of(context).size.height * .8,
        alignment: Alignment.center,
        child: Text(
            "No ${EnumToString.convertToString(widget.status)} Requests!",
            style: TextStyle(fontSize: 18)),
      ),
    );
  }

  var labelGroup = AutoSizeGroup();
  var responseGroup = AutoSizeGroup();
  var btnLabelGroup = AutoSizeGroup();
  Widget buildChildItem(Field field, BookingApplication ba) {
    Widget fieldWidget = SizedBox();
    print(field.label);
    if (field != null) {
      switch (field.type) {
        case FieldType.TEXT:
          {
            FormInputFieldText newfield = field as FormInputFieldText;
            //TODO Smita - Add case if field is isEmail
            fieldWidget = Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  //width: cardWidth * .12,
                  child: AutoSizeText(
                    newfield.label!,
                    group: labelGroup,
                    minFontSize: 9,
                    maxFontSize: 11,
                    maxLines: 1,
                    overflow: TextOverflow.clip,
                    style: TextStyle(
                        color: Colors.blueGrey[700],
                        fontFamily: 'RalewayRegular'),
                  ),
                ),
                horizontalSpacer,
                SizedBox(
                  width: MediaQuery.of(context).size.width * .8,
                  //height: cardHeight * .1,
                  child: AutoSizeText(
                    newfield.response!,
                    group: responseGroup,
                    minFontSize: 12,
                    maxFontSize: 14,
                    maxLines: 2,
                    overflow: TextOverflow.clip,
                    style: TextStyle(
                        fontSize: 14,
                        color: Colors.indigo[900],
                        //  fontWeight: FontWeight.bold,
                        fontFamily: 'Roboto'),
                  ),
                ),
              ],
            );
          }
          break;
        case FieldType.INT:
          {
            FormInputFieldInt newfield = field as FormInputFieldInt;
            fieldWidget = Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  //width: cardWidth * .12,
                  child: AutoSizeText(
                    newfield.label!,
                    group: labelGroup,
                    minFontSize: 9,
                    maxFontSize: 11,
                    maxLines: 1,
                    overflow: TextOverflow.clip,
                    style: TextStyle(
                        color: Colors.blueGrey[700],
                        fontFamily: 'RalewayRegular'),
                  ),
                ),
                horizontalSpacer,
                SizedBox(
                  //  width: cardWidth * .4,
                  //height: cardHeight * .1,
                  child: AutoSizeText(
                    newfield.response.toString(),
                    group: responseGroup,
                    minFontSize: 12,
                    maxFontSize: 14,
                    maxLines: 1,
                    overflow: TextOverflow.clip,
                    style: TextStyle(
                        fontSize: 14,
                        color: Colors.indigo[900],
                        // fontWeight: FontWeight.bold,
                        fontFamily: 'Roboto'),
                  ),
                ),
              ],
            );
          }
          break;
        case FieldType.NUMBER:
          {
            FormInputFieldNumber newfield = field as FormInputFieldNumber;
            fieldWidget = Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  //width: cardWidth * .12,
                  child: AutoSizeText(
                    newfield.label!,
                    group: labelGroup,
                    minFontSize: 9,
                    maxFontSize: 11,
                    maxLines: 1,
                    overflow: TextOverflow.clip,
                    style: TextStyle(
                        color: Colors.blueGrey[700],
                        fontFamily: 'RalewayRegular'),
                  ),
                ),
                horizontalSpacer,
                SizedBox(
                  //  width: cardWidth * .4,
                  //height: cardHeight * .1,
                  child: AutoSizeText(
                    newfield.response.toString(),
                    group: responseGroup,
                    minFontSize: 12,
                    maxFontSize: 14,
                    maxLines: 1,
                    overflow: TextOverflow.clip,
                    style: TextStyle(
                        fontSize: 14,
                        color: Colors.indigo[900],
                        // fontWeight: FontWeight.bold,
                        fontFamily: 'Roboto'),
                  ),
                ),
              ],
            );
          }
          break;
        case FieldType.PHONE:
          {
            FormInputFieldPhone newfield = field as FormInputFieldPhone;
            fieldWidget = Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  //width: cardWidth * .12,
                  child: AutoSizeText(
                    newfield.label!,
                    group: labelGroup,
                    minFontSize: 9,
                    maxFontSize: 11,
                    maxLines: 1,
                    overflow: TextOverflow.clip,
                    style: TextStyle(
                        color: Colors.blueGrey[700],
                        fontFamily: 'RalewayRegular'),
                  ),
                ),
                horizontalSpacer,
                SizedBox(
                  //  width: cardWidth * .4,
                  //height: cardHeight * .1,
                  child: AutoSizeText(
                    "+91 ${newfield.responsePhone.toString()}",
                    group: responseGroup,
                    minFontSize: 12,
                    maxFontSize: 14,
                    maxLines: 1,
                    overflow: TextOverflow.clip,
                    style: TextStyle(
                        color: Colors.indigo[900],
                        //fontWeight: FontWeight.bold,
                        fontFamily: 'Roboto'),
                  ),
                ),
              ],
            );
          }
          break;

        case FieldType.DATETIME:
          {
            FormInputFieldDateTime newfield = field as FormInputFieldDateTime;
            //TODO Smita - Add case if field is Age
            fieldWidget = Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  //width: cardWidth * .12,
                  child: AutoSizeText(
                    newfield.label!,
                    group: labelGroup,
                    minFontSize: 9,
                    maxFontSize: 11,
                    maxLines: 1,
                    overflow: TextOverflow.clip,
                    style: TextStyle(
                        color: Colors.blueGrey[700],
                        fontFamily: 'RalewayRegular'),
                  ),
                ),
                // horizontalSpacer,
                SizedBox(
                  //  width: cardWidth * .4,
                  //height: cardHeight * .1,
                  child: AutoSizeText(
                    (newfield.yearOnly!
                            ? newfield.responseDateTime!.year.toString()
                            : DateFormat('dd-MM-yyyy')
                                .format(newfield.responseDateTime!)
                                .toString()) +
                        (newfield.isAge!
                            ? " (Age - ${((DateTime.now().difference(newfield.responseDateTime!).inDays) / 365).toStringAsFixed(0)} years)"
                            : ""),
                    group: responseGroup,
                    minFontSize: 12,
                    maxFontSize: 14,
                    maxLines: 1,
                    overflow: TextOverflow.clip,
                    style: TextStyle(
                        color: Colors.indigo[900], fontFamily: 'Roboto'),
                  ),
                ),
              ],
            );
          }
          break;
        case FieldType.OPTIONS:
          {
            FormInputFieldOptions newfield = field as FormInputFieldOptions;
            //If field is multi-select then concatenate responses and show.

            String? responseVals;
            for (Value val in newfield.responseValues!) {
              if (!Utils.isNotNullOrEmpty(responseVals)) responseVals = "";
              responseVals = responseVals! +
                  ((responseVals != "")
                      ? (' | ' + val.value.toString())
                      : val.value.toString());
            }
            if (Utils.isStrNullOrEmpty(responseVals))
              responseVals = "No Data Found";

            fieldWidget = Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  //width: cardWidth * .12,
                  child: AutoSizeText(
                    newfield.label!,
                    group: labelGroup,
                    minFontSize: 9,
                    maxFontSize: 11,
                    maxLines: 1,
                    overflow: TextOverflow.clip,
                    style: TextStyle(
                        color: Colors.blueGrey[700],
                        fontFamily: 'RalewayRegular'),
                  ),
                ),
                // horizontalSpacer,
                SizedBox(
                  //  width: cardWidth * .4,
                  //height: cardHeight * .1,
                  child: AutoSizeText(
                    responseVals!,
                    group: responseGroup,
                    minFontSize: 12,
                    maxFontSize: 14,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                        fontSize: 14,
                        color: Colors.indigo[900],
                        fontFamily: 'Roboto'),
                  ),
                ),
              ],
            );
          }
          break;
        case FieldType.OPTIONS_ATTACHMENTS:
          {
            FormInputFieldOptionsWithAttachments newfield = field as FormInputFieldOptionsWithAttachments;
            String? responseVals;
            for (Value val in newfield.responseValues!) {
              if (!Utils.isNotNullOrEmpty(responseVals)) {
                responseVals = "";
              }
              if (responseVals == "")
                responseVals = responseVals! + val.value.toString();
              else
                responseVals = responseVals! + " | " + val.value.toString();
            }

            //  responseVals = newfield.responseValues.toString();

            fieldWidget = Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    SizedBox(
                      //width: cardWidth * .12,
                      child: AutoSizeText(
                        newfield.label!,
                        group: labelGroup,
                        minFontSize: 9,
                        maxFontSize: 11,
                        maxLines: 1,
                        overflow: TextOverflow.clip,
                        style: TextStyle(
                            color: Colors.blueGrey[700],
                            fontFamily: 'RalewayRegular'),
                      ),
                    ),
                    Row(
                      children: [
                        SizedBox(
                          width: MediaQuery.of(context).size.width * .85,
                          //height: cardHeight * .1,
                          child: AutoSizeText(
                            (responseVals != null) ? responseVals : "None",
                            group: responseGroup,
                            minFontSize: 12,
                            maxFontSize: 14,
                            maxLines: 3,
                            overflow: TextOverflow.clip,
                            style: TextStyle(
                                color: Colors.indigo[900],
                                fontFamily: 'Roboto'),
                          ),
                        ),
                        //horizontalSpacer,
                        // IconButton(
                        //   icon: Icon(
                        //     Icons.attach_file,
                        //     size: 14,
                        //   ),
                        //   onPressed: () {
                        //     print("Pressed");
                        //   },
                        // )
                      ],
                    ),
                  ],
                ),
                // IconButton(
                //     padding: EdgeInsets.all(0),
                //     splashColor: highlightColor,
                //     constraints: BoxConstraints(
                //       maxHeight: 25,
                //       maxWidth: 25,
                //     ),
                //     icon: Icon(
                //       Icons.attach_file,
                //       color: Colors.blueGrey[600],
                //     ),
                //     onPressed: () {
                //       Navigator.of(context).push(
                //           PageAnimation.createRoute(ShowApplicationDetails(
                //         bookingApplication: ba,
                //       )));
                //     })
              ],
            );
          }
          break;
        default:
          {
            // fieldWidget = Text("Could not fetch data");
          }
          break;
      }
    }
    return fieldWidget;
  }

  Future<DateTime?> showAvailableSlotsPopUp(
      BuildContext context, MetaEntity metaEntity, DateTime date) async {
    DateTime? selectedSlot;
    bool? returnVal = await showDialog(
        barrierDismissible: false,
        context: context,
        builder: (_) => AlertDialog(
              titlePadding: EdgeInsets.fromLTRB(10, 15, 10, 10),
              contentPadding: EdgeInsets.all(0),
              actionsPadding: EdgeInsets.all(5),
              content: Container(
                padding: EdgeInsets.all(10),
                color: Colors.white,
                width: MediaQuery.of(context).size.width,
                child: Column(
                  children: [
                    // image,
                    // ShowSlotsPage(
                    //     metaEntity: metaEntity, dateTime: date, forPage: null),

                    IconButton(
                      alignment: Alignment.topRight,
                      padding: EdgeInsets.zero,
                      icon: Icon(Icons.cancel_outlined,
                          color: Colors.red, size: 30),
                      onPressed: () => Navigator.of(_).pop(true),
                    ),
                  ],
                ),
              ),
            ));
    return selectedSlot;
  }

  Widget _buildItem(BookingApplication ba) {
    DateTime newSlot;
    List<Field> listOfMeta = new List<Field>();
    // if (!listOfControllers.containsKey(ba.id)) {
    //   listOfControllers[ba.id] = new TextEditingController();
    // }

    listOfMeta.addAll(ba.responseForm!
        .getFormFields()
        .where((element) => element.isMeta == true));

    double cardHeight = MediaQuery.of(context).size.height * .38;
    double cardWidth = MediaQuery.of(context).size.width * .95;
    var medCondGroup = AutoSizeGroup();
    var labelGroup = AutoSizeGroup();

    // String medConds =
    //    Utils.isNotNullOrEmpty(mbImg1)? mbImg1 + (Utils.isNotNullOrEmpty(mbImg2) ? " & $mbImg2" : "");

    return Card(
      elevation: 5,
      child: SingleChildScrollView(
        physics: ScrollPhysics(),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                          width: cardWidth * .75,
                          padding: EdgeInsets.fromLTRB(10, 5, 10, 0),
                          margin: EdgeInsets.zero,
                          child: Row(
                            children: [
                              SizedBox(
                                width: cardWidth * .3,
                                child: AutoSizeText(
                                  "Submission Date - ",
                                  group: labelGroup,
                                  minFontSize: 9,
                                  maxFontSize: 11,
                                  maxLines: 1,
                                  overflow: TextOverflow.clip,
                                  style: TextStyle(
                                      color: Colors.blueGrey[700],
                                      fontFamily: 'RalewayRegular'),
                                ),
                              ),
                              SizedBox(
                                width: cardWidth * .35,
                                child: AutoSizeText(
                                  DateFormat('yyyy-MM-dd – HH:mm')
                                      .format(ba.timeOfSubmission!),
                                  group: responseGroup,
                                  minFontSize: 10,
                                  maxFontSize: 14,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.indigo[900],
                                      fontFamily: 'Roboto'),
                                ),
                              ),
                            ],
                          )),
                      Container(
                          padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
                          margin: EdgeInsets.zero,
                          child: Row(
                            children: [
                              AutoSizeText(
                                "Submitted By - ",
                                group: labelGroup,
                                minFontSize: 9,
                                maxFontSize: 11,
                                maxLines: 1,
                                overflow: TextOverflow.clip,
                                style: TextStyle(
                                    color: Colors.blueGrey[700],
                                    fontFamily: 'RalewayRegular'),
                              ),
                              AutoSizeText(
                                ba.userId != null ? ba.userId! : '-',
                                group: responseGroup,
                                minFontSize: 12,
                                maxFontSize: 14,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.indigo[900],
                                    fontFamily: 'Roboto'),
                              ),
                              IconButton(
                                  padding: EdgeInsets.all(0),
                                  alignment: Alignment.center,
                                  highlightColor: Colors.orange[300],
                                  icon: Icon(
                                    Icons.phone_in_talk,
                                    color: primaryDarkColor,
                                    size: 16,
                                  ),
                                  onPressed: () {
                                    if (ba.userId != null) {
                                      try {
                                        callPhone(ba.userId);
                                      } catch (error) {
                                        Utils.showMyFlushbar(
                                            context,
                                            Icons.error,
                                            Duration(seconds: 5),
                                            "Could not connect call to the number ${ba.userId} !!",
                                            "Try again later.");
                                      }
                                    } else {
                                      Utils.showMyFlushbar(
                                          context,
                                          Icons.info,
                                          Duration(seconds: 5),
                                          "Contact information not found!!",
                                          "");
                                    }
                                  })
                            ],
                          )),
                    ],
                  ),
                  Container(
                    padding: EdgeInsets.all(2),
                    margin: EdgeInsets.all(0),
                    alignment: Alignment.topCenter,
                    decoration: BoxDecoration(
                        color: (ba.status == ApplicationStatus.NEW)
                            ? Colors.blue
                            : (ba.status == ApplicationStatus.ONHOLD
                                ? Colors.yellow[700]
                                : (ba.status == ApplicationStatus.REJECTED
                                    ? Colors.red
                                    : (ba.status == ApplicationStatus.APPROVED
                                        ? Colors.green[400]
                                        : (ba.status ==
                                                ApplicationStatus.COMPLETED
                                            ? Colors.purple
                                            : Colors.blueGrey)))),
                        shape: BoxShape.rectangle,
                        borderRadius: BorderRadius.only(
                            bottomLeft: Radius.circular(5.0))),
                    child: SizedBox(
                      width: cardWidth * .2,
                      height: cardHeight * .1,
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
            if (Utils.isNotNullOrEmpty(ba.tokenId))
              Container(
                  margin: EdgeInsets.fromLTRB(10, 5, 10, 10),
                  padding: EdgeInsets.all(5),
                  width: MediaQuery.of(context).size.width * .9,
                  // color: Colors.cyan[100],
                  decoration: BoxDecoration(
                      border: Border.all(color: Colors.blueGrey[100]!),
                      color: Colors.white,
                      shape: BoxShape.rectangle,
                      borderRadius: BorderRadius.all(Radius.circular(5.0))),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        width: MediaQuery.of(context).size.width * .38,
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              AutoSizeText(
                                'Token#',
                                group: labelGroup,
                                minFontSize: 10,
                                maxFontSize: 11,
                                maxLines: 1,
                                overflow: TextOverflow.clip,
                                style: TextStyle(
                                    color: Colors.blueGrey[700],
                                    fontFamily: 'RalewayRegular'),
                              ),
                              AutoSizeText(
                                ('${Utils.getTokenDisplayName(ba.entityName!, ba.tokenId!)}'),
                                minFontSize: 9,
                                maxFontSize: 15,
                                maxLines: 1,
                                overflow: TextOverflow.clip,
                                style: TextStyle(
                                    color: (ba.status == ApplicationStatus.NEW)
                                        ? Colors.blue
                                        : (ba.status == ApplicationStatus.ONHOLD
                                            ? Colors.yellow[700]
                                            : (ba.status ==
                                                    ApplicationStatus.REJECTED
                                                ? Colors.red
                                                : (ba.status ==
                                                        ApplicationStatus
                                                            .APPROVED
                                                    ? Colors.greenAccent[700]
                                                    : (ba.status ==
                                                            ApplicationStatus
                                                                .COMPLETED
                                                        ? Colors.purple
                                                        : Colors.blueGrey)))),
                                    fontFamily: 'Roboto'),
                              ),
                            ]),
                      ),
                      Container(
                        width: MediaQuery.of(context).size.width * .38,
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              AutoSizeText(
                                'Time-Slot',
                                group: labelGroup,
                                minFontSize: 10,
                                maxFontSize: 11,
                                maxLines: 1,
                                overflow: TextOverflow.clip,
                                style: TextStyle(
                                    color: Colors.blueGrey[700],
                                    fontFamily: 'RalewayRegular'),
                              ),
                              horizontalSpacer,
                              AutoSizeText(
                                ('${DateFormat('yyyy-MM-dd – HH:mm').format(Utils.getTokenDate(ba.tokenId!))}'),
                                // group: medCondGroup,
                                minFontSize: 9,
                                maxFontSize: 15,
                                maxLines: 1,
                                overflow: TextOverflow.clip,
                                style: TextStyle(
                                    color: (ba.status == ApplicationStatus.NEW)
                                        ? Colors.blue
                                        : (ba.status == ApplicationStatus.ONHOLD
                                            ? Colors.yellow[700]
                                            : (ba.status ==
                                                    ApplicationStatus.REJECTED
                                                ? Colors.red
                                                : (ba.status ==
                                                        ApplicationStatus
                                                            .APPROVED
                                                    ? Colors.greenAccent[700]
                                                    : (ba.status ==
                                                            ApplicationStatus
                                                                .COMPLETED
                                                        ? Colors.purple
                                                        : Colors.blueGrey)))),
                                    //  fontWeight: FontWeight.bold,
                                    fontFamily: 'Roboto'),
                              ),
                            ]),
                      ),
                    ],
                  )),
            if (Utils.isStrNullOrEmpty(ba.tokenId))
              Container(
                margin: EdgeInsets.fromLTRB(10, 5, 10, 10),
                padding: EdgeInsets.all(5),
                width: MediaQuery.of(context).size.width * .9,
                // color: Colors.cyan[100],
                decoration: BoxDecoration(
                    border: Border.all(color: Colors.blueGrey[100]!),
                    color: Colors.white,
                    shape: BoxShape.rectangle,
                    borderRadius: BorderRadius.all(Radius.circular(5.0))),
                child: Text(
                  'No Token issued yet',
                  style: TextStyle(
                      color: Colors.blueGrey[700],
                      fontFamily: 'RalewayRegular'),
                ),
              ),
            ListView.builder(
              itemCount: listOfMeta.length,
              physics: NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              //reverse: false,
              itemBuilder: (BuildContext context, int index) {
                return Container(
                  padding: EdgeInsets.fromLTRB(10, 5, 10, 5),
                  margin: EdgeInsets.zero,
                  // margin: EdgeInsets.fromLTRB(10, 10, 10, 0),
                  child: new Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      //  Text('dfhgd'),
                      buildChildItem(listOfMeta[index], ba)
                    ],
                  ),
                );
              },
            ),
            Container(
              padding: EdgeInsets.fromLTRB(10, 5, 10, 0),
              margin: EdgeInsets.zero,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          SizedBox(
                              child: Wrap(
                            children: [
                              AutoSizeText(
                                "Preferred Time-slot by User",
                                group: labelGroup,
                                minFontSize: 9,
                                maxFontSize: 11,
                                maxLines: 1,
                                overflow: TextOverflow.clip,
                                style: TextStyle(
                                    color: Colors.blueGrey[700],
                                    fontFamily: 'RalewayRegular'),
                              ),
                            ],
                          )),
                          Row(
                            children: [
                              Container(
                                padding: EdgeInsets.fromLTRB(0, 0, 8, 0),
                                child: Row(
                                  children: [
                                    AutoSizeText(
                                      ((ba.preferredSlotTiming != null)
                                          ? DateFormat('yyyy-MM-dd – HH:mm')
                                              .format(ba.preferredSlotTiming!)
                                          : "None"),
                                      minFontSize: 12,
                                      maxFontSize: 14,
                                      maxLines: 1,
                                      group: responseGroup,
                                      overflow: TextOverflow.clip,
                                      style: TextStyle(
                                          fontSize: 14,
                                          color: Colors.indigo[900],
                                          fontFamily: 'Roboto'),
                                    ),
                                  ],
                                ),
                              ),
                              horizontalSpacer,
                              if ((ba.status == ApplicationStatus.NEW) ||
                                  (ba.status == ApplicationStatus.ONHOLD))
                                DateTime.now().isAfter(ba.preferredSlotTiming!)
                                    ? Row(
                                        children: [
                                          Icon(Icons.event_busy,
                                              color: Colors.orangeAccent[700]),
                                          Text('Expired',
                                              style: TextStyle(
                                                  color:
                                                      Colors.orangeAccent[700]))
                                        ],
                                      )
                                    : (isAvailable(ba.preferredSlotTiming!)
                                        ? Row(
                                            children: [
                                              Icon(Icons.event_available,
                                                  color:
                                                      Colors.greenAccent[700]),
                                              Text('Available',
                                                  style: TextStyle(
                                                      color: Colors
                                                          .greenAccent[700])),
                                            ],
                                          )
                                        : Row(
                                            children: [
                                              Icon(Icons.event_busy,
                                                  color:
                                                      Colors.orangeAccent[700]),
                                              Text('Not Available',
                                                  style: TextStyle(
                                                      color: Colors
                                                          .orangeAccent[700]))
                                            ],
                                          )),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                  if ((ba.status == ApplicationStatus.NEW) ||
                      (ba.status == ApplicationStatus.ONHOLD))
                    Container(
                      padding: EdgeInsets.all(5),
                      color: Colors.cyan[50],
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              AutoSizeText(
                                "Click to choose another Time-Slot",
                                //group: labelGroup,
                                minFontSize: 12,
                                maxFontSize: 13,
                                maxLines: 1,
                                overflow: TextOverflow.clip,
                                style: TextStyle(
                                    color: Colors.indigo[900],
                                    fontFamily: 'RalewayRegular'),
                              ),
                              IconButton(
                                  padding: EdgeInsets.all(4),
                                  constraints: BoxConstraints(
                                    maxHeight: 30,
                                    maxWidth: 30,
                                  ),
                                  icon: Icon(
                                    Icons.date_range,
                                    color: (ba.status !=
                                                ApplicationStatus.COMPLETED &&
                                            ba.status !=
                                                ApplicationStatus.CANCELLED)
                                        ? Colors.indigo[900]
                                        : disabledColor,
                                  ),
                                  onPressed: () async {
                                    if (widget.isReadOnly) {
                                      return;
                                    }
                                    if (ba.status !=
                                            ApplicationStatus.COMPLETED &&
                                        ba.status !=
                                            ApplicationStatus.CANCELLED) {
                                      if (ba.status ==
                                          ApplicationStatus.APPROVED) {
                                        Utils.showMyFlushbar(
                                            context,
                                            Icons.info_outline,
                                            Duration(seconds: 6),
                                            "This application is already approved, Cannot change timings now.",
                                            "");
                                        return;
                                      }

                                      final result = await Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  SlotSelectionAdmin(
                                                    metaEntity:
                                                        widget.metaEntity,
                                                    dateTime:
                                                        ba.preferredSlotTiming,
                                                    forAdmin: "ApplicationList",
                                                    tokenCounter:
                                                        tokenCounterForEntity,
                                                  )));

                                      print(result);
                                      setState(() {
                                        if (result != null) {
                                          applicationNewSlotMap[ba.id] = result;
                                        }
                                        //newSlot = result;
                                      });
                                    }
                                  })
                            ],
                          ),
                          if (applicationNewSlotMap.containsKey(ba.id))
                            AutoSizeText(
                              DateFormat('yyyy-MM-dd – HH:mm')
                                  .format(applicationNewSlotMap[ba.id]!),
                              minFontSize: 12,
                              maxFontSize: 14,
                              maxLines: 1,
                              overflow: TextOverflow.clip,
                              style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.indigo[900],
                                  fontFamily: 'Roboto'),
                            ),
                        ],
                      ),
                    ),
                  verticalSpacer,
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(bottom: 4.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  margin: EdgeInsets.zero,
                                  padding: EdgeInsets.zero,
                                  child: AutoSizeText(
                                    'Mode',
                                    group: labelGroup,
                                    minFontSize: 9,
                                    maxFontSize: 11,
                                    maxLines: 1,
                                    overflow: TextOverflow.clip,
                                    style: TextStyle(
                                        color: Colors.blueGrey[700],
                                        fontFamily: 'RalewayRegular'),
                                  ),
                                ),
                                Container(
                                  margin: EdgeInsets.zero,
                                  padding: EdgeInsets.zero,
                                  child: AutoSizeText(
                                    ba.isOnlineModeOfInteraction!
                                        ? 'Online'
                                        : 'Walk-in',
                                    minFontSize: 12,
                                    maxFontSize: 14,
                                    maxLines: 1,
                                    group: responseGroup,
                                    overflow: TextOverflow.clip,
                                    style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.indigo[900],
                                        fontFamily: 'Roboto'),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          ba.isOnlineModeOfInteraction!
                              ? GestureDetector(
                                  onTap: () {
                                    if ((ba.tokenId) != null) {
                                      DateTime tokenDateTime =
                                          Utils.getTokenDate(ba.tokenId!);
                                      if (tokenDateTime != null) {
                                        Duration timeDiff = DateTime.now()
                                            .difference(tokenDateTime);
                                        if (timeDiff.inMinutes <= -1) {
                                          print("Diff more");
                                          Utils.showMyFlushbar(
                                              context,
                                              Icons.info,
                                              Duration(seconds: 5),
                                              yourTurnUserMessage1,
                                              yourTurnUserMessage2);
                                        } else if (tokenDateTime
                                            .isBefore(DateTime.now())) {
                                          Utils.showMyFlushbar(
                                              context,
                                              Icons.error,
                                              Duration(seconds: 6),
                                              "Could not start WhatsApp call as this Booking has already expired.",
                                              "Please contact Owner/Manager of this Place");
                                        } else {
                                          String? phoneNo = ba.userId;
                                          if (phoneNo != null &&
                                              phoneNo != "") {
                                            try {
                                              launchWhatsApp(
                                                  message: whatsappMessageToPlaceOwner +
                                                      '${Utils.getTokenDisplayName(ba.entityName!, ba.tokenId!)}' +
                                                      "\n\n<Type your message here..>",
                                                  phone: phoneNo);
                                            } catch (error) {
                                              Utils.showMyFlushbar(
                                                  context,
                                                  Icons.error,
                                                  Duration(seconds: 5),
                                                  "Could not connect to the WhatsApp number $phoneNo !!",
                                                  "Try again later");
                                            }
                                          } else {
                                            Utils.showMyFlushbar(
                                                context,
                                                Icons.info,
                                                Duration(seconds: 5),
                                                "WhatsApp contact information not found!!",
                                                "");
                                          }
                                        }
                                      }
                                    } else {
                                      Utils.showMyFlushbar(
                                          context,
                                          Icons.info,
                                          Duration(seconds: 5),
                                          yourTurnUserMessageWhenTokenIsNotAlloted,
                                          '');
                                    }
                                  },
                                  child: Container(
                                      padding: EdgeInsets.zero,
                                      margin:
                                          EdgeInsets.symmetric(horizontal: 8),
                                      child: Icon(
                                        Icons.videocam,
                                        size: 25,
                                        color: highlightColor,
                                      )),
                                )
                              : SizedBox(
                                  width: 0,
                                  height: 0,
                                ),
                        ],
                      ),
                      GestureDetector(
                        onTap: () {
                          Navigator.of(context)
                              .push(new MaterialPageRoute(
                                  builder: (BuildContext context) =>
                                      ShowApplicationDetails(
                                        bookingApplication: ba,
                                        showReject: false,
                                        metaEntity: widget.metaEntity,
                                        newBookingDate: (applicationNewSlotMap
                                                .containsKey(ba.id)
                                            ? applicationNewSlotMap[ba.id]
                                            : ba.preferredSlotTiming),
                                        isReadOnly: widget.isReadOnly,
                                        isAvailable:
                                            isAvailable(ba.preferredSlotTiming!),
                                        tokenCounter: tokenCounterForEntity,
                                        backRoute: ApplicationsList(
                                            metaEntity: widget.metaEntity,
                                            bookingFormId: widget.bookingFormId,
                                            isReadOnly: widget.isReadOnly,
                                            status: widget.status,
                                            titleText: widget.titleText),
                                      )))
                              .then((value) {
                            tokenCounterForEntity = value;
                            //refreshTokenCounter();
                            setState(() {
                              print(
                                  'Updated returned Token counter from details page');
                            });
                          });
                        },
                        child: Container(
                          padding: EdgeInsets.zero,
                          child: Text("..show all details",
                              style: TextStyle(
                                color: Colors.blue,
                                fontSize: 12,
                              )),
                        ),
                      ),
                    ],
                  ),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [],
                  ),
                ],
              ),
            ),
            if (!widget.isReadOnly)
              Divider(
                indent: 0,
                endIndent: 0,
                thickness: 0.5,
                height: 5,
                color: Colors.blueGrey[400],
              ),
            if (!widget.isReadOnly)
              IntrinsicHeight(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      margin: EdgeInsets.fromLTRB(0, 0, 0, 0),
                      padding: EdgeInsets.fromLTRB(0, 0, 0, 0),
                      width: cardWidth * .22,
                      height: cardWidth * .15,
                      child: IconButton(
                          alignment: Alignment.center,
                          //    visualDensity: VisualDensity.compact,
                          padding: const EdgeInsets.fromLTRB(8, 2, 8, 2),
                          color: (ba.status != ApplicationStatus.COMPLETED &&
                                  ba.status != ApplicationStatus.CANCELLED)
                              ? Colors.purple[400]
                              : disabledColor,
                          onPressed: () {
                            if (widget.isReadOnly) {
                              Utils.showMyFlushbar(
                                  context,
                                  Icons.info,
                                  Duration(seconds: 3),
                                  "$noEditPermission the Application",
                                  "Please contact Admin of this place.");
                              return;
                            }
                            if (DateTime.now().isAfter(
                                (applicationNewSlotMap.containsKey(ba.id)
                                    ? applicationNewSlotMap[ba.id]!
                                    : ba.preferredSlotTiming!))) {
                              Utils.showMyFlushbar(
                                  context,
                                  Icons.info,
                                  Duration(seconds: 3),
                                  timeSlotExpired,
                                  "Select a different Date or Time and try again.");
                              return;
                            }
                            if (ba.status != ApplicationStatus.COMPLETED &&
                                ba.status != ApplicationStatus.CANCELLED) {
                              setState(() {
                                showLoading = true;
                              });

                              showApplicationStatusDialog(
                                      context,
                                      "Complete Application",
                                      'Are you sure you want to mark this Application as Completed?',
                                      completeDialogMsg,
                                      'Completed')
                                  .then((remarks) {
                                //Update application status change on server.
                                if ((remarks![1])) {
                                  ba.notesOnPuttingOnHold = (remarks[0]);
                                  ba.notesOnCompletion = remarks[0];
                                  DateTime? bookingDate =
                                      applicationNewSlotMap.containsKey(ba.id)
                                          ? applicationNewSlotMap[ba.id]
                                          : ba.preferredSlotTiming;
                                  _gs!
                                      .getApplicationService()!
                                      .updateApplicationStatus(
                                          ba.id!,
                                          ApplicationStatus.COMPLETED,
                                          remarks[0],
                                          widget.metaEntity,
                                          bookingDate)
                                      .then((value) {
                                    if (value != null) {
                                      setState(() {
                                        ba.status = ApplicationStatus.COMPLETED;
                                        ba.timeOfCompletion =
                                            value.item1!.timeOfCompletion;
                                        ba.notesOnCompletion =
                                            value.item1!.notesOnCompletion;
                                        ba.completedBy =
                                            value.item1!.completedBy;
                                      });
                                      Utils.showMyFlushbar(
                                          context,
                                          Icons.check,
                                          Duration(seconds: 2),
                                          "Application is marked completed!!",
                                          "",
                                          Colors.purple[400],
                                          Colors.white);
                                      refreshTokenCounter().then((value) {
                                        setState(() {
                                          showLoading = false;
                                        });
                                      });
                                    } else {
                                      print("Could not update application");
                                      Utils.showMyFlushbar(
                                          context,
                                          Icons.error,
                                          Duration(seconds: 4),
                                          "Oops! Application could not be marked Completed!!",
                                          "Try again later.");
                                      setState(() {
                                        showLoading = false;
                                      });
                                    }
                                  }).catchError((error) {
                                    Utils.handleErrorsInUpdateApplicationStatus(
                                        error, context);
                                    setState(() {
                                      showLoading = false;
                                    });
                                  });
                                } else {
                                  setState(() {
                                    showLoading = false;
                                  });
                                }
                              });
                            }
                          },
                          icon: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              SizedBox(
                                width: cardWidth * .07,
                                height: cardWidth * .07,
                                child: Icon(
                                  Icons.thumb_up,
                                  size: 20,
                                ),
                              ),
                              Container(
                                width: cardWidth * .18,
                                height: cardHeight * .045,
                                alignment: Alignment.center,
                                margin: EdgeInsets.fromLTRB(0, 5, 0, 0),
                                padding: EdgeInsets.fromLTRB(0, 0, 0, 0),
                                child: AutoSizeText('COMPLETE',
                                    group: btnLabelGroup,
                                    minFontSize: 8,
                                    maxFontSize: 13,
                                    maxLines: 1,
                                    style: TextStyle(
                                        color: Colors.blueGrey[900],
                                        fontFamily: 'Roboto')),
                              ),
                            ],
                          )),
                    ),
                    VerticalDivider(
                      indent: 0,
                      endIndent: 0,
                      // thickness: 1,
                      width: 5,
                      color: Colors.blueGrey[400],
                    ),
                    Container(
                      margin: EdgeInsets.fromLTRB(0, 0, 0, 0),
                      padding: EdgeInsets.fromLTRB(0, 0, 0, 0),
                      width: cardWidth * .22,
                      height: cardWidth * .15,
                      child: IconButton(
                          alignment: Alignment.center,
                          //    visualDensity: VisualDensity.compact,
                          padding: const EdgeInsets.fromLTRB(8, 0, 8, 0),
                          color: (ba.status != ApplicationStatus.COMPLETED &&
                                  ba.status != ApplicationStatus.CANCELLED &&
                                  ba.status != ApplicationStatus.APPROVED)
                              ? Colors.green[400]
                              : disabledColor,
                          onPressed: () {
                            if (widget.isReadOnly) {
                              Utils.showMyFlushbar(
                                  context,
                                  Icons.info,
                                  Duration(seconds: 3),
                                  "$noEditPermission the Application",
                                  "Please contact Admin of this place.");
                              return;
                            }
                            if (DateTime.now().isAfter(
                                (applicationNewSlotMap.containsKey(ba.id)
                                    ? applicationNewSlotMap[ba.id]!
                                    : ba.preferredSlotTiming!))) {
                              Utils.showMyFlushbar(
                                  context,
                                  Icons.info,
                                  Duration(seconds: 3),
                                  timeSlotExpired,
                                  "Select a different Date or Time and try again.");
                              return;
                            }
                            if (ba.status != ApplicationStatus.COMPLETED &&
                                ba.status != ApplicationStatus.CANCELLED &&
                                ba.status != ApplicationStatus.APPROVED) {
                              setState(() {
                                showLoading = true;
                              });

                              showApplicationStatusDialog(
                                      context,
                                      "Confirm Approval",
                                      'Do you want to proceed?',
                                      approveDialogMsg,
                                      'Approve')
                                  .then((remarks) {
                                //Update application status change on server.
                                if ((remarks![1])) {
                                  ba.notesOnPuttingOnHold = (remarks[0]);
                                  ba.notesOnApproval = remarks[0];
                                  DateTime? bookingDate =
                                      applicationNewSlotMap.containsKey(ba.id)
                                          ? applicationNewSlotMap[ba.id]
                                          : ba.preferredSlotTiming;
                                  _gs!
                                      .getApplicationService()!
                                      .updateApplicationStatus(
                                          ba.id!,
                                          ApplicationStatus.APPROVED,
                                          remarks[0],
                                          widget.metaEntity,
                                          bookingDate)
                                      .then((value) {
                                    if (value != null) {
                                      setState(() {
                                        ba.status = ApplicationStatus.APPROVED;
                                        //set tokenId with new values from Server.
                                        ba.timeOfApproval =
                                            value.item1!.timeOfApproval;
                                        ba.approvedBy = value.item1!.approvedBy;
                                        ba.notesOnApproval =
                                            value.item1!.notesOnApproval;
                                        ba.tokenId = value.item1!.tokenId;
                                      });
                                      Utils.showMyFlushbar(
                                          context,
                                          Icons.check,
                                          Duration(seconds: 2),
                                          "Application is Approved!!",
                                          "",
                                          successGreenSnackBar,
                                          Colors.white);
                                      refreshTokenCounter().then((value) {
                                        setState(() {
                                          showLoading = false;
                                        });
                                      });
                                    } else {
                                      print(
                                          "Could not update application status");
                                      Utils.showMyFlushbar(
                                          context,
                                          Icons.error,
                                          Duration(seconds: 4),
                                          "Oops! Application could not be Approved!!",
                                          tryAgainToBook);
                                      setState(() {
                                        showLoading = false;
                                      });
                                    }
                                  }).catchError((error) {
                                    Utils.handleErrorsInUpdateApplicationStatus(
                                        error, context);
                                    setState(() {
                                      showLoading = false;
                                    });
                                  });
                                } else
                                  setState(() {
                                    showLoading = false;
                                  });
                              });
                            }
//Update application status change on server.
                          },
                          icon: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              SizedBox(
                                width: cardWidth * .07,
                                height: cardWidth * .07,
                                child: Icon(
                                  Icons.check_circle,
                                  size: 20,
                                ),
                              ),
                              Container(
                                width: cardWidth * .18,
                                height: cardHeight * .045,
                                alignment: Alignment.center,
                                margin: EdgeInsets.fromLTRB(0, 5, 0, 0),
                                padding: EdgeInsets.fromLTRB(0, 0, 0, 0),
                                child: AutoSizeText('APPROVE',
                                    group: btnLabelGroup,
                                    minFontSize: 8,
                                    maxFontSize: 13,
                                    maxLines: 1,
                                    style: TextStyle(
                                        color: Colors.blueGrey[900],
                                        fontFamily: 'Roboto')),
                              ),
                            ],
                          )),
                    ),
                    VerticalDivider(
                      indent: 0,
                      endIndent: 0,
                      // thickness: 1,
                      width: 5,
                      color: Colors.blueGrey[400],
                    ),
                    Container(
                      margin: EdgeInsets.fromLTRB(0, 0, 0, 0),
                      padding: EdgeInsets.fromLTRB(0, 0, 0, 0),
                      width: cardWidth * .22,
                      height: cardWidth * .15,
                      child: IconButton(
                        alignment: Alignment.center,
                        //    visualDensity: VisualDensity.compact,
                        padding: const EdgeInsets.fromLTRB(8, 2, 8, 2),
                        visualDensity: VisualDensity.compact,

                        color: (ba.status != ApplicationStatus.COMPLETED &&
                                ba.status != ApplicationStatus.CANCELLED &&
                                ba.status != ApplicationStatus.ONHOLD)
                            ? Colors.yellow[700]
                            : disabledColor,
                        onPressed: () {
                          if (widget.isReadOnly) {
                            Utils.showMyFlushbar(
                                context,
                                Icons.info,
                                Duration(seconds: 3),
                                "$noEditPermission the Application",
                                "Please contact Admin of this place.");
                            return;
                          }

                          // if (DateTime.now().isAfter(
                          //     (applicationNewSlotMap.containsKey(ba.id)
                          //         ? applicationNewSlotMap[ba.id]
                          //         : ba.preferredSlotTiming))) {
                          //   Utils.showMyFlushbar(
                          //       context,
                          //       Icons.info,
                          //       Duration(seconds: 3),
                          //       timeSlotExpired,
                          //       "Select a different Date or Time and try again.");
                          //   return;
                          // }
                          if (ba.status != ApplicationStatus.COMPLETED &&
                              ba.status != ApplicationStatus.CANCELLED &&
                              ba.status != ApplicationStatus.ONHOLD) {
                            setState(() {
                              showLoading = true;
                            });

                            showApplicationStatusDialog(
                                    context,
                                    "On-Hold Confirmation",
                                    'Are you sure you want to put this application On-Hold?',
                                    onHoldDialogMsg,
                                    'On-Hold')
                                .then((remarks) {
                              //Update application status change on server.

                              if ((remarks![1])) {
                                ba.notesOnPuttingOnHold = (remarks[0]);
                                DateTime? bookingDate =
                                    applicationNewSlotMap.containsKey(ba.id)
                                        ? applicationNewSlotMap[ba.id]
                                        : ba.preferredSlotTiming;
                                _gs!
                                    .getApplicationService()!
                                    .updateApplicationStatus(
                                        ba.id!,
                                        ApplicationStatus.ONHOLD,
                                        remarks[0],
                                        widget.metaEntity,
                                        bookingDate)
                                    .then((value) {
                                  setState(() {
                                    showLoading = false;
                                  });
                                  if (value != null) {
                                    setState(() {
                                      ba.status = ApplicationStatus.ONHOLD;
                                      ba.tokenId = value.item1!.tokenId;
                                      ba.putOnHoldBy = value.item1!.putOnHoldBy;
                                      ba.notesOnPuttingOnHold =
                                          value.item1!.notesOnPuttingOnHold;

                                      ba.timeOfPuttingOnHold =
                                          value.item1!.timeOfPuttingOnHold;
                                    });
                                    Utils.showMyFlushbar(
                                        context,
                                        Icons.check,
                                        Duration(seconds: 2),
                                        "Application is put on-hold!!",
                                        "",
                                        Colors.yellow[700],
                                        Colors.white);
                                    refreshTokenCounter().then((value) {
                                      setState(() {
                                        showLoading = false;
                                      });
                                    });
                                  } else {
                                    print(
                                        "Could not update application status");
                                    Utils.showMyFlushbar(
                                        context,
                                        Icons.error,
                                        Duration(seconds: 4),
                                        "Oops! Application could not be put On-Hold!!",
                                        tryAgainLater);
                                    setState(() {
                                      showLoading = false;
                                    });
                                  }
                                }).catchError((error) {
                                  setState(() {
                                    showLoading = false;
                                  });
                                  Utils.handleErrorsInUpdateApplicationStatus(
                                      error, context);
                                });
                              } else {
                                setState(() {
                                  showLoading = false;
                                });
                              }
                            });
                          }
                        },
                        icon: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            SizedBox(
                              width: cardWidth * .07,
                              height: cardWidth * .07,
                              child: Icon(
                                Icons.pan_tool_rounded,
                                size: 19,
                              ),
                            ),
                            Container(
                              width: cardWidth * .18,
                              height: cardHeight * .045,
                              alignment: Alignment.center,
                              margin: EdgeInsets.fromLTRB(0, 5, 0, 0),
                              padding: EdgeInsets.fromLTRB(0, 0, 0, 0),
                              child: AutoSizeText('ON-HOLD',
                                  group: btnLabelGroup,
                                  minFontSize: 8,
                                  maxFontSize: 13,
                                  maxLines: 1,
                                  style: TextStyle(
                                      color: Colors.blueGrey[900],
                                      fontFamily: 'Roboto')),
                            ),
                          ],
                        ),
                      ),
                    ),
                    VerticalDivider(
                      indent: 0,
                      endIndent: 0,
                      // thickness: 1,
                      width: 5,
                      color: Colors.blueGrey[400],
                    ),
                    Container(
                      margin: EdgeInsets.fromLTRB(0, 0, 0, 0),
                      padding: EdgeInsets.fromLTRB(0, 0, 0, 0),
                      width: cardWidth * .22,
                      height: cardWidth * .15,
                      child: IconButton(
                        // visualDensity: VisualDensity.compact,
                        alignment: Alignment.center,
                        //    visualDensity: VisualDensity.compact,
                        padding: const EdgeInsets.fromLTRB(8, 2, 8, 0),
                        color: (ba.status != ApplicationStatus.COMPLETED &&
                                ba.status != ApplicationStatus.CANCELLED &&
                                ba.status != ApplicationStatus.REJECTED)
                            ? Colors.red
                            : disabledColor,
                        onPressed: () {
                          if (widget.isReadOnly) {
                            Utils.showMyFlushbar(
                                context,
                                Icons.info,
                                Duration(seconds: 3),
                                "$noEditPermission the Application",
                                "Please contact Admin of this place.");
                            return;
                          }
                          // if (DateTime.now().isAfter(
                          //     (applicationNewSlotMap.containsKey(ba.id)
                          //         ? applicationNewSlotMap[ba.id]
                          //         : ba.preferredSlotTiming))) {
                          //   Utils.showMyFlushbar(
                          //       context,
                          //       Icons.info,
                          //       Duration(seconds: 3),
                          //       timeSlotExpired,
                          //       "Select a different Date or Time and try again.");
                          //   return;
                          // }
                          if (ba.status != ApplicationStatus.COMPLETED &&
                              ba.status != ApplicationStatus.CANCELLED &&
                              ba.status != ApplicationStatus.REJECTED) {
                            setState(() {
                              showLoading = true;
                            });

                            showApplicationStatusDialog(
                                    context,
                                    "Confirm Rejection",
                                    'Are you sure you want to Reject this Application?',
                                    rejectDialogMsg,
                                    'Reject')
                                .then((remarks) {
                              //Update application status change on server.
                              if ((remarks![1])) {
                                ba.notesOnPuttingOnHold = (remarks[0]);
                                ba.notesOnRejection = remarks[0];
                                DateTime? bookingDate =
                                    applicationNewSlotMap.containsKey(ba.id)
                                        ? applicationNewSlotMap[ba.id]
                                        : ba.preferredSlotTiming;
                                _gs!
                                    .getApplicationService()!
                                    .updateApplicationStatus(
                                        ba.id!,
                                        ApplicationStatus.REJECTED,
                                        remarks[0],
                                        widget.metaEntity,
                                        bookingDate)
                                    .then((value) {
                                  if (value != null) {
                                    setState(() {
                                      ba.status = ApplicationStatus.REJECTED;
                                      ba.tokenId = value.item1!.tokenId;
                                      ba.rejectedBy = value.item1!.rejectedBy;
                                      ba.notesOnRejection =
                                          value.item1!.notesOnRejection;
                                      ba.timeOfRejection =
                                          value.item1!.timeOfRejection;
                                    });
                                    Utils.showMyFlushbar(
                                        context,
                                        Icons.check,
                                        Duration(seconds: 2),
                                        "Application is Rejected!!",
                                        "",
                                        Colors.red,
                                        Colors.white);
                                    refreshTokenCounter().then((value) {
                                      setState(() {
                                        showLoading = false;
                                      });
                                    });
                                  } else {
                                    print(
                                        "Could not update application status");
                                    Utils.showMyFlushbar(
                                        context,
                                        Icons.error,
                                        Duration(seconds: 4),
                                        "Oops! Application could not be rejected!!",
                                        "");
                                    setState(() {
                                      showLoading = false;
                                    });
                                  }
                                }).catchError((error) {
                                  Utils.handleErrorsInUpdateApplicationStatus(
                                      error, context);
                                  setState(() {
                                    showLoading = false;
                                  });
                                });
                              } else {
                                setState(() {
                                  showLoading = false;
                                });
                              }
                            });
                          }
                        },
                        icon: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            SizedBox(
                              width: cardWidth * .07,
                              height: cardWidth * .07,
                              child: Icon(
                                Icons.cancel,
                                size: 21,
                              ),
                            ),
                            Container(
                              width: cardWidth * .18,
                              height: cardHeight * .045,
                              alignment: Alignment.center,
                              margin: EdgeInsets.fromLTRB(0, 5, 0, 0),
                              padding: EdgeInsets.fromLTRB(0, 0, 0, 0),
                              child: AutoSizeText('REJECT',
                                  group: btnLabelGroup,
                                  minFontSize: 8,
                                  maxFontSize: 13,
                                  maxLines: 1,
                                  style: TextStyle(
                                      color: Colors.blueGrey[900],
                                      fontFamily: 'Roboto')),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
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
      return WillPopScope(
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
          body: Stack(
            children: [
              Center(
                child: Column(
                  children: <Widget>[
                    (!Utils.isNullOrEmpty(listOfBa))
                        ? Expanded(
                            child: ListView.builder(
                              itemCount: listOfBa!.length,
                              reverse: false,
                              controller: _childScrollControllerAppls,
                              itemBuilder: (BuildContext context, int index) {
                                return Container(
                                  margin: EdgeInsets.fromLTRB(10, 8, 10, 8),
                                  child: new Column(
                                    children: [
                                      _buildItem(listOfBa![index].item1!),
                                      if (index == listOfBa!.length - 1)
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          children: [
                                            if (Utils.isNotNullOrEmpty(
                                                loadMoreMsg))
                                              Row(
                                                children: [
                                                  Container(
                                                      margin:
                                                          EdgeInsets.fromLTRB(
                                                              10, 10, 10, 18),
                                                      child: Text(
                                                        loadMoreMsg!,
                                                        style: TextStyle(
                                                            color: btnColor,
                                                            fontSize: 17),
                                                      ))
                                                ],
                                              ),
                                            if (!Utils.isNotNullOrEmpty(
                                                loadMoreMsg))
                                              Container(
                                                margin: EdgeInsets.all(10),
                                                child: MaterialButton(
                                                  shape: RoundedRectangleBorder(
                                                      side: BorderSide(
                                                          color: btnColor!),
                                                      borderRadius:
                                                          BorderRadius.all(
                                                              Radius.circular(
                                                                  3.0))),
                                                  child: Column(
                                                    children: [
                                                      Text(
                                                          'Show more Applications',
                                                          style: TextStyle(
                                                              fontSize: 15,
                                                              color:
                                                                  Colors.blue)),
                                                    ],
                                                  ),
                                                  onPressed: () {
                                                    loadMoreApplications();
                                                  },
                                                ),
                                              ),
                                          ],
                                        ),
                                    ],
                                  ),
                                );
                              },
                            ),
                          )
                        : _emptyPage(),
                  ],
                ),
              ),
              if (showLoading)
                Center(
                  child: Padding(
                    padding: EdgeInsets.only(top: 10.0, bottom: 10),
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
                  ),
                )
            ],
          ),
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
      );
    }
  }
}
