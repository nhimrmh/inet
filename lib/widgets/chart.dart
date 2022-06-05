import 'dart:async';

import 'package:colour/colour.dart';
import 'package:fl_animated_linechart/chart/animated_line_chart.dart';
import 'package:fl_animated_linechart/chart/line_chart.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:page_transition/page_transition.dart';
import 'package:inet/config/config.dart';
import 'package:inet/main/layout_chart.dart';
import 'package:inet/models/logger_data.dart';

import '../main.dart';

final GlobalKey<ChannelChartState> chartKey = new GlobalKey<ChannelChartState>();

class ChannelChart extends StatefulWidget {
  bool isLoadingData = false;
  LineChart lineChart;
  Map<DateTime, double> chartData = new Map<DateTime, double>();
  String currentLogger = "", currentChannel = "";
  Function setChartChanged;
  List<LoggerData> listLogger;

  ChannelChart(this.isLoadingData, this.lineChart, this.chartData,
      this.currentLogger, this.currentChannel, this.setChartChanged, this.listLogger) : super(key: chartKey);

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return ChannelChartState(isLoadingData, lineChart, chartData, currentChannel, currentChannel, setChartChanged, listLogger);
  }
}

class ChannelChartState extends State<ChannelChart> {

  bool isLoadingData = false;
  bool isError = false;
  bool isCancel = false;
  LineChart lineChart;
  Map<DateTime, double> chartData = new Map<DateTime, double>();
  String currentLogger = "", currentChannel = "";
  Function setChartChanged;
  Timer t;
  List<LoggerData> listLogger;
  int maxDateTime;

  ChannelChartState(this.isLoadingData, this.lineChart, this.chartData,
      this.currentLogger, this.currentChannel, this.setChartChanged, this.listLogger);

  //Chart Functions

  void setMaxDateTime(int datetime) {
    setState(() {
      maxDateTime = datetime;
    });
  }

  void setNewLineChart(LineChart newLineChart) {
    setState(() {
      lineChart = newLineChart;
      flagChartClicked = false;
    });
  }

  void setChartInfo(String loggerNAme, String channelName, bool isFinal) {
    if(mounted) {
      setState(() {
        t.cancel();
        isCancel = true;
        currentLogger = loggerNAme;
        currentChannel = channelName;
        isError = false;
        if(isFinal) {
          isLoadingData = false;
        }
      });
    }
  }

  void setDataChart(LoggerData logger, String channelName){
    setState(() {
      isLoadingData = true;
      isCancel = false;
    });

    int idx = 1;
    for (var element in listSocket) {
      isReceivedChartQuery[idx.toString()] = false;
      mapNameChartQuery[idx] = logger.objName;
      socketService.getDataChart(logger.objName, channelName, 1000, "", "", setChartChanged, element, idx, listSocket.length, idx.toString());
      idx++;
    }

    t = Timer(Duration(seconds: 5), () {
      if(!isCancel) {
        setState(() {
          isLoadingData = false;
          isError = true;
        });
      }
    });
  }
  //End Chart Functions

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Container(
      transform: Matrix4.translationValues(0, 10, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          chartData.isEmpty ? Container() : Container(
            margin: EdgeInsets.only(top: 10, right: 25, left: 25),
            padding: EdgeInsets.only(left: 10, right: 10, top: 5, bottom: 5),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(child: Text(chartData.isEmpty ? "" : "Logger: " + currentLogger + ", Channel: " + currentChannel, style: Theme.of(context).textTheme.subtitle1.merge(TextStyle(color: Colors.white)),),),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    GestureDetector(
                      onTap: (){
                        Navigator.push(
                          context,
                          PageTransition(
                            type: PageTransitionType.rightToLeft,
                            child: ChartView(lineChart, chartData, currentLogger, currentChannel, listLogger, maxDateTime),
                          ),
                        );
                      },
                      child: Container(
                        margin: EdgeInsets.only(right: 5),
                        child: Icon(Icons.fullscreen, color: Colors.white,),
                      ),
                    ),
                    GestureDetector(
                      onTap: (){
                        setState(() {
                          chartData.clear();
                        });
                      },
                      child: Container(
                        child: Icon(Icons.close, color: Colors.red,),
                      ),
                    )
                  ],
                )
              ],
            ),
            decoration: BoxDecoration(
                color: Colour("#246EE9")
            ),
          ),
          isLoadingData ? Container(
              height: 200,
              margin: EdgeInsets.only(top: 10, right: 25, left: 25),
              child: Center(
                child: Container(
                  width: 50,
                  height: 50,
                  child: CircularProgressIndicator(),
                ),
              )
          ) : isError ? Container() : Container(
              height: chartData.isEmpty ? 0 : 200,
              margin: EdgeInsets.only(top: 15, right: 25, left: 25),
              child: chartData.isEmpty ? Container() : AnimatedLineChart(
                lineChart,
                key: UniqueKey(),
              )
          ),
        ],
      )
    );
  }

}