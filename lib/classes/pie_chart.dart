import 'package:colour/colour.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:inet/config/config.dart';
import '../models/piechart_data.dart';
import 'indicator.dart';

class MyPieChart extends StatefulWidget {
  List<MyPieChartData> data;
  double total;
  MyPieChart({Key key, this.data, this.total}) : super(key: key);

  @override
  State<StatefulWidget> createState() => PieChartState(data, total);
}

class PieChartState extends State {
  List<MyPieChartData> data;
  double total;

  PieChartState(this.data, this.total);

  int touchedIndex = -1;

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
        aspectRatio: 1.2,
        child: Stack(
          children: [
            PieChart(
              PieChartData(
                  pieTouchData: PieTouchData(touchCallback:
                      (FlTouchEvent event, pieTouchResponse) {
                    setState(() {
                      if (!event.isInterestedForInteractions ||
                          pieTouchResponse == null ||
                          pieTouchResponse.touchedSection == null) {
                        touchedIndex = -1;
                        return;
                      }
                      touchedIndex = pieTouchResponse
                          .touchedSection.touchedSectionIndex;
                    });
                  }),
                  borderData: FlBorderData(
                    show: false,
                  ),
                  sectionsSpace: 0,
                  centerSpaceRadius: 80,
                  sections: showingSections()),
            ),
            Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    margin: EdgeInsets.only(bottom: 5),
                    child: Text("Tổng cộng", textAlign: TextAlign.center,),
                  ),
                  Text("${total.toStringAsFixed(1)}", textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold),),
                ],
              )
            )
          ],
        )
    );
  }

  List<PieChartSectionData> showingSections() {
    int i = 0;
    List<PieChartSectionData> result = [];
    if(data != null && data.isNotEmpty) {
      for(MyPieChartData item in data) {
        final isTouched = i == touchedIndex;
        final fontSize = isTouched ? 16.0 : 14.0;
        final radius = isTouched ? 90.0 : 80.0;
        final String percentage = ((item.value/total)*100).toStringAsFixed(1);

        if(item.value > 0) {
          result.add(
              PieChartSectionData(
                color: Colour(listColors.elementAt(i%5)),
                value: item.value,
                title: '${item.loggerID}\n($percentage%)',
                radius: radius,
                borderSide: const BorderSide(color: Colors.white, width: 2),
                titleStyle: TextStyle(
                    fontSize: fontSize,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xffffffff)),
              )
          );
          i++;
        }

      }
      return result;
    }
    else {
      return [];
    }
  }
}