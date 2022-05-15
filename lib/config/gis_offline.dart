import 'package:latlong2/latlong.dart';
import 'package:inet/models/logger_point.dart';

class GisOffline {
  List<LoggerPoint> _listLogger;

  GisOffline(this._listLogger);

  List<LoggerPoint> get listLogger => _listLogger;

  set listLogger(List<LoggerPoint> value) {
    _listLogger = value;
  }
}

LoggerPoint _2006 = new LoggerPoint.offline("2006", "Mai Chí Thọ - Nguyễn Cơ Thạch", "", LatLng(10.772754084425861, 106.72274851779522), false);
GisOffline gisThuDuc = new GisOffline([_2006]);

