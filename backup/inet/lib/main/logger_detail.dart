import 'package:colour/colour.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:inet/classes/get_date.dart';
import 'package:inet/models/channel_measure.dart';
import 'package:inet/models/field_logger_data.dart';
import 'package:inet/models/logger_address.dart';
import 'package:inet/models/logger_data.dart';
import 'package:inet/config/config.dart';
import 'package:inet/models/logger_point.dart';

class LoggerDetail extends StatefulWidget {
  LoggerData data;

  LoggerDetail(this.data);

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return LoggerDetailState(data);
  }

}

class LoggerDetailState extends State<LoggerDetail> {
  LoggerData data;
  LoggerDetailState(this.data);

  List<bool> isExpanded = new List<bool>();

  String currentAddress = "";
  String currentName = "";
  String currentDMA = "";
  @override
  void initState() {
    super.initState();

    try {
      LoggerPoint tempAddress = listAddresses.where((element) => element.maLogger == data.objName).first;
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
  }

  List<Widget> buildChilderDetail(Map<int, double> details, String currentChannel) {
    ChannelMeasure currentMeasure = new ChannelMeasure();
    try {
      currentMeasure = listChannelMeasure.where((measure) => measure.channelID == currentChannel).first;
    }
    catch(e) {
      currentMeasure = null;
    }

    List<Widget> resultWidgets = new List<Widget>();
    details.forEach((key, value) {
      resultWidgets.add(
          new Container(
            margin: EdgeInsets.only(top: 3, bottom: 3),
            padding: EdgeInsets.only(top: 10, bottom: 10, left: 15, right: 15),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                    value.toString() + (currentMeasure != null ? " (" + currentMeasure.unit + ")" : "")
                      ?? "Chưa có dữ liệu",
                    style: Theme.of(context).textTheme.subtitle1.merge(TextStyle(fontWeight: FontWeight.w400))
                ),
                Text(
                    getDateString(key),
                    style: Theme.of(context).textTheme.subtitle1.merge(TextStyle(fontWeight: FontWeight.w400))
                ),
              ],
            ),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.all(Radius.circular(5))
            ),
          )
      );
    });
    return resultWidgets;
  }

  List<Widget> buidlLoggerDetail(LoggerData loggerData) {
    List<Widget> resultWidgets = new List<Widget>();
    for(int i = 0; i < loggerData.listElements.length; i++) {
      isExpanded.add(false);

      ChannelMeasure currentMeasure = new ChannelMeasure();
      try {
        currentMeasure = listChannelMeasure.where((measure) => measure.channelID == loggerData.listElements.elementAt(i).fieldName).first;
      }
      catch(e) {
        currentMeasure = null;
      }

      resultWidgets.add(
          new Container(
            margin: i == 0 ? EdgeInsets.only(left: 25, right: 25) : i != (loggerData.listElements.length - 1) ? EdgeInsets.only(left: 25, right: 25, top: 15) : EdgeInsets.only(left: 25, right: 25, top: 15, bottom: 15),
            padding: EdgeInsets.only(left: 20, right: 10, top: 10, bottom: 10),
            child: Theme(
              data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
              child: ExpansionTile(
                title: Column (
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      margin: EdgeInsets.only(bottom: 10),
                      child: Text(
                          currentMeasure != null ? currentMeasure.channelName : loggerData.listElements.elementAt(i).fieldName,
                          style: Theme.of(context).textTheme.headline1),
                    ),
                    !isExpanded.elementAt(i) ? Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Expanded(
                          child: Text(
                              (loggerData.listElements.elementAt(i).value.values != null && loggerData.listElements.elementAt(i).value.values.length > 0) ?
                              loggerData.listElements.elementAt(i).value.values.last.toString() + (currentMeasure != null ? " (" + currentMeasure.unit + ")" : "") : "Chưa có dữ liệu",
                              style: Theme.of(context).textTheme.subtitle1.merge(TextStyle(fontWeight: FontWeight.w400))
                          ),
                        ),
                        Expanded(
                          child: Text(
                              (loggerData.listElements.elementAt(i).value.keys != null && loggerData.listElements.elementAt(i).value.keys.length > 0) ?
                              getDateString(loggerData.listElements.elementAt(i).value.keys.last) : "",
                              style: Theme.of(context).textTheme.subtitle1.merge(TextStyle(fontWeight: FontWeight.w400))
                          ),
                        ),
                      ],
                    ) : Container()
                  ],
                ),
                children: buildChilderDetail(loggerData.listElements.elementAt(i).value, loggerData.listElements.elementAt(i).fieldName),
                tilePadding: EdgeInsets.zero,
                onExpansionChanged: (state){
                  setState(() {
                    isExpanded[i] = state;
                  });
                },
                initiallyExpanded: isExpanded.elementAt(i),
              )
            ),
            decoration: BoxDecoration(
              // color: loggersList.elementAt(i).isAlarm ? Colour('#ECF2FF') : Colour('#ECF2FF'),
                color: (loggerData.listElements.elementAt(i).value.values != null && loggerData.listElements.elementAt(i).value.values.length > 0) ? Colour('#ECF2FF') : Colors.blueGrey[100],
                borderRadius: BorderRadius.all(Radius.circular(15)),
                boxShadow: [
                  BoxShadow(
                      color: Color.fromRGBO(151, 161, 204, 0.1),
                      offset: Offset(
                          2,2
                      ),
                      blurRadius: 3,
                      spreadRadius: 1
                  )
                ]
            ),
          )
      );
    }
    return resultWidgets;
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return GestureDetector(
      onTap: (){

      },
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: Text("Thông số", style: TextStyle(color: Colour("#051639")),),
          centerTitle: true,
          backgroundColor: Colors.white,
          elevation: 0,
          actions: [
            Container(
                margin: EdgeInsets.only(right: 25),
                child: new Icon(Icons.bar_chart, color: Colour("#051639"),)
            )
          ],
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
              margin: EdgeInsets.only(top: 20, left: 25, right: 25),
              child: Text(currentName != "" ? (currentName + (data.objName != null ? (" (" + data.objName +  ")") : "")) : (data.objName ?? ""), style: Theme.of(context).textTheme.headline1,),
            ),
            Container(
              margin: EdgeInsets.only(top: 10, bottom: 20),
              child: Text(currentDMA.trim() == "" ? "Chưa có DMA" : currentDMA, style: Theme.of(context).textTheme.subtitle2),
            ),
            Expanded(child: ListView(
              children: buidlLoggerDetail(data),
            ))
          ],
        ),
      )
    );
  }

}