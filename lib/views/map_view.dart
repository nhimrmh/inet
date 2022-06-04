import 'dart:convert';

import 'package:colour/colour.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:ionicons/ionicons.dart';
import 'package:latlong2/latlong.dart';
import 'package:page_transition/page_transition.dart';

import '../classes/get_date.dart';
import '../config/config.dart';
import '../main.dart';
import '../main/logger_detail.dart';
import '../models/alarm_type.dart';
import '../models/channel_measure.dart';
import '../models/logger_data.dart';
import '../models/logger_point.dart';
import 'package:flutter_map_arcgis/esri_plugin.dart';
import 'package:flutter_map_arcgis/layers/feature_layer_options.dart' as arcgis;
import 'package:flutter_map_marker_cluster/flutter_map_marker_cluster.dart';

import '../widgets/alert.dart';
import 'logger_information.dart';

class GisMapView extends StatefulWidget {
  const GisMapView({Key key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return GisMapViewState();
  }
}

class GisMapViewState extends State<GisMapView> {
  ///Map variables
  List<LayerOptions> listLayers = List<LayerOptions>();
  List<LoggerPoint> listLoggerPoints = List<LoggerPoint>();
  int viewMenu = 0;
  bool isViewMenu = false;
  bool isSearch = false;
  bool isInformation = false;
  TextEditingController searchMapController = TextEditingController();
  Map<String, bool> listAlarm = Map<String, bool>();
  bool isTatCa = true;
  bool isInitAlarm = false;
  List<Marker> listMarkers = List<Marker>();
  String currentSearchText = "";
  LoggerPoint currentPoint = LoggerPoint();
  bool isInitMap = false;
  bool isLoadingMap = true;
  List<Marker> markers;

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return isInitMap && !isLoadingMap ? Stack(
      children: [
        Container(
          margin: const EdgeInsets.only(top: 80),
          child: FlutterMap(
            mapController: globalMapController,
            options: MapOptions(
              center: mapCenter != LatLng(0,0) ? mapCenter : LatLng(10.428053, 106.829196),
              zoom: 10,
              plugins: [
                MarkerClusterPlugin(),
                EsriPlugin()
              ],
              onTap: (_, __){
                clearFocus();
              },
            ),
            layers: listLayers,
          ),
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
                      Expanded(
                          child: Container(
                            margin: const EdgeInsets.only(left: 15, right: 0),
                            child: searchBar(),
                          )
                      ),
                      GestureDetector(
                        onTap: (){
                          setState(() {
                            if(viewMenu != 2) {
                              viewMenu = 2;
                              isViewMenu = true;
                            }
                            else {
                              isViewMenu = !isViewMenu;
                            }
                            isSearch = false;
                            FocusManager.instance.primaryFocus?.unfocus();
                          });
                        },
                        child: Container(
                            margin: const EdgeInsets.only(left: 15, right: 0),
                            child: Icon(Icons.visibility, color: Colour("#051639"))
                        ),
                      ),
                      GestureDetector(
                        onTap: (){
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
                        child: Container(
                          margin: const EdgeInsets.only(left: 15, right: 15),
                          child: Icon(Icons.list, color: Colour("#051639")),
                        ),
                      )
                    ],
                  ),
                  decoration: const BoxDecoration(
                      color: Colors.white
                  ),
                )
            ),
            Expanded(child: Stack(
              children: [
                isInformation ? InformationPanel(currentPoint) : Container(),
                isSearch ? SearchPanel(currentSearchText) :
                (isViewMenu ? (viewMenu != 1 ? DetailPanel(viewMenu == 0 ? ListLogger() : ListLayer()) : FilterPanel(VisibilityLogger())) : Container()),
                !isInformation ? RecenterWidget() : Container()
              ],
            ))
          ],
        ),
      ],
    ) : const Center(
      child: SizedBox(
        width: 50,
        height: 50,
        child: CircularProgressIndicator(),
      ),
    );
  }

  void initMap() {
      listLayers.add(TileLayerOptions(
        urlTemplate: 'https://server.arcgisonline.com/ArcGIS/rest/services/World_Topo_Map/MapServer/tile/{z}/{y}/{x}',
        subdomains: ['a', 'b', 'c'],
      ));
      mapLayer.forEach((key, value) {
        listLayers.add(mapLayerVisible[key] ? arcgis.FeatureLayerOptions(
          value,
          "polygon",
          onTap: (dynamic attributes, LatLng location) {},
          render: (dynamic attributes){
            // You can render by attribute
            if(key == "TenQuan") {
              return const PolygonOptions(
                borderColor: Colors.cyan,
                color: Colors.transparent,
                borderStrokeWidth: 2,
              );
            }
            else if(key == "TENDMA") {
              return const PolygonOptions(
                borderColor: Colors.red,
                color: Colors.greenAccent,
                borderStrokeWidth: 1,
              );
            }
            else {
              return const PolygonOptions(
                borderColor: Colors.red,
                color: Colors.transparent,
                borderStrokeWidth: 2,
              );
            }
          },
        ) : Container());
      });
      listLayers.add(MarkerClusterLayerOptions(
        spiderfyCircleRadius: 20,
        spiderfySpiralDistanceMultiplier: 2,
        circleSpiralSwitchover: 12,
        maxClusterRadius: 50,
        rotate: true,
        size: const Size(40, 40),
        anchor: AnchorPos.align(AnchorAlign.center),
        fitBoundsOptions: const FitBoundsOptions(
          padding: EdgeInsets.all(50),
        ),
        markers: isTatCa ? listMarkers : listMarkers.where((element) => element.width != 0 && element.height != 0).toList(),
        polygonOptions: const PolygonOptions(
            borderColor: Colors.blueAccent,
            color: Colors.black12,
            borderStrokeWidth: 3),
        popupOptions: PopupOptions(
          popupSnap: PopupSnap.markerTop,
          // popupController: _popupController,
          popupBuilder: (_, marker) => Container(),
        ),
        builder: (context, markers) {
          return Container(
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20.0),
                color: Colors.blue),
            child: Center(
              child: Text(
                markers.length.toString(),
                style: const TextStyle(color: Colors.white),
              ),
            ),
          );
        },
      ));

      getFeatures();
  }

  void setIsInitMap(bool value) {
    setState(() {
      isInitMap = value;
    });
  }

  bool getIsInitMap() {
    return isInitMap;
  }

  void setIsLoadingMap(bool value) {
    setState(() {
      isLoadingMap = value;
    });
  }

  bool getIsLoadingMap() {
    return isLoadingMap;
  }

  bool getIsSearch() {
    return isSearch;
  }

  void setIsSearch(bool value) {
    setState(() {
      isSearch = value;
    });
  }

  bool getIsViewMenu() {
    return isViewMenu;
  }

  void setIsViewMenu(bool value) {
    setState(() {
      isViewMenu = value;
    });
  }

  int getViewMenu() {
    return viewMenu;
  }

  void setViewMenu(int value) {
    setState(() {
      viewMenu = value;
    });
  }

  bool getIsInitAlarm() {
    return isInitAlarm;
  }

  void setIsInitAlarm(bool value) {
    setState(() {
      isInitAlarm = value;
    });
  }

  void initAlarm() {
    for(int i = 0; i < listAlarmType.length; i++) {
      if(!listAlarm.containsKey(listAlarmType.elementAt(i).name)) {
        listAlarm[listAlarmType.elementAt(i).name] = true;
      }
    }
  }

  void inverseAlarm(bool isChecked) {
    if(viewMenu == 1) {
      listAlarm.forEach((key, value) {
        listAlarm[key] = isChecked;
      });
    }
  }

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
      LoggerPoint temp = LoggerPoint();
      try {
        temp = listLoggerPoints.where((element) => element.isFocused == true).first;
      }
      catch(e) {
        temp = null;
      }

      if(temp != null) {
        temp.isFocused = false;
      }
    });
  }

  void getFeatures() {
    setState(() {
      listMarkers.clear();
    });
    ///getting features for map
    if(linkFeatureLayer != "") {
      socketService.getFeature().then((value){
        ///received features
        setFeaturesChanged(value);
      });
    }
    else {
      setFeaturesOffline();
    }
  }

  void setFeaturesChanged(String result) {
    if(mounted) {
      try {
        if(result != null && result.trim() != "" && result != "timeout") {

          listLoggerPoints = List<LoggerPoint>();

          Map<String, dynamic> jsonResult = Map<String, dynamic>.from(json.decode(result));

          jsonResult.forEach((key, value) {
            if(key == "features") {
              List<dynamic> listFeatures = value;
              listFeatures.forEach((element) {
                Map<String, dynamic> featureInfo = Map<String, dynamic>.from(element);

                LoggerPoint temp = LoggerPoint();
                double temp_x = 0;
                double temp_y = 0;

                featureInfo.forEach((key, value) {
                  if(key == "attributes") {
                    Map<String, dynamic> mapTenLogger = value;
                    mapTenLogger.forEach((key, value) {
                      if(key == "TenLogger") {
                        temp.tenLogger = value ?? "";
                      }
                      else if(key == "MaLogger") {
                        temp.maLogger = value.toString() ?? "";
                      }
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

                LoggerData tempLogger;

                try {
                  tempLogger = storedData.where((element) => element.objName == temp.maLogger).first;
                }
                catch(e) {
                  tempLogger = null;
                }

                if(tempLogger != null) {
                  for (var element in tempLogger.listElements) {
                    Map<int,double> mapElement = storedData.where((element) => element.objName == temp.maLogger).first.listElements.where((fieldElement) => fieldElement.fieldName == element.fieldName).first.value;
                    int maxKey = 0;
                    mapElement.forEach((key, value) {
                      if(key > maxKey) {
                        maxKey = key;
                      }
                    });
                    Map<int,String> mapAlarm;
                    try {
                      mapAlarm = storedData.where((element) => element.objName == temp.maLogger).first.listElements.where((fieldElement) => fieldElement.fieldName == element.fieldName).first.alarm;
                    }
                    catch(e) {
                      mapAlarm = null;
                    }

                    AlarmType tempAlarmType = AlarmType();
                    try {
                      tempAlarmType = listAlarmType.where((element) => element.id == mapAlarm[maxKey]).first;
                    }
                    catch(e) {
                      tempAlarmType = null;
                    }
                    if(tempAlarmType != null) {
                      temp.listAlarm.add(tempAlarmType);
                    }
                  }

                  if(temp.listAlarm != null && temp.listAlarm.length > 1) {
                    temp.listAlarm.sort((b,a) => a.id.compareTo(b.id));
                  }

                  Marker tempMarker = Marker(
                      anchorPos: AnchorPos.align(AnchorAlign.center),
                      width: isTatCa || (temp.listAlarm != null && temp.listAlarm.isNotEmpty && listAlarm.containsKey(temp.listAlarm.first.name) && listAlarm[temp.listAlarm.first.name] == true && temp.isFocused != true) ? 30 : 0,
                      height: isTatCa || (temp.listAlarm != null && temp.listAlarm.isNotEmpty && listAlarm.containsKey(temp.listAlarm.first.name) && listAlarm[temp.listAlarm.first.name] == true && temp.isFocused != true) ? 30 : 0,
                      point: LatLng(temp_y, temp_x),
                      builder: (ctx) =>
                      (!isTatCa && listAlarm.containsKey(temp.listAlarm.first.name) && listAlarm[temp.listAlarm.first.name] != true && temp.isFocused != true) ? Container() :
                      GestureDetector(
                        onTap: (){
                          globalMapController.move(temp.position, globalMapController.zoom);
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
                              child: temp.isFocused ? const Icon(Ionicons.location,
                                color: Colors.black, size: 30,) : Container(),
                            )),
                            Positioned.fill(child: Align(
                              alignment: Alignment.center,
                              child: temp.isFocused ? const Icon(Ionicons.location,
                                color: Colors.greenAccent, size: 28,) : Container(),
                            )),
                            Positioned.fill(child: Align(
                              alignment: Alignment.center,
                              child: Icon(Ionicons.location, size: 20,
                                  color: temp.listAlarm != null && temp.listAlarm.isNotEmpty ? Colour(temp.listAlarm.elementAt(0).color) : Colors.blue),
                            )),
                            const Positioned.fill(child: Align(
                              alignment: Alignment.center,
                              child: Icon(Ionicons.location_outline, size: 24,
                                color: Colors.black,),
                            )),

                          ],
                        ),
                      )
                  );
                  listMarkers.add(tempMarker);
                }

                temp.isFocused = false;

                listLoggerPoints.add(temp);

                if(mapReceiveGis.containsKey(temp.maLogger)) {
                  mapReceiveGis[temp.maLogger] = true;
                }
              });
            }
          });

          listLoggerPoints.sort((a,b) => a.tenLogger.compareTo(b.tenLogger));

          setFeaturesOffline();

          setState(() {
            isInitMap = true;
            isLoadingMap = false;
          });
        }
        else {
          setFeaturesOffline();
        }
      }
      catch(e) {
        setFeaturesOffline();
      }
    }
  }

  void setFeaturesOffline() {
    if(mounted) {

      List<LoggerPoint> tempList = List<LoggerPoint>();
      mapReceiveGis.forEach((key, value) {
        if(value == false) {
          LoggerPoint temp = LoggerPoint();
          try{
            temp = listLoggerPoints.where((element) => element.maLogger == key).first;
          }
          catch(e) {
            temp = null;
          }

          if(temp != null && !tempList.contains(temp)) {
            tempList.add(temp);
          }
        }
      });

      setState(() {
        // tempList.clear();
        for (var element in listAddresses) {
          if(!tempList.contains(element)) {
            tempList.add(element);
            if(listLoggerPoints != null && !listLoggerPoints.contains(element)) {
              element.isFocused = false;
              listLoggerPoints.add(element);
            }
          }
        }

      });
      for (var temp in tempList) {
        temp.isFocused = false;
        LoggerData tempLogger;

        try {
          tempLogger = storedData.where((element) => element.objName == temp.maLogger).first;
        }
        catch(e) {
          tempLogger = null;
        }

        if(tempLogger != null) {
          temp.listAlarm = List<AlarmType>();
          for (var element in tempLogger.listElements) {
            Map<int,double> mapElement = storedData.where((element) => element.objName == temp.maLogger).first.listElements.where((fieldElement) => fieldElement.fieldName == element.fieldName).first.value;
            int maxKey = 0;
            mapElement.forEach((key, value) {
              if(key > maxKey) {
                maxKey = key;
              }
            });
            Map<int,String> mapAlarm;
            try {
              mapAlarm = storedData.where((element) => element.objName == temp.maLogger).first.listElements.where((fieldElement) => fieldElement.fieldName == element.fieldName).first.alarm;
            }
            catch(e) {
              mapAlarm = null;
            }

            AlarmType tempAlarmType = AlarmType();
            try {
              tempAlarmType = listAlarmType.where((element) => element.id == mapAlarm[maxKey]).first;
            }
            catch(e) {
              tempAlarmType = null;
            }
            if(tempAlarmType != null) {
              temp.listAlarm.add(tempAlarmType);
            }
          }

          if(temp.listAlarm != null && temp.listAlarm.length > 1) {
            temp.listAlarm.sort((b,a) => a.id.compareTo(b.id));
          }

          Marker tempMarker = Marker(
              anchorPos: AnchorPos.align(AnchorAlign.center),
              width: isTatCa || (temp.listAlarm != null && temp.listAlarm.isNotEmpty && listAlarm.containsKey(temp.listAlarm.first.name) && listAlarm[temp.listAlarm.first.name] == true && temp.isFocused != true) ? 30 : 0,
              height: isTatCa || (temp.listAlarm != null && temp.listAlarm.isNotEmpty && listAlarm.containsKey(temp.listAlarm.first.name) && listAlarm[temp.listAlarm.first.name] == true && temp.isFocused != true) ? 30 : 0,
              point: LatLng(temp.position.latitude, temp.position.longitude),
              builder: (ctx) =>
              (!isTatCa && temp.listAlarm != null && temp.listAlarm.isNotEmpty && listAlarm.containsKey(temp.listAlarm.first.name) && listAlarm[temp.listAlarm.first.name] != true && temp.isFocused != true) ? Container() :
              GestureDetector(
                onTap: (){
                  globalMapController.move(temp.position, globalMapController.zoom);
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
                      child: temp.isFocused ? const Icon(Ionicons.location,
                        color: Colors.black, size: 30,) : Container(),
                    )),
                    Positioned.fill(child: Align(
                      alignment: Alignment.center,
                      child: temp.isFocused ? const Icon(Ionicons.location,
                        color: Colors.greenAccent, size: 28,) : Container(),
                    )),
                    Positioned.fill(child: Align(
                      alignment: Alignment.center,
                      child: Icon(Ionicons.location, size: 20,
                          color: temp.listAlarm != null && temp.listAlarm.isNotEmpty ? Colour(temp.listAlarm.elementAt(0).color) : Colors.blue),
                    )),
                    const Positioned.fill(child: Align(
                      alignment: Alignment.center,
                      child: Icon(Ionicons.location_outline, size: 24,
                        color: Colors.black,),
                    )),

                  ],
                ),
              )
          );
          listMarkers.add(tempMarker);
        }


      }

      tempList.sort((a,b) => a.tenLogger.compareTo(b.tenLogger));
      setState(() {
        isInitMap = true;
        isLoadingMap = false;
      });
    }
  }

  Widget searchBar() {
    return TextFormField(
      controller: searchMapController,
      autovalidateMode: AutovalidateMode.disabled,
      onChanged: (text){
        setState(() {
          currentSearchText = text;
        });
      },
      onTap: () {
        // clearFocus();
        setState(() {
          isSearch = true;
          isViewMenu = false;
          isInformation = false;
        });
        clearFocusLogger();
      },
      decoration: InputDecoration(
        filled: true,
        fillColor: Colour('#F8FAFF'),
        contentPadding: const EdgeInsets.only(top: 6, bottom: 6, left: 15, right: 15),
        suffixIcon: IconButton(
          onPressed: (){
            if(isSearch) {
              setState(() {
                isSearch = false;
                searchMapController.text = "";
              });
              FocusManager.instance.primaryFocus?.unfocus();
            }
          },
          icon: Icon(isSearch ? Icons.close : Icons.search, color: Colour('#666D75'), size: 30,),
        ),
        hintText: "Nhập tên logger cần tìm", hintStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w400),
        enabledBorder: OutlineInputBorder(
            borderRadius: const BorderRadius.all(const Radius.circular(20)),
            borderSide: BorderSide(
                color: Colour('#D1DBEE'),
                width: 1
            )
        ),
        border: OutlineInputBorder(
            borderRadius: const BorderRadius.all(const Radius.circular(20)),
            borderSide: BorderSide(
                color: Colour('#D1DBEE'),
                width: 1
            )
        ),

      ),
    );
  }

  List<Widget> ListSearch(String searchText) {
    List<Widget> resultWidgets = List<Widget>();
    if(searchText.trim() != "") {

      for(int i = 0; i < listLoggerPoints.length; i++) {
        LoggerData a;
        try {
          a = storedData.where((storedElement) => storedElement.objName == listLoggerPoints.elementAt(i).maLogger).first;
        }
        catch(e) {
          a = null;
        }

        if(listLoggerPoints.elementAt(i).tenLogger.trim().toUpperCase().contains(searchText.trim().toUpperCase()) && a != null) {
          resultWidgets.add(
              GestureDetector(
                  onTap: (){
                    clearFocus();

                    globalMapController.move(listLoggerPoints.elementAt(i).position, globalMapController.zoom);
                    setState(() {
                      currentPoint = listLoggerPoints.elementAt(i);
                      listLoggerPoints.elementAt(i).isFocused = true;
                      isInformation = true;
                    });
                  },
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.only(top: 10, bottom: 10, left: 15 , right: 15),
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

  Widget FilterPanel(List<Widget> listItem) {
    listItem.insert( 0,
        Row(
          children: [
            Checkbox(
                value: isTatCa,
                onChanged: (isChecked){
                  clearFocusLogger();
                  recenterMap();
                  setState(() {
                    isTatCa = isChecked;
                    inverseAlarm(isChecked);
                  });
                  getFeatures();
                }),
            GestureDetector(
              onTap: () {
                clearFocusLogger();
                recenterMap();
                setState(() {
                  isTatCa = !isTatCa;
                });
                inverseAlarm(isTatCa);
                getFeatures();
              },
              child: Container(
                padding: const EdgeInsets.only(top: 10, bottom: 10),
                child: const Text("Tất cả"),
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

    return Align(
      alignment: Alignment.bottomCenter,
      child: Container(
        padding: const EdgeInsets.only(left: 5, right: 5),
        height: (70 * ((listItem.length / 3).ceil())).toDouble(),
        width: double.infinity,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              margin: const EdgeInsets.only(top: 10, bottom: 10),
              child: Text("Lọc cảnh báo", style: Theme.of(context).textTheme.headline1,),
            ),
            GridView.count(
              physics: const NeverScrollableScrollPhysics(), // to disable GridView's scrolling
              shrinkWrap: true,
              childAspectRatio: 3,
              crossAxisCount: 3,
              mainAxisSpacing: 0.0,
              children: listItem,
            ),
          ],
        ),
        decoration: const BoxDecoration(
            color: Colors.white
        ),
      ),
    );
  }

  Widget DetailPanel(List<Widget> listItem) {
    return Align(
      alignment: Alignment.topRight,
      child: Container(
        padding: viewMenu != 1 ? const EdgeInsets.only(left: 15, right: 15) : const EdgeInsets.only(left: 5, right: 5),
        height: double.infinity,
        width: viewMenu != 1 ? MediaQuery.of(context).size.width/2 : 150,
        child: Column(
          mainAxisSize: MainAxisSize.max,
          children: [
            Container(
              margin: const EdgeInsets.only(top: 10, bottom: 10),
              child: Text(viewMenu == 0 ? "Danh sách Logger" : (viewMenu == 2 ?  "Layer" : "Lọc cảnh báo"), style: Theme.of(context).textTheme.headline1,),
            ),
            viewMenu == 1 ? Row(
              children: [
                Checkbox(
                    value: isTatCa,
                    onChanged: (isChecked){
                      clearFocusLogger();
                      recenterMap();
                      setState(() {
                        isTatCa = isChecked;
                        inverseAlarm(isChecked);
                      });
                      getFeatures();
                    }),
                GestureDetector(
                  onTap: () {
                    clearFocusLogger();
                    recenterMap();
                    setState(() {
                      isTatCa = !isTatCa;
                    });
                    inverseAlarm(isTatCa);
                    getFeatures();
                  },
                  child: Container(
                    padding: const EdgeInsets.only(top: 10, bottom: 10),
                    child: const Text("Tất cả"),
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
        decoration: const BoxDecoration(
            color: Colors.white
        ),
      ),
    );
  }

  Widget RecenterWidget(){
    return Align(
      alignment: Alignment.bottomRight,
      child: Container(
        padding: const EdgeInsets.all(5),
        margin: const EdgeInsets.all(15),
        child: IconButton(
          onPressed: () => recenterMap(),
          icon: const Icon(Icons.zoom_out_map, size: 35,),
        ),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.all(Radius.circular(10)),
          boxShadow: [
            BoxShadow(
              color: Colors.black26,
              spreadRadius: 0,
              blurRadius: 2,
              offset: Offset(2, 2)
            )
          ]
        ),
      )
    );
  }

  Widget InformationPanel(LoggerPoint item) {
    LoggerData a;
    try {
      a = storedData.where((storedElement) => storedElement.objName == item.maLogger).first;
    }
    catch(e) {
      a = null;
    }

    int currentTime = 0;
    Map<ChannelMeasure, double> mapChannelValues = <ChannelMeasure, double>{};
    if(a != null) {
      for (var element in a.listElements) {
        int maxKey = 0;
        element.value.forEach((key, value) {
          if(key > currentTime) {
            currentTime = key;
            maxKey = key;
          }

        });
        ChannelMeasure currentMeasure = ChannelMeasure();
        try {
          currentMeasure = listChannelMeasure.where((measure) => measure.channelID == element.fieldName).first;
        }
        catch(e) {
          currentMeasure = null;
        }
        if(currentMeasure != null) {
          mapChannelValues[currentMeasure] = element.value[maxKey];
        }
        else {
          mapChannelValues[null] = element.value[maxKey];
        }

      }
    }

    return currentPoint.tenLogger.trim() != "" ? Align(
        alignment: Alignment.bottomCenter,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            RecenterWidget(),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.only(left: 25, right: 15, top: 15, bottom: 15),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.only(left: 15, right: 15, top: 5, bottom: 5,),
                    decoration: BoxDecoration(
                        color: Colour("#243347"),
                        borderRadius: const BorderRadius.all(Radius.circular(5))
                    ),
                    margin: const EdgeInsets.only(bottom: 5),
                    child: Text("${item.tenLogger} (${item.maLogger})", style: Theme.of(context).textTheme.headline2.merge(const TextStyle(fontSize: 16, color: Colors.white)),),
                  ),
                  Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    child: Text(currentTime != 0 ? getDateString1(currentTime) : ""),
                  ),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Container(
                            //   margin: const EdgeInsets.only(bottom: 10),
                            //   child: Text("Địa chỉ: ${item.diaChi}, ${item.dma}",
                            //     style: Theme.of(context).textTheme.subtitle1.merge(const TextStyle(fontWeight: FontWeight.w400)),),
                            // ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: _buildChannelValues(mapChannelValues),
                            )
                          ],
                        ),
                      ),
                      Container(
                          margin: const EdgeInsets.only(left: 25),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              GestureDetector(
                                onTap: (){
                                  globalMapController.move(currentPoint.position, 15);
                                },
                                child: Container(
                                  padding: const EdgeInsets.all(10),
                                  child: const Icon(Icons.search, color: Colors.white,),
                                  decoration: BoxDecoration(
                                      color: Colour('#246EE9'),
                                      borderRadius: const BorderRadius.all(Radius.circular(10)),
                                      boxShadow: const [
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
                              GestureDetector(
                                onTap: (){
                                  LoggerData temp;
                                  try {
                                    temp = storedData.where((storedElement) => storedElement.objName == item.maLogger).first;
                                  }
                                  catch(e) {
                                    temp = null;
                                  }
                                  if(temp != null) {
                                    Navigator.push(
                                      context,
                                      PageTransition(
                                        type: PageTransitionType.rightToLeft,
                                        child: LoggerInformation(storedData.where((storedElement) => storedElement.objName == item.maLogger).first),
                                      ),
                                    );
                                  }
                                  else {
                                    showAlertDialog(context, "Không thể xem dữ liệu logger", "Dữ liệu của logger này chưa được cập nhật về hệ thống, vui lòng thử lại sau");
                                  }
                                },
                                child: Container(
                                  margin: const EdgeInsets.only(top: 15),
                                  padding: const EdgeInsets.all(10),
                                  child: const Icon(Icons.bar_chart, color: Colors.white,),
                                  decoration: BoxDecoration(
                                      color: Colour('#246EE9'),
                                      borderRadius: const BorderRadius.all(Radius.circular(10)),
                                      boxShadow: const [
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
                      )
                    ],
                  ),
                ],
              ),
              decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(topLeft: Radius.circular(15), topRight: Radius.circular(15)),
                  boxShadow: [
                    BoxShadow(
                        color: Colors.black26,
                        spreadRadius: 0,
                        blurRadius: 2,
                        offset: Offset(-2, -2)
                    )
                  ]
              ),
            )
          ],
        )
    ) : Container();
  }

  void recenterMap() {
    globalMapController.move((mapCenter != LatLng(0,0) ? mapCenter : LatLng(10.428053, 106.829196)), 10);
    clearFocusLogger();
  }

  List<Widget> _buildChannelValues(Map<ChannelMeasure, double> mapChannelValues){
    List<Widget> resultWidgets = [];
    mapChannelValues.forEach((key, value) {
      if(listChannelSelect.contains(key.channelID)) {
        resultWidgets.add(
            Expanded(
              child: Container(
                margin: const EdgeInsets.only(left: 10, right: 10),
                padding: const EdgeInsets.only(left: 10, right: 10, top: 20, bottom: 20),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Container(
                      margin: const EdgeInsets.only(bottom: 5),
                      child: Text(key.channelName),
                    ),
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text("${value != null ? value.toStringAsFixed(1) : "0"} (${key?.unit ?? ""})", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.blue[700]),),
                    )
                  ],
                ),
                decoration: BoxDecoration(
                    borderRadius: const BorderRadius.all(Radius.circular(5)),
                    border: Border.all(color: Colors.black26, width: 1)
                ),
              ),
            )
        );
      }
    });

    return resultWidgets;
  }

  List<Widget> VisibilityLogger() {
    List<Widget> resultWidget = List<Widget>();

    listAlarm.forEach((key, value) {
      resultWidget.add(
          Row(
            children: [
              Checkbox(value: listAlarm[key], onChanged: (isChecked){
                setState(() {
                  listAlarm[key] = isChecked;
                  recenterMap();
                });
                getFeatures();
              }),
              GestureDetector(
                onTap: (){
                  setState(() {
                    listAlarm[key] = !listAlarm[key];
                    recenterMap();
                  });
                  getFeatures();
                },
                child: Container(
                  padding: const EdgeInsets.only(top: 10, bottom: 10),
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

  List<Widget> ListLayer() {
    List<Widget> resultWidget = List<Widget>();
    mapLayerVisible.forEach((key, value) {
      resultWidget.add(
          Row(
            children: [
              Checkbox(
                  value: value,
                  onChanged: (isChecked){

                  }
              ),
              Text(key)
            ],
          )
      );
    });
    return resultWidget;
  }

  List<Widget> ListLogger () {
    List<Widget> resultWidget = List<Widget>();
    for(int i = 0; i < listLoggerPoints.length; i++) {

      LoggerData a;
      try {
        a = storedData.where((storedElement) => storedElement.objName == listLoggerPoints.elementAt(i).maLogger).first;
      }
      catch(e) {
        a = null;
      }

      if(a != null) {
        resultWidget.add(
            GestureDetector(
                onTap: (){
                  globalMapController.move(listLoggerPoints.elementAt(i).position, 15);
                  setState(() {
                    clearFocusLogger();
                    listLoggerPoints.elementAt(i).isFocused = true;
                    currentPoint = listLoggerPoints.elementAt(i);
                    isInformation = true;
                    isViewMenu = false;
                  });
                },
                child: Container(
                  padding: const EdgeInsets.only(top: 10, bottom: 10),
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
    }
    return resultWidget;
  }
}