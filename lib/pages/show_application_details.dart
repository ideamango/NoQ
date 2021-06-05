import 'package:LESSs/SlotSelectionPage.dart';
import 'package:LESSs/constants.dart';
import 'package:LESSs/db/db_model/user_token.dart';
import 'package:LESSs/pages/token_alert.dart';
import 'package:LESSs/services/url_services.dart';
import 'package:LESSs/slot_selection_admin.dart';
import 'package:LESSs/tuple.dart';
import 'package:LESSs/widget/page_animation.dart';
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
  final bool showReject;
  final bool forInfo;
  final dynamic backRoute;
  final bool isReadOnly;
  final MetaEntity metaEntity;
  final DateTime newBookingDate;
  final bool isAvailable;
  final TokenCounter tokenCounter;

  ShowApplicationDetails({
    Key key,
    @required this.bookingApplication,
    @required this.showReject,
    @required this.forInfo,
    @required this.backRoute,
    @required this.isReadOnly,
    @required this.metaEntity,
    @required this.newBookingDate,
    @required this.isAvailable,
    @required this.tokenCounter,
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
  bool showLoading = false;
  DateTime newBookingDate;
  bool applicationUpdated = false;
  Tuple<BookingApplication, TokenCounter> returnTupleNewBa;
  @override
  void initState() {
    super.initState();
    //  newBookingDate = widget.newBookingDate;
    getGlobalState().whenComplete(() {
      //getListOfData();
      if (this.mounted) {
        // _gs.getEntity(widget.bookingApplication.entityId).then((value) {
        //   if (value != null) metaEntity = value.item1.getMetaEntity();
        setState(() {
          initCompleted = true;
        });
        // });
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
  var btnLabelGroup = AutoSizeGroup();

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

  bool isAvailable(DateTime date) {
    String slotIdForDate = DateFormat('yyyy~M~d').format(date).toString() +
        '#' +
        date.hour.toString() +
        '~' +
        date.minute.toString();
    print(slotIdForDate);
    if (widget.tokenCounter != null) {
      if (widget.tokenCounter.slotWiseStats.containsKey(slotIdForDate)) {
        if ((widget.tokenCounter.slotWiseStats[slotIdForDate]
                    .numberOfTokensCreated -
                widget.tokenCounter.slotWiseStats[slotIdForDate]
                    .numberOfTokensCancelled) <
            widget.metaEntity.maxAllowed) {
          return true;
        } else
          return false;
      }
    }
    return true;
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
                    //  height: MediaQuery.of(context).size.height * .08,
                    child: TextField(
                      controller: listOfControllers[field.label],
                      readOnly: true,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.indigo[900],
                      ),
                      maxLines: null,
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
                    conds = conds + "  |  " + newfield.responseValues[i].value;
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
    double cardHeight = MediaQuery.of(context).size.height * .38;
    double cardWidth = MediaQuery.of(context).size.width * .95;
    if (initCompleted) {
      notesController.text = widget.bookingApplication.notes;
      return MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData.light().copyWith(),
        home: WillPopScope(
          child: Scaffold(
            // appBar: CustomAppBarWithBackButton(
            //   backRoute: null,
            //   // (widget.backRoute != null)
            //   //     ? widget.backRoute
            //   //     : UserHomePage(),
            //   titleTxt: "Application Details",
            // ),
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
                    if (applicationUpdated)
                      Navigator.of(context).pop(returnTupleNewBa);
                    else
                      Navigator.of(context).pop();
                  }),
            ),
            body: SingleChildScrollView(
              physics: ScrollPhysics(),
              child: Card(
                elevation: 8,
                margin: EdgeInsets.all(10),
                // decoration: BoxDecoration(
                //     border: Border.all(color: Colors.blueGrey[300]),
                //     borderRadius: BorderRadius.all(Radius.circular(5.0))),
                // mainAxisAlignment: MainAxisAlignment.spaceBetween,
                child: Column(children: [
                  Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                                width: cardWidth * .75,
                                padding: EdgeInsets.fromLTRB(15, 5, 10, 0),
                                margin: EdgeInsets.zero,
                                child: Row(
                                  children: [
                                    SizedBox(
                                      width: cardWidth * .3,
                                      child: AutoSizeText(
                                        "Submission Date - ",
                                        //group: labelGroup,
                                        minFontSize: 9,
                                        maxFontSize: 11,
                                        maxLines: 1,
                                        overflow: TextOverflow.clip,
                                        style: TextStyle(
                                            color: Colors.blueGrey[500],
                                            fontWeight: FontWeight.bold,
                                            fontFamily: 'RalewayRegular'),
                                      ),
                                    ),
                                    SizedBox(
                                      width: cardWidth * .35,
                                      child: AutoSizeText(
                                        DateFormat('yyyy-MM-dd – HH:mm').format(
                                            widget.bookingApplication
                                                .timeOfSubmission),
                                        // group: responseGroup,
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
                                padding: EdgeInsets.fromLTRB(15, 0, 0, 0),
                                margin: EdgeInsets.zero,
                                child: Row(
                                  children: [
                                    AutoSizeText(
                                      "Submitted By - ",
                                      // group: labelGroup,
                                      minFontSize: 9,
                                      maxFontSize: 11,
                                      maxLines: 1,
                                      overflow: TextOverflow.clip,
                                      style: TextStyle(
                                          color: Colors.blueGrey[500],
                                          fontWeight: FontWeight.bold,
                                          fontFamily: 'RalewayRegular'),
                                    ),
                                    AutoSizeText(
                                      widget.bookingApplication.userId != null
                                          ? widget.bookingApplication.userId
                                          : '-',
                                      //  group: responseGroup,
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
                                        visualDensity: VisualDensity.compact,
                                        highlightColor: Colors.orange[300],
                                        icon: Icon(
                                          Icons.phone_in_talk,
                                          color: primaryDarkColor,
                                          size: 16,
                                        ),
                                        onPressed: () {
                                          if (widget
                                                  .bookingApplication.userId !=
                                              null) {
                                            try {
                                              callPhone(widget
                                                  .bookingApplication.userId);
                                            } catch (error) {
                                              Utils.showMyFlushbar(
                                                  context,
                                                  Icons.error,
                                                  Duration(seconds: 5),
                                                  "Could not connect call to the number ${widget.bookingApplication.userId} !!",
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
                          padding: EdgeInsets.all(5),
                          margin: EdgeInsets.all(0),
                          decoration: BoxDecoration(
                              shape: BoxShape.rectangle,
                              color: (widget.bookingApplication.status ==
                                      ApplicationStatus.NEW)
                                  ? Colors.blue
                                  : (widget.bookingApplication.status ==
                                          ApplicationStatus.ONHOLD
                                      ? Colors.yellow[700]
                                      : (widget.bookingApplication.status ==
                                              ApplicationStatus.REJECTED
                                          ? Colors.red
                                          : (widget.bookingApplication.status ==
                                                  ApplicationStatus.APPROVED
                                              ? Colors.greenAccent[700]
                                              : (widget.bookingApplication
                                                          .status ==
                                                      ApplicationStatus
                                                          .COMPLETED
                                                  ? Colors.purple
                                                  : Colors.blueGrey[400])))),
                              borderRadius: BorderRadius.only(
                                  bottomLeft: Radius.circular(5.0))),
                          child: SizedBox(
                            //height: cardHeight * .11,
                            child: Center(
                              child: AutoSizeText(
                                  EnumToString.convertToString(
                                      widget.bookingApplication.status),
                                  textAlign: TextAlign.center,
                                  minFontSize: 8,
                                  maxFontSize: 10,
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 1,
                                      color: Colors.white,
                                      fontFamily: 'RalewayRegular')),
                            ),
                          ),
                        ),
                      ]),
                  if (Utils.isNotNullOrEmpty(widget.bookingApplication.tokenId))
                    Container(
                        margin: EdgeInsets.fromLTRB(15, 0, 10, 10),
                        padding: EdgeInsets.all(5),
                        width: MediaQuery.of(context).size.width * .9,
                        // color: Colors.cyan[100],
                        decoration: BoxDecoration(
                            border: Border.all(color: Colors.blueGrey[100]),
                            color: Colors.white,
                            shape: BoxShape.rectangle,
                            borderRadius:
                                BorderRadius.all(Radius.circular(5.0))),
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
                                      //  group: labelGroup,
                                      minFontSize: 10,
                                      maxFontSize: 11,
                                      maxLines: 1,
                                      overflow: TextOverflow.clip,
                                      style: TextStyle(
                                          color: Colors.blueGrey[700],
                                          fontFamily: 'RalewayRegular'),
                                    ),
                                    AutoSizeText(
                                      ('${Utils.getTokenDisplayName(widget.bookingApplication.entityName, widget.bookingApplication.tokenId)}'),
                                      minFontSize: 9,
                                      maxFontSize: 15,
                                      maxLines: 1,
                                      overflow: TextOverflow.clip,
                                      style: TextStyle(
                                          color: (widget.bookingApplication.status ==
                                                  ApplicationStatus.NEW)
                                              ? Colors.blue
                                              : (widget.bookingApplication.status ==
                                                      ApplicationStatus.ONHOLD
                                                  ? Colors.yellow[700]
                                                  : (widget.bookingApplication.status ==
                                                          ApplicationStatus
                                                              .REJECTED
                                                      ? Colors.red
                                                      : (widget.bookingApplication
                                                                  .status ==
                                                              ApplicationStatus
                                                                  .APPROVED
                                                          ? Colors
                                                              .greenAccent[700]
                                                          : (widget.bookingApplication
                                                                      .status ==
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
                                      // group: labelGroup,
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
                                      ('${DateFormat('yyyy-MM-dd – HH:mm').format(Utils.getTokenDate(widget.bookingApplication.tokenId))}'),
                                      // group: medCondGroup,
                                      minFontSize: 9,
                                      maxFontSize: 15,
                                      maxLines: 1,
                                      overflow: TextOverflow.clip,
                                      style: TextStyle(
                                          color: (widget.bookingApplication
                                                      .status ==
                                                  ApplicationStatus.NEW)
                                              ? Colors.blue
                                              : (widget.bookingApplication
                                                          .status ==
                                                      ApplicationStatus.ONHOLD
                                                  ? Colors.yellow[700]
                                                  : (widget.bookingApplication
                                                              .status ==
                                                          ApplicationStatus
                                                              .REJECTED
                                                      ? Colors.red
                                                      : (widget.bookingApplication
                                                                  .status ==
                                                              ApplicationStatus
                                                                  .APPROVED
                                                          ? Colors
                                                              .greenAccent[700]
                                                          : (widget.bookingApplication
                                                                      .status ==
                                                                  ApplicationStatus
                                                                      .COMPLETED
                                                              ? Colors.purple
                                                              : Colors
                                                                  .blueGrey)))),
                                          //  fontWeight: FontWeight.bold,
                                          fontFamily: 'Roboto'),
                                    ),
                                  ]),
                            ),
                          ],
                        )),
                  if (Utils.isStrNullOrEmpty(widget.bookingApplication.tokenId))
                    Container(
                      margin: EdgeInsets.fromLTRB(10, 5, 10, 10),
                      padding: EdgeInsets.all(5),
                      width: MediaQuery.of(context).size.width * .9,
                      // color: Colors.cyan[100],
                      decoration: BoxDecoration(
                          border: Border.all(color: Colors.blueGrey[100]),
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
                  Container(
                    padding: EdgeInsets.fromLTRB(15, 5, 10, 0),
                    margin: EdgeInsets.fromLTRB(5, 0, 0, 0),
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
                                      minFontSize: 9,
                                      maxFontSize: 11,
                                      maxLines: 1,
                                      overflow: TextOverflow.clip,
                                      style: TextStyle(
                                          color: Colors.blueGrey[500],
                                          fontWeight: FontWeight.bold,
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
                                            ((widget.bookingApplication
                                                        .preferredSlotTiming !=
                                                    null)
                                                ? DateFormat(
                                                        'yyyy-MM-dd – HH:mm')
                                                    .format(widget
                                                        .bookingApplication
                                                        .preferredSlotTiming)
                                                : "None"),
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
                                    horizontalSpacer,
                                    if ((widget.bookingApplication.status ==
                                            ApplicationStatus.NEW) ||
                                        (widget.bookingApplication.status ==
                                            ApplicationStatus.ONHOLD))
                                      DateTime.now().isAfter(widget
                                              .bookingApplication
                                              .preferredSlotTiming)
                                          ? Row(
                                              children: [
                                                Icon(Icons.event_busy,
                                                    color: Colors
                                                        .orangeAccent[700]),
                                                Text('Expired',
                                                    style: TextStyle(
                                                        color: Colors
                                                            .orangeAccent[700]))
                                              ],
                                            )
                                          : (isAvailable(widget
                                                  .bookingApplication
                                                  .preferredSlotTiming)
                                              ? Row(
                                                  children: [
                                                    Icon(Icons.event_available,
                                                        color: Colors
                                                            .greenAccent[700]),
                                                    Text('Available',
                                                        style: TextStyle(
                                                            color: Colors
                                                                    .greenAccent[
                                                                700])),
                                                  ],
                                                )
                                              : Row(
                                                  children: [
                                                    Icon(Icons.event_busy,
                                                        color: Colors
                                                            .orangeAccent[700]),
                                                    Text('Not Available',
                                                        style: TextStyle(
                                                            color: Colors
                                                                    .orangeAccent[
                                                                700]))
                                                  ],
                                                )),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                        if ((widget.bookingApplication.status ==
                                ApplicationStatus.NEW) ||
                            (widget.bookingApplication.status ==
                                ApplicationStatus.ONHOLD))
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
                                          color: (widget.bookingApplication
                                                          .status !=
                                                      ApplicationStatus
                                                          .COMPLETED &&
                                                  widget.bookingApplication
                                                          .status !=
                                                      ApplicationStatus
                                                          .CANCELLED)
                                              ? Colors.indigo[900]
                                              : disabledColor,
                                        ),
                                        onPressed: () async {
                                          if (widget.isReadOnly) {
                                            return;
                                          }
                                          if (widget.bookingApplication
                                                      .status !=
                                                  ApplicationStatus.COMPLETED &&
                                              widget.bookingApplication
                                                      .status !=
                                                  ApplicationStatus.CANCELLED) {
                                            if (widget.bookingApplication
                                                    .status ==
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
                                                          dateTime: widget
                                                              .bookingApplication
                                                              .preferredSlotTiming,
                                                          forAdmin:
                                                              "ApplicationList",
                                                          tokenCounter: widget
                                                              .tokenCounter,
                                                        )));

                                            print(result);
                                            setState(() {
                                              if (result != null) {
                                                newBookingDate = result;
                                              }
                                              //newSlot = result;
                                            });
                                          }
                                        })
                                  ],
                                ),
                                if (newBookingDate != null)
                                  AutoSizeText(
                                    DateFormat('yyyy-MM-dd – HH:mm')
                                        .format(newBookingDate),
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
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Container(
                                        margin: EdgeInsets.zero,
                                        padding: EdgeInsets.zero,
                                        child: AutoSizeText(
                                          'Mode',
                                          minFontSize: 9,
                                          maxFontSize: 11,
                                          maxLines: 1,
                                          overflow: TextOverflow.clip,
                                          style: TextStyle(
                                              color: Colors.blueGrey[500],
                                              fontWeight: FontWeight.bold,
                                              fontFamily: 'RalewayRegular'),
                                        ),
                                      ),
                                      Container(
                                        margin: EdgeInsets.zero,
                                        padding: EdgeInsets.zero,
                                        child: AutoSizeText(
                                          (widget.bookingApplication
                                                  .isOnlineModeOfInteraction)
                                              ? 'Online'
                                              : 'Walk-in',
                                          minFontSize: 12,
                                          maxFontSize: 14,
                                          maxLines: 1,
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
                                (widget.bookingApplication
                                        .isOnlineModeOfInteraction)
                                    ? GestureDetector(
                                        onTap: () {
                                          if ((widget.bookingApplication
                                                  .tokenId) !=
                                              null) {
                                            DateTime tokenDateTime =
                                                Utils.getTokenDate(widget
                                                    .bookingApplication
                                                    .tokenId);
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
                                                    "Could not start Whatsapp call as this Booking has already expired.",
                                                    "Please contact Owner/Manager of this Place");
                                              } else {
                                                String phoneNo = widget
                                                    .bookingApplication.userId;
                                                if (phoneNo != null &&
                                                    phoneNo != "") {
                                                  try {
                                                    launchWhatsApp(
                                                        message: whatsappMessageToPlaceOwner +
                                                            '${Utils.getTokenDisplayName(widget.bookingApplication.entityName, widget.bookingApplication.tokenId)}' +
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
                                                      "Whatsapp contact information not found!!",
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
                                            margin: EdgeInsets.symmetric(
                                                horizontal: 8),
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
                            // GestureDetector(
                            //   onTap: () {
                            //     Navigator.of(context).push(
                            //         PageAnimation.createRoute(
                            //             ShowApplicationDetails(
                            //       bookingApplication: ba,
                            //       showCancel: false,
                            //       metaEntity: widget.metaEntity,
                            //       newBookingDate:
                            //           (applicationNewSlotMap.containsKey(widget.bookingApplication.id)
                            //               ? applicationNewSlotMap[widget.bookingApplication.id]
                            //               : widget.bookingApplication.preferredSlotTiming),
                            //       isReadOnly: widget.isReadOnly,
                            //       backRoute: ApplicationsList(
                            //           metaEntity: widget.metaEntity,
                            //           bookingFormId: widget.bookingFormId,
                            //           isReadOnly: widget.isReadOnly,
                            //           status: widget.status,
                            //           titleText: widget.titleText),
                            //     )));
                            //   },
                            //   child: Container(
                            //     padding: EdgeInsets.zero,
                            //     child: Text("..show all details",
                            //         style: TextStyle(
                            //             color: Colors.blue,
                            //             fontSize: 12,
                            //             fontFamily: 'RalewayRegular')),
                            //   ),
                            // ),
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
                  if (widget.showReject)
                    Container(
                      // width: MediaQuery.of(context).size.width * .8,
                      margin: EdgeInsets.all(9),
                      child: MaterialButton(
                          elevation: 8,
                          color: (widget.bookingApplication.status !=
                                      ApplicationStatus.COMPLETED &&
                                  widget.bookingApplication.status !=
                                      ApplicationStatus.CANCELLED &&
                                  widget.bookingApplication.status !=
                                      ApplicationStatus.REJECTED)
                              ? Colors.yellow[800]
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

                            if (widget.bookingApplication.status !=
                                    ApplicationStatus.COMPLETED &&
                                widget.bookingApplication.status !=
                                    ApplicationStatus.CANCELLED &&
                                widget.bookingApplication.status !=
                                    ApplicationStatus.REJECTED) {
                              setState(() {
                                showLoading = true;
                              });
                              Future.delayed(Duration(seconds: 1))
                                  .then((value) {
                                showApplicationStatusDialog(
                                        context,
                                        "Confirm Rejection",
                                        'Are you sure you want to Reject this Application?',
                                        rejectDialogMsg,
                                        'Reject')
                                    .then((remarks) {
                                  //Update application status change on server.
                                  if ((remarks[1])) {
                                    widget.bookingApplication.notesOnRejection =
                                        remarks[0];

                                    _gs
                                        .getApplicationService()
                                        .updateApplicationStatus(
                                            widget.bookingApplication.id,
                                            ApplicationStatus.REJECTED,
                                            remarks[0],
                                            widget.metaEntity,
                                            (newBookingDate != null
                                                ? newBookingDate
                                                : widget.newBookingDate))
                                        .then((newBa) {
                                      if (newBa != null) {
                                        setState(() {
                                          widget.bookingApplication.status =
                                              ApplicationStatus.REJECTED;
                                          widget.bookingApplication.tokenId =
                                              newBa.item1.tokenId;
                                          widget.bookingApplication.rejectedBy =
                                              newBa.item1.rejectedBy;
                                          widget.bookingApplication
                                                  .notesOnRejection =
                                              newBa.item1.notesOnRejection;
                                          widget.bookingApplication
                                                  .timeOfRejection =
                                              newBa.item1.timeOfRejection;
                                        });
                                        applicationUpdated = true;
                                        returnTupleNewBa = newBa;
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
                                      Utils
                                          .handleErrorsInUpdateApplicationStatus(
                                              error, context);
                                    });
                                  }
                                  setState(() {
                                    showLoading = false;
                                  });
                                });
                              });
                            } else
                              return;
                          },
                          child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  "Reject Application",
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
                  if (!widget.forInfo)
                    Divider(
                      indent: 0,
                      endIndent: 0,
                      thickness: 0.5,
                      height: 5,
                      color: Colors.blueGrey[400],
                    ),
                  if (!widget.forInfo)
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
                                color: (widget.bookingApplication.status !=
                                            ApplicationStatus.COMPLETED &&
                                        widget.bookingApplication.status !=
                                            ApplicationStatus.CANCELLED)
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
                                      (newBookingDate != null
                                          ? newBookingDate
                                          : widget.newBookingDate))) {
                                    Utils.showMyFlushbar(
                                        context,
                                        Icons.info,
                                        Duration(seconds: 3),
                                        timeSlotExpired,
                                        "Select a different Date or Time and try again.");
                                    return;
                                  }
                                  if (widget.bookingApplication.status !=
                                          ApplicationStatus.COMPLETED &&
                                      widget.bookingApplication.status !=
                                          ApplicationStatus.CANCELLED) {
                                    setState(() {
                                      showLoading = true;
                                    });
                                    Future.delayed(Duration(seconds: 2))
                                        .then((value) {
                                      showApplicationStatusDialog(
                                              context,
                                              "Complete Application",
                                              'Are you sure you want to mark this Application as Completed?',
                                              completeDialogMsg,
                                              'Completed')
                                          .then((remarks) {
                                        //Update application status change on server.
                                        if ((remarks[1])) {
                                          widget.bookingApplication
                                                  .notesOnPuttingOnHold =
                                              (remarks[0]);
                                          widget.bookingApplication
                                              .notesOnCompletion = remarks[0];
                                          // DateTime bookingDate = newBookingDate;
                                          // applicationNewSlotMap.containsKey(
                                          //         widget.bookingApplication.id)
                                          //     ? applicationNewSlotMap[
                                          //         widget.bookingApplication.id]
                                          //     : widget.bookingApplication
                                          //         .preferredSlotTiming;
                                          _gs
                                              .getApplicationService()
                                              .updateApplicationStatus(
                                                  widget.bookingApplication.id,
                                                  ApplicationStatus.COMPLETED,
                                                  remarks[0],
                                                  widget.metaEntity,
                                                  (newBookingDate != null
                                                      ? newBookingDate
                                                      : widget.newBookingDate))
                                              .then((newBa) {
                                            if (newBa != null) {
                                              setState(() {
                                                widget.bookingApplication
                                                        .status =
                                                    ApplicationStatus.COMPLETED;
                                                widget.bookingApplication
                                                        .tokenId =
                                                    newBa.item1.tokenId;
                                                widget.bookingApplication
                                                        .putOnHoldBy =
                                                    newBa.item1.putOnHoldBy;
                                                widget.bookingApplication
                                                        .notesOnPuttingOnHold =
                                                    newBa.item1
                                                        .notesOnPuttingOnHold;

                                                widget.bookingApplication
                                                        .timeOfPuttingOnHold =
                                                    newBa.item1
                                                        .timeOfPuttingOnHold;
                                              });
                                              applicationUpdated = true;
                                              returnTupleNewBa = newBa;
                                              Utils.showMyFlushbar(
                                                  context,
                                                  Icons.check,
                                                  Duration(seconds: 2),
                                                  "Application is marked completed!!",
                                                  "",
                                                  Colors.purple[400],
                                                  Colors.white);
                                            } else {
                                              print(
                                                  "Could not update application");
                                              Utils.showMyFlushbar(
                                                  context,
                                                  Icons.error,
                                                  Duration(seconds: 4),
                                                  "Oops! Application could not be marked Completed!!",
                                                  "Try again later.");
                                            }
                                          }).catchError((error) {
                                            Utils
                                                .handleErrorsInUpdateApplicationStatus(
                                                    error, context);
                                          });
                                        }
                                        setState(() {
                                          showLoading = false;
                                        });
                                      });
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
                                color: (widget.bookingApplication.status !=
                                            ApplicationStatus.COMPLETED &&
                                        widget.bookingApplication.status !=
                                            ApplicationStatus.CANCELLED &&
                                        widget.bookingApplication.status !=
                                            ApplicationStatus.APPROVED)
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
                                      (newBookingDate != null
                                          ? newBookingDate
                                          : widget.newBookingDate))) {
                                    Utils.showMyFlushbar(
                                        context,
                                        Icons.info,
                                        Duration(seconds: 3),
                                        timeSlotExpired,
                                        "Select a different Date or Time and try again.");
                                    return;
                                  }
                                  if (widget.bookingApplication.status !=
                                          ApplicationStatus.COMPLETED &&
                                      widget.bookingApplication.status !=
                                          ApplicationStatus.CANCELLED &&
                                      widget.bookingApplication.status !=
                                          ApplicationStatus.APPROVED) {
                                    setState(() {
                                      showLoading = true;
                                    });
                                    Future.delayed(Duration(seconds: 2))
                                        .then((value) {
                                      showApplicationStatusDialog(
                                              context,
                                              "Confirm Approval",
                                              'Do you want to proceed?',
                                              approveDialogMsg,
                                              'Approve')
                                          .then((remarks) {
                                        //Update application status change on server.
                                        if ((remarks[1])) {
                                          widget.bookingApplication
                                                  .notesOnPuttingOnHold =
                                              (remarks[0]);
                                          widget.bookingApplication
                                              .notesOnApproval = remarks[0];
                                          // DateTime bookingDate = newBookingDate;
                                          // applicationNewSlotMap.containsKey(
                                          //         widget.bookingApplication.id)
                                          //     ? applicationNewSlotMap[
                                          //         widget.bookingApplication.id]
                                          //     : widget.bookingApplication
                                          //         .preferredSlotTiming;
                                          _gs
                                              .getApplicationService()
                                              .updateApplicationStatus(
                                                  widget.bookingApplication.id,
                                                  ApplicationStatus.APPROVED,
                                                  remarks[0],
                                                  widget.metaEntity,
                                                  (newBookingDate != null
                                                      ? newBookingDate
                                                      : widget.newBookingDate))
                                              .then((newBa) {
                                            if (newBa != null) {
                                              setState(() {
                                                widget.bookingApplication
                                                        .status =
                                                    ApplicationStatus.APPROVED;
                                                //set tokenId with new newBas from Server.
                                                widget.bookingApplication
                                                        .tokenId =
                                                    newBa.item1.tokenId;
                                                widget.bookingApplication
                                                        .putOnHoldBy =
                                                    newBa.item1.putOnHoldBy;
                                                widget.bookingApplication
                                                        .notesOnPuttingOnHold =
                                                    newBa.item1
                                                        .notesOnPuttingOnHold;
                                                widget.bookingApplication
                                                        .timeOfPuttingOnHold =
                                                    newBa.item1
                                                        .timeOfPuttingOnHold;
                                              });
                                              applicationUpdated = true;
                                              returnTupleNewBa = newBa;
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
                                            Utils
                                                .handleErrorsInUpdateApplicationStatus(
                                                    error, context);
                                          });
                                        }
                                        setState(() {
                                          showLoading = false;
                                        });
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

                              color: (widget.bookingApplication.status !=
                                          ApplicationStatus.COMPLETED &&
                                      widget.bookingApplication.status !=
                                          ApplicationStatus.CANCELLED &&
                                      widget.bookingApplication.status !=
                                          ApplicationStatus.ONHOLD)
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
                                // if (DateTime.now().isAfter((newBookingDate != null
                                //     ? newBookingDate
                                //     : widget.newBookingDate))) {
                                //   Utils.showMyFlushbar(
                                //       context,
                                //       Icons.info,
                                //       Duration(seconds: 3),
                                //       timeSlotExpired,
                                //       "Select a different Date or Time and try again.");
                                //   return;
                                // }
                                if (widget.bookingApplication.status !=
                                        ApplicationStatus.COMPLETED &&
                                    widget.bookingApplication.status !=
                                        ApplicationStatus.CANCELLED &&
                                    widget.bookingApplication.status !=
                                        ApplicationStatus.ONHOLD) {
                                  setState(() {
                                    showLoading = true;
                                  });
                                  Future.delayed(Duration(seconds: 2))
                                      .then((value) {
                                    showApplicationStatusDialog(
                                            context,
                                            "On-Hold Confirmation",
                                            'Are you sure you want to put this application On-Hold?',
                                            onHoldDialogMsg,
                                            'On-Hold')
                                        .then((remarks) {
                                      //Update application status change on server.

                                      if ((remarks[1])) {
                                        widget.bookingApplication
                                                .notesOnPuttingOnHold =
                                            (remarks[0]);
                                        // DateTime bookingDate = newBookingDate;
                                        // applicationNewSlotMap.containsKey(
                                        //         widget.bookingApplication.id)
                                        //     ? applicationNewSlotMap[
                                        //         widget.bookingApplication.id]
                                        //     : widget.bookingApplication
                                        //         .preferredSlotTiming;
                                        _gs
                                            .getApplicationService()
                                            .updateApplicationStatus(
                                                widget.bookingApplication.id,
                                                ApplicationStatus.ONHOLD,
                                                remarks[0],
                                                widget.metaEntity,
                                                (newBookingDate != null
                                                    ? newBookingDate
                                                    : widget.newBookingDate))
                                            .then((newBa) {
                                          setState(() {
                                            showLoading = false;
                                          });
                                          if (newBa != null) {
                                            setState(() {
                                              widget.bookingApplication.status =
                                                  ApplicationStatus.ONHOLD;
                                              widget.bookingApplication
                                                      .tokenId =
                                                  newBa.item1.tokenId;
                                              widget.bookingApplication
                                                      .putOnHoldBy =
                                                  newBa.item1.putOnHoldBy;
                                              widget.bookingApplication
                                                      .notesOnPuttingOnHold =
                                                  newBa.item1
                                                      .notesOnPuttingOnHold;

                                              widget.bookingApplication
                                                      .timeOfPuttingOnHold =
                                                  newBa.item1
                                                      .timeOfPuttingOnHold;
                                            });
                                            applicationUpdated = true;
                                            returnTupleNewBa = newBa;
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
                                          setState(() {
                                            showLoading = false;
                                          });
                                          Utils
                                              .handleErrorsInUpdateApplicationStatus(
                                                  error, context);
                                        });
                                      }
                                      setState(() {
                                        showLoading = false;
                                      });
                                    });
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
                              color: (widget.bookingApplication.status !=
                                          ApplicationStatus.COMPLETED &&
                                      widget.bookingApplication.status !=
                                          ApplicationStatus.CANCELLED &&
                                      widget.bookingApplication.status !=
                                          ApplicationStatus.REJECTED)
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
                                // if (DateTime.now().isAfter((newBookingDate != null
                                //     ? newBookingDate
                                //     : widget.newBookingDate))) {
                                //   Utils.showMyFlushbar(
                                //       context,
                                //       Icons.info,
                                //       Duration(seconds: 3),
                                //       timeSlotExpired,
                                //       "Select a different Date or Time and try again.");
                                //   return;
                                // }
                                if (widget.bookingApplication.status !=
                                        ApplicationStatus.COMPLETED &&
                                    widget.bookingApplication.status !=
                                        ApplicationStatus.CANCELLED &&
                                    widget.bookingApplication.status !=
                                        ApplicationStatus.REJECTED) {
                                  setState(() {
                                    showLoading = true;
                                  });
                                  Future.delayed(Duration(seconds: 1))
                                      .then((value) {
                                    showApplicationStatusDialog(
                                            context,
                                            "Confirm Rejection",
                                            'Are you sure you want to Reject this Application?',
                                            rejectDialogMsg,
                                            'Reject')
                                        .then((remarks) {
                                      //Update application status change on server.
                                      if ((remarks[1])) {
                                        widget.bookingApplication
                                                .notesOnPuttingOnHold =
                                            (remarks[0]);
                                        widget.bookingApplication
                                            .notesOnRejection = remarks[0];
                                        // DateTime bookingDate = newBookingDate;
                                        // applicationNewSlotMap.containsKey(
                                        //         widget.bookingApplication.id)
                                        //     ? applicationNewSlotMap[
                                        //         widget.bookingApplication.id]
                                        //     : widget.bookingApplication
                                        //         .preferredSlotTiming;
                                        _gs
                                            .getApplicationService()
                                            .updateApplicationStatus(
                                                widget.bookingApplication.id,
                                                ApplicationStatus.REJECTED,
                                                remarks[0],
                                                widget.metaEntity,
                                                (newBookingDate != null
                                                    ? newBookingDate
                                                    : widget.newBookingDate))
                                            .then((newBa) {
                                          if (newBa != null) {
                                            setState(() {
                                              widget.bookingApplication.status =
                                                  ApplicationStatus.REJECTED;
                                              widget.bookingApplication
                                                      .tokenId =
                                                  newBa.item1.tokenId;
                                              widget.bookingApplication
                                                      .putOnHoldBy =
                                                  newBa.item1.putOnHoldBy;
                                              widget.bookingApplication
                                                      .notesOnPuttingOnHold =
                                                  newBa.item1
                                                      .notesOnPuttingOnHold;

                                              widget.bookingApplication
                                                      .timeOfPuttingOnHold =
                                                  newBa.item1
                                                      .timeOfPuttingOnHold;
                                            });
                                            applicationUpdated = true;
                                            returnTupleNewBa = newBa;
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
                                          Utils
                                              .handleErrorsInUpdateApplicationStatus(
                                                  error, context);
                                        });
                                      }
                                      setState(() {
                                        showLoading = false;
                                      });
                                    });
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
                ]),
//                   Container(
//                     width: MediaQuery.of(context).size.width * .97,
//                     padding: EdgeInsets.fromLTRB(8, 0, 8, 15),
//                     child: Row(
//                       mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//                       mainAxisSize: MainAxisSize.min,
//                       children: [
//                         SizedBox(
//                           width: MediaQuery.of(context).size.width * .21,
//                           child: RaisedButton(
//                               elevation: 8,
//                               color: (widget.bookingApplication.status !=
//                                           ApplicationStatus.COMPLETED &&
//                                       widget.bookingApplication.status !=
//                                           ApplicationStatus.CANCELLED)
//                                   ? Colors.purple
//                                   : disabledColor,
//                               onPressed: () {
//                                 if (widget.bookingApplication.status !=
//                                         ApplicationStatus.COMPLETED &&
//                                     widget.bookingApplication.status !=
//                                         ApplicationStatus.CANCELLED) {
//                                   showApplicationStatusDialog(
//                                           context,
//                                           "Complete Application",
//                                           'Are you sure you want to mark this application as Completed?',
//                                           completeDialogMsg,
//                                           'Complete')
//                                       .then((remarks) {
//                                     //Update application status change on server.
//                                     if (Utils.isNotNullOrEmpty(remarks)) {
//                                       widget.bookingApplication
//                                           .notesOnCompletion = remarks;
//                                       _gs
//                                           .getApplicationService()
//                                           .updateApplicationStatus(
//                                               widget.bookingApplication.id,
//                                               ApplicationStatus.COMPLETED,
//                                               remarks,
//                                               metaEntity,
//                                               widget.bookingApplication
//                                                   .preferredSlotTiming)
//                                           .then((value) {
//                                         if (value) {
//                                           setState(() {
//                                             widget.bookingApplication.status =
//                                                 ApplicationStatus.COMPLETED;
//                                           });
//                                           Utils.showMyFlushbar(
//                                               context,
//                                               Icons.check,
//                                               Duration(seconds: 2),
//                                               "Application is marked completed!!",
//                                               "",
//                                               Colors.purple[400],
//                                               Colors.white);
//                                         } else {
//                                           print("Could not update application");
//                                           Utils.showMyFlushbar(
//                                               context,
//                                               Icons.error,
//                                               Duration(seconds: 4),
//                                               "Oops! Application could not be marked Completed!!",
//                                               "Try again later.");
//                                         }
//                                       }).catchError((error) {
//                                         Utils.handleUpdateApplicationStatus(
//                                             error, context);
//                                       });
//                                     }
//                                   });
//                                 }
//                               },
//                               child: Icon(
//                                 Icons.thumb_up,
//                                 color: Colors.white,
//                               )),
//                         ),
//                         SizedBox(
//                           width: MediaQuery.of(context).size.width * .21,
//                           child: MaterialButton(
//                               elevation: 8,
//                               color: (widget.bookingApplication.status !=
//                                           ApplicationStatus.COMPLETED &&
//                                       widget.bookingApplication.status !=
//                                           ApplicationStatus.CANCELLED)
//                                   ? Colors.green[400]
//                                   : disabledColor,
//                               onPressed: () {
//                                 if (widget.bookingApplication.status !=
//                                         ApplicationStatus.COMPLETED &&
//                                     widget.bookingApplication.status !=
//                                         ApplicationStatus.CANCELLED) {
//                                   showApplicationStatusDialog(
//                                           context,
//                                           "Approve Application",
//                                           'Do you want to proceed with the Approval?',
//                                           approveDialogMsg,
//                                           'Approve')
//                                       .then((remarks) {
//                                     //Update application status change on server.
//                                     if (Utils.isNotNullOrEmpty(remarks)) {
//                                       widget.bookingApplication
//                                           .notesOnApproval = remarks;
//                                       _gs
//                                           .getApplicationService()
//                                           .updateApplicationStatus(
//                                               widget.bookingApplication.id,
//                                               ApplicationStatus.APPROVED,
//                                               remarks,
//                                               metaEntity,
//                                               widget.bookingApplication
//                                                   .preferredSlotTiming)
//                                           .then((value) {
//                                         if (value) {
//                                           setState(() {
//                                             widget.bookingApplication.status =
//                                                 ApplicationStatus.APPROVED;
//                                           });
//                                           Utils.showMyFlushbar(
//                                               context,
//                                               Icons.check,
//                                               Duration(seconds: 2),
//                                               "Application is Approved!!",
//                                               "",
//                                               successGreenSnackBar,
//                                               Colors.white);
//                                         } else {
//                                           print(
//                                               "Could not update application status");
//                                           Utils.showMyFlushbar(
//                                               context,
//                                               Icons.error,
//                                               Duration(seconds: 4),
//                                               "Oops! Application could not be Approved!!",
//                                               tryAgainToBook);
//                                         }
//                                       }).catchError((error) {
//                                         Utils.handleUpdateApplicationStatus(
//                                             error, context);
//                                       });
//                                     }
//                                   });
//                                 }
// //Update application status change on server.
//                               },
//                               child: Icon(
//                                 Icons.check_circle,
//                                 color: Colors.white,
//                               )),
//                         ),
//                         SizedBox(
//                           width: MediaQuery.of(context).size.width * .21,
//                           child: RaisedButton(
//                             color: (widget.bookingApplication.status !=
//                                         ApplicationStatus.COMPLETED &&
//                                     widget.bookingApplication.status !=
//                                         ApplicationStatus.CANCELLED)
//                                 ? Colors.yellow[700]
//                                 : disabledColor,
//                             onPressed: () {
//                               if (widget.bookingApplication.status !=
//                                       ApplicationStatus.COMPLETED &&
//                                   widget.bookingApplication.status !=
//                                       ApplicationStatus.CANCELLED) {
//                                 showApplicationStatusDialog(
//                                         context,
//                                         "On-Hold Application",
//                                         'Are you sure you want to put this Application On-Hold?',
//                                         onHoldDialogMsg,
//                                         'On-Hold')
//                                     .then((remarks) {
//                                   //Update application status change on server.
//                                   if (Utils.isNotNullOrEmpty(remarks)) {
//                                     widget.bookingApplication
//                                         .notesOnPuttingOnHold = remarks;

//                                     _gs
//                                         .getApplicationService()
//                                         .updateApplicationStatus(
//                                             widget.bookingApplication.id,
//                                             ApplicationStatus.ONHOLD,
//                                             remarks,
//                                             metaEntity,
//                                             widget.bookingApplication
//                                                 .preferredSlotTiming)
//                                         .then((value) {
//                                       if (value) {
//                                         setState(() {
//                                           widget.bookingApplication.status =
//                                               ApplicationStatus.ONHOLD;
//                                         });
//                                         Utils.showMyFlushbar(
//                                             context,
//                                             Icons.check,
//                                             Duration(seconds: 2),
//                                             "Application is put on-hold!!",
//                                             "",
//                                             Colors.yellow[700],
//                                             Colors.white);
//                                       } else {
//                                         print(
//                                             "Could not update application status");
//                                         Utils.showMyFlushbar(
//                                             context,
//                                             Icons.error,
//                                             Duration(seconds: 4),
//                                             "Oops! Application could not be put On-Hold!!",
//                                             tryAgainLater);
//                                       }
//                                     }).catchError((error) {
//                                       Utils.handleUpdateApplicationStatus(
//                                           error, context);
//                                     });
//                                   }
//                                 });
//                               }
//                             },
//                             child: Icon(
//                               Icons.pan_tool_rounded,
//                               color: Colors.white,
//                             ),
//                           ),
//                         ),
//                         SizedBox(
//                           width: MediaQuery.of(context).size.width * .21,
//                           child: RaisedButton(
//                             color: (widget.bookingApplication.status !=
//                                         ApplicationStatus.COMPLETED &&
//                                     widget.bookingApplication.status !=
//                                         ApplicationStatus.CANCELLED)
//                                 ? Colors.red
//                                 : disabledColor,
//                             onPressed: () {
//                               if (widget.bookingApplication.status !=
//                                       ApplicationStatus.COMPLETED &&
//                                   widget.bookingApplication.status !=
//                                       ApplicationStatus.CANCELLED) {
//                                 showApplicationStatusDialog(
//                                         context,
//                                         "Confirm Rejection",
//                                         'Are you sure you want to Reject this Application?',
//                                         rejectDialogMsg,
//                                         'Reject')
//                                     .then((remarks) {
//                                   //Update application status change on server.
//                                   if (Utils.isNotNullOrEmpty(remarks)) {
//                                     widget.bookingApplication.notesOnRejection =
//                                         remarks;
//                                     _gs
//                                         .getApplicationService()
//                                         .updateApplicationStatus(
//                                             widget.bookingApplication.id,
//                                             ApplicationStatus.REJECTED,
//                                             remarks,
//                                             metaEntity,
//                                             widget.bookingApplication
//                                                 .preferredSlotTiming)
//                                         .then((value) {
//                                       if (value) {
//                                         setState(() {
//                                           widget.bookingApplication.status =
//                                               ApplicationStatus.REJECTED;
//                                         });
//                                         Utils.showMyFlushbar(
//                                             context,
//                                             Icons.check,
//                                             Duration(seconds: 2),
//                                             "Application is rejected!!",
//                                             "",
//                                             Colors.red,
//                                             Colors.white);
//                                       } else {
//                                         print(
//                                             "Could not update application status");
//                                         Utils.showMyFlushbar(
//                                             context,
//                                             Icons.error,
//                                             Duration(seconds: 4),
//                                             "Oops! Application could not be rejected!!",
//                                             "");
//                                       }
//                                     }).catchError((error) {
//                                       Utils.handleUpdateApplicationStatus(
//                                           error, context);
//                                     });
//                                   }
//                                 });
//                               }
//                             },
//                             child: Icon(
//                               Icons.cancel_rounded,
//                               color: Colors.white,
//                             ),
//                           ),
//                         ),
//                       ],
//                     ),
//                   )
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
