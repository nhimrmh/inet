import 'dart:convert';
import 'dart:math';

import 'package:crypto/crypto.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:http/http.dart' as http;
import 'package:inet/config/config.dart';
import 'package:inet/models/chart_dashboard.dart';

import 'get_date.dart';

const _chars = 'abcdefghijklmnopqrstuvwxyz';
Random _rnd = Random();

String getRandomString(int length) => String.fromCharCodes(Iterable.generate(
    length, (_) => _chars.codeUnitAt(_rnd.nextInt(_chars.length))));

class SocketService {

  void createSocketConnection(Function setDataChanged) async {
    try {
      for(int i = 0; i < ioConnector.length; i++) {
        if(ioAuthenicator.elementAt(i).isEmpty) {
          ioAuthenicator[i] = "http://103.163.214.64:8092"; ///set default io authenticator server
        }

        await http.get(Uri.parse(ioAuthenicator.elementAt(i) + '/session/getId')).then((value){
          if(ioConnector.isEmpty) {
            ioConnector[i] = "http://103.163.214.64:9092"; ///set default io connector server
          }

          IO.Socket socket = IO.io(ioConnector.elementAt(i) + '?userId=' + value.body.toString(), <String, dynamic>{
            'transports': ['websocket'],
          });

          listSocket.add(socket);

          socket.on("disconnect", (_) => print('Disconnected'));

          socket.on("connect", (_) {
            isConnectToSocket = true;
            pushDataEvent(setDataChanged, socket, i+1);
            // getDataChart("2006", "a00", 100, setChartChanged);
          });
        });
      }
    }
    catch(exception) {

    }
  }

  void pushDataEvent(Function setDataChanged, IO.Socket currentSocket, int idx) {
    // String myJSON  = "{\"id\":1, \"command\": \"catching\", \"event\":\"synch\",\"fixInterval\":3000,\"listTag\": [{\"dataType\":\"TAGCURRENT\",\"name\":\"cello-logger\",\"query\":\".\",\"modify\":null,\"value\":null}]}";
    String myJSON  = "{\"id\":1, \"command\": \"catching\", \"event\":\"synch\",\"fixInterval\":null,\"listTag\": [{\"dataType\":\"TAGCURRENT\",\"name\":\"cello-logger\",\"query\":{\"randomId\": \"1\",\"mode\": \"0\", \"statement\": \".\"},\"modify\":null}]}";
    //var json = jsonDecode(myJSON);

    currentSocket.emit('push_data_event', myJSON);
    //this.socket.on("synch", (_) => print("receive data"));

    currentSocket.on("synch", (result) {
      isConnectToSocket = true;
      if(setDataChanged != null) {
        setDataChanged(result.toString(), idx);
      }
    });
  }

  void getDashboardDataChart(List<ChartDashboard> listChartDashboard, Function function, IO.Socket currentSocket, int socketIdx) {
    String myJSON;

    Random random = new Random();
    int randomID = random.nextInt(100) + 1;

    myJSON  = "{\"id\":" + randomID.toString() + ", \"command\": \"query\", \"event\":\"dataset\",\"fixInterval\":null,\"listTag\": [";

    for(int i = 0; i < listChartDashboard.length; i++) {
      String randomString = getRandomString(20);
      if(i != listChartDashboard.length - 1) {
        myJSON += "{\"dataType\":\"TAGQUERY\",\"name\":\"" + listChartDashboard.elementAt(i).loggerName + "\",\"query\":{\"randomId\": \"" + randomString
            + "\",\"mode\": \"0\", \"statement\": \"SELECT timestamp, "
            + (listChartDashboard.elementAt(i).listChannels.length > 1 ? listChartDashboard.elementAt(i).listChannels.join(", ") : listChartDashboard.elementAt(i).listChannels.first)
            + " FROM DATATABLE ORDER BY timestamp DESC LIMIT 1000\"},\"modify\":null}, ";
      }
      else {
        myJSON += "{\"dataType\":\"TAGQUERY\",\"name\":\"" + listChartDashboard.elementAt(i).loggerName + "\",\"query\":{\"randomId\": \"" + randomString
            + "\",\"mode\": \"0\", \"statement\": \"SELECT timestamp, "
            + (listChartDashboard.elementAt(i).listChannels.length > 1 ? listChartDashboard.elementAt(i).listChannels.join(", ") : listChartDashboard.elementAt(i).listChannels.first)
            + " FROM DATATABLE ORDER BY timestamp DESC LIMIT 1000\"},\"modify\":null}";
      }

    }

    myJSON += "]}";

    currentSocket.emit('push_data_event', myJSON);
    //this.socket.on("synch", (_) => print("receive data"));
    currentSocket.on("dataset", (result) {
      function(result, listChartDashboard, socketIdx);
    });
  }

  void getDataChart(String loggerName, String channelSelect, int numberOfRecords, String fromDate, String toDate, Function function, IO.Socket currentSocket, int currentIdx, int total) {
    String randomString = getRandomString(20);
    String myJSON;

    Random random = new Random();
    int randomID = random.nextInt(100) + 1;

    if(fromDate != "" && toDate != ""){
      myJSON  = "{\"id\":" + randomID.toString() + ", \"command\": \"query\", \"event\":\"dataset\",\"fixInterval\":null,\"listTag\": [{\"dataType\":\"TAGQUERY\",\"name\":\"" + loggerName + "\",\"query\":{\"randomId\": \"" + randomString + "\",\"mode\": \"0\", \"statement\": \"SELECT timestamp, " + channelSelect + " FROM DATATABLE WHERE timestamp >= " + getDateFromString(fromDate).millisecondsSinceEpoch.toString() + " AND timestamp <= " + getDateFromStringAddDay(toDate).millisecondsSinceEpoch.toString() + " ORDER BY timestamp DESC LIMIT " + numberOfRecords.toString() + "\"},\"modify\":null}]}";
    }
    else if(fromDate != "") {
      myJSON  = "{\"id\":" + randomID.toString() + ", \"command\": \"query\", \"event\":\"dataset\",\"fixInterval\":null,\"listTag\": [{\"dataType\":\"TAGQUERY\",\"name\":\"" + loggerName + "\",\"query\":{\"randomId\": \"" + randomString + "\",\"mode\": \"0\", \"statement\": \"SELECT timestamp, " + channelSelect + " FROM DATATABLE WHERE timestamp >= " + getDateFromString(fromDate).millisecondsSinceEpoch.toString() + " ORDER BY timestamp DESC LIMIT " + numberOfRecords.toString() + "\"},\"modify\":null}]}";
    }
    else if(toDate != "") {
      myJSON  = "{\"id\":" + randomID.toString() + ", \"command\": \"query\", \"event\":\"dataset\",\"fixInterval\":null,\"listTag\": [{\"dataType\":\"TAGQUERY\",\"name\":\"" + loggerName + "\",\"query\":{\"randomId\": \"" + randomString + "\",\"mode\": \"0\", \"statement\": \"SELECT timestamp, " + channelSelect + " FROM DATATABLE WHERE timestamp <= " + getDateFromStringAddDay(toDate).millisecondsSinceEpoch.toString() + " ORDER BY timestamp DESC LIMIT " + numberOfRecords.toString() + "\"},\"modify\":null}]}";
    }
    else {
      myJSON  = "{\"id\":" + randomID.toString() + ", \"command\": \"query\", \"event\":\"dataset\",\"fixInterval\":null,\"listTag\": [{\"dataType\":\"TAGQUERY\",\"name\":\"" + loggerName + "\",\"query\":{\"randomId\": \"" + randomString + "\",\"mode\": \"0\", \"statement\": \"SELECT timestamp, " + channelSelect + " FROM DATATABLE ORDER BY timestamp DESC LIMIT " + numberOfRecords.toString() + "\"},\"modify\":null}]}";
    }

    currentSocket.emit('push_data_event', myJSON);

    currentSocket.on("dataset", (result) {
      function(result, loggerName, channelSelect, currentIdx);
    });
  }

  Future<String> getView(String username, String password) async {
    try {
      await http.get(Uri.parse('http://' + currentServer + '/session/getView?username=' + username + '&password=' + sha256.convert(utf8.encode(password)).toString())).then((value){
        viewData = value.body.toString();
      });
      return viewData;
    }
    catch(exception) {
      return "timeout";
    }
  }

  Future<String> addtoken(String username, String token) async {
    try {
      await http.get(Uri.parse('http://' + currentServer + '/session/saveToken?username=' + username + '&token=' + token)).then((value){
        String result = value.body.toString();
      });
      return viewData;
    }
    catch(exception) {
      return "timeout";
    }
  }

  Future<String> getFeature() async {
    if(linkFeatureLayer != "") {
      await http.get(Uri.parse(linkFeatureLayer + '/query?where=MaLogger+is+not+NULL&text=&objectIds=&time=&geometry=&geometryType=esriGeometryPoint&inSR=&spatialRel=esriSpatialRelIntersects&relationParam=&outFields=MaLogger%2C+TenLogger%2C+Phuong%2C+QuanHuyen+%2C+DiaChi%2C+Pressure%2C+MucDichSuDung+&returnGeometry=true&returnTrueCurves=false&maxAllowableOffset=&geometryPrecision=&outSR=4326&having=&returnIdsOnly=false&returnCountOnly=false&orderByFields=&groupByFieldsForStatistics=&outStatistics=&returnZ=false&returnM=false&gdbVersion=&historicMoment=&returnDistinctValues=false&resultOffset=&resultRecordCount=&queryByDistance=&returnExtentOnly=false&datumTransformation=&parameterValues=&rangeValues=&quantizationParameters=&f=pjson')).then((value){
        viewData = value.body.toString();
      });
      return viewData;
    }
    else {
      return "";
    }
  }

  Future<String> getAddresses() async {
    if(linkFeatureLayer != "") {
      await http.get(Uri.parse(linkFeatureLayer + '/query?where=MaLogger+is+not+NULL&text=&objectIds=&time=&geometry=&geometryType=esriGeometryEnvelope&inSR=&spatialRel=esriSpatialRelIntersects&relationParam=&outFields=MaLogger%2C+TenLogger%2C+DiaChi&returnGeometry=true&returnTrueCurves=false&maxAllowableOffset=&geometryPrecision=&outSR=&having=&returnIdsOnly=false&returnCountOnly=false&orderByFields=&groupByFieldsForStatistics=&outStatistics=&returnZ=false&returnM=false&gdbVersion=&historicMoment=&returnDistinctValues=false&resultOffset=&resultRecordCount=&queryByDistance=&returnExtentOnly=false&datumTransformation=&parameterValues=&rangeValues=&quantizationParameters=&f=pjson')).then((value){
        viewData = value.body.toString();
      });
      return viewData;
    }
    else {
      return "";
    }
  }

  //https://ags.capnuocthuduc.vn/server/rest/services/ALTD/DiemApLuc/MapServer/0/query?where=1%3D1&text=&objectIds=&time=&geometry=&geometryType=esriGeometryEnvelope&inSR=&spatialRel=esriSpatialRelIntersects&relationParam=&outFields=&returnGeometry=true&returnTrueCurves=false&maxAllowableOffset=&geometryPrecision=&outSR=&having=&returnIdsOnly=false&returnCountOnly=false&orderByFields=&groupByFieldsForStatistics=&outStatistics=&returnZ=false&returnM=false&gdbVersion=&historicMoment=&returnDistinctValues=false&resultOffset=&resultRecordCount=&queryByDistance=&returnExtentOnly=false&datumTransformation=&parameterValues=&rangeValues=&quantizationParameters=&f=html
}