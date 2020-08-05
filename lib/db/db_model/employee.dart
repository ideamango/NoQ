import 'package:noq/db/db_model/user.dart';
import 'package:noq/utils.dart';

class Employee {
  String name;
  String employeeId;
  String ph;
  int shiftStartHour;
  int shiftStartMinute;
  int shiftEndHour;
  int shiftEndMinute;
  List<String> daysOff;
  bool isManager;
  String altPhone;

  Employee(
      {this.name,
      this.ph,
      this.employeeId,
      this.shiftStartHour,
      this.shiftStartMinute,
      this.shiftEndHour,
      this.shiftEndMinute,
      this.daysOff,
      this.isManager,
      this.altPhone});

  static Employee fromJson(Map<String, dynamic> json) {
    if (json == null) return null;
    return Employee(
        employeeId: json['employeeId'],
        name: json['name'],
        ph: json['ph'],
        shiftStartHour: json['shiftStartHour'],
        shiftStartMinute: json['shiftStartMinute'],
        shiftEndHour: json['shiftEndHour'],
        shiftEndMinute: json['shiftEndMinute'],
        daysOff: convertList(json['daysOff']),
        isManager: json['isManager'],
        altPhone: json['altPhone']);
  }

  static List<String> convertList(List<dynamic> list) {
    List<String> newList = new List();
    if (Utils.isNullOrEmpty(list)) return newList;
    for (dynamic day in list) {
      newList.add(day.toString());
    }
    return newList;
  }

  Map<String, dynamic> toJson() => {
        'employeeId': employeeId,
        'name': name,
        'ph': ph,
        'shiftStartHour': shiftStartHour,
        'shiftStartMinute': shiftStartMinute,
        'shiftEndHour': shiftEndHour,
        'shiftEndMinute': shiftEndMinute,
        'daysOff': daysOff,
        'isManager': isManager,
        'altPhone': altPhone
      };
}
