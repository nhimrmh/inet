import 'dart:math';

import 'package:flutter/material.dart';
import 'package:inet/models/chart_data.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

import '../models/chart_data_id.dart';

class MyChart extends StatelessWidget {
  List<ChartDataID> data = [];
  String title;
  List<String> listLoggerID;
  List<String> listChannel;
  String previousLoggerName = "";
  String previousLoggerChannel = "";

  MyChart(this.data, {this.title, this.listLoggerID, this.listChannel});

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
    int idx = 0;
    List<LineSeries<ChartData, String>> resultWidgets = [];
    for(var item in data) {
      String _loggerName = "";
      String _channelName = "";
      try {
        _loggerName = listLoggerID?.elementAt(idx)??"";
        previousLoggerName = _loggerName;
      }
      catch(e) {
        _loggerName = previousLoggerName;
      }

      try {
        _channelName = listChannel?.elementAt(idx)??"";
        previousLoggerChannel = _channelName;
      }
      catch(e) {
        _channelName = previousLoggerChannel;
      }

      resultWidgets.add(LineSeries<ChartData, String>(
          dataSource: item.chartData,
          xValueMapper: (ChartData data, _) => data.timeStamp.toString(),
          yValueMapper: (ChartData data, _) => data.value,
          name: "$_loggerName($_channelName)",

          // Enable data label
          dataLabelSettings: const DataLabelSettings(isVisible: false))
      );
      idx++;
    }
    return resultWidgets;
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
                Expanded(child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(title??"", style: const TextStyle(color: Colors.white),)
                ),),
                Container(
                  margin: const EdgeInsets.only(left: 10),
                  child: GestureDetector(
                    onTap: () => _zoomPanBehavior.reset(),
                    child: const Icon(Icons.replay, color: Colors.white,),
                  ),
                )
              ],
            ),
            decoration: BoxDecoration(
              color: Colors.blue,
              border: Border.all(width: 1, color: Colors.black26),
              borderRadius: const BorderRadius.only(topLeft: Radius.circular(10), topRight: Radius.circular(10))
            ),
          ),
          Expanded(child: SfCartesianChart(
              primaryXAxis: CategoryAxis(
                // Axis will be rendered based on the index values
                  arrangeByIndex: true
              ),
              zoomPanBehavior: _zoomPanBehavior,
              legend: Legend(isVisible: true, position: LegendPosition.bottom),
              tooltipBehavior: TooltipBehavior(enable: true),
              series: buildSeries()
          ))
        ],
      ),
      decoration: BoxDecoration(
        border: Border.all(width: 1, color: Colors.black26),
        borderRadius: const BorderRadius.all(Radius.circular(10))
      ),
    );
  }
}