import 'dart:async';
import 'dart:convert';
import 'dart:ffi';
import 'dart:ui';

import 'package:colour/colour.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:fl_animated_linechart/chart/line_chart.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:inet/models/chart_data.dart';
import 'package:inet/views/chart_view.dart';

import 'package:latlong2/latlong.dart';
import 'package:page_transition/page_transition.dart';
import 'package:inet/config/config.dart';
import 'package:inet/main/logger_detail.dart';
import 'package:inet/models/alarm_type.dart';
import 'package:inet/models/channel_measure.dart';
import 'package:inet/models/field_logger_data.dart';
import 'package:inet/models/logger_data.dart';

import 'package:inet/widgets/chart.dart';
import 'package:inet/widgets/loading.dart';
import '../classes/get_date.dart';
import '../data/dashboard_data.dart';
import '../main.dart';
import '../models/alarm_logger.dart';
import '../models/logger_point.dart';
import 'dashboard_view.dart';
import 'map_view.dart';

class MyHomePage extends StatefulWidget {
  String username, password;

  MyHomePage({Key key, this.username, this.password}) : super(key: key);

  @override
  MyHomePageState createState(){
    return MyHomePageState();
  }
}

class MyHomePageState extends State<MyHomePage> with TickerProviderStateMixin {
  ///Main variables
  TabController tabController;
  int currentTabIndex = 0;

  ///Datatable variables
  bool isGotData = false, isInit = true, isCancel = false, isNoInternet = false, isError = false;
  String resultString = "";
  TextEditingController searchController = TextEditingController();
  int tabIdx = 0;

  ///Check connection variables
  final Connectivity _connectivity = Connectivity();
  StreamSubscription<ConnectivityResult> _connectivitySubscription;
  Timer loadTimer;

  //Chart variables
  bool isLoadingData = false;
  LineChart lineChart;
  List<List<ChartData>> chartData = [];
  String currentLogger = "", currentChannel = "";

  @override
  void initState() {
    super.initState();

    isSendingQuery = false;
    isCancel = false;

    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent
    ));

    getAddresses();

    ///init connect to server
    initConnectivity();
    _connectivitySubscription =
        _connectivity.onConnectivityChanged.listen(_updateConnectionStatus);

    tabController = TabController(length: 3, vsync: this);

    tabController.addListener(doOnTabChange);

  }

  @override
  void dispose() {
    _connectivitySubscription.cancel();
    isReceivedDashboardChart = false;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onTap: (){
          FocusManager.instance.primaryFocus?.unfocus();
        },
        child: DefaultTabController(
          length: 3,
          child: Scaffold(
              backgroundColor: Colors.white,
              appBar: AppBar(
                title: Text("Monitor", style: TextStyle(color: Colour("#051639")),),
                centerTitle: true,
                backgroundColor: Colors.white,
                elevation: 0,
                leading: IconButton(
                    onPressed: (){
                      Navigator.of(context).pop();
                    },
                    icon: Icon(Icons.arrow_back, color: Colour("#051639"),)
                ),
                actions: [
                  tabIdx == 2 ? IconButton(
                      onPressed: (){
                        if(mapKey.currentState?.getIsInitAlarm() == false) {
                          mapKey.currentState.initAlarm();
                          mapKey.currentState.setIsInitAlarm(true);
                        }

                        setState(() {
                          if(mapKey.currentState.getViewMenu() != 1) {
                            mapKey.currentState.setViewMenu(1);
                            mapKey.currentState.setIsViewMenu(true);
                          }
                          else {
                            mapKey.currentState.setIsViewMenu(!mapKey.currentState.getIsViewMenu());
                          }
                          mapKey.currentState.setIsSearch(false);
                          FocusManager.instance.primaryFocus?.unfocus();
                        });
                      },
                      icon: Icon(Icons.filter_alt, color: Colour("#051639"),)
                  ) : Container()
                ],
                bottom: TabBar(
                  physics: tabIdx == 2 ? const NeverScrollableScrollPhysics() : const AlwaysScrollableScrollPhysics(),
                  controller: tabController,
                  isScrollable: true,
                  tabs: [
                    Tab(icon: Text("Dashboard", style: Theme.of(context).textTheme.subtitle1,)),
                    Tab(icon: Text("Datatable", style: Theme.of(context).textTheme.subtitle1,)),
                    Tab(icon: Text("Map", style: Theme.of(context).textTheme.subtitle1,)),
                  ],
                ),

              ),
              //searchBar
              body: TabBarView(
                physics: tabIdx == 2 ? const NeverScrollableScrollPhysics() : const AlwaysScrollableScrollPhysics(),
                controller: tabController,
                children: myTabWidget(),
              )
          ),
        )
    );
  }

  Widget DatatableView() {
    return isNoInternet ? loadError(retrySocketIO, Theme.of(context), 0, "") : isGotData == true ? Container(
      width: double.infinity,
      height: double.infinity,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
              margin: const EdgeInsets.only(top: 20),
              child: Container(
                margin: const EdgeInsets.only(left: 20, right: 20),
                child: TextFormField(
                  controller: searchController,
                  autovalidateMode: AutovalidateMode.disabled,
                  onChanged: (text){
                    searchData(text);
                  },
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colour('#F8FAFF'),
                    contentPadding: const EdgeInsets.only(top: 6, bottom: 6, left: 15, right: 15),
                    suffixIcon: IconButton(
                      onPressed: (){
                            (){};
                      },
                      icon: Icon(Icons.search, color: Colour('#666D75'), size: 30,),
                    ),
                    hintText: "Nhập thông tin logger cần tìm", hintStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w400),
                    enabledBorder: OutlineInputBorder(
                        borderRadius: const BorderRadius.all(Radius.circular(20)),
                        borderSide: BorderSide(
                            color: Colour('#D1DBEE'),
                            width: 1
                        )
                    ),
                    border: OutlineInputBorder(
                        borderRadius: const BorderRadius.all(const Radius.circular(20)),
                        borderSide: BorderSide(
                            color: Colour('#D1DBEE'),
                            width: 1
                        )
                    ),

                  ),
                ),
              )
          ),
          isLoadingData ? Container(
              height: 200,
              margin: const EdgeInsets.only(top: 10, right: 25, left: 25),
              child: miniLoading()
          ) : (chartData != null && chartData.isNotEmpty ? Container(
            margin: const EdgeInsets.only(top: 15, right: 25, left: 25),
            width: double.infinity,
            height: 300,
            child: MyChart(chartData, title: "Logger: $currentLogger, channel: $currentChannel",),
          ) : Container()),
          // ChannelChart(isLoadingData, lineChart, chartData, currentChannel, currentChannel, setChartChanged, storedData),
          Container(
              margin: const EdgeInsets.only(left: 25, right: 25, bottom: 20, top: 15),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("Danh sách logger", style: Theme.of(context).textTheme.headline2,),
                  // GestureDetector(
                  //   onTap: (){
                  //
                  //   },
                  //   child: Image.asset("assets/filter.png", scale: 1,),
                  // )
                ],
              )
          ),
          Expanded(child: ListView(
            children: buildListLoggers(listData),
          ))
        ],
      ),
    ) : isError ? loadError(retrySocketIO, Theme.of(context), 1, "logger") : loading(Theme.of(context), "logger");
  }

  List<Widget> myTabWidget() {
    List<Widget> resultWidget = List<Widget>();

    resultWidget.add(
        DashboardView(key: dashboardKey, username: widget.username, password: widget.password,)
    );

    resultWidget.add(
        DatatableView()
    );

    resultWidget.add(
        GisMapView(key: mapKey,)
    );

    return resultWidget;
  }

  void doOnTabChange() {
    switch(tabController.index) {
      case 0: {
        if(!tabController.indexIsChanging) {
          setState(() {
            tabIdx = 0;
            mapKey.currentState?.setIsLoadingMap(true);
          });

          if(dashboardKey.currentState.getError()) {
            dashboardKey.currentState.setLoading(true);
            retrySocketIO();
          }
          else {
            dashboardKey.currentState.loadDashboard();
          }
        }
        break;
      }
      case 1: {
        if(!tabController.indexIsChanging) {
          setState(() {
            tabIdx = 1;
            mapKey.currentState?.setIsLoadingMap(true);
          });
          if(dashboardKey.currentState?.getError() == true) {
            retrySocketIO();
          }
        }
        break;
      }
      case 2: {

        if(!tabController.indexIsChanging) {

          setState(() {
            tabIdx = 2;
            mapKey.currentState.setIsLoadingMap(true);

            globalMapController = MapController();
            if(!mapKey.currentState.getIsInitMap()) {
              mapKey.currentState.initMap();
            }
            else {
              mapKey.currentState.setIsLoadingMap(false);
            }
          });
        }

        break;
      }
      default: {
        setState(() {
          tabIdx = 0;
        });
        break;
      }
    }
  }

  Future<void> initConnectivity() async {
    ConnectivityResult result = ConnectivityResult.none;
    // Platform messages may fail, so we use a try/catch PlatformException.
    try {
      result = await _connectivity.checkConnectivity();
    } on PlatformException catch (e) {
    }

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) {
      return Future.value(null);
    }

    return _updateConnectionStatus(result);
  }

  Future<void> _updateConnectionStatus(ConnectivityResult result) async {
    switch (result) {
      case ConnectivityResult.wifi:
      case ConnectivityResult.mobile:
        WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
          if(isInit) {
            if(!isConnectToSocket) {
              initSocketIO();
            }
            else {
              Future.delayed(const Duration(seconds: 5), (){
                if(!isCancel) {
                  isConnectToSocket = false;
                }
              });

              setState(() {
                listData.clear();
                storedData.clear();
                listAddresses.clear();
                listAlarmLogger.clear();
              });
              int idx = 1;
              for (var element in listSocket) {
                socketService.pushDataEvent(setDataChanged, element, idx);
                idx++;
              }
            }
            isInit = false;
          }
        });
        break;
      case ConnectivityResult.none:
        if(mounted) {
          setState(() => isNoInternet = true);
        }
        break;
      default:
      //setState(() => _connectionStatus = 'Failed to get connectivity.');
        break;
    }
  }

  ///global key functions
  bool getIsGotData() {
    return isGotData;
  }

  void setIsCancel(bool val) {
    setState(() {
      isCancel = val;
    });
  }

  bool getIsCancel() {
    return isCancel;
  }

  void retrySocketIO() {
    if(loadTimer != null) {
      loadTimer.cancel();
    }

    if(mounted) {
      setState(() {
        isGotData = false;
        dashboardKey.currentState.setError(false);
        isInit = true;
        isCancel = false;
        isNoInternet = false;
      });
    }

    Future.delayed(const Duration(seconds: 1), (){
      initConnectivity();

      loadTimer = Timer(const Duration(seconds: 5), (){
        if(mounted && isGotData != true && !isCancel) {
          setState(() {
            dashboardKey.currentState.setError(true);
          });
        }
      });
    });
  }

  void initSocketIO() {
    Future.delayed(const Duration(seconds: 10), (){
      if(!isCancel && dashboardKey.currentState != null) {
        dashboardKey.currentState.setLoading(false);
      }
    });
    setState(() {
      listData.clear();
      storedData.clear();
      listAddresses.clear();
    });
    socketService.createSocketConnection(setDataChanged);
  }

  void searchData(String searchText) {
    if(mounted) {
      setState(() {
        isGotData = false;
        listData.clear();
      });

      if(searchText.trim() != "") {
        for (var element in storedData) {
          if(element.objName.contains(searchText)){
            listData.add(element);
          }
        }
      }
      else {
        listData.addAll(storedData);
      }

      setState(() {
        isGotData = true;
      });
    }
  }

  void setDataChanged(String result, int currentIdx) {
    if(mounted) {
      setState(() {
        if(currentIdx == listSocket.length) {
          isCancel = true;
        }
      });

      int totalLogger = 0;
      double sumLat = 0;
      double sumLong = 0;

      if(result != null && result.trim() != "") {

        List<LoggerData> loggerList = List<LoggerData>();

        List<dynamic> jsonResult = json.decode(result);
        for (var logger in jsonResult) {
          Map<String, dynamic> mapLogger = Map<String, dynamic>.from(logger);
          LoggerData temp = LoggerData();
          mapLogger.forEach((key, value) {

            if(key == "objName") {
              temp.objName = value;
            }
            else if(key == "listElement") {

              //temp.listElements
              List<dynamic> listElements = value;
              temp.listElements = List<FieldLoggerData>();

              Map<String, int> maxTimestamp = Map<String, int>();
              Map<String, double> maxValue = Map<String, double>();
              String currentLoggerID = "";
              double currentValue = 0;

              for (var element in listElements) {
                Map<String, dynamic> mapElement = Map<String, dynamic>.from(element);
                if(mapElement["dataType"] == "TAGINFO") {
                  Map<String, dynamic> listValue = Map<String, dynamic>.from(mapElement["value"]);
                  LoggerPoint temp = LoggerPoint();
                  temp.maLogger = listValue["loggerId"];
                  temp.tenLogger = listValue["name"];
                  temp.quanHuyen = listValue["districtId"].toString();
                  temp.diaChi = listValue["name"];
                  temp.dma = listValue["dma"];
                  temp.position = LatLng(listValue["lat"], listValue["lon"]);
                  listAddresses.add(temp);
                  totalLogger++;
                  sumLat+=listValue["lat"];
                  sumLong+=listValue["lon"];
                  currentLoggerID = listValue["loggerId"];
                }
                else if(mapElement["dataType"] == "DATASET" || mapElement["dataType"] == "QUERYSET") {
                  int tempMaxTimestamp = 0;
                  FieldLoggerData tempFieldData = FieldLoggerData();
                  tempFieldData.fieldName = mapElement["name"];

                  //get map value
                  Map<String, String> listValue = Map<String, String>.from(mapElement["value"]);
                  Map<int, double> mapValue = Map<int, double>();
                  listValue.forEach((key, value) {
                    if(int.parse(key) > tempMaxTimestamp) {
                      tempMaxTimestamp = int.parse(key);
                      currentValue = double.parse(value);
                    }
                    if(value != "null" && value.trim() != "") {
                      mapValue[int.parse(key)] = double.parse(value);
                    }
                    else {
                      mapValue[int.parse(key)] = 0;
                    }
                  });

                  if(tempMaxTimestamp != 0) {
                    maxTimestamp[mapElement["name"]] = tempMaxTimestamp;
                    maxValue[mapElement["name"]] = currentValue;
                  }

                  tempFieldData.value = mapValue;

                  temp.listElements.add(tempFieldData);
                }
                else if(mapElement["dataType"] == "ALARMSET") {
                  FieldLoggerData tempFieldLoggerData;
                  AlarmType tempAlarm = AlarmType();
                  try {
                    tempFieldLoggerData = temp.listElements.where((element) => element.fieldName == mapElement["name"]).first;
                  }
                  catch(e) {
                    tempFieldLoggerData = null;
                  }

                  if(tempFieldLoggerData != null) {
                    temp.listElements.where((element) => element.fieldName == mapElement["name"]).first.alarm = Map<int, String>();
                  }
                  List<dynamic> listValue = mapElement["value"];

                  listValue.forEach((value) {
                    Map<String, dynamic> mapValueElement = Map<String, dynamic>.from(value);

                    if(tempFieldLoggerData != null) {
                      temp.listElements.where((element) => element.fieldName == mapElement["name"]).first.alarm[mapValueElement["timestamp"]] = mapValueElement["classId"].toString();
                    }

                    if(maxTimestamp.containsKey(mapElement["name"]) && maxTimestamp.containsValue(mapValueElement["timestamp"])) {
                      AlarmLogger tempAlarmLogger = AlarmLogger();
                      tempAlarmLogger.loggerID = currentLoggerID;
                      tempAlarmLogger.channel = mapElement["name"];
                      tempAlarmLogger.value = maxValue[mapElement["name"]];
                      tempAlarmLogger.timeStamp = mapValueElement["timestamp"];
                      tempAlarmLogger.alarmID = mapValueElement["classId"].toString();
                      tempAlarmLogger.status = mapValueElement["status"].toString();
                      tempAlarmLogger.className = mapValueElement["className"].toString();
                      tempAlarmLogger.comment = mapValueElement["comment"].toString();
                      listAlarmLogger.add(tempAlarmLogger);
                    }

                  });
                }
              }
            }
          });

          if(!loggerList.contains(temp)) {
            loggerList.add(temp);
          }
        }

        mapCenter = LatLng(sumLat/totalLogger, sumLong/totalLogger);

        setState(() {
          isGotData = true;
          resultString = result;

          loggerList.sort((a,b) => a.objName.compareTo(b.objName));

          loggerList.forEach((element) {
            if(!storedData.contains(element)) {
              storedData.add(element);
              mapReceiveGis[element.objName] = false;
            }
          });

          if(searchController == null || searchController.text.trim() == "") {
            loggerList.forEach((element) {
              if(!listData.contains(element)) {
                listData.add(element);
              }
            });
          }
          else {
            searchData(searchController.text);
          }
        });
        //change here
        if(!isReceivedDashboardChart && currentIdx == listSocket.length){
          dashboardKey.currentState.loadDashboard();
          isReceivedDashboardChart = true;
        }
      }
    }
  }

  void setChartChanged(String result, String loggerName, String channelName, int idx) {
    if(mounted && isReceivedChartQuery[idx] == false && mapNameChartQuery[idx] == loggerName) {
      setState(() {
        chartData.clear();
        isReceivedChartQuery[idx] = true;
      });
      int tempMaxDateTime = -1;
      List<ChartData> tempList = <ChartData>[];
      if(result != null && result.trim() != "") {
        List<dynamic> jsonResult = json.decode(result);

        for (var jsonField in jsonResult) {
          Map<String, dynamic> mapElement = Map<String, dynamic>.from(jsonField);
          mapElement.forEach((key, value) {
            if(key == "listElement") {
              value.forEach((detail){
                Map<String, dynamic> mapField = Map<String, dynamic>.from(detail);
                mapField.forEach((key, value) {
                  if(key == "value") {

                    Map<String, String> mapValue = Map<String, String>.from(value);
                    mapValue.forEach((key, value) {
                      try {
                        if(int.parse(key) > tempMaxDateTime) {
                          tempMaxDateTime = int.parse(key);
                        }
                      }
                      catch(e) {

                      }
                      try {
                        ChartData tempChartData = ChartData(getDateString1(int.parse(key)), double.parse(value));
                        tempList.add(tempChartData);
                      }
                      catch(e) {

                      }
                    });
                  }
                });

                // lineChart = LineChart.fromDateTimeMaps([chartData], [Colors.green]);
                // chartKey.currentState.setNewLineChart(lineChart);
                // chartKey.currentState.setMaxDateTime(tempMaxDateTime);
                // chartKey.currentState.setChartInfo(loggerName, channelName, !isReceivedChartDashboard.containsValue(false));
              });
            }
          });
        }
        setState(() {
          chartData.add(tempList);
          flagChartClicked = false;
        });
      }
    }
  }

  void setDataChart(LoggerData logger, String channelName){
    setState(() {
      isLoadingData = true;
      isCancel = false;
    });

    int idx = 1;
    for (var element in listSocket) {
      isReceivedChartQuery[idx] = false;
      mapNameChartQuery[idx] = logger.objName;
      socketService.getDataChart(logger.objName, channelName, 1000, "", "", setChartChanged, element, idx, listSocket.length);
      idx++;
    }

    loadTimer = Timer(Duration(seconds: 5), () {
      if(!isCancel) {
        setState(() {
          isLoadingData = false;
          isError = true;
        });
      }
    });
  }

  List<Widget> buildDetailLogger(List<FieldLoggerData> listLoggerData, LoggerData logger) {
    List<Widget> resultWidget = List<Widget>();
    int i = 0;
    listLoggerData.forEach((element) {
      ChannelMeasure currentMeasure = ChannelMeasure();
      try {
        currentMeasure = listChannelMeasure.where((measure) => measure.channelID == element.fieldName).first;
      }
      catch(e) {
        currentMeasure = null;
      }
      if(i < 3) {
        resultWidget.add(
            Expanded(child: GestureDetector(
                onTap: (){
                  //clicked once but trigger multiple time??
                  if(!flagChartClicked) {
                    setDataChart(logger, element.fieldName);
                    setState(() {
                      currentLogger = logger.objName;
                      currentChannel = currentMeasure != null ? currentMeasure.channelName : element.fieldName;
                    });
                  }
                  setState(() {
                    flagChartClicked = true;
                  });
                },
                child: Container(
                  decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.5)
                  ),
                  padding: const EdgeInsets.only(top: 15, bottom: 5),
                  child: Text((currentMeasure != null ? currentMeasure.channelName : element.fieldName) + ": " +
                      (
                          (element.value != null && element.value.length > 0 ? (element.value.values.last.toString().substring(element.value.values.last.toString().indexOf(".") + 1).length > 2 ?
                          element.value.values.last.toStringAsFixed(2) : element.value.values.last.toString()) : "")
                              + (currentMeasure != null ? " (" + currentMeasure.unit + ")" : "")
                      ),
                    style: Theme.of(context).textTheme.subtitle1.merge(
                        TextStyle(
                            shadows: [Shadow(color: Colour("#246EE9"), offset: const Offset(0,-5))],
                            decoration: TextDecoration.underline,
                            decorationColor: Colour("#246EE9"),
                            color: Colors.transparent,
                            fontSize: 12
                        )),
                  ),
                )
            ))
        );
      }
      i++;
    });
    return resultWidget;
  }

  List<Widget> buildListLoggers(List<LoggerData> loggersList) {
    List<Widget> resultWidgets = List<Widget>();
    for(int i = 0; i < loggersList.length; i++) {

      String currentAddress = "";
      String currentName = "";
      String currentDMA = "";
      try {
        LoggerPoint tempAddress = listAddresses.where((element) => element.maLogger == loggersList.elementAt(i).objName).first;
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

      int currentTime = 0;
      if(loggersList.elementAt(i) != null) {
        loggersList.elementAt(i).listElements.forEach((element) {

          element.value.forEach((key, value) {
            if(key > currentTime) {
              currentTime = key;
            }
          });
        });
      }

      resultWidgets.add(
          GestureDetector(
            onTap: (){
              Navigator.push(
                context,
                PageTransition(
                  type: PageTransitionType.rightToLeft,
                  child: LoggerDetail(loggersList.elementAt(i)),
                ),
              );
            },
            child: Container(
              margin: i == 0 ? const EdgeInsets.only(left: 25, right: 25) : i != (loggersList.length - 1) ? const EdgeInsets.only(left: 25, right: 25, top: 15) : const EdgeInsets.only(left: 25, right: 25, top: 15, bottom: 15),
              padding: const EdgeInsets.only(left: 20, right: 10, top: 20, bottom: 20),
              child: Column (
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.only(left: 15, right: 15, top: 5, bottom: 5,),
                        child: Text(currentName.trim() == "" ? "Logger chưa có tên" : currentName, style: Theme.of(context).textTheme.headline1.merge(TextStyle(color: Colors.white, fontSize: 14))),
                        decoration: BoxDecoration(
                            color: Colour("#243347"),
                            borderRadius: const BorderRadius.all(Radius.circular(5))
                        ),
                      ),
                      Container(
                        margin: const EdgeInsets.only(right: 10),
                        child: Text(currentTime != 0 ? getDateString1(currentTime) : "", style: TextStyle(fontSize: 12),),
                      ),
                    ],
                  ),
                  Container(
                      margin: const EdgeInsets.only(top: 5, bottom: 5),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text("Logger ID: " + loggersList.elementAt(i).objName + (currentDMA != "" ? (", " + currentDMA) : ""), style: Theme.of(context).textTheme.subtitle2),
                          const Icon(Icons.arrow_right_outlined, size: 30,)
                        ],
                      )
                  ),
                  Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: buildDetailLogger(loggersList.elementAt(i).listElements, loggersList.elementAt(i))
                  )
                ],
              ),
              decoration: BoxDecoration(
                // color: loggersList.elementAt(i).isAlarm ? Colour('#ECF2FF') : Colour('#ECF2FF'),
                  color: i%2 == 0 ? Colour('#ECF2FF') : (i%2 == 1 ? Colour('#F0ECE4') : Colour('C6D0DF')),
                  borderRadius: const BorderRadius.all(Radius.circular(15)),
                  boxShadow: const [
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
      );
    }
    return resultWidgets;
  }

  List<Widget> buildListGroup() {
    List<Widget> resultWidgets = List<Widget>();
    for(int i = 0; i < 4; i++) {
      resultWidgets.add(
          Container(
            margin: const EdgeInsets.only(right: 15),
            width: 100,
            height: 100,
            decoration: BoxDecoration(
                color: Colour('#D0D9FF'),
                borderRadius: const BorderRadius.all(Radius.circular(20))
            ),
          )
      );
    }
    return resultWidgets;
  }

  void getAddresses() {
    socketService.getAddresses().then((result){
      if(result != null && result.trim() != "") {

        Map<String, dynamic> jsonResult = Map<String, dynamic>.from(json.decode(result));

        jsonResult.forEach((key, value) {
          if(key == "features") {
            List<dynamic> listFeatures = value;
            listFeatures.forEach((element) {
              Map<String, dynamic> featureInfo = Map<String, dynamic>.from(element);

              LoggerPoint temp = LoggerPoint();

              featureInfo.forEach((key, value) {
                if(key == "attributes") {
                  Map<String, dynamic> mapTenLogger = value;
                  mapTenLogger.forEach((key, value) {
                    if(key == "TenLogger") {
                      temp.tenLogger = value ?? "";
                    }
                    else if(key == "MaLogger") {
                      temp.maLogger = value.toString() ?? "";
                    }
                    else if(key == "DiaChi") {
                      temp.diaChi = value ?? "";
                    }
                  });

                }

              });

              if(!listAddresses.contains(temp)) {
                listAddresses.add(temp);
              }

            });


          }
        });
        setState(() {});
      }
    });
  }
}