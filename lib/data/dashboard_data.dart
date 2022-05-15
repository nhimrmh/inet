import 'package:fl_animated_linechart/chart/line_chart.dart';
import 'package:inet/models/chart_dashboard.dart';

import '../models/dashboard_content.dart';

bool preloadedGotDashboardData = false;
bool isReceivedDashboardChart = false;
List<DashboardContent> preloadedListDashboardContent = new List<DashboardContent>();

bool isSendingQuery = false;