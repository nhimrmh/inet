import 'package:latlong2/latlong.dart';
import 'package:inet/models/alarm_type.dart';


class LoggerPoint {
  String _maLogger;
  String _tenLogger;
  String _mucDichSuDung;
  String _quanHuyen;
  String _diaChi;
  LatLng _position;
  double _pressure;
  bool _isFocused;
  String _dma;
  List<AlarmType> _listAlarm;


  List<AlarmType> get listAlarm => _listAlarm;

  set listAlarm(List<AlarmType> value) {
    _listAlarm = value;
  }

  LoggerPoint();

  LoggerPoint.offline(this._maLogger, this._tenLogger, this._diaChi, this._position, this._isFocused);


  String get dma => _dma;

  set dma(String value) {
    _dma = value;
  }

  bool get isFocused => _isFocused;

  set isFocused(bool value) {
    _isFocused = value;
  }

  double get pressure => _pressure;

  set pressure(double value) {
    _pressure = value;
  }

  String get diaChi => _diaChi;

  set diaChi(String value) {
    _diaChi = value;
  }

  LatLng get position => _position;

  set position(LatLng value) {
    _position = value;
  }

  String get maLogger => _maLogger;

  set maLogger(String value) {
    _maLogger = value;
  }

  String get tenLogger => _tenLogger;

  String get quanHuyen => _quanHuyen;

  set quanHuyen(String value) {
    _quanHuyen = value;
  }

  String get mucDichSuDung => _mucDichSuDung;

  set mucDichSuDung(String value) {
    _mucDichSuDung = value;
  }

  set tenLogger(String value) {
    _tenLogger = value;
  }
}