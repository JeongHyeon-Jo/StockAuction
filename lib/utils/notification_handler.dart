import 'dart:convert';

import 'package:auction/main.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:go_router/go_router.dart';
import 'package:permission_handler/permission_handler.dart';

class NotificationHandler {
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
  final GoRouter router;

  NotificationHandler({required this.router});

  Future<void> initialize() async {
    await _requestAndroidPermissions();
    await _configureLocalNotifications();
    await _configureFCM();
  }

  Future<void> _requestAndroidPermissions() async {
    if (await Permission.notification.isDenied) {
      await Permission.notification.request();
    }
  }

  Future<void> _configureLocalNotifications() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
    AndroidInitializationSettings('@mipmap/ic_launcher');
    final DarwinInitializationSettings initializationSettingsIOS =
    DarwinInitializationSettings();
    final InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );
    await _flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response){
        _onDidReceiveNotificationResponse(response.payload);
      },
    );
  }

  void _onDidReceiveNotificationResponse(String? payload) {
    if (payload != null) {
      final screenAndParameter = splitScreenParameter(payload);

      if(screenAndParameter[1].isEmpty){
        router.push(screenAndParameter[0]);
      }else{
        router.push(screenAndParameter[0],extra: screenAndParameter[1]);
      }

    }
  }

  Future<void> _configureFCM() async {
    NotificationSettings settings = await _firebaseMessaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      print('User granted permission');

      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        print("Received message: ${message.notification?.title}");
        _handleMessage(message);
      });

      FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
        print("Opened app from notification");
        _handleMessageOpenedApp(message);
      });
    } else {
      print('User declined or has not accepted permission');
    }
  }

  void _handleMessage(RemoteMessage message) {
    if (message.notification != null) {
      _showNotification(message);
    }
  }

  void _handleMessageOpenedApp(RemoteMessage message) {
    print('call _handleMessageOpenedApp');
    final String? screen = message.data['screen'];
    final screenAndParameter = splitScreenParameter(screen ?? "");

    if(screenAndParameter[1].isEmpty){
      router.push(screenAndParameter[0]);
    }else{
      router.push(screenAndParameter[0],extra: screenAndParameter[1]);
    }

  }

  Future<void> _showNotification(RemoteMessage message) async {
    final AndroidNotificationDetails androidPlatformChannelSpecifics =
    AndroidNotificationDetails(
      'general_channel',
      'General Notifications',
      importance: Importance.max,
      priority: Priority.high,
    );
    final NotificationDetails platformChannelSpecifics =
    NotificationDetails(android: androidPlatformChannelSpecifics);

    print("recived push title : ${message.notification?.title ?? "알림"},data : ${message.data}");

    await _flutterLocalNotificationsPlugin.show(
      0,
      message.notification?.title ?? "알림",
      message.notification?.body ?? "",
      platformChannelSpecifics,
      payload: message.data['screen'],
    );
  }

  Future<void> showCustomNotification({
    required String title,
    required String body,
    required String screen,
    String? postUid,
    String? chatId,
  }) async {
    final AndroidNotificationDetails androidPlatformChannelSpecifics =
    AndroidNotificationDetails(
      'general_channel',
      'General Notifications',
      importance: Importance.max,
      priority: Priority.high,
    );
    final NotificationDetails platformChannelSpecifics =
    NotificationDetails(android: androidPlatformChannelSpecifics);

    final payload = {
      'screen': screen,
      if (postUid != null) 'postUid': postUid,
      if (chatId != null) 'chatId': chatId,
    };

    await _flutterLocalNotificationsPlugin.show(
      0,
      title,
      body,
      platformChannelSpecifics,
      payload: payload.toString(),
    );
  }

  List<String> splitScreenParameter(String data) {
    String screen;
    String parameter;

    int questionMarkIndex = data.indexOf('?');

    if (questionMarkIndex != -1) {
      // '?'가 존재하는 경우
      screen = data.substring(0, questionMarkIndex);
      parameter = data.substring(questionMarkIndex + 1);
    } else {
      // '?'가 없는 경우
      screen = data;
      parameter = '';
    }
    return [screen, parameter];
  }

  Future<String?> getToken() async {
    return await _firebaseMessaging.getToken();
  }
}