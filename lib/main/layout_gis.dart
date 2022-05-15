import 'dart:async';
import 'dart:convert';
import 'package:colour/colour.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_map/flutter_map.dart';

import 'package:ionicons/ionicons.dart';
import 'package:latlong2/latlong.dart';

import 'package:inet/classes/socket_service.dart';
import 'package:inet/main.dart';
import 'package:inet/models/logger_point.dart';

class MapScene extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return MapSceneState();
  }

}

class MapSceneState extends State<MapScene> {
  List<LoggerPoint> listLoggerPoints = new List<LoggerPoint>();
  int viewMenu = 0;
  bool isViewMenu = false;
  bool isSearch = false;
  bool isInformation = false;
  bool isNoInternet = false;
  TextEditingController searchController = new TextEditingController();
  MapController _mapController = new MapController();

  Map<String, bool> listDMA = new Map<String, bool>();

  bool isTatCa = true;

  bool isInitPhuong = false;

  List<Marker> listMarkers = new List<Marker>();

  String currentSearchText = "";

  LoggerPoint currentPoint = new LoggerPoint();

  final Connectivity _connectivity = Connectivity();
  StreamSubscription<ConnectivityResult> _connectivitySubscription;

  void clearFocus() {
    FocusManager.instance.primaryFocus?.unfocus();
    setState(() {
      isViewMenu = false;
      isSearch = false;
      isInformation = false;
      clearFocusLogger();
    });
  }

  void clearFocusLogger() {
    setState(() {
      isInformation = false;
      try {
        listLoggerPoints.where((element) => element.isFocused == true).first.isFocused = false;
      }
      catch(e) {

      }
    });
  }

  void getFeatures() {
    final SocketService socketService = injector.get<SocketService>();
    socketService.getFeature().then((value){
      setFeaturesChanged(value);
    });
  }

  void setFeaturesChanged(String result) {
    if(mounted) {
      if(result != null && result.trim() != "") {

        listLoggerPoints = new List<LoggerPoint>();

        Map<String, dynamic> jsonResult = Map<String, dynamic>.from(json.decode(result));

        jsonResult.forEach((key, value) {
          print(key);
          if(key == "features") {
            List<dynamic> listFeatures = value;
            listFeatures.forEach((element) {
              Map<String, dynamic> featureInfo = Map<String, dynamic>.from(element);

              LoggerPoint temp = new LoggerPoint();
              double temp_x = 0;
              double temp_y = 0;

              featureInfo.forEach((key, value) {
                if(key == "attributes") {
                  Map<String, dynamic> mapTenLogger = value;
                  mapTenLogger.forEach((key, value) {
                    if(key == "TenLogger") {
                      temp.tenLogger = value ?? "";
                    }
                    // else if(key == "Phuong") {
                    //   temp.phuong = value.toString() ?? "";
                    // }
                    else if(key == "QuanHuyen") {
                      temp.quanHuyen = value.toString() ?? "";
                    }
                    else if(key == "DiaChi") {
                      temp.diaChi = value ?? "";
                    }
                    else if(key == "Pressure") {
                      temp.pressure = double.parse(value != null ? value.toString() : "0");
                    }
                    else if(key == "MucDichSuDung") {
                      temp.mucDichSuDung = value ?? "";
                    }
                  });

                }
                else if (key == "geometry") {
                  Map<String, dynamic> mapGeometryLogger = value;
                  mapGeometryLogger.forEach((key, value) {
                    if(key == "x") {
                      temp_x = value;
                    }
                    else if(key == "y") {
                      temp_y = value;
                    }
                  });
                  temp.position = LatLng(temp_y, temp_x);
                }
              });

              Marker tempMarker = new Marker(
                width: 30,
                height: 30,
                point: LatLng(temp_y, temp_x),
                builder: (ctx) =>
                (listDMA.containsKey(temp.dma) && listDMA[temp.dma] != true && temp.isFocused != true) ? Container() : GestureDetector(
                  onTap: (){
                    _mapController.move(temp.position, _mapController.zoom);
                    setState(() {
                      clearFocusLogger();
                      temp.isFocused = true;
                      currentPoint = temp;
                      isInformation = true;
                      isViewMenu = false;
                    });
                  },
                  child: Stack(
                    children: [
                      Positioned.fill(child: Align(
                        alignment: Alignment.center,
                        child: temp.isFocused ? Icon(Ionicons.location,
                          color: Colors.black, size: 30,) : Container(),
                      )),
                      Positioned.fill(child: Align(
                        alignment: Alignment.center,
                        child: temp.isFocused ? Icon(Ionicons.location,
                          color: Colors.greenAccent, size: 28,) : Container(),
                      )),
                      Positioned.fill(child: Align(
                        alignment: Alignment.center,
                        child: Icon(Ionicons.location, size: 20,
                          color: temp.pressure == null ? Colors.black
                              : temp.pressure <= 10 ? Colors.red[700] : temp.pressure <= 20 ? Colors.yellow[700] : temp.pressure <= 30 ? Colors.yellow[700] : Colors.green[700],),
                      )),
                      Positioned.fill(child: Align(
                        alignment: Alignment.center,
                        child: Icon(Ionicons.location_outline, size: 20,
                          color: Colors.black,),
                      )),

                    ],
                  ),
                )
              );

              setState(() {
                listMarkers.add(tempMarker);
              });

              temp.isFocused = false;

              listLoggerPoints.add(temp);
            });
          }
        });

        listLoggerPoints.sort((a,b) => a.tenLogger.compareTo(b.tenLogger));

      }
    }
  }

  @override
  void initState() {
    super.initState();
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
        statusBarColor: Colors.transparent
    ));

    initConnectivity();
    _connectivitySubscription =
        _connectivity.onConnectivityChanged.listen(_updateConnectionStatus);

    getFeatures();
  }

  Future<void> initConnectivity() async {
    ConnectivityResult result = ConnectivityResult.none;
    // Platform messages may fail, so we use a try/catch PlatformException.
    try {
      result = await _connectivity.checkConnectivity();
    } on PlatformException catch (e) {
      print(e.toString());
    }

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) {
      return Future.value(null);
    }

    return _updateConnectionStatus(result);
  }

  Future<void> _updateConnectionStatus(ConnectivityResult result) async {
    switch (result) {
      case ConnectivityResult.wifi:
        break;
      case ConnectivityResult.mobile:
        break;
      case ConnectivityResult.none:
        setState(() {
          isNoInternet = true;
        });
        break;
      default:
      //setState(() => _connectionStatus = 'Failed to get connectivity.');
        break;
    }
  }

  void inversePhuong(bool isChecked) {
    if(viewMenu == 1) {
      listDMA.forEach((key, value) {
        listDMA[key] = isChecked;
      });
    }
  }

  Widget searchBar() {
    return TextFormField(
      controller: searchController,
      autovalidateMode: AutovalidateMode.disabled,
      onChanged: (text){
        setState(() {
          currentSearchText = text;
        });
      },
      onTap: () {
        clearFocus();
        setState(() {
          isSearch = true;
          isViewMenu = false;
        });
      },
      decoration: InputDecoration(
        filled: true,
        fillColor: Colour('#F8FAFF'),
        contentPadding: EdgeInsets.only(top: 6, bottom: 6, left: 15, right: 15),
        suffixIcon: IconButton(
          onPressed: (){
                (){};
          },
          icon: Icon(Icons.search, color: Colour('#666D75'), size: 30,),
        ),
        hintText: "Nhập tên logger cần tìm", hintStyle: TextStyle(fontSize: 16, fontWeight: FontWeight.w400),
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
    );
  }

  List<Widget> ListSearch(String searchText) {
    List<Widget> resultWidgets = new List<Widget>();
    if(searchText.trim() != "") {
      for(int i = 0; i < listLoggerPoints.length; i++) {
        if(listLoggerPoints.elementAt(i).tenLogger.trim().toUpperCase().contains(searchText.trim().toUpperCase())) {
          resultWidgets.add(
              GestureDetector(
                onTap: (){
                  clearFocusLogger();
                  clearFocus();

                  _mapController.move(listLoggerPoints.elementAt(i).position, _mapController.zoom);
                  setState(() {
                    currentPoint = listLoggerPoints.elementAt(i);
                    listLoggerPoints.elementAt(i).isFocused = true;
                    isInformation = true;
                  });
                },
                child: Container(
                  width: double.infinity,
                  padding: EdgeInsets.only(top: 10, bottom: 10, left: 15 , right: 15),
                  child: Text(listLoggerPoints.elementAt(i).tenLogger.trim()),
                  decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border(
                          top: BorderSide(width: 1, color: Colour("#D1DBEE"))
                      )
                  ),
                )
              )
          );
        }
      }
    }
    else {
      resultWidgets.add(Container());
    }
    return resultWidgets;
  }

  Widget SearchPanel(String searchText) {
    return Container(
      color: Colors.transparent,
      width: double.infinity,
      child: ListView(
        children: ListSearch(searchText),
      ),
    );
  }

  Widget DetailPanel(List<Widget> listItem) {
    return Align(
      alignment: Alignment.topRight,
      child: Container(
        padding: EdgeInsets.only(left: 15, right: 15),
        height: double.infinity,
        width: MediaQuery.of(context).size.width/2,
        child: Column(
          mainAxisSize: MainAxisSize.max,
          children: [
            Container(
              margin: EdgeInsets.only(top: 10, bottom: 10),
              child: Text(viewMenu == 0 ? "Danh sách Logger" : "Lọc theo Phường", style: Theme.of(context).textTheme.headline1,),
            ),
            viewMenu != 0 ? Row(
              children: [
                Checkbox(
                  value: isTatCa,
                  onChanged: (isChecked){
                    clearFocusLogger();
                    recenterMap();
                    setState(() {
                      isTatCa = isChecked;
                      inversePhuong(isChecked);
                    });
                }),
                GestureDetector(
                  onTap: () {
                    clearFocusLogger();
                    recenterMap();
                    setState(() {
                      isTatCa = !isTatCa;
                    });
                    inversePhuong(isTatCa);
                  },
                  child: Container(
                    padding: EdgeInsets.only(top: 10, bottom: 10),
                    child: Text("Tất cả"),
                    decoration: BoxDecoration(
                        border: Border(
                            top: BorderSide(width: 1, color: Colour("#D1DBEE"))
                        )
                    ),
                  ),
                )
              ],
            ) : Container(),
            Expanded(
                child: ListView(
                  children: listItem,
                )
            ),
          ],
        ),
        decoration: BoxDecoration(
          color: Colors.white
        ),
      ),
    );
  }

  Widget InformationPanel(LoggerPoint item) {
    return currentPoint.tenLogger.trim() != "" ? Align(
        alignment: Alignment.bottomCenter,
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.only(left: 25, right: 15, top: 15, bottom: 15),
          child: Row(
            children: [
              Expanded(child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    margin: EdgeInsets.only(bottom: 10),
                    child: Text("Tên logger: " + item.tenLogger, style: Theme.of(context).textTheme.headline1,),
                  ),
                  Container(
                    margin: EdgeInsets.only(bottom: 10),
                    child: Text("Địa chỉ: " + (item.diaChi.trim() == "" ? "Chưa có" : item.diaChi.trim()),
                      style: Theme.of(context).textTheme.subtitle1.merge(TextStyle(fontWeight: FontWeight.w400)),),
                  ),
                  Container(
                    margin: EdgeInsets.only(bottom: 10),
                    child: Text("DMA: " + (item.dma.trim() == "" ? "Chưa có" : item.dma.trim()),
                      style: Theme.of(context).textTheme.subtitle1.merge(TextStyle(fontWeight: FontWeight.w400)),),
                  ),
                  Container(
                    margin: EdgeInsets.only(bottom: 10),
                    child: Text("Quận huyện: " + (item.quanHuyen.trim() == "" ? "Chưa có" : item.quanHuyen.trim()),
                      style: Theme.of(context).textTheme.subtitle1.merge(TextStyle(fontWeight: FontWeight.w400)),),
                  ),
                  Container(
                    margin: EdgeInsets.only(bottom: 10),
                    child: Text("Áp lực: " + item.pressure.toString(),
                      style: Theme.of(context).textTheme.subtitle1.merge(TextStyle(fontWeight: FontWeight.w400)),),
                  ),
                  Container(
                    margin: EdgeInsets.only(bottom: 0),
                    child: Text("Mục đích sử dụng: " + (item.mucDichSuDung.trim() == "" ? "Chưa có" : item.mucDichSuDung.trim()),
                      style: Theme.of(context).textTheme.subtitle1.merge(TextStyle(fontWeight: FontWeight.w400)),),
                  ),
                ],
              )),
              GestureDetector(
                onTap: (){
                  _mapController.move(currentPoint.position, 15);
                },
                child: Container(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        padding: EdgeInsets.all(10),
                        child: Icon(Icons.gps_fixed_outlined, color: Colors.white,),
                        decoration: BoxDecoration(
                            color: Colour("#246EE9"),
                            borderRadius: BorderRadius.all(Radius.circular(10))
                        ),
                      ),
                      Container(
                        margin: EdgeInsets.only(top: 10),
                        child: Text("Đi đến đây"),
                      )
                    ],
                  ),
                ),
              )
            ],
          ),
          decoration: BoxDecoration(
              color: Colors.white
          ),
        )
    ) : Container();
  }

  void initPhuong() {
    for(int i = 0; i < listLoggerPoints.length; i++) {
      if(!listDMA.containsKey(listLoggerPoints.elementAt(i).dma)) {
        listDMA[listLoggerPoints.elementAt(i).dma] = true;
      }
    }
  }

  void recenterMap() {
    _mapController.move(LatLng(10.828053, 106.779196), 11);
    clearFocusLogger();
  }

  List<Widget> VisibilityLogger() {
    List<Widget> resultWidget = new List<Widget>();

    listDMA.forEach((key, value) {
      resultWidget.add(
          new Row(
            children: [
              Checkbox(value: listDMA[key], onChanged: (isChecked){
                setState(() {
                  listDMA[key] = isChecked;
                  recenterMap();
                });
              }),
              GestureDetector(
                onTap: (){
                  setState(() {
                    listDMA[key] = !listDMA[key];
                    recenterMap();
                  });
                },
                child: Container(
                  padding: EdgeInsets.only(top: 10, bottom: 10),
                  child: Text(key.trim() == "" ? "Chưa có" : key),
                  decoration: BoxDecoration(
                      border: Border(
                          top: BorderSide(width: 1, color: Colour("#D1DBEE"))
                      )
                  ),
                ),
              )
            ],
          )
      );
    });

    return resultWidget;
  }

  List<Widget> ListLogger () {
    List<Widget> resultWidget = new List<Widget>();
    for(int i = 0; i < listLoggerPoints.length; i++) {
      resultWidget.add(
        new GestureDetector(
          onTap: (){
            _mapController.move(listLoggerPoints.elementAt(i).position, _mapController.zoom);
            setState(() {
              clearFocusLogger();
              listLoggerPoints.elementAt(i).isFocused = true;
              currentPoint = listLoggerPoints.elementAt(i);
              isInformation = true;
              isViewMenu = false;
            });
          },
          child: Container(
            padding: EdgeInsets.only(top: 10, bottom: 10),
            child: Text(listLoggerPoints.elementAt(i).tenLogger.trim() == "" ? "Chưa có" : listLoggerPoints.elementAt(i).tenLogger.trim()),
            decoration: BoxDecoration(
                border: Border(
                    top: BorderSide(width: 1, color: Colour("#D1DBEE"))
                )
            ),
          )
        )
      );
    }
    return resultWidget;
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return GestureDetector(
      onTap: (){
        clearFocus();
      },
      child: Scaffold(
        appBar: AppBar(
          // Here we take the value from the MyHomePage object that was created by
          // the App.build method, and use it to set our appbar title.
          backgroundColor: Colors.white,
          toolbarHeight: 0,
          elevation: 0,
        ),
        body: Container(
            width: double.infinity,
            height: double.infinity,
            child: Stack(
              children: [
                FlutterMap(
                  mapController: _mapController,
                  options: new MapOptions(
                    center: LatLng(10.828053, 106.779196),
                    zoom: 11,
                    onTap: (_, __){
                      clearFocus();
                    },

                  ),
                  layers: [
                    TileLayerOptions(
                      urlTemplate: 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
                      subdomains: ['a', 'b', 'c'],
                    ),
                    MarkerLayerOptions(markers: listMarkers)
                  ],
                ),
                Column(
                  children: [
                    Align(
                        alignment: Alignment.topCenter,
                        child: Container(
                          height: 80,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              IconButton(
                                  onPressed: (){
                                    Navigator.of(context).pop();
                                  },
                                  icon: Icon(Icons.arrow_back, color: Colour("#051639"),)
                              ),
                              Expanded(
                                  child: Container(
                                    margin: EdgeInsets.only(left: 15, right: 15),
                                    child: searchBar(),
                                  )
                              ),
                              IconButton(
                                  onPressed: (){
                                    if(!isInitPhuong) {
                                      initPhuong();
                                      isInitPhuong = true;
                                    }

                                    setState(() {
                                      if(viewMenu != 1) {
                                        viewMenu = 1;
                                        isViewMenu = true;
                                      }
                                      else {
                                        isViewMenu = !isViewMenu;
                                      }
                                      isSearch = false;
                                      FocusManager.instance.primaryFocus?.unfocus();
                                    });
                                  },
                                  icon: Icon(Icons.visibility, color: Colour("#051639"),)
                              ),
                              IconButton(
                                  onPressed: (){
                                    setState(() {
                                      if(viewMenu != 0) {
                                        viewMenu = 0;
                                        isViewMenu = true;
                                      }
                                      else {
                                        isViewMenu = !isViewMenu;
                                      }
                                      isSearch = false;
                                      FocusManager.instance.primaryFocus?.unfocus();
                                    });
                                  },
                                  icon: Icon(Icons.list, color: Colour("#051639"),)
                              )
                            ],
                          ),
                          decoration: BoxDecoration(
                              color: Colors.white
                          ),
                        )
                    ),
                    Expanded(child: Stack(
                      children: [
                        isInformation ? InformationPanel(currentPoint) : Container(),
                        isSearch ? SearchPanel(currentSearchText) :
                        (isViewMenu ? DetailPanel(viewMenu == 0 ? ListLogger() : VisibilityLogger()) : Container()),
                      ],
                    ))
                  ],
                ),

              ],
            )
        ),
      )
    );
  }

}