import 'dart:async';
import 'dart:convert';

import 'package:colour/colour.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../classes/get_date.dart';
import '../classes/get_unit_name.dart';
import '../config/config.dart';
import '../main.dart';
import '../main/logger_detail.dart';
import '../models/channel_measure.dart';
import '../models/chart_data.dart';
import '../models/chart_data_id.dart';
import '../models/dashboard_content.dart';
import '../models/field_logger_data.dart';
import '../models/logger_data.dart';
import '../models/logger_point.dart';
import '../widgets/loading.dart';
import 'chart_view.dart';

class LoggerInformation extends StatefulWidget {
  LoggerData data;

  LoggerInformation(this.data);

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return LoggerInformationState();
  }

}

class LoggerInformationState extends State<LoggerInformation> {

  String currentAddress = "";
  String currentName = "";
  String currentDMA = "";
  bool isLoadingData = true;
  List<ChartDataID> chartData = [];
  List<String> listCurrentLoggers = [], listCurrentChannels = [];
  bool isCancel = false, isError = false, isReceivedChart = false;
  Timer loadTimer;
  List<String> listChannelsExist = [];
  List<DashboardElement> listQueryChart = [];

  @override
  void initState() {
    super.initState();
    getChannelsExist();
    createListQuery();
    getDataChart();
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build

    try {
      LoggerPoint tempAddress = listAddresses.where((element) => element.maLogger == widget.data.objName).first;
      if(tempAddress != null) {
        if(tempAddress.dma != null && tempAddress.dma != "") {
          currentAddress = tempAddress.dma;
        }
        else {
          currentAddress = tempAddress.tenLogger;
        }

        if(tempAddress.tenLogger != null && tempAddress.tenLogger != "") {
          currentName = tempAddress.tenLogger;
        }
        else {
          currentName = "";
        }

        if(tempAddress.dma != null && tempAddress.dma != "") {
          currentDMA = tempAddress.dma;
        }
        else {
          currentDMA = "";
        }
      }
    }
    catch(e) {

    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text("Thông số", style: TextStyle(color: Colour("#051639")),),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
            onPressed: (){
              Navigator.of(context).pop();
            },
            icon: Icon(Icons.arrow_back, color: Colour("#051639"),)
        ),
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.only(top: 15, bottom: 15, left: 25, right: 25),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(currentName != "" ? (currentName + (widget.data.objName != null ? (" (" + widget.data.objName +  ")") : "")) : (widget.data.objName ?? ""), style: Theme.of(context).textTheme.headline1.merge(const TextStyle(color: Colors.white)),),
                Container(
                  margin: const EdgeInsets.only(top: 10, bottom: 0),
                  child: Text(currentDMA.trim() == "" ? "Chưa có DMA" : currentDMA, style: Theme.of(context).textTheme.subtitle2.merge(const TextStyle(color: Colors.white))),
                )
              ],
            ),
            decoration: BoxDecoration(
                color: Colour("#243347"),
                borderRadius: const BorderRadius.all(Radius.circular(5))
            ),
          ),
          isLoadingData ? Container(
            height: 300,
            margin: const EdgeInsets.only(top: 15, right: 25, left: 25),
            child: loading(Theme.of(context), "chart"),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.black26, width: 1),
              borderRadius: const BorderRadius.all(const Radius.circular(10))
            ),
          ) : (chartData != null && chartData.isNotEmpty ? Container(
            margin: const EdgeInsets.only(top: 15, right: 25, left: 25),
            width: double.infinity,
            height: 300,
            child: MyChart(chartData, title: "Loggers: ${listCurrentLoggers.toSet().toList()}, Channels: ${listCurrentChannels.toSet().toList()}", listLoggerID: listCurrentLoggers, listChannel: listCurrentChannels,),
          ) : Container()),
          Expanded(child: Container(
            margin: const EdgeInsets.only(top: 15),
            padding: const EdgeInsets.only(left: 15, right: 15),
            child: ListView(children: [LoggerDetail(widget.data)],),
          ))
        ],
      )
    );
  }

  void getChannelsExist() {
    for(var item in widget.data.listElements) {
      if(listChannelSelectForMap.contains(item.fieldName)) {
        listChannelsExist.add(item.fieldName);
      }
    }
  }

  void createListQuery() {
    for(var item in listChannelsExist) {
      DashboardElement temp = DashboardElement()
          ..loggerID = widget.data.objName
          ..rawName = item;
      listQueryChart.add(temp);
      listCurrentLoggers.add(widget.data.objName);
      listCurrentChannels.add(getChannelName(item));
    }
  }

  void getDataChart(){
    setState(() {
      isCancel = false;
    });

    int socketID = 1;
    for (var element in listSocket) {
      socketService.getMultipleDataChart(listQueryChart, 500, "", "", setChartChanged, element, socketID, listSocket.length);
      socketID++;
    }

    loadTimer = Timer(const Duration(seconds: 5), () {
      if(mounted && !isCancel) {
        setState(() {
          isLoadingData = false;
          isError = true;
        });
      }
    });
  }

  void setChartChanged(String result) {
    if(mounted && !isReceivedChart && result.replaceAll("[]", "").isNotEmpty) {
      isReceivedChart = true;
      List<dynamic> jsonResult = json.decode(result);
      for (var jsonField in jsonResult) {
        ///data of chart
        List<ChartData> currentChartData = [];
        Map<String, dynamic> mapElement = Map<String, dynamic>.from(jsonField);
        mapElement.forEach((key, value) {
          if(key == "listElement") {
            List<dynamic> listElements = value;
            for (var detail in listElements) {
              Map<String, dynamic> mapField = Map<String, dynamic>.from(detail);
              mapField.forEach((key, value) {
                if(key == "value") {
                  Map<String, String> mapValue = Map<String, String>.from(value);
                  mapValue.forEach((key, value) {
                    try {
                      ChartData tempChartData = ChartData(getDateString1(int.parse(key)), double.parse(value));
                      currentChartData.add(tempChartData);
                    }
                    catch(e) {

                    }
                  });

                }
              });
            }
          }
        });

        setState(() {
          ChartDataID temp = ChartDataID()
            ..id = ""
            ..chartData = currentChartData;
          chartData.add(temp);
        });
      }

      setState(() {
        isLoadingData = false;
        isError = false;
      });
    }
  }
}