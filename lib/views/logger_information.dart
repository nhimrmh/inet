import 'package:colour/colour.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../config/config.dart';
import '../main/logger_detail.dart';
import '../models/logger_data.dart';
import '../models/logger_point.dart';

class LoggerInformation extends StatelessWidget {
  LoggerData data;

  LoggerInformation(this.data);

  String currentAddress = "";
  String currentName = "";
  String currentDMA = "";

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
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

    return Scaffold(
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
          Expanded(child: ListView(children: [LoggerDetail(data)],))
        ],
      )
    );
  }

}