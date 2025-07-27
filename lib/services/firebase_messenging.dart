import 'dart:async';
import 'dart:convert';
import 'dart:developer';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import 'package:flutter_arch/common/snack_bar.dart';
import 'package:flutter_arch/storage/flutter_secure_storage.dart';

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  log('📥 Background message: ${message.notification?.title}');
  await FirebaseMessagingService.showBackgroundNotification(message);
}

class FirebaseMessagingService {
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  final MySecureStorage _secureStorage = MySecureStorage();

  static final FirebaseMessagingService _instance =
      FirebaseMessagingService._internal();
  factory FirebaseMessagingService() => _instance;
  FirebaseMessagingService._internal();

  String? _fcmToken;
  String? get fcmToken => _fcmToken;

  static final FlutterLocalNotificationsPlugin _staticFlutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  Future<void> initialize(BuildContext? context) async {
    try {
      FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
      await _requestPermission();
      await _initializeLocalNotifications();
      await _getToken();
      _configureMessaging(context);
      log('✅ Firebase Messaging initialized');
    } catch (e) {
      log('❌ Firebase Messaging init error: $e');
    }
  }

  Future<void> _requestPermission() async {
    final settings = await _firebaseMessaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );
    log('🔐 Notification permission: ${settings.authorizationStatus}');
  }

  Future<void> _initializeLocalNotifications() async {
    try {
      const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
      const initializationSettings = InitializationSettings(
        android: androidInit,
        iOS: null, // Add iOS settings if needed
      );

      await _flutterLocalNotificationsPlugin.initialize(
        initializationSettings,
        onDidReceiveNotificationResponse: (response) {
          if (response.payload != null) {
            log('📦 Notification payload: ${response.payload}');
          }
        },
      );

      const AndroidNotificationChannel channel = AndroidNotificationChannel(
        'high_importance_channel',
        'High Importance Notifications',
        description: 'This channel is used for important notifications.',
        importance: Importance.max,
      );

      await _flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
          ?.createNotificationChannel(channel);
    } catch (e) {
      log('❌ Local notification init error: $e');
    }
  }

  void _configureMessaging(BuildContext? context) {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      log('📲 Foreground message: ${message.notification?.title}');
      _showNotification(message);

      if (context != null && message.notification?.title != null) {
        MySnackBar.showSnackBar(context, message.notification!.title!);
      }
    });

    FirebaseMessaging.instance.getInitialMessage().then((message) {
      if (message != null) {
        log('🚀 App launched via notification: ${message.notification?.title}');
      }
    });

    FirebaseMessaging.onMessageOpenedApp.listen((message) {
      log('🟢 Notification opened app: ${message.notification?.title}');
    });

    _firebaseMessaging.onTokenRefresh.listen((String token) async {
      _fcmToken = token;
      await _saveFcmToken(token);
      log('🔁 FCM token refreshed: $token');
    });
  }

  Future<void> _getToken() async {
    try {
      _fcmToken = await _secureStorage.readFcmToken();

      if (_fcmToken == null || _fcmToken!.isEmpty) {
        _fcmToken = await _firebaseMessaging.getToken();
        if (_fcmToken != null) {
          await _saveFcmToken(_fcmToken!);
        }
      }

      log('📡 FCM Token: $_fcmToken');
    } catch (e) {
      log('❌ Error getting FCM token: $e');
    }
  }

  Future<void> _saveFcmToken(String token) async {
    await _secureStorage.writeFcmToken(token);
  }

  Future<void> _showNotification(RemoteMessage message) async {
    await FirebaseMessagingService.showBackgroundNotification(message);
  }

  static Future<void> showBackgroundNotification(RemoteMessage message) async {
    final notification = message.notification;
    final android = notification?.android;

    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'high_importance_channel',
      'High Importance Notifications',
      channelDescription: 'This channel is used for important notifications.',
      icon: '@mipmap/ic_launcher',
      priority: Priority.high,
      importance: Importance.max,
    );

    final NotificationDetails platformDetails = NotificationDetails(android: androidDetails);

    final title = notification?.title ?? 'New Message';
    final body = notification?.body ?? message.data['body'] ?? 'You have a new notification.';

    await _staticFlutterLocalNotificationsPlugin.show(
      DateTime.now().millisecondsSinceEpoch ~/ 1000,
      title,
      body,
      platformDetails,
      payload: json.encode(message.data),
    );
  }

  Future<void> subscribeToTopic(String topic) async {
    await _firebaseMessaging.subscribeToTopic(topic);
    log('📬 Subscribed to topic: $topic');
  }

  Future<void> unsubscribeFromTopic(String topic) async {
    await _firebaseMessaging.unsubscribeFromTopic(topic);
    log('📭 Unsubscribed from topic: $topic');
  }
}
