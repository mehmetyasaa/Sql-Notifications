import 'package:http/http.dart' as http;
import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:convert';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("IMT Event Viewer"),
      ),
      body: Center(
        child: TextButton(
          onPressed: NotificationController.checkServer,
          child: const Text("bildirim"),
        ),
      ),
    );
  }
}

class NotificationController {
  static void triggerNotification() {
    AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: 10,
        channelKey: 'basic_channel',
        title: 'Uygulama Duraklatıldı',
        body: 'IMT veri gönderilemedi',
      ),
    );
  }

  static Future<void> checkServer() async {
    final url = Uri.parse('http://localhost:3000/imt');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data[0]["somekey"] != 0) {
        triggerNotification();
      }
    }
  }
}
