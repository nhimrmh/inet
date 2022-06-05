import 'dart:async';
import 'dart:convert';

import 'package:colour/colour.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:page_transition/page_transition.dart';
import '../classes/auth.dart';
import '../classes/valid_check.dart';
import '../config/config.dart';
import '../data/dashboard_data.dart';
import '../main.dart';
import '../models/alarm_type.dart';
import '../models/channel_measure.dart';
import '../models/dashboard_content.dart';
import '../models/dashboard_model.dart';
import '../widgets/button.dart';
import '../widgets/dropdown.dart';
import '../widgets/edittext.dart';
import '../widgets/empty.dart';
import '../widgets/loading.dart';
import 'package:flutter_map_arcgis/layers/feature_layer_options.dart' as arcgis;

import 'menu_view.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return LoginState();
  }
}

class LoginState extends State<LoginPage> {
  final Connectivity _connectivity = Connectivity();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final GlobalKey<FormState> _addServerFormKey = GlobalKey<FormState>();

  StreamSubscription<ConnectivityResult> _connectivitySubscription;

  bool isNoInternet = false; ///check internet variable
  bool isLoading = true;
  bool isSuccess = false;
  bool isFail = false;
  bool isTimeout = false;
  bool isRemember = false;
  bool isCancel = false;

  Auth authentication;
  String savedUsername = "";
  String savedPassword = "";

  final Map<String, String> _listServer = <String, String>{};

  bool _isManagingServer = false;
  bool _isAddingServer = false;

  TextEditingController usernameController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _ipController = TextEditingController();
  final TextEditingController _portController = TextEditingController();

  @override
  void initState() {
    super.initState();
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent
    ));

    initAuth();

    getSavedData();

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
          ),
          //searchBar
          body: Stack(
            children: [
              Container(
                  padding: const EdgeInsets.only(left: 20, right: 20),
                  child: Center(
                    child: isLoading ? loadingDangNhap(Theme.of(context))
                        : isSuccess ? success(Theme.of(context), "Đăng nhập thành công")
                        : SizedBox(
                        height: MediaQuery.of(context).size.height,
                        child: ListView(
                          children: [
                            Form(
                              key: _formKey,
                              child: Column(
                              children: [
                                Center(
                                  child: Container(
                                    margin: const EdgeInsets.only(bottom: 50, top: 50),
                                    width: 100,
                                    height: 100,
                                    child: Image.asset("assets/logo.png"),
                                  ),
                                ),
                                Container(
                                    margin: const EdgeInsets.only(left: 20, right: 20, bottom: 20),
                                    child: _listServer.length > 1 ? MyDropDown(
                                      listOptions: _listServer.entries.where((element) => element.key.isNotEmpty && element.value.isNotEmpty).map((e) => e.key).toList(),
                                      currentValue: currentServerName,
                                      onChangedFunction: changeServer,
                                      isExpand: true,
                                      customMargin: 15,
                                    ) : Container(
                                      width: double.infinity,
                                      padding: const EdgeInsets.all(10),
                                      child: Text("Hiện chưa có server, vui lòng thêm mới", style: TextStyle(color: Colors.red[700]), textAlign: TextAlign.center,),
                                      decoration: BoxDecoration(
                                          border: Border.all(color: Colors.black26, width: 1),
                                          borderRadius: const BorderRadius.all(Radius.circular(10))
                                      ),
                                    )
                                ),
                                (isFail || isTimeout) ? Container(
                                  margin: const EdgeInsets.only(bottom: 20),
                                  child: Text(isTimeout ? "Không thể kết nối đến máy chủ" : "Tên đăng nhập hoặc mật khẩu không chính xác", style: Theme.of(context).textTheme.subtitle2.merge(TextStyle(color: Colors.red[700])),),
                                ) : Container(),
                                Container(
                                  margin: const EdgeInsets.only(left: 20, right: 20),
                                  child: TextFormField(
                                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w400),
                                    controller: usernameController,
                                    autovalidateMode: AutovalidateMode.disabled,
                                    autocorrect: false,
                                    onChanged: (text){
                                      setState(() {});
                                    },
                                    decoration: InputDecoration(
                                      filled: true,
                                      fillColor: Colour('#F8FAFF'),
                                      contentPadding: const EdgeInsets.only(top: 6, bottom: 6, left: 15, right: 15),
                                      prefixIcon: Icon(Icons.account_circle, color: usernameController.text.isEmpty ? Colour('#666D75') : Colors.green, size: 20,),
                                      hintText: "Tên đăng nhập", hintStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w400),
                                      enabledBorder: OutlineInputBorder(
                                          borderRadius: const BorderRadius.all(Radius.circular(20)),
                                          borderSide: BorderSide(
                                              color: Colour('#D1DBEE'),
                                              width: 1
                                          )
                                      ),
                                      border: OutlineInputBorder(
                                          borderRadius: const BorderRadius.all(Radius.circular(20)),
                                          borderSide: BorderSide(
                                              color: Colour('#D1DBEE'),
                                              width: 1
                                          )
                                      ),

                                    ),
                                    validator: checkEmpty,
                                  ),
                                ),
                                Container(
                                    margin: const EdgeInsets.only(top: 20),
                                    child: Container(
                                      margin: const EdgeInsets.only(left: 20, right: 20),
                                      child: TextFormField(
                                        obscureText: true,
                                        controller: passwordController,
                                        autovalidateMode: AutovalidateMode.disabled,
                                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w400),
                                        onChanged: (text){
                                          setState(() {});
                                        },
                                        validator: checkEmpty,
                                        decoration: InputDecoration(
                                          filled: true,
                                          fillColor: Colour('#F8FAFF'),
                                          labelStyle: const TextStyle(fontSize: 50),
                                          contentPadding: const EdgeInsets.only(top: 6, bottom: 6, left: 15, right: 15),
                                          prefixIcon: Icon(Icons.lock, color: passwordController.text.isEmpty ? Colour('#666D75') : Colors.green, size: 20,),
                                          hintText: "Mật khẩu", hintStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w400),
                                          enabledBorder: OutlineInputBorder(
                                              borderRadius: const BorderRadius.all(Radius.circular(20)),
                                              borderSide: BorderSide(
                                                  color: Colour('#D1DBEE'),
                                                  width: 1
                                              )
                                          ),
                                          border: OutlineInputBorder(
                                              borderRadius: const BorderRadius.all(Radius.circular(20)),
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
                                  margin: const EdgeInsets.only(left: 15, top: 10),
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
                                              style: Theme.of(context).textTheme.subtitle1.merge(const TextStyle(fontWeight: FontWeight.w400)),
                                            ),
                                          )
                                      )
                                    ],
                                  ),
                                ),
                                GestureDetector(
                                  onTap: () {
                                    if(_formKey.currentState.validate()) {
                                      tryLogin(usernameController.text.toString().trim(), passwordController.text.toString());
                                    }
                                  },
                                  child: Container(
                                    width: MediaQuery.of(context).size.width/2,
                                    margin: const EdgeInsets.only(top: 10),
                                    padding: const EdgeInsets.only(left: 15, right: 20, top: 10, bottom: 10),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        const Icon(Icons.login, color: Colors.white,),
                                        Expanded(child: Container(
                                          margin: const EdgeInsets.only(left: 15),
                                          child: Text("Đăng nhập", style: Theme.of(context).textTheme.subtitle1.merge(const TextStyle(color: Colors.white)), textAlign: TextAlign.center, overflow: TextOverflow.ellipsis,),
                                        ))
                                      ],
                                    ),
                                    decoration: const BoxDecoration(
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
                                    margin: const EdgeInsets.only(top: 10, bottom: 10),
                                    child: const Text("hoặc", style: TextStyle(fontStyle: FontStyle.italic),)
                                ),
                                GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      _isManagingServer = true;
                                    });
                                  },
                                  child: Container(
                                    width: MediaQuery.of(context).size.width/2,
                                    padding: const EdgeInsets.only(left: 15, right: 20, top: 10, bottom: 10),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        const Icon(Icons.edit, color: Colors.white,),
                                        Expanded(child: Container(
                                          margin: const EdgeInsets.only(left: 10),
                                          child: Text("Quản lý server", style: Theme.of(context).textTheme.subtitle1.merge(const TextStyle(color: Colors.white)), textAlign: TextAlign.center, overflow: TextOverflow.ellipsis,),
                                        ))
                                      ],
                                    ),
                                    decoration: BoxDecoration(
                                        color: Colour('#89A1FF'),
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
                  margin: const EdgeInsets.all(15),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    child: Form(
                      key: _addServerFormKey,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Icon(Icons.close, color: Colors.transparent, size: 20,),
                              Text(_isAddingServer ? "Thêm Server mới" : "Danh sách Server", style: const TextStyle(fontSize: 16),),
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
                                  child: const Icon(Icons.close, color: Colors.black, size: 20,)
                              ),
                            ],
                          ),
                          !_isAddingServer ? Container(
                            margin: const EdgeInsets.only(top: 15),
                            width: 120,
                            padding: const EdgeInsets.only(left: 8, right: 15, top: 5, bottom: 5),
                            child: Row(
                              children: [
                                Container(
                                  margin: const EdgeInsets.only(right: 5),
                                  child: const Icon(Icons.add, color: Colors.white, size: 20,),
                                ),
                                Expanded(child: GestureDetector(
                                  onTap: (){
                                    setState(() {
                                      _isAddingServer = true;
                                    });
                                  },
                                  child: const Text("Thêm mới", style: TextStyle(fontSize: 14, color: Colors.white, fontWeight: FontWeight.bold), textAlign: TextAlign.center, overflow: TextOverflow.ellipsis,),
                                ))
                              ],
                            ),
                            decoration: const BoxDecoration(
                                color: Colors.green,
                                borderRadius: BorderRadius.all(Radius.circular(5))
                            ),
                          ) : Container(),
                          !_isAddingServer ? Container(
                              height: 300,
                              margin: _listServer.length > 1 ? const EdgeInsets.only(top: 30) : const EdgeInsets.only(top: 0),
                              child: _listServer.length > 1 ? ListView(
                                children: _buildListServer(),
                              ) : Center(
                                child: EmptyWidget(title: "server"),
                              )
                          ) : Container(),
                          _isAddingServer ? Column(
                            children: [
                              Container(
                                margin: const EdgeInsets.only(top: 30),
                                child: MyTextEdittingController(
                                  icon: Icons.edit,
                                  description: "Tên server",
                                  title: "Tên server",
                                  controller: _nameController,
                                  textInputType: TextInputType.text,
                                  validator: checkEmpty,
                                  onChangedFunction: (){
                                    setState(() {

                                    });
                                  },
                                ),
                              ),
                              Container(
                                margin: const EdgeInsets.only(top: 15),
                                child: MyTextEdittingController(
                                  icon: Icons.work,
                                  description: "VD: 103.163.214.64",
                                  title: "Địa chỉ IP",
                                  controller: _ipController,
                                  textInputType: TextInputType.number,
                                  validator: checkEmpty,
                                  onChangedFunction: (){
                                    setState(() {

                                    });
                                  },
                                ),
                              ),
                              Container(
                                margin: const EdgeInsets.only(top: 15),
                                child: MyTextEdittingController(
                                  icon: Icons.padding,
                                  description: "VD: 8081",
                                  title: "Port",
                                  controller: _portController,
                                  textInputType: TextInputType.number,
                                  validator: checkEmpty,
                                  onChangedFunction: (){
                                    setState(() {

                                    });
                                  },
                                ),
                              ),
                              Container(
                                  margin: const EdgeInsets.only(top: 30, left: 30, right: 30),
                                  child: MyIconButton(
                                      icon: Icons.check,
                                      color: Colors.green,
                                      title: "Thêm mới",
                                      clickedFunction: (){
                                        if(_addServerFormKey.currentState.validate()) {
                                          authentication.setServer(_ipController.text, _portController.text, _nameController.text).then((value){
                                            loadServer(newServer: _ipController.text + ":" + _portController.text, newServerName: _nameController.text).then((value){
                                              setState(() {
                                                _isAddingServer = false;
                                              });
                                            });
                                          });
                                        }
                                      }
                                  )
                              )
                            ],
                          ) : Container()
                        ],
                      )
                    ),
                    decoration: const BoxDecoration(
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
      currentServer = _listServer.entries.where((element) => element.key == newServer).first?.value ?? "";
      currentServerName = newServer;
      authentication.setCurrentServer(newServer);
    });
  }

  void deleteServer(String value) {
    String getIp = "";
    try {
      getIp = _listServer.entries.where((element) => element.key == value).first?.value;
    }
    catch(e) {
      getIp = "";
    }

    setState(() {
      if(currentServerName == value) {
        if(_listServer.length > 2) {
          String newName = "";
          String newIp = "";

          try {
            MapEntry<String, String> firstServer = _listServer.entries.where((element) => element.key.isNotEmpty && element.key != value).first;
            newName = firstServer.key;
            newIp = firstServer.value;
          }
          catch(e) {
            newName = "";
            newIp = "";
          }

          if(newName.isNotEmpty && newIp.isNotEmpty) {
            currentServer = newIp;
            authentication.setCurrentServer(newName);
            currentServerName = newName;
          }
        }
        else {
          currentServer = "";
          authentication.setCurrentServer("");
          currentServerName = "";
        }
      }
      _listServer.remove(value);
    });

    if(getIp.isNotEmpty) {
      authentication.deleteServer("$getIp+$value-");
    }


  }

  Future<void> loadServer({String newServer, String newServerName}) async {
    setState(() {
      _listServer.clear();
      _listServer[""] = "";
    });
    await authentication.getServer().then((value){
      if(value != null && value.isNotEmpty) {
        List<String> tempServer = value.split("-");
        int count = 1;
        for (var element in tempServer) {
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
        }
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
      currentServer = _listServer.entries.where((element) => element.key == newServerName).first?.value ?? "";

    }
  }

  List<Widget> _buildListServer() {
    List<Widget> resultWidget = [];
    _listServer.forEach((key, value) {
      if(key.isNotEmpty && value.isNotEmpty) {
        resultWidget.add(
            Container(
                margin: const EdgeInsets.only(top: 10),
                height: 40,
                decoration: BoxDecoration(
                    color: Colors.blueGrey[100].withOpacity(0.75)
                ),
                child: Row(
                  children: [
                    Checkbox(value: key == currentServerName, onChanged: (isCheck){
                      if(isCheck) {
                        setState(() {
                          currentServer = value;
                          authentication.setCurrentServer(key);
                          currentServerName = key;
                        });
                      }
                    }),
                    Expanded(child: GestureDetector(
                        onTap: (){
                          setState(() {
                            currentServer = value;
                            authentication.setCurrentServer(key);
                            currentServerName = key;

                          });
                        },
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(child: Text(key),),
                            key != "Server mặc định" ? IconButton(
                                onPressed: (){
                                  deleteServer(key);
                                },
                                icon: const Icon(Icons.delete, color: Colors.red,)
                            ) : Container()
                          ],
                        )
                    ))
                  ],
                )
            )
        );
      }
    });

    return resultWidget;
  }

  void initAuth() {
    authentication = Auth();
  }

  void getSavedData() async {
    await authentication.getUsername().then((value){
      savedUsername = value;
    });
    await authentication.getPassword().then((value){
      savedPassword = value;
    });

    authentication.getCurrentServer().then((value){
      loadServer(newServerName: value).then((value) => loginWithSavedData());
    });
  }

  void loginWithSavedData() {
    if(savedUsername != null && savedPassword != null && savedUsername != "" && savedPassword != "") {
      usernameController.text = savedUsername;
      passwordController.text = savedPassword;
      isRemember = true;
      tryLogin(savedUsername, savedPassword);
    }
    else {
      clearState();
    }
  }

  void tryLogin(String username, String password){
    if(username.trim() != "" && password.trim() != "") {
      setLoading();

      Future.delayed(const Duration(seconds: 10), (){
        if(mounted && !isCancel) {
          setTimeOut();
        }
      });

      socketService.getView(username, password).then((value){
        if(value != null && value.trim() == "timeout") {
          setTimeOut();
        }
        else if(value != null && value.trim() != "")
        {
          setCancel();

          getConfigSettings(value);
          getDashboardData(value);

          if(isRemember) {
            authentication.setUsername(username);
            authentication.setPassword(password);
          }

          setSuccess();

          username_config = username;

          Future.delayed(const Duration(seconds: 1), (){
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
          setFail();
        }

      });
    }
    else {
      clearState();
    }
  }

  void getConfigSettings(String value) {
    listChannelSelect.clear();
    listChannelMeasure.clear();
    listAlarmType.clear();

    List<dynamic> jsonResult = json.decode(value);
    bool isChannelSelect = false;
    bool isChannelSelectForMap = false;
    bool isChannelMeasure = false;
    for (var field in jsonResult) {
      Map<String, dynamic> mapField = Map<String, dynamic>.from(field);
      mapField.forEach((key, value) {
        if(key == "name" && value == "login-viewer") {
          isChannelMeasure = true;
        }
        else if(key == "name" && value == "datatable-viewer") {
          isChannelSelect = true;
        }
        else if(key == "name" && value == "arcgis-map-viewer") {
          isChannelSelectForMap = true;
        }
      });
      if(isChannelMeasure) {
        List<dynamic> listScreenElement = mapField["listScreenElement"];
        for (var screenElement in listScreenElement) {
          Map<String, dynamic> mapScreenElement = Map<String, dynamic>.from(screenElement);
          mapScreenElement.forEach((key, value) {
            if(key == "listTagInElement") {
              List<dynamic> listTagInElement = value;
              for (var tagElement in listTagInElement) {
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
                                if(!ioConnector.contains(value)) {
                                  ioConnector.add(value);
                                }

                              }
                              else if(key == "authority") {
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
              }
            }
            else if(key == "listSpecProp") {
              List<dynamic> listSpecProp = value;
              for (var specProp in listSpecProp) {
                Map<String, dynamic> mapSpecProp = Map<String, dynamic>.from(specProp);
                bool isDashboardProperties = false;
                bool isAlarmProperties = false;
                bool isFeatureLayerProperties = false;
                mapSpecProp.forEach((key, value) {
                  if(key == "properties") {
                    Map<String, dynamic> mapProperty = Map<String, dynamic>.from(value);
                    ChannelMeasure temp = ChannelMeasure();
                    AlarmType tempAlarm = AlarmType();
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
              }
            }
          });
        }

      }
      else if(isChannelSelect) {
        List<dynamic> listScreenElement = mapField["listScreenElement"];
        for (var screenElement in listScreenElement) {
          Map<String, dynamic> mapScreenElement = Map<String, dynamic>.from(screenElement);
          mapScreenElement.forEach((key, value) {
            if(key == "listSpecProp") {
              List<dynamic> listSpecProp = value;
              for (var specProp in listSpecProp) {
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
                        String tempListChannelSelects = value.toString();
                        tempListChannelSelects.replaceAll("[", "");
                        tempListChannelSelects.replaceAll("]", "");
                        listChannelSelect.addAll(tempListChannelSelects.split(",").map((e) => e.trim()).toList());
                      }
                    });
                    isDashboardProperties = false;
                  }
                });
              }
            }
          });
        }
      }
      else if(isChannelSelectForMap) {
        List<dynamic> listScreenElement = mapField["listScreenElement"];
        for (var screenElement in listScreenElement) {
          Map<String, dynamic> mapScreenElement = Map<String, dynamic>.from(screenElement);
          bool isLinePlaceholder = false;
          mapScreenElement.forEach((key, value) {
            if(key == "objId" && value == "line-placeholder") {
              isLinePlaceholder = true;
            }
            if(key == "listSpecProp" && isLinePlaceholder) {
              List<dynamic> listSpecProp = value;
              for (var specProp in listSpecProp) {
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
                        String tempListChannelSelects = value.toString();
                        tempListChannelSelects.replaceAll("[", "");
                        tempListChannelSelects.replaceAll("]", "");
                        listChannelSelectForMap.addAll(tempListChannelSelects.split(",").map((e) => e.trim()).toList());
                      }
                    });
                    isDashboardProperties = false;
                  }
                });
              }
            }
          });
        }
      }
      isChannelMeasure = false;
      isChannelSelect = false;
      isChannelSelectForMap = false;
    }
  }

  String getDashboardData(String value) {
    if(value != null && value.trim() != "" && value.trim() != "timeout")
    {
      setState(() {
        listDashboardModel.clear();
      });

      List<DashboardContent> listDashboardContent = List<DashboardContent>();
      List<dynamic> jsonResult = json.decode(value);
      bool isDashboardContent = false;
      for (var field in jsonResult) {
        Map<String, dynamic> mapField = Map<String, dynamic>.from(field);
        mapField.forEach((key, value) {
          if(key == "name" && value == "dashboard-viewer") {
            isDashboardContent = true;
          }
        });
        if(isDashboardContent) {
          List<dynamic> listScreenElement = mapField["listScreenElement"];
          for (var screenElement in listScreenElement) {
            Map<String, dynamic> mapScreenElement = Map<String, dynamic>.from(screenElement);
            mapScreenElement.forEach((key, value) {
              if(key == "listSpecProp") {
                List<dynamic> listSpecProp = value;
                for (var specProp in listSpecProp) {
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
                            DashboardModel tempDashbordModel = DashboardModel();
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
                                      for (var element in listChildren) {
                                        Map<String, dynamic> mapChildren = Map<String, dynamic>.from(element);
                                        mapChildren.forEach((key, value) {
                                          if(key == "content") {

                                            if(tempDashbordModel.isActivated == true) {
                                              DashboardContent temp = DashboardContent();

                                              int maxCurrentIdx = 0;

                                              String messDashboardContent = value;
                                              String testTypeDashboardContent = value;

                                              if(testTypeDashboardContent.contains("tw-class=\"")) {
                                                testTypeDashboardContent = testTypeDashboardContent.substring(testTypeDashboardContent.indexOf("tw-class=\"") + 10);
                                                String twClass = testTypeDashboardContent.substring(0, testTypeDashboardContent.indexOf("\""));
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
                                                else if(twClass == "channel-pie") {
                                                  temp.type = 3;
                                                }
                                                else {
                                                  temp.type = -1;
                                                }

                                              }
                                              else {
                                                temp.type = -1;
                                              }

                                              if(temp.type == 0) {
                                                if(messDashboardContent.contains("logger-id=\"")) {
                                                  messDashboardContent = messDashboardContent.substring(messDashboardContent.indexOf("logger-id=\"") + 11);
                                                  String loggerID = messDashboardContent.substring(0, messDashboardContent.indexOf("\""));
                                                  temp.loggerID = loggerID;
                                                }
                                                else {
                                                  temp.loggerID = "";
                                                }

                                                String reservedContent = messDashboardContent;

                                                if(messDashboardContent.contains("logger-name=\"")) {
                                                  messDashboardContent = messDashboardContent.substring(messDashboardContent.indexOf("logger-name=\"") + 13);
                                                  String loggerName = messDashboardContent.substring(0, messDashboardContent.indexOf("\""));
                                                  temp.loggerName = loggerName;
                                                }
                                                else {
                                                  temp.loggerName = "";
                                                }

                                                if(messDashboardContent.contains("channel=\"")) {
                                                  messDashboardContent = messDashboardContent.substring(messDashboardContent.indexOf("channel=\"") + 9);
                                                  String loggerName = messDashboardContent.substring(0, messDashboardContent.indexOf("\""));

                                                  temp.listElement = List<DashboardElement>();
                                                  while(loggerName.contains("{")) {
                                                    DashboardElement tempElement = DashboardElement();
                                                    if(loggerName.contains("rawName:")) {
                                                      loggerName = loggerName.substring(loggerName.indexOf("rawName:") + 8);
                                                      String rawName = loggerName.substring(0, loggerName.indexOf(","));
                                                      tempElement.rawName = rawName;
                                                    }
                                                    else {
                                                      tempElement.rawName = "";
                                                    }

                                                    if(loggerName.contains("name:")) {
                                                      loggerName = loggerName.substring(loggerName.indexOf("name:") + 5);
                                                      String name = loggerName.substring(0, loggerName.indexOf(","));
                                                      tempElement.name = name;
                                                    }
                                                    else {
                                                      tempElement.name = "";
                                                    }

                                                    if(loggerName.contains("unit:")) {
                                                      loggerName = loggerName.substring(loggerName.indexOf("unit:") + 5);
                                                      String unit = loggerName.substring(0, loggerName.indexOf(","));
                                                      tempElement.unit = unit;
                                                    }
                                                    else {
                                                      tempElement.unit = "";
                                                    }
                                                    temp.listElement.add(tempElement);

                                                  }
                                                  listDashboardContent.add(temp);
                                                }
                                                else if(reservedContent.contains("channel=\"")) {
                                                  reservedContent = reservedContent.substring(reservedContent.indexOf("channel=\"") + 9);
                                                  String loggerName = reservedContent.substring(0, reservedContent.indexOf("\""));

                                                  temp.listElement = List<DashboardElement>();
                                                  while(loggerName.contains("{")) {
                                                    DashboardElement tempElement = DashboardElement();
                                                    if(loggerName.contains("rawName:")) {
                                                      loggerName = loggerName.substring(loggerName.indexOf("rawName:") + 8);
                                                      String rawName = loggerName.substring(0, loggerName.indexOf(","));
                                                      tempElement.rawName = rawName;
                                                    }
                                                    else {
                                                      tempElement.rawName = "";
                                                    }

                                                    if(loggerName.contains("name:")) {
                                                      loggerName = loggerName.substring(loggerName.indexOf("name:") + 5);
                                                      String name = loggerName.substring(0, loggerName.indexOf(","));
                                                      tempElement.name = name;
                                                    }
                                                    else {
                                                      tempElement.name = "";
                                                    }

                                                    if(loggerName.contains("unit:")) {
                                                      loggerName = loggerName.substring(loggerName.indexOf("unit:") + 5);
                                                      String unit = loggerName.substring(0, loggerName.indexOf(","));
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
                                                if(messDashboardContent.contains("chart=\"")) {
                                                  messDashboardContent = messDashboardContent.substring(messDashboardContent.indexOf("chart=\"") + 9);
                                                  String loggerName = messDashboardContent.substring(0, messDashboardContent.indexOf("\""));

                                                  temp.listElement = List<DashboardElement>();

                                                  while(loggerName.contains("{")) {
                                                    DashboardElement tempElement = DashboardElement();

                                                    if(loggerName.contains("loggerId:")) {
                                                      loggerName = loggerName.substring(loggerName.indexOf("loggerId:") + 9);
                                                      String id = loggerName.substring(0, loggerName.indexOf(","));
                                                      tempElement.loggerID = id;
                                                    }
                                                    else {
                                                      temp.loggerID = "";
                                                    }

                                                    if(loggerName.contains("rawName:")) {
                                                      loggerName = loggerName.substring(loggerName.indexOf("rawName:") + 8);
                                                      String rawName = loggerName.substring(0, loggerName.indexOf(","));
                                                      tempElement.rawName = rawName;
                                                    }
                                                    else {
                                                      tempElement.rawName = "";
                                                    }

                                                    if(loggerName.contains("name:")) {
                                                      loggerName = loggerName.substring(loggerName.indexOf("name:") + 5);
                                                      String name = loggerName.substring(0, loggerName.indexOf(","));
                                                      tempElement.name = name;
                                                    }
                                                    else {
                                                      tempElement.name = "";
                                                    }

                                                    if(loggerName.contains("unit:")) {
                                                      loggerName = loggerName.substring(loggerName.indexOf("unit:") + 5);
                                                      String unit = loggerName.substring(0, loggerName.indexOf(","));
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
                                                if(messDashboardContent.contains("alarm-class=\"")) {
                                                  messDashboardContent = messDashboardContent.substring(messDashboardContent.indexOf("alarm-class=\"[") + 14);
                                                  String loggerID = messDashboardContent.substring(0, messDashboardContent.indexOf("]\""));
                                                  if(loggerID.isNotEmpty && loggerID.contains(",")) {
                                                    temp.listAlarm = loggerID.split(",");
                                                  }
                                                }
                                                else {
                                                  temp.listAlarm = null;
                                                }
                                                listDashboardContent.add(temp);
                                              }
                                              else if(temp.type == 3) {
                                                if(messDashboardContent.contains("logger-id=\"")) {
                                                  messDashboardContent = messDashboardContent.substring(messDashboardContent.indexOf("logger-id=\"[") + 12);
                                                  String loggerID = messDashboardContent.substring(0, messDashboardContent.indexOf("]\""));
                                                  if(loggerID.isNotEmpty && loggerID.contains(",")) {
                                                    temp.listLoggerId = loggerID.split(",");
                                                  }
                                                  else if(loggerID.isNotEmpty) {
                                                    temp.listLoggerId.add(loggerID);
                                                  }

                                                  if(messDashboardContent.contains("rawName:")) {
                                                    String rawName = messDashboardContent.substring(messDashboardContent.indexOf("rawName:") + 8);
                                                    String channel = rawName.substring(0, rawName.indexOf(","));
                                                    temp.channel = channel;
                                                  }
                                                  else {
                                                    temp.channel = "";
                                                  }
                                                }
                                                else {
                                                  temp.listLoggerId = null;
                                                }
                                                listDashboardContent.add(temp);
                                              }
                                            }
                                          }
                                          if(!listDashboardModel.map((e) => e.name).toList().contains(tempDashbordModel.name)) {
                                            listDashboardModel.add(tempDashbordModel);
                                          }
                                        });
                                      }
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
                }
              }
            });
          }

        }
        isDashboardContent = false;
      }
      preloadedListDashboardContent = listDashboardContent;
      if(listDashboardModel.isNotEmpty) {
        try {
          currentDashboard = listDashboardModel.where((element) => element.isActivated == true).first.name;
        }
        catch(e) {
          currentDashboard = listDashboardModel.elementAt(0).name;
        }
      }

      return "got data";
    }
    else {
      setState(() {
        preloadedGotDashboardData = false;
      });
      return value;
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

  void clearState() {
    setState(() {
      isLoading = false;
      isFail = false;
      isSuccess = false;
      isTimeout = false;
    });
  }

  void setLoading() {
    setState(() {
      isLoading = true;
    });
  }

  void setSuccess() {
    setState(() {
      isLoading = false;
      isSuccess = true;
      isFail = false;
      isTimeout = false;
    });
  }

  void setFail() {
    setState(() {
      isLoading = false;
      isFail = true;
      isSuccess = false;
      isTimeout = false;
    });
  }

  void setCancel() {
    setState(() {
      isCancel = true;
    });
  }

  void setTimeOut() {
    setState(() {
      isLoading = false;
      isFail = false;
      isSuccess = false;
      isTimeout = true;
    });
  }
}