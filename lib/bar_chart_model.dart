import 'package:charts_flutter/flutter.dart' as charts;

class BarChartModel {
  String date;
  String timeSlot;
  int numOfTokens;
  final charts.Color color;

  BarChartModel({
    this.date,
    this.timeSlot,
    this.numOfTokens,
    this.color,
  });
}
