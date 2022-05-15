class FieldLoggerData {
  String _fieldName;
  Map<int, double> _value;
  Map<int, String> _alarm;

  Map<int, String> get alarm => _alarm;

  set alarm(Map<int, String> value) {
    _alarm = value;
  }

  Map<int, double> get value => _value;

  set value(Map<int, double> value) {
    _value = value;
  }

  String get fieldName => _fieldName;

  set fieldName(String value) {
    _fieldName = value;
  }
}