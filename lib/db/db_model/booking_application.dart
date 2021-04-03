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

  String notes;

  Map<String, dynamic> toJson() {
    Map<String, dynamic> map = {
      'id': id,
      'responseForm': responseForm.toJson(),
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
      'timeOfApproval': (timeOfApproval != null)
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
      'notes': notes
    };

    for (Field f in responseForm.getFormFields()) {
      if (f.type == FieldType.TEXT) {
        FormInputFieldText t = f;
        map[t.key] = t.response;
      } else if (f.type == FieldType.NUMBER) {
        FormInputFieldNumber t = f;
        map[t.key] = t.response;
      } else if (f.type == FieldType.OPTIONS) {
        FormInputFieldOptions t = f;
        List<String> fieldValueIds = List<String>();
        for (Value val in t.responseValues) {
          fieldValueIds.add(val.key);
        }
        map[t.key] = fieldValueIds;
      } else if (f.type == FieldType.ATTACHMENT) {
        FormInputFieldAttachment t = f;
      } else if (f.type == FieldType.DATETIME) {
        FormInputFieldDateTime t = f;
        map[t.key] = t.responseDateTime;
      } else if (f.type == FieldType.PHONE) {
        FormInputFieldPhone t = f;
        map[t.key] = t.responsePhone;
      } else if (f.type == FieldType.OPTIONS_ATTACHMENTS) {
        FormInputFieldOptionsWithAttachments t = f;
        List<String> fieldValueIds = List<String>();
        if (t.responseValues != null) {
          for (Value val in t.responseValues) {
            fieldValueIds.add(val.key);
          }
        }
        map[t.key] = fieldValueIds;
      } else if (f.type == FieldType.BOOL) {
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
    ba.id = json['id'];

    ba.tokenId = json['tokenId'];
    ba.userId = json['userId'];
    ba.notes = json['notes'];

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

class BookingApplicationCounter {
  BookingApplicationCounter({this.bookingFormId, this.entityId});

  String id = Uuid().v1();
  String bookingFormId;
  String
      entityId; //this will be null for the global applications record for a global bookingFormId (i.e. which is shared across the Entities)

  int totalApplications = 0;
  int numberOfNew = 0;
  int numberOfApproved = 0;
  int numberOfRejected = 0;
  int numberOfPutOnHold = 0;
  int numberOfInProcess = 0;
  int numberOfCompleted = 0;
  int numberOfCancelled = 0;

  Map<String, ApplicationStats> dailyStats; //key should be year#month#day

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
        'numberOfCancelled': numberOfCancelled,
        'dailyStats': convertFromMap(dailyStats)
      };

  static BookingApplicationCounter fromJson(Map<String, dynamic> json) {
    if (json == null) return null;

    BookingApplicationCounter overview = BookingApplicationCounter(
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
    overview.dailyStats = convertToMapFromJSON(json['dailyStats']);
    return overview;
  }

  Map<String, dynamic> convertFromMap(
      Map<String, ApplicationStats> dailyStats) {
    if (dailyStats == null) {
      return null;
    }

    Map<String, dynamic> map = Map<String, dynamic>();

    dailyStats.forEach((k, v) => map[k] = v.toJson());

    return map;
  }

  static Map<String, ApplicationStats> convertToMapFromJSON(
      Map<dynamic, dynamic> map) {
    Map<String, ApplicationStats> roles = new Map<String, ApplicationStats>();
    map.forEach((k, v) => roles[k] = ApplicationStats.fromJson(v));
    return roles;
  }
}

class ApplicationStats {
  int numberOfNew = 0;
  int numberOfApproved = 0;
  int numberOfRejected = 0;
  int numberOfPutOnHold = 0;
  int numberOfInProcess = 0;
  int numberOfCompleted = 0;
  int numberOfCancelled = 0;

  Map<String, dynamic> toJson() => {
        'numberOfNew': numberOfNew,
        'numberOfInProcess': numberOfInProcess,
        'numberOfApproved': numberOfApproved,
        'numberOfRejected': numberOfRejected,
        'numberOfPutOnHold': numberOfPutOnHold,
        'numberOfCompleted': numberOfCompleted,
        'numberOfCancelled': numberOfCancelled
      };

  static ApplicationStats fromJson(Map<String, dynamic> json) {
    if (json == null) return null;

    ApplicationStats overview = ApplicationStats();
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
