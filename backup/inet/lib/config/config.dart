import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:inet/models/alarm_type.dart';
import 'package:inet/models/channel_measure.dart';
import 'package:inet/models/dashboard_model.dart';
import 'package:inet/models/logger_address.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:inet/models/logger_point.dart';
import 'package:latlong2/latlong.dart';
import '../models/alarm_logger.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import '../models/logger_data.dart';
import 'package:flutter_map_arcgis/layers/feature_layer_options.dart' as arcgis;


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

String currentServer = "103.163.214.64:8081";
String currentServerName = "Server mặc định";

List<String> ioConnector = new List<String>();
List<String> ioAuthenicator = new List<String>();

List<IO.Socket> listSocket = new List<IO.Socket>();

List<LoggerData> listData = new List<LoggerData>();
List<LoggerData> storedData = new List<LoggerData>();

List<DashboardModel> listDashboardModel = new List<DashboardModel>();

String currentDashboard = "";

Map<int, bool> isReceivedChartDashboard = new Map<int, bool>();

Map<int, bool> isReceivedChartQuery = new Map<int, bool>();
Map<int, String> mapNameChartQuery = new Map<int, String>();

Map<String, bool> mapReceiveGis = new Map<String, bool>();

LatLng mapCenter = LatLng(0, 0);

List<arcgis.FeatureLayerOptions> listLayerArcgis = new List <arcgis.FeatureLayerOptions>();