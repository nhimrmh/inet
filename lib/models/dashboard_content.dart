class DashboardContent {
  String _loggerID;
  String _loggerName;
  bool _active;
  int _type;
  List<String> _listAlarm;
  List<String> _listLoggerId;
  List<DashboardElement> _listElement;
  String _channel;
  int _id;

  int get id => _id;

  set id(int value) {
    _id = value;
  }

  String get channel => _channel;

  set channel(String value) {
    _channel = value;
  }

  List<String> get listLoggerId => _listLoggerId;

  set listLoggerId(List<String> value) {
    _listLoggerId = value;
  }

  List<String> get listAlarm => _listAlarm;

  set listAlarm(List<String> value) {
    _listAlarm = value;
  }

  int get type => _type;

  set type(int value) {
    _type = value;
  }

  List<DashboardElement> get listElement => _listElement;

  set listElement(List<DashboardElement> value) {
    _listElement = value;
  }

  String get loggerID => _loggerID;

  set loggerID(String value) {
    _loggerID = value;
  }

  String get loggerName => _loggerName;

  set loggerName(String value) {
    _loggerName = value;
  }

  bool get active => _active;

  set active(bool value) {
    _active = value;
  }
}

class DashboardElement {
  String _loggerID;
  String _rawName;
  String _name;
  String _unit;
  int _id;


  int get id => _id;

  set id(int value) {
    _id = value;
  }

  String get loggerID => _loggerID;

  set loggerID(String value) {
    _loggerID = value;
  }

  String get rawName => _rawName;

  set rawName(String value) {
    _rawName = value;
  }

  String get name => _name;

  set name(String value) {
    _name = value;
  }

  String get unit => _unit;

  set unit(String value) {
    _unit = value;
  }
}