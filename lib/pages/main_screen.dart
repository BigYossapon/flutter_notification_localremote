import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:http/http.dart' as http;
import 'package:fluttertoast/fluttertoast.dart';

import '../service/firebase_helper.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

@pragma("vm.entry-point")
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  print('Handling a background message ${message.messageId}');
}

@pragma("vm.entry-point")
void initInfo() {
  late FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  var androidInitializeApp =
      const AndroidInitializationSettings('@mipmap/ic_launcher');
  //now darwin is macos and ios
  var iOSInitializeApp = const DarwinInitializationSettings();
  var initializationsSettings = InitializationSettings(
      android: androidInitializeApp, iOS: iOSInitializeApp);
  flutterLocalNotificationsPlugin.initialize(
    initializationsSettings,
    onDidReceiveNotificationResponse: (details) {
      try {
        if (details.payload != null && details.payload!.isNotEmpty) {
        } else {}
      } catch (e) {
        return;
      }
    },
    onDidReceiveBackgroundNotificationResponse: (details) {
      try {
        if (details.payload != null && details.payload!.isNotEmpty) {
        } else {}
      } catch (e) {
        return;
      }
    },
  );

  FirebaseMessaging.onMessage.listen((event) async {
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
  });
  FirebaseMessaging.onMessageOpenedApp.listen((event) async {
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
        AndroidNotificationDetails('dbfood', 'dbfood',
            importance: Importance.high,
            styleInformation: bigTextStyleInformation,
            priority: Priority.high,
            playSound: true);
    NotificationDetails platformChannelSpecifics = NotificationDetails(
        android: androidPlatformChannelSpecifics,
        iOS: const DarwinNotificationDetails());
    await flutterLocalNotificationsPlugin.show(0, event.notification?.title,
        event.notification?.body, platformChannelSpecifics,
        payload: event.data['body']);
  });

  //FirebaseMessaging.onBackgroundMessage((message) => )
}

class _MainScreenState extends State<MainScreen> {
  late FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  String? mtoken = "";
  TextEditingController username = TextEditingController();
  TextEditingController title = TextEditingController();
  TextEditingController body = TextEditingController();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    requestPermission();
    getToken();
    initInfo();
  }

  void getToken() async {
    await FirebaseMessaging.instance.getToken().then((token) {
      setState(() {
        mtoken = token;
        print('My token is $mtoken');
      });
      saveToken(token!);
    });
  }

  void saveToken(String token) async {
    await FirebaseFirestore.instance
        .collection('UserTokens')
        .doc("User1")
        .set({'token': token});
  }

  void requestPermission() async {
    FirebaseMessaging messaging = FirebaseMessaging.instance;

    NotificationSettings settings = await messaging.requestPermission(
        alert: true,
        announcement: false,
        badge: true,
        carPlay: false,
        criticalAlert: false,
        provisional: false,
        sound: true);

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      print('User granted permission');
    } else if (settings.authorizationStatus ==
        AuthorizationStatus.provisional) {
      print('User granted provisional permission');
    } else {
      print('User declined or has not accepted permission');
    }
  }

  void sendPushMessage(String token, String body, String title) async {
    try {
      await http.post(Uri.parse('https://fcm.googleapis.com/fcm/send'),
          headers: <String, String>{
            'Content=Type': 'application/json',
            'Authorization':
                'key=AAAAgCNlRwc:APA91bHyQzZeOA3EnyauaMwVvdDRTFSEf66YcmSuzLa9fRC9-lFgpdUPeiYE4RkZOJY_hxcH2q-i_Z4HodGFsJfFcXRalIJWQQi8UjprUwkwe-uDckJghy6OWk_NR7QsQr-bLtNghFnW'
          },
          body: jsonEncode(<String, dynamic>{
            'priority': 'high',
            'data': <String, dynamic>{
              'click_action': 'Flutter_notification_click',
              'status': 'done',
              'body': body,
              'title': title,
            },
            'notification': <String, dynamic>{
              "title": title,
              "body": body,
              "android_channel_id": "android_id"
            },
            "to": token
          }));
    } catch (e) {
      if (kDebugMode) {
        print("error push notifications");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('main screen')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextFormField(
              controller: username,
            ),
            TextFormField(
              controller: username,
            ),
            TextFormField(
              controller: username,
            ),
            ElevatedButton(
                onPressed: () async {
                  String name = username.text.trim();
                  String titleText = title.text;
                  String bodyText = body.text;

                  if (name != "") {
                    DocumentSnapshot snapshot = await FirebaseFirestore.instance
                        .collection("UserTokens")
                        .doc(name)
                        .get();
                    String token = snapshot['token'];
                    print(token);
                    sendPushMessage(token, bodyText, titleText);
                  }
                },
                child: Container(
                  margin: const EdgeInsets.all(20),
                  height: 40,
                  width: 200,
                  decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(color: Colors.redAccent.withOpacity(0.5)),
                      ]),
                  child: Center(
                    child: const Text('button'),
                  ),
                )),
            ElevatedButton(
                onPressed: () async {
                  String name = username.text.trim();
                  String titleText = title.text;
                  String bodyText = body.text;
                },
                child: Container(
                  margin: const EdgeInsets.all(20),
                  height: 40,
                  width: 200,
                  decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(color: Colors.redAccent.withOpacity(0.5)),
                      ]),
                  child: Center(
                    child: const Text('send notification'),
                  ),
                ))
          ],
        ),
      ),
    );
  }
}
