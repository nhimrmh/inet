import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:inet/models/alarm_type.dart';
import 'package:inet/models/channel_measure.dart';
import 'package:inet/models/chart_data_id.dart';
import 'package:inet/models/dashboard_model.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:inet/models/logger_point.dart';
import 'package:inet/views/login_view.dart';
import 'package:inet/views/map_view.dart';
import 'package:latlong2/latlong.dart';
import '../models/alarm_logger.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import '../models/chart_data.dart';
import '../models/logger_data.dart';
import 'package:flutter_map_arcgis/layers/feature_layer_options.dart' as arcgis;

import '../views/dashboard_view.dart';
import '../views/home_view.dart';


FirebaseMessaging messaging;

String viewData = "";

String username_config = "";

List<ChannelMeasure> listChannelMeasure = new List<ChannelMeasure>();

List<String> listChannelSelect = new List<String>();

List<LoggerPoint> listAddresses = new List<LoggerPoint>();

bool isConnectToSocket = false;

bool isOffline = false;

bool isGisAvailable = true;

MapController globalMapController;

String linkFeatureLayer = "";

Map<String, String> mapLayer = new Map<String, String>();
Map<String, bool> mapLayerVisible = new Map<String, bool>();

bool flagChartClicked = false;

List<AlarmType> listAlarmType = new List<AlarmType>();

List<AlarmLogger> listAlarmLogger = new List<AlarmLogger>();

String currentServer = "";
String currentServerName = "";

List<String> ioConnector = new List<String>();
List<String> ioAuthenicator = new List<String>();

List<IO.Socket> listSocket = new List<IO.Socket>();

List<LoggerData> listData = new List<LoggerData>();
List<LoggerData> storedData = new List<LoggerData>();

List<DashboardModel> listDashboardModel = new List<DashboardModel>();

String currentDashboard = "";

Map<String, bool> isReceivedChartDashboard = new Map<String, bool>();

Map<int, bool> isReceivedChartQuery = new Map<int, bool>();
Map<int, String> mapNameChartQuery = new Map<int, String>();
Map<String, bool> mapReceiveGis = new Map<String, bool>();
Map<String, bool> mapIsChartChannel = <String, bool>{};

LatLng mapCenter = LatLng(0, 0);

List<arcgis.FeatureLayerOptions> listLayerArcgis = new List <arcgis.FeatureLayerOptions>();

GlobalKey<LoginState> loginKey = GlobalKey();
GlobalKey<DashboardViewState> dashboardKey = GlobalKey();
GlobalKey<GisMapViewState> mapKey = GlobalKey();
GlobalKey<MyHomePageState> homeKey = GlobalKey();

List<String> listColors = ["#775ecc", "#2191f6", "#fa4063", "#32e499", "#fbaf37"];

Map<int, List<ChartDataID>> mapAllChartData = <int, List<ChartDataID>>{};