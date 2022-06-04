import 'package:inet/models/chart_data.dart';

class ChartDataID {
  String _id;
  List<ChartData> _chartData;

  String get id => _id;

  set id(String value) {
    _id = value;
  }

  List<ChartData> get chartData => _chartData;

  set chartData(List<ChartData> value) {
    _chartData = value;
  }
}