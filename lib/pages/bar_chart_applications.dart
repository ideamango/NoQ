import 'package:flutter/material.dart';
import 'package:charts_flutter/flutter.dart' as charts;
import '../bar_chart_model.dart';
import '../db/db_model/meta_entity.dart';
import '../db/db_model/user_token.dart';
import '../pages/bar_chart_graph.dart';
import '../pages/entity_token_list_page.dart';
import '../pages/manage_entity_list_page.dart';
import '../utils.dart';
import '../widget/appbar.dart';

class BarChartApplications extends StatefulWidget {
  final Map<String, int> dataMap;
  final MetaEntity? metaEn;
  BarChartApplications({Key? key, required this.dataMap, required this.metaEn})
      : super(key: key);
  @override
  _BarChartApplicationsState createState() => _BarChartApplicationsState();
}

class _BarChartApplicationsState extends State<BarChartApplications> {
  late Map<String, int> _dataMap;
  List<dynamic> colors = [
    charts.ColorUtil.fromDartColor(Colors.pink[200]!),
    charts.ColorUtil.fromDartColor(Colors.green[200]!),
    charts.ColorUtil.fromDartColor(Colors.yellow[200]!),
    charts.ColorUtil.fromDartColor(Colors.red[200]!),
    charts.ColorUtil.fromDartColor(Colors.lightBlueAccent[200]!),
    charts.ColorUtil.fromDartColor(Colors.purple[200]!),
    charts.ColorUtil.fromDartColor(Colors.indigoAccent[200]!)
  ];

  final List<BarChartModel> data = [
    // BarChartModel(
    //   timeSlot: "10:15",
    //   numOfTokens: 20,
    //   color: charts.ColorUtil.fromDartColor(Color(0xFF47505F)),
    // ),
    // BarChartModel(
    //   timeSlot: "11:15",
    //   numOfTokens: 30,
    //   color: charts.ColorUtil.fromDartColor(Colors.red),
    // ),
    // BarChartModel(
    //   timeSlot: "12:15",
    //   numOfTokens: 20,
    //   color: charts.ColorUtil.fromDartColor(Colors.green),
    // ),
    // BarChartModel(
    //   timeSlot: "1:15",
    //   numOfTokens: 45,
    //   color: charts.ColorUtil.fromDartColor(Colors.yellow),
    // ),
    // BarChartModel(
    //   timeSlot: "2:15",
    //   numOfTokens: 63,
    //   color: charts.ColorUtil.fromDartColor(Colors.lightBlueAccent),
    // ),
    // BarChartModel(
    //   timeSlot: "3:15",
    //   numOfTokens: 100,
    //   color: charts.ColorUtil.fromDartColor(Colors.pink),
    // ),
    // BarChartModel(
    //   timeSlot: "4:15",
    //   numOfTokens: 40,
    //   color: charts.ColorUtil.fromDartColor(Colors.purple),
    // ),
  ];

  @override
  void initState() {
    // TODO: build data for bar graph using token map
    _dataMap = widget.dataMap;
    int colorCount = 0;
    _dataMap.forEach((key, value) {
      if (colorCount == colors.length) colorCount = 0;
      data.add(BarChartModel(
        timeSlot: key,
        numOfTokens: value,
        color: colors[colorCount],
      ));
      colorCount++;
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Text("Testing");
    //  Container(
    //   child:
    //   BarChartGraph(
    //     chartLength: "today",
    //     tokenCreatedData: data,
    //   ),
    // );
  }
}

// class BarChartModel {
//   String month;
//   String timeSlot;
//   int numOfTokens;
//   final charts.Color color;

//   BarChartModel({
//     this.month,
//     this.timeSlot,
//     this.numOfTokens,
//     this.color,
//   });
// }
