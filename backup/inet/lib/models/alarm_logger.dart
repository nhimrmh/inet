class AlarmLogger {
  String _loggerID;
  String _channel;
  String _alarmID;
  int _timeStamp;
  String _status;
  String _className;
  String _comment;
  double _value;

  String get channel => _channel;

  set channel(String value) {
    _channel = value;
  }

  double get value => _value;

  set value(double value) {
    _value = value;
  }

  String get comment => _comment;

  set comment(String value) {
    _comment = value;
  }

  String get className => _className;

  set className(String value) {
    _className = value;
  }

  String get status => _status;

  set status(String value) {
    _status = value;
  }

  String get loggerID => _loggerID;

  set loggerID(String value) {
    _loggerID = value;
  }

  int get timeStamp => _timeStamp;

  set timeStamp(int value) {
    _timeStamp = value;
  }

  String get alarmID => _alarmID;

  set alarmID(String value) {
    _alarmID = value;
  }
}