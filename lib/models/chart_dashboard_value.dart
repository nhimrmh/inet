import 'package:fl_animated_linechart/chart/line_chart.dart';

class ChartDashboardValue {
  String _loggerName;
  List<String> _listChannels;
  int _idx;

  int get idx => _idx;

  set idx(int value) {
    _idx = value;
  }

  String get loggerName => _loggerName;

  set loggerName(String value) {
    _loggerName = value;
  }

  List<String> get listChannels => _listChannels;

  set listChannels(List<String> value) {
    _listChannels = value;
  }
}