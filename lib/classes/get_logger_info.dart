import '../config/config.dart';
import '../models/logger_point.dart';

String getLoggerName(String loggerID) {
  String currentName = "";
  try {
    LoggerPoint tempAddress = listAddresses.where((element) => element.maLogger == loggerID).first;
    if(tempAddress != null) {
      if(tempAddress.tenLogger != null && tempAddress.tenLogger != "") {
        currentName = tempAddress.tenLogger;
      }
      else {
        currentName = "Logger chưa có tên";
      }

      return currentName;
    }
    return "Logger chưa có tên";
  }
  catch(e) {
    return "Logger chưa có tên";
  }
}

String getLoggerAddress(String loggerID) {
  String currentAddress = "";
  try {
    LoggerPoint tempAddress = listAddresses.where((element) => element.maLogger == loggerID).first;
    if(tempAddress != null) {
      if(tempAddress.dma != null && tempAddress.dma != "") {
        currentAddress = tempAddress.dma;
      }
      else {
        currentAddress = tempAddress.tenLogger;
      }

      return currentAddress;
    }
    return "Logger chưa có tên";
  }
  catch(e) {
    return "Logger chưa có tên";
  }
}

String getLoggerDMA(String loggerID) {
  String currentDMA = "";
  try {
    LoggerPoint tempAddress = listAddresses.where((element) => element.maLogger == loggerID).first;
    if(tempAddress != null) {
            if(tempAddress.dma != null && tempAddress.dma != "") {
        currentDMA = tempAddress.dma;
      }
      else {
        currentDMA = "";
      }

      return currentDMA;
    }
    return "";
  }
  catch(e) {
    return "";
  }
}