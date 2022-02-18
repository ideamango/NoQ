class DateTimeExt extends DateTime {
  DateTimeExt(int year,
      [int month = 1,
      int day = 1,
      int hour = 0,
      int minute = 0,
      int second = 0,
      int millisecond = 0,
      int microsecond = 0])
      : super(year, month = 1, day = 1, hour = 0, minute = 0, second = 0,
            millisecond = 0, microsecond = 0);

  String? toJson(String pattern) {
    try {
      return this.toString();
    } catch (e) {
      return null;
    }
  }
}
