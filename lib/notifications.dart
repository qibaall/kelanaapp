// ignore_for_file: prefer_const_constructors

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NotificationService {
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  Future<void> saveNotification(String notification) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String>? notifications = prefs.getStringList('notifications') ?? [];
    notifications.add(notification);
    await prefs.setStringList('notifications', notifications);
  }

  // Retrieve all notifications
  Future<List<String>> getNotifications() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getStringList('notifications') ?? [];
  }

  Future<void> initializeNotifications() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    final InitializationSettings initializationSettings =
        InitializationSettings(android: initializationSettingsAndroid);

    await flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) async {
        if (response.payload != null) {
          debugPrint('notification payload: ${response.payload}');
        }
      },
    );
  }

  Future<void> sendNotification(int reportId, String status) async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'report_status_channel',
      'Report Status Channel',
      importance: Importance.high,
      priority: Priority.high,
      showWhen: false,
    );

    const NotificationDetails platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);

    try {
      await flutterLocalNotificationsPlugin.show(
        reportId,
        'Status Laporan',
        'Laporan Dengan ID $reportId Status Laporan Sudah $status',
        platformChannelSpecifics,
        payload: 'Report ID: $reportId',
      );
      debugPrint('Notification sent successfully for Report ID: $reportId');
    } catch (e) {
      debugPrint(
          'Failed to send notification for Report ID: $reportId, Error: $e');
    }
  }
}
