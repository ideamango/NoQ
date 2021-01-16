import 'package:enum_to_string/enum_to_string.dart';
import 'package:noq/db/db_model/booking_form.dart';
import 'package:noq/enum/application_status.dart';
import 'package:noq/enum/field_type.dart';
import 'package:uuid/uuid.dart';

class BookingApplication {
  BookingApplication({this.entityId, this.responseForm});

  //SlotId is entityID#20~06~01#9~30
  String id = Uuid().v1();
  String bookingFormId;

  //when the Application status is Approved, then the token is assigned
  String tokenId;
  String entityId;
  String userId;
  ApplicationStatus status;

  DateTime timeOfSubmission;
  String notesOnSubmission;

  DateTime timeOfInProcess;
  String notesInProcess;
  String processedBy;

  DateTime timeOfApproval;
  String notesOnApproval;
  String approvedBy;

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

  DateTime preferredSlotTiming;

  Map<String, dynamic> toJson() {
    Map<String, dynamic> map = {
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
      'timeOfInProcess': (timeOfInProcess != null)
          ? timeOfInProcess.millisecondsSinceEpoch
          : null,
      'notesInProcess': notesInProcess,
      'processedBy': processedBy,
      'timeOfAcceptance': (timeOfApproval != null)
          ? timeOfApproval.millisecondsSinceEpoch
          : null,
      'notesOnApproval': notesOnApproval,
      'approvedBy': approvedBy,
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
      'preferredSlotTiming': (preferredSlotTiming != null)
          ? preferredSlotTiming.millisecondsSinceEpoch
          : null,
    };

    for (Field f in responseForm.getFormFields()) {
      if (f.type == EnumToString.convertToString(FieldType.TEXT)) {
        FormInputFieldText t = f;
        map[t.key] = t.response;
      } else if (f.type == EnumToString.convertToString(FieldType.NUMBER)) {
        FormInputFieldNumber t = f;
        map[t.key] = t.response;
      } else if (f.type == EnumToString.convertToString(FieldType.OPTIONS)) {
        FormInputFieldOptions t = f;
        List<String> fieldValueIds = List<String>();
        for (Value val in t.responseValues) {
          fieldValueIds.add(val.key);
        }
        map[t.key] = fieldValueIds;
      } else if (f.type == EnumToString.convertToString(FieldType.ATTACHMENT)) {
        FormInputFieldAttachment t = f;
      } else if (f.type == EnumToString.convertToString(FieldType.DATETIME)) {
        FormInputFieldDateTime t = f;
        map[t.key] = t.responseDateTime;
      } else if (f.type == EnumToString.convertToString(FieldType.PHONE)) {
        FormInputFieldPhone t = f;
        map[t.key] = t.responsePhone;
      } else if (f.type ==
          EnumToString.convertToString(FieldType.OPTIONS_ATTACHMENTS)) {
        FormInputFieldOptionsWithAttachments t = f;
        List<String> fieldValueIds = List<String>();
        for (Value val in t.responseValues) {
          fieldValueIds.add(val.key);
        }
        map[t.key] = fieldValueIds;
      } else if (f.type == EnumToString.convertToString(FieldType.BOOL)) {
        FormInputFieldBool t = f;
        map[t.key] = t.response;
      }
    }

    return map;
  }

  static BookingApplication fromJson(Map<String, dynamic> json) {
    if (json == null) return null;

    BookingForm bf = BookingForm.fromJson(json['responseForm']);
    BookingApplication ba =
        BookingApplication(entityId: json['entityId'], responseForm: bf);
    ba.bookingFormId = bf.id;

    ba.tokenId = json['tokenId'];
    ba.userId = json['userId'];

    ba.status =
        EnumToString.fromString(ApplicationStatus.values, json['status']);

    ba.timeOfSubmission = (json['timeOfSubmission'] != null)
        ? new DateTime.fromMillisecondsSinceEpoch(json['timeOfSubmission'])
        : null;
    ba.notesOnSubmission = json['notesOnSubmission'];

    ba.timeOfInProcess = (json['timeOfInProcess'] != null)
        ? new DateTime.fromMillisecondsSinceEpoch(json['timeOfInProcess'])
        : null;
    ba.notesInProcess = json['notesInProcess'];
    ba.processedBy = json['processedBy'];

    ba.timeOfApproval = (json['timeOfApproval'] != null)
        ? new DateTime.fromMillisecondsSinceEpoch(json['timeOfApproval'])
        : null;
    ba.notesOnApproval = json['notesOnApproval'];
    ba.approvedBy = json['approvedBy'];

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

    ba.preferredSlotTiming = (json['preferredSlotTiming'] != null)
        ? new DateTime.fromMillisecondsSinceEpoch(json['preferredSlotTiming'])
        : null;

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
  int numberOfInProcess;
  int numberOfCompleted;
  int numberOfCancelled;

  Map<String, dynamic> toJson() => {
        'id': id,
        'bookingFormId': bookingFormId,
        'entityId': entityId,
        'totalApplications': totalApplications,
        'numberOfNew': numberOfNew,
        'numberOfInProcess': numberOfInProcess,
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
    overview.numberOfInProcess = json['numberOfInProcess'];
    overview.numberOfApproved = json['numberOfApproved'];
    overview.numberOfRejected = json['numberOfRejected'];
    overview.numberOfPutOnHold = json['numberOfPutOnHold'];
    overview.numberOfCompleted = json['numberOfCompleted'];
    overview.numberOfCancelled = json['numberOfCancelled'];
    return overview;
  }
}
