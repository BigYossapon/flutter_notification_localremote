import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_notification_localandremote/pages/main_screen.dart';

@pragma("vm.entry-point")
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage event) async {
  late FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  print('Handling a background message ${event.messageId}');
  debugPrint(".............onMessage................");
  debugPrint(
      "onMessage: ${event.notification?.title}/${event.notification?.body} ");

  BigTextStyleInformation bigTextStyleInformation = BigTextStyleInformation(
    event.notification!.body.toString(),
    htmlFormatBigText: true,
    contentTitle: event.notification!.title.toString(),
    htmlFormatContentTitle: true,
  );
  AndroidNotificationDetails androidPlatformChannelSpecifics =
      AndroidNotificationDetails("android_id", "android_name",
          importance: Importance.high,
          styleInformation: bigTextStyleInformation,
          priority: Priority.high,
          playSound: true);
  NotificationDetails platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
      iOS: const DarwinNotificationDetails());
  await flutterLocalNotificationsPlugin.show(
      event.hashCode,
      event.notification?.title,
      event.notification?.body,
      platformChannelSpecifics,
      payload: event.data['body']);
}

const topic = 'app_promotion';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await FirebaseMessaging.instance.getInitialMessage();
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  FirebaseAnalytics.instance;

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'flutter noti',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: MainScreen(),
    );
  }
}
