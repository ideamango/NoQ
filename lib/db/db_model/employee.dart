import 'package:noq/db/db_model/user.dart';

class Employee extends User {
  final int shiftStartHour;
  final int shiftStartMinute;
  final int shiftEndHour;
  final int shiftEndMinute;
  final List<String> daysOff;
  final bool isManager;

  Employee(
      {id,
      firebaseId,
      fn,
      ln,
      loc,
      ph,
      this.shiftStartHour,
      this.shiftStartMinute,
      this.shiftEndHour,
      this.shiftEndMinute,
      this.daysOff,
      this.isManager})
      : super(id: id, firebaseId: firebaseId, fn: fn, ln: ln, loc: loc, ph: ph);

  factory Employee.fromJson(Map<String, dynamic> parsedJson) {
    final User usr = User.fromJson(parsedJson);

    return Employee(
        id: usr.id,
        firebaseId: usr.firebaseId,
        fn: usr.fn,
        ln: usr.ln,
        ph: usr.ph,
        shiftStartHour: parsedJson['shiftStartHour'],
        shiftStartMinute: parsedJson['shiftStartMinute'],
        shiftEndHour: parsedJson['shiftEndHour'],
        shiftEndMinute: parsedJson['shiftEndMinute'],
        daysOff: parsedJson['daysOff'],
        isManager: parsedJson['isManager']);
  }
}
