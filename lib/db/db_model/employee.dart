import 'package:noq/db/db_model/user.dart';

class Employee extends User {
  int shiftStartHour;
  int shiftStartMinute;
  int shiftEndHour;
  int shiftEndMinute;
  List<String> daysOff;
  bool isManager;
  String altPhone;

  Employee(
      {id,
      name,
      loc,
      ph,
      this.shiftStartHour,
      this.shiftStartMinute,
      this.shiftEndHour,
      this.shiftEndMinute,
      this.daysOff,
      this.isManager,
      this.altPhone})
      : super(id: id, name: name, loc: loc, ph: ph);

  factory Employee.fromJson(Map<String, dynamic> parsedJson) {
    final User usr = User.fromJson(parsedJson);

    return Employee(
        id: usr.id,
        name: usr.name,
        ph: usr.ph,
        loc: usr.loc,
        shiftStartHour: parsedJson['shiftStartHour'],
        shiftStartMinute: parsedJson['shiftStartMinute'],
        shiftEndHour: parsedJson['shiftEndHour'],
        shiftEndMinute: parsedJson['shiftEndMinute'],
        daysOff: parsedJson['daysOff'],
        isManager: parsedJson['isManager'],
        altPhone: parsedJson['altPhone']);
  }
}
