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
  String
      tokenId; //when the Application status is Approved, then the token is assigned
  String entityId;
  String userId;
  ApplicationStatus status;

  DateTime timeOfSubmission;
  String notesOnSubmission;

  DateTime timeOfInReview;
  String notesInReview;
  String reviewedBy;

  DateTime timeOfAcceptance;
  String notesOnAcceptance;
  String acceptedBy;

  DateTime timeOfRejection;
  String notesOnRejection;
  String rejectedBy;

  DateTime timeOfPuttingOnHold;
  String notesOnPuttingOnHold;
  String putOnHoldBy;

  DateTime timeOfCompletion;
  String notesOnCompletion;
  String completedBy;

  DateTime timeOfCancellation;
  String notesOnCancellation;

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
        'notesOnSubmission': notesOnSubmission,
        'timeOfInReview': (timeOfInReview != null)
            ? timeOfInReview.millisecondsSinceEpoch
            : null,
        'notesInReview': notesInReview,
        'reviewedBy': reviewedBy,
        'timeOfAcceptance': (timeOfAcceptance != null)
            ? timeOfAcceptance.millisecondsSinceEpoch
            : null,
        'notesOnAcceptance': notesOnAcceptance,
        'acceptedBy': acceptedBy,
        'timeOfRejection': (timeOfRejection != null)
            ? timeOfRejection.millisecondsSinceEpoch
            : null,
        'notesOnRejection': notesOnRejection,
        'rejectedBy': rejectedBy,
        'timeOfPuttingOnHold': (timeOfPuttingOnHold != null)
            ? timeOfPuttingOnHold.millisecondsSinceEpoch
            : null,
        'notesOnPuttingOnHold': notesOnPuttingOnHold,
        'putOnHoldBy': putOnHoldBy,
        'timeOfCompletion': (timeOfCompletion != null)
            ? timeOfCompletion.millisecondsSinceEpoch
            : null,
        'notesOnCompletion': notesOnCompletion,
        'completedBy': completedBy,
        'timeOfCancellation': (timeOfCancellation != null)
            ? timeOfCancellation.millisecondsSinceEpoch
            : null,
        'notesOnCancellation': notesOnCancellation,
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
    ba.notesOnSubmission = json['notesOnSubmission'];

    ba.timeOfInReview = (json['timeOfInReview'] != null)
        ? new DateTime.fromMillisecondsSinceEpoch(json['timeOfInReview'])
        : null;
    ba.notesInReview = json['notesInReview'];
    ba.reviewedBy = json['reviewedBy'];

    ba.timeOfAcceptance = (json['timeOfAcceptance'] != null)
        ? new DateTime.fromMillisecondsSinceEpoch(json['timeOfAcceptance'])
        : null;
    ba.notesOnAcceptance = json['notesOnAcceptance'];
    ba.acceptedBy = json['acceptedBy'];

    ba.timeOfRejection = (json['timeOfRejection'] != null)
        ? new DateTime.fromMillisecondsSinceEpoch(json['timeOfRejection'])
        : null;
    ba.notesOnRejection = json['notesOnRejection'];
    ba.rejectedBy = json['rejectedBy'];

    ba.timeOfPuttingOnHold = (json['timeOfPuttingOnHold'] != null)
        ? new DateTime.fromMillisecondsSinceEpoch(json['timeOfPuttingOnHold'])
        : null;
    ba.notesOnPuttingOnHold = json['notesOnPuttingOnHold'];
    ba.putOnHoldBy = json['putOnHoldBy'];

    ba.timeOfCompletion = (json['timeOfCompletion'] != null)
        ? new DateTime.fromMillisecondsSinceEpoch(json['timeOfCompletion'])
        : null;

    ba.notesOnCompletion = json['notesOnCompletion'];
    ba.completedBy = json['completedBy'];

    ba.timeOfCancellation = (json['timeOfCancellation'] != null)
        ? new DateTime.fromMillisecondsSinceEpoch(json['timeOfCancellation'])
        : null;

    ba.notesOnCancellation = json['notesOnCancellation'];

    return ba;
  }
}

class BookingApplicationsOverview {
  BookingApplicationsOverview({this.bookingFormId, this.entityId});

  String id = Uuid().v1();
  String bookingFormId;
  String
      entityId; //this will be null for the global applications record for a global bookingFormId (i.e. which is shared across the Entities)

  int totalApplications;
  int numberOfNew;
  int numberOfApproved;
  int numberOfRejected;
  int numberOfPutOnHold;
  int numberOfInReview;
  int numberOfCompleted;
  int numberOfCancelled;

  Map<String, dynamic> toJson() => {
        'id': id,
        'bookingFormId': bookingFormId,
        'entityId': entityId,
        'totalApplications': totalApplications,
        'numberOfNew': numberOfNew,
        'numberOfInReview': numberOfInReview,
        'numberOfApproved': numberOfApproved,
        'numberOfRejected': numberOfRejected,
        'numberOfPutOnHold': numberOfPutOnHold,
        'numberOfCompleted': numberOfCompleted,
        'numberOfCancelled': numberOfCancelled
      };

  static BookingApplicationsOverview fromJson(Map<String, dynamic> json) {
    if (json == null) return null;

    BookingApplicationsOverview overview = BookingApplicationsOverview(
        bookingFormId: json['bookingFormId'], entityId: json['entityId']);

    overview.id = json['id'];
    overview.totalApplications = json['totalApplications'];
    overview.numberOfNew = json['numberOfNew'];
    overview.numberOfInReview = json['numberOfInReview'];
    overview.numberOfApproved = json['numberOfApproved'];
    overview.numberOfRejected = json['numberOfRejected'];
    overview.numberOfPutOnHold = json['numberOfPutOnHold'];
    overview.numberOfCompleted = json['numberOfCompleted'];
    overview.numberOfCancelled = json['numberOfCancelled'];
    return overview;
  }
}
