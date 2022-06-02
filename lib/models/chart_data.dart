class ChartData {
  String _timeStamp;
  double _value;


  ChartData(this._timeStamp, this._value);

  String get timeStamp => _timeStamp;

  set timeStamp(String value) {
    _timeStamp = value;
  }

  double get value => _value;

  set value(double value) {
    _value = value;
  }
}