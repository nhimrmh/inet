import 'dart:async';
import 'dart:convert';

import 'package:colour/colour.dart';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:inet/models/chart_data_id.dart';
import 'package:inet/models/piechart_data.dart';
import 'package:page_transition/page_transition.dart';

import '../classes/get_date.dart';
import '../classes/pie_chart.dart';
import '../config/config.dart';
import '../data/dashboard_data.dart';
import '../main.dart';
import '../main/logger_detail.dart';
import '../models/alarm_logger.dart';
import '../models/alarm_type.dart';
import '../models/channel_measure.dart';
import '../models/chart_dashboard.dart';
import '../models/chart_dashboard_value.dart';
import '../models/chart_data.dart';
import '../models/dashboard_content.dart';
import '../models/dashboard_model.dart';
import '../models/field_logger_data.dart';
import '../models/logger_data.dart';
import '../widgets/dropdown.dart';
import '../widgets/loading.dart';
import 'chart_view.dart';

class DashboardView extends StatefulWidget {
  String username, password;
  DashboardView({Key key, this.username, this.password}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return DashboardViewState();
  }
}

class DashboardViewState extends State<DashboardView> {
  ///Dashboard variables
  List<DashboardContent> listDashboard = List<DashboardContent>();
  bool isLoadingDashboard = true, isErrorDashboard = false, isGotDashboardData = false, isError = false;
  Timer timerDashboard;
  List<Widget> listDashboardWidgets = List<Widget>();
  List<Widget> listLoggersWidgets = List<Widget>();
  List<Widget> listChartsWidgets = List<Widget>();
  bool isDashboardLogger = true;
  bool isDashboardChart = true;

  @override
  void initState() {
    super.initState();
    isGotDashboardData = false;
    ///set time out 5s
    Future.delayed(const Duration(seconds: 5), (){
      if(mounted && homeKey.currentState.getIsGotData() != true && !homeKey.currentState.getIsCancel()) {
        setState(() {
          isError = true;
          isErrorDashboard = true;
        });
      }
    });

    if(listDashboardModel.isNotEmpty) {
      try {
        setState(() {
          currentDashboard = listDashboardModel.where((element) => element.isActivated == true).first.name;
        });
      }
      catch(e) {
        setState(() {
          currentDashboard = listDashboardModel.elementAt(0).name;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Container(
      child: isLoadingDashboard ? loading(Theme.of(context), "dashboard")
          : isErrorDashboard ? loadError(reloadDashboard, Theme.of(context), 1, "dashboard")
          : Column(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                MyDropDown(
                  listOptions: listDashboardModel.map((e) => e.name).toList(),
                  currentValue: currentDashboard,
                  onChangedFunction: changeDashboard,
                  isExpand: false,
                  customMargin: 15,
                ),
                Container(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Checkbox(value: isDashboardLogger, onChanged: (value){
                        setState(() {
                          isDashboardLogger = value;
                        });
                      }),
                      GestureDetector(
                        onTap: (){
                          setState(() {
                            isDashboardLogger = !isDashboardLogger;
                          });
                        },
                        child: const Text("Xem logger"),
                      )
                    ],
                  ),
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Checkbox(value: isDashboardChart, onChanged: (value){
                      setState(() {
                        isDashboardChart = value;
                      });
                    }),
                    GestureDetector(
                      onTap: (){
                        setState(() {
                          isDashboardChart = !isDashboardChart;
                        });
                      },
                      child: const Text("Xem chart"),
                    )
                  ],
                )
              ],
            ),
          ),
          Container(
            height: 1,
            width: double.infinity,
            color: Colors.black26,
          ),
          Expanded(child:
          listDashboard.isNotEmpty && (listDashboardWidgets.isNotEmpty || listLoggersWidgets.isNotEmpty) ? ListView(
            key: UniqueKey(),
            children: (isDashboardLogger && isDashboardChart) ? (listDashboardWidgets.isNotEmpty ? listDashboardWidgets : listLoggersWidgets) : (isDashboardLogger ? listLoggersWidgets : listChartsWidgets),
          ) :
          isLoadingDashboard ? loading(Theme.of(context), "dashboard") : loadError(reloadDashboard, Theme.of(context), 1, "dashboard")
          )
        ],
      ),
    );
  }

  ///functions for global key
  void setLoading(bool value) {
    setState(() {
      isLoadingDashboard = value;
    });
  }

  void setError(bool value) {
    setState(() {
      isError = value;
    });
  }

  bool getError() {
    return isError;
  }

  ///functions for state
  void loadDashboard() {
    String temp = "";
    if(listDashboardModel.isNotEmpty) {
      try {
        setState(() {
          temp = listDashboardModel.where((element) => element.isActivated == true).first.name;
        });
      }
      catch(e) {
        setState(() {
          temp = listDashboardModel.elementAt(0).name;
        });
      }
    }
    if(temp == currentDashboard) {
      setDashboardChanged(preloadedListDashboardContent);
    }
    else {
      ///enable if want to reload dashboard
      // reloadDashboard();
    }
    // buildListDashboard();
  }

  void reloadDashboard() {
    setState(() {
      isLoadingDashboard = true;
    });

    timerDashboard = Timer(const Duration(seconds: 5), () {
      if(!isGotDashboardData) {
        setState(() {
          isLoadingDashboard = false;
          isErrorDashboard = true;
        });
      }
    });

    socketService.getView(widget.username, widget.password).then((value){
      if(mounted && value != null && value.isNotEmpty && value.trim() != "timeout")
      {
        List<DashboardContent> listDashboardContent = List<DashboardContent>();
        List<dynamic> jsonResult = json.decode(value);
        bool isDashboardContent = false;
        for (var field in jsonResult) {
          Map<String, dynamic> mapField = Map<String, dynamic>.from(field);
          mapField.forEach((key, value) {
            if(key == "name" && value == "dashboard-viewer") {
              isDashboardContent = true;
            }
          });
          if(isDashboardContent) {
            List<dynamic> listScreenElement = mapField["listScreenElement"];
            listScreenElement.forEach((screenElement) {
              Map<String, dynamic> mapScreenElement = Map<String, dynamic>.from(screenElement);
              mapScreenElement.forEach((key, value) {
                if(key == "listSpecProp") {
                  List<dynamic> listSpecProp = value;
                  listSpecProp.forEach((specProp) {
                    Map<String, dynamic> mapSpecProp = Map<String, dynamic>.from(specProp);
                    bool isDashboardProperties = false;
                    mapSpecProp.forEach((key, value) {
                      if(key == "properties") {
                        Map<String, dynamic> mapProperty = Map<String, dynamic>.from(value);
                        mapProperty.forEach((key, value) {
                          if(key == "style" && value == "dashboard-content") {
                            isDashboardProperties = true;
                          }
                          if(key.contains("prop") && isDashboardProperties == true) {
                            if(value.trim() != "null") {
                              DashboardModel tempDashbordModel = DashboardModel();
                              try {
                                Map<String, dynamic> mapProp1 = json.decode(value);
                                mapProp1.forEach((key, value) {
                                  if(key == "name") {
                                    tempDashbordModel.name = value;
                                  }
                                  else if(key == "activate") {
                                    try {
                                      tempDashbordModel.isActivated = value.toString().toUpperCase() == 'TRUE' ? true : false;
                                    }
                                    catch(e) {
                                      tempDashbordModel.isActivated = value.toString().toUpperCase() == 'TRUE' ? true : false;
                                    }
                                  }
                                  else if(key == "content") {
                                    tempDashbordModel.content = value;
                                    Map<String, dynamic> mapContent = Map<String, dynamic>.from(value);
                                    mapContent.forEach((key, value) {
                                      if(key == "children") {
                                        List<dynamic> listChildren = value;
                                        listChildren.forEach((element) {
                                          Map<String, dynamic> mapChildren = Map<String, dynamic>.from(element);
                                          mapChildren.forEach((key, value) {
                                            if(key == "content") {

                                              if(tempDashbordModel.isActivated == true) {
                                                DashboardContent temp = DashboardContent();

                                                String messDashboardContent = value;
                                                String testTypeDashboardContent = value;

                                                if(testTypeDashboardContent.contains("tw-class=\"")) {
                                                  testTypeDashboardContent = testTypeDashboardContent.substring(testTypeDashboardContent.indexOf("tw-class=\"") + 10);
                                                  String twClass = testTypeDashboardContent.substring(0, testTypeDashboardContent.indexOf("\""));
                                                  if(twClass == "logger-panel") {
                                                    temp.type = 0;
                                                  }
                                                  else if(twClass == "logger-chart") {
                                                    temp.type = 1;
                                                    messDashboardContent = messDashboardContent.substring(messDashboardContent.indexOf("tw-class=\"") + 10);
                                                  }
                                                  else if(twClass == "alarm-panel") {
                                                    temp.type = 2;
                                                  }
                                                  else if(twClass == "channel-pie") {
                                                    temp.type = 3;
                                                  }
                                                  else {
                                                    temp.type = -1;
                                                  }

                                                }
                                                else {
                                                  temp.type = -1;
                                                }

                                                if(temp.type == 0) {
                                                  if(messDashboardContent.contains("logger-id=\"")) {
                                                    messDashboardContent = messDashboardContent.substring(messDashboardContent.indexOf("logger-id=\"") + 11);
                                                    String loggerID = messDashboardContent.substring(0, messDashboardContent.indexOf("\""));
                                                    temp.loggerID = loggerID;
                                                  }
                                                  else {
                                                    temp.loggerID = "";
                                                  }

                                                  String reservedContent = messDashboardContent;

                                                  if(messDashboardContent.contains("logger-name=\"")) {
                                                    messDashboardContent = messDashboardContent.substring(messDashboardContent.indexOf("logger-name=\"") + 13);
                                                    String loggerName = messDashboardContent.substring(0, messDashboardContent.indexOf("\""));
                                                    temp.loggerName = loggerName;
                                                  }
                                                  else {
                                                    temp.loggerName = "";
                                                  }

                                                  if(messDashboardContent.contains("channel=\"")) {
                                                    messDashboardContent = messDashboardContent.substring(messDashboardContent.indexOf("channel=\"") + 9);
                                                    String loggerName = messDashboardContent.substring(0, messDashboardContent.indexOf("\""));

                                                    temp.listElement = List<DashboardElement>();
                                                    while(loggerName.contains("{")) {
                                                      DashboardElement tempElement = DashboardElement();
                                                      if(loggerName.contains("rawName:")) {
                                                        loggerName = loggerName.substring(loggerName.indexOf("rawName:") + 8);
                                                        String rawName = loggerName.substring(0, loggerName.indexOf(","));
                                                        tempElement.rawName = rawName;
                                                      }
                                                      else {
                                                        tempElement.rawName = "";
                                                      }

                                                      if(loggerName.contains("name:")) {
                                                        loggerName = loggerName.substring(loggerName.indexOf("name:") + 5);
                                                        String name = loggerName.substring(0, loggerName.indexOf(","));
                                                        tempElement.name = name;
                                                      }
                                                      else {
                                                        tempElement.name = "";
                                                      }

                                                      if(loggerName.contains("unit:")) {
                                                        loggerName = loggerName.substring(loggerName.indexOf("unit:") + 5);
                                                        String unit = loggerName.substring(0, loggerName.indexOf(","));
                                                        tempElement.unit = unit;
                                                      }
                                                      else {
                                                        tempElement.unit = "";
                                                      }
                                                      temp.listElement.add(tempElement);

                                                    }
                                                    listDashboardContent.add(temp);
                                                  }
                                                  else if(reservedContent.contains("channel=\"")) {
                                                    reservedContent = reservedContent.substring(reservedContent.indexOf("channel=\"") + 9);
                                                    String loggerName = reservedContent.substring(0, reservedContent.indexOf("\""));

                                                    temp.listElement = List<DashboardElement>();
                                                    while(loggerName.contains("{")) {
                                                      DashboardElement tempElement = DashboardElement();
                                                      if(loggerName.contains("rawName:")) {
                                                        loggerName = loggerName.substring(loggerName.indexOf("rawName:") + 8);
                                                        String rawName = loggerName.substring(0, loggerName.indexOf(","));
                                                        tempElement.rawName = rawName;
                                                      }
                                                      else {
                                                        tempElement.rawName = "";
                                                      }

                                                      if(loggerName.contains("name:")) {
                                                        loggerName = loggerName.substring(loggerName.indexOf("name:") + 5);
                                                        String name = loggerName.substring(0, loggerName.indexOf(","));
                                                        tempElement.name = name;
                                                      }
                                                      else {
                                                        tempElement.name = "";
                                                      }

                                                      if(loggerName.contains("unit:")) {
                                                        loggerName = loggerName.substring(loggerName.indexOf("unit:") + 5);
                                                        String unit = loggerName.substring(0, loggerName.indexOf(","));
                                                        tempElement.unit = unit;
                                                      }
                                                      else {
                                                        tempElement.unit = "";
                                                      }
                                                      temp.listElement.add(tempElement);

                                                    }
                                                    listDashboardContent.add(temp);
                                                  }
                                                }
                                                else if(temp.type == 1) {
                                                  if(messDashboardContent.contains("chart=\"")) {
                                                    messDashboardContent = messDashboardContent.substring(messDashboardContent.indexOf("chart=\"") + 9);
                                                    String loggerName = messDashboardContent.substring(0, messDashboardContent.indexOf("\""));

                                                    temp.listElement = List<DashboardElement>();

                                                    while(loggerName.contains("{")) {
                                                      DashboardElement tempElement = DashboardElement();

                                                      if(loggerName.contains("loggerId:")) {
                                                        loggerName = loggerName.substring(loggerName.indexOf("loggerId:") + 9);
                                                        String id = loggerName.substring(0, loggerName.indexOf(","));
                                                        tempElement.loggerID = id;
                                                      }
                                                      else {
                                                        temp.loggerID = "";
                                                      }

                                                      if(loggerName.contains("rawName:")) {
                                                        loggerName = loggerName.substring(loggerName.indexOf("rawName:") + 8);
                                                        String rawName = loggerName.substring(0, loggerName.indexOf(","));
                                                        tempElement.rawName = rawName;
                                                      }
                                                      else {
                                                        tempElement.rawName = "";
                                                      }

                                                      if(loggerName.contains("name:")) {
                                                        loggerName = loggerName.substring(loggerName.indexOf("name:") + 5);
                                                        String name = loggerName.substring(0, loggerName.indexOf(","));
                                                        tempElement.name = name;
                                                      }
                                                      else {
                                                        tempElement.name = "";
                                                      }

                                                      if(loggerName.contains("unit:")) {
                                                        loggerName = loggerName.substring(loggerName.indexOf("unit:") + 5);
                                                        String unit = loggerName.substring(0, loggerName.indexOf(","));
                                                        tempElement.unit = unit;
                                                      }
                                                      else {
                                                        tempElement.unit = "";
                                                      }
                                                      temp.listElement.add(tempElement);

                                                    }
                                                    listDashboardContent.add(temp);
                                                  }
                                                }
                                                else if(temp.type == 2) {
                                                  if(messDashboardContent.contains("alarm-class=\"")) {
                                                    messDashboardContent = messDashboardContent.substring(messDashboardContent.indexOf("alarm-class=\"[") + 14);
                                                    String loggerID = messDashboardContent.substring(0, messDashboardContent.indexOf("]\""));
                                                    if(loggerID.isNotEmpty && loggerID.contains(",")) {
                                                      temp.listAlarm = loggerID.split(",");
                                                    }
                                                  }
                                                  else {
                                                    temp.listAlarm = null;
                                                  }
                                                  listDashboardContent.add(temp);
                                                }
                                                else if(temp.type == 3) {
                                                  if(messDashboardContent.contains("logger-id=\"")) {
                                                    messDashboardContent = messDashboardContent.substring(messDashboardContent.indexOf("logger-id=\"[") + 12);
                                                    String loggerID = messDashboardContent.substring(0, messDashboardContent.indexOf("]\""));
                                                    if(loggerID.isNotEmpty && loggerID.contains(",")) {
                                                      temp.listLoggerId = loggerID.split(",");
                                                    }
                                                    else if(loggerID.isNotEmpty) {
                                                      temp.listLoggerId.add(loggerID);
                                                    }

                                                    if(messDashboardContent.contains("rawName:")) {
                                                      String rawName = messDashboardContent.substring(messDashboardContent.indexOf("rawName:") + 8);
                                                      String channel = rawName.substring(0, rawName.indexOf(","));
                                                      temp.channel = channel;
                                                    }
                                                    else {
                                                      temp.channel = "";
                                                    }
                                                  }
                                                  else {
                                                    temp.listLoggerId = null;
                                                  }
                                                  listDashboardContent.add(temp);
                                                }
                                              }
                                            }
                                            if(!listDashboardModel.map((e) => e.name).toList().contains(tempDashbordModel.name)) {
                                              listDashboardModel.add(tempDashbordModel);
                                            }
                                          });
                                        });
                                      }
                                    });
                                  }
                                });
                              }
                              catch(e) {

                              }
                            }
                          }
                        });
                      }
                      isDashboardProperties = false;
                    });
                  });
                }
              });
            });

          }
          isDashboardContent = false;
        }
        setDashboardChanged(listDashboardContent);
      }
      else {
        setState(() {
          isGotDashboardData = false;
        });
      }
    });
  }

  void changeDashboard(String newDashboard) {
    homeKey.currentState.setIsCancel(true);
    setState(() {
      isErrorDashboard = false;
      isLoadingDashboard = true;
      currentDashboard = newDashboard;
      listDashboard = decodeJsonDashboard(listDashboardModel.where((element) => element.name == newDashboard).first.content);
    });
    buildListDashboard();
  }

  void setDashboardChanged(List<DashboardContent> newListDashboard) {
    setState(() {
      if(timerDashboard != null) timerDashboard.cancel();
      listDashboard = newListDashboard;
      isErrorDashboard = false;
      isGotDashboardData = true;
    });
    buildListDashboard();
  }

  List<DashboardContent> decodeJsonDashboard(Map<String, dynamic> mapProp1) {
    List<DashboardContent> listDashboardContent = List<DashboardContent>();
    try {
      mapProp1.forEach((key, value) {
        if(key == "children") {
          List<dynamic> listChildren = value;
          listChildren.forEach((element) {
            Map<String, dynamic> mapChildren = Map<String, dynamic>.from(element);
            mapChildren.forEach((key, value) {
              if(key == "content") {

                DashboardContent temp = DashboardContent();

                int maxCurrentIdx = 0;

                String messDashboardContent = value;
                String testTypeDashboardContent = value;

                if(testTypeDashboardContent.contains("tw-class=\"")) {
                  testTypeDashboardContent = testTypeDashboardContent.substring(testTypeDashboardContent.indexOf("tw-class=\"") + 10);
                  String twClass = testTypeDashboardContent.substring(0, testTypeDashboardContent.indexOf("\""));
                  if(twClass == "logger-panel") {
                    temp.type = 0;
                  }
                  else if(twClass == "logger-chart") {
                    temp.type = 1;
                    messDashboardContent = messDashboardContent.substring(messDashboardContent.indexOf("tw-class=\"") + 10);
                  }
                  else if(twClass == "alarm-panel") {
                    temp.type = 2;
                  }
                  else {
                    temp.type = -1;
                  }

                }
                else {
                  temp.type = -1;
                }

                if(temp.type == 0) {
                  if(messDashboardContent.contains("logger-id=\"")) {
                    messDashboardContent = messDashboardContent.substring(messDashboardContent.indexOf("logger-id=\"") + 11);
                    String loggerID = messDashboardContent.substring(0, messDashboardContent.indexOf("\""));
                    temp.loggerID = loggerID;
                  }
                  else {
                    temp.loggerID = "";
                  }

                  String reservedContent = messDashboardContent;

                  if(messDashboardContent.contains("logger-name=\"")) {
                    messDashboardContent = messDashboardContent.substring(messDashboardContent.indexOf("logger-name=\"") + 13);
                    String loggerName = messDashboardContent.substring(0, messDashboardContent.indexOf("\""));
                    temp.loggerName = loggerName;
                  }
                  else {
                    temp.loggerName = "";
                  }

                  if(messDashboardContent.contains("channel=\"")) {
                    messDashboardContent = messDashboardContent.substring(messDashboardContent.indexOf("channel=\"") + 9);
                    String loggerName = messDashboardContent.substring(0, messDashboardContent.indexOf("\""));

                    temp.listElement = List<DashboardElement>();
                    while(loggerName.contains("{")) {
                      DashboardElement tempElement = DashboardElement();
                      if(loggerName.contains("rawName:")) {
                        loggerName = loggerName.substring(loggerName.indexOf("rawName:") + 8);
                        String rawName = loggerName.substring(0, loggerName.indexOf(","));
                        tempElement.rawName = rawName;
                      }
                      else {
                        tempElement.rawName = "";
                      }

                      if(loggerName.contains("name:")) {
                        loggerName = loggerName.substring(loggerName.indexOf("name:") + 5);
                        String name = loggerName.substring(0, loggerName.indexOf(","));
                        tempElement.name = name;
                      }
                      else {
                        tempElement.name = "";
                      }

                      if(loggerName.contains("unit:")) {
                        loggerName = loggerName.substring(loggerName.indexOf("unit:") + 5);
                        String unit = loggerName.substring(0, loggerName.indexOf(","));
                        tempElement.unit = unit;
                      }
                      else {
                        tempElement.unit = "";
                      }
                      temp.listElement.add(tempElement);

                    }
                    listDashboardContent.add(temp);
                  }
                  else if(reservedContent.contains("channel=\"")) {
                    reservedContent = reservedContent.substring(reservedContent.indexOf("channel=\"") + 9);
                    String loggerName = reservedContent.substring(0, reservedContent.indexOf("\""));

                    temp.listElement = List<DashboardElement>();
                    while(loggerName.contains("{")) {
                      DashboardElement tempElement = DashboardElement();
                      if(loggerName.contains("rawName:")) {
                        loggerName = loggerName.substring(loggerName.indexOf("rawName:") + 8);
                        String rawName = loggerName.substring(0, loggerName.indexOf(","));
                        tempElement.rawName = rawName;
                      }
                      else {
                        tempElement.rawName = "";
                      }

                      if(loggerName.contains("name:")) {
                        loggerName = loggerName.substring(loggerName.indexOf("name:") + 5);
                        String name = loggerName.substring(0, loggerName.indexOf(","));
                        tempElement.name = name;
                      }
                      else {
                        tempElement.name = "";
                      }

                      if(loggerName.contains("unit:")) {
                        loggerName = loggerName.substring(loggerName.indexOf("unit:") + 5);
                        String unit = loggerName.substring(0, loggerName.indexOf(","));
                        tempElement.unit = unit;
                      }
                      else {
                        tempElement.unit = "";
                      }
                      temp.listElement.add(tempElement);

                    }
                    listDashboardContent.add(temp);
                  }
                }
                else if(temp.type == 1) {
                  if(messDashboardContent.contains("chart=\"")) {
                    messDashboardContent = messDashboardContent.substring(messDashboardContent.indexOf("chart=\"") + 9);
                    String loggerName = messDashboardContent.substring(0, messDashboardContent.indexOf("\""));

                    temp.listElement = List<DashboardElement>();

                    while(loggerName.contains("{")) {
                      DashboardElement tempElement = DashboardElement();

                      if(loggerName.contains("loggerId:")) {
                        loggerName = loggerName.substring(loggerName.indexOf("loggerId:") + 9);
                        String id = loggerName.substring(0, loggerName.indexOf(","));
                        tempElement.loggerID = id;
                      }
                      else {
                        temp.loggerID = "";
                      }

                      if(loggerName.contains("rawName:")) {
                        loggerName = loggerName.substring(loggerName.indexOf("rawName:") + 8);
                        String rawName = loggerName.substring(0, loggerName.indexOf(","));
                        tempElement.rawName = rawName;
                      }
                      else {
                        tempElement.rawName = "";
                      }

                      if(loggerName.contains("name:")) {
                        loggerName = loggerName.substring(loggerName.indexOf("name:") + 5);
                        String name = loggerName.substring(0, loggerName.indexOf(","));
                        tempElement.name = name;
                      }
                      else {
                        tempElement.name = "";
                      }

                      if(loggerName.contains("unit:")) {
                        loggerName = loggerName.substring(loggerName.indexOf("unit:") + 5);
                        String unit = loggerName.substring(0, loggerName.indexOf(","));
                        tempElement.unit = unit;
                      }
                      else {
                        tempElement.unit = "";
                      }
                      temp.listElement.add(tempElement);

                    }
                    listDashboardContent.add(temp);
                  }
                }
                else if(temp.type == 2) {
                  if(messDashboardContent.contains("alarm-class=\"")) {
                    messDashboardContent = messDashboardContent.substring(messDashboardContent.indexOf("alarm-class=\"[") + 14);
                    String loggerAlarm = messDashboardContent.substring(0, messDashboardContent.indexOf("]\""));
                    List<String> tempAlarm = loggerAlarm.split(",");
                    temp.listAlarm = tempAlarm;
                    listDashboardContent.add(temp);
                  }
                  else {
                    // temp.listAlarm.clear();
                  }
                }
              }

            });
          });
        }
      });
    }
    catch(e) {
      String a = e.toString();
    }
    return listDashboardContent;
  }

  List<Widget> buildDashboardInfo(List<DashboardElement> listElements, String loggerID, String loggerName) {

    List<Widget> resultWidgets = List<Widget>();
    if(listElements != null && listElements.length > 0) {
      for (var element in listElements) {

        ChannelMeasure currentMeasure = ChannelMeasure();
        try {
          currentMeasure = listChannelMeasure.where((measure) => measure.channelID == element.rawName).first;
        }
        catch(e) {
          currentMeasure = null;
        }

        Map<int,double> mapElement = Map<int, double>();
        Map<int,String> mapAlarm;

        FieldLoggerData temp = FieldLoggerData();

        try {
          temp = storedData.where((element) => element.objName == loggerID).first.listElements.where((fieldElement) => fieldElement.fieldName == element.rawName).first;
        }
        catch(e) {
          temp = null;
        }

        if(temp != null) {
          mapElement = temp.value;
          mapAlarm = temp.alarm;
        }

        AlarmType tempAlarmType;

        int maxKey = 0;
        mapElement.forEach((key, value) {
          if(key > maxKey) {
            maxKey = key;
          }
        });

        if(mapAlarm != null && mapAlarm[maxKey] != null) {
          try {
            tempAlarmType = listAlarmType.where((element) => element.id == mapAlarm[maxKey]).first;
          }
          catch(e) {
            tempAlarmType = null;
          }
        }

        resultWidgets.add(
            Container(
              margin: const EdgeInsets.only(top: 3, bottom: 3),
              padding: const EdgeInsets.only(top: 10, bottom: 10, left: 15, right: 15),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    currentMeasure != null ? currentMeasure.channelName : element.rawName,
                    style: Theme.of(context).textTheme.subtitle1.merge(
                        TextStyle(fontWeight: FontWeight.w400, color: (tempAlarmType != null &&
                            (tempAlarmType.id == '4' || tempAlarmType.id == '6' || tempAlarmType.id == '7')
                            ? Colors.white : Colors.black))
                    ),
                  ),
                  mapElement.isNotEmpty ? Text(
                    (mapElement[maxKey].toString().substring(mapElement[maxKey].toString().indexOf(".") + 1).length > 2 ?
                    mapElement[maxKey].toStringAsFixed(2) : mapElement[maxKey].toString()) + (element.unit != "null" ? " (" + element.unit + ")" : ""),
                    style: Theme.of(context).textTheme.subtitle1.merge(
                        TextStyle(fontWeight: FontWeight.w400, color: (tempAlarmType != null &&
                            (tempAlarmType.id == '4' || tempAlarmType.id == '5' || tempAlarmType.id == '6' || tempAlarmType.id == '7')
                            ? Colors.white : Colors.black))
                    ),
                  ) : Container(),
                ],
              ),
              decoration: BoxDecoration(
                  color: tempAlarmType != null ? Colour(tempAlarmType.color) : Colors.white,
                  borderRadius: const BorderRadius.all(Radius.circular(5))
              ),
            )
        );
      }
    }
    return resultWidgets;
  }

  Widget buildDashboardAlarm(AlarmLogger alarm) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          margin: const EdgeInsets.only(top: 3, bottom: 3),
          padding: const EdgeInsets.only(top: 10, bottom: 10, left: 15, right: 15),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                alarm.comment ?? "",
                style: Theme.of(context).textTheme.subtitle1.merge(
                    const TextStyle(fontWeight: FontWeight.w400, color: Colors.black)
                ),
              ),
            ],
          ),
          decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.all(Radius.circular(5))
          ),
        ),
        Container(
          margin: const EdgeInsets.only(top: 3, bottom: 3),
          padding: const EdgeInsets.only(top: 10, bottom: 10, left: 15, right: 15),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Value: " + (alarm.value != null ? alarm.value.toStringAsFixed(1) : ""),
                style: Theme.of(context).textTheme.subtitle1.merge(
                    const TextStyle(fontWeight: FontWeight.w400, color: Colors.black)
                ),
              ),
              Text(
                "Range: " + alarm.status ?? "",
                style: Theme.of(context).textTheme.subtitle1.merge(
                    const TextStyle(fontWeight: FontWeight.w400, color: Colors.black)
                ),
              ),
            ],
          ),
          decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.all(Radius.circular(5))
          ),
        ),
      ],
    );
  }

  void setChartChanged_dashboard(String result, List<DashboardElement> listChartDashboard, int socketID, int idx, String title, {List<String> listLoggerID, List<String> listChannel}) {
    if(mounted && isReceivedChartDashboard["$socketID-$idx"] == false && result.replaceAll("[]", "").isNotEmpty) {
      isReceivedChartDashboard["$socketID-$idx"] = true;
      if(mounted) {
        setState(() {
          listChartsWidgets.clear();
        });
        if(result != null && result.trim() != "") {

          List<dynamic> jsonResult = json.decode(result);



          for (var jsonField in jsonResult) {
            ///data of chart
            List<ChartData> currentChartData = [];
            int previousTime = 0;
            Map<String, dynamic> mapElement = Map<String, dynamic>.from(jsonField);
            ChartDashboardValue temp = ChartDashboardValue();
            mapElement.forEach((key, value) {
              temp.listChannels = List<String>();

              if(key == "objName") {
                temp.loggerName = value;
              }
              else if(key == "listElement") {
                List<dynamic> listElements = value;
                for (var detail in listElements) {
                  Map<String, dynamic> mapField = Map<String, dynamic>.from(detail);
                  mapField.forEach((key, value) {
                    if(key == "name") {
                      temp.listChannels.add(value);
                    }
                    else if(key == "value") {
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


            if(mapAllChartData[idx] == null || mapAllChartData[idx].isEmpty) {
              mapAllChartData[idx] = [];
              ChartDataID temp = ChartDataID()
              ..id = ""
              ..chartData = currentChartData;
              mapAllChartData[idx].add(temp);
              int findIdx;
              try {
                findIdx = listChartDashboard.elementAt(0).id;
              }
              catch(e) {
                findIdx = null;
              }


              Widget chartChild = MyChart(mapAllChartData[idx], title: title, listLoggerID: listLoggerID, listChannel: listChannel,);

              setState(() {
                listChartsWidgets.add(
                    Container(
                      margin: const EdgeInsets.only(top: 15, right: 25, left: 25),
                      width: double.infinity,
                      height: 300,
                      child: chartChild,
                    )
                );
                if(findIdx != null && listDashboardWidgets.length > findIdx) {
                  listDashboardWidgets.insert(
                      findIdx,
                      Container(
                        margin: const EdgeInsets.only(top: 15, right: 25, left: 25),
                        width: double.infinity,
                        height: 300,
                        child: chartChild,
                      )
                  );
                }
                else {
                  listDashboardWidgets.add(
                      Container(
                        margin: const EdgeInsets.only(top: 15, right: 25, left: 25),
                        width: double.infinity,
                        height: 300,
                        child: chartChild,
                      )
                  );
                }
              });
            }
            else {
              setState(() {
                ChartDataID temp = ChartDataID()
                  ..id = ""
                  ..chartData = currentChartData;
                mapAllChartData[idx].add(temp);
              });
            }
          }

        }
        setState(() {
          isLoadingDashboard = false;
        });

        isSendingQuery = false;
        isReceivedDashboardChart = false;
        mapAllChartData.clear();

      }
    }
  }

  void buildListDashboard() {
    Map<int, List<DashboardElement>> listChartQuery = <int, List<DashboardElement>>{};
    setState(() {
      listDashboardWidgets.clear();
      listLoggersWidgets.clear();
      listChartsWidgets.clear();
    });
    bool isHavingChart = false;
    int i = 0;
    int idx = 0;

    for (var element in listDashboard) {
      LoggerData a;
      try {
        a = storedData.where((storedElement) => storedElement.objName == element.loggerID).first;
      }
      catch(e) {
        a = null;
      }

      int currentTime = 0;
      if(a != null) {
        for (var element in a.listElements) {

          element.value.forEach((key, value) {
            if(key > currentTime) {
              currentTime = key;
            }
          });
        }
      }

      if(a != null || element.type == 2 || (element.listElement != null && element.listElement.isNotEmpty)) {
        if(element.type == 0) {
          setState(() {
            listDashboardWidgets.add(
                GestureDetector(
                  onTap: (){
                    Navigator.push(
                      context,
                      PageTransition(
                        type: PageTransitionType.rightToLeft,
                        child: LoggerDetail(storedData.where((storedElement) => storedElement.objName == element.loggerID).first),
                      ),
                    );
                  },
                  child: Container(
                    margin: i != 0 ? const EdgeInsets.only(left: 25, right: 25, bottom: 15) : const EdgeInsets.only(left: 25, right: 25, top: 15, bottom: 15),
                    padding: const EdgeInsets.only(left: 20, right: 20, top: 10, bottom: 10),
                    child: Column (
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.only(left: 15, right: 15, top: 5, bottom: 5,),
                          margin: const EdgeInsets.only(bottom: 10, top: 5),
                          child: Text(element.loggerName + " (" + element.loggerID + ")", style: Theme.of(context).textTheme.headline1.merge(TextStyle(color: Colors.white))),
                          decoration: BoxDecoration(
                              color: Colour("#243347"),
                              borderRadius: const BorderRadius.all(Radius.circular(5))
                          ),
                        ),
                        Container(
                          margin: const EdgeInsets.only(bottom: 15),
                          child: Text(currentTime != 0 ? getDateString1(currentTime) : "", style: TextStyle(fontSize: 12),),
                        ),
                        Column(
                          children: buildDashboardInfo(element.listElement, element.loggerID, element.loggerName),
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
            listLoggersWidgets.add(
                GestureDetector(
                  onTap: (){
                    Navigator.push(
                      context,
                      PageTransition(
                        type: PageTransitionType.rightToLeft,
                        child: LoggerDetail(storedData.where((storedElement) => storedElement.objName == element.loggerID).first),
                      ),
                    );
                  },
                  child: Container(
                    margin: i != 0 ? const EdgeInsets.only(left: 25, right: 25, bottom: 15) : const EdgeInsets.only(left: 25, right: 25, top: 15, bottom: 15),
                    padding: const EdgeInsets.only(left: 20, right: 20, top: 10, bottom: 10),
                    child: Column (
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.only(left: 15, right: 15, top: 5, bottom: 5,),
                          margin: const EdgeInsets.only(bottom: 10, top: 5),
                          child: Text(element.loggerName + " (" + element.loggerID + ")", style: Theme.of(context).textTheme.headline1.merge(TextStyle(color: Colors.white))),
                          decoration: BoxDecoration(
                              color: Colour("#243347"),
                              borderRadius: const BorderRadius.all(Radius.circular(5))
                          ),
                        ),
                        Container(
                          margin: const EdgeInsets.only(bottom: 15),
                          child: Text(currentTime != 0 ? getDateString1(currentTime) : "", style: TextStyle(fontSize: 12),),
                        ),
                        Column(
                          children: buildDashboardInfo(element.listElement, element.loggerID, element.loggerName),
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
          });
          i++;
          idx++;
        }
        else if (element.type == 1){
          isHavingChart = true;
          // ChartDashboard temp = ChartDashboard();
          // temp.loggerName = element.loggerID;
          // List<String> listChannels = List<String>();
          // for (var channelElement in element.listElement) {
          //   listChannels.add(channelElement.rawName);
          // }
          // temp.listChannels = List<String>();
          // temp.listChannels = listChannels;
          // temp.idx = idx;
          // if(temp.loggerName != "" && temp.loggerName != null && temp.listChannels != null && temp.listChannels.isNotEmpty){
          //
          //   idx++;
          // }
          element.id = idx;
          for(var item in element.listElement) {
            item.id = idx;
          }
          listChartQuery[idx] = [];
          listChartQuery[idx].addAll(element.listElement);
          idx++;
        }
        else if(element.type == 2) {

          for (var alarmLogger in listAlarmLogger) {
            ChannelMeasure currentMeasure = ChannelMeasure();
            try {
              currentMeasure = listChannelMeasure.where((measure) => measure.channelID == alarmLogger.channel).first;
            }
            catch(e) {
              currentMeasure = null;
            }

            if(element.listAlarm != null && element.listAlarm.contains(alarmLogger.alarmID)) {
              ///lay mau alarm tuong ung
              AlarmType tempAlarmType;

              try {
                tempAlarmType = listAlarmType.where((element) => element.id == alarmLogger.alarmID).first;
              }
              catch(e) {
                tempAlarmType = null;
              }

              ///add logger to dashboard
              setState(() {
                listDashboardWidgets.add(
                    GestureDetector(
                      onTap: (){
                        Navigator.push(
                          context,
                          PageTransition(
                            type: PageTransitionType.rightToLeft,
                            child: LoggerDetail(storedData.where((storedElement) => storedElement.objName == alarmLogger.loggerID).first),
                          ),
                        );
                      },
                      child: Container(
                        margin: i != 0 ? const EdgeInsets.only(left: 25, right: 25, bottom: 15) : const EdgeInsets.only(left: 25, right: 25, top: 15, bottom: 15),
                        padding: const EdgeInsets.only(left: 20, right: 20, top: 10, bottom: 10),
                        child: Column (
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Container(
                              padding: const EdgeInsets.only(left: 15, right: 15, top: 5, bottom: 5,),
                              margin: const EdgeInsets.only(bottom: 5, top: 5),
                              child: Text(alarmLogger.loggerID + " (" + (currentMeasure != null ? currentMeasure.channelName : alarmLogger.channel) + ")", style: Theme.of(context).textTheme.headline1.merge(TextStyle(color: Colors.white))),
                              decoration: BoxDecoration(
                                  color: Colour("#243347"),
                                  borderRadius: const BorderRadius.all(Radius.circular(5))
                              ),
                            ),
                            Container(
                              margin: const EdgeInsets.only(bottom: 15),
                              child: Text(getDateString1(alarmLogger.timeStamp), style: TextStyle(fontSize: 12),),
                            ),
                            buildDashboardAlarm(alarmLogger)
                          ],
                        ),
                        decoration: BoxDecoration(
                            border: Border.all(color: tempAlarmType != null ? Colour(tempAlarmType.color) : Colors.white, width: 2),
                            color: tempAlarmType != null ? Colour(tempAlarmType.color).withOpacity(0.5) : Colors.white,
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
                listLoggersWidgets.add(
                    GestureDetector(
                      onTap: (){
                        Navigator.push(
                          context,
                          PageTransition(
                            type: PageTransitionType.rightToLeft,
                            child: LoggerDetail(storedData.where((storedElement) => storedElement.objName == alarmLogger.loggerID).first),
                          ),
                        );
                      },
                      child: Container(
                        margin: i != 0 ? const EdgeInsets.only(left: 25, right: 25, bottom: 15) : const EdgeInsets.only(left: 25, right: 25, top: 15, bottom: 15),
                        padding: const EdgeInsets.only(left: 20, right: 20, top: 10, bottom: 10),
                        child: Column (
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Container(
                              padding: const EdgeInsets.only(left: 15, right: 15, top: 5, bottom: 5,),
                              margin: const EdgeInsets.only(bottom: 5, top: 5),
                              child: Text(alarmLogger.loggerID + " (" + (currentMeasure != null ? currentMeasure.channelName : alarmLogger.channel) + ")", style: Theme.of(context).textTheme.headline1.merge(TextStyle(color: Colors.white))),
                              decoration: BoxDecoration(
                                  color: Colour("#243347"),
                                  borderRadius: const BorderRadius.all(Radius.circular(5))
                              ),
                            ),
                            Container(
                              margin: const EdgeInsets.only(bottom: 15),
                              child: Text(getDateString1(alarmLogger.timeStamp), style: TextStyle(fontSize: 12),),
                            ),
                            buildDashboardAlarm(alarmLogger)
                          ],
                        ),
                        decoration: BoxDecoration(
                            border: Border.all(color: tempAlarmType != null ? Colour(tempAlarmType.color) : Colors.white, width: 2),
                            color: tempAlarmType != null ? Colour(tempAlarmType.color).withOpacity(0.5) : Colors.white,
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
              });
              idx++;
            }
          }

        }
        else if(element.type == 3) {
          List<MyPieChartData> listData = [];
          double total = 0;
          for(String item in element.listLoggerId) {
            double value = 0;

            LoggerData getValue;
            try {
              getValue = storedData.where((storedElement) => storedElement.objName == item).first;
            }
            catch(e) {
              getValue = null;
            }
            
            if(getValue != null) {
              FieldLoggerData listValueChannels;
              try {
                listValueChannels = getValue.listElements.where((listElement) => listElement.fieldName == element.channel).first;
              }
              catch(e) {
                listValueChannels = null;
              }
              
              if(listValueChannels != null && listValueChannels.value.isNotEmpty) {
                int maxKey = 0;
                listValueChannels.value.forEach((key, value) {
                  if(key > maxKey) {
                    maxKey = key;
                  }
                });

                value = listValueChannels.value[maxKey];
              }
            }
            
            MyPieChartData temp = MyPieChartData();

            temp.value = value;
            temp.loggerID = item;
            temp.channel = element.channel;
            listData.add(temp);
            total+=value;
          }
          setState(() {
            listDashboardWidgets.add(MyPieChart(data: listData, total: total,));
            listChartsWidgets.add(MyPieChart(data: listData, total: total,));
          });
          idx++;
        }
      }
    }

    if(!isHavingChart) {
      setState(() {
        isLoadingDashboard = false;
      });
    }
    else {
      if(!isSendingQuery) {
        isSendingQuery = true;
        int socketID = 0;
        
        listChartQuery.forEach((key, value) {
          List<DashboardElement> listElements = value;
          String title = "Loggers: ${listElements.map((e) => e.loggerID).toSet().toList()}\nChannels: ${listElements.map((e) => e.rawName).toSet().toList()}";
          for (var element in listSocket) {
            isReceivedChartDashboard["$socketID-$idx"] = false;
            socketService.getDashboardDataChart(value, setChartChanged_dashboard, element, socketID, idx, title, listLoggerId: listElements.map((e) => e.loggerID).toList(), listChannel: listElements.map((e) => e.rawName).toList());
            idx++;
          }
        });
      }
    }
  }
}