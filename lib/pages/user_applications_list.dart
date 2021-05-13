import 'package:LESSs/constants.dart';
import 'package:LESSs/db/db_model/user_token.dart';
import 'package:LESSs/services/circular_progress.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:enum_to_string/enum_to_string.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../db/db_model/booking_application.dart';
import '../db/db_model/booking_form.dart';
import '../db/db_model/entity.dart';
import '../db/db_model/meta_entity.dart';
import '../enum/application_status.dart';
import '../enum/field_type.dart';
import '../global_state.dart';
import '../pages/show_user_application_details.dart';
import '../services/qr_code_user_application.dart';
import '../style.dart';
import '../utils.dart';
import '../widget/page_animation.dart';
import '../widget/widgets.dart';

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
  List<UserToken> tokens;
  String entityName;
  DateTime bookingTime;
  @override
  void initState() {
    super.initState();
    getGlobalState().whenComplete(() {
      //get Token details from GS
      if (Utils.isNotNullOrEmpty(widget.ba.tokenId)) {
        List<UserToken> listOfAllTokens = _gs.bookings;
        if (!Utils.isNullOrEmpty(listOfAllTokens)) {
          tokens = [];
          for (var token in listOfAllTokens) {
            if (token.getID() == widget.ba.tokenId) {
              tokens.add(token);
            }
          }
        }
      }
      if (!Utils.isNullOrEmpty(tokens)) {
        entityName = tokens[0].parent.entityName;
        bookingTime = tokens[0].parent.dateTime;
      }
      setState(() {
        initCompleted = true;
      });
    });
  }

  Future<void> getGlobalState() async {
    _gs = await GlobalState.getGlobalState();
  }

  shareQr(MetaEntity metaEntity) {
    Entity en;
    _gs.getEntity(metaEntity.entityId, false).then((value) {
      bool isSavedOnServer = true;
      if (value != null) {
        en = value.item1;
        isSavedOnServer = value.item2;
      }

      if (!isSavedOnServer) {
        Utils.showMyFlushbar(
            context,
            Icons.info,
            Duration(seconds: 4),
            "Important details are missing in entity, Please fill those first.",
            "Save Entity and then Share!!");
      } else
        Navigator.of(context)
            .push(PageAnimation.createRoute(GenerateQrUserApplication(
          uniqueTokenIdentifier: widget.ba.id,
          entityName: metaEntity.name,
          backRoute: "UserAppsList",
        )));
    });
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

  var labelGroup = AutoSizeGroup();
  var responseGroup = AutoSizeGroup();

//   Widget buildChildItem(Field field, BookingApplication ba) {
//     Widget fieldWidget = SizedBox();
//     print(field.label);
//     //Widget fieldsContainer = Container();
//     if (field != null) {
//       switch (field.type) {
//         case FieldType.TEXT:
//           {
//             FormInputFieldText newfield = field;
//             //TODO Smita - Add case if field is isEmail
//             fieldWidget = Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 SizedBox(
//                   //width: cardWidth * .12,
//                   child: AutoSizeText(
//                     newfield.label,
//                     group: labelGroup,
//                     minFontSize: 9,
//                     maxFontSize: 11,
//                     maxLines: 1,
//                     overflow: TextOverflow.clip,
//                     style: TextStyle(
//                         color: Colors.black, fontFamily: 'RalewayRegular'),
//                   ),
//                 ),
//                 horizontalSpacer,
//                 SizedBox(
//                   width: MediaQuery.of(context).size.width * .8,
//                   //height: cardHeight * .1,
//                   child: AutoSizeText(
//                     newfield.response,
//                     group: responseGroup,
//                     minFontSize: 12,
//                     maxFontSize: 14,
//                     maxLines: 2,
//                     overflow: TextOverflow.clip,
//                     style: TextStyle(
//                         fontSize: 14,
//                         color: Colors.indigo[900],
//                         //  fontWeight: FontWeight.bold,
//                         fontFamily: 'Roboto'),
//                   ),
//                 ),
//               ],
//             );
//           }
//           break;
//         case FieldType.NUMBER:
//           {
//             FormInputFieldNumber newfield = field;
//             fieldWidget = Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 SizedBox(
//                   //width: cardWidth * .12,
//                   child: AutoSizeText(
//                     newfield.label,
//                     group: labelGroup,
//                     minFontSize: 9,
//                     maxFontSize: 11,
//                     maxLines: 1,
//                     overflow: TextOverflow.clip,
//                     style: TextStyle(
//                         color: Colors.blueGrey[700],
//                         fontFamily: 'RalewayRegular'),
//                   ),
//                 ),
//                 horizontalSpacer,
//                 SizedBox(
//                   //  width: cardWidth * .4,
//                   //height: cardHeight * .1,
//                   child: AutoSizeText(
//                     newfield.response.toString(),
//                     group: responseGroup,
//                     minFontSize: 12,
//                     maxFontSize: 14,
//                     maxLines: 1,
//                     overflow: TextOverflow.clip,
//                     style: TextStyle(
//                         fontSize: 14,
//                         color: Colors.indigo[900],
//                         // fontWeight: FontWeight.bold,
//                         fontFamily: 'Roboto'),
//                   ),
//                 ),
//               ],
//             );
//           }
//           break;
//         case FieldType.PHONE:
//           {
//             FormInputFieldPhone newfield = field;
//             fieldWidget = Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 SizedBox(
//                   //width: cardWidth * .12,
//                   child: AutoSizeText(
//                     newfield.label,
//                     group: labelGroup,
//                     minFontSize: 9,
//                     maxFontSize: 11,
//                     maxLines: 1,
//                     overflow: TextOverflow.clip,
//                     style: TextStyle(
//                         color: Colors.blueGrey[700],
//                         fontFamily: 'RalewayRegular'),
//                   ),
//                 ),
//                 horizontalSpacer,
//                 SizedBox(
//                   //  width: cardWidth * .4,
//                   //height: cardHeight * .1,
//                   child: AutoSizeText(
//                     "+91 ${newfield.responsePhone.toString()}",
//                     group: responseGroup,
//                     minFontSize: 12,
//                     maxFontSize: 14,
//                     maxLines: 1,
//                     overflow: TextOverflow.clip,
//                     style: TextStyle(
//                         color: Colors.indigo[900],
//                         //fontWeight: FontWeight.bold,
//                         fontFamily: 'Roboto'),
//                   ),
//                 ),
//               ],
//             );
//           }
//           break;

//         case FieldType.DATETIME:
//           {
//             FormInputFieldDateTime newfield = field;
//             //TODO Smita - Add case if field is Age
//             fieldWidget = Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 SizedBox(
//                   //width: cardWidth * .12,
//                   child: AutoSizeText(
//                     newfield.label,
//                     group: labelGroup,
//                     minFontSize: 9,
//                     maxFontSize: 11,
//                     maxLines: 1,
//                     overflow: TextOverflow.clip,
//                     style: TextStyle(
//                         color: Colors.black, fontFamily: 'RalewayRegular'),
//                   ),
//                 ),
//                 // horizontalSpacer,
//                 SizedBox(
//                   //  width: cardWidth * .4,
//                   //height: cardHeight * .1,
//                   child: AutoSizeText(
//                     DateFormat('dd-MM-yyyy')
//                         .format(newfield.responseDateTime)
//                         .toString(),
//                     group: responseGroup,
//                     minFontSize: 12,
//                     maxFontSize: 14,
//                     maxLines: 1,
//                     overflow: TextOverflow.clip,
//                     style: TextStyle(
//                         color: Colors.indigo[900], fontFamily: 'Roboto'),
//                   ),
//                 ),
//               ],
//             );
//           }
//           break;
//         case FieldType.OPTIONS:
//           {
//             FormInputFieldOptions newfield = field;
//             //If field is multi-select then concatenate responses and show.

//             String responseVals;
//             for (Value val in newfield.responseValues) {
//               if (!Utils.isNotNullOrEmpty(responseVals)) responseVals = "";
//               responseVals = responseVals + val.value.toString();
//             }

//             fieldWidget = Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 SizedBox(
//                   //width: cardWidth * .12,
//                   child: AutoSizeText(
//                     newfield.label,
//                     group: labelGroup,
//                     minFontSize: 9,
//                     maxFontSize: 11,
//                     maxLines: 1,
//                     overflow: TextOverflow.clip,
//                     style: TextStyle(
//                         color: Colors.blueGrey[700],
//                         fontFamily: 'RalewayRegular'),
//                   ),
//                 ),
//                 // horizontalSpacer,
//                 SizedBox(
//                   //  width: cardWidth * .4,
//                   //height: cardHeight * .1,
//                   child: AutoSizeText(
//                     responseVals,
//                     group: responseGroup,
//                     minFontSize: 12,
//                     maxFontSize: 14,
//                     maxLines: 1,
//                     overflow: TextOverflow.clip,
//                     style: TextStyle(
//                         fontSize: 14,
//                         color: Colors.indigo[900],
//                         fontFamily: 'Roboto'),
//                   ),
//                 ),
//               ],
//             );
//           }
//           break;
//         case FieldType.OPTIONS_ATTACHMENTS:
//           {
//             FormInputFieldOptionsWithAttachments newfield = field;
//             String responseVals;
//             for (Value val in newfield.responseValues) {
//               if (!Utils.isNotNullOrEmpty(responseVals)) {
//                 responseVals = "";
//               }
//               if (responseVals == "")
//                 responseVals = responseVals + val.value.toString();
//               else
//                 responseVals = responseVals + " | " + val.value.toString();
//             }

//             //  responseVals = newfield.responseValues.toString();

//             fieldWidget = Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   mainAxisAlignment: MainAxisAlignment.start,
//                   children: [
//                     SizedBox(
//                       //width: cardWidth * .12,
//                       child: AutoSizeText(
//                         newfield.label,
//                         group: labelGroup,
//                         minFontSize: 9,
//                         maxFontSize: 11,
//                         maxLines: 1,
//                         overflow: TextOverflow.clip,
//                         style: TextStyle(
//                             color: Colors.black, fontFamily: 'RalewayRegular'),
//                       ),
//                     ),
//                     Row(
//                       children: [
//                         SizedBox(
//                           width: MediaQuery.of(context).size.width * .8,
//                           //height: cardHeight * .1,
//                           child: AutoSizeText(
//                             (responseVals != null) ? responseVals : "None",
//                             group: responseGroup,
//                             minFontSize: 12,
//                             maxFontSize: 14,
//                             maxLines: 3,
//                             overflow: TextOverflow.clip,
//                             style: TextStyle(
//                                 color: Colors.indigo[900],
//                                 fontFamily: 'Roboto'),
//                           ),
//                         ),
//                         //horizontalSpacer,
//                         // IconButton(
//                         //   icon: Icon(
//                         //     Icons.attach_file,
//                         //     size: 14,
//                         //   ),
//                         //   onPressed: () {
//                         //     print("Pressed");
//                         //   },
//                         // )
//                       ],
//                     ),
//                   ],
//                 ),
//                 IconButton(
//                     padding: EdgeInsets.all(0),
//                     splashColor: highlightColor,
//                     constraints: BoxConstraints(
//                       maxHeight: 25,
//                       maxWidth: 25,
//                     ),
//                     icon: Icon(
//                       Icons.attach_file,
//                       color: Colors.blueGrey[600],
//                     ),
//                     onPressed: () {
//                       Navigator.of(context).push(
//                           PageAnimation.createRoute(ShowUserApplicationDetails(
//                         bookingApplication: ba,
//                         isAdmin: false,
//                       )));
//                     })
//               ],
//             );
//           }
//           break;
//         default:
//           {
//             // fieldWidget = Text("Could not fetch data");
//           }
//           break;
//       }
//     }
//     return fieldWidget;
//   }

//   Widget buildChildItem(Field field) {
//     var labelGroup = AutoSizeGroup();
//     return Card(
//       elevation: 5,
//       child: SingleChildScrollView(
//         physics: ScrollPhysics(),
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//           children: [
//             Padding(
//               padding: const EdgeInsets.fromLTRB(8, 10, 8, 4),
//               child: Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                   children: [
//                     GestureDetector(
//                       onTap: () {
//                         Navigator.of(context).push(PageAnimation.createRoute(
//                             ShowUserApplicationDetails(
//                           bookingApplication: widget.ba,
//                           isAdmin: false,
//                         )));
//                       },
//                       child: Container(
//                         child: Text("View details..",
//                             style: TextStyle(color: Colors.blue, fontSize: 12)),
//                       ),
//                     ),
//                     Container(
//                       padding: EdgeInsets.all(2),
//                       margin: EdgeInsets.all(0),
//                       decoration: BoxDecoration(
//                           color: (widget.ba.status == ApplicationStatus.NEW)
//                               ? Colors.blue
//                               : (widget.ba.status == ApplicationStatus.ONHOLD
//                                   ? Colors.yellow[700]
//                                   : (widget.ba.status ==
//                                           ApplicationStatus.REJECTED
//                                       ? Colors.red
//                                       : (widget.ba.status ==
//                                               ApplicationStatus.APPROVED
//                                           ? Colors.green[400]
//                                           : (widget.ba.status ==
//                                                   ApplicationStatus.COMPLETED
//                                               ? Colors.purple
//                                               : Colors.blueGrey)))),
//                           shape: BoxShape.rectangle,
//                           borderRadius: BorderRadius.all(Radius.circular(5.0))),
//                       child: SizedBox(
//                         // width: cardWidth * .2,
//                         // height: cardHeight * .11,
//                         child: Center(
//                           child: AutoSizeText(
//                               EnumToString.convertToString(widget.ba.status),
//                               textAlign: TextAlign.center,
//                               minFontSize: 7,
//                               maxFontSize: 9,
//                               style: TextStyle(
//                                   fontSize: 9,
//                                   fontWeight: FontWeight.bold,
//                                   letterSpacing: 1,
//                                   color: Colors.white,
//                                   fontFamily: 'RalewayRegular')),
//                         ),
//                       ),
//                     ),
//                   ]),
//             ),

//             ListView.builder(
//               itemCount: listOfMeta.length,
//               physics: NeverScrollableScrollPhysics(),
//               shrinkWrap: true,
//               // reverse: true,
//               itemBuilder: (BuildContext context, int index) {
//                 return Container(
//                   padding: EdgeInsets.fromLTRB(10, 5, 10, 5),
//                   margin: EdgeInsets.zero,
//                   // margin: EdgeInsets.fromLTRB(10, 10, 10, 0),
//                   child: new Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       //  Text('dfhgd'),
//                       buildChildItem(listOfMeta[index], widget.ba)
//                     ],
//                   ),
//                 );
//               },
//             ),
//             // SizedBox(
//             //   width: cardWidth * .9,
//             //   height: cardHeight * .4,
//             // ),
//             Container(
//               padding: EdgeInsets.fromLTRB(10, 5, 10, 5),
//               margin: EdgeInsets.zero,
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 mainAxisAlignment: MainAxisAlignment.start,
//                 children: [
//                   Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     mainAxisAlignment: MainAxisAlignment.start,
//                     children: [
//                       SizedBox(
//                           // width: cardWidth * .45,
//                           child: Wrap(
//                         children: [
//                           AutoSizeText(
//                             "Current time-slot",
//                             group: labelGroup,
//                             minFontSize: 9,
//                             maxFontSize: 11,
//                             maxLines: 1,
//                             overflow: TextOverflow.clip,
//                             style: TextStyle(
//                                 color: Colors.black,
//                                 fontFamily: 'RalewayRegular'),
//                           ),
//                         ],
//                       )),
//                       Wrap(children: [
//                         Container(
//                           padding: EdgeInsets.all(0),
//                           child: AutoSizeText(
//                             ((widget.ba.preferredSlotTiming != null)
//                                 ? DateFormat('yyyy-MM-dd – kk:mm')
//                                     .format(widget.ba.preferredSlotTiming)
//                                 : "None"),
//                             // group: medCondGroup,
//                             minFontSize: 12,
//                             maxFontSize: 14,
//                             maxLines: 1,
//                             overflow: TextOverflow.clip,
//                             style: TextStyle(
//                                 fontSize: 14,
//                                 color: Colors.indigo[900],
//                                 //  fontWeight: FontWeight.bold,
//                                 fontFamily: 'Roboto'),
//                           ),
//                         ),
//                       ]),
//                     ],
//                   ),
//                 ],
//               ),
//             ),

//             // Row(
//             //   //  mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             //   children: [
//             //     Container(
//             //         margin: EdgeInsets.zero,
//             //         padding: EdgeInsets.fromLTRB(8, 0, 0, 0),
//             //         width: cardWidth * .9,
//             //         height: cardHeight * .2,
//             //         child: TextFormField(
//             //           controller: listOfControllers[widget.ba.id],
//             //           readOnly: (widget.ba.status ==
//             //                       ApplicationStatus.COMPLETED ||
//             //                   widget.ba.status == ApplicationStatus.CANCELLED)
//             //               ? true
//             //               : false,
//             //           style: TextStyle(
//             //               fontSize: 15,
//             //               color: Colors.black,
//             //               fontFamily: 'RalewayRegular'),
//             //           decoration: InputDecoration(
//             //             labelText: 'Remarks',
//             //             enabledBorder: UnderlineInputBorder(
//             //                 borderSide: BorderSide(color: Colors.grey)),
//             //             focusedBorder: UnderlineInputBorder(
//             //                 borderSide: BorderSide(color: Colors.orange)),
//             //           ),
//             //           maxLines: 1,
//             //           keyboardType: TextInputType.text,
//             //         )),
//             //   ],
//             // ),
// //             Row(
// //               mainAxisAlignment: MainAxisAlignment.end,
// //               children: [
// //                 Container(
// //                   width: cardWidth * .6,
// //                   child: Row(
// //                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
// //                     children: [
// //                       IconButton(
// //                           alignment: Alignment.center,
// //                           //    visualDensity: VisualDensity.compact,
// //                           padding: const EdgeInsets.fromLTRB(8, 2, 8, 0),
// //                           color: (widget.ba.status !=
// //                                       ApplicationStatus.COMPLETED &&
// //                                   widget.ba.status !=
// //                                       ApplicationStatus.CANCELLED)
// //                               ? Colors.purple[400]
// //                               : disabledColor,
// //                           onPressed: () {
// //                             if (widget.ba.status !=
// //                                     ApplicationStatus.COMPLETED &&
// //                                 widget.ba.status !=
// //                                     ApplicationStatus.CANCELLED) {
// //                               widget.ba.notesOnApproval =
// //                                   listOfControllers[widget.ba.id].text;
// //                               _gs
// //                                   .getApplicationService()
// //                                   .updateApplicationStatus(
// //                                       widget.ba.id,
// //                                       ApplicationStatus.COMPLETED,
// //                                       listOfControllers[widget.ba.id].text,
// //                                       widget.metaEntity,
// //                                       widget.ba.preferredSlotTiming)
// //                                   .then((value) {
// //                                 if (value) {
// //                                   setState(() {
// //                                     widget.ba.status =
// //                                         ApplicationStatus.COMPLETED;
// //                                   });
// //                                   Utils.showMyFlushbar(
// //                                       context,
// //                                       Icons.check,
// //                                       Duration(seconds: 2),
// //                                       "Application is marked completed!!",
// //                                       "",
// //                                       Colors.purple[400],
// //                                       Colors.white);
// //                                 } else {
// //                                   print("Could not update application");
// //                                   Utils.showMyFlushbar(
// //                                       context,
// //                                       Icons.error,
// //                                       Duration(seconds: 4),
// //                                       "Oops! Application could not be marked Completed!!",
// //                                       "Try again later.");
// //                                 }
// //                               }).catchError((error) {
// //                                 print(error.toString());
// //                                 print("Error in token booking" +
// //                                     error.toString());

// //                                 Utils.showMyFlushbar(
// //                                     context,
// //                                     Icons.error,
// //                                     Duration(seconds: 5),
// //                                     "Oops! Application could not be marked Completed!!",
// //                                     tryAgainLater);
// //                               });
// //                             }
// // //Update application status change on server.
// //                           },
// //                           icon: Icon(
// //                             Icons.thumb_up,
// //                             size: 30,
// //                           )),
// //                       IconButton(
// //                           alignment: Alignment.center,
// //                           //    visualDensity: VisualDensity.compact,
// //                           padding: const EdgeInsets.fromLTRB(8, 2, 8, 0),
// //                           color: (widget.ba.status !=
// //                                       ApplicationStatus.COMPLETED &&
// //                                   widget.ba.status !=
// //                                       ApplicationStatus.CANCELLED)
// //                               ? Colors.green[400]
// //                               : disabledColor,
// //                           onPressed: () {
// //                             if (widget.ba.status !=
// //                                     ApplicationStatus.COMPLETED &&
// //                                 widget.ba.status !=
// //                                     ApplicationStatus.CANCELLED) {
// //                               widget.ba.notesOnApproval =
// //                                   listOfControllers[widget.ba.id].text;
// //                               _gs
// //                                   .getApplicationService()
// //                                   .updateApplicationStatus(
// //                                       widget.ba.id,
// //                                       ApplicationStatus.APPROVED,
// //                                       listOfControllers[widget.ba.id].text,
// //                                       widget.metaEntity,
// //                                       widget.ba.preferredSlotTiming)
// //                                   .then((value) {
// //                                 if (value) {
// //                                   setState(() {
// //                                     widget.ba.status =
// //                                         ApplicationStatus.APPROVED;
// //                                   });
// //                                   Utils.showMyFlushbar(
// //                                       context,
// //                                       Icons.check,
// //                                       Duration(seconds: 2),
// //                                       "Application is Approved!!",
// //                                       "",
// //                                       Colors.green,
// //                                       Colors.white);
// //                                 } else {
// //                                   print("Could not update application status");
// //                                   Utils.showMyFlushbar(
// //                                       context,
// //                                       Icons.error,
// //                                       Duration(seconds: 4),
// //                                       "Oops! Application could not be Approved!!",
// //                                       tryAgainToBook);
// //                                 }
// //                               }).catchError((error) {
// //                                 print(error.toString());
// //                                 print("Error in token booking" +
// //                                     error.toString());

// //                                 if (error is SlotFullException) {
// //                                   Utils.showMyFlushbar(
// //                                       context,
// //                                       Icons.error,
// //                                       Duration(seconds: 5),
// //                                       slotsAlreadyBooked,
// //                                       tryAgainToBook);
// //                                 } else {
// //                                   Utils.showMyFlushbar(
// //                                       context,
// //                                       Icons.error,
// //                                       Duration(seconds: 5),
// //                                       error.toString(),
// //                                       tryAgainToBook);
// //                                 }
// //                               });
// //                             }
// // //Update application status change on server.
// //                           },
// //                           icon: Icon(
// //                             Icons.check_circle,
// //                             size: 30,
// //                           )),
// //                       IconButton(
// //                         alignment: Alignment.center,
// //                         //    visualDensity: VisualDensity.compact,
// //                         padding: const EdgeInsets.fromLTRB(8, 2, 8, 0),
// //                         visualDensity: VisualDensity.compact,

// //                         color: (widget.ba.status !=
// //                                     ApplicationStatus.COMPLETED &&
// //                                 widget.ba.status != ApplicationStatus.CANCELLED)
// //                             ? Colors.yellow[700]
// //                             : disabledColor,
// //                         onPressed: () {
// //                           if (widget.ba.status != ApplicationStatus.COMPLETED &&
// //                               widget.ba.status != ApplicationStatus.CANCELLED) {
// //                             widget.ba.notesOnPuttingOnHold =
// //                                 listOfControllers[widget.ba.id].text;

// //                             _gs
// //                                 .getApplicationService()
// //                                 .updateApplicationStatus(
// //                                     widget.ba.id,
// //                                     ApplicationStatus.ONHOLD,
// //                                     listOfControllers[widget.ba.id].text,
// //                                     widget.metaEntity,
// //                                     widget.ba.preferredSlotTiming)
// //                                 .then((value) {
// //                               if (value) {
// //                                 setState(() {
// //                                   widget.ba.status = ApplicationStatus.ONHOLD;
// //                                 });
// //                                 Utils.showMyFlushbar(
// //                                     context,
// //                                     Icons.check,
// //                                     Duration(seconds: 2),
// //                                     "Application is put on-hold!!",
// //                                     "",
// //                                     Colors.yellow[700],
// //                                     Colors.white);
// //                               } else {
// //                                 print("Could not update application status");
// //                                 Utils.showMyFlushbar(
// //                                     context,
// //                                     Icons.error,
// //                                     Duration(seconds: 4),
// //                                     "Oops! Application could not be put On-Hold!!",
// //                                     tryAgainLater);
// //                               }
// //                             }).catchError((error) {
// //                               print(error.toString());
// //                               print(
// //                                   "Error in token booking" + error.toString());

// //                               Utils.showMyFlushbar(
// //                                   context,
// //                                   Icons.error,
// //                                   Duration(seconds: 5),
// //                                   "Oops! Application could not be put On-Hold!!",
// //                                   tryAgainLater);
// //                             });
// //                           }
// //                         },
// //                         icon: Icon(
// //                           Icons.pan_tool_rounded,
// //                           size: 28,
// //                         ),
// //                       ),
// //                       IconButton(
// //                         // visualDensity: VisualDensity.compact,
// //                         alignment: Alignment.center,
// //                         //    visualDensity: VisualDensity.compact,
// //                         padding: const EdgeInsets.fromLTRB(8, 2, 8, 0),
// //                         color: (widget.ba.status !=
// //                                     ApplicationStatus.COMPLETED &&
// //                                 widget.ba.status != ApplicationStatus.CANCELLED)
// //                             ? Colors.red
// //                             : disabledColor,
// //                         onPressed: () {
// //                           if (widget.ba.status != ApplicationStatus.COMPLETED &&
// //                               widget.ba.status != ApplicationStatus.CANCELLED) {
// //                             widget.ba.notesOnRejection =
// //                                 listOfControllers[widget.ba.id].text;
// //                             _gs
// //                                 .getApplicationService()
// //                                 .updateApplicationStatus(
// //                                     widget.ba.id,
// //                                     ApplicationStatus.REJECTED,
// //                                     listOfControllers[widget.ba.id].text,
// //                                     widget.metaEntity,
// //                                     widget.ba.preferredSlotTiming)
// //                                 .then((value) {
// //                               if (value) {
// //                                 setState(() {
// //                                   widget.ba.status = ApplicationStatus.REJECTED;
// //                                 });
// //                                 Utils.showMyFlushbar(
// //                                     context,
// //                                     Icons.check,
// //                                     Duration(seconds: 2),
// //                                     "Application is rejected!!",
// //                                     "",
// //                                     Colors.red,
// //                                     Colors.white);
// //                               } else {
// //                                 print("Could not update application status");
// //                                 Utils.showMyFlushbar(
// //                                     context,
// //                                     Icons.error,
// //                                     Duration(seconds: 4),
// //                                     "Oops! Application could not be rejected!!",
// //                                     "");
// //                               }
// //                             }).catchError((error) {
// //                               print(error.toString());
// //                               print(
// //                                   "Error in token booking" + error.toString());

// //                               Utils.showMyFlushbar(
// //                                   context,
// //                                   Icons.error,
// //                                   Duration(seconds: 5),
// //                                   "Oops! Application could not be rejected!!",
// //                                   tryAgainLater);
// //                             });
// //                           }
// //                         },
// //                         icon: Icon(
// //                           Icons.cancel,
// //                           size: 30,
// //                         ),
// //                       ),
// //                     ],
// //                   ),
// //                 ),
// //               ],
// //             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildItem(BookingApplication ba) {
//     List<Field> listOfMeta = new List<Field>();
//     if (!listOfControllers.containsKey(widget.ba.id)) {
//       listOfControllers[widget.ba.id] = new TextEditingController();
//     }

//     String name;
//     String age;
//     bool isFrontlineWorker = false;
//     String fwImg1;

//     bool isMedicalMorbidities = false;

//     String medConds;
//     TextEditingController notesController = new TextEditingController();

//     listOfMeta.addAll(ba.responseForm
//         .getFormFields()
//         .where((element) => element.isMeta == true));

//     for (var element in listOfMeta) {
//       switch (element.type) {
//         case FieldType.TEXT:
//           name = (element as FormInputFieldText).response;
//           break;
//         case FieldType.DATETIME:
//           FormInputFieldDateTime newfield = element;
//           age = ((DateTime.now().difference(newfield.responseDateTime).inDays) /
//                   365)
//               .toStringAsFixed(0);
//           break;
//         case FieldType.OPTIONS_ATTACHMENTS:
//           FormInputFieldOptionsWithAttachments newfield = element;
//           isMedicalMorbidities = !Utils.isNullOrEmpty(newfield.responseValues);
//           if (isMedicalMorbidities) {
//             for (Value val in newfield.responseValues) {
//               if (!Utils.isNotNullOrEmpty(medConds)) {
//                 medConds = "";
//               }
//               if (medConds == "")
//                 medConds = medConds + val.value.toString();
//               else
//                 medConds = medConds + " | " + val.value.toString();
//             }
//             // mbImg1 = newfield.responseValues[0].value;
//             // if (newfield.responseValues.length > 1)
//             //   mbImg2 = newfield.responseValues[1].value;
//           }
//           break;
//         case FieldType.PHONE:
//           break;
//         case FieldType.NUMBER:
//           {}
//           break;
//         case FieldType.OPTIONS:
//           {}
//           break;
//         case FieldType.ATTACHMENT:
//           {}
//           break;

//         default:
//           name = (element as FormInputFieldText).response;
//           break;
//       }
//     }

//     double cardHeight = MediaQuery.of(context).size.height * .18;
//     double cardWidth = MediaQuery.of(context).size.width * .9;
//     var medCondGroup = AutoSizeGroup();
//     var labelGroup = AutoSizeGroup();
//     Iterable<String> autoHints = [
//       "Documents Incomplete",
//       "Not priority now",
//       "No Slots available"
//     ];

//     // String medConds =
//     //    Utils.isNotNullOrEmpty(mbImg1)? mbImg1 + (Utils.isNotNullOrEmpty(mbImg2) ? " & $mbImg2" : "");

//     return GestureDetector(
//       onTap: () {
//         Navigator.of(context)
//             .push(PageAnimation.createRoute(ShowUserApplicationDetails(
//           bookingApplication: ba,
//           isAdmin: false,
//         )));
//       },
//       child: Container(
//         //  height: MediaQuery.of(context).size.height * .9,
//         child: Scrollbar(
//           child: SingleChildScrollView(
//             padding: EdgeInsets.all(MediaQuery.of(context).size.width * .01),
//             child: Column(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 Row(
//                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Container(
//                         padding: EdgeInsets.all(0),
//                         margin: EdgeInsets.all(0),
//                         height: cardWidth * .1,
//                         width: cardWidth * .1,
//                         child: IconButton(
//                             padding: EdgeInsets.fromLTRB(0, 0, 0, 0),
//                             alignment: Alignment.topLeft,
//                             highlightColor: Colors.orange[300],
//                             icon: ImageIcon(
//                               AssetImage('assets/qrcode.png'),
//                               size: 25,
//                               color: primaryIcon,
//                             ),
//                             onPressed: () {
//                               print(widget.ba.entityId);
//                               Navigator.of(context).push(
//                                   PageAnimation.createRoute(
//                                       GenerateQrUserApplication(
//                                 entityName: "Application QR code",
//                                 backRoute: "UserAppsList",
//                                 uniqueTokenIdentifier: widget.ba.id,
//                               )));
//                             }),
//                       ),
//                       SizedBox(
//                         width: cardWidth * .55,
//                         child: AutoSizeText(
//                           "${widget.ba.entityId} \n ${widget.ba.responseForm.formName}",
//                           group: labelGroup,
//                           textAlign: TextAlign.center,
//                           minFontSize: 9,
//                           maxFontSize: 12,
//                           maxLines: 2,
//                           overflow: TextOverflow.clip,
//                           style: TextStyle(
//                             color: Colors.blueGrey[900],
//                           ),
//                         ),
//                       ),
//                       Container(
//                         padding: EdgeInsets.all(2),
//                         margin: EdgeInsets.all(0),
//                         decoration: BoxDecoration(
//                             color: (widget.ba.status == ApplicationStatus.NEW)
//                                 ? Colors.blue
//                                 : (widget.ba.status == ApplicationStatus.ONHOLD
//                                     ? Colors.yellow[700]
//                                     : (widget.ba.status ==
//                                             ApplicationStatus.REJECTED
//                                         ? Colors.red
//                                         : (widget.ba.status ==
//                                                 ApplicationStatus.APPROVED
//                                             ? Colors.green[400]
//                                             : Colors.blueGrey))),
//                             shape: BoxShape.rectangle,
//                             borderRadius:
//                                 BorderRadius.all(Radius.circular(5.0))),
//                         child: SizedBox(
//                           width: cardWidth * .2,
//                           height: cardHeight * .11,
//                           child: Center(
//                             child: AutoSizeText(
//                                 EnumToString.convertToString(widget.ba.status),
//                                 textAlign: TextAlign.center,
//                                 minFontSize: 6,
//                                 maxFontSize: 8,
//                                 style: TextStyle(
//                                     fontWeight: FontWeight.bold,
//                                     letterSpacing: 1,
//                                     color: Colors.white,
//                                     fontFamily: 'Monsterrat')),
//                           ),
//                         ),
//                       ),
//                     ]),
//                 // //Logic for auto-creating fields from booking al\pplication goes here.
//                 ListView.builder(
//                   itemCount: listOfMeta.length,
//                   physics: NeverScrollableScrollPhysics(),
//                   shrinkWrap: true,
//                   // reverse: true,
//                   itemBuilder: (BuildContext context, int index) {
//                     return Container(
//                       padding: EdgeInsets.fromLTRB(10, 5, 10, 5),
//                       margin: EdgeInsets.zero,
//                       // margin: EdgeInsets.fromLTRB(10, 10, 10, 0),
//                       child: new Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           //  Text('dfhgd'),
//                           buildChildItem(listOfMeta[index])
//                         ],
//                       ),
//                     );
//                   },
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }

  @override
  void dispose() {
    super.dispose();
  }

  Widget buildChildItem(Field field, BookingApplication ba) {
    Widget fieldWidget = SizedBox();
    print(field.label);
    //Widget fieldsContainer = Container();
    if (field != null) {
      switch (field.type) {
        case FieldType.TEXT:
          {
            FormInputFieldText newfield = field;
            //TODO Smita - Add case if field is isEmail
            fieldWidget = Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  //width: cardWidth * .12,
                  child: AutoSizeText(
                    newfield.label,
                    group: labelGroup,
                    minFontSize: 9,
                    maxFontSize: 11,
                    maxLines: 1,
                    overflow: TextOverflow.clip,
                    style: TextStyle(color: Colors.black, fontFamily: 'Roboto'),
                  ),
                ),
                horizontalSpacer,
                SizedBox(
                  width: MediaQuery.of(context).size.width * .8,
                  //height: cardHeight * .1,
                  child: AutoSizeText(
                    newfield.response,
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
        case FieldType.NUMBER:
          {
            FormInputFieldNumber newfield = field;
            fieldWidget = Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  //width: cardWidth * .12,
                  child: AutoSizeText(
                    newfield.label,
                    group: labelGroup,
                    minFontSize: 9,
                    maxFontSize: 11,
                    maxLines: 1,
                    overflow: TextOverflow.clip,
                    style: TextStyle(
                        color: Colors.blueGrey[700], fontFamily: 'Roboto'),
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
            FormInputFieldPhone newfield = field;
            fieldWidget = Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  //width: cardWidth * .12,
                  child: AutoSizeText(
                    newfield.label,
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
            FormInputFieldDateTime newfield = field;
            //TODO Smita - Add case if field is Age
            fieldWidget = Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  //width: cardWidth * .12,
                  child: AutoSizeText(
                    newfield.label,
                    group: labelGroup,
                    minFontSize: 9,
                    maxFontSize: 11,
                    maxLines: 1,
                    overflow: TextOverflow.clip,
                    style: TextStyle(
                        color: Colors.black, fontFamily: 'RalewayRegular'),
                  ),
                ),
                // horizontalSpacer,
                SizedBox(
                  //  width: cardWidth * .4,
                  //height: cardHeight * .1,
                  child: AutoSizeText(
                    DateFormat('dd-MM-yyyy')
                        .format(newfield.responseDateTime)
                        .toString(),
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
            FormInputFieldOptions newfield = field;
            //If field is multi-select then concatenate responses and show.

            String responseVals;
            for (Value val in newfield.responseValues) {
              if (!Utils.isNotNullOrEmpty(responseVals)) responseVals = "";
              responseVals = responseVals + val.value.toString();
            }

            fieldWidget = Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  //width: cardWidth * .12,
                  child: AutoSizeText(
                    newfield.label,
                    group: labelGroup,
                    minFontSize: 9,
                    maxFontSize: 11,
                    maxLines: 1,
                    overflow: TextOverflow.clip,
                    style: TextStyle(color: Colors.black, fontFamily: 'Roboto'),
                  ),
                ),
                // horizontalSpacer,
                SizedBox(
                  //  width: cardWidth * .4,
                  //height: cardHeight * .1,
                  child: AutoSizeText(
                    responseVals,
                    group: responseGroup,
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
            );
          }
          break;
        case FieldType.OPTIONS_ATTACHMENTS:
          {
            FormInputFieldOptionsWithAttachments newfield = field;
            String responseVals;
            for (Value val in newfield.responseValues) {
              if (!Utils.isNotNullOrEmpty(responseVals)) {
                responseVals = "";
              }
              if (responseVals == "")
                responseVals = responseVals + val.value.toString();
              else
                responseVals = responseVals + " | " + val.value.toString();
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
                        newfield.label,
                        group: labelGroup,
                        minFontSize: 9,
                        maxFontSize: 11,
                        maxLines: 1,
                        overflow: TextOverflow.clip,
                        style: TextStyle(
                            color: Colors.black, fontFamily: 'RalewayRegular'),
                      ),
                    ),
                    Row(
                      children: [
                        SizedBox(
                          width: MediaQuery.of(context).size.width * .7,
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
                IconButton(
                    padding: EdgeInsets.all(0),
                    splashColor: highlightColor,
                    constraints: BoxConstraints(
                      maxHeight: 25,
                      maxWidth: 25,
                    ),
                    icon: Icon(
                      Icons.attach_file,
                      color: Colors.blueGrey[600],
                    ),
                    onPressed: () {
                      Navigator.of(context).push(
                          PageAnimation.createRoute(ShowUserApplicationDetails(
                        bookingApplication: ba,
                        isAdmin: false,
                      )));
                    })
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

  Future<bool> cancelBooking(BuildContext context) async {
    bool cancelVal = await showDialog(
        barrierDismissible: false,
        context: context,
        builder: (_) => AlertDialog(
              titlePadding: EdgeInsets.fromLTRB(10, 15, 10, 10),
              contentPadding: EdgeInsets.all(0),
              actionsPadding: EdgeInsets.all(5),
              //buttonPadding: EdgeInsets.all(0),
              title: Container(
                width: MediaQuery.of(context).size.width,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      "Do you really want to CANCEL this Application?",
                      style: TextStyle(
                        fontSize: 15,
                        color: Colors.blueGrey[600],
                      ),
                    ),
                    verticalSpacer,
                    // myDivider,
                  ],
                ),
              ),
              content: Container(
                width: MediaQuery.of(context).size.width,
                child: Divider(
                  color: Colors.blueGrey[400],
                  height: 1,
                  //indent: 40,
                  //endIndent: 30,
                ),
              ),

              //content: Text('This is my content'),
              actions: <Widget>[
                SizedBox(
                  height: 24,
                  child: FlatButton(
                    color: Colors.transparent,
                    splashColor: highlightColor.withOpacity(.8),
                    textColor: Colors.orange,
                    shape: RoundedRectangleBorder(
                        side: BorderSide(color: Colors.orange)),
                    child: Text('Yes'),
                    onPressed: () {
                      Navigator.of(_).pop(true);
                    },
                  ),
                ),
                SizedBox(
                  height: 24,
                  child: FlatButton(
                    // elevation: 20,
                    autofocus: true,
                    focusColor: highlightColor,
                    splashColor: highlightColor,
                    color: Colors.white,
                    textColor: Colors.orange,
                    shape: RoundedRectangleBorder(
                        side: BorderSide(color: Colors.orange)),
                    child: Text('No'),
                    onPressed: () {
                      Navigator.of(_).pop(false);
                    },
                  ),
                ),
              ],
            ));

    return cancelVal;
  }

  Widget _buildItem(BookingApplication ba) {
    List<Field> listOfMeta = new List<Field>();
    if (!listOfControllers.containsKey(ba.id)) {
      listOfControllers[ba.id] = new TextEditingController();
    }

    listOfMeta.addAll(ba.responseForm
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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: MediaQuery.of(context).size.width * .9,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    alignment: Alignment.center,
                    margin: EdgeInsets.all(5),
                    width: double.infinity,
                    child: AutoSizeText(
                      ba.entityName,
                      minFontSize: 10,
                      maxFontSize: 16,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(),
                    ),
                  ),
                  Text(ba.responseForm.formName)
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 10, 8, 4),
              child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    GestureDetector(
                      onTap: () {
                        Navigator.of(context).push(PageAnimation.createRoute(
                            ShowUserApplicationDetails(
                          bookingApplication: ba,
                          isAdmin: false,
                        )));
                      },
                      child: Container(
                        child: Text("View details..",
                            style: TextStyle(color: Colors.blue, fontSize: 12)),
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
                                          : (ba.status ==
                                                  ApplicationStatus.COMPLETED
                                              ? Colors.purple
                                              : Colors.blueGrey)))),
                          shape: BoxShape.rectangle,
                          borderRadius: BorderRadius.all(Radius.circular(5.0))),
                      child: SizedBox(
                        width: cardWidth * .22,
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

            ListView.builder(
              itemCount: listOfMeta.length,
              physics: NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              // reverse: true,
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
            // SizedBox(
            //   width: cardWidth * .9,
            //   height: cardHeight * .4,
            // ),
            Container(
              padding: EdgeInsets.fromLTRB(10, 5, 10, 10),
              margin: EdgeInsets.zero,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  SizedBox(
                      // width: cardWidth * .45,
                      child: AutoSizeText(
                    "Preferred Time-Slot",
                    group: labelGroup,
                    minFontSize: 9,
                    maxFontSize: 11,
                    maxLines: 1,
                    overflow: TextOverflow.clip,
                    style: TextStyle(color: Colors.black, fontFamily: 'Roboto'),
                  )),
                  Container(
                    padding: EdgeInsets.all(0),
                    child: AutoSizeText(
                      ((ba.preferredSlotTiming != null)
                          ? DateFormat('yyyy-MM-dd – kk:mm')
                              .format(ba.preferredSlotTiming)
                          : "None"),
                      // group: medCondGroup,
                      minFontSize: 12,
                      maxFontSize: 14,
                      maxLines: 1,
                      overflow: TextOverflow.clip,
                      style: TextStyle(
                          fontSize: 14,
                          color: Colors.indigo[900],
                          //  fontWeight: FontWeight.bold,
                          fontFamily: 'Roboto'),
                    ),
                  ),
                ],
              ),
            ),
            if (!Utils.isNullOrEmpty(tokens))
              Container(
                margin: EdgeInsets.fromLTRB(10, 5, 10, 10),
                padding: EdgeInsets.all(5),
                width: MediaQuery.of(context).size.width * .9,
                color: Colors.cyan[100],
                child: ListView.builder(
                  itemCount: tokens.length,
                  physics: NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  // reverse: true,
                  itemBuilder: (BuildContext context, int index) {
                    return Row(
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
                                  minFontSize: 9,
                                  maxFontSize: 11,
                                  maxLines: 1,
                                  overflow: TextOverflow.clip,
                                  style: TextStyle(
                                      color: Colors.black,
                                      fontFamily: 'Roboto'),
                                ),
                                AutoSizeText(
                                  ('${tokens[index].getDisplayName()}'),
                                  minFontSize: 9,
                                  maxFontSize: 12,
                                  maxLines: 1,
                                  overflow: TextOverflow.clip,
                                  style: TextStyle(
                                      color: Colors.indigo[900],
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
                                  minFontSize: 9,
                                  maxFontSize: 11,
                                  maxLines: 1,
                                  overflow: TextOverflow.clip,
                                  style: TextStyle(
                                      color: Colors.black,
                                      fontFamily: 'Roboto'),
                                ),
                                horizontalSpacer,
                                AutoSizeText(
                                  ('${DateFormat('yyyy-MM-dd – kk:mm').format(tokens[index].parent.dateTime)}'),
                                  // group: medCondGroup,
                                  minFontSize: 9,
                                  maxFontSize: 12,
                                  maxLines: 1,
                                  overflow: TextOverflow.clip,
                                  style: TextStyle(
                                      color: Colors.indigo[900],
                                      //  fontWeight: FontWeight.bold,
                                      fontFamily: 'Roboto'),
                                ),
                              ]),
                        ),
                      ],
                    );
                  },
                ),
              ),

            if (widget.ba.status != ApplicationStatus.CANCELLED &&
                widget.ba.status != ApplicationStatus.REJECTED &&
                widget.ba.status != ApplicationStatus.COMPLETED)
              Container(
                  margin: EdgeInsets.zero,
                  padding: EdgeInsets.fromLTRB(8, 0, 0, 0),
                  width: cardWidth * .9,
                  height: cardHeight * .2,
                  child: TextFormField(
                    controller: listOfControllers[ba.id],
                    readOnly: (ba.status == ApplicationStatus.COMPLETED ||
                            ba.status == ApplicationStatus.CANCELLED)
                        ? true
                        : false,
                    style: TextStyle(
                        fontSize: 15,
                        color: Colors.black,
                        fontFamily: 'Roboto'),
                    decoration: InputDecoration(
                      labelText: 'Remarks',
                      enabledBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: Colors.grey)),
                      focusedBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: Colors.orange)),
                    ),
                    maxLines: 1,
                    keyboardType: TextInputType.text,
                  )),
            if (widget.ba.status != ApplicationStatus.CANCELLED &&
                widget.ba.status != ApplicationStatus.REJECTED &&
                widget.ba.status != ApplicationStatus.COMPLETED)
              Container(
                // width: MediaQuery.of(context).size.width * .8,
                margin: EdgeInsets.all(9),
                child: MaterialButton(
                    elevation: 8,
                    color: Colors.yellow[800],
                    onPressed: () {
                      cancelBooking(context).then((value) {
                        if (value) {
                          Utils.showMyFlushbar(
                              context,
                              Icons.info_outline,
                              Duration(
                                seconds: 3,
                              ),
                              "Cancelling the Application.. ",
                              "This would take a moment");
                          _gs
                              .getApplicationService()
                              .withDrawApplication(
                                  widget.ba.id, listOfControllers[ba.id].text)
                              .then((value) {
                            widget.ba.notesOnCancellation =
                                listOfControllers[ba.id].text;
                            setState(() {
                              widget.ba.status = ApplicationStatus.CANCELLED;
                            });

                            Utils.showMyFlushbar(
                                context,
                                Icons.check,
                                Duration(seconds: 4),
                                "Application Cancelled!!",
                                "",
                                Colors.greenAccent[400]);
                          }).onError((error, stackTrace) {
                            print("on error");
                          });
                        }
                      });
                    },
                    child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "Cancel",
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
//             Row(
//               mainAxisAlignment: MainAxisAlignment.end,
//               children: [
//                 Container(
//                   width: cardWidth * .6,
//                   child: Row(
//                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                     children: [
//                       IconButton(
//                           alignment: Alignment.center,
//                           //    visualDensity: VisualDensity.compact,
//                           padding: const EdgeInsets.fromLTRB(8, 2, 8, 0),
//                           color: (ba.status != ApplicationStatus.COMPLETED &&
//                                   ba.status != ApplicationStatus.CANCELLED)
//                               ? Colors.purple[400]
//                               : disabledColor,
//                           onPressed: () {
//                             // if (ba.status != ApplicationStatus.COMPLETED &&
//                             //     ba.status != ApplicationStatus.CANCELLED) {
//                             //   ba.notesOnApproval =
//                             //       listOfControllers[ba.id].text;
//                             //   _gs
//                             //       .getApplicationService()
//                             //       .updateApplicationStatus(
//                             //           ba.id,
//                             //           ApplicationStatus.COMPLETED,
//                             //           listOfControllers[ba.id].text,
//                             //           widget.metaEntity,
//                             //           ba.preferredSlotTiming)
//                             //       .then((value) {
//                             //     if (value) {
//                             //       setState(() {
//                             //         ba.status = ApplicationStatus.COMPLETED;
//                             //       });
//                             //       Utils.showMyFlushbar(
//                             //           context,
//                             //           Icons.check,
//                             //           Duration(seconds: 2),
//                             //           "Application is marked completed!!",
//                             //           "",
//                             //           Colors.purple[400],
//                             //           Colors.white);
//                             //     } else {
//                             //       print("Could not update application");
//                             //       Utils.showMyFlushbar(
//                             //           context,
//                             //           Icons.error,
//                             //           Duration(seconds: 4),
//                             //           "Oops! Application could not be marked Completed!!",
//                             //           "Try again later.");
//                             //     }
//                             //   }).catchError((error) {
//                             //     print(error.toString());
//                             //     print("Error in token booking" +
//                             //         error.toString());

//                             //     Utils.showMyFlushbar(
//                             //         context,
//                             //         Icons.error,
//                             //         Duration(seconds: 5),
//                             //         "Oops! Application could not be marked Completed!!",
//                             //         tryAgainLater);
//                             //   });
//                             // }
// //Update application status change on server.
//                           },
//                           icon: Icon(
//                             Icons.thumb_up,
//                             size: 30,
//                           )),
//                       IconButton(
//                           alignment: Alignment.center,
//                           //    visualDensity: VisualDensity.compact,
//                           padding: const EdgeInsets.fromLTRB(8, 2, 8, 0),
//                           color: (ba.status != ApplicationStatus.COMPLETED &&
//                                   ba.status != ApplicationStatus.CANCELLED)
//                               ? Colors.green[400]
//                               : disabledColor,
//                           onPressed: () {
//                             if (ba.status != ApplicationStatus.COMPLETED &&
//                                 ba.status != ApplicationStatus.CANCELLED) {
//                               ba.notesOnApproval =
//                                   listOfControllers[ba.id].text;
//                               _gs
//                                   .getApplicationService()
//                                   .updateApplicationStatus(
//                                       ba.id,
//                                       ApplicationStatus.APPROVED,
//                                       listOfControllers[ba.id].text,
//                                       widget.metaEntity,
//                                       ba.preferredSlotTiming)
//                                   .then((value) {
//                                 if (value) {
//                                   setState(() {
//                                     ba.status = ApplicationStatus.APPROVED;
//                                   });
//                                   Utils.showMyFlushbar(
//                                       context,
//                                       Icons.check,
//                                       Duration(seconds: 2),
//                                       "Application is Approved!!",
//                                       "",
//                                       Colors.green,
//                                       Colors.white);
//                                 } else {
//                                   print("Could not update application status");
//                                   Utils.showMyFlushbar(
//                                       context,
//                                       Icons.error,
//                                       Duration(seconds: 4),
//                                       "Oops! Application could not be Approved!!",
//                                       tryAgainToBook);
//                                 }
//                               }).catchError((error) {
//                                 print(error.toString());
//                                 print("Error in token booking" +
//                                     error.toString());

//                                 if (error is SlotFullException) {
//                                   Utils.showMyFlushbar(
//                                       context,
//                                       Icons.error,
//                                       Duration(seconds: 5),
//                                       slotsAlreadyBooked,
//                                       tryAgainToBook);
//                                 } else {
//                                   Utils.showMyFlushbar(
//                                       context,
//                                       Icons.error,
//                                       Duration(seconds: 5),
//                                       error.toString(),
//                                       tryAgainToBook);
//                                 }
//                               });
//                             }
// //Update application status change on server.
//                           },
//                           icon: Icon(
//                             Icons.check_circle,
//                             size: 30,
//                           )),
//                       IconButton(
//                         alignment: Alignment.center,
//                         //    visualDensity: VisualDensity.compact,
//                         padding: const EdgeInsets.fromLTRB(8, 2, 8, 0),
//                         visualDensity: VisualDensity.compact,

//                         color: (ba.status != ApplicationStatus.COMPLETED &&
//                                 ba.status != ApplicationStatus.CANCELLED)
//                             ? Colors.yellow[700]
//                             : disabledColor,
//                         onPressed: () {
//                           if (ba.status != ApplicationStatus.COMPLETED &&
//                               ba.status != ApplicationStatus.CANCELLED) {
//                             ba.notesOnPuttingOnHold =
//                                 listOfControllers[ba.id].text;

//                             _gs
//                                 .getApplicationService()
//                                 .updateApplicationStatus(
//                                     ba.id,
//                                     ApplicationStatus.ONHOLD,
//                                     listOfControllers[ba.id].text,
//                                     widget.metaEntity,
//                                     ba.preferredSlotTiming)
//                                 .then((value) {
//                               if (value) {
//                                 setState(() {
//                                   ba.status = ApplicationStatus.ONHOLD;
//                                 });
//                                 Utils.showMyFlushbar(
//                                     context,
//                                     Icons.check,
//                                     Duration(seconds: 2),
//                                     "Application is put on-hold!!",
//                                     "",
//                                     Colors.yellow[700],
//                                     Colors.white);
//                               } else {
//                                 print("Could not update application status");
//                                 Utils.showMyFlushbar(
//                                     context,
//                                     Icons.error,
//                                     Duration(seconds: 4),
//                                     "Oops! Application could not be put On-Hold!!",
//                                     tryAgainLater);
//                               }
//                             }).catchError((error) {
//                               print(error.toString());
//                               print(
//                                   "Error in token booking" + error.toString());

//                               Utils.showMyFlushbar(
//                                   context,
//                                   Icons.error,
//                                   Duration(seconds: 5),
//                                   "Oops! Application could not be put On-Hold!!",
//                                   tryAgainLater);
//                             });
//                           }
//                         },
//                         icon: Icon(
//                           Icons.pan_tool_rounded,
//                           size: 28,
//                         ),
//                       ),
//                       IconButton(
//                         // visualDensity: VisualDensity.compact,
//                         alignment: Alignment.center,
//                         //    visualDensity: VisualDensity.compact,
//                         padding: const EdgeInsets.fromLTRB(8, 2, 8, 0),
//                         color: (ba.status != ApplicationStatus.COMPLETED &&
//                                 ba.status != ApplicationStatus.CANCELLED)
//                             ? Colors.red
//                             : disabledColor,
//                         onPressed: () {
//                           if (ba.status != ApplicationStatus.COMPLETED &&
//                               ba.status != ApplicationStatus.CANCELLED) {
//                             ba.notesOnRejection = listOfControllers[ba.id].text;
//                             _gs
//                                 .getApplicationService()
//                                 .updateApplicationStatus(
//                                     ba.id,
//                                     ApplicationStatus.REJECTED,
//                                     listOfControllers[ba.id].text,
//                                     widget.metaEntity,
//                                     ba.preferredSlotTiming)
//                                 .then((value) {
//                               if (value) {
//                                 setState(() {
//                                   ba.status = ApplicationStatus.REJECTED;
//                                 });
//                                 Utils.showMyFlushbar(
//                                     context,
//                                     Icons.check,
//                                     Duration(seconds: 2),
//                                     "Application is rejected!!",
//                                     "",
//                                     Colors.red,
//                                     Colors.white);
//                               } else {
//                                 print("Could not update application status");
//                                 Utils.showMyFlushbar(
//                                     context,
//                                     Icons.error,
//                                     Duration(seconds: 4),
//                                     "Oops! Application could not be rejected!!",
//                                     "");
//                               }
//                             }).catchError((error) {
//                               print(error.toString());
//                               print(
//                                   "Error in token booking" + error.toString());

//                               Utils.showMyFlushbar(
//                                   context,
//                                   Icons.error,
//                                   Duration(seconds: 5),
//                                   "Oops! Application could not be rejected!!",
//                                   tryAgainLater);
//                             });
//                           }
//                         },
//                         icon: Icon(
//                           Icons.cancel,
//                           size: 30,
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               ],
//             ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (initCompleted)
      return Center(child: _buildItem(widget.ba));
    else {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            showCircularProgress(),
          ],
        ),
      );
    }
  }
}
