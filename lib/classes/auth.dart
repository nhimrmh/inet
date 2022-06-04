import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class Auth {
  FlutterSecureStorage storage;
  Auth() {
    storage = const FlutterSecureStorage(); // 1
  }

  Future<void> deleteServer(String name) async {
    await storage.read(key: "inetServer").then((value){
      print(value);
      if(value.contains(name)) {
        value = value.replaceAll(name, "");
      }
      print(value);
      storage.write(key: "inetServer", value: value); // 3
      return;
    }); //
  }

  Future<void> setServer(String ip, String port, String name) async {
    await storage.read(key: "inetServer").then((value){
      print(value);
      storage.write(key: "inetServer", value: (value ?? "") + ip + ":" + port + "+" + name + "-"); // 3
      storage.write(key: "inetCurrentServer", value: name); // 3
      return;
    }); // 2
  }

  void setCurrentServer(String value) async {
    await storage.write(key: "inetCurrentServer", value: value); // 3
  }

  Future<String> getCurrentServer() async { // 1
    return await storage.read(key: "inetCurrentServer"); // 2
  }

  Future<String> getServer() async { // 1
    return await storage.read(key: "inetServer"); // 2
    }

  void setPassword(String password) { // 1
    storage.write(key: "inetPassword", value: password); // 3
  }

  Future<String> getPassword() async { // 1
    return await storage.read(key: "inetPassword"); // 2
  }

  void setUsername(String password) { // 1
    storage.write(key: "inetUsername", value: password); // 3
  }

  Future<String> getUsername() async { // 1
    return await storage.read(key: "inetUsername"); // 2
  }

  void clearSavedData() {
    storage.write(key: "inetPassword", value: ""); //
    storage.write(key: "inetUsername", value: ""); // 3// 3
  }
}