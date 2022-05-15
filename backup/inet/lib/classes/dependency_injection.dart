import 'package:flutter_simple_dependency_injection/injector.dart';
import 'package:inet/classes/socket_service.dart';

class DependencyInjection {
  Injector initialise(Injector injector) {
    injector.map<SocketService>((i) => SocketService(), isSingleton: true);
    return injector;
  }
}