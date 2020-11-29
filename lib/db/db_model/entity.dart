import 'package:noq/db/db_model/address.dart';
import 'package:noq/db/db_model/employee.dart';
import 'package:noq/db/db_model/meta_entity.dart';
import 'package:noq/db/db_model/meta_user.dart';
import 'package:noq/db/db_model/my_geo_fire_point.dart';
import 'package:noq/db/db_model/offer.dart';
import 'package:noq/utils.dart';

class Entity {
  Entity(
      {this.entityId,
      this.name,
      this.description,
      this.address,
      this.advanceDays,
      this.isPublic,
      this.managers,
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
      this.gpay,
      this.paytm,
      this.applepay,
      this.offer,
      this.phone});

  //SlotDocumentId is entityID#20~06~01 it is not auto-generated, will help in not duplicating the record
  String entityId;
  String name;
  String description;
  String regNum;
  Address address;
  int advanceDays;
  bool isPublic;
  //List<MetaUser> admins;
  List<Employee> managers;
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
  String type;
  bool isBookable;
  bool isActive;
  MyGeoFirePoint coordinates;
  double distance;
  String whatsapp;
  DateTime createdAt;
  DateTime modifiedAt;
  //"Verification Pending", "Verified", "Rejected"
  String verificationStatus;
  String gpay;
  String paytm;
  String applepay;
  Offer offer;
  String phone;
  MetaEntity _meta;

  Map<String, dynamic> toJson() => {
        'entityId': entityId,
        'name': name,
        'description': description,
        //'regNum': regNum,
        'address': address != null ? address.toJson() : null,
        'advanceDays': advanceDays,
        'isPublic': isPublic,
        //'admins': usersToJson(admins),
        'managers': employeesToJson(managers),
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
        'type': type,
        'isBookable': isBookable,
        'isActive': isActive,
        'coordinates': coordinates != null ? coordinates.toJson() : null,
        'nameQuery': constructQueriableList(name),
        'distance': distance,
        'whatsapp': whatsapp,
        'createdAt': createdAt.millisecondsSinceEpoch,
        'modifiedAt': modifiedAt.millisecondsSinceEpoch,
        'verificationStatus': verificationStatus,
        'gpay': gpay,
        'paytm': paytm,
        'applepay': applepay,
        'offer': offer != null ? offer.toJson() : null,
        'phone': phone
      };

  List<dynamic> usersToJson(List<MetaUser> users) {
    List<dynamic> usersJson = new List<dynamic>();
    if (users == null) return usersJson;
    for (MetaUser usr in users) {
      usersJson.add(usr.toJson());
    }
    return usersJson;
  }

  List<dynamic> employeesToJson(List<Employee> emps) {
    List<dynamic> usersJson = new List<dynamic>();
    if (emps == null) return usersJson;
    for (Employee emp in emps) {
      usersJson.add(emp.toJson());
    }
    return usersJson;
  }

  List<dynamic> metaEntitiesToJson(List<MetaEntity> metaEntities) {
    List<dynamic> usersJson = new List<dynamic>();
    if (metaEntities == null) return usersJson;
    for (MetaEntity meta in metaEntities) {
      usersJson.add(meta.toJson());
    }
    return usersJson;
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
        //admins: convertToUsersFromJson(json['admins']),
        managers: convertToEmployeesFromJson(json['managers']),
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
        type: json['type'],
        isBookable: json['isBookable'],
        isActive: json['isActive'],
        coordinates: MyGeoFirePoint.fromJson(json['coordinates']),
        distance: json['distance'],
        whatsapp: json['whatsapp'],
        createdAt: new DateTime.fromMillisecondsSinceEpoch(json['createdAt']),
        modifiedAt: new DateTime.fromMillisecondsSinceEpoch(json['modifiedAt']),
        verificationStatus: json['verificationStatus'],
        gpay: json['gpay'],
        paytm: json['paytm'],
        applepay: json['applepay'],
        offer: Offer.fromJson(json['offer']),
        phone: json['phone']);
  }

  static Address convertToAddressFromJson(Map<String, dynamic> json) {
    return Address.fromJson(json);
  }

  static List<MetaUser> convertToUsersFromJson(List<dynamic> usersJson) {
    List<MetaUser> users = new List<MetaUser>();
    if (usersJson == null) return users;

    for (Map<String, dynamic> json in usersJson) {
      MetaUser sl = MetaUser.fromJson(json);
      users.add(sl);
    }
    return users;
  }

  static List<Employee> convertToEmployeesFromJson(List<dynamic> usersJson) {
    List<Employee> users = new List<Employee>();
    if (usersJson == null) return users;

    for (Map<String, dynamic> json in usersJson) {
      Employee emp = Employee.fromJson(json);
      users.add(emp);
    }
    return users;
  }

  static List<MetaEntity> convertToMetaEntitiesFromJson(
      List<dynamic> metaEntityJson) {
    List<MetaEntity> metaEntities = new List<MetaEntity>();
    if (metaEntityJson == null) return metaEntities;

    for (Map<String, dynamic> json in metaEntityJson) {
      MetaEntity metaEnt = MetaEntity.fromJson(json);
      metaEntities.add(metaEnt);
    }
    return metaEntities;
  }

  static List<String> convertToClosedOnArrayFromJson(List<dynamic> daysJson) {
    List<String> days = new List<String>();
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
          gpay: gpay,
          paytm: paytm,
          applepay: applepay,
          offer: offer,
          phone: phone,
          address:
              (address != null) ? Utils.getFormattedAddress(address) : null,
          hasChildren: (childEntities != null && childEntities.length > 0)
              ? true
              : false,
          isBookable: isBookable);
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
      _meta.gpay = gpay;
      _meta.paytm = paytm;
      _meta.applepay = applepay;
      _meta.offer = offer;
      _meta.phone = phone;
      _meta.address =
          (address != null) ? Utils.getFormattedAddress(address) : null;
      _meta.hasChildren =
          (childEntities != null && childEntities.length > 0) ? true : false;
      _meta.isBookable = isBookable;
    }
    return _meta;
  }

  List<String> constructQueriableList(String string) {
    if (string == null) return new List<String>();
    String lowercased = string.toLowerCase();
    List<String> queriables = new List<String>();
    for (int i = 1; i <= lowercased.length; i++) {
      queriables.add(lowercased.substring(0, i));
    }
    return queriables;
  }
}
