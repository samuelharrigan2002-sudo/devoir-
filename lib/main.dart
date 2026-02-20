import 'dart:io';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:async';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await NotificationService().init();
  await _requestNotificationPermission();
  runApp(const MyApp());
}

Future<void> _requestNotificationPermission() async {
  // Request notification permission (Android 13+)
  final status = await Permission.notification.status;
  if (status.isDenied) {
    await Permission.notification.request();
  }

  // Request exact alarm permission (Android 14+ / API 34+)
  if (Platform.isAndroid) {
    final exactAlarmStatus = await Permission.scheduleExactAlarm.status;
    if (!exactAlarmStatus.isGranted) {
      await Permission.scheduleExactAlarm.request();
    }
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Notif',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blueGrey,
        ),
        useMaterial3: true,
      ),
      home: const Page(),
    );
  }
}

class Page extends StatelessWidget {
  const Page({super.key});

  @override
  Widget build(BuildContext context) {
    final notificationService = NotificationService();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.blue,
        elevation: 0,
        title: const Text(
          'Notif',
          style: TextStyle(
            fontSize: 16,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 80),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blueAccent,
              foregroundColor: Colors.white,
              elevation: 8,
              ),
              onPressed: () {notificationService.showInstantNotification();},
              child: const Text('Notification pou kunya'),
            ),

            SizedBox(height: 20),

            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blueAccent,
                foregroundColor: Colors.white,
                elevation: 8,
              ),
              onPressed: () {notificationService.showScheduledNotification();},
              child: const Text('Notification apre 2s'),
            ),

            SizedBox(height: 20),

            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blueAccent,
                foregroundColor: Colors.white,
                elevation: 8,
              ),
              onPressed: () {notificationService.showRepeatingNotification();},
              child: const Text('Notification chak minit'),
            ),

            SizedBox(height: 20),

            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blueAccent,
                foregroundColor: Colors.white,
                elevation: 8,
              ),
              onPressed: () {notificationService.showBigTextNotification();},
              child: const Text('Notification anpil teks'),
            ),

          ],
        ),
      ),
    );
  }

  Widget _flatButton({required String label, required VoidCallback onPressed}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 20),
          side: const BorderSide(color: Colors.black12, width: 1),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
        ),
        child: Text(
          label,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w400,
            color: Colors.black87,
            letterSpacing: 0.5,
          ),
        ),
      ),
    );
  }
}

//===============================================================================
class NotificationService {
  static final NotificationService _instance = NotificationService._internal();

  factory NotificationService() {
    return _instance;
  }

  NotificationService._internal();

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
  FlutterLocalNotificationsPlugin();

  Timer? _repeatingTimer;

  Future<void> init() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
    AndroidInitializationSettings('@mipmap/ic_launcher');

    final DarwinInitializationSettings initializationSettingsDarwin =
    DarwinInitializationSettings(
      requestSoundPermission: true,
      requestBadgePermission: true,
      requestAlertPermission: true,
    );

    final InitializationSettings initializationSettings =
    InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsDarwin,
    );

    await flutterLocalNotificationsPlugin.initialize(
      settings: initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) async {
        // Handle notification tapped logic here
      },
    );
  }

  Future<void> showInstantNotification() async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
    AndroidNotificationDetails(
      'instant_channel_id',
      'Notifikasyon pou kunya',
      channelDescription: 'Channel for instant notifications',
      importance: Importance.max,
      priority: Priority.high,
    );
    const NotificationDetails platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
    );
    await flutterLocalNotificationsPlugin.show(
      id: 0,
      title: 'Notifikasyon pou kunya',
      body: 'se yon notifikasyon ki paret kunya',
      notificationDetails: platformChannelSpecifics,
    );
  }

  Future<void> showScheduledNotification() async {
    Future.delayed(const Duration(seconds: 2), () async {
      await flutterLocalNotificationsPlugin.show(
        id: 1,
        title: 'Notifikasyon planifye chak 2 seconde',
        body: 'se yon notifikasyon kap paret chak 2 seconde!',
        notificationDetails: const NotificationDetails(
          android: AndroidNotificationDetails(
            'scheduled_channel_id',
            'Notifikasyon planifye',
            channelDescription: 'Channel for scheduled notifications',
            importance: Importance.max,
            priority: Priority.high,
          ),
        ),
      );
    });
  }

  Future<void> showRepeatingNotification() async {
    // Cancel any existing repeating timer
    _repeatingTimer?.cancel();
    _repeatingTimer = Timer.periodic(const Duration(seconds: 10), (timer) async {
      await flutterLocalNotificationsPlugin.show(
        id: 2,
        title: 'Notifikasyon ki repete chk 10s',
        body: 'Notification #${timer.tick} - repeats every minute',
        notificationDetails: const NotificationDetails(
          android: AndroidNotificationDetails(
            'repeating_channel_id',
            'Notifikasyon ki repete',
            channelDescription: 'Channel for repeating notifications',
            importance: Importance.max,
            priority: Priority.high,
          ),
        ),
      );
    });
  }



  Future<void> showBigTextNotification() async {
    const BigTextStyleInformation
    bigTextStyleInformation = BigTextStyleInformation(
      '222222222222222222222222222222222222222222222222222222222222222222222222222222'
          '3333333333333333333333333333333333333333333333333333'
          '444444444444444444444444444444444444444444444444444444444444444444444'
          '55555555555555555555555555555555555555555555555555555555555555555555555555'
          '66666666666666666666666666666666666666666666666666666666666666666666666',
      htmlFormatBigText: true,
      contentTitle: 'Notifikasyon ak anpil teks',
      htmlFormatContentTitle: true,
      summaryText: 'summary <i>text</i>',
      htmlFormatSummaryText: true,
    );

    const AndroidNotificationDetails androidPlatformChannelSpecifics =
    AndroidNotificationDetails(
      'big_text_channel_id',
      'Big Text Notifications',
      channelDescription: 'Channel for big text notifications',
      styleInformation: bigTextStyleInformation,
    );

    const NotificationDetails platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
    );

    await flutterLocalNotificationsPlugin.show(
      id: 3,
      title: 'Big Text Notification',
      body: 'Expand to see more text',
      notificationDetails: platformChannelSpecifics,
    );
  }
}


