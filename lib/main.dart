import 'dart:async';
import 'dart:ui';

import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter/material.dart';
import 'package:imt_ev/homepage.dart';

Future<void> main() async {
  // Initialize the Awesome Notifications package
  await AwesomeNotifications().initialize(
      'resource://drawable/res_app_icon',
      [
        NotificationChannel(
            channelKey: 'basic_channel',
            channelName: 'Basic notifications',
            channelDescription: 'Notification channel for basic tests',
            defaultColor: Color(0xFF9D50DD),
            ledColor: Colors.white)
      ],
      debug: true);

  // Periodically check the server
  await Timer.periodic(const Duration(seconds: 5),
      (Timer t) => NotificationController.checkServer());

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  static final GlobalKey<NavigatorState> navigatorKey =
      GlobalKey<NavigatorState>();

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
    // Request permission to send notifications
    AwesomeNotifications().requestPermissionToSendNotifications();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Notification App',
      navigatorKey: MyApp.navigatorKey,
      home: const MyHomePage(),
    );
  }
}
