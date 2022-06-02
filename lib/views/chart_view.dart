import 'dart:math';

import 'package:flutter/material.dart';
import 'package:inet/models/chart_data.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class MyChart extends StatelessWidget {
  List<List<ChartData>> data = [];
  String title;

  MyChart(this.data, {this.title});

  ZoomPanBehavior _zoomPanBehavior = ZoomPanBehavior(
    // Enables pinch zooming
      enablePinching: true,
      enableDoubleTapZooming: true,
      enableSelectionZooming: true,
      enablePanning: true
  );

  void setTitle(String title) {
    this.title = title;
  }

  List<LineSeries<ChartData, String>> buildSeries() {
    var temp = data.map((e) {
      return LineSeries<ChartData, String>(
          dataSource: e,
          xValueMapper: (ChartData data, _) => data.timeStamp.toString(),
          yValueMapper: (ChartData data, _) => data.value,
          name: 'Giá trị',
          // Enable data label
          dataLabelSettings: DataLabelSettings(isVisible: false));
    }).toList();
    return temp;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.only(top: 5, bottom: 5, left: 10, right: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(title??"", style: const TextStyle(color: Colors.white),),
                GestureDetector(
                  onTap: () => _zoomPanBehavior.reset(),
                  child: const Icon(Icons.replay, color: Colors.white,),
                )
              ],
            ),
            decoration: BoxDecoration(
              color: Colors.blue,
              border: Border.all(width: 1, color: Colors.black26)
            ),
          ),
          Expanded(child: SfCartesianChart(
              primaryXAxis: CategoryAxis(
                // Axis will be rendered based on the index values
                  arrangeByIndex: true
              ),
              zoomPanBehavior: _zoomPanBehavior,
              legend: Legend(isVisible: false),
              tooltipBehavior: TooltipBehavior(enable: true),
              series: buildSeries()
          ))
        ],
      ),
      decoration: BoxDecoration(
        border: Border.all(width: 1, color: Colors.black26)
      ),
    );
  }
}