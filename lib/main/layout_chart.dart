import 'dart:async';
import 'dart:convert';

import 'package:colour/colour.dart';
import 'package:fl_animated_linechart/chart/animated_line_chart.dart';
import 'package:fl_animated_linechart/chart/line_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:inet/classes/get_date.dart';
import 'package:inet/models/channel_measure.dart';
import 'package:inet/models/field_logger_data.dart';
import 'package:inet/models/logger_data.dart';
import 'package:inet/widgets/alert.dart';
import 'package:inet/widgets/chart.dart';
import 'package:inet/widgets/dropdown.dart';
import 'package:inet/widgets/loading.dart';
import 'package:inet/models/info_detail.dart';

import '../main.dart';
import 'package:inet/config/config.dart';

final GlobalKey<ChartDetailState> detailChartKey = new GlobalKey<ChartDetailState>();
final GlobalKey<FilterDetailState> filterChartKey = new GlobalKey<FilterDetailState>();


class ChartView extends StatelessWidget {
  LineChart lineChart;
  Map<DateTime, double> chartData;
  String currentLogger = "", currentChannel = "";
  List<LoggerData> listLogger;
  int maxDateTime;

  ChartView(
      this.lineChart, this.chartData, this.currentLogger, this.currentChannel, this.listLogger, this.maxDateTime);

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return GestureDetector(
      onTap: (){
        FocusManager.instance.primaryFocus?.unfocus();
        filterChartKey.currentState.setFocusChanged(false);
      },
      child: Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            title: Text("Chart", style: TextStyle(color: Colour("#051639")),),
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
          //searchBar
          body: ListView(
            children: [
              ChartDetail(lineChart, chartData, currentLogger, currentChannel),
              FilterDetail(currentLogger, currentChannel, listLogger, chartData, maxDateTime)
            ],
          )
      ),
    );
  }
}

class ChartDetail extends StatefulWidget {
  LineChart lineChart;
  Map<DateTime, double> chartData = new Map<DateTime, double>();
  String currentLogger = "", currentChannel = "";

  ChartDetail(
      this.lineChart, this.chartData, this.currentLogger, this.currentChannel) : super(key: detailChartKey);
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return ChartDetailState(lineChart, chartData, currentLogger, currentChannel);
  }
}

class ChartDetailState extends State<ChartDetail> {
  LineChart lineChart;
  Map<DateTime, double> chartData = new Map<DateTime, double>();
  String currentLogger = "", currentChannel = "";
  ChartDetailState(
      this.lineChart, this.chartData, this.currentLogger, this.currentChannel);

  bool isLoadingData = false;
  bool isError = false;

  Timer t;


  @override
  void initState() {
    super.initState();
  }

  void newLogger(String logger) {
    setState(() {
      currentLogger = logger;
    });
  }

  void setChartInfo(String loggerName, String channelName) {
    if(mounted) {
      setState(() {
        t.cancel();
        currentLogger = loggerName;
        currentChannel = channelName;
        isLoadingData = false;
        isError = false;
      });
    }
  }

  void setNewLineChart(LineChart newLineChart) {
    setState(() {
      lineChart = newLineChart;
    });
  }

  void setDataChart(String loggerName, String channelName, String fromDate, String toDate, int numberOfRecord){
    setState(() {
      isLoadingData = true;
    });
    if(numberOfRecord != 0) {
      int idx = 1;
      listSocket.forEach((element) {
        socketService.getDataChart(loggerName, channelName, numberOfRecord, "", "", setChartChanged, element, idx, listSocket.length);
        idx++;
      });
    }
    else {
      int idx = 1;
      listSocket.forEach((element) {
        socketService.getDataChart(loggerName, channelName, 1000, fromDate, toDate, setChartChanged, element, idx, listSocket.length);
        idx++;
      });
    }
    t = Timer(Duration(seconds: 10), () {
      setState(() {
        isLoadingData = false;
        isError = true;
      });
    });
  }

  void setChartChanged(String result) {
    if(mounted) {
      setState(() {
        chartData.clear();
      });
      print("List elements");
      print(result.toString());
      if(result != null && result.trim() != "") {
        List<dynamic> jsonResult = json.decode(result);

        jsonResult.forEach((jsonField) {
          Map<String, dynamic> mapElement = Map<String, dynamic>.from(jsonField);
          mapElement.forEach((key, value) {
            if(key == "listElement") {
              value.forEach((detail){
                Map<String, dynamic> mapField = Map<String, dynamic>.from(detail);
                mapField.forEach((key, value) {
                  if(key == "value") {

                    Map<String, String> mapValue = new Map<String, String>.from(value);
                    mapValue.forEach((key, value) {
                      try {
                        chartData[DateTime.fromMicrosecondsSinceEpoch(int.parse(key) * 1000)] = double.parse(value);
                      }
                      catch(e) {
                        chartData[DateTime.fromMicrosecondsSinceEpoch(int.parse(key) * 1000)] = 0;
                      }
                    });
                  }
                });
                filterChartKey.currentState.setChartData(chartData);
                lineChart = LineChart.fromDateTimeMaps([chartData], [Colors.green]);
                setNewLineChart(lineChart);
              });
            }
          });
        });

      }
    }
  }
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          margin: EdgeInsets.only(top: 10, right: 25, left: 25),
          padding: EdgeInsets.only(left: 10, right: 10, top: 5, bottom: 5),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(child: Text("Logger: " + currentLogger + ", Channel: " + currentChannel, style: Theme.of(context).textTheme.subtitle1.merge(TextStyle(color: Colors.white)),),),
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
        ) : Container(
            height: 200,
            margin: EdgeInsets.only(top: 15, right: 25, left: 25),
            child: chartData == null || chartData.isEmpty ? Container(
              child: Center(
                child: emptyData(Theme.of(context), "Không có dữ liệu được gửi về theo ngày đã tìm")
              ),
            ) : AnimatedLineChart(
              lineChart,
              key: UniqueKey(),
            )
        ),
      ],
    );
  }
}

class FilterDetail extends StatefulWidget {
  List<LoggerData> listLogger;
  String currentLogger = "", currentChannel = "";
  Map<DateTime, double> chartData;
  int maxDateTime;

  FilterDetail(this.currentLogger, this.currentChannel, this.listLogger, this.chartData, this.maxDateTime) : super(key: filterChartKey);

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return FilterDetailState(currentLogger, currentChannel, listLogger, chartData, maxDateTime);
  }
}

class FilterDetailState extends State<FilterDetail> {
  bool isSearching = false;
  DateTime fromDatePicker, toDatePicker;
  TextEditingController searchController = new TextEditingController();
  List<LoggerData> listLogger;
  String currentLogger = "", currentChannel = "", currentNumber = "1000";
  List<String> listLoggerName = new List<String>();
  List<String> listLoggerChannel = new List<String>();
  List<String> listNumberOfRecord = new List<String>();
  Map<DateTime, double> chartData;
  int maxDateTime;
  int currentFilter = 1;

  FilterDetailState(this.currentLogger, this.currentChannel, this.listLogger, this.chartData, this.maxDateTime);

  List<Widget> buildDetailList() {
    int i = 0;
    List<Widget> resultWidgets = new List<Widget>();
    List<InfoDetail> listSortedDate = new List<InfoDetail>();
    chartData.forEach((key, value) {
      InfoDetail temp = new InfoDetail();
      temp.dateTime = key;
      temp.value = value;
      listSortedDate.add(temp);
    });

    ChannelMeasure currentMeasure = new ChannelMeasure();
    try {
      currentMeasure = listChannelMeasure.where((measure) => measure.channelID == currentChannel).first;
    }
    catch(e) {
      currentMeasure = null;
    }

    listSortedDate.sort((b,a) => a.dateTime.compareTo(b.dateTime));

    listSortedDate.forEach((element) {
      resultWidgets.add(
          new Container(
            padding: EdgeInsets.only(left: 15, right: 15, top: 5, bottom: 5),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(element.value.toString() + (currentMeasure != null ? " (" + currentMeasure.unit + ")" : "")),
                Text(fullDate(element.dateTime)),
              ],
            ),
            decoration: BoxDecoration(
              color: i % 2 == 1 ? Colour('#ECF2FF') : Colors.white,
            ),
          )
      );
      i++;
    });

    return resultWidgets;
  }

  void setChartData(Map<DateTime, double> newChartData) {
    setState(() {
      chartData = newChartData;
    });
  }

  void newChannel(String channel) {
    setState(() {
      currentChannel = channel;
    });
  }

  void newNumber(String newNumber) {
    setState(() {
      currentNumber = newNumber;
    });
  }

  void setFocusChanged(bool isFocused) {
    setState(() {
      print("Change focus to: " + isFocused.toString());
      isSearching = isFocused;
    });
  }

  void setListChannel(String newCurrentLogger) {
    setState(() {
      listLoggerChannel.clear();
      currentLogger = newCurrentLogger;
    });
    try {
      LoggerData temp = listLogger.where((element) => element.objName.trim() == newCurrentLogger.trim()).first;
      if(temp != null) {
        List<FieldLoggerData> listFields = temp.listElements;
        if(listFields.length > 0) {
          setState(() {
            currentChannel = listFields.first.fieldName;
            listFields.forEach((element) {
              listLoggerChannel.add(element.fieldName);
            });
          });
        }
        else {
          setState(() {
            listLoggerChannel.add("Không có channel");
            currentChannel = "Không có channel";
          });
        }
      }
      else {
        setState(() {
          listLoggerChannel.add("Không có channel");
          currentChannel = "Không có channel";
        });
      }
    }
    catch(e) {
      setState(() {
        listLoggerChannel.add("...");
        currentChannel = "...";
      });
    }
  }

  void setListLogger() {
    listLogger.forEach((element) {
      listLoggerName.add(element.objName);
    });
    setState(() {});
  }

  void setListNumberOfRecord() {
    listNumberOfRecord.add("10");
    listNumberOfRecord.add("100");
    listNumberOfRecord.add("1000");
    listNumberOfRecord.add("10000");
  }

  void newFromDate(DateTime newDate){
    try {
      setState(() {
        fromDatePicker = newDate;
      });
    }
    catch(e) {

    }
  }

  void newToDate(DateTime newDate) {
    try {
      setState(() {
        toDatePicker = newDate;
      });
    }
    catch(e) {

    }
  }

  void selectChannelFunction(String newLogger) {
    setState(() {
      searchController.text = newLogger;
    });
  }

  @override
  void initState() {
    super.initState();
    
    if(maxDateTime > 0) {
      fromDatePicker = getDateFromInt(maxDateTime);
      toDatePicker = getDateFromInt(maxDateTime);
    }
    else {
      fromDatePicker = DateTime.now();
      toDatePicker = DateTime.now();
    }
    setState(() {
      searchController.text = currentLogger;
    });
    setListLogger();
    setListChannel(currentLogger);
    setListNumberOfRecord();
    searchController.addListener(() {
      setListChannel(searchController.text);
    });
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Column(
      children: [
        Container(
          margin: EdgeInsets.only(top: 10, bottom: 10),
          height: 1,
          color: Colour("#d6d6d6"),
          width: double.infinity,
        ),
        Center(
            child: Container (
              margin: EdgeInsets.only(bottom: 15, top: 15),
              child: Text("Chọn thông tin logger cần xem", style: Theme.of(context).textTheme.headline1,),
            )
        ),
        Stack(
          children: [
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  child: Row(
                    children: [
                      Expanded(child: Container(
                          padding: EdgeInsets.only(left: 25, right: 25),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                  margin: EdgeInsets.only(bottom: 10),
                                  child: Text("Chọn logger", style: TextStyle(),)
                              ),
                              Container(
                                  margin: EdgeInsets.only(bottom: 9),
                                  height: 30,
                                  child: TextFormField(
                                    controller: searchController,
                                    autovalidateMode: AutovalidateMode.disabled,
                                    onChanged: (text){
                                      setState(() {

                                      });
                                    },
                                    onTap: () {
                                      setState(() {
                                        isSearching = true;
                                      });
                                    },
                                    decoration: InputDecoration(
                                      filled: true,
                                      fillColor: Colour('#F8FAFF'),
                                      contentPadding: EdgeInsets.only(top: 5, bottom: 5, left: 10, right: 10),
                                      hintText: "Nhập tên logger", hintStyle: TextStyle(fontSize: 14, fontWeight: FontWeight.w400),
                                      enabledBorder: OutlineInputBorder(
                                          borderSide: BorderSide(
                                              color: Colour('#D1DBEE'),
                                              width: 1
                                          )
                                      ),
                                      border: OutlineInputBorder(
                                          borderSide: BorderSide(
                                              color: Colour('#D1DBEE'),
                                              width: 1
                                          )
                                      ),

                                    ),
                                  )
                              ),

                            ],
                          )
                      )),
                      Expanded(child: DropDownChart("Chọn channel", listLoggerChannel, currentChannel, newChannel),)
                    ],
                  ),
                ),
                Container(
                  margin: EdgeInsets.only(bottom: 15, top: 15),
                  child: Row(
                    children: [
                      Expanded(child: GestureDetector(
                        onTap: (){
                          setState(() {
                            currentFilter = 0;
                          });
                        },
                        child: Container (
                          margin: EdgeInsets.only(right: 10),
                          child: Text("Lọc theo ngày", style: Theme.of(context).textTheme.headline1.merge(
                              TextStyle(
                                  fontWeight: currentFilter == 0 ? FontWeight.bold : FontWeight.w400
                              )
                          ), textAlign: TextAlign.right,),
                        ),
                      )),
                      Container(
                        width: 1,
                        height: 20,
                        color: Colors.black,
                      ),
                      Expanded(child: GestureDetector(
                        onTap: (){
                          setState(() {
                            currentFilter = 1;
                          });
                        },
                        child: Container (
                          margin: EdgeInsets.only(left: 10),
                          child: Text("Lọc theo số lượng", style: Theme.of(context).textTheme.headline1.merge(
                              TextStyle(
                                  fontWeight: currentFilter == 1 ? FontWeight.bold : FontWeight.w400
                              )
                          ), textAlign: TextAlign.left,),
                        ),
                      )),
                    ],
                  ),
                ),
                currentFilter == 0 ? Container(
                  margin: EdgeInsets.only(top: 15),
                  child: Row(
                    children: [
                      Expanded(child: DatePicker(this.context, "Từ ngày", simpleDate(fromDatePicker), fromDatePicker, newFromDate),),
                      Expanded(child: DatePicker(this.context, "Đến ngày", simpleDate(toDatePicker), toDatePicker, newToDate),),
                    ],
                  ),
                ) : Container(),
                currentFilter == 1 ? Container(
                  child: Row(
                    children: [
                      Expanded(child: DropDownChart("Số lượng", listNumberOfRecord, currentNumber, newNumber),),
                      Expanded(child: Container(
                        child: Text("record gần nhất",),
                      ))
                    ],
                  ),
                ) : Container(),
              ],
            ),
            Align(
                alignment: Alignment.topLeft,
                child: isSearching ? Container(
                  margin: EdgeInsets.only(left: 25, top: 65,),
                  width: MediaQuery.of(context).size.width/2 - 50,
                  height: 100,
                  child: ListView(
                    children: SearchResult(listLoggerName, searchController.text, selectChannelFunction),
                  ),
                  color: Colors.transparent,
                ) : Container()
            )
          ],
        ),
        Center(
            child: GestureDetector(
              onTap: (){
                if(currentChannel.trim() != "...") {
                  if(currentFilter == 0) {
                    detailChartKey.currentState.setDataChart(currentLogger, currentChannel, simpleDate(fromDatePicker), simpleDate(toDatePicker), 0);
                  }
                  else {
                    detailChartKey.currentState.setDataChart(currentLogger, currentChannel, simpleDate(fromDatePicker), simpleDate(toDatePicker), int.parse(currentNumber));
                  }
                }
                else {
                  showAlertDialog(context, "Không thể lấy dữ liệu", "Thông tin logger không đúng");
                }
              },
              child: Container(
                margin: EdgeInsets.only(top: 15, bottom: 15),
                padding: EdgeInsets.only(left: 15, right: 20, top: 10, bottom: 10),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.bar_chart, color: Colors.white,),
                    Container(
                      margin: EdgeInsets.only(left: 10),
                      child: Text("Xem dữ liệu", style: Theme.of(context).textTheme.subtitle1.merge(TextStyle(color: Colors.white)),),
                    )
                  ],
                ),
                decoration: BoxDecoration(
                    color: Colour('#246EE9'),
                    borderRadius: BorderRadius.all(Radius.circular(10)),
                    boxShadow: [
                      BoxShadow(
                          color: Color.fromRGBO(151, 161, 204, 0.5),
                          offset: Offset(
                              2,2
                          ),
                          blurRadius: 3,
                          spreadRadius: 0
                      )
                    ]
                ),
              ),
            )
        ),
        chartData != null && chartData.length > 0 ? Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              margin: EdgeInsets.only(top: 10, bottom: 10),
              height: 1,
              color: Colour("#d6d6d6"),
              width: double.infinity,
            ),
            Center(
                child: Container (
                  margin: EdgeInsets.only(bottom: 15, top: 15),
                  child: Text("Chi tiết dữ liệu", style: Theme.of(context).textTheme.headline1,),
                )
            ),
            Container(
              height: MediaQuery.of(context).size.height - 200,
              child: ListView(
                children: buildDetailList(),
              ),
            )
          ],
        ) : Container()
      ],
    );
  }
}