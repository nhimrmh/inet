import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:inet/classes/auth.dart';
import 'package:inet/classes/valid_check.dart';
import 'package:http/http.dart' as http;
import 'package:inet/config/config.dart';
import 'package:inet/views/login_view.dart';

import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'login_test.mocks.dart';

@GenerateMocks([http.Client])
void main() {
  group('valid test', (){
    testWidgets('Test login empty data', (WidgetTester tester) async {
      // Build our app and trigger a frame.
      var result = checkEmpty('');
      expect(result, 'Vui lòng nhập');

    });

    testWidgets('Test login valid data', (WidgetTester tester) async {
      // Build our app and trigger a frame.
      var result = checkEmpty('demo');
      expect(result, null);
    });
  });

  group('preferences test', (){
    testWidgets('Test save username in preferences', (WidgetTester tester) async {
      Auth authentication = Auth();
      authentication.setUsername("demo");
      authentication.getUsername().then((value) {
        expect(value, "demo");
      });
    });

    testWidgets('Test save password in preferences', (WidgetTester tester) async {
      Auth authentication = Auth();
      authentication.setPassword("123");
      authentication.getPassword().then((value) {
        expect(value, "123");
      });
    });

    testWidgets('Test save server in preferences', (WidgetTester tester) async {
      Auth authentication = Auth();
      authentication.setServer("1.1.1.1", "8080", "test");
      authentication.getServer().then((value) {
        expect(value, "1.1.1.1:8080+test-");
      });

      authentication.setServer("1.2.3.4", "8081", "test 1");
      authentication.getServer().then((value) {
        expect(value, "1.1.1.1:8080+test-1.2.3.4:8081+test 1-");
      });

      authentication.setServer("1.2.3.4", "8081", "test 2");
      authentication.getServer().then((value) {
        expect(value, "1.1.1.1:8080+test-1.2.3.4:8081+test 1-1.2.3.4:8081+test 2-");
      });

    });

    testWidgets('Test delete server in preferences', (WidgetTester tester) async {
      Auth authentication = Auth();
      authentication.setServer("1.1.1.1", "8080", "test");
      authentication.setServer("1.2.3.4", "8081", "test 1");
      authentication.setServer("1.2.3.4", "8081", "test 2");
      authentication.getServer().then((value) {
        expect(value, "1.1.1.1:8080+test-1.2.3.4:8081+test 1-1.2.3.4:8081+test 2-");
      });

      authentication.deleteServer("1.2.3.4:8081+test 1-").then((_) {
        authentication.getServer().then((value) {
          expect(value, "1.1.1.1:8080+test-1.2.3.4:8081+test 2-");
        });
      });

      authentication.deleteServer("1.1.1.1:8080+test-").then((_) {
        authentication.getServer().then((value) {
          expect(value, "1.2.3.4:8081+test 2-");
        });
      });

      authentication.deleteServer("1.2.3.4:8081+test 2-").then((_) {
        authentication.getServer().then((value) {
          expect(value, "");
        });
      });
    });

    testWidgets('Test get current server in preferences', (WidgetTester tester) async {
      Auth authentication = Auth();
      authentication.setCurrentServer("test 2");
      authentication.getCurrentServer().then((value) {
        expect(value, "test 2");
      });
    });

    testWidgets('Test clear data in preferences', (WidgetTester tester) async {
      Auth authentication = Auth();
      authentication.setUsername("demo");
      authentication.setPassword("123");
      authentication.getUsername().then((value) {
        expect(value, "demo");
      });
      authentication.getPassword().then((value) {
        expect(value, "123");
      });
      authentication.clearSavedData();
      authentication.getUsername().then((value) {
        expect(value, "");
      });
      authentication.getPassword().then((value) {
        expect(value, "");
      });
    });

    testWidgets('Test change server', (WidgetTester tester) async {
      Auth authentication = Auth();
      authentication.setCurrentServer("test 2");
      authentication.getCurrentServer().then((value) {
        expect(value, "test 2");
      });
    });
  });

  group('http test', (){
    testWidgets('Test login timeout', (WidgetTester tester) async {
      await tester.pumpWidget(MaterialApp(home: LoginPage(key: loginKey,),));

      final client = MockClient();

      // Use Mockito to return a successful response when it calls the
      // provided http.Client.
      when(client
          .get(Uri.parse('http://test.com/session/getView?username=demo&password=123')))
          .thenAnswer((_) async =>
          http.Response("timeout", 408));
      
      final response = await client.get(Uri.parse('http://test.com/session/getView?username=demo&password=123'));

      expect( loginKey.currentState.getDashboardData(response.body), 'timeout');
    });

    testWidgets('Test login failed', (WidgetTester tester) async {
      await tester.pumpWidget(MaterialApp(home: LoginPage(key: loginKey,),));

      final client = MockClient();

      // Use Mockito to return a successful response when it calls the
      // provided http.Client.
      when(client
          .get(Uri.parse('http://test.com/session/getView?username=demo&password=123')))
          .thenAnswer((_) async =>
          http.Response("", 500));

      final response = await client.get(Uri.parse('http://test.com/session/getView?username=demo&password=123'));

      expect( loginKey.currentState.getDashboardData(response.body), '');
    });

  });
}