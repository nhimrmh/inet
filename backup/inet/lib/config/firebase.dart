import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:overlay_support/overlay_support.dart';

import '../main.dart';
import '../models/push_notification.dart';
import 'config.dart';

Future _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  print("Handling a background message: ${message.messageId}");
  print(message.notification?.title);
  print(message.notification?.body);
}

checkForInitialMessage() async {
  await Firebase.initializeApp();
  RemoteMessage initialMessage =
  await FirebaseMessaging.instance.getInitialMessage();

  if (initialMessage != null) {
    PushNotification notification = PushNotification(
      title: initialMessage.notification?.title,
      body: initialMessage.notification?.body,
    );
    print("Initial message:");
    print(initialMessage.notification?.title);
    print(initialMessage.notification?.body);
  }
}

void registerNotification(String username) async {
  // 1. Initialize the Firebase app
  await Firebase.initializeApp();

  // 2. Instantiate Firebase Messaging
  messaging = FirebaseMessaging.instance;

  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);


  // 3. On iOS, this helps to take the user permissions
  NotificationSettings settings = await messaging.requestPermission(
    alert: true,
    badge: true,
    provisional: false,
    sound: true,
  );

  if (settings.authorizationStatus == AuthorizationStatus.authorized) {
    print('User granted permission');
    // TODO: handle the received notifications
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      // Parse the message received
      PushNotification notification = PushNotification(
        title: message.notification?.title,
        body: message.notification?.body,
      );

      print(message.notification?.title);
      print(message.notification?.body);

      showSimpleNotification(
        Container(
          margin: EdgeInsets.only(bottom: 10),
          child: Text(message.notification?.title ?? "", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),),
        ),
        leading: Icon(Icons.notifications),
        subtitle: Text(message.notification?.body ?? ""),
        background: Colors.blue,
        duration: Duration(seconds: 5),
        contentPadding: EdgeInsets.all(20)
      );

    });

    // For handling notification when the app is in background
    // but not terminated
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      PushNotification notification = PushNotification(
        title: message.notification?.title,
        body: message.notification?.body,
      );
      print(message.notification?.title);
      print(message.notification?.body);
    });
  } else {
    print('User declined or has not accepted permission');
  }

  messaging.getToken().then((value) {
    print('your token: ' + value);
    if(value.isNotEmpty) {
      socketService.addtoken(username, value);
    }
  });
}