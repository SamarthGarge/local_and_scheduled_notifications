import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import 'package:flutter_timezone/flutter_timezone.dart';

class NotiService {
  NotiService._privateConstructor();
  static final NotiService _instance = NotiService._privateConstructor();
  factory NotiService() => _instance;

  final notificationsPlugin = FlutterLocalNotificationsPlugin();
  bool _isInitialized = false;

  bool get isInitialized => _isInitialized;

  // Initialize
  Future<void> initNotification() async {
    if (_isInitialized) return; // prevent re-initialization

    // Request notificationo permissions
    final AndroidFlutterLocalNotificationsPlugin? androidPlugin =
        notificationsPlugin.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();

    await androidPlugin?.requestNotificationsPermission();

    // init timezone handling
    tz.initializeTimeZones();

    try {
      final String currentTimeZone = await FlutterTimezone.getLocalTimezone();

      // Fix incorrect "Asia/Calcutta" issue
      final String fixedTimeZone = (currentTimeZone == "Asia/Calcutta")
          ? "Asia/Kolkata"
          : currentTimeZone;

      tz.setLocalLocation(tz.getLocation(fixedTimeZone));
    } catch (e) {
      print("Error getting timezone: $e");
      tz.setLocalLocation(
          tz.getLocation("Asia/Kolkata")); // Use default fallback
    }
    // final String currentTimeZone = await FlutterTimezone.getLocalTimezone();
    // tz.setLocalLocation(tz.getLocation(currentTimeZone));

    // init android
    const AndroidInitializationSettings initSettingsAndroid =
        AndroidInitializationSettings("@mipmap/ic_launcher");

    // init ios
    const DarwinInitializationSettings initSettingsIOS =
        DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    // init settings
    const InitializationSettings initSettings = InitializationSettings(
      android: initSettingsAndroid,
      iOS: initSettingsIOS,
    );

    // init
    await notificationsPlugin.initialize(initSettings);
    _isInitialized = true;
  }

  // Noti details setup
  NotificationDetails notificationDetails() {
    return const NotificationDetails(
      android: AndroidNotificationDetails(
        'daily_channel_id',
        'Daily Notifications',
        channelDescription: 'Daily notification channel',
        importance: Importance.max,
        priority: Priority.high,
      ),
      iOS: DarwinNotificationDetails(),
    );
  }

  // Show an immediate notification
  Future<void> showNotification({
    int id = 0,
    String? title,
    String? body,
    String? payload,
  }) async {
    return notificationsPlugin.show(
      id,
      title,
      body,
      notificationDetails(),
    );
  }

  /* 

  Schedule a notification at a specified time (e.g. 11pm)

  - hour (0-23)
  - minute (0-59)

  */
  Future<void> scheduleNotification(
      {int id = 1,
      required String title,
      required String body,
      required int hour,
      required int minute}) async {
    // Get the current date/time in device's local timezone
    final now = tz.TZDateTime.now(tz.local);

    // Create a date/time for today at the specified hour/min
    var scheduledDate = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      hour,
      minute,
    );

    // Schedule the notification
    await notificationsPlugin.zonedSchedule(
      id,
      title,
      body,
      scheduledDate,
      notificationDetails(),

      // iOS specific: Use exact time specified (vs relative time)
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,

      // Android specific: Allow notification while device is in low_power mode
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,

      // Make notification repeat daily at same time
      matchDateTimeComponents: DateTimeComponents.time,
    );

    print("Notification Scheduled");
  }

  // Cancel all notifications
  Future<void> cancelAllNotifications() async {
    await notificationsPlugin.cancelAll();
  }
}
