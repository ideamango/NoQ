import 'package:enum_to_string/enum_to_string.dart';
import './address.dart';
import './employee.dart';
import './meta_entity.dart';
import './meta_form.dart';
import './meta_user.dart';
import './my_geo_fire_point.dart';
import './offer.dart';
import '../../enum/entity_type.dart';
import '../../enum/entity_role.dart';
import '../../utils.dart';

class Entity {
  Entity(
      {this.entityId,
      this.name,
      this.description,
      this.address,
      this.advanceDays,
      this.isPublic,
      this.admins,
      this.managers,
      this.executives,
      this.childEntities,
      this.maxAllowed,
      this.slotDuration,
      this.closedOn,
      this.breakStartHour,
      this.breakStartMinute,
      this.breakEndHour,
      this.breakEndMinute,
      this.startTimeHour,
      this.startTimeMinute,
      this.endTimeHour,
      this.endTimeMinute,
      this.parentId,
      this.type,
      this.isBookable,
      this.isActive,
      this.coordinates,
      this.distance,
      this.whatsapp,
      this.createdAt,
      this.modifiedAt,
      this.verificationStatus,
      this.upiId,
      this.upiPhoneNumber,
      this.upiQRImagePath,
      this.offer,
      this.phone,
      this.forms,
      this.maxTokensPerSlotByUser = 1,
      this.maxPeoplePerToken = 1,
      this.parentGroupId,
      this.supportEmail,
      this.maxTokensByUserInDay = 1,
      this.allowOnlineAppointment = false,
      this.allowWalkinAppointment = true});

  //SlotDocumentId is entityID#20~06~01 it is not auto-generated, will help in not duplicating the record
  String entityId;
  String name;
  String description;
  String regNum;
  Address address;
  int advanceDays;
  bool isPublic;
  List<Employee> admins;
  List<Employee> managers;
  List<Employee> executives;
  List<MetaEntity> childEntities;
  //MyGeoFirePoint geo;
  int maxAllowed;
  int slotDuration;
  List<String> closedOn;
  int breakStartHour;
  int breakStartMinute;
  int breakEndHour;
  int breakEndMinute;
  int startTimeHour;
  int startTimeMinute;
  int endTimeHour;
  int endTimeMinute;
  String parentId;
  EntityType type;
  bool isBookable;
  bool isActive;
  MyGeoFirePoint coordinates;
  double distance;
  String whatsapp;
  DateTime createdAt;
  DateTime modifiedAt;
  //"Verification Pending", "Verified", "Rejected"
  String verificationStatus;
  String upiId;
  String upiPhoneNumber;
  String upiQRImagePath;
  Offer offer;
  String phone;
  MetaEntity _meta;
  List<MetaForm> forms;
  int maxTokensPerSlotByUser;
  int maxPeoplePerToken;
  String
      parentGroupId; //this value will be present and common for different branches of same company
  String supportEmail;
  int maxTokensByUserInDay;
  bool allowOnlineAppointment;
  bool allowWalkinAppointment;

  Map<String, dynamic> toJson() => {
        'entityId': entityId,
        'name': name,
        'description': description,
        //'regNum': regNum,
        'address': address != null ? address.toJson() : null,
        'advanceDays': advanceDays,
        'isPublic': isPublic,
        'admins': employeesToJson(admins),
        'managers': employeesToJson(managers),
        'executives': employeesToJson(executives),
        'childEntities': metaEntitiesToJson(childEntities),
        'maxAllowed': maxAllowed,
        'slotDuration': slotDuration,
        'closedOn': closedOn,
        'breakStartHour': breakStartHour,
        'breakStartMinute': breakStartMinute,
        'breakEndHour': breakEndHour,
        'breakEndMinute': breakEndMinute,
        'startTimeHour': startTimeHour,
        'startTimeMinute': startTimeMinute,
        'endTimeHour': endTimeHour,
        'endTimeMinute': endTimeMinute,
        'parentId': parentId,
        'type': EnumToString.convertToString(type),
        'isBookable': isBookable,
        'isActive': isActive,
        'coordinates': coordinates != null ? coordinates.toJson() : null,
        'nameQuery': constructQueriableList(name),
        'distance': distance,
        'whatsapp': whatsapp,
        'createdAt': createdAt.millisecondsSinceEpoch,
        'modifiedAt': modifiedAt.millisecondsSinceEpoch,
        'verificationStatus': verificationStatus,
        'upiId': upiId,
        'upiPhoneNumber': upiPhoneNumber,
        'upiQRImagePath': upiQRImagePath,
        'offer': offer != null ? offer.toJson() : null,
        'phone': phone,
        'forms': metaFormsToJson(forms),
        'maxTokensPerSlotByUser': maxTokensPerSlotByUser,
        'maxPeoplePerToken': maxPeoplePerToken,
        'parentGroupId': parentGroupId,
        'supportEmail': supportEmail,
        'maxTokensByUserInDay': maxTokensByUserInDay,
        'allowOnlineAppointment': allowOnlineAppointment,
        'allowWalkinAppointment': allowWalkinAppointment
      };

  List<dynamic> usersToJson(List<MetaUser> users) {
    List<dynamic> usersJson = [];
    if (users == null) return usersJson;
    for (MetaUser usr in users) {
      usersJson.add(usr.toJson());
    }
    return usersJson;
  }

  List<dynamic> employeesToJson(List<Employee> emps) {
    List<dynamic> usersJson = [];
    if (emps == null) return usersJson;
    for (Employee emp in emps) {
      usersJson.add(emp.toJson());
    }
    return usersJson;
  }

  List<dynamic> metaEntitiesToJson(List<MetaEntity> metaEntities) {
    List<dynamic> usersJson = [];
    if (metaEntities == null) return usersJson;
    for (MetaEntity meta in metaEntities) {
      usersJson.add(meta.toJson());
    }
    return usersJson;
  }

  List<dynamic> metaFormsToJson(List<MetaForm> metaForms) {
    List<dynamic> usersJson = [];
    if (metaForms == null) return usersJson;
    for (MetaForm meta in metaForms) {
      usersJson.add(meta.toJson());
    }
    return usersJson;
  }

  EntityRole getRole(String phone) {
    for (int index = 0; index < this.admins.length; index++) {
      if (this.admins[index].ph == phone) {
        return EntityRole.Admin;
      }
    }

    for (int index = 0; index < this.managers.length; index++) {
      if (this.managers[index].ph == phone) {
        return EntityRole.Manager;
      }
    }

    for (int index = 0; index < this.executives.length; index++) {
      if (this.executives[index].ph == phone) {
        return EntityRole.Executive;
      }
    }

    return null;
  }

  static Entity fromJson(Map<String, dynamic> json) {
    if (json == null) return null;
    return new Entity(
        entityId: json['entityId'],
        name: json['name'],
        description: json['description'],
        //regNum: json['regNum'],
        address: Address.fromJson(json['address']),
        advanceDays: json['advanceDays'],
        isPublic: json['isPublic'],
        admins: convertToEmployeesFromJson(json['admins']),
        managers: convertToEmployeesFromJson(json['managers']),
        executives: convertToEmployeesFromJson(json['executives']),
        childEntities: convertToMetaEntitiesFromJson(json['childEntities']),
        maxAllowed: json['maxAllowed'],
        slotDuration: json['slotDuration'],
        closedOn: convertToClosedOnArrayFromJson(json['closedOn']),
        breakStartHour: json['breakStartHour'],
        breakStartMinute: json['breakStartMinute'],
        breakEndHour: json['breakEndHour'],
        breakEndMinute: json['breakEndMinute'],
        startTimeHour: json['startTimeHour'],
        startTimeMinute: json['startTimeMinute'],
        endTimeHour: json['endTimeHour'],
        endTimeMinute: json['endTimeMinute'],
        parentId: json['parentId'],
        type: EnumToString.fromString(EntityType.values, json['type']),
        isBookable: json['isBookable'],
        isActive: json['isActive'],
        coordinates: MyGeoFirePoint.fromJson(json['coordinates']),
        distance: json['distance'],
        whatsapp: json['whatsapp'],
        createdAt: new DateTime.fromMillisecondsSinceEpoch(json['createdAt']),
        modifiedAt: new DateTime.fromMillisecondsSinceEpoch(json['modifiedAt']),
        verificationStatus: json['verificationStatus'],
        upiId: json['upiId'],
        upiPhoneNumber: json['upiPhoneNumber'],
        upiQRImagePath: json['upiQRImagePath'],
        offer: Offer.fromJson(json['offer']),
        phone: json['phone'],
        forms: convertToMetaFormsFromJson(json['forms']),
        maxTokensPerSlotByUser: json['maxTokensPerSlotByUser'],
        maxPeoplePerToken: json['maxPeoplePerToken'],
        parentGroupId: json['parentGroupId'],
        supportEmail: json['supportEmail'],
        maxTokensByUserInDay: json['maxTokensByUserInDay'],
        allowOnlineAppointment: json['allowOnlineAppointment'],
        allowWalkinAppointment: json['allowWalkinAppointment']);
  }

  bool removeChildEntity(String childEntityId) {
    if (childEntities == null) {
      return false;
    }
    int index = -1;
    bool matched = false;
    for (MetaEntity me in childEntities) {
      index++;
      if (me.entityId == childEntityId) {
        matched = true;
        break;
      }
    }

    if (matched) {
      childEntities.removeAt(index);
      return true;
    }

    return false;
  }

  static Address convertToAddressFromJson(Map<String, dynamic> json) {
    return Address.fromJson(json);
  }

  static List<MetaUser> convertToUsersFromJson(List<dynamic> usersJson) {
    List<MetaUser> users = [];
    if (usersJson == null) return users;

    for (Map<String, dynamic> json in usersJson) {
      MetaUser sl = MetaUser.fromJson(json);
      users.add(sl);
    }
    return users;
  }

  static List<Employee> convertToEmployeesFromJson(List<dynamic> usersJson) {
    List<Employee> users = [];
    if (usersJson == null) return users;

    for (Map<String, dynamic> json in usersJson) {
      Employee emp = Employee.fromJson(json);
      users.add(emp);
    }
    return users;
  }

  static List<MetaEntity> convertToMetaEntitiesFromJson(
      List<dynamic> metaEntityJson) {
    List<MetaEntity> metaEntities = [];
    if (metaEntityJson == null) return metaEntities;

    for (Map<String, dynamic> json in metaEntityJson) {
      MetaEntity metaEnt = MetaEntity.fromJson(json);
      metaEntities.add(metaEnt);
    }
    return metaEntities;
  }

  static List<MetaForm> convertToMetaFormsFromJson(List<dynamic> metaFormJson) {
    List<MetaForm> metaForms = [];
    if (metaFormJson == null) return metaForms;

    for (Map<String, dynamic> json in metaFormJson) {
      MetaForm metaEnt = MetaForm.fromJson(json);
      metaForms.add(metaEnt);
    }
    return metaForms;
  }

  static List<String> convertToClosedOnArrayFromJson(List<dynamic> daysJson) {
    List<String> days = [];
    if (daysJson == null) return days;

    for (String day in daysJson) {
      days.add(day);
    }
    return days;
  }

  MetaEntity getMetaEntity() {
    if (_meta == null) {
      _meta = new MetaEntity(
          entityId: entityId,
          name: name,
          type: type,
          advanceDays: advanceDays,
          isPublic: isPublic,
          closedOn: closedOn,
          breakStartHour: breakStartHour,
          breakStartMinute: breakStartMinute,
          breakEndHour: breakEndHour,
          breakEndMinute: breakEndMinute,
          startTimeHour: startTimeHour,
          startTimeMinute: startTimeMinute,
          endTimeHour: endTimeHour,
          endTimeMinute: endTimeMinute,
          isActive: isActive,
          lat: (coordinates != null) ? coordinates.geopoint.latitude : null,
          lon: (coordinates != null) ? coordinates.geopoint.longitude : null,
          slotDuration: slotDuration,
          maxAllowed: maxAllowed,
          distance: distance,
          whatsapp: whatsapp,
          parentId: parentId,
          upiId: upiId,
          upiPhoneNumber: upiPhoneNumber,
          upiQRImagePath: upiQRImagePath,
          offer: offer,
          phone: phone,
          address:
              (address != null) ? Utils.getFormattedAddress(address) : null,
          hasChildren: (childEntities != null && childEntities.length > 0)
              ? true
              : false,
          isBookable: isBookable,
          forms: forms,
          maxTokensPerSlotByUser: maxTokensPerSlotByUser,
          maxPeoplePerToken: maxPeoplePerToken,
          parentGroupId: parentGroupId,
          supportEmail: supportEmail,
          maxTokensByUserInDay: maxTokensByUserInDay,
          allowOnlineAppointment: allowOnlineAppointment,
          allowWalkinAppointment: allowWalkinAppointment);
    } else {
      _meta.name = name;
      _meta.type = type;
      _meta.advanceDays = advanceDays;
      _meta.isPublic = isPublic;
      _meta.closedOn = closedOn;

      _meta.breakStartHour = breakStartHour;
      _meta.breakStartMinute = breakStartMinute;
      _meta.breakEndHour = breakEndHour;
      _meta.breakEndMinute = breakEndMinute;
      _meta.startTimeHour = startTimeHour;
      _meta.startTimeMinute = startTimeMinute;
      _meta.endTimeHour = endTimeHour;
      _meta.endTimeMinute = endTimeMinute;
      _meta.isActive = isActive;
      _meta.lat = (coordinates != null) ? coordinates.geopoint.latitude : null;
      _meta.lon = (coordinates != null) ? coordinates.geopoint.longitude : null;
      _meta.slotDuration = slotDuration;
      _meta.maxAllowed = maxAllowed;
      _meta.distance = distance;
      _meta.whatsapp = whatsapp;
      _meta.parentId = parentId;
      _meta.upiId = upiId;
      _meta.upiPhoneNumber = upiPhoneNumber;
      _meta.upiQRImagePath = upiQRImagePath;
      _meta.offer = offer;
      _meta.phone = phone;
      _meta.address =
          (address != null) ? Utils.getFormattedAddress(address) : null;
      _meta.hasChildren =
          (childEntities != null && childEntities.length > 0) ? true : false;
      _meta.isBookable = isBookable;
      _meta.forms = forms;
      _meta.maxTokensPerSlotByUser = maxTokensPerSlotByUser;
      _meta.maxPeoplePerToken = maxPeoplePerToken;
      _meta.parentGroupId = parentGroupId;
      _meta.supportEmail = supportEmail;
      _meta.maxTokensByUserInDay = maxTokensByUserInDay;
      _meta.allowOnlineAppointment = allowOnlineAppointment;
      _meta.allowWalkinAppointment = allowWalkinAppointment;
    }
    return _meta;
  }

  List<String> constructQueriableList(String string) {
    if (string == null) return [];
    String lowercased = string.toLowerCase();
    List<String> queriables = [];
    for (int i = 1; i <= lowercased.length; i++) {
      queriables.add(lowercased.substring(0, i));
    }
    return queriables;
  }
}
