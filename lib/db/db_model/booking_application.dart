import 'package:enum_to_string/enum_to_string.dart';
import 'package:noq/db/db_model/booking_form.dart';
import 'package:noq/enum/application_status.dart';
import 'package:uuid/uuid.dart';

class BookingApplication {
  BookingApplication(
      {this.tokenId, this.entityId, this.userId, this.responseForm});

  //SlotId is entityID#20~06~01#9~30
  String id = Uuid().v1();
  String bookingFormId;
  String tokenId;
  String entityId;
  String userId;
  ApplicationStatus status;

  DateTime timeOfSubmission;
  DateTime timeOfAcceptance;
  DateTime timeOfRejection;
  DateTime timeOfPuttingOnHold;

  BookingForm responseForm;

  Map<String, dynamic> toJson() => {
        'id': id,
        'bookingFormId': bookingFormId,
        'tokenId': tokenId,
        'entityId': entityId,
        'userId': userId,
        'status': EnumToString.convertToString(status),
        'timeOfSubmission': (timeOfSubmission != null)
            ? timeOfSubmission.millisecondsSinceEpoch
            : null,
        'timeOfAcceptance': (timeOfAcceptance != null)
            ? timeOfAcceptance.millisecondsSinceEpoch
            : null,
        'timeOfRejection': (timeOfRejection != null)
            ? timeOfRejection.millisecondsSinceEpoch
            : null,
        'timeOfPuttingOnHold': (timeOfPuttingOnHold != null)
            ? timeOfPuttingOnHold.millisecondsSinceEpoch
            : null
      };

  static BookingApplication fromJson(Map<String, dynamic> json) {
    if (json == null) return null;

    BookingForm bf = BookingForm.fromJson(json['responseForm']);
    BookingApplication ba = BookingApplication(
        tokenId: json['tokenId'],
        entityId: json['entityId'],
        userId: json['userId'],
        responseForm: bf);
    ba.bookingFormId = bf.id;

    ba.status =
        EnumToString.fromString(ApplicationStatus.values, json['status']);

    ba.timeOfSubmission = (json['timeOfSubmission'] != null)
        ? new DateTime.fromMillisecondsSinceEpoch(json['timeOfSubmission'])
        : null;

    ba.timeOfAcceptance = (json['timeOfAcceptance'] != null)
        ? new DateTime.fromMillisecondsSinceEpoch(json['timeOfAcceptance'])
        : null;

    ba.timeOfRejection = (json['timeOfRejection'] != null)
        ? new DateTime.fromMillisecondsSinceEpoch(json['timeOfRejection'])
        : null;

    ba.timeOfPuttingOnHold = (json['timeOfPuttingOnHold'] != null)
        ? new DateTime.fromMillisecondsSinceEpoch(json['timeOfPuttingOnHold'])
        : null;

    return ba;
  }
}
