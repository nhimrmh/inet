import 'package:latlong2/latlong.dart';

class LoggerAddress {
  String _loggerID;
  String _diachi;
  String _tenLogger;
  String _dma;
  String _district;
  LatLng _position;

  String get district => _district;

  set district(String value) {
    _district = value;
  }

  LatLng get position => _position;

  set position(LatLng value) {
    _position = value;
  }

  String get dma => _dma;

  set dma(String value) {
    _dma = value;
  }

  String get loggerID => _loggerID;

  set loggerID(String value) {
    _loggerID = value;
  }

  String get diachi => _diachi;

  set diachi(String value) {
    _diachi = value;
  }

  String get tenLogger => _tenLogger;

  set tenLogger(String value) {
    _tenLogger = value;
  }
}