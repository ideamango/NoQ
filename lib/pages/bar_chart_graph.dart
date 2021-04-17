import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:charts_flutter/flutter.dart' as charts;
import 'package:intl/intl.dart';
import 'package:noq/bar_chart_model.dart';
import 'package:noq/constants.dart';
import 'package:noq/db/db_model/meta_entity.dart';
import 'package:noq/db/db_model/user_token.dart';

class BarChartGraph extends StatefulWidget {
  //final String chartLength;
  final Map<String, TokenStats> dataMap;
  final MetaEntity metaEn;
  // final List<BarChartModel> tokenCreatedData;
  // final List<BarChartModel> tokenCancelledData;

  const BarChartGraph(
      {Key key,
      //  @required this.chartLength,
      @required this.dataMap,
      @required this.metaEn
      // @required this.tokenCreatedData,
      // @required this.tokenCancelledData,
      })
      : super(key: key);

  @override
  BarChartGraphState createState() => BarChartGraphState();
}

class BarChartGraphState extends State<BarChartGraph> {
  List<BarChartModel> _barChartList;
  Map<String, TokenStats> _dataMap;
  final List<BarChartModel> tokenCancelledData = [];
  final List<BarChartModel> tokenCreatedData = [];
  @override
  void initState() {
    // TODO: implement initState
    _dataMap = widget.dataMap;
    // int colorCount = 0;
    _dataMap.forEach((key, value) {
      // if (colorCount == createdColors.length) colorCount = 0;
      tokenCreatedData.add(BarChartModel(
        timeSlot: key,
        numOfTokens: value.numberOfTokensCreated,
        color: charts.ColorUtil.fromDartColor(Colors.blue[300]),
      ));
      tokenCancelledData.add(BarChartModel(
        timeSlot: key,
        numOfTokens: value.numberOfTokensCancelled,
        color: charts.ColorUtil.fromDartColor(Colors.orange[200]),
      ));
      //colorCount++;
    });

    super.initState();
    // if (this.widget.chartLength == "today")
    _barChartList = [
      BarChartModel(
          date: DateFormat(dateDisplayFormat).format(DateTime.now()),
          color: null),
    ];
    // if (this.widget.chartLength == "month")
    //   _barChartList = [
    //     BarChartModel(
    //         date: DateFormat(dateDisplayFormat).format(DateTime.now())),
    //   ];
  }

  @override
  Widget build(BuildContext context) {
    List<charts.Series<BarChartModel, String>> series = [
      charts.Series(
        id: "Booked",
        data: tokenCreatedData,
        domainFn: (BarChartModel series, _) => series.timeSlot,
        measureFn: (BarChartModel series, _) => series.numOfTokens,
        colorFn: (BarChartModel series, _) => series.color,
        labelAccessorFn: (BarChartModel series, _) => '${series.numOfTokens}',
      ),
      charts.Series(
        id: "Cancelled",
        data: tokenCancelledData,
        domainFn: (BarChartModel series, _) => series.timeSlot,
        measureFn: (BarChartModel series, _) => series.numOfTokens,
        colorFn: (BarChartModel series, _) => series.color,
        labelAccessorFn: (BarChartModel series, _) => '${series.numOfTokens}',
      ),
    ];

    return _buildFinancialList(series);
  }

  // _onSelectionChanged(charts.SelectionModel model) {
  //   final selectedDatum = model.selectedDatum;
  //   print("afdfgsdf" + selectedDatum.length.toString());

  //   if (selectedDatum.isNotEmpty) {
  //     setState(() {
  //       print(selectedDatum.first.datum.sales);
  //     });
  //   }
  // }

  refresh() {
    setState(() {
      print("REWQDFQWDWUEDGWYEG");
    });
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
                        barGroupingType: charts.BarGroupingType.grouped,
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
                        defaultInteractions: false,
                        domainAxis: new charts.OrdinalAxisSpec(
                            showAxisLine: true,
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
                        // selectionModels: [
                        //   new charts.SelectionModelConfig(
                        //     type: charts.SelectionModelType.info,
                        //     changedListener: _onSelectionChanged,
                        //   )
                        // ],

                        selectionModels: [
                          new charts.SelectionModelConfig(
                            type: charts.SelectionModelType.info,
                            changedListener: (model) {
                              print(
                                  'Change in ${model.selectedDatum.first.datum}');
                            },
                            updatedListener: (model) {
                              print('updatedListener in $model');
                            },
                          ),
                        ],
                        barRendererDecorator:
                            new charts.BarLabelDecorator<String>(
                          labelPosition: charts.BarLabelPosition.inside,
                          labelAnchor: charts.BarLabelAnchor.end,
                        ),
                        primaryMeasureAxis: new charts.NumericAxisSpec(
                            renderSpec: new charts.NoneRenderSpec()),
                        // primaryMeasureAxis: new charts.NumericAxisSpec(
                        //     tickProviderSpec:
                        //         new charts.BasicNumericTickProviderSpec(
                        //             desiredTickCount: 1)),
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
