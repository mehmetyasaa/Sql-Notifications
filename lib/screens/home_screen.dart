// import 'dart:async';
// import 'dart:convert';
// import 'dart:isolate';
// import 'dart:ui';

// import 'package:awesome_notifications/awesome_notifications.dart';
// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;

// Future<void> main() async {
//   WidgetsFlutterBinding.ensureInitialized();

//   // Always initialize Awesome Notifications
//   await NotificationController.initializeLocalNotifications();
//   await NotificationController.initializeIsolateReceivePort();
//   runApp(const MyApp());

//   // Start the periodic task
//   Timer.periodic(const Duration(minutes: 1),
//       (Timer t) => NotificationController.checkServer());
// }

// class NotificationController {
//   static ReceivedAction? initialAction;

//   static Future<void> initializeLocalNotifications() async {
//     await AwesomeNotifications().initialize(
//         null, 
//         [
//           NotificationChannel(
//               channelKey: 'alerts',
//               channelName: 'Alerts',
//               channelDescription: 'Notification tests as alerts',
//               playSound: true,
//               onlyAlertOnce: true,
//               groupAlertBehavior: GroupAlertBehavior.Children,
//               importance: NotificationImportance.High,
//               defaultPrivacy: NotificationPrivacy.Private,
//               defaultColor: Colors.deepPurple,
//               ledColor: Colors.deepPurple),
//           NotificationChannel(
//               channelKey: 'basic_channel',
//               channelName: 'Basic Notifications',
//               channelDescription: 'Notification tests for basic usage',
//               playSound: true,
//               onlyAlertOnce: true,
//               groupAlertBehavior: GroupAlertBehavior.Children,
//               importance: NotificationImportance.High,
//               defaultPrivacy: NotificationPrivacy.Private,
//               defaultColor: Colors.deepPurple,
//               ledColor: Colors.deepPurple)
//         ],
//         debug: true);

//     // Get initial notification action is optional
//     initialAction = await AwesomeNotifications()
//         .getInitialNotificationAction(removeFromActionEvents: false);
//   }

//   static ReceivePort? receivePort;
//   static Future<void> initializeIsolateReceivePort() async {
//     receivePort = ReceivePort('Notification action port in main isolate')
//       ..listen(
//           (silentData) => onActionReceivedImplementationMethod(silentData));

//     // This initialization only happens on main isolate
//     IsolateNameServer.registerPortWithName(
//         receivePort!.sendPort, 'notification_action_port');
//   }

//   ///  *********************************************
//   ///     NOTIFICATION EVENTS LISTENER
//   ///  *********************************************
//   ///  Notifications events are only delivered after call this method
//   static Future<void> startListeningNotificationEvents() async {
//     AwesomeNotifications()
//         .setListeners(onActionReceivedMethod: onActionReceivedMethod);
//   }

//   ///  *********************************************
//   ///     NOTIFICATION EVENTS
//   ///  *********************************************
//   ///
//   @pragma('vm:entry-point')
//   static Future<void> onActionReceivedMethod(
//       ReceivedAction receivedAction) async {
//     if (receivedAction.actionType == ActionType.SilentAction ||
//         receivedAction.actionType == ActionType.SilentBackgroundAction) {
//       // For background actions, you must hold the execution until the end
//       print(
//           'Message sent via notification input: "${receivedAction.buttonKeyInput}"');
//       await executeLongTaskInBackground();
//     } else {
//       // this process is only necessary when you need to redirect the user
//       // to a new page or use a valid context, since parallel isolates do not
//       // have valid context, so you need redirect the execution to main isolate
//       if (receivePort == null) {
//         print(
//             'onActionReceivedMethod was called inside a parallel dart isolate.');
//         SendPort? sendPort =
//             IsolateNameServer.lookupPortByName('notification_action_port');

//         if (sendPort != null) {
//           print('Redirecting the execution to main isolate process.');
//           sendPort.send(receivedAction);
//           return;
//         }
//       }

//       return onActionReceivedImplementationMethod(receivedAction);
//     }
//   }

//   static Future<void> onActionReceivedImplementationMethod(
//       ReceivedAction receivedAction) async {
//     MyApp.navigatorKey.currentState?.pushNamedAndRemoveUntil(
//         '/notification-page',
//         (route) =>
//             (route.settings.name != '/notification-page') || route.isFirst,
//         arguments: receivedAction);
//   }

//   ///  *********************************************
//   ///     REQUESTING NOTIFICATION PERMISSIONS
//   ///  *********************************************
//   ///
//   static Future<bool> displayNotificationRationale() async {
//     bool userAuthorized = false;
//     BuildContext context = MyApp.navigatorKey.currentContext!;
//     await showDialog(
//         context: context,
//         builder: (BuildContext ctx) {
//           return AlertDialog(
//             title: Text('Get Notified!',
//                 style: Theme.of(context).textTheme.titleLarge),
//             content: Column(
//               mainAxisSize: MainAxisSize.min,
//               children: [
//                 Row(
//                   children: [
//                     Expanded(
//                       child: Image.asset(
//                         'assets/images/animated-bell.gif',
//                         height: MediaQuery.of(context).size.height * 0.3,
//                         fit: BoxFit.fitWidth,
//                       ),
//                     ),
//                   ],
//                 ),
//                 const SizedBox(height: 20),
//                 const Text(
//                     'Allow Awesome Notifications to send you beautiful notifications!'),
//               ],
//             ),
//             actions: [
//               TextButton(
//                   onPressed: () {
//                     Navigator.of(ctx).pop();
//                   },
//                   child: Text(
//                     'Deny',
//                     style: Theme.of(context)
//                         .textTheme
//                         .titleLarge
//                         ?.copyWith(color: Colors.red),
//                   )),
//               TextButton(
//                   onPressed: () async {
//                     userAuthorized = true;
//                     Navigator.of(ctx).pop();
//                   },
//                   child: Text(
//                     'Allow',
//                     style: Theme.of(context)
//                         .textTheme
//                         .titleLarge
//                         ?.copyWith(color: Colors.deepPurple),
//                   )),
//             ],
//           );
//         });
//     return userAuthorized &&
//         await AwesomeNotifications().requestPermissionToSendNotifications();
//   }

//   ///  *********************************************
//   ///     BACKGROUND TASKS TEST
//   ///  *********************************************
//   static Future<void> executeLongTaskInBackground() async {
//     print("starting long task");
//     await Future.delayed(const Duration(seconds: 4));
//     final url = Uri.parse("http://google.com");
//     final re = await http.get(url);
//     print(re.body);
//     print("long task done");
//   }

//   ///  *********************************************
//   ///     NOTIFICATION CREATION METHODS
//   ///  *********************************************
//   ///
//   static Future<void> createNewNotification() async {
//     bool isAllowed = await AwesomeNotifications().isNotificationAllowed();
//     if (!isAllowed) isAllowed = await displayNotificationRationale();
//     if (!isAllowed) return;

//     await AwesomeNotifications().createNotification(
//         content: NotificationContent(
//             id: -1, // -1 is replaced by a random number
//             channelKey: 'alerts',
//             title: 'Huston! The eagle has landed!',
//             body:
//                 "A small step for a man, but a giant leap to Flutter's community!",
//             bigPicture: 'https://storage.googleapis.com/cms-storage-bucket/d406c736e7c4c57f5f61.png',
//             largeIcon: 'https://storage.googleapis.com/cms-storage-bucket/0dbfcc7a59cd1cf16282.png',
//             //'asset://assets/images/balloons-in-sky.jpg',
//             notificationLayout: NotificationLayout.BigPicture,
//             payload: {'notificationId': '1234567890'}),
//         actionButtons: [
//           NotificationActionButton(key: 'REDIRECT', label: 'Redirect'),
//           NotificationActionButton(
//               key: 'REPLY',
//               label: 'Reply Message',
//               requireInputText: true,
//               actionType: ActionType.SilentAction),
//           NotificationActionButton(
//               key: 'DISMISS',
//               label: 'Dismiss',
//               actionType: ActionType.DismissAction,
//               isDangerousOption: true)
//         ]);
//   }

//   static Future<void> scheduleNewNotification() async {
//     bool isAllowed = await AwesomeNotifications().isNotificationAllowed();
//     if (!isAllowed) isAllowed = await displayNotificationRationale();
//     if (!isAllowed) return;

//     // Yeni bildirim planlanır (10 saniye sonra)
//     await myNotifyScheduleInSeconds(
//         title: 'Planlanmış Bildirim',
//         msg: 'Bu bildirim 10 saniye sonra görünecek şekilde planlandı.',
//         heroThumbUrl:
//             'https://storage.googleapis.com/cms-storage-bucket/d406c736e7c4c57f5f61.png',
//         secondsFromNow: 10,
//         username: 'test kullanıcı',
//         repeatNotif: false);
//   }

//   static Future<void> resetBadgeCounter() async {
//     await AwesomeNotifications().resetGlobalBadge();
//   }

//   static Future<void> cancelNotifications() async {
//     await AwesomeNotifications().cancelAll();
//   }

//   static Future<void> checkServer() async {
//     final url = Uri.parse('http://localhost:3000/imt');
//     final response = await http.get(url);

//     if (response.statusCode == 200) {
//       final data = jsonDecode(response.body);
//       if (data ==
//           [
//             {"": 0}
//           ]) {
//         await createNewNotification();
//       }
//     }
//   }

//   static Future<void> myNotifyScheduleInSeconds({
//     required String title,
//     required String msg,
//     required String heroThumbUrl,
//     required int secondsFromNow,
//     required String username,
//     required bool repeatNotif,
//   }) async {
//     DateTime scheduleTime =
//         DateTime.now().add(Duration(seconds: secondsFromNow));
//     await AwesomeNotifications().createNotification(
//         content: NotificationContent(
//             id: 1,
//             channelKey: 'alerts',
//             title: title,
//             body: msg,
//             notificationLayout: NotificationLayout.BigPicture,
//             bigPicture: heroThumbUrl,
//             payload: {'username': username}),
//         schedule: NotificationCalendar.fromDate(date: scheduleTime),
//         actionButtons: [
//           NotificationActionButton(key: 'REDIRECT', label: 'Redirect')
//         ]);

//     if (repeatNotif) {
//       await AwesomeNotifications().createNotification(
//           content: NotificationContent(
//               id: 1,
//               channelKey: 'alerts',
//               title: 'Tekrarlayan bildirim',
//               body: 'Bu bildirim her 10 saniyede bir tekrar ediliyor.',
//               notificationLayout: NotificationLayout.BigPicture,
//               bigPicture:
//                   'https://storage.googleapis.com/cms-storage-bucket/d406c736e7c4c57f5f61.png',
//               payload: {'username': username}),
//           schedule: NotificationInterval(interval: 10, timeZone: 'GMT'));
//     }
//   }
// }

// class MyApp extends StatefulWidget {
//   const MyApp({Key? key}) : super(key: key);

//   static final GlobalKey<NavigatorState> navigatorKey =
//       GlobalKey<NavigatorState>();

//   @override
//   State<MyApp> createState() => _MyAppState();
// }

// class _MyAppState extends State<MyApp> {
//   @override
//   void initState() {
//     super.initState();
//     NotificationController.startListeningNotificationEvents();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'Notification App',
//       navigatorKey: MyApp.navigatorKey,
//       home: const MyHomePage(),
//     );
//   }
// }

// class MyHomePage extends StatelessWidget {
//   const MyHomePage({Key? key}) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Notification App'),
//       ),
//       body: Center(
//         child: ElevatedButton(
//           onPressed: () {
//             NotificationController.scheduleNewNotification();
//           },
//           child: const Text('Schedule Notification'),
//         ),
//       ),
//     );
//   }
// }
