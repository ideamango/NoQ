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
import 'package:noq/pages/show_user_application_details.dart';
import 'package:noq/services/circular_progress.dart';
import 'package:noq/style.dart';
import 'package:noq/userHomePage.dart';
import 'package:noq/utils.dart';
import 'package:noq/widget/appbar.dart';
import 'package:noq/widget/page_animation.dart';
import 'package:noq/widget/widgets.dart';

class UserApplicationsList extends StatefulWidget {
  final BookingApplication ba;

  UserApplicationsList({
    Key key,
    @required this.ba,
  }) : super(key: key);
  @override
  _UserApplicationsListState createState() => _UserApplicationsListState();
}

class _UserApplicationsListState extends State<UserApplicationsList> {
  bool initCompleted = false;
  GlobalState _gs;

  //List<BookingApplication> listOfBa;
  Map<String, TextEditingController> listOfControllers =
      new Map<String, TextEditingController>();

  @override
  void initState() {
    super.initState();
    getGlobalState().whenComplete(() {
      //******gettinmg dummy data -remove this afterwards */
      //  getListOfData();

      // listOfBa = widget.ba;
      if (this.mounted) {
        setState(() {
          initCompleted = true;
        });
      } else
        initCompleted = true;
    });
  }

  Future<void> getGlobalState() async {
    _gs = await GlobalState.getGlobalState();
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
    double cardWidth = MediaQuery.of(context).size.width * .9;
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
            .push(PageAnimation.createRoute(ShowUserApplicationDetails(
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
                child: Row(mainAxisAlignment: MainAxisAlignment.end, children: [
                  SizedBox(
                    width: cardWidth * .15,
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
                                    : (ba.status == ApplicationStatus.APPROVED
                                        ? Colors.green[400]
                                        : Colors.blueGrey))),
                        shape: BoxShape.rectangle,
                        borderRadius: BorderRadius.all(Radius.circular(5.0))),
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
              ),
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
                              width: cardWidth * .14,
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
                              width: cardWidth * .34,
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
                            width: cardWidth * .1,
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
                            width: cardWidth * .1,
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

              // Row(
              //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
              //   children: [
              //     Container(
              //         margin: EdgeInsets.zero,
              //         padding: EdgeInsets.only(left: 8, top: 0),
              //         width: cardWidth * .5,
              //         height: cardHeight * .35,
              //         child: TextFormField(
              //           controller: listOfControllers[ba.id],
              //           style: TextStyle(
              //               fontSize: 12,
              //               color: Colors.blueGrey[700],
              //               fontFamily: 'RalewayRegular'),
              //           decoration: InputDecoration(
              //             labelText: 'Remarks',
              //             enabledBorder: UnderlineInputBorder(
              //                 borderSide: BorderSide(color: Colors.grey)),
              //             focusedBorder: UnderlineInputBorder(
              //                 borderSide: BorderSide(color: Colors.orange)),
              //           ),
              //           maxLines: 2,
              //           keyboardType: TextInputType.text,
              //         )),
              //     Container(
              //       width: cardWidth * .42,
              //       child: Row(
              //         mainAxisAlignment: MainAxisAlignment.spaceBetween,
              //         children: [
              //           IconButton(
              //               alignment: Alignment.bottomCenter,
              //               //    visualDensity: VisualDensity.compact,
              //               padding: const EdgeInsets.fromLTRB(8, 2, 8, 0),
              //               color: Colors.green[400],
              //               onPressed: () {
              //                 ba.notesOnApproval =
              //                     listOfControllers[ba.id].text;
              //                 setState(() {
              //                   ba.status = ApplicationStatus.APPROVED;
              //                 });
              //               },
              //               icon: Icon(
              //                 Icons.check_circle,
              //                 size: 30,
              //               )),
              //           IconButton(
              //             alignment: Alignment.bottomCenter,
              //             //    visualDensity: VisualDensity.compact,
              //             padding: const EdgeInsets.fromLTRB(8, 2, 8, 0),
              //             visualDensity: VisualDensity.compact,

              //             color: Colors.yellow[700],
              //             onPressed: () {
              //               ba.notesOnPuttingOnHold =
              //                   listOfControllers[ba.id].text;
              //               setState(() {
              //                 ba.status = ApplicationStatus.ONHOLD;
              //               });
              //             },
              //             icon: Icon(
              //               Icons.pan_tool_rounded,
              //               size: 30,
              //             ),
              //           ),
              //           IconButton(
              //             // visualDensity: VisualDensity.compact,
              //             alignment: Alignment.bottomCenter,
              //             //    visualDensity: VisualDensity.compact,
              //             padding: const EdgeInsets.fromLTRB(8, 2, 8, 0),
              //             color: Colors.red,
              //             onPressed: () {
              //               ba.notesOnRejection = listOfControllers[ba.id].text;
              //               setState(() {
              //                 ba.status = ApplicationStatus.REJECTED;
              //               });
              //             },
              //             icon: Icon(
              //               Icons.cancel,
              //               size: 30,
              //             ),
              //           ),
              //         ],
              //       ),
              //     ),
              //   ],
              // ),
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
    return Center(child: _buildItem(widget.ba));
  }
}