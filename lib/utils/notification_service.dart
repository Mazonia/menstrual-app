import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz_init;

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  Future<void> initialize() async {
    tz_init.initializeTimeZones();

    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const DarwinInitializationSettings initializationSettingsIOS =
        DarwinInitializationSettings(
          requestAlertPermission: true,
          requestBadgePermission: true,
          requestSoundPermission: true,
        );

    const InitializationSettings initializationSettings =
        InitializationSettings(
          android: initializationSettingsAndroid,
          iOS: initializationSettingsIOS,
        );

    await _flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }

  Future<void> schedulePeriodReminder(DateTime periodStartDate) async {
    // Schedule a notification 2 days before the period is due to start
    DateTime notificationDate = periodStartDate.subtract(
      const Duration(days: 2),
    );

    // Only schedule if the notification date is in the future
    if (notificationDate.isAfter(DateTime.now())) {
      await _flutterLocalNotificationsPlugin.zonedSchedule(
        1, // ID for period reminder
        'Period Reminder',
        'Your period is expected to start in 2 days',
        tz.TZDateTime.from(
          notificationDate,
          tz.local,
        ).add(const Duration(hours: 9)), // 9 AM
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'period_channel',
            'Period Reminders',
            channelDescription: 'Channel for period reminders',
            importance: Importance.high,
            priority: Priority.high,
          ),
          iOS: DarwinNotificationDetails(),
        ),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
      );
    }
  }

  Future<void> scheduleOvulationReminder(DateTime ovulationDate) async {
    // Schedule a notification 1 day before ovulation
    DateTime notificationDate = ovulationDate.subtract(const Duration(days: 1));

    // Only schedule if the notification date is in the future
    if (notificationDate.isAfter(DateTime.now())) {
      await _flutterLocalNotificationsPlugin.zonedSchedule(
        2, // ID for ovulation reminder
        'Fertility Window',
        'Your fertile window is starting soon',
        tz.TZDateTime.from(
          notificationDate,
          tz.local,
        ).add(const Duration(hours: 9)), // 9 AM
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'fertility_channel',
            'Fertility Reminders',
            channelDescription: 'Channel for fertility reminders',
            importance: Importance.high,
            priority: Priority.high,
          ),
          iOS: DarwinNotificationDetails(),
        ),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
      );
    }
  }

  Future<void> cancelAllNotifications() async {
    await _flutterLocalNotificationsPlugin.cancelAll();
  }
}
