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
        id: "Booked Tokens for a day",
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
                height: MediaQuery.of(context).size.height * .8,
                padding: EdgeInsets.all(10),
                child: Column(
                  children: [
                    // Row(
                    //   mainAxisAlignment: MainAxisAlignment.center,
                    //   children: [
                    //     Text(_barChartList[index].date,
                    //         style: TextStyle(
                    //             color: Colors.black,
                    //             fontSize: 22,
                    //             fontWeight: FontWeight.bold)),
                    //   ],
                    // ),
                    Expanded(
                      child: charts.BarChart(
                        series,
                        animate: true,
                        vertical: false,
                        // domainAxis: charts.OrdinalAxisSpec(
                        //   renderSpec:
                        //       charts.SmallTickRendererSpec(labelRotation: 60),
                        // )

                        // domainAxis: new charts.OrdinalAxisSpec(
                        //     renderSpec: new charts.SmallTickRendererSpec(
                        //         labelRotation: 60,
                        //         // Tick and Label styling here.
                        //         labelStyle: new charts.TextStyleSpec(
                        //             fontSize: 8, // size in Pts.
                        //             color: charts.MaterialPalette.black),

                        //         // Change the line colors to match text color.
                        //         lineStyle: new charts.LineStyleSpec(
                        //             color: charts.MaterialPalette.black))),

                        /// Assign a custom style for the measure axis.
                        // primaryMeasureAxis: new charts.NumericAxisSpec(
                        //     renderSpec: new charts.GridlineRendererSpec(

                        //         // Tick and Label styling here.
                        //         labelStyle: new charts.TextStyleSpec(
                        //             fontSize: 10, // size in Pts.
                        //             color: charts.MaterialPalette.black),

                        //         // Change the line colors to match text color.
                        //         lineStyle: new charts.LineStyleSpec(
                        //             color: charts.MaterialPalette.black))),

                        domainAxis: new charts.OrdinalAxisSpec(
                            //  viewport: new charts.OrdinalViewport('AePS', 10),
                            renderSpec: new charts.SmallTickRendererSpec(
                                //labelRotation: 60,
                                // Tick and Label styling here.
                                labelStyle: new charts.TextStyleSpec(
                                    fontSize: 8, // size in Pts.
                                    color: charts.MaterialPalette.black),

                                // Change the line colors to match text color.
                                lineStyle: new charts.LineStyleSpec(
                                    color: charts.MaterialPalette.black))),
                        behaviors: [
                          new charts.SeriesLegend(),
                          new charts.SlidingViewport(),
                          new charts.PanAndZoomBehavior(),
                        ],
                        primaryMeasureAxis: new charts.NumericAxisSpec(
                            tickProviderSpec:
                                new charts.BasicNumericTickProviderSpec(
                                    desiredTickCount: 1)),
                        // secondaryMeasureAxis: new charts.NumericAxisSpec(
                        //     tickProviderSpec:
                        //         new charts.BasicNumericTickProviderSpec(
                        //             desiredTickCount: 3)),
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
