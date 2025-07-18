import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_arch/common/snack_bar.dart';
import 'package:flutter_arch/storage/flutter_secure_storage.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';


Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  log('Background message received: ${message.notification?.title}');
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

  Future<void> initialize(BuildContext? context) async {
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    await _requestPermission();

    await _initializeLocalNotifications();

    await getToken();

    _configureMessaging(context);

    log('Firebase Messaging initialized');
  }

  Future<void> _requestPermission() async {
    NotificationSettings settings = await _firebaseMessaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false,
    );

    log('Notification permission status: ${settings.authorizationStatus}');
  }

  Future<void> _initializeLocalNotifications() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@drawable/ic_notification');

    const InitializationSettings initializationSettings =
        InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: null,
    );

    await _flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        final payload = response.payload;
        if (payload != null) {
          log('Notification payload: $payload');
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
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);
  }

  void _configureMessaging(BuildContext? context) {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      log('Foreground message received: ${message.notification?.title}');
      log('Message data: ${message}');
      _showNotification(message);

      if (context != null) {
        MySnackBar.showSnackBar(context,
            message.notification?.title ?? 'New notification received');
      }
    });

    FirebaseMessaging.instance
        .getInitialMessage()
        .then((RemoteMessage? message) {
      if (message != null) {
        log('App opened from terminated state with message: ${message.notification?.title}');
      }
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      log('App opened from background state with message: ${message.notification?.title}');
    });

    _firebaseMessaging.onTokenRefresh.listen((String token) {
      _fcmToken = token;
      _saveFcmToken(token);
      log('FCM token refreshed: $token');
    });
  }

  Future<void> getToken() async {
    try {
      _fcmToken = await _secureStorage.readFcmToken();

      if (_fcmToken == null || _fcmToken!.isEmpty) {
        _fcmToken = await _firebaseMessaging.getToken();
        if (_fcmToken != null) {
          await _saveFcmToken(_fcmToken!);
        }
      }

      log('FCM Token: $_fcmToken');
    } catch (e) {
      log('Error getting FCM token: $e');
    }
  }

  Future<void> _saveFcmToken(String token) async {
    await _secureStorage.writeFcmToken(token);
  }

  Future<void> _showNotification(RemoteMessage message) async {
    RemoteNotification? notification = message.notification;
    AndroidNotification? android = message.notification?.android;

    if (notification != null && android != null) {
      AndroidNotificationDetails androidDetails = _createDefaultAndroidDetails(android);

      await _flutterLocalNotificationsPlugin.show(
        notification.hashCode,
        notification.title,
        notification.body,
        NotificationDetails(android: androidDetails),
        payload: json.encode(message.data),
      );
    }
  }

  AndroidNotificationDetails _createDefaultAndroidDetails(
      AndroidNotification android) {
    return AndroidNotificationDetails(
      'high_importance_channel',
      'High Importance Notifications',
      channelDescription: 'This channel is used for important notifications.',
      icon: '@drawable/ic_notification',
      priority: Priority.high,
      importance: Importance.max,
    );
  }

  Future<void> subscribeToTopic(String topic) async {
    await _firebaseMessaging.subscribeToTopic(topic);
    log('Subscribed to topic: $topic');
  }

  Future<void> unsubscribeFromTopic(String topic) async {
    await _firebaseMessaging.unsubscribeFromTopic(topic);
    log('Unsubscribed from topic: $topic');
  }
}
