/*
import 'dart:io';
import 'package:city_sightseeing/service/shared_pred_service.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';

import 'http_service.dart';


class FirebaseNotificationService {
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  String? token;
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
  FlutterLocalNotificationsPlugin();

  void init(){
    _initializeFirebaseMessaging();
  }

*/
/*  Future<void> _initializeFirebaseMessaging() async {
    // Register the background handler inside the controller
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  }*//*


  */
/*static Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
    // Handle the background message
    debugPrint('Handling a background message: ${message.messageId}');
    // Perform your background message processing logic here, such as showing a notification
    // For example:
    showMessage(message.notification?.title ?? "No Title");
  }*//*

*/
/*  Future<FirebaseNotificationService> init() async {
    debugPrint("INIT");

    await _initializeFirebaseMessaging();
    debugPrint("DONE FIREBASE INIT");
    return this;
  }*//*



  // get token
  Future<String?> getFcmToken() async {
    final token = await _firebaseMessaging.getToken();
    debugPrint('_firebaseMessaging_Token: $token');
    if (token != null) {
      getFireBaseToken(token);

    }
    return token;
  }


  //refresh token


  Future<String?> refreshFcmToken() async {
    _firebaseMessaging.onTokenRefresh.listen((token) async {
      getFireBaseToken(token);
    });
    return null;
  }


  Future<void> _initializeFirebaseMessaging() async {

    // Request permissions for iOS
    final settings = await _firebaseMessaging.requestPermission();
    debugPrint('User granted permission: ${settings.authorizationStatus}');

    debugPrint("INIT");
    // Get the token
    token = await _firebaseMessaging.getToken();

    if(token!=null){
      debugPrint('FirebaseMessaging token: $token');
      getFireBaseToken(token!);
    }


    // Handle background messages
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);


    // Handle foreground messages
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      debugPrint('Got a message whilst in the foreground!');
      debugPrint('Message data: ${message.data}');


      if (message.notification != null) {
        debugPrint(
          'Message also contained a notification: ${message.notification}',
        );
        _showNotification(message.notification);


        */
/* // Add the notification to the NotificationController
        Get.put<NotificationController>(NotificationController())
            .addNotification(message.notification!);*//*

      }
    });


    await initMessaging();
  }


  Future<void> initMessaging() async {
    if (Platform.isAndroid) {
      await flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>()!
          .requestNotificationsPermission();
      await FirebaseMessaging.instance
          .setForegroundNotificationPresentationOptions(
        alert: true,
        badge: true,
        sound: true,
      );
    } else if (Platform.isIOS) {
      final settings = await _firebaseMessaging.requestPermission();
      if (settings.authorizationStatus == AuthorizationStatus.authorized) {
        debugPrint('User granted permission');
      } else {
        debugPrint('User declined or has not accepted permission');
      }
    }
    await Permission.notification.request();


    const initializationSettingsAndroid =
    AndroidInitializationSettings('@mipmap/ic_launcher');


    const initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
    );


    await flutterLocalNotificationsPlugin.initialize(initializationSettings);


    //
  }


  Future<void> _showNotification(RemoteNotification? notification) async {
    if (notification != null) {
      const androidPlatformChannelSpecifics = AndroidNotificationDetails(
        'your_channel_id',
        'your_channel_name',
        channelDescription: 'your_channel_description',
        importance: Importance.max,
        priority: Priority.high,
        showWhen: false,
      );
      const platformChannelSpecifics =
      NotificationDetails(android: androidPlatformChannelSpecifics);
      await flutterLocalNotificationsPlugin.show(
        0,
        notification.title,
        notification.body,
        platformChannelSpecifics,
        payload: 'item x',
      );
    }
  }
  static Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
    debugPrint('Handling a background message: ${message.messageId}');
    // Use the local notifications plugin to show a notification
    final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
    const androidPlatformChannelSpecifics = AndroidNotificationDetails(
      'your_channel_id',
      'your_channel_name',
      channelDescription: 'your_channel_description',
      importance: Importance.max,
      priority: Priority.high,
      showWhen: false,
    );
    const platformChannelSpecifics = NotificationDetails(android: androidPlatformChannelSpecifics);
    await flutterLocalNotificationsPlugin.show(
      0,
      message.notification?.title,
      message.notification?.body,
      platformChannelSpecifics,
      payload: 'item x',
    );
  }

*/
/*
  static Future<void> _firebaseMessagingBackgroundHandler(
      RemoteMessage message,
      ) async {

    debugPrint('Handling a background message: ${message.messageId}');
      showMessage(  message.notification?.title ?? "");
  *//*
*/
/*  await AppNotification.showBigTextNotification(
      title: message.notification?.title ?? '',
      body: message.notification?.body ?? '',
      fln: FlutterLocalNotificationsPlugin(),
    );*//*
*/
/*
  }*//*


  void getFireBaseToken(String token) async {
    try {

      var map = new Map<String, dynamic>();
      map['token'] = token;
      print("-----firebase token --->${token}");
      var response =
      await HttpService.httpPostWithoutToken("update_firebase_token", map);

      if (response.statusCode == 200 || response.statusCode == 201) {
        debugPrint("---------firebase token updated--------");
        await SharedPrefService.setToken(token.toString());
      }
    } catch (e) {}
  }
}*/
