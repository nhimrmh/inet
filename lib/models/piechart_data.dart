class MyPieChartData {
  String _loggerID;
  double _value;
  String _channel;

  String get loggerID => _loggerID;

  set loggerID(String value) {
    _loggerID = value;
  }

  double get value => _value;

  String get channel => _channel;

  set channel(String value) {
    _channel = value;
  }

  set value(double value) {
    _value = value;
  }
}