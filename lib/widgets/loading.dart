import 'package:colour/colour.dart';
import 'package:fl_animated_linechart/chart/animated_line_chart.dart';
import 'package:fl_animated_linechart/chart/line_chart.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

Widget fakeChart() {
  LineChart lineChart;

  Map<DateTime, double> chartData = new Map<DateTime, double>();

  chartData[DateTime.fromMicrosecondsSinceEpoch(1620108900000)] = 1;
  chartData[DateTime.fromMicrosecondsSinceEpoch(1620109800000)] = 10;

  lineChart = LineChart.fromDateTimeMaps([chartData], [Colors.green]);

  return AnimatedLineChart(
    lineChart,
    key: UniqueKey(),
  );
}

Widget searchBar(TextEditingController controller, Function searchFunction, Function textChangedFunction) {
  return Center(
    child: Container(
      margin: EdgeInsets.only(left: 20, right: 20),
      child: TextFormField(
        controller: controller,
        autovalidateMode: AutovalidateMode.disabled,
        onChanged: (text){
          textChangedFunction(text);
        },
        decoration: InputDecoration(
          filled: true,
          fillColor: Colour('#F8FAFF'),
          contentPadding: EdgeInsets.only(top: 6, bottom: 6, left: 15, right: 15),
          suffixIcon: IconButton(
            onPressed: (){
              searchFunction();
            },
            icon: Icon(Icons.search, color: Colour('#666D75'), size: 30,),
          ),
          hintText: "Nhập thông tin logger cần tìm", hintStyle: TextStyle(fontSize: 18, fontWeight: FontWeight.w400),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(20)),
            borderSide: BorderSide(
              color: Colour('#D1DBEE'),
              width: 1
            )
          ),
          border: OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(20)),
              borderSide: BorderSide(
                  color: Colour('#D1DBEE'),
                  width: 1
              )
          ),

        ),
      ),
    ),
  );
}

Widget loading (ThemeData themeData, String title) {
  return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircularProgressIndicator(),
          Container(
            child: Text("Đang tải dữ liệu " + title + ", vui lòng đợi", style: themeData.textTheme.subtitle1.merge(TextStyle(fontWeight: FontWeight.w400)),),
            margin: EdgeInsets.only(top: 20, bottom: 25, left: 15, right: 15),
          ),
        ],
      )
  );
}

Widget loadError(Function function, ThemeData themeData, int type, String title) {
  return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            margin: EdgeInsets.only(bottom: 20),
            child: type == 1 ? Icon(Icons.work_off_outlined, color: Colour("#051639"), size: 50,) : Icon(Icons.wifi_off, color: Colour("#051639"), size: 50,),
          ),
          Text("Tải dữ liệu " + title + " không thành công", style: themeData.textTheme.subtitle1),
          Container(
            child: Text(type == 0 ? "Không có kết nối internet, vui lòng kiểm tra lại" : "Không thể kết nối tới máy chủ", style: themeData.textTheme.subtitle1.merge(TextStyle(fontWeight: FontWeight.w400))),
            margin: EdgeInsets.only(top: 5, bottom: 20, left: 15, right: 15),
          ),
          GestureDetector(
            onTap: (){
              function();
            },
            child: Container(
              padding: EdgeInsets.only(left: 15, right: 20, top: 10, bottom: 10),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.refresh),
                  Container(
                    margin: EdgeInsets.only(left: 10),
                    child: Text("Thử lại", style: themeData.textTheme.subtitle1,),
                  )
                ],
              ),
              decoration: BoxDecoration(
                color: Colour('#89A1FF'),
                borderRadius: BorderRadius.all(Radius.circular(10)),
                boxShadow: [
                  BoxShadow(
                      color: Color.fromRGBO(151, 161, 204, 0.5),
                      offset: Offset(
                          2,2
                      ),
                      blurRadius: 3,
                      spreadRadius: 0
                  )
                ]
              ),
            ),
          ),
        ],
      )
  );
}

Widget loadingDangNhap(ThemeData themeData) {
  return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircularProgressIndicator(),
          Container(
            child: Text("Đang đăng nhập", style: themeData.textTheme.subtitle1.merge(TextStyle(fontWeight: FontWeight.w400)),),
            margin: EdgeInsets.only(top: 20, bottom: 25, left: 15, right: 15),
          ),
        ],
      )
  );
}

Widget success(ThemeData themeData, String title) {
  return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.check_circle, size: 50, color: Colors.green[700],),
          Container(
            child: Text(title, style: themeData.textTheme.subtitle1.merge(TextStyle(fontWeight: FontWeight.w400)),),
            margin: EdgeInsets.only(top: 20, bottom: 25, left: 15, right: 15),
          ),
        ],
      )
  );
}

Widget emptyData(ThemeData themeData, String description) {
  return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            margin: EdgeInsets.only(bottom: 20),
            child: Icon(Icons.wb_cloudy_outlined, color: Colour("#051639"), size: 50,),
          ),
          Text("Không tìm thấy dữ liệu", style: themeData.textTheme.subtitle1),
          Container(
            child: Text(description, style: themeData.textTheme.subtitle1.merge(TextStyle(fontWeight: FontWeight.w400))),
            margin: EdgeInsets.only(top: 5, bottom: 20, left: 15, right: 15),
          ),
        ],
      )
  );
}