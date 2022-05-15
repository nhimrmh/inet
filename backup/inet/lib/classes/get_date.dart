import 'package:intl/intl.dart';

String getDateString1(int dateValue) {
  var date = new DateTime.fromMicrosecondsSinceEpoch(dateValue*1000);
  if(date != null) {
    return DateFormat('dd/MM/yyyy HH:mm').format(date);
  }
  else {
    return "Không có dữ liệu thời gian";
  }
}

String getDateString(int dateValue) {
  var date = new DateTime.fromMicrosecondsSinceEpoch(dateValue*1000);
  if(date != null) {
    return DateFormat('HH:mm - dd/MM/yyyy').format(date);
  }
  else {
    return "Không có dữ liệu thời gian";
  }
}

DateTime getDateFromInt(int dateValue) {
  return DateTime.fromMicrosecondsSinceEpoch(dateValue*1000);
}

String simpleDate(DateTime date) {
  var formatter = new DateFormat('dd/MM/yyyy');
  return formatter.format(date);
}

String fullDate(DateTime date) {
  var formatter = new DateFormat('HH:mm - dd/MM/yyyy');
  return formatter.format(date);
}

DateTime getDateFromString(String dateString) {
  var formatter = new DateFormat('dd/MM/yyyy');
  return formatter.parse(dateString);
}

DateTime getDateFromStringAddDay(String dateString) {
  var formatter = new DateFormat('dd/MM/yyyy');
  return formatter.parse(dateString).add(Duration(days: 1));
}