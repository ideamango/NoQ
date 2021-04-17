// import 'package:flutter/material.dart';
// import 'package:charts_flutter/flutter.dart' as charts;
// import 'package:noq/bar_chart_model.dart';
// import 'package:noq/db/db_model/meta_entity.dart';
// import 'package:noq/db/db_model/user_token.dart';
// import 'package:noq/pages/bar_chart_graph.dart';
// import 'package:noq/pages/entity_token_list_page.dart';
// import 'package:noq/pages/manage_entity_list_page.dart';
// import 'package:noq/utils.dart';
// import 'package:noq/widget/appbar.dart';

// class BarChartTokens extends StatefulWidget {
//   final Map<String, TokenStats> dataMap;
//   final MetaEntity metaEn;
//   BarChartTokens({Key key, @required this.dataMap, @required this.metaEn})
//       : super(key: key);
//   @override
//   _BarChartTokensState createState() => _BarChartTokensState();
// }

// class _BarChartTokensState extends State<BarChartTokens> {
//   Map<String, TokenStats> _dataMap;
//   List<dynamic> createdColors = [
//     // charts.ColorUtil.fromDartColor(Colors.pink[200]),
//     // charts.ColorUtil.fromDartColor(Colors.green[200]),
//     // charts.ColorUtil.fromDartColor(Colors.yellow[200]),
//     // charts.ColorUtil.fromDartColor(Colors.red[200]),
//     charts.ColorUtil.fromDartColor(Colors.lightBlue),
//     // charts.ColorUtil.fromDartColor(Colors.purple[200]),
//     // charts.ColorUtil.fromDartColor(Colors.indigoAccent[200])
//   ];
//   List<dynamic> cancelledColors = [
//     charts.ColorUtil.fromDartColor(Colors.orange[200]),
//   ];
//   final List<BarChartModel> tokenCancelledData = [
//     // BarChartModel(
//     //   timeSlot: "10:15",
//     //   numOfTokens: 10,
//     //   color: charts.ColorUtil.fromDartColor(Colors.lightBlueAccent[200]),
//     // ),
//     // BarChartModel(
//     //   timeSlot: "11:15",
//     //   numOfTokens: 0,
//     //   color: charts.ColorUtil.fromDartColor(Colors.lightBlueAccent[200]),
//     // ),
//     // BarChartModel(
//     //   timeSlot: "12:15",
//     //   numOfTokens: 5,
//     //   color: charts.ColorUtil.fromDartColor(Colors.lightBlueAccent[200]),
//     // ),
//     // BarChartModel(
//     //   timeSlot: "1:15",
//     //   numOfTokens: 4,
//     //   color: charts.ColorUtil.fromDartColor(Colors.lightBlueAccent[200]),
//     // ),
//     // BarChartModel(
//     //   timeSlot: "2:15",
//     //   numOfTokens: 70,
//     //   color: charts.ColorUtil.fromDartColor(Colors.lightBlueAccent[200]),
//     // ),
//     // BarChartModel(
//     //   timeSlot: "3:15",
//     //   numOfTokens: 10,
//     //   color: charts.ColorUtil.fromDartColor(Colors.lightBlueAccent[200]),
//     // ),
//     // BarChartModel(
//     //   timeSlot: "4:15",
//     //   numOfTokens: 4,
//     //   color: charts.ColorUtil.fromDartColor(Colors.lightBlueAccent[200]),
//     // ),
//   ];
//   final List<BarChartModel> tokenCreatedData = [
//     // BarChartModel(
//     //   timeSlot: "10:15",
//     //   numOfTokens: 20,
//     //   color: charts.ColorUtil.fromDartColor(Colors.orange[200]),
//     // ),
//     // BarChartModel(
//     //   timeSlot: "11:15",
//     //   numOfTokens: 30,
//     //   color: charts.ColorUtil.fromDartColor(Colors.orange[200]),
//     // ),
//     // BarChartModel(
//     //   timeSlot: "12:15",
//     //   numOfTokens: 20,
//     //   color: charts.ColorUtil.fromDartColor(Colors.orange[200]),
//     // ),
//     // BarChartModel(
//     //   timeSlot: "1:15",
//     //   numOfTokens: 45,
//     //   color: charts.ColorUtil.fromDartColor(Colors.orange[200]),
//     // ),
//     // BarChartModel(
//     //   timeSlot: "2:15",
//     //   numOfTokens: 63,
//     //   color: charts.ColorUtil.fromDartColor(Colors.orange[200]),
//     // ),
//     // BarChartModel(
//     //   timeSlot: "3:15",
//     //   numOfTokens: 100,
//     //   color: charts.ColorUtil.fromDartColor(Colors.orange[200]),
//     // ),
//     // BarChartModel(
//     //   timeSlot: "4:15",
//     //   numOfTokens: 40,
//     //   color: charts.ColorUtil.fromDartColor(Colors.orange[200]),
//     // ),
//   ];

//   @override
//   void initState() {
//     // TODO: build data for bar graph using token map
//     _dataMap = widget.dataMap;
//     int colorCount = 0;
//     _dataMap.forEach((key, value) {
//       if (colorCount == createdColors.length) colorCount = 0;
//       tokenCreatedData.add(BarChartModel(
//         timeSlot: key,
//         numOfTokens: value.numberOfTokensCreated,
//         color: charts.ColorUtil.fromDartColor(Colors.blue[300]),
//       ));
//       tokenCancelledData.add(BarChartModel(
//         timeSlot: key,
//         numOfTokens: value.numberOfTokensCancelled,
//         color: charts.ColorUtil.fromDartColor(Colors.orange[200]),
//       ));
//       colorCount++;
//     });

//     super.initState();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       child: BarChartGraph(
//         chartLength: "today",
//         tokenCreatedData: tokenCreatedData,
//         tokenCancelledData: tokenCancelledData,
//       ),
//     );
//   }
// }

// // class BarChartModel {
// //   String month;
// //   String timeSlot;
// //   int numOfTokens;
// //   final charts.Color color;

// //   BarChartModel({
// //     this.month,
// //     this.timeSlot,
// //     this.numOfTokens,
// //     this.color,
// //   });
// // }
