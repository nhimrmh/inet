import 'dart:async';
import 'dart:convert';
import 'dart:ui';

import 'package:colour/colour.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:fl_animated_linechart/chart/animated_line_chart.dart';
import 'package:fl_animated_linechart/chart/line_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_arcgis/esri_plugin.dart';
import 'package:flutter_map_arcgis/layers/feature_layer_options.dart' as arcgis;
import 'package:flutter_map_marker_cluster/flutter_map_marker_cluster.dart';
import 'package:flutter_simple_dependency_injection/injector.dart';
import 'package:inet/models/dashboard_model.dart';
import 'package:inet/widgets/button.dart';
import 'package:inet/widgets/dropdown.dart';
import 'package:inet/widgets/edittext.dart';
import 'package:ionicons/ionicons.dart';
import 'package:latlong2/latlong.dart';
import 'package:overlay_support/overlay_support.dart';

import 'package:page_transition/page_transition.dart';
import 'package:inet/config/config.dart';
import 'package:inet/config/gis_offline.dart';
import 'package:inet/main/layout_gis.dart';

import 'package:inet/main/logger_detail.dart';
import 'package:inet/main/test_layout.dart';
import 'package:inet/models/alarm_type.dart';
import 'package:inet/models/channel_measure.dart';
import 'package:inet/models/chart_dashboard.dart';
import 'package:inet/models/chart_dashboard_value.dart';
import 'package:inet/models/field_logger_data.dart';
import 'package:inet/models/logger_data.dart';
import 'package:inet/models/news_model.dart';
import 'package:inet/models/dashboard_content.dart';
import 'package:inet/widgets/alert.dart';
import 'package:inet/widgets/chart.dart';
import 'package:inet/widgets/loading.dart';
import 'package:inet/widgets/chart.dart';
import 'classes/auth.dart';
import 'classes/dependency_injection.dart';
import 'classes/get_date.dart';
import 'classes/socket_service.dart';
import 'config/firebase.dart';
import 'data/dashboard_data.dart';
import 'main/layout_chart.dart';
import 'models/alarm_logger.dart';
import 'models/chart_data.dart';
import 'models/logger_point.dart';
import 'models/menu_model.dart';
import 'package:inet/models/logger_address.dart';

Injector injector;
final SocketService socketService = injector.get<SocketService>();

class AppInitializer {
  initialise(Injector injector) async {}
}

void main() async {
  DependencyInjection().initialise(Injector.getInjector());
  injector = Injector.getInjector();
  await AppInitializer().initialise(injector);
  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    home: IntroductionPage(),
  ));
  //connectAndListen1();
}

List<Widget> createListFunction(String result) {
  List<Widget> resultList = [];
  resultList.add(
      Container(
        child: Text(result),
      )
  );
}

class IntroductionPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return IntroductionPageState();
  }
}

class IntroductionPageState extends State<IntroductionPage> {

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Container(
            width: double.infinity,
            height: double.infinity,
            color: Colors.white,
            child: Center(
              child: Container(
                width: 100,
                height: 100,
                child: Image.asset("assets/abp.jpeg"),
              ),
            )
        )
    );
  }

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration(seconds: 2), (){
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => MyApp()));
    });
  }
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return OverlaySupport(child: MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'App Socket IO',
      theme: ThemeData(
          primarySwatch: Colors.blue,
          textTheme: TextTheme(
            headline1: TextStyle(fontSize: 16, color: Colour("#051639"), fontWeight: FontWeight.w500),
            headline2: TextStyle(fontSize: 20, color: Colour("#051639"), fontWeight: FontWeight.w500),
            subtitle1: TextStyle(fontSize: 14, color: Colour("#051639"), fontWeight: FontWeight.w500),
            subtitle2: TextStyle(fontSize: 12, color: Colour("#051639"), fontWeight: FontWeight.w400),
          )
      ),
      home: LoginPage(),
    ));
  }
}

class LoginPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return LoginState();
  }
}

class LoginState extends State<LoginPage> {
  final Connectivity _connectivity = Connectivity();
  StreamSubscription<ConnectivityResult> _connectivitySubscription;
  bool isNoInternet = false;
  bool hasUsername = false;
  bool hasPassword = false;
  bool isLoading = true;
  bool isSuccess = false;
  bool isFail = false;
  bool isTimeout = false;
  bool isRemember = false;
  bool isCancel = false;

  Auth authenication;

  TextEditingController usernameController = new TextEditingController();
  TextEditingController passwordController = new TextEditingController();

  String savedUsername = "";
  String savedPassword = "";

  Map<String, String> _listServer = new Map<String, String>();

  bool _isManagingServer = false;
  bool _isAddingServer = false;
  bool _isDeletingServer = false;

  TextEditingController _nameController = new TextEditingController();
  TextEditingController _ipController = new TextEditingController();
  TextEditingController _portController = new TextEditingController();

  @override
  void initState() {
    super.initState();
    // SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
        statusBarColor: Colors.transparent
    ));

    initAuth();

    initConnectivity();
    _connectivitySubscription =
        _connectivity.onConnectivityChanged.listen(_updateConnectionStatus);

  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return GestureDetector(
      onTap: (){
        FocusManager.instance.primaryFocus?.unfocus();
      },
      child: Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            title: Text("Đăng nhập", style: TextStyle(color: Colour("#051639")),),
            centerTitle: true,
            backgroundColor: Colors.white,
            elevation: 0,
            actions: [
            ],
          ),
          //searchBar
          body: Stack(
            children: [
              Container(
                  padding: EdgeInsets.only(left: 20, right: 20),
                  child: Center(
                    child: isLoading ? loadingDangNhap(Theme.of(context))
                        : isSuccess ? success(Theme.of(context), "Đăng nhập thành công")
                        :
                    Container(
                      height: MediaQuery.of(context).size.height,
                      child: ListView(
                        children: [
                          Column(
                            children: [
                              Center(
                                child: Container(
                                  margin: EdgeInsets.only(bottom: 50, top: 50),
                                  width: 100,
                                  height: 100,
                                  child: Image.asset("assets/logo.png"),
                                ),
                              ),
                              Container(
                                  margin: EdgeInsets.only(left: 20, right: 20, bottom: 20),
                                  child: MyDropDown(
                                    listOptions: _listServer.entries.map((e) => e.key).toList(),
                                    currentValue: currentServerName,
                                    onChangedFunction: changeServer,
                                    isExpand: true,
                                    customMargin: 15,
                                  )
                              ),
                              (isFail || isTimeout) ? Container(
                                margin: EdgeInsets.only(bottom: 20),
                                child: Text(isTimeout ? "Không thể kết nối đến máy chủ" : "Tên đăng nhập hoặc mật khẩu không chính xác", style: Theme.of(context).textTheme.subtitle2.merge(TextStyle(color: Colors.red[700])),),
                              ) : Container(),
                              Container(
                                  child: Container(
                                    margin: EdgeInsets.only(left: 20, right: 20),
                                    child: TextFormField(
                                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w400),
                                      controller: usernameController,
                                      autovalidateMode: AutovalidateMode.disabled,
                                      autocorrect: false,
                                      onChanged: (text){
                                        if(text.trim() != "") {
                                          setState(() {
                                            hasUsername = true;
                                          });
                                        }
                                        else {
                                          setState(() {
                                            hasUsername = false;
                                          });
                                        }
                                      },
                                      decoration: InputDecoration(
                                        filled: true,
                                        fillColor: Colour('#F8FAFF'),
                                        contentPadding: EdgeInsets.only(top: 6, bottom: 6, left: 15, right: 15),
                                        prefixIcon: Icon(Icons.account_circle, color:  !hasUsername ? Colour('#666D75') : Colour('#89A1FF'), size: 20,),
                                        hintText: "Tên đăng nhập", hintStyle: TextStyle(fontSize: 16, fontWeight: FontWeight.w400),
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
                                  )
                              ),
                              Container(
                                  margin: EdgeInsets.only(top: 20),
                                  child: Container(
                                    margin: EdgeInsets.only(left: 20, right: 20),
                                    child: TextFormField(
                                      obscureText: true,
                                      controller: passwordController,
                                      autovalidateMode: AutovalidateMode.disabled,
                                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w400),
                                      onChanged: (text){
                                        if(text.trim() != "") {
                                          setState(() {
                                            hasPassword = true;
                                          });
                                        }
                                        else {
                                          setState(() {
                                            hasPassword = false;
                                          });
                                        }
                                      },
                                      decoration: InputDecoration(
                                        filled: true,
                                        fillColor: Colour('#F8FAFF'),
                                        labelStyle: TextStyle(fontSize: 50),
                                        contentPadding: EdgeInsets.only(top: 6, bottom: 6, left: 15, right: 15),
                                        prefixIcon: Icon(Icons.lock, color: !hasPassword ? Colour('#666D75') : Colour('#89A1FF'), size: 20,),
                                        hintText: "Mật khẩu", hintStyle: TextStyle(fontSize: 16, fontWeight: FontWeight.w400),
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
                                  )
                              ),
                              Container(
                                margin: EdgeInsets.only(left: 15, top: 10),
                                child: Row(
                                  children: [
                                    Checkbox(value: isRemember, onChanged: (isChecked) {
                                      setState(() {
                                        isRemember = isChecked;
                                      });
                                    }),
                                    GestureDetector(
                                        onTap: (){
                                          setState(() {
                                            isRemember = !isRemember;
                                          });
                                        },
                                        child: Container(
                                          child: Text(
                                            "Lưu đăng nhập",
                                            style: Theme.of(context).textTheme.subtitle1.merge(TextStyle(fontWeight: FontWeight.w400)),
                                          ),
                                        )
                                    )
                                  ],
                                ),
                              ),
                              GestureDetector(
                                onTap: () {
                                  tryLogin(usernameController.text.toString().trim(), passwordController.text.toString());
                                },
                                child: Container(
                                  width: MediaQuery.of(context).size.width/2,
                                  margin: EdgeInsets.only(top: 10),
                                  padding: EdgeInsets.only(left: 15, right: 20, top: 10, bottom: 10),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(Icons.login, color: Colors.white,),
                                      Expanded(child: Container(
                                        margin: EdgeInsets.only(left: 15),
                                        child: Text("Đăng nhập", style: Theme.of(context).textTheme.subtitle1.merge(TextStyle(color: Colors.white)), textAlign: TextAlign.center, overflow: TextOverflow.ellipsis,),
                                      ))
                                    ],
                                  ),
                                  decoration: BoxDecoration(
                                      color: Colors.green,
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
                              Container(
                                  margin: EdgeInsets.only(top: 10, bottom: 10),
                                  child: Text("hoặc", style: TextStyle(fontStyle: FontStyle.italic),)
                              ),
                              GestureDetector(
                                onTap: () {
                                  setState(() {
                                    _isManagingServer = true;
                                  });
                                },
                                child: Container(
                                  width: MediaQuery.of(context).size.width/2,
                                  padding: EdgeInsets.only(left: 15, right: 20, top: 10, bottom: 10),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(Icons.edit, color: Colors.white,),
                                      Expanded(child: Container(
                                        margin: EdgeInsets.only(left: 10),
                                        child: Text("Quản lý server", style: Theme.of(context).textTheme.subtitle1.merge(TextStyle(color: Colors.white)), textAlign: TextAlign.center, overflow: TextOverflow.ellipsis,),
                                      ))
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
                        ],
                      )
                    ),
                  )
              ),
              _isManagingServer ? GestureDetector(
                onTap: (){
                  setState(() {
                    if(_isAddingServer) {
                      _isAddingServer = false;
                    }
                    else {
                      _isManagingServer = false;
                    }
                  });
                },
                child: Container(
                  width: double.infinity,
                  height: double.infinity,
                  color: Colors.black.withOpacity(0.5),
                )
              ) : Container(),
              _isManagingServer ? Center(
                child: Container(
                  margin: EdgeInsets.all(15),
                  child: Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(20),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Icon(Icons.close, color: Colors.transparent, size: 20,),
                            Text(_isAddingServer ? "Thêm Server mới" : "Danh sách Server", style: TextStyle(fontSize: 16),),
                            GestureDetector(
                                onTap: (){
                                  setState(() {
                                    if(_isAddingServer) {
                                      _isAddingServer = false;
                                    }
                                    else {
                                      _isManagingServer = false;
                                    }
                                  });
                                },
                                child: Container(
                                  child: Icon(Icons.close, color: Colors.black, size: 20,),
                                )
                            ),
                          ],
                        ),
                        !_isAddingServer ? Container(
                          margin: EdgeInsets.only(top: 15),
                          width: 120,
                          padding: EdgeInsets.only(left: 8, right: 15, top: 5, bottom: 5),
                          child: Row(
                            children: [
                              Container(
                                margin: EdgeInsets.only(right: 5),
                                child: Icon(Icons.add, color: Colors.white, size: 20,),
                              ),
                              Expanded(child: GestureDetector(
                                onTap: (){
                                  setState(() {
                                    _isAddingServer = true;
                                  });
                                },
                                child: Text("Thêm mới", style: TextStyle(fontSize: 14, color: Colors.white, fontWeight: FontWeight.bold), textAlign: TextAlign.center, overflow: TextOverflow.ellipsis,),
                              ))
                            ],
                          ),
                          decoration: BoxDecoration(
                              color: Colors.green,
                              borderRadius: BorderRadius.all(Radius.circular(5))
                          ),
                        ) : Container(),
                        !_isAddingServer ? Container(
                          height: 300,
                          margin: EdgeInsets.only(top: 30),
                          child: ListView(
                            children: _buildListServer(),
                          )
                        ) : Container(),
                        _isAddingServer ? Column(
                          children: [
                            Container(
                              margin: EdgeInsets.only(top: 30),
                              child: MyTextEdittingController(
                                icon: Icons.edit,
                                description: "Tên server",
                                title: "Tên server",
                                controller: _nameController,
                                textInputType: TextInputType.text,
                                validator: checkIP,
                                onChangedFunction: (){
                                  setState(() {

                                  });
                                },
                              ),
                            ),
                            Container(
                              margin: EdgeInsets.only(top: 15),
                              child: MyTextEdittingController(
                                icon: Icons.work,
                                description: "VD: 103.163.214.64",
                                title: "Địa chỉ IP",
                                controller: _ipController,
                                textInputType: TextInputType.number,
                                validator: checkIP,
                                onChangedFunction: (){
                                  setState(() {

                                  });
                                },
                              ),
                            ),
                            Container(
                              margin: EdgeInsets.only(top: 15),
                              child: MyTextEdittingController(
                                icon: Icons.padding,
                                description: "VD: 8081",
                                title: "Port",
                                controller: _portController,
                                textInputType: TextInputType.number,
                                validator: checkIP,
                                onChangedFunction: (){
                                  setState(() {

                                  });
                                },
                              ),
                            ),
                            Container(
                                margin: EdgeInsets.only(top: 30, left: 30, right: 30),
                                child: MyIconButton(
                                    icon: Icons.check,
                                    color: Colors.green,
                                    title: "Thêm mới",
                                    clickedFunction: (){
                                      authenication.setServer(_ipController.text, _portController.text, _nameController.text).then((value){
                                        // authenication.setCurrentServer(_ipController.text, _portController.text);
                                        loadServer(newServer: _ipController.text + ":" + _portController.text, newServerName: _nameController.text).then((value){
                                          setState(() {
                                            _isAddingServer = false;
                                          });
                                        });
                                      });

                                    }
                                )
                            )
                          ],
                        ) : Container()
                      ],
                    ),
                    decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.all(Radius.circular(15)),
                        boxShadow: [
                          BoxShadow(
                              color: Colors.black26,
                              spreadRadius: 2,
                              blurRadius: 2,
                              offset: Offset(2,2)
                          )
                        ]
                    ),
                  ),
                ),
              ) : Container()
            ],
          )
      ),
    );

  }

  void changeServer(String newServer) {
    setState(() {
      currentServer = _listServer.entries.where((element) => element.key == newServer).first?.value ?? "103.163.214.64:8081";
      currentServerName = newServer;
      authenication.setCurrentServer(newServer);
    });
  }

  List<Widget> _buildListServer() {
    List<Widget> resultWidget = new List<Widget>();
    _listServer.forEach((key, value) {
      resultWidget.add(
          Container(
              margin: EdgeInsets.only(top: 10),
              height: 40,
              decoration: BoxDecoration(
                  color: Colors.blueGrey[100].withOpacity(0.75)
              ),
              child: Row(
                children: [
                  Checkbox(value: key == currentServerName, onChanged: (value){
                    setState(() {
                      currentServer = key;
                      authenication.setCurrentServer(key);
                    });
                  }),
                  Expanded(child: GestureDetector(
                      onTap: (){
                        setState(() {
                          currentServer = key;
                          authenication.setCurrentServer(key);
                        });
                      },
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(child: Container(
                            child: Text(key),
                          ),),
                          key != "Server mặc định" ? IconButton(
                              onPressed: (){
                                deleteServer(key);
                              },
                              icon: Icon(Icons.delete, color: Colors.red,)
                          ) : Container()
                        ],
                      )
                  ))
                ],
              )
          )
      );
    });

    return resultWidget;
  }

  void deleteServer(String value) {

  }

  Future<void> loadServer({String newServer, String newServerName}) async {
    setState(() {
      _listServer.clear();
      _listServer["Server mặc định"] = "103.163.214.64:8081";
    });
    await authenication.getServer().then((value){
      print(value);
      if(value != null && value.isNotEmpty) {
        List<String> tempServer = value.split("-");
        int count = 1;
        tempServer.forEach((element) {
          String serverIP = "";
          String serverName = "";

          if(element.contains("+")) {
            serverIP = element.substring(0, element.indexOf("+"));
            serverName = element.substring(element.indexOf("+") + 1);
          }
          else {
            serverIP = element;
            serverName = "Server " + count.toString();
            count++;
          }

          if(element.isNotEmpty && !_listServer.containsKey(element)) {
            setState(() {
              _listServer[serverName] = serverIP;
            });
          }
        });
      }
      return;
    });

    if(newServer != null) {
      setState(() {
        currentServer = newServer;
      });
    }

    if(newServerName != null) {
      currentServerName = newServerName;
      currentServer = _listServer.entries.where((element) => element.key == newServerName).first?.value ?? "103.163.214.64:8081";

    }
  }

  bool isValidIP(String value) {
    return value.isEmpty ? false : true;
  }

  String checkIP(String value) {
    return !isValidIP(value) ? 'Vui lòng nhập' : null;
  }

  void initAuth() async {
    authenication = new Auth();
    await authenication.getUsername().then((value){
      savedUsername = value;
    });
    await authenication.getPassword().then((value){
      savedPassword = value;
    });

    authenication.getCurrentServer().then((value){
      print("Current server: " + (value ?? ""));
      loadServer(newServerName: value).then((value) => initSavedData());
    });
  }

  void initSavedData() {
    if(savedUsername != null && savedPassword != null && savedUsername != "" && savedPassword != "") {
      usernameController.text = savedUsername;
      passwordController.text = savedPassword;
      isRemember = true;
      tryLogin(savedUsername, savedPassword);
    }
    else {
      setState(() {
        isLoading = false;
      });
    }
  }

  void tryLogin(String username, String password){
    if(username.trim() != "" && password.trim() != "") {
      setState(() {
        isLoading = true;
      });

      Future.delayed(Duration(seconds: 10), (){
        if(mounted && !isCancel) {
          setState(() {
            setState(() {
              isLoading = false;
              isFail = false;
              isSuccess = false;
              isTimeout = true;
            });
          });
        }
      });

      socketService.getView(username, password).then((value){
        // print("get view: " + value);
        if(value != null && value.trim() == "timeout") {
          setState(() {
            isLoading = false;
            isFail = false;
            isSuccess = false;
            isTimeout = true;
          });
        }
        else if(value != null && value.trim() != "")
        {
          setState(() {
            isCancel = true;
          });

          getConfigSettings(value);
          getDashboardData(value);

          if(isRemember) {
            authenication.setUsername(username);
            authenication.setPassword(password);
          }

          setState(() {
            isLoading = false;
            isSuccess = true;
            isFail = false;
            isTimeout = false;
          });

          username_config = username;

          Future.delayed(Duration(seconds: 1), (){
            Navigator.push(
              context,
              PageTransition(
                type: PageTransitionType.rightToLeft,
                child: MainMenuPage(username, password),
              ),
            );
          });

        }
        else {
          setState(() {
            isLoading = false;
            isFail = true;
            isSuccess = false;
            isTimeout = false;
          });
        }

      });
    }
    else {
      setState(() {
        isLoading = false;
        isFail = false;
        isSuccess = false;
        isTimeout = false;
      });
    }
  }

  void getConfigSettings(String value) {
    listChannelSelect.clear();
    listChannelMeasure.clear();
    listAlarmType.clear();

    List<dynamic> jsonResult = json.decode(value);
    bool isChannelSelect = false;
    bool isChannelMeasure = false;
    jsonResult.forEach((field) {
      Map<String, dynamic> mapField = Map<String, dynamic>.from(field);
      mapField.forEach((key, value) {
        if(key == "name" && value == "login-viewer") {
          isChannelMeasure = true;
        }
        else if(key == "name" && value == "datatable-viewer") {
          isChannelSelect = true;
        }
      });
      if(isChannelMeasure) {
        List<dynamic> listScreenElement = mapField["listScreenElement"];
        listScreenElement.forEach((screenElement) {
          Map<String, dynamic> mapScreenElement = Map<String, dynamic>.from(screenElement);
          mapScreenElement.forEach((key, value) {
            if(key == "listTagInElement") {
              List<dynamic> listTagInElement = value;
              listTagInElement.forEach((tagElement) {
                Map<String, dynamic> mapTagElement = Map<String, dynamic>.from(tagElement);
                mapTagElement.forEach((key, value) {
                  if(key == "clientTag") {
                    Map<String, dynamic> mapSpecProp = Map<String, dynamic>.from(value);
                    mapSpecProp.forEach((key, value) {
                      if(key == "clientCmd") {
                        Map<String, dynamic> mapProperty = Map<String, dynamic>.from(value);
                        mapProperty.forEach((key, value) {
                          if(key == "clientHost") {
                            Map<String, dynamic> mapClientHost = Map<String, dynamic>.from(value);
                            mapClientHost.forEach((key, value) {
                              if(key == "connector") {
                                print("receive connector: " + value);
                                if(!ioConnector.contains(value)) {
                                  ioConnector.add(value);
                                }
                                
                              }
                              else if(key == "authority") {
                                print("receive authenicator: " + value);
                                if(!ioAuthenicator.contains(value)) {
                                  ioAuthenicator.add(value);
                                }
                              }
                            });
                          }
                        });
                      }
                      else if(key == "tagName") {

                      }
                    });
                  }
                });
              });
            }
            else if(key == "listSpecProp") {
              List<dynamic> listSpecProp = value;
              listSpecProp.forEach((specProp) {
                Map<String, dynamic> mapSpecProp = Map<String, dynamic>.from(specProp);
                bool isDashboardProperties = false;
                bool isAlarmProperties = false;
                bool isFeatureLayerProperties = false;
                mapSpecProp.forEach((key, value) {
                  if(key == "properties") {
                    Map<String, dynamic> mapProperty = Map<String, dynamic>.from(value);
                    ChannelMeasure temp = new ChannelMeasure();
                    AlarmType tempAlarm = new AlarmType();
                    mapProperty.forEach((key, value) {
                      if(key == "style" && value == "channel-meassure") {
                        isDashboardProperties = true;
                      }
                      else if(key == "style" && value == "feature-layer") {
                        isFeatureLayerProperties = true;
                      }
                      else if(key == "style" && value == "const-layer") {
                        mapLayer[mapProperty["prop2"]] = mapProperty["prop3"];
                        mapLayerVisible[mapProperty["prop2"]] = true;
                        arcgis.FeatureLayerOptions temp = arcgis.FeatureLayerOptions(mapProperty["prop3"],"");
                        listLayerArcgis.add(temp);
                      }
                      else if(key == "style" && value == "alarm-class") {
                        isAlarmProperties = true;
                      }
                      else if(key == "prop2" && isFeatureLayerProperties) {
                        linkFeatureLayer = value;
                      }
                      else if(key == "prop1" && isDashboardProperties) {
                        temp.channelID = value;
                      }
                      else if(key == "prop2" && isDashboardProperties) {
                        temp.channelName = value;
                      }
                      else if(key == "prop3" && isDashboardProperties) {
                        temp.unit = value;
                      }
                      else if(key == "prop1" && isAlarmProperties) {
                        tempAlarm.id = value;
                      }
                      else if(key == "prop2" && isAlarmProperties) {
                        tempAlarm.name = value;
                      }
                      else if(key == "prop3" && isAlarmProperties) {
                        tempAlarm.color = value;
                      }
                    });
                    if(isDashboardProperties) {
                      listChannelMeasure.add(temp);
                    }
                    else if(isAlarmProperties) {
                      listAlarmType.add(tempAlarm);
                    }
                    isAlarmProperties = false;
                    isDashboardProperties = false;
                    isFeatureLayerProperties = false;
                  }
                });
              });
            }
          });
        });

      }
      else if(isChannelSelect) {
        List<dynamic> listScreenElement = mapField["listScreenElement"];
        listScreenElement.forEach((screenElement) {
          Map<String, dynamic> mapScreenElement = Map<String, dynamic>.from(screenElement);
          mapScreenElement.forEach((key, value) {
            if(key == "listSpecProp") {
              List<dynamic> listSpecProp = value;
              listSpecProp.forEach((specProp) {
                Map<String, dynamic> mapSpecProp = Map<String, dynamic>.from(specProp);
                bool isDashboardProperties = false;
                mapSpecProp.forEach((key, value) {
                  if(key == "properties") {
                    Map<String, dynamic> mapProperty = Map<String, dynamic>.from(value);
                    mapProperty.forEach((key, value) {
                      if(key == "style" && value == "channel-select") {
                        isDashboardProperties = true;
                      }
                      else if(key == "prop1" && isDashboardProperties) {
                        listChannelSelect.add(value);
                      }
                    });
                    isDashboardProperties = false;
                  }
                });
              });
            }
          });
        });

      }
      isChannelMeasure = false;
      isChannelSelect = false;
    });
  }

  void getDashboardData(String value) {
    if(value != null && value.trim() != "" && value.trim() != "timeout")
    {
      setState(() {
        listDashboardModel.clear();
      });

      List<DashboardContent> listDashboardContent = new List<DashboardContent>();
      List<dynamic> jsonResult = json.decode(value);
      bool isDashboardContent = false;
      jsonResult.forEach((field) {
        Map<String, dynamic> mapField = Map<String, dynamic>.from(field);
        mapField.forEach((key, value) {
          if(key == "name" && value == "dashboard-viewer") {
            isDashboardContent = true;
          }
        });
        if(isDashboardContent) {
          List<dynamic> listScreenElement = mapField["listScreenElement"];
          listScreenElement.forEach((screenElement) {
            Map<String, dynamic> mapScreenElement = Map<String, dynamic>.from(screenElement);
            mapScreenElement.forEach((key, value) {
              if(key == "listSpecProp") {
                // print("inside");
                List<dynamic> listSpecProp = value;
                listSpecProp.forEach((specProp) {
                  Map<String, dynamic> mapSpecProp = Map<String, dynamic>.from(specProp);
                  bool isDashboardProperties = false;
                  mapSpecProp.forEach((key, value) {
                    if(key == "properties") {
                      Map<String, dynamic> mapProperty = Map<String, dynamic>.from(value);
                      mapProperty.forEach((key, value) {
                        if(key == "style" && value == "dashboard-content") {
                          isDashboardProperties = true;
                        }
                        if(key.contains("prop") && isDashboardProperties == true) {
                          if(value.trim() != "null") {
                            DashboardModel tempDashbordModel = new DashboardModel();
                            try {
                              Map<String, dynamic> mapProp1 = json.decode(value);
                              mapProp1.forEach((key, value) {
                                if(key == "name") {
                                  tempDashbordModel.name = value;
                                  currentDashboard = value;
                                }
                                else if(key == "activate") {
                                  try {
                                    tempDashbordModel.isActivated = value.toString().toUpperCase() == 'TRUE' ? true : false;
                                  }
                                  catch(e) {
                                    tempDashbordModel.isActivated = value.toString().toUpperCase() == 'TRUE' ? true : false;
                                  }
                                }
                                else if(key == "content") {
                                  tempDashbordModel.content = value;
                                  Map<String, dynamic> mapContent = Map<String, dynamic>.from(value);
                                  mapContent.forEach((key, value) {
                                    if(key == "children") {
                                      List<dynamic> listChildren = value;
                                      listChildren.forEach((element) {
                                        Map<String, dynamic> mapChildren = Map<String, dynamic>.from(element);
                                        mapChildren.forEach((key, value) {
                                          if(key == "content") {

                                            if(tempDashbordModel.isActivated == true) {
                                              DashboardContent temp = new DashboardContent();

                                              int maxCurrentIdx = 0;

                                              String messDashboardContent = value;
                                              String testTypeDashboardContent = value;

                                              if(testTypeDashboardContent.indexOf("tw-class=\"") != -1) {
                                                testTypeDashboardContent = testTypeDashboardContent.substring(testTypeDashboardContent.indexOf("tw-class=\"") + 10);
                                                String twClass = testTypeDashboardContent.substring(0, testTypeDashboardContent.indexOf("\""));
                                                // print(twClass);
                                                if(twClass == "logger-panel") {
                                                  temp.type = 0;
                                                }
                                                else if(twClass == "logger-chart") {
                                                  temp.type = 1;
                                                  messDashboardContent = messDashboardContent.substring(messDashboardContent.indexOf("tw-class=\"") + 10);
                                                }
                                                else if(twClass == "alarm-panel") {
                                                  temp.type = 2;
                                                }
                                                else {
                                                  temp.type = -1;
                                                }

                                              }
                                              else {
                                                temp.type = -1;
                                              }

                                              if(temp.type == 0) {
                                                if(messDashboardContent.indexOf("logger-id=\"") != -1) {
                                                  messDashboardContent = messDashboardContent.substring(messDashboardContent.indexOf("logger-id=\"") + 11);
                                                  String loggerID = messDashboardContent.substring(0, messDashboardContent.indexOf("\""));
                                                  // print(loggerID);
                                                  temp.loggerID = loggerID;
                                                }
                                                else {
                                                  temp.loggerID = "";
                                                }

                                                String reservedContent = messDashboardContent;

                                                if(messDashboardContent.indexOf("logger-name=\"") != -1) {
                                                  messDashboardContent = messDashboardContent.substring(messDashboardContent.indexOf("logger-name=\"") + 13);
                                                  String loggerName = messDashboardContent.substring(0, messDashboardContent.indexOf("\""));
                                                  // print(loggerName);
                                                  temp.loggerName = loggerName;
                                                }
                                                else {
                                                  temp.loggerName = "";
                                                }

                                                if(messDashboardContent.indexOf("channel=\"") != -1) {
                                                  messDashboardContent = messDashboardContent.substring(messDashboardContent.indexOf("channel=\"") + 9);
                                                  String loggerName = messDashboardContent.substring(0, messDashboardContent.indexOf("\""));

                                                  temp.listElement = new List<DashboardElement>();
                                                  while(loggerName.indexOf("{") != -1) {
                                                    DashboardElement tempElement = new DashboardElement();
                                                    if(loggerName.indexOf("rawName:") != -1) {
                                                      loggerName = loggerName.substring(loggerName.indexOf("rawName:") + 8);
                                                      String rawName = loggerName.substring(0, loggerName.indexOf(","));
                                                      // print("Raw name: " + rawName);
                                                      tempElement.rawName = rawName;
                                                    }
                                                    else {
                                                      tempElement.rawName = "";
                                                    }

                                                    if(loggerName.indexOf("name:") != - 1) {
                                                      loggerName = loggerName.substring(loggerName.indexOf("name:") + 5);
                                                      String name = loggerName.substring(0, loggerName.indexOf(","));
                                                      // print("Name: " + name);
                                                      tempElement.name = name;
                                                    }
                                                    else {
                                                      tempElement.name = "";
                                                    }

                                                    if(loggerName.indexOf("unit:") != -1) {
                                                      loggerName = loggerName.substring(loggerName.indexOf("unit:") + 5);
                                                      String unit = loggerName.substring(0, loggerName.indexOf(","));
                                                      // print("Unit: " + unit);
                                                      tempElement.unit = unit;
                                                    }
                                                    else {
                                                      tempElement.unit = "";
                                                    }
                                                    temp.listElement.add(tempElement);

                                                  }
                                                  listDashboardContent.add(temp);
                                                }
                                                else if(reservedContent.indexOf("channel=\"") != -1) {
                                                  reservedContent = reservedContent.substring(reservedContent.indexOf("channel=\"") + 9);
                                                  String loggerName = reservedContent.substring(0, reservedContent.indexOf("\""));

                                                  temp.listElement = new List<DashboardElement>();
                                                  while(loggerName.indexOf("{") != -1) {
                                                    DashboardElement tempElement = new DashboardElement();
                                                    if(loggerName.indexOf("rawName:") != -1) {
                                                      loggerName = loggerName.substring(loggerName.indexOf("rawName:") + 8);
                                                      String rawName = loggerName.substring(0, loggerName.indexOf(","));
                                                      // print("Raw name: " + rawName);
                                                      tempElement.rawName = rawName;
                                                    }
                                                    else {
                                                      tempElement.rawName = "";
                                                    }

                                                    if(loggerName.indexOf("name:") != - 1) {
                                                      loggerName = loggerName.substring(loggerName.indexOf("name:") + 5);
                                                      String name = loggerName.substring(0, loggerName.indexOf(","));
                                                      // print("Name: " + name);
                                                      tempElement.name = name;
                                                    }
                                                    else {
                                                      tempElement.name = "";
                                                    }

                                                    if(loggerName.indexOf("unit:") != -1) {
                                                      loggerName = loggerName.substring(loggerName.indexOf("unit:") + 5);
                                                      String unit = loggerName.substring(0, loggerName.indexOf(","));
                                                      // print("Unit: " + unit);
                                                      tempElement.unit = unit;
                                                    }
                                                    else {
                                                      tempElement.unit = "";
                                                    }
                                                    temp.listElement.add(tempElement);

                                                  }
                                                  listDashboardContent.add(temp);
                                                }
                                              }
                                              else if(temp.type == 1) {
                                                if(messDashboardContent.indexOf("chart=\"") != -1) {
                                                  messDashboardContent = messDashboardContent.substring(messDashboardContent.indexOf("chart=\"") + 9);
                                                  String loggerName = messDashboardContent.substring(0, messDashboardContent.indexOf("\""));

                                                  temp.listElement = new List<DashboardElement>();
                                                  bool isGotID = false;
                                                  while(loggerName.indexOf("{") != -1) {
                                                    DashboardElement tempElement = new DashboardElement();

                                                    if(!isGotID) {
                                                      if(loggerName.indexOf("loggerId:") != -1) {
                                                        loggerName = loggerName.substring(loggerName.indexOf("loggerId:") + 9);
                                                        String id = loggerName.substring(0, loggerName.indexOf(","));
                                                        // print("Logger ID: " + id);
                                                        temp.loggerID = id;
                                                        isGotID = true;
                                                      }
                                                      else {
                                                        temp.loggerID = "";
                                                      }
                                                    }

                                                    if(loggerName.indexOf("rawName:") != -1) {
                                                      loggerName = loggerName.substring(loggerName.indexOf("rawName:") + 8);
                                                      String rawName = loggerName.substring(0, loggerName.indexOf(","));
                                                      // print("Raw name: " + rawName);
                                                      tempElement.rawName = rawName;
                                                    }
                                                    else {
                                                      tempElement.rawName = "";
                                                    }

                                                    if(loggerName.indexOf("name:") != - 1) {
                                                      loggerName = loggerName.substring(loggerName.indexOf("name:") + 5);
                                                      String name = loggerName.substring(0, loggerName.indexOf(","));
                                                      // print("Name: " + name);
                                                      tempElement.name = name;
                                                    }
                                                    else {
                                                      tempElement.name = "";
                                                    }

                                                    if(loggerName.indexOf("unit:") != -1) {
                                                      loggerName = loggerName.substring(loggerName.indexOf("unit:") + 5);
                                                      String unit = loggerName.substring(0, loggerName.indexOf(","));
                                                      // print("Unit: " + unit);
                                                      tempElement.unit = unit;
                                                    }
                                                    else {
                                                      tempElement.unit = "";
                                                    }
                                                    temp.listElement.add(tempElement);

                                                  }
                                                  listDashboardContent.add(temp);
                                                }
                                              }
                                              else if(temp.type == 2) {
                                                if(messDashboardContent.indexOf("alarm-class=\"") != -1) {
                                                  messDashboardContent = messDashboardContent.substring(messDashboardContent.indexOf("alarm-class=\"]") + 14);
                                                  String loggerID = messDashboardContent.substring(0, messDashboardContent.indexOf("\"]"));
                                                  // print(loggerID);
                                                  temp.loggerID = loggerID;
                                                }
                                                else {
                                                  temp.loggerID = "";
                                                }
                                              }
                                            }
                                          }
                                          if(!listDashboardModel.map((e) => e.name).toList().contains(tempDashbordModel.name)) {
                                            listDashboardModel.add(tempDashbordModel);
                                          }
                                        });
                                      });
                                    }
                                  });
                                }
                              });
                            }
                            catch(e) {

                            }
                          }
                        }
                      });
                    }
                    isDashboardProperties = false;
                  });
                });
              }
            });
          });

        }
        isDashboardContent = false;
      });
      preloadedListDashboardContent = listDashboardContent;
      if(listDashboardModel.isNotEmpty) {
        try {
          currentDashboard = listDashboardModel.where((element) => element.isActivated == true).first.name;
        }
        catch(e) {
          currentDashboard = listDashboardModel.elementAt(0).name;
        }
      }
    }
    else {
      setState(() {
        preloadedGotDashboardData = false;
      });
    }
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
}

class MainMenuPage extends StatefulWidget {
  String username, password;

  MainMenuPage(this.username, this.password);

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return MainMenuState(username, password);
  }
}

class MainMenuState extends State<MainMenuPage> {

  List<MenuModel> listMenus = new List<MenuModel>();
  List<NewsModel> listNews = new List<NewsModel>();
  TextEditingController searchController = new TextEditingController();

  String username, password;

  MainMenuState(this.username, this.password);

  String searchText = "";

  @override
  void initState() {
    super.initState();
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
        statusBarColor: Colors.transparent
    ));

    registerNotification(username);

    addMenu();

    addNews();
  }

  void addMenu() {
    MenuModel dashboard = new MenuModel();
    dashboard.title = "Monitor";
    dashboard.color = Colors.transparent;
    dashboard.image = "assets/dashboard.png";
    dashboard.icon = Icon(Icons.assignment, color: Colors.white, size: 30,);
    listMenus.add(dashboard);

    // MenuModel report = new MenuModel();
    // report.title = "Report";
    // report.color = Colors.transparent;
    // report.image = "assets/report.png";
    // report.icon = Icon(Icons.assignment, color: Colors.white, size: 30,);
    // listMenus.add(report);
    //
    // MenuModel map = new MenuModel();
    // map.title = "Bản đồ";
    // map.color = Colors.transparent;
    // map.image = "assets/map.png";
    // map.icon = Icon(Icons.map, color: Colors.white, size: 30,);
    // listMenus.add(map);

    // for(int i = 0; i < 7; i++) {
    //   MenuModel temp = new MenuModel();
    //   temp.title = "Menu";
    //   temp.color = Colour('#ECF2FF');
    //   listMenus.add(temp);
    // }
  }

  void addNews() {
    NewsModel news1 = new NewsModel();
    news1.title = "Điểm sự cố trong ngày";
    news1.color = Colors.transparent;
    news1.image = "assets/news1.png";
    news1.icon = Icon(Icons.assignment, color: Colors.white, size: 30,);
    listNews.add(news1);

    NewsModel news2 = new NewsModel();
    news2.title = "Thông tin mới nổi bật";
    news2.color = Colors.transparent;
    news2.image = "assets/news2.png";
    news2.icon = Icon(Icons.assignment, color: Colors.white, size: 30,);
    listNews.add(news2);

    // for(int i = 0; i < 2; i++) {
    //   NewsModel temp = new NewsModel();
    //   temp.color = Colour('#ECF2FF');
    //   listNews.add(temp);
    // }
  }

  List<Widget> buildNewsMenu() {
    List<Widget> resultWidgets = new List<Widget>();
    for(int i = 0; i < listNews.length; i++) {
      resultWidgets.add(
          (listNews.elementAt(i).title != null && listNews.elementAt(i).title != "") ? new Container(
            margin: EdgeInsets.only(right: 20),
            padding: EdgeInsets.all(15),
            height: 130,
            width: 280,
            child: Row(
              children: [
                Container(
                  margin: EdgeInsets.only(right: 15),
                  padding: EdgeInsets.all(10),
                  child: SizedBox(
                    child: Image.asset(listNews.elementAt(i).image),
                    width: 100,
                  ),

                ),
                Expanded(child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Flexible(child: Text(listNews.elementAt(i).title,
                          style: Theme.of(context).textTheme.headline1.merge(TextStyle(fontWeight: FontWeight.w400)), overflow: TextOverflow.visible, textAlign: TextAlign.center,),
                        ),
                      ],
                    ),
                    GestureDetector(
                      onTap: (){
                        showAlertDialog(context, "Chức năng này đang được phát ", "Vui lòng đợi các bản cập nhật tiếp theo");
                      },
                      child: Container(
                        padding: EdgeInsets.only(left: 15, right: 15, top: 8, bottom: 8),
                        child: Text("Xem ngay", style: Theme.of(context).textTheme.headline1),
                        decoration: BoxDecoration(
                            color: Colour("#F6d06D"),
                            borderRadius: BorderRadius.all(Radius.circular(25))
                        ),
                      ),
                    )
                  ],
                ))
              ],
            ),
            decoration: BoxDecoration(
              color: Colour('#ECF2FF'),
              borderRadius: BorderRadius.all(Radius.circular(10)),
            ),
          ) : new Container(
            margin: EdgeInsets.only(right: 20),
            padding: EdgeInsets.all(15),
            height: 130,
            width: 250,
            decoration: BoxDecoration(
              color: Colour('#ECF2FF'),
              borderRadius: BorderRadius.all(Radius.circular(10)),
            ),
          )
      );
    }
    return resultWidgets;
  }

  List<Widget> buildMainMenu(List<MenuModel> listMenu) {
    List<Widget> resultWidgets = new List<Widget>();
    for(int i = 0; i < listMenu.length; i++) {
      if(listMenu.elementAt(i).title.toUpperCase().contains(searchText.toUpperCase())) {
        resultWidgets.add(
            new GestureDetector(
              onTap: (){
                if(listMenu.elementAt(i).title.trim() == "Monitor") {
                  Navigator.push(
                    context,
                    PageTransition(
                      type: PageTransitionType.rightToLeft,
                      child: MyHomePage(username, password),
                    ),
                  );
                }
                else if(listMenu.elementAt(i).title.trim() == "Bản đồ") {
                  Navigator.push(
                    context,
                    PageTransition(
                      type: PageTransitionType.rightToLeft,
                      child: MapScene(),
                    ),
                  );
                }
              },
              child: Container(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 50,
                      height: 50,
                      child: (listMenu.elementAt(i).image != null && listMenu.elementAt(i).image != "") ? (Image.asset(listMenu.elementAt(i).image)) : (listMenu.elementAt(i).icon != null ? listMenu.elementAt(i).icon : Container()),
                      margin: EdgeInsets.only(bottom: 10),
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.all(Radius.circular(10)),
                          // color: Colour('#ECF2FF')
                          color: listMenu.elementAt(i).color
                      ),
                    ),
                    Text(listMenu.elementAt(i).title.trim(), style: Theme.of(context).textTheme.subtitle1.merge(TextStyle(fontWeight: FontWeight.w400)),)
                  ],
                ),
              ),
            )
        );
      }
    }
    return resultWidgets;
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return GestureDetector(
      onTap: (){
        FocusManager.instance.primaryFocus?.unfocus();
      },
      child: Scaffold(
          backgroundColor: Colors.white,
          appBar: PreferredSize(
            preferredSize: Size.fromHeight(0),
            child: AppBar(
              centerTitle: false,
              backgroundColor: Colour("#246EE9"),
              elevation: 0,
              toolbarHeight: 0,
            )
          ),
          //searchBar
          body: ListView(
            children: [
              Container(
                padding: EdgeInsets.only(top: 25, left: 25, right: 25, bottom: 50),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: (){

                      },
                      child: Container(
                        margin: EdgeInsets.only(right: 15),
                        child: Icon(Icons.account_circle, size: 60, color: Colour('#D1DBEE'),),
                      ),
                    ),
                    Expanded(child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          margin: EdgeInsets.only(bottom: 5),
                          child: Text(username, style: Theme.of(context).textTheme.headline1.merge(TextStyle(color: Colors.white)),),
                        ),
                        Text("Xin chào!", style: Theme.of(context).textTheme.subtitle2.merge(TextStyle(color: Colors.white)),),

                      ],
                    ),),
                    GestureDetector(
                        onTap: (){
                          Auth authenication = new Auth();
                          authenication.clearSavedDate();
                          Navigator.push(
                            context,
                            PageTransition(
                              type: PageTransitionType.rightToLeft,
                              child: LoginPage(),
                            ),
                          );
                        },
                        child: Container(
                            child: new Icon(Icons.logout, color: Colors.white,)
                        )
                    )
                  ],
                ),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Colour("#246EE9"), Colour("#011586")],
                  ),
                ),
              ),
              Container(
                transform: Matrix4.translationValues(0, -25, 0),
                padding: EdgeInsets.only(left: 25, right: 25, top: 20),
                child: TextFormField(
                  controller: searchController,
                  autovalidateMode: AutovalidateMode.disabled,
                  onChanged: (text){
                    setState(() {
                      searchText = text;
                    });
                  },
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colour('#F8FAFF'),
                    contentPadding: EdgeInsets.only(top: 6, bottom: 6, left: 15, right: 15),
                    suffixIcon: IconButton(
                      onPressed: (){

                      },
                      icon: Icon(Icons.search, color: Colour('#666D75'), size: 30,),
                    ),
                    hintText: "Bạn cần tìm gì", hintStyle: TextStyle(fontSize: 16, fontWeight: FontWeight.w400),
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
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(topLeft: Radius.circular(25), topRight: Radius.circular(25))
                ),
              ),
              GridView.count(
                padding: EdgeInsets.only(top: 10, left: 25, right: 25),
                physics: NeverScrollableScrollPhysics(), // to disable GridView's scrolling
                shrinkWrap: true,
                crossAxisCount: 4,
                mainAxisSpacing: 10.0,
                children: buildMainMenu(listMenus),
              ),
              Container(
                  padding: EdgeInsets.only(left: 25, right: 25),
                  margin: EdgeInsets.only(top: 30),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("Cập nhật hôm nay", style: Theme.of(context).textTheme.headline2,),
                      Text("Xem thêm", style: Theme.of(context).textTheme.subtitle1.merge(TextStyle(fontWeight: FontWeight.w400, color: Colors.blue)),)
                      // Text("Tất cả", style: TextStyle(fontSize: 16, color: Colour('#4466EE')),)
                    ],
                  )
              ),
              Container(
                  margin: EdgeInsets.only(left: 25, top: 20),
                  height: 130,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: buildNewsMenu(),
                  )
              )
            ],
          )
      ),
    );

  }
}

class MyHomePage extends StatefulWidget {
  String username, password;

  MyHomePage(this.username, this.password);

  @override
  _MyHomePageState createState(){
    return _MyHomePageState(username, password);
  }
}

class _MyHomePageState extends State<MyHomePage> with TickerProviderStateMixin {
  //Main variables
  TabController tabController;
  int currentTabIndex = 0;
  String username, password;
  _MyHomePageState(this.username, this.password);

  //Datatable variables
  bool isGotData = false, isError = false, isInit = true, isCancel = false, isNoInternet = false;
  String resultString = "";
  TextEditingController searchController = new TextEditingController();
  int tabIdx = 0;

  //Check connection variables
  final Connectivity _connectivity = Connectivity();
  StreamSubscription<ConnectivityResult> _connectivitySubscription;
  Timer loadTimer;

  //Dashboard variables
  List<DashboardContent> listDashboard = new List<DashboardContent>();
  bool isLoadingDashboard = true, isErrorDashboard = false, isGotDashboardData = false;
  Timer timerDashboard;
  List<Widget> listDashboardWidgets = new List<Widget>();
  List<Widget> listLoggersWidgets = new List<Widget>();
  List<Widget> listChartsWidgets = new List<Widget>();
  bool isDashboardLogger = true;
  bool isDashboardChart = true;

  //Map variables
  List<LayerOptions> listLayers = new List<LayerOptions>();
  List<LoggerPoint> listLoggerPoints = new List<LoggerPoint>();
  int viewMenu = 0;
  bool isViewMenu = false;
  bool isSearch = false;
  bool isInformation = false;
  // bool isNoInternet = false;
  TextEditingController searchMapController = new TextEditingController();
  MapController _mapController;
  Map<String, bool> listPhuong = new Map<String, bool>();
  bool isTatCa = true;
  bool isInitPhuong = false;
  List<Marker> listMarkers = new List<Marker>();
  String currentSearchText = "";
  LoggerPoint currentPoint = new LoggerPoint();
  bool isInitMap = false;
  bool isLoadingMap = true;
  List<Marker> markers;

  //Chart variables
  bool isLoadingData = false;
  LineChart lineChart;
  Map<DateTime, double> chartData = new Map<DateTime, double>();
  String currentLogger = "", currentChannel = "";

  @override
  void initState() {
    super.initState();

    isSendingQuery = false;
    isCancel = false;
    isGotDashboardData = false;

    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
        statusBarColor: Colors.transparent
    ));

    getAddresses();

    Future.delayed(Duration(seconds: 5), (){
      if(isGotData != true && !isCancel) {
        if(mounted) {
          setState(() {
            isError = true;
            isErrorDashboard = true;
          });
        }
      }
    });

    initConnectivity();
    _connectivitySubscription =
        _connectivity.onConnectivityChanged.listen(_updateConnectionStatus);

    tabController = new TabController(length: 3, vsync: this);

    tabController.addListener(doOnTabChange);

    if(listDashboardModel.isNotEmpty) {
      try {
        setState(() {
          currentDashboard = listDashboardModel.where((element) => element.isActivated == true).first.name;
        });
      }
      catch(e) {
        setState(() {
          currentDashboard = listDashboardModel.elementAt(0).name;
        });
      }
    }

  }

  void doOnTabChange() {
    switch(tabController.index) {
      case 0: {
        if(!tabController.indexIsChanging) {
          setState(() {
            tabIdx = 0;
            isLoadingMap = true;
          });

          if(isError) {
            setState(() {
              isLoadingDashboard = true;
            });
            retrySocketIO();
          }
          else {
            loadDashboard();
          }
        }
        break;
      }
      case 1: {
        if(!tabController.indexIsChanging) {
          setState(() {
            tabIdx = 1;
            isLoadingMap = true;
          });
          if(isError) {
            retrySocketIO();
          }
        }
        break;
      }
      case 2: {

        if(!tabController.indexIsChanging) {

          setState(() {
            tabIdx = 2;
            isLoadingMap = true;
            _mapController = new MapController();
            globalMapController = _mapController;
            if(!isInitMap) {
              listLayers.add(TileLayerOptions(
                urlTemplate: 'https://server.arcgisonline.com/ArcGIS/rest/services/World_Topo_Map/MapServer/tile/{z}/{y}/{x}',
                subdomains: ['a', 'b', 'c'],
              ));
              mapLayer.forEach((key, value) {
                listLayers.add(mapLayerVisible[key] ? arcgis.FeatureLayerOptions(
                  value,
                  "polygon",
                  onTap: (dynamic attributes, LatLng location) {
                    print(attributes);
                  },
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
                size: Size(40, 40),
                anchor: AnchorPos.align(AnchorAlign.center),
                fitBoundsOptions: FitBoundsOptions(
                  padding: EdgeInsets.all(50),
                ),
                markers: isTatCa ? listMarkers : listMarkers.where((element) => element.width != 0 && element.height != 0).toList(),
                polygonOptions: PolygonOptions(
                    borderColor: Colors.blueAccent,
                    color: Colors.black12,
                    borderStrokeWidth: 3),
                popupOptions: PopupOptions(
                    popupSnap: PopupSnap.markerTop,
                    // popupController: _popupController,
                    popupBuilder: (_, marker) => Container(
                      width: 200,
                      height: 100,
                      color: Colors.white,
                      child: GestureDetector(
                        // onTap: () => debugPrint('Popup tap!'),
                        child: Text(
                          'Container popup for marker at ${marker.point}',
                        ),
                      ),
                    )),
                builder: (context, markers) {
                  return Container(
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20.0),
                        color: Colors.blue),
                    child: Center(
                      child: Text(
                        markers.length.toString(),
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  );
                },
              ));

              getFeatures();
            }
            else {
              isLoadingMap = false;
            }
          });
        }

        break;
      }
      default: {
        setState(() {
          tabIdx = 0;
        });
        break;
      }
    }
  }

  @override
  void dispose() {
    _connectivitySubscription.cancel();
    isReceivedDashboardChart = false;
    super.dispose();
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
        WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
          if(isInit) {
            if(!isConnectToSocket) {
              initSocketIO();
            }
            else {
              Future.delayed(Duration(seconds: 5), (){
                if(!isCancel) {
                  isConnectToSocket = false;
                }
              });

              setState(() {
                listData.clear();
                storedData.clear();
                listAddresses.clear();
              });
              print("list sockets size: " + listSocket.length.toString());
              int idx = 1;
              listSocket.forEach((element) {
                socketService.pushDataEvent(setDataChanged, element, idx);
                idx++;
              });
            }
            isInit = false;
          }
        });
        break;
      case ConnectivityResult.mobile:
        WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
          if(isInit) {
            if(!isConnectToSocket) {
              initSocketIO();
            }
            else {
              Future.delayed(Duration(seconds: 5), (){
                if(!isCancel) {
                  isConnectToSocket = false;
                }
              });

              setState(() {
                listData.clear();
                storedData.clear();
                listAddresses.clear();
              });
              int idx = 1;
              print("list sockets size: " + listSocket.length.toString());
              listSocket.forEach((element) {
                socketService.pushDataEvent(setDataChanged, element, idx);
                idx++;
              });
            }
            isInit = false;
          }
        });
        break;
      case ConnectivityResult.none:
        if(mounted) {
          setState(() => isNoInternet = true);
        }
        break;
      default:
      //setState(() => _connectionStatus = 'Failed to get connectivity.');
        break;
    }
  }

  //Logger Data Functions

  void retrySocketIO() {
    print("rerty socket io");

    if(loadTimer != null) {
      loadTimer.cancel();
    }

    if(mounted) {
      setState(() {
        isGotData = false;
        isError = false;
        isInit = true;
        isCancel = false;
        isNoInternet = false;
      });
    }

    Future.delayed(Duration(seconds: 1), (){
      initConnectivity();

      loadTimer = Timer(Duration(seconds: 5), (){
        if(isGotData != true && !isCancel) {
          if(mounted) {
            setState(() {
              isError = true;
            });
          }
        }
      });
    });


  }

  void initSocketIO() {
    print("init socket io");
    Future.delayed(Duration(seconds: 10), (){
      print("isCancel: " + isCancel.toString());
      if(!isCancel) {
        setState(() {
          isLoadingDashboard = false;
        });
      }
    });
    setState(() {
      listData.clear();
      storedData.clear();
      listAddresses.clear();
    });
    socketService.createSocketConnection(setDataChanged);
  }

  void searchData(String searchText) {


    if(mounted) {
      setState(() {
        isGotData = false;
        listData.clear();
      });

      if(searchText.trim() != "") {
        storedData.forEach((element) {
          if(element.objName.contains(searchText)){
            listData.add(element);
          }
        });
      }
      else {
        listData.addAll(storedData);
      }

      setState(() {
        isGotData = true;
      });
    }
  }

  void setDashboardChanged(List<DashboardContent> newListDashboard) {
    setState(() {
      if(timerDashboard != null) timerDashboard.cancel();
      listDashboard = newListDashboard;
      isErrorDashboard = false;
      isGotDashboardData = true;
    });
    buildListDashboard();
  }

  void reloadDashboard() {
    print("reload dashboard");
    setState(() {
      isLoadingDashboard = true;
    });

    timerDashboard = Timer(Duration(seconds: 5), () {
      if(!isGotDashboardData) {
        setState(() {
          isLoadingDashboard = false;
          isErrorDashboard = true;
        });
      }
    });

    int temp_time = DateTime.now().millisecondsSinceEpoch;

    socketService.getView(username, password).then((value){
      print("wait for view in " + (DateTime.now().millisecondsSinceEpoch - temp_time).toString());
      temp_time = DateTime.now().millisecondsSinceEpoch;
      if(mounted && tabIdx == 0) {
        if(value != null && value.trim() != "" && value.trim() != "timeout")
        {
          List<DashboardContent> listDashboardContent = new List<DashboardContent>();
          List<dynamic> jsonResult = json.decode(value);
          bool isDashboardContent = false;
          jsonResult.forEach((field) {
            Map<String, dynamic> mapField = Map<String, dynamic>.from(field);
            mapField.forEach((key, value) {
              if(key == "name" && value == "dashboard-viewer") {
                isDashboardContent = true;
              }
            });
            if(isDashboardContent) {
              List<dynamic> listScreenElement = mapField["listScreenElement"];
              listScreenElement.forEach((screenElement) {
                Map<String, dynamic> mapScreenElement = Map<String, dynamic>.from(screenElement);
                mapScreenElement.forEach((key, value) {
                  if(key == "listSpecProp") {
                    // print("inside");
                    List<dynamic> listSpecProp = value;
                    listSpecProp.forEach((specProp) {
                      Map<String, dynamic> mapSpecProp = Map<String, dynamic>.from(specProp);
                      bool isDashboardProperties = false;
                      mapSpecProp.forEach((key, value) {
                        if(key == "properties") {
                          Map<String, dynamic> mapProperty = Map<String, dynamic>.from(value);
                          mapProperty.forEach((key, value) {
                            if(key == "style" && value == "dashboard-content") {
                              isDashboardProperties = true;
                            }
                            if(key.contains("prop") && isDashboardProperties == true) {
                              if(value.trim() != "null") {
                                DashboardModel tempDashbordModel = new DashboardModel();
                                try {
                                  Map<String, dynamic> mapProp1 = json.decode(value);
                                  mapProp1.forEach((key, value) {
                                    if(key == "name") {
                                      tempDashbordModel.name = value;
                                    }
                                    else if(key == "activate") {
                                      try {
                                        tempDashbordModel.isActivated = value.toString().toUpperCase() == 'TRUE' ? true : false;
                                      }
                                      catch(e) {
                                        tempDashbordModel.isActivated = value.toString().toUpperCase() == 'TRUE' ? true : false;
                                      }
                                    }
                                    else if(key == "content") {
                                      tempDashbordModel.content = value;
                                      Map<String, dynamic> mapContent = Map<String, dynamic>.from(value);
                                      mapContent.forEach((key, value) {
                                        if(key == "children") {
                                          List<dynamic> listChildren = value;
                                          listChildren.forEach((element) {
                                            Map<String, dynamic> mapChildren = Map<String, dynamic>.from(element);
                                            mapChildren.forEach((key, value) {
                                              if(key == "content") {

                                                if(tempDashbordModel.isActivated == true) {
                                                  DashboardContent temp = new DashboardContent();

                                                  int maxCurrentIdx = 0;

                                                  String messDashboardContent = value;
                                                  String testTypeDashboardContent = value;

                                                  if(testTypeDashboardContent.indexOf("tw-class=\"") != -1) {
                                                    testTypeDashboardContent = testTypeDashboardContent.substring(testTypeDashboardContent.indexOf("tw-class=\"") + 10);
                                                    String twClass = testTypeDashboardContent.substring(0, testTypeDashboardContent.indexOf("\""));
                                                    // print(twClass);
                                                    if(twClass == "logger-panel") {
                                                      temp.type = 0;
                                                    }
                                                    else if(twClass == "logger-chart") {
                                                      temp.type = 1;
                                                      messDashboardContent = messDashboardContent.substring(messDashboardContent.indexOf("tw-class=\"") + 10);
                                                    }
                                                    else if(twClass == "alarm-panel") {
                                                      temp.type = 2;
                                                    }
                                                    else {
                                                      temp.type = -1;
                                                    }

                                                  }
                                                  else {
                                                    temp.type = -1;
                                                  }

                                                  if(temp.type == 0) {
                                                    if(messDashboardContent.indexOf("logger-id=\"") != -1) {
                                                      messDashboardContent = messDashboardContent.substring(messDashboardContent.indexOf("logger-id=\"") + 11);
                                                      String loggerID = messDashboardContent.substring(0, messDashboardContent.indexOf("\""));
                                                      // print(loggerID);
                                                      temp.loggerID = loggerID;
                                                    }
                                                    else {
                                                      temp.loggerID = "";
                                                    }

                                                    String reservedContent = messDashboardContent;

                                                    if(messDashboardContent.indexOf("logger-name=\"") != -1) {
                                                      messDashboardContent = messDashboardContent.substring(messDashboardContent.indexOf("logger-name=\"") + 13);
                                                      String loggerName = messDashboardContent.substring(0, messDashboardContent.indexOf("\""));
                                                      // print(loggerName);
                                                      temp.loggerName = loggerName;
                                                    }
                                                    else {
                                                      temp.loggerName = "";
                                                    }

                                                    if(messDashboardContent.indexOf("channel=\"") != -1) {
                                                      messDashboardContent = messDashboardContent.substring(messDashboardContent.indexOf("channel=\"") + 9);
                                                      String loggerName = messDashboardContent.substring(0, messDashboardContent.indexOf("\""));

                                                      temp.listElement = new List<DashboardElement>();
                                                      while(loggerName.indexOf("{") != -1) {
                                                        DashboardElement tempElement = new DashboardElement();
                                                        if(loggerName.indexOf("rawName:") != -1) {
                                                          loggerName = loggerName.substring(loggerName.indexOf("rawName:") + 8);
                                                          String rawName = loggerName.substring(0, loggerName.indexOf(","));
                                                          // print("Raw name: " + rawName);
                                                          tempElement.rawName = rawName;
                                                        }
                                                        else {
                                                          tempElement.rawName = "";
                                                        }

                                                        if(loggerName.indexOf("name:") != - 1) {
                                                          loggerName = loggerName.substring(loggerName.indexOf("name:") + 5);
                                                          String name = loggerName.substring(0, loggerName.indexOf(","));
                                                          // print("Name: " + name);
                                                          tempElement.name = name;
                                                        }
                                                        else {
                                                          tempElement.name = "";
                                                        }

                                                        if(loggerName.indexOf("unit:") != -1) {
                                                          loggerName = loggerName.substring(loggerName.indexOf("unit:") + 5);
                                                          String unit = loggerName.substring(0, loggerName.indexOf(","));
                                                          // print("Unit: " + unit);
                                                          tempElement.unit = unit;
                                                        }
                                                        else {
                                                          tempElement.unit = "";
                                                        }
                                                        temp.listElement.add(tempElement);

                                                      }
                                                      listDashboardContent.add(temp);
                                                    }
                                                    else if(reservedContent.indexOf("channel=\"") != -1) {
                                                      reservedContent = reservedContent.substring(reservedContent.indexOf("channel=\"") + 9);
                                                      String loggerName = reservedContent.substring(0, reservedContent.indexOf("\""));

                                                      temp.listElement = new List<DashboardElement>();
                                                      while(loggerName.indexOf("{") != -1) {
                                                        DashboardElement tempElement = new DashboardElement();
                                                        if(loggerName.indexOf("rawName:") != -1) {
                                                          loggerName = loggerName.substring(loggerName.indexOf("rawName:") + 8);
                                                          String rawName = loggerName.substring(0, loggerName.indexOf(","));
                                                          // print("Raw name: " + rawName);
                                                          tempElement.rawName = rawName;
                                                        }
                                                        else {
                                                          tempElement.rawName = "";
                                                        }

                                                        if(loggerName.indexOf("name:") != - 1) {
                                                          loggerName = loggerName.substring(loggerName.indexOf("name:") + 5);
                                                          String name = loggerName.substring(0, loggerName.indexOf(","));
                                                          // print("Name: " + name);
                                                          tempElement.name = name;
                                                        }
                                                        else {
                                                          tempElement.name = "";
                                                        }

                                                        if(loggerName.indexOf("unit:") != -1) {
                                                          loggerName = loggerName.substring(loggerName.indexOf("unit:") + 5);
                                                          String unit = loggerName.substring(0, loggerName.indexOf(","));
                                                          // print("Unit: " + unit);
                                                          tempElement.unit = unit;
                                                        }
                                                        else {
                                                          tempElement.unit = "";
                                                        }
                                                        temp.listElement.add(tempElement);

                                                      }
                                                      listDashboardContent.add(temp);
                                                    }
                                                  }
                                                  else if(temp.type == 1) {
                                                    if(messDashboardContent.indexOf("chart=\"") != -1) {
                                                      messDashboardContent = messDashboardContent.substring(messDashboardContent.indexOf("chart=\"") + 9);
                                                      String loggerName = messDashboardContent.substring(0, messDashboardContent.indexOf("\""));

                                                      temp.listElement = new List<DashboardElement>();
                                                      bool isGotID = false;
                                                      while(loggerName.indexOf("{") != -1) {
                                                        DashboardElement tempElement = new DashboardElement();

                                                        if(!isGotID) {
                                                          if(loggerName.indexOf("loggerId:") != -1) {
                                                            loggerName = loggerName.substring(loggerName.indexOf("loggerId:") + 9);
                                                            String id = loggerName.substring(0, loggerName.indexOf(","));
                                                            // print("Logger ID: " + id);
                                                            temp.loggerID = id;
                                                            isGotID = true;
                                                          }
                                                          else {
                                                            temp.loggerID = "";
                                                          }
                                                        }

                                                        if(loggerName.indexOf("rawName:") != -1) {
                                                          loggerName = loggerName.substring(loggerName.indexOf("rawName:") + 8);
                                                          String rawName = loggerName.substring(0, loggerName.indexOf(","));
                                                          // print("Raw name: " + rawName);
                                                          tempElement.rawName = rawName;
                                                        }
                                                        else {
                                                          tempElement.rawName = "";
                                                        }

                                                        if(loggerName.indexOf("name:") != - 1) {
                                                          loggerName = loggerName.substring(loggerName.indexOf("name:") + 5);
                                                          String name = loggerName.substring(0, loggerName.indexOf(","));
                                                          // print("Name: " + name);
                                                          tempElement.name = name;
                                                        }
                                                        else {
                                                          tempElement.name = "";
                                                        }

                                                        if(loggerName.indexOf("unit:") != -1) {
                                                          loggerName = loggerName.substring(loggerName.indexOf("unit:") + 5);
                                                          String unit = loggerName.substring(0, loggerName.indexOf(","));
                                                          // print("Unit: " + unit);
                                                          tempElement.unit = unit;
                                                        }
                                                        else {
                                                          tempElement.unit = "";
                                                        }
                                                        temp.listElement.add(tempElement);

                                                      }
                                                      listDashboardContent.add(temp);
                                                    }
                                                  }
                                                  else if(temp.type == 2) {
                                                    if(messDashboardContent.indexOf("alarm-class=\"") != -1) {
                                                      messDashboardContent = messDashboardContent.substring(messDashboardContent.indexOf("alarm-class=\"]") + 14);
                                                      String loggerID = messDashboardContent.substring(0, messDashboardContent.indexOf("\"]"));
                                                      // print(loggerID);
                                                      temp.loggerID = loggerID;
                                                    }
                                                    else {
                                                      temp.loggerID = "";
                                                    }
                                                  }
                                                }
                                              }
                                              if(!listDashboardModel.map((e) => e.name).toList().contains(tempDashbordModel.name)) {
                                                listDashboardModel.add(tempDashbordModel);
                                              }
                                            });
                                          });
                                        }
                                      });
                                    }
                                  });
                                }
                                catch(e) {

                                }
                              }
                            }
                          });
                        }
                        isDashboardProperties = false;
                      });
                    });
                  }
                });
              });

            }
            isDashboardContent = false;
          });
          setDashboardChanged(listDashboardContent);
        }
        else {
          setState(() {
            isGotDashboardData = false;
          });
        }
      }
      print("process data in " + (DateTime.now().millisecondsSinceEpoch - temp_time).toString());
    });

  }

  List<DashboardContent> decodeJsonDashboard(Map<String, dynamic> mapProp1) {
    List<DashboardContent> listDashboardContent = new List<DashboardContent>();
    try {
      mapProp1.forEach((key, value) {
        if(key == "children") {
          List<dynamic> listChildren = value;
          listChildren.forEach((element) {
            Map<String, dynamic> mapChildren = Map<String, dynamic>.from(element);
            mapChildren.forEach((key, value) {
              if(key == "content") {

                DashboardContent temp = new DashboardContent();

                int maxCurrentIdx = 0;

                String messDashboardContent = value;
                String testTypeDashboardContent = value;

                if(testTypeDashboardContent.indexOf("tw-class=\"") != -1) {
                  testTypeDashboardContent = testTypeDashboardContent.substring(testTypeDashboardContent.indexOf("tw-class=\"") + 10);
                  String twClass = testTypeDashboardContent.substring(0, testTypeDashboardContent.indexOf("\""));
                  // print(twClass);
                  if(twClass == "logger-panel") {
                    temp.type = 0;
                  }
                  else if(twClass == "logger-chart") {
                    temp.type = 1;
                    messDashboardContent = messDashboardContent.substring(messDashboardContent.indexOf("tw-class=\"") + 10);
                  }
                  else if(twClass == "alarm-panel") {
                    temp.type = 2;
                  }
                  else {
                    temp.type = -1;
                  }

                }
                else {
                  temp.type = -1;
                }

                if(temp.type == 0) {
                  if(messDashboardContent.indexOf("logger-id=\"") != -1) {
                    messDashboardContent = messDashboardContent.substring(messDashboardContent.indexOf("logger-id=\"") + 11);
                    String loggerID = messDashboardContent.substring(0, messDashboardContent.indexOf("\""));
                    // print(loggerID);
                    temp.loggerID = loggerID;
                  }
                  else {
                    temp.loggerID = "";
                  }

                  String reservedContent = messDashboardContent;

                  if(messDashboardContent.indexOf("logger-name=\"") != -1) {
                    messDashboardContent = messDashboardContent.substring(messDashboardContent.indexOf("logger-name=\"") + 13);
                    String loggerName = messDashboardContent.substring(0, messDashboardContent.indexOf("\""));
                    // print(loggerName);
                    temp.loggerName = loggerName;
                  }
                  else {
                    temp.loggerName = "";
                  }

                  if(messDashboardContent.indexOf("channel=\"") != -1) {
                    messDashboardContent = messDashboardContent.substring(messDashboardContent.indexOf("channel=\"") + 9);
                    String loggerName = messDashboardContent.substring(0, messDashboardContent.indexOf("\""));

                    temp.listElement = new List<DashboardElement>();
                    while(loggerName.indexOf("{") != -1) {
                      DashboardElement tempElement = new DashboardElement();
                      if(loggerName.indexOf("rawName:") != -1) {
                        loggerName = loggerName.substring(loggerName.indexOf("rawName:") + 8);
                        String rawName = loggerName.substring(0, loggerName.indexOf(","));
                        // print("Raw name: " + rawName);
                        tempElement.rawName = rawName;
                      }
                      else {
                        tempElement.rawName = "";
                      }

                      if(loggerName.indexOf("name:") != - 1) {
                        loggerName = loggerName.substring(loggerName.indexOf("name:") + 5);
                        String name = loggerName.substring(0, loggerName.indexOf(","));
                        // print("Name: " + name);
                        tempElement.name = name;
                      }
                      else {
                        tempElement.name = "";
                      }

                      if(loggerName.indexOf("unit:") != -1) {
                        loggerName = loggerName.substring(loggerName.indexOf("unit:") + 5);
                        String unit = loggerName.substring(0, loggerName.indexOf(","));
                        // print("Unit: " + unit);
                        tempElement.unit = unit;
                      }
                      else {
                        tempElement.unit = "";
                      }
                      temp.listElement.add(tempElement);

                    }
                    listDashboardContent.add(temp);
                  }
                  else if(reservedContent.indexOf("channel=\"") != -1) {
                    reservedContent = reservedContent.substring(reservedContent.indexOf("channel=\"") + 9);
                    String loggerName = reservedContent.substring(0, reservedContent.indexOf("\""));

                    temp.listElement = new List<DashboardElement>();
                    while(loggerName.indexOf("{") != -1) {
                      DashboardElement tempElement = new DashboardElement();
                      if(loggerName.indexOf("rawName:") != -1) {
                        loggerName = loggerName.substring(loggerName.indexOf("rawName:") + 8);
                        String rawName = loggerName.substring(0, loggerName.indexOf(","));
                        // print("Raw name: " + rawName);
                        tempElement.rawName = rawName;
                      }
                      else {
                        tempElement.rawName = "";
                      }

                      if(loggerName.indexOf("name:") != - 1) {
                        loggerName = loggerName.substring(loggerName.indexOf("name:") + 5);
                        String name = loggerName.substring(0, loggerName.indexOf(","));
                        // print("Name: " + name);
                        tempElement.name = name;
                      }
                      else {
                        tempElement.name = "";
                      }

                      if(loggerName.indexOf("unit:") != -1) {
                        loggerName = loggerName.substring(loggerName.indexOf("unit:") + 5);
                        String unit = loggerName.substring(0, loggerName.indexOf(","));
                        // print("Unit: " + unit);
                        tempElement.unit = unit;
                      }
                      else {
                        tempElement.unit = "";
                      }
                      temp.listElement.add(tempElement);

                    }
                    listDashboardContent.add(temp);
                  }
                }
                else if(temp.type == 1) {
                  if(messDashboardContent.indexOf("chart=\"") != -1) {
                    messDashboardContent = messDashboardContent.substring(messDashboardContent.indexOf("chart=\"") + 9);
                    String loggerName = messDashboardContent.substring(0, messDashboardContent.indexOf("\""));

                    temp.listElement = new List<DashboardElement>();
                    bool isGotID = false;
                    while(loggerName.indexOf("{") != -1) {
                      DashboardElement tempElement = new DashboardElement();

                      if(!isGotID) {
                        if(loggerName.indexOf("loggerId:") != -1) {
                          loggerName = loggerName.substring(loggerName.indexOf("loggerId:") + 9);
                          String id = loggerName.substring(0, loggerName.indexOf(","));
                          // print("Logger ID: " + id);
                          temp.loggerID = id;
                          isGotID = true;
                        }
                        else {
                          temp.loggerID = "";
                        }
                      }

                      if(loggerName.indexOf("rawName:") != -1) {
                        loggerName = loggerName.substring(loggerName.indexOf("rawName:") + 8);
                        String rawName = loggerName.substring(0, loggerName.indexOf(","));
                        // print("Raw name: " + rawName);
                        tempElement.rawName = rawName;
                      }
                      else {
                        tempElement.rawName = "";
                      }

                      if(loggerName.indexOf("name:") != - 1) {
                        loggerName = loggerName.substring(loggerName.indexOf("name:") + 5);
                        String name = loggerName.substring(0, loggerName.indexOf(","));
                        // print("Name: " + name);
                        tempElement.name = name;
                      }
                      else {
                        tempElement.name = "";
                      }

                      if(loggerName.indexOf("unit:") != -1) {
                        loggerName = loggerName.substring(loggerName.indexOf("unit:") + 5);
                        String unit = loggerName.substring(0, loggerName.indexOf(","));
                        // print("Unit: " + unit);
                        tempElement.unit = unit;
                      }
                      else {
                        tempElement.unit = "";
                      }
                      temp.listElement.add(tempElement);

                    }
                    listDashboardContent.add(temp);
                  }
                }
                else if(temp.type == 2) {
                  if(messDashboardContent.indexOf("alarm-class=\"") != -1) {
                    messDashboardContent = messDashboardContent.substring(messDashboardContent.indexOf("alarm-class=\"[") + 14);
                    String loggerAlarm = messDashboardContent.substring(0, messDashboardContent.indexOf("]\""));
                    // print(loggerID);
                    List<String> tempAlarm = loggerAlarm.split(",");
                    temp.listAlarm = tempAlarm;
                    listDashboardContent.add(temp);
                  }
                  else {
                    // temp.listAlarm.clear();
                  }
                }
              }

            });
          });
        }
      });
    }
    catch(e) {
      String a = e.toString();
    }
    return listDashboardContent;
  }

  void changeDashboard(String newDashboard) {
    setState(() {
      isLoadingDashboard = true;
      currentDashboard = newDashboard;
      listDashboard = decodeJsonDashboard(listDashboardModel.where((element) => element.name == newDashboard).first.content);
    });
    buildListDashboard();
  }

  void loadDashboard() {
    print("load dashboard");
    String temp = "";
    if(listDashboardModel.isNotEmpty) {
      try {
        setState(() {
          temp = listDashboardModel.where((element) => element.isActivated == true).first.name;
        });
      }
      catch(e) {
        setState(() {
          temp = listDashboardModel.elementAt(0).name;
        });
      }
    }
    if(temp == currentDashboard) {
      setDashboardChanged(preloadedListDashboardContent);
    }
    else {
      ///enable if want to reload dashboard
      // reloadDashboard();
    }
    // buildListDashboard();
  }

  void setDataChanged(String result, int currentIdx) {
    if(mounted) {
      setState(() {
        if(currentIdx == listSocket.length) {
          isCancel = true;
          listAlarmLogger.clear();
        }
      });

      int totalLogger = 0;
      double sumLat = 0;
      double sumLong = 0;

      if(result != null && result.trim() != "") {

        List<LoggerData> loggerList = new List<LoggerData>();

        List<dynamic> jsonResult = json.decode(result);
        jsonResult.forEach((logger) {
          Map<String, dynamic> mapLogger = Map<String, dynamic>.from(logger);
          LoggerData temp = new LoggerData();
          mapLogger.forEach((key, value) {

            if(key == "objName") {
              temp.objName = value;
            }
            else if(key == "listElement") {

              //temp.listElements
              List<dynamic> listElements = value;
              temp.listElements = new List<FieldLoggerData>();

              Map<String, int> maxTimestamp = Map<String, int>();
              Map<String, double> maxValue = Map<String, double>();
              String currentLoggerID = "";
              double currentValue = 0;

              listElements.forEach((element){
                Map<String, dynamic> mapElement = Map<String, dynamic>.from(element);
                if(mapElement["dataType"] == "TAGINFO") {
                  Map<String, dynamic> listValue = Map<String, dynamic>.from(mapElement["value"]);
                  LoggerPoint temp = new LoggerPoint();
                  temp.maLogger = listValue["loggerId"];
                  temp.tenLogger = listValue["name"];
                  temp.quanHuyen = listValue["districtId"].toString();
                  temp.diaChi = listValue["name"];
                  temp.dma = listValue["dma"];
                  temp.position = LatLng(listValue["lat"], listValue["lon"]);
                  listAddresses.add(temp);
                  totalLogger++;
                  sumLat+=listValue["lat"];
                  sumLong+=listValue["lon"];
                  currentLoggerID = listValue["loggerId"];
                }
                else if(mapElement["dataType"] == "DATASET" || mapElement["dataType"] == "QUERYSET") {
                  int tempMaxTimestamp = 0;
                  FieldLoggerData tempFieldData = new FieldLoggerData();
                  tempFieldData.fieldName = mapElement["name"];

                  //get map value
                  Map<String, String> listValue = Map<String, String>.from(mapElement["value"]);
                  Map<int, double> mapValue = new Map<int, double>();
                  listValue.forEach((key, value) {
                    if(int.parse(key) > tempMaxTimestamp) {
                      tempMaxTimestamp = int.parse(key);
                      currentValue = double.parse(value);
                    }
                    if(value != "null" && value.trim() != "") {
                      mapValue[int.parse(key)] = double.parse(value);
                    }
                    else {
                      mapValue[int.parse(key)] = 0;
                    }
                  });

                  if(tempMaxTimestamp != 0) {
                    maxTimestamp[mapElement["name"]] = tempMaxTimestamp;
                    maxValue[mapElement["name"]] = currentValue;
                  }

                  tempFieldData.value = mapValue;

                  temp.listElements.add(tempFieldData);
                }
                else if(mapElement["dataType"] == "ALARMSET") {
                  FieldLoggerData tempFieldLoggerData;
                  AlarmType tempAlarm = new AlarmType();
                  try {
                    tempFieldLoggerData = temp.listElements.where((element) => element.fieldName == mapElement["name"]).first;
                  }
                  catch(e) {
                    tempFieldLoggerData = null;
                  }

                  if(tempFieldLoggerData != null) {
                    temp.listElements.where((element) => element.fieldName == mapElement["name"]).first.alarm = new Map<int, String>();
                  }
                  List<dynamic> listValue = mapElement["value"];

                  listValue.forEach((value) {
                    Map<String, dynamic> mapValueElement = Map<String, dynamic>.from(value);

                    if(tempFieldLoggerData != null) {
                      temp.listElements.where((element) => element.fieldName == mapElement["name"]).first.alarm[mapValueElement["timestamp"]] = mapValueElement["classId"].toString();
                    }

                    if(maxTimestamp.containsKey(mapElement["name"]) && maxTimestamp.containsValue(mapValueElement["timestamp"])) {
                      AlarmLogger tempAlarmLogger = new AlarmLogger();
                      tempAlarmLogger.loggerID = currentLoggerID;
                      tempAlarmLogger.channel = mapElement["name"];
                      tempAlarmLogger.value = maxValue[mapElement["name"]];
                      tempAlarmLogger.timeStamp = mapValueElement["timestamp"];
                      tempAlarmLogger.alarmID = mapValueElement["classId"].toString();
                      tempAlarmLogger.status = mapValueElement["status"].toString();
                      tempAlarmLogger.className = mapValueElement["className"].toString();
                      tempAlarmLogger.comment = mapValueElement["comment"].toString();
                      listAlarmLogger.add(tempAlarmLogger);
                    }

                  });
                }
              });
            }
          });

          if(!loggerList.contains(temp)) {
            loggerList.add(temp);
          }
        });

        mapCenter = LatLng(sumLat/totalLogger, sumLong/totalLogger);

        setState(() {
          isGotData = true;
          resultString = result;

          loggerList.sort((a,b) => a.objName.compareTo(b.objName));

          loggerList.forEach((element) {
            if(!storedData.contains(element)) {
              storedData.add(element);
              mapReceiveGis[element.objName] = false;
            }
          });

          if(searchController == null || searchController.text.trim() == "") {
            loggerList.forEach((element) {
              if(!listData.contains(element)) {
                listData.add(element);
              }
            });
          }
          else {
            searchData(searchController.text);
          }
        });
        //change here
        print("current idx: " + currentIdx.toString());
        if(!isReceivedDashboardChart && currentIdx == listSocket.length){
          loadDashboard();
          isReceivedDashboardChart = true;
        }
      }
    }
  }

  void setChartChanged(String result, String loggerName, String channelName, int idx) {
    if(mounted && isReceivedChartQuery[idx] == false && mapNameChartQuery[idx] == loggerName) {
      setState(() {
        chartData.clear();
        isReceivedChartQuery[idx] = true;
      });
      // print("List elements");
      // print(result.toString());
      int tempMaxDateTime = -1;
      if(result != null && result.trim() != "") {
        List<dynamic> jsonResult = json.decode(result);

        jsonResult.forEach((jsonField) {
          Map<String, dynamic> mapElement = Map<String, dynamic>.from(jsonField);
          mapElement.forEach((key, value) {
            if(key == "listElement") {
              value.forEach((detail){
                Map<String, dynamic> mapField = Map<String, dynamic>.from(detail);
                mapField.forEach((key, value) {
                  if(key == "value") {

                    Map<String, String> mapValue = new Map<String, String>.from(value);
                    mapValue.forEach((key, value) {
                      try {
                        if(int.parse(key) > tempMaxDateTime) {
                          tempMaxDateTime = int.parse(key);
                        }
                      }
                      catch(e) {

                      }
                      try {
                        chartData[DateTime.fromMicrosecondsSinceEpoch(int.parse(key) * 1000)] = double.parse(value);
                      }
                      catch(e) {
                        chartData[DateTime.fromMicrosecondsSinceEpoch(int.parse(key) * 1000)] = 0;
                      }
                    });
                  }
                });

                lineChart = LineChart.fromDateTimeMaps([chartData], [Colors.green]);
                chartKey.currentState.setNewLineChart(lineChart);
                chartKey.currentState.setMaxDateTime(tempMaxDateTime);
                chartKey.currentState.setChartInfo(loggerName, channelName, !isReceivedChartDashboard.containsValue(false));
              });
            }
          });
        });

      }
    }
  }

  List<Widget> buildDashboardInfo(List<DashboardElement> listElements, String loggerID, String loggerName) {

    List<Widget> resultWidgets = new List<Widget>();
    if(listElements != null && listElements.length > 0) {
      listElements.forEach((element) {

        ChannelMeasure currentMeasure = new ChannelMeasure();
        try {
          currentMeasure = listChannelMeasure.where((measure) => measure.channelID == element.rawName).first;
        }
        catch(e) {
          currentMeasure = null;
        }

        Map<int,double> mapElement = new Map<int, double>();
        Map<int,String> mapAlarm;

        FieldLoggerData temp = new FieldLoggerData();

        try {
          temp = storedData.where((element) => element.objName == loggerID).first.listElements.where((fieldElement) => fieldElement.fieldName == element.rawName).first;
        }
        catch(e) {
          temp = null;
        }

        if(temp != null) {
          mapElement = temp.value;
          mapAlarm = temp.alarm;
        }


        AlarmType tempAlarmType;

        int maxKey = 0;
        mapElement.forEach((key, value) {
          if(key > maxKey) {
            maxKey = key;
          }
        });

        if(mapAlarm != null && mapAlarm[maxKey] != null) {
          try {
            // print(mapAlarm[maxKey]);
            tempAlarmType = listAlarmType.where((element) => element.id == mapAlarm[maxKey]).first;
          }
          catch(e) {
            tempAlarmType = null;
          }
        }

        resultWidgets.add(
            Container(
              margin: EdgeInsets.only(top: 3, bottom: 3),
              padding: EdgeInsets.only(top: 10, bottom: 10, left: 15, right: 15),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    currentMeasure != null ? currentMeasure.channelName : element.rawName,
                    style: Theme.of(context).textTheme.subtitle1.merge(
                        TextStyle(fontWeight: FontWeight.w400, color: (tempAlarmType != null &&
                            (tempAlarmType.id == '4' || tempAlarmType.id == '6' || tempAlarmType.id == '7')
                            ? Colors.white : Colors.black))
                    ),
                  ),
                  mapElement.isNotEmpty ? Text(
                    (mapElement[maxKey].toString().substring(mapElement[maxKey].toString().indexOf(".") + 1).length > 2 ?
                    mapElement[maxKey].toStringAsFixed(2) : mapElement[maxKey].toString()) + (element.unit != "null" ? " (" + element.unit + ")" : ""),
                    style: Theme.of(context).textTheme.subtitle1.merge(
                        TextStyle(fontWeight: FontWeight.w400, color: (tempAlarmType != null &&
                            (tempAlarmType.id == '4' || tempAlarmType.id == '5' || tempAlarmType.id == '6' || tempAlarmType.id == '7')
                            ? Colors.white : Colors.black))
                    ),
                  ) : Container(),
                ],
              ),
              decoration: BoxDecoration(
                  color: tempAlarmType != null ? Colour(tempAlarmType.color) : Colors.white,
                  borderRadius: const BorderRadius.all(Radius.circular(5))
              ),
            )
        );
      });
    }
    return resultWidgets;
  }

  Widget buildDashboardAlarm(AlarmLogger alarm) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Container(
        //   margin: EdgeInsets.only(top: 3, bottom: 3),
        //   padding: EdgeInsets.only(top: 10, bottom: 10, left: 15, right: 15),
        //   child: Row(
        //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
        //     children: [
        //       Text(
        //         "Class name: " + alarm.className,
        //         style: Theme.of(context).textTheme.subtitle1.merge(
        //             TextStyle(fontWeight: FontWeight.w400, color: Colors.black)
        //         ),
        //       ),
        //     ],
        //   ),
        //   decoration: BoxDecoration(
        //       color: Colors.white,
        //       borderRadius: const BorderRadius.all(Radius.circular(5))
        //   ),
        // ),
        Container(
          margin: EdgeInsets.only(top: 3, bottom: 3),
          padding: EdgeInsets.only(top: 10, bottom: 10, left: 15, right: 15),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                alarm.comment ?? "",
                style: Theme.of(context).textTheme.subtitle1.merge(
                    TextStyle(fontWeight: FontWeight.w400, color: Colors.black)
                ),
              ),
            ],
          ),
          decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: const BorderRadius.all(Radius.circular(5))
          ),
        ),
        Container(
          margin: EdgeInsets.only(top: 3, bottom: 3),
          padding: EdgeInsets.only(top: 10, bottom: 10, left: 15, right: 15),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Value: " + (alarm.value != null ? alarm.value.toString() : ""),
                style: Theme.of(context).textTheme.subtitle1.merge(
                    TextStyle(fontWeight: FontWeight.w400, color: Colors.black)
                ),
              ),
              Text(
                "Range: " + alarm.status ?? "",
                style: Theme.of(context).textTheme.subtitle1.merge(
                    TextStyle(fontWeight: FontWeight.w400, color: Colors.black)
                ),
              ),
            ],
          ),
          decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: const BorderRadius.all(Radius.circular(5))
          ),
        ),
      ],
    );
  }

  void setChartChanged_dashboard(String result, List<ChartDashboard> listChartDashboard, int idx) {
    if(mounted && isReceivedChartDashboard[idx] == false) {
      isReceivedChartDashboard[idx] = true;
      setState(() {
        listChartsWidgets.clear();
      });
      // print("List elements");
      // print(result.toString());
      if(result != null && result.trim() != "") {

        List<dynamic> jsonResult = json.decode(result);

        jsonResult.forEach((jsonField) {
          List<Map<DateTime, double>> listChartData = new List<Map<DateTime, double>>();
          Map<String, dynamic> mapElement = Map<String, dynamic>.from(jsonField);
          ChartDashboardValue temp = new ChartDashboardValue();
          mapElement.forEach((key, value) {
            temp.listChannels = new List<String>();

            if(key == "objName") {
              temp.loggerName = value;
            }
            else if(key == "listElement") {
              List<dynamic> listElements = value;
              listElements.forEach((detail) {
                Map<String, dynamic> mapField = Map<String, dynamic>.from(detail);
                mapField.forEach((key, value) {
                  if(key == "name") {
                    temp.listChannels.add(value);
                  }
                  else if(key == "value") {
                    Map<String, String> mapValue = new Map<String, String>.from(value);
                    Map<DateTime, double> chartData = new Map<DateTime, double>();
                    mapValue.forEach((key, value) {
                      try {
                        chartData[DateTime.fromMicrosecondsSinceEpoch(int.parse(key) * 1000)] = double.parse(value);
                      }
                      catch(e) {
                        chartData[DateTime.fromMicrosecondsSinceEpoch(int.parse(key) * 1000)] = 0;
                      }
                    });

                    listChartData.add(chartData);
                  }
                });
              });
            }

          });



          if(listChartData != null && listChartData.length > 0) {
            LineChart tempLineChart;

            List<MaterialColor> listColors = new List<MaterialColor>();

            for(int i = 0; i < listChartData.length; i++) {
              if(i % 2 == 0) {
                listColors.add(Colors.blue);
              }
              else {
                listColors.add(Colors.green);
              }
            }

            tempLineChart = LineChart.fromDateTimeMaps(listChartData, listColors);

            ChartDashboard findIdx;
            try {
              findIdx = listChartDashboard.where((element) => element.loggerName == temp.loggerName && element.listChannels.join(",") == temp.listChannels.join(",")).first;
            }
            catch(e) {
              findIdx = null;
            }

            setState(() {
              listChartsWidgets.add(
                  new Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        margin: EdgeInsets.only(top: 10, right: 25, left: 25),
                        padding: EdgeInsets.only(left: 10, right: 10, top: 5, bottom: 5),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(child: Text("Logger: " + temp.loggerName + ", Channel: " + temp.listChannels.join(", "), style: Theme.of(context).textTheme.subtitle1.merge(TextStyle(color: Colors.white)),),),
                          ],
                        ),
                        decoration: BoxDecoration(
                            color: Colour("#246EE9")
                        ),
                      ),
                      Container(
                          height: 200,
                          margin: EdgeInsets.only(top: 15, right: 25, left: 25),
                          child: listChartData == null || listChartData.isEmpty ? Container(
                            child: Center(
                                child: emptyData(Theme.of(context), "Không có dữ liệu được gửi về theo ngày đã tìm")
                            ),
                          ) : AnimatedLineChart(
                            tempLineChart,
                            key: UniqueKey(),
                          )
                      ),
                    ],
                  )
              );
              if(findIdx != null) {
                // print("Insert chart " + temp.loggerName + " at: " + findIdx.idx.toString());
                listDashboardWidgets.insert(
                  findIdx.idx
                  ,new Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          margin: EdgeInsets.only(top: 10, right: 25, left: 25),
                          padding: EdgeInsets.only(left: 10, right: 10, top: 5, bottom: 5),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(child: Text("Logger: " + temp.loggerName + ", Channel: " + temp.listChannels.join(", "), style: Theme.of(context).textTheme.subtitle1.merge(TextStyle(color: Colors.white)),),),
                            ],
                          ),
                          decoration: BoxDecoration(
                              color: Colour("#246EE9")
                          ),
                        ),
                        Container(
                            height: 200,
                            margin: EdgeInsets.only(top: 15, right: 25, left: 25),
                            child: listChartData == null || listChartData.isEmpty ? Container(
                              child: Center(
                                  child: emptyData(Theme.of(context), "Không có dữ liệu được gửi về theo ngày đã tìm")
                              ),
                            ) : AnimatedLineChart(
                              tempLineChart,
                              key: UniqueKey(),
                            )
                        ),
                      ],
                    )
                );
              }
              else {
                listDashboardWidgets.add(
                    new Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          margin: EdgeInsets.only(top: 10, right: 25, left: 25),
                          padding: EdgeInsets.only(left: 10, right: 10, top: 5, bottom: 5),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(child: Text("Logger: " + temp.loggerName + ", Channel: " + temp.listChannels.join(", "), style: Theme.of(context).textTheme.subtitle1.merge(TextStyle(color: Colors.white)),),),
                            ],
                          ),
                          decoration: BoxDecoration(
                              color: Colour("#246EE9")
                          ),
                        ),
                        Container(
                            height: 200,
                            margin: EdgeInsets.only(top: 15, right: 25, left: 25),
                            child: listChartData == null || listChartData.isEmpty ? Container(
                              child: Center(
                                  child: emptyData(Theme.of(context), "Không có dữ liệu được gửi về theo ngày đã tìm")
                              ),
                            ) : AnimatedLineChart(
                              tempLineChart,
                              key: UniqueKey(),
                            )
                        ),
                      ],
                    )
                );
              }
            });
          }
        });

      }
      setState(() {
        isLoadingDashboard = false;
      });

      isSendingQuery = false;
      isReceivedDashboardChart = false;
    }
  }

  void buildListDashboard() {
    List<ChartDashboard> listChartQuery = new List<ChartDashboard>();
    setState(() {
      listDashboardWidgets.clear();
      listLoggersWidgets.clear();
      listChartsWidgets.clear();
    });
    bool isHavingChart = false;
    int i = 0;
    int idx = 0;
    int listDashboardSize = listDashboard.length;

    listDashboard.forEach((element) {
      listDashboardSize--;
      LoggerData a;
      try {
        a = storedData.where((storedElement) => storedElement.objName == element.loggerID).first;
      }
      catch(e) {
        a = null;
      }

      if(a != null || element.type == 2) {
        if(element.type == 0) {
          setState(() {
            listDashboardWidgets.add(
                GestureDetector(
                  onTap: (){
                    Navigator.push(
                      context,
                      PageTransition(
                        type: PageTransitionType.rightToLeft,
                        child: LoggerDetail(storedData.where((storedElement) => storedElement.objName == element.loggerID).first),
                      ),
                    );
                  },
                  child: Container(
                    margin: i != 0 ? EdgeInsets.only(left: 25, right: 25, bottom: 15) : EdgeInsets.only(left: 25, right: 25, top: 15, bottom: 15),
                    padding: EdgeInsets.only(left: 20, right: 20, top: 15, bottom: 15),
                    child: Column (
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Container(
                          margin: EdgeInsets.only(bottom: 15, top: 5),
                          child: Text(element.loggerName + " (" + element.loggerID + ")", style: Theme.of(context).textTheme.headline1),
                        ),
                        // Container(
                        //   margin: EdgeInsets.only(top: 10, bottom: 10),
                        //   child: Text(, style: Theme.of(context).textTheme.subtitle1.merge(TextStyle(fontWeight: FontWeight.w400))),
                        // ),
                        Column(
                          children: buildDashboardInfo(element.listElement, element.loggerID, element.loggerName),
                        )
                      ],
                    ),
                    decoration: BoxDecoration(
                      // color: loggersList.elementAt(i).isAlarm ? Colour('#ECF2FF') : Colour('#ECF2FF'),
                        color: i%3 == 0 ? Colour('#ECF2FF') : (i%3 == 1 ? Colour('#F0ECE4') : Colour('C6D0DF')),
                        borderRadius: BorderRadius.all(Radius.circular(15)),
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
                )
            );
            listLoggersWidgets.add(
                GestureDetector(
                  onTap: (){
                    Navigator.push(
                      context,
                      PageTransition(
                        type: PageTransitionType.rightToLeft,
                        child: LoggerDetail(storedData.where((storedElement) => storedElement.objName == element.loggerID).first),
                      ),
                    );
                  },
                  child: Container(
                    margin: i != 0 ? EdgeInsets.only(left: 25, right: 25, bottom: 15) : EdgeInsets.only(left: 25, right: 25, top: 15, bottom: 15),
                    padding: EdgeInsets.only(left: 20, right: 20, top: 15, bottom: 15),
                    child: Column (
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Container(
                          margin: EdgeInsets.only(bottom: 15, top: 5),
                          child: Text(element.loggerName + " (" + element.loggerID + ")", style: Theme.of(context).textTheme.headline1),
                        ),
                        // Container(
                        //   margin: EdgeInsets.only(top: 10, bottom: 10),
                        //   child: Text(, style: Theme.of(context).textTheme.subtitle1.merge(TextStyle(fontWeight: FontWeight.w400))),
                        // ),
                        Column(
                          children: buildDashboardInfo(element.listElement, element.loggerID, element.loggerName),
                        )
                      ],
                    ),
                    decoration: BoxDecoration(
                      // color: loggersList.elementAt(i).isAlarm ? Colour('#ECF2FF') : Colour('#ECF2FF'),
                        color: i%3 == 0 ? Colour('#ECF2FF') : (i%3 == 1 ? Colour('#F0ECE4') : Colour('C6D0DF')),
                        borderRadius: BorderRadius.all(Radius.circular(15)),
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
                )
            );
          });
          i++;
          idx++;
        }
        else if (element.type == 1){
          isHavingChart = true;
          ChartDashboard temp = new ChartDashboard();
          temp.loggerName = element.loggerID;
          List<String> listChannels = new List<String>();
          element.listElement.forEach((channelElement) {
            listChannels.add(channelElement.rawName);
          });
          temp.listChannels = new List<String>();
          temp.listChannels = listChannels;
          temp.idx = idx;
          if(temp.loggerName != "" && temp.loggerName != null && temp.listChannels != null && temp.listChannels .length > 0){
            listChartQuery.add(temp);
            idx++;
          }
        }
        else if(element.type == 2) {

          listAlarmLogger.forEach((alarmLogger) {
            ChannelMeasure currentMeasure = new ChannelMeasure();
            try {
              currentMeasure = listChannelMeasure.where((measure) => measure.channelID == alarmLogger.channel).first;
            }
            catch(e) {
              currentMeasure = null;
            }

            if(element.listAlarm.contains(alarmLogger.alarmID)) {
              ///lay mau larm tuong ung
              AlarmType tempAlarmType;

              try {
                // print(mapAlarm[maxKey]);
                tempAlarmType = listAlarmType.where((element) => element.id == alarmLogger.alarmID).first;
              }
              catch(e) {
                tempAlarmType = null;
              }

              ///add logger to dashboard
              setState(() {
                listDashboardWidgets.add(
                    GestureDetector(
                      onTap: (){
                        Navigator.push(
                          context,
                          PageTransition(
                            type: PageTransitionType.rightToLeft,
                            child: LoggerDetail(storedData.where((storedElement) => storedElement.objName == alarmLogger.loggerID).first),
                          ),
                        );
                      },
                      child: Container(
                        margin: i != 0 ? EdgeInsets.only(left: 25, right: 25, bottom: 15) : EdgeInsets.only(left: 25, right: 25, top: 15, bottom: 15),
                        padding: EdgeInsets.only(left: 20, right: 20, top: 15, bottom: 15),
                        child: Column (
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Container(
                              margin: EdgeInsets.only(bottom: 5, top: 5),
                              child: Text(alarmLogger.loggerID + " (" + (currentMeasure != null ? currentMeasure.channelName : alarmLogger.channel) + ")", style: Theme.of(context).textTheme.headline1),
                            ),
                            Container(
                              margin: EdgeInsets.only(bottom: 15),
                              child: Text(getDateString1(alarmLogger.timeStamp)),
                            ),
                            buildDashboardAlarm(alarmLogger)
                          ],
                        ),
                        decoration: BoxDecoration(
                          border: Border.all(color: tempAlarmType != null ? Colour(tempAlarmType.color) : Colors.white, width: 5),
                            color: tempAlarmType != null ? Colour(tempAlarmType.color).withOpacity(0.5) : Colors.white,
                            borderRadius: BorderRadius.all(Radius.circular(15)),
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
                    )
                );
                listLoggersWidgets.add(
                    GestureDetector(
                      onTap: (){
                        Navigator.push(
                          context,
                          PageTransition(
                            type: PageTransitionType.rightToLeft,
                            child: LoggerDetail(storedData.where((storedElement) => storedElement.objName == alarmLogger.loggerID).first),
                          ),
                        );
                      },
                      child: Container(
                        margin: i != 0 ? EdgeInsets.only(left: 25, right: 25, bottom: 15) : EdgeInsets.only(left: 25, right: 25, top: 15, bottom: 15),
                        padding: EdgeInsets.only(left: 20, right: 20, top: 15, bottom: 15),
                        child: Column (
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Container(
                              margin: EdgeInsets.only(bottom: 15, top: 5),
                              child: Text(alarmLogger.loggerID + " (" + alarmLogger.channel??"" + ")", style: Theme.of(context).textTheme.headline1),
                            ),
                            buildDashboardAlarm(alarmLogger)
                          ],
                        ),
                        decoration: BoxDecoration(
                            color: tempAlarmType != null ? Colour(tempAlarmType.color) : Colors.white,
                            borderRadius: BorderRadius.all(Radius.circular(15)),
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
                    )
                );
              });
            }
          });
        }
      }
    });

    if(!isHavingChart) {
      print("nummber of logger in dashboard: " + listLoggersWidgets.length.toString());
      print("nummber of dashboard in dashboard: " + listDashboardWidgets.length.toString());
      print("no chart in dashboard");

      setState(() {
        isLoadingDashboard = false;

      });
    }
    else {
      print("there are charts in dashboard");
      if(!isSendingQuery) {
        isSendingQuery = true;
        int idx = 0;
        listSocket.forEach((element) {
          isReceivedChartDashboard[idx] = false;

          socketService.getDashboardDataChart(listChartQuery, setChartChanged_dashboard, element, idx);
          idx++;
        });
      }
    }
  }

  //Build Loggers Function

  List<Widget> buildDetailLogger(List<FieldLoggerData> listLoggerData, LoggerData logger) {
    List<Widget> resultWidget = new List<Widget>();
    int i = 0;
    listLoggerData.forEach((element) {
      ChannelMeasure currentMeasure = new ChannelMeasure();
      try {
        currentMeasure = listChannelMeasure.where((measure) => measure.channelID == element.fieldName).first;
      }
      catch(e) {
        currentMeasure = null;
      }
      if(i < 3) {
        resultWidget.add(
            new Expanded(child: GestureDetector(
                onTap: (){
                  //clicked once but trigger multiple time??
                  if(!flagChartClicked) {
                    chartKey.currentState.setDataChart(logger, element.fieldName);
                  }
                  setState(() {
                    flagChartClicked = true;
                  });
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.5)
                  ),
                  padding: EdgeInsets.only(top: 15, bottom: 5),
                  child: Text((currentMeasure != null ? currentMeasure.channelName : element.fieldName) + ": " +
                      (
                          (element.value != null && element.value.length > 0 ? (element.value.values.last.toString().substring(element.value.values.last.toString().indexOf(".") + 1).length > 2 ?
                          element.value.values.last.toStringAsFixed(2) : element.value.values.last.toString()) : "")
                          + (currentMeasure != null ? " (" + currentMeasure.unit + ")" : "")
                      ),
                    style: Theme.of(context).textTheme.subtitle1.merge(
                        TextStyle(
                          shadows: [Shadow(color: Colour("#246EE9"), offset: Offset(0,-5))],
                          decoration: TextDecoration.underline,
                          decorationColor: Colour("#246EE9"),
                          color: Colors.transparent,
                          fontSize: 12
                        )),
                  ),
                )
            ))
        );
      }
      i++;
    });
    return resultWidget;
  }

  List<Widget> buildListLoggers(List<LoggerData> loggersList) {
    List<Widget> resultWidgets = new List<Widget>();
    for(int i = 0; i < loggersList.length; i++) {

      String currentAddress = "";
      String currentName = "";
      String currentDMA = "";
      try {
        LoggerPoint tempAddress = listAddresses.where((element) => element.maLogger == loggersList.elementAt(i).objName).first;
        if(tempAddress != null) {
          if(tempAddress.dma != null && tempAddress.dma != "") {
            currentAddress = tempAddress.dma;
          }
          else {
            currentAddress = tempAddress.tenLogger;
          }

          if(tempAddress.tenLogger != null && tempAddress.tenLogger != "") {
            currentName = tempAddress.tenLogger;
          }
          else {
            currentName = "";
          }

          if(tempAddress.dma != null && tempAddress.dma != "") {
            currentDMA = tempAddress.dma;
          }
          else {
            currentDMA = "";
          }
        }
      }
      catch(e) {

      }

      resultWidgets.add(
          GestureDetector(
            onTap: (){
              Navigator.push(
                context,
                PageTransition(
                  type: PageTransitionType.rightToLeft,
                  child: LoggerDetail(loggersList.elementAt(i)),
                ),
              );
            },
            child: Container(
              margin: i == 0 ? EdgeInsets.only(left: 25, right: 25) : i != (loggersList.length - 1) ? EdgeInsets.only(left: 25, right: 25, top: 15) : EdgeInsets.only(left: 25, right: 25, top: 15, bottom: 15),
              padding: EdgeInsets.only(left: 20, right: 10, top: 20, bottom: 20),
              child: Column (
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(currentName.trim() == "" ? "Logger chưa có tên" : currentName, style: Theme.of(context).textTheme.headline1),
                  Container(
                    margin: EdgeInsets.only(top: 5, bottom: 5),
                    child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text("Logger ID: " + loggersList.elementAt(i).objName + (currentDMA != "" ? (", " + currentDMA) : ""), style: Theme.of(context).textTheme.subtitle2),
                              Icon(Icons.arrow_right_outlined, size: 30,)
                            ],
                          )
                  ),
                  Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: buildDetailLogger(loggersList.elementAt(i).listElements, loggersList.elementAt(i))
                  )
                ],
              ),
              decoration: BoxDecoration(
                // color: loggersList.elementAt(i).isAlarm ? Colour('#ECF2FF') : Colour('#ECF2FF'),
                  color: i%3 == 0 ? Colour('#ECF2FF') : (i%3 == 1 ? Colour('#F0ECE4') : Colour('C6D0DF')),
                  borderRadius: BorderRadius.all(Radius.circular(15)),
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
          )
      );
    }
    return resultWidgets;
  }

  List<Widget> buildListGroup() {
    List<Widget> resultWidgets = new List<Widget>();
    for(int i = 0; i < 4; i++) {
      resultWidgets.add(
          new Container(
            margin: EdgeInsets.only(right: 15),
            width: 100,
            height: 100,
            decoration: BoxDecoration(
                color: Colour('#D0D9FF'),
                borderRadius: BorderRadius.all(Radius.circular(20))
            ),
          )
      );
    }
    return resultWidgets;
  }

  //End Build Logger Function

  //End Logger Data Function

  //Map Functions
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

  void getAddresses() {
    socketService.getAddresses().then((result){
      if(result != null && result.trim() != "") {

        Map<String, dynamic> jsonResult = Map<String, dynamic>.from(json.decode(result));

        jsonResult.forEach((key, value) {
          // print(key);
          if(key == "features") {
            List<dynamic> listFeatures = value;
            listFeatures.forEach((element) {
              Map<String, dynamic> featureInfo = Map<String, dynamic>.from(element);

              LoggerPoint temp = new LoggerPoint();

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
                    else if(key == "DiaChi") {
                      temp.diaChi = value ?? "";
                    }
                  });

                }

              });

              if(!listAddresses.contains(temp)) {
                listAddresses.add(temp);
              }

            });


          }
        });
        setState(() {});
      }
    });
  }

  void getFeatures() {
    setState(() {
      listMarkers.clear();
    });
    print('getting features for map...');
    if(linkFeatureLayer != "") {
      socketService.getFeature().then((value){
        print('receive features');
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

          listLoggerPoints = new List<LoggerPoint>();

          Map<String, dynamic> jsonResult = Map<String, dynamic>.from(json.decode(result));

          jsonResult.forEach((key, value) {
            // print(key);
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
                      else if(key == "MaLogger") {
                        temp.maLogger = value.toString() ?? "";
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

                LoggerData tempLogger;

                try {
                  tempLogger = storedData.where((element) => element.objName == temp.maLogger).first;
                }
                catch(e) {
                  tempLogger = null;
                }

                if(tempLogger != null) {
                  tempLogger.listElements.forEach((element) {
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

                    AlarmType tempAlarmType = new AlarmType();
                    try {
                      tempAlarmType = listAlarmType.where((element) => element.id == mapAlarm[maxKey]).first;
                    }
                    catch(e) {
                      tempAlarmType = null;
                    }
                    if(tempAlarmType != null) {
                      temp.listAlarm.add(tempAlarmType);
                    }
                  });

                  if(temp.listAlarm != null && temp.listAlarm.length > 1) {
                    temp.listAlarm.sort((b,a) => a.id.compareTo(b.id));
                  }

                  Marker tempMarker = Marker(
                      anchorPos: AnchorPos.align(AnchorAlign.center),
                      width: isTatCa || (temp.listAlarm != null && temp.listAlarm.length > 0 && listPhuong.containsKey(temp.listAlarm.first.name) && listPhuong[temp.listAlarm.first.name] == true && temp.isFocused != true) ? 30 : 0,
                      height: isTatCa || (temp.listAlarm != null && temp.listAlarm.length > 0 && listPhuong.containsKey(temp.listAlarm.first.name) && listPhuong[temp.listAlarm.first.name] == true && temp.isFocused != true) ? 30 : 0,
                      point: LatLng(temp_y, temp_x),
                      builder: (ctx) =>
                      (!isTatCa && listPhuong.containsKey(temp.listAlarm.first.name) && listPhuong[temp.listAlarm.first.name] != true && temp.isFocused != true) ? Container() :
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
                                  color: temp.listAlarm != null && temp.listAlarm.length > 0 ? Colour(temp.listAlarm.elementAt(0).color) : Colors.blue),
                            )),
                            Positioned.fill(child: Align(
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

      List<LoggerPoint> tempList = new List<LoggerPoint>();
      mapReceiveGis.forEach((key, value) {
        if(value == false) {
          LoggerPoint temp = new LoggerPoint();
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
        listAddresses.forEach((element) {
          if(!tempList.contains(element)) {
            tempList.add(element);
            if(listLoggerPoints != null && !listLoggerPoints.contains(element)) {
              element.isFocused = false;
              listLoggerPoints.add(element);
            }
          }
        });

      });
      tempList.forEach((temp) {
        temp.isFocused = false;
        LoggerData tempLogger;

        try {
          tempLogger = storedData.where((element) => element.objName == temp.maLogger).first;
        }
        catch(e) {
          tempLogger = null;
        }

        if(tempLogger != null) {
          temp.listAlarm = new List<AlarmType>();
          tempLogger.listElements.forEach((element) {
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

            AlarmType tempAlarmType = new AlarmType();
            try {
              tempAlarmType = listAlarmType.where((element) => element.id == mapAlarm[maxKey]).first;
            }
            catch(e) {
              tempAlarmType = null;
            }
            if(tempAlarmType != null) {
              temp.listAlarm.add(tempAlarmType);
            }
          });

          if(temp.listAlarm != null && temp.listAlarm.length > 1) {
            temp.listAlarm.sort((b,a) => a.id.compareTo(b.id));
          }

          Marker tempMarker = Marker(
              anchorPos: AnchorPos.align(AnchorAlign.center),
              width: isTatCa || (temp.listAlarm != null && temp.listAlarm.length > 0 && listPhuong.containsKey(temp.listAlarm.first.name) && listPhuong[temp.listAlarm.first.name] == true && temp.isFocused != true) ? 30 : 0,
              height: isTatCa || (temp.listAlarm != null && temp.listAlarm.length > 0 && listPhuong.containsKey(temp.listAlarm.first.name) && listPhuong[temp.listAlarm.first.name] == true && temp.isFocused != true) ? 30 : 0,
              point: LatLng(temp.position.latitude, temp.position.longitude),
              builder: (ctx) =>
              (!isTatCa && temp.listAlarm != null && temp.listAlarm.length > 0 && listPhuong.containsKey(temp.listAlarm.first.name) && listPhuong[temp.listAlarm.first.name] != true && temp.isFocused != true) ? Container() :
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
                          color: temp.listAlarm != null && temp.listAlarm.length > 0 ? Colour(temp.listAlarm.elementAt(0).color) : Colors.blue),
                    )),
                    Positioned.fill(child: Align(
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


      });

      tempList.sort((a,b) => a.tenLogger.compareTo(b.tenLogger));
      setState(() {
        isInitMap = true;
        isLoadingMap = false;
      });
    }
  }

  void inversePhuong(bool isChecked) {
    if(viewMenu == 1) {
      listPhuong.forEach((key, value) {
        listPhuong[key] = isChecked;
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

                    globalMapController.move(listLoggerPoints.elementAt(i).position, globalMapController.zoom);
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
                    inversePhuong(isChecked);
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
                inversePhuong(isTatCa);
                getFeatures();
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
        )
    );

    return Align(
      alignment: Alignment.bottomCenter,
      child: Container(
        padding: EdgeInsets.only(left: 5, right: 5),
        height: (70 * ((listItem.length / 3).ceil())).toDouble(),
        width: double.infinity,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              margin: EdgeInsets.only(top: 10, bottom: 10),
              child: Text("Lọc cảnh báo", style: Theme.of(context).textTheme.headline1,),
            ),
            GridView.count(
              physics: NeverScrollableScrollPhysics(), // to disable GridView's scrolling
              shrinkWrap: true,
              childAspectRatio: 3,
              crossAxisCount: 3,
              mainAxisSpacing: 0.0,
              children: listItem,
            ),
          ],
        ),
        decoration: BoxDecoration(
            color: Colors.white
        ),
      ),
    );
  }

  Widget DetailPanel(List<Widget> listItem) {
    return Align(
      alignment: Alignment.topRight,
      child: Container(
        padding: viewMenu != 1 ? EdgeInsets.only(left: 15, right: 15) : EdgeInsets.only(left: 5, right: 5),
        height: double.infinity,
        width: viewMenu != 1 ? MediaQuery.of(context).size.width/2 : 150,
        child: Column(
          mainAxisSize: MainAxisSize.max,
          children: [
            Container(
              margin: EdgeInsets.only(top: 10, bottom: 10),
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
                        inversePhuong(isChecked);
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
                    inversePhuong(isTatCa);
                    getFeatures();
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
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                margin: EdgeInsets.only(bottom: 15),
                child: Text(item.tenLogger, style: Theme.of(context).textTheme.headline2,),
              ),
              Row(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        margin: EdgeInsets.only(bottom: 10),
                        child: Text("Địa chỉ: " + (item.diaChi == null || item.diaChi.trim() == "" ? "Chưa có" : item.diaChi.trim()),
                          style: Theme.of(context).textTheme.subtitle1.merge(TextStyle(fontWeight: FontWeight.w400)),),
                      ),
                      Container(
                        margin: EdgeInsets.only(bottom: 10),
                        child: Text("DMA: " + (item.dma == null || item.dma.trim() == "" ? "Chưa có" : item.dma.trim()),
                          style: Theme.of(context).textTheme.subtitle1.merge(TextStyle(fontWeight: FontWeight.w400)),),
                      ),
                      Container(
                        margin: EdgeInsets.only(bottom: 10),
                        child: Text("Quận huyện: " + (item.quanHuyen == null || item.quanHuyen.trim() == "" ? "Chưa có" : item.quanHuyen.trim()),
                          style: Theme.of(context).textTheme.subtitle1.merge(TextStyle(fontWeight: FontWeight.w400)),),
                      ),
                      // Container(
                      //   margin: EdgeInsets.only(bottom: 10),
                      //   child: Text("Áp lực: " + item.pressure.toString(),
                      //     style: Theme.of(context).textTheme.subtitle1.merge(TextStyle(fontWeight: FontWeight.w400)),),
                      // ),
                      Container(
                        margin: EdgeInsets.only(bottom: 0),
                        child: Text("Mục đích sử dụng: " + (item.mucDichSuDung == null || item.mucDichSuDung.trim() == "" ? "Chưa có" : item.mucDichSuDung.trim()),
                          style: Theme.of(context).textTheme.subtitle1.merge(TextStyle(fontWeight: FontWeight.w400)),),
                      ),
                    ],
                  ),
                  Expanded(child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      GestureDetector(
                        onTap: (){
                          globalMapController.move(currentPoint.position, 15);
                        },
                        child: Container(
                          padding: EdgeInsets.all(10),
                          child: Icon(Icons.search, color: Colors.white,),
                          decoration: BoxDecoration(
                              color: Colour('#246EE9'),
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
                                child: LoggerDetail(storedData.where((storedElement) => storedElement.objName == item.maLogger).first),
                              ),
                            );
                          }
                          else {
                            showAlertDialog(context, "Không thể xem dữ liệu logger", "Dữ liệu của logger này chưa được cập nhật về hệ thống, vui lòng thử lại sau");
                          }
                        },
                        child: Container(
                          margin: EdgeInsets.only(top: 15),
                          padding: EdgeInsets.all(10),
                          child: Icon(Icons.bar_chart, color: Colors.white,),
                          decoration: BoxDecoration(
                              color: Colour('#246EE9'),
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
                  ))
                ],
              ),
            ],
          ),
          decoration: BoxDecoration(
              color: Colors.white
          ),
        )
    ) : Container();
  }

  void initPhuong() {
    for(int i = 0; i < listAlarmType.length; i++) {
      if(!listPhuong.containsKey(listAlarmType.elementAt(i).name)) {
        listPhuong[listAlarmType.elementAt(i).name] = true;
      }
    }
  }

  void recenterMap() {

    globalMapController.move((mapCenter != LatLng(0,0) ? mapCenter : LatLng(10.428053, 106.829196)), 10);
    clearFocusLogger();

  }

  List<Widget> VisibilityLogger() {
    List<Widget> resultWidget = new List<Widget>();

    listPhuong.forEach((key, value) {
      resultWidget.add(
          new Container(
            child: Row(
              children: [
                Checkbox(value: listPhuong[key], onChanged: (isChecked){
                  setState(() {
                    listPhuong[key] = isChecked;
                    recenterMap();
                  });
                  getFeatures();
                }),
                GestureDetector(
                  onTap: (){
                    setState(() {
                      listPhuong[key] = !listPhuong[key];
                      recenterMap();
                    });
                    getFeatures();
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
            ),
          )
      );
    });

    return resultWidget;
  }

  List<Widget> ListLayer() {
    List<Widget> resultWidget = new List<Widget>();
    mapLayerVisible.forEach((key, value) {
      resultWidget.add(
        Row(
          children: [
            Checkbox(
              value: value,
              // onChanged: (isChecked){
              //   setState(() {
              //     mapLayerVisible[key] = isChecked;
              //   });
              // }
            ),
            Text(key)
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
  //End Map Functions

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onTap: (){
          FocusManager.instance.primaryFocus?.unfocus();
        },
        child: DefaultTabController(
          length: 3,
          child: Scaffold(
              backgroundColor: Colors.white,
              appBar: AppBar(
                title: Text("Monitor", style: TextStyle(color: Colour("#051639")),),
                centerTitle: true,
                backgroundColor: Colors.white,
                elevation: 0,
                leading: IconButton(
                    onPressed: (){
                      Navigator.of(context).pop();
                    },
                    icon: Icon(Icons.arrow_back, color: Colour("#051639"),)
                ),
                actions: [
                  tabIdx == 2 ? IconButton(
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
                      icon: Icon(Icons.filter_alt, color: Colour("#051639"),)
                  ) : Container()
                ],
                bottom: TabBar(
                  physics: tabIdx == 2 ? NeverScrollableScrollPhysics() : AlwaysScrollableScrollPhysics(),
                  controller: tabController,
                  isScrollable: true,
                  tabs: [
                    Tab(icon: Text("Dashboard", style: Theme.of(context).textTheme.subtitle1,)),
                    Tab(icon: Text("Datatable", style: Theme.of(context).textTheme.subtitle1,)),
                    Tab(icon: Text("Map", style: Theme.of(context).textTheme.subtitle1,)),
                  ],
                ),

              ),
              //searchBar
              body: TabBarView(
                physics: tabIdx == 2 ? NeverScrollableScrollPhysics() : AlwaysScrollableScrollPhysics(),
                controller: tabController,
                children: myTabWidget(),
              )
          ),
        )
    );
  }

  List<Widget> myTabWidget()
  {
    List<Widget> resultWidget = new List<Widget>();

    resultWidget.add(
        Container(
          child: isLoadingDashboard ? loading(Theme.of(context), "dashboard")
              : isErrorDashboard ? loadError(reloadDashboard, Theme.of(context), 1, "dashboard")
              : Column(
            children: [
              Container(
                padding: EdgeInsets.all(10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    MyDropDown(
                      listOptions: listDashboardModel.map((e) => e.name).toList(),
                      currentValue: currentDashboard,
                      onChangedFunction: changeDashboard,
                      isExpand: false,
                      customMargin: 15,
                    ),
                    Container(
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Checkbox(value: isDashboardLogger, onChanged: (value){
                            setState(() {
                              isDashboardLogger = value;
                            });
                          }),
                          GestureDetector(
                            onTap: (){
                              setState(() {
                                isDashboardLogger = !isDashboardLogger;
                              });
                            },
                            child: Text("Xem logger"),
                          )
                        ],
                      ),
                    ),
                    Container(
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Checkbox(value: isDashboardChart, onChanged: (value){
                            setState(() {
                              isDashboardChart = value;
                            });
                          }),
                          GestureDetector(
                            onTap: (){
                              setState(() {
                                isDashboardChart = !isDashboardChart;
                              });
                            },
                            child: Text("Xem chart"),
                          )
                        ],
                      ),
                    )
                  ],
                ),
              ),
              Container(
                height: 1,
                width: double.infinity,
                color: Colors.black26,
              ),
              Expanded(child:
                listDashboard.isNotEmpty && (listDashboardWidgets.isNotEmpty || listLoggersWidgets.isNotEmpty) ? ListView(
                  key: UniqueKey(),
                  children: (isDashboardLogger && isDashboardChart) ? (listDashboardWidgets.isNotEmpty ? listDashboardWidgets : listLoggersWidgets) : (isDashboardLogger ? listLoggersWidgets : listChartsWidgets),
                ) :
                loadError(reloadDashboard, Theme.of(context), 1, "dashboard")
              )
            ],
          ),
        )
    );

    resultWidget.add(
        isNoInternet ? loadError(retrySocketIO, Theme.of(context), 0, "") : isGotData == true ? Container(
          width: double.infinity,
          height: double.infinity,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                  margin: EdgeInsets.only(top: 20),
                  child: Container(
                    margin: EdgeInsets.only(left: 20, right: 20),
                    child: TextFormField(
                      controller: searchController,
                      autovalidateMode: AutovalidateMode.disabled,
                      onChanged: (text){
                        searchData(text);
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
                        hintText: "Nhập thông tin logger cần tìm", hintStyle: TextStyle(fontSize: 16, fontWeight: FontWeight.w400),
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
                  )
              ),
              ChannelChart(isLoadingData, lineChart, chartData, currentChannel, currentChannel, setChartChanged, storedData),
              Container(
                  margin: EdgeInsets.only(left: 25, right: 25, bottom: 20, top: 15),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("Danh sách logger", style: Theme.of(context).textTheme.headline2,),
                      // GestureDetector(
                      //   onTap: (){
                      //
                      //   },
                      //   child: Image.asset("assets/filter.png", scale: 1,),
                      // )
                    ],
                  )
              ),
              Expanded(child: ListView(
                children: buildListLoggers(listData),
              ))
            ],
          ),
        ) : isError ? loadError(retrySocketIO, Theme.of(context), 1, "logger") : loading(Theme.of(context), "logger")
    );

    resultWidget.add(
        isInitMap && !isLoadingMap ? Stack(
          children: [
            Container(
              margin: EdgeInsets.only(top: 80),
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
                          // IconButton(
                          //     onPressed: (){
                          //       Navigator.of(context).pop();
                          //     },
                          //     icon: Icon(Icons.arrow_back, color: Colour("#051639"),)
                          // ),
                          Expanded(
                              child: Container(
                                margin: EdgeInsets.only(left: 15, right: 0),
                                child: searchBar(),
                              )
                          ),
                          // IconButton(
                          //     onPressed: (){
                          //       if(!isInitPhuong) {
                          //         initPhuong();
                          //         isInitPhuong = true;
                          //       }
                          //
                          //       setState(() {
                          //         if(viewMenu != 1) {
                          //           viewMenu = 1;
                          //           isViewMenu = true;
                          //         }
                          //         else {
                          //           isViewMenu = !isViewMenu;
                          //         }
                          //         isSearch = false;
                          //         FocusManager.instance.primaryFocus?.unfocus();
                          //       });
                          //     },
                          //     icon: Icon(Icons.visibility, color: Colour("#051639"),)
                          // ),
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
                                margin: EdgeInsets.only(left: 15, right: 0),
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
                                margin: EdgeInsets.only(left: 15, right: 15),
                                child: Icon(Icons.list, color: Colour("#051639")),
                              ),
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
                    (isViewMenu ? (viewMenu != 1 ? DetailPanel(viewMenu == 0 ? ListLogger() : ListLayer()) : FilterPanel(VisibilityLogger())) : Container()),
                  ],
                ))
              ],
            ),
          ],
        ) : Container(
          child: Center(
            child: Container(
              width: 50,
              height: 50,
              child: CircularProgressIndicator(),
            ),
          ),
        )
    );

    return resultWidget;
  }

}
