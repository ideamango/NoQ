import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:charts_flutter/flutter.dart' as charts;
import 'package:intl/intl.dart';
import 'package:noq/bar_chart_model.dart';
import 'package:noq/constants.dart';
import 'package:noq/pages/bar_chart.dart';

class BarChartGraph extends StatefulWidget {
  final String chartLength;
  final List<BarChartModel> data;

  const BarChartGraph(
      {Key key, @required this.chartLength, @required this.data})
      : super(key: key);

  @override
  _BarChartGraphState createState() => _BarChartGraphState();
}

class _BarChartGraphState extends State<BarChartGraph> {
  List<BarChartModel> _barChartList;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    if (this.widget.chartLength == "today")
      _barChartList = [
        BarChartModel(
            date: DateFormat(dateDisplayFormat).format(DateTime.now())),
      ];
    if (this.widget.chartLength == "month")
      _barChartList = [
        BarChartModel(
            date: DateFormat(dateDisplayFormat).format(DateTime.now())),
      ];
  }

  @override
  Widget build(BuildContext context) {
    List<charts.Series<BarChartModel, String>> series = [
      charts.Series(
        id: "Tokens booked in a Day",
        data: widget.data,
        domainFn: (BarChartModel series, _) => series.timeSlot,
        measureFn: (BarChartModel series, _) => series.numOfTokens,
        colorFn: (BarChartModel series, _) => series.color,
        labelAccessorFn: (BarChartModel series, _) => '${series.numOfTokens}',
      ),
    ];

    return _buildFinancialList(series);
  }

  Widget _buildFinancialList(series) {
    return _barChartList != null
        ? ListView.separated(
            physics: NeverScrollableScrollPhysics(),
            separatorBuilder: (context, index) => Divider(
              color: Colors.white,
              height: 5,
            ),
            scrollDirection: Axis.vertical,
            shrinkWrap: true,
            itemCount: _barChartList.length,
            itemBuilder: (BuildContext context, int index) {
              return Container(
                height: MediaQuery.of(context).size.height / 2.3,
                padding: EdgeInsets.all(10),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(_barChartList[index].date,
                            style: TextStyle(
                                color: Colors.black,
                                fontSize: 22,
                                fontWeight: FontWeight.bold)),
                      ],
                    ),
                    Expanded(
                      child: charts.BarChart(
                        series,
                        animate: true,
                        // domainAxis: charts.OrdinalAxisSpec(
                        //   renderSpec:
                        //       charts.SmallTickRendererSpec(labelRotation: 60),
                        // )
                        domainAxis: new charts.OrdinalAxisSpec(
                          viewport: new charts.OrdinalViewport('AePS', 8),
                        ),
                        behaviors: [
                          new charts.SeriesLegend(),
                          new charts.SlidingViewport(),
                          new charts.PanAndZoomBehavior(),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          )
        : SizedBox();
  }
}
