import 'package:inet/models/field_logger_data.dart';

class LoggerData {
  String _objName;
  List<FieldLoggerData> _listElements;

  List<FieldLoggerData> get listElements => _listElements;

  set listElements(List<FieldLoggerData> value) {
    _listElements = value;
  }

  String get objName => _objName;

  set objName(String value) {
    _objName = value;
  }
}