import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io' show Platform;

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();
  bool _isInitialized = false;

  // Notification IDs for each prayer
  static const int fajrId = 1;
  static const int dhuhrId = 2;
  static const int asrId = 3;
  static const int maghribId = 4;
  static const int ishaId = 5;

  // Initialize the notification service
  Future<void> initialize() async {
    if (_isInitialized) return;

    // Initialize timezone
    tz.initializeTimeZones();
    tz.setLocalLocation(tz.getLocation('Africa/Tunis')); // Default to Tunisia

    // Android initialization settings
    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    // iOS initialization settings
    const DarwinInitializationSettings iosSettings =
        DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    // Combined initialization settings
    const InitializationSettings initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    // Initialize
    await _notifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationTap,
    );

    _isInitialized = true;
  }

  // Handle notification tap
  void _onNotificationTap(NotificationResponse response) {
    // Handle what happens when user taps notification
    print('Notification tapped: ${response.payload}');
  }

  // Request notification permissions (especially for iOS and Android 13+)
  Future<bool> requestPermissions() async {
    if (Platform.isAndroid) {
      final AndroidFlutterLocalNotificationsPlugin? androidImplementation =
          _notifications.resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>();

      if (androidImplementation != null) {
        final bool? granted =
            await androidImplementation.requestNotificationsPermission();
        return granted ?? false;
      }
    } else if (Platform.isIOS) {
      final bool? granted = await _notifications
          .resolvePlatformSpecificImplementation<
              IOSFlutterLocalNotificationsPlugin>()
          ?.requestPermissions(
            alert: true,
            badge: true,
            sound: true,
          );
      return granted ?? false;
    }
    return true;
  }

  // Schedule prayer notifications
  Future<void> schedulePrayerNotifications({
    required String fajr,
    required String dhuhr,
    required String asr,
    required String maghrib,
    required String isha,
  }) async {
    if (!_isInitialized) {
      await initialize();
    }

    // Get notification preferences
    final prefs = await SharedPreferences.getInstance();
    final bool notificationsEnabled =
        prefs.getBool('notifications_enabled') ?? true;

    if (!notificationsEnabled) {
      return; // Don't schedule if disabled
    }

    // Get individual prayer notification settings
    final bool fajrEnabled = prefs.getBool('notification_fajr') ?? true;
    final bool dhuhrEnabled = prefs.getBool('notification_dhuhr') ?? true;
    final bool asrEnabled = prefs.getBool('notification_asr') ?? true;
    final bool maghribEnabled = prefs.getBool('notification_maghrib') ?? true;
    final bool ishaEnabled = prefs.getBool('notification_isha') ?? true;

    // Cancel all existing notifications first
    await cancelAllNotifications();

    // Schedule each prayer
    if (fajrEnabled) {
      await _schedulePrayerNotification(
        id: fajrId,
        title: '🕌 Fajr',
        body: "C'est l'heure de la prière du Fajr",
        time: fajr,
      );
    }

    if (dhuhrEnabled) {
      await _schedulePrayerNotification(
        id: dhuhrId,
        title: '🕌 Dhuhr',
        body: "C'est l'heure de la prière du Dhuhr",
        time: dhuhr,
      );
    }

    if (asrEnabled) {
      await _schedulePrayerNotification(
        id: asrId,
        title: '🕌 Asr',
        body: "C'est l'heure de la prière de l'Asr",
        time: asr,
      );
    }

    if (maghribEnabled) {
      await _schedulePrayerNotification(
        id: maghribId,
        title: '🕌 Maghrib',
        body: "C'est l'heure de la prière du Maghrib",
        time: maghrib,
      );
    }

    if (ishaEnabled) {
      await _schedulePrayerNotification(
        id: ishaId,
        title: '🕌 Isha',
        body: "C'est l'heure de la prière de l'Isha",
        time: isha,
      );
    }

    print('✅ Prayer notifications scheduled successfully');
  }

  // Schedule a single prayer notification
  Future<void> _schedulePrayerNotification({
    required int id,
    required String title,
    required String body,
    required String time,
  }) async {
    try {
      // Parse time (format: "HH:mm")
      final timeParts = time.split(':');
      if (timeParts.length != 2) return;

      final int hour = int.parse(timeParts[0]);
      final int minute = int.parse(timeParts[1]);

      // Get current time
      final now = tz.TZDateTime.now(tz.local);

      // Schedule for today
      var scheduledDate = tz.TZDateTime(
        tz.local,
        now.year,
        now.month,
        now.day,
        hour,
        minute,
      );

      // If the time has already passed today, schedule for tomorrow
      if (scheduledDate.isBefore(now)) {
        scheduledDate = scheduledDate.add(const Duration(days: 1));
      }
// Notification details
      const AndroidNotificationDetails androidDetails =
          AndroidNotificationDetails(
        'prayer_times_channel_v2',
        'Prayer Times',
        channelDescription: 'Notifications for prayer times',
        importance: Importance.high,
        priority: Priority.high,
        sound: RawResourceAndroidNotificationSound('azan'), // ✅ RÉACTIVÉ
        playSound: true,
        enableVibration: true,
      );

      const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
        sound: 'azan.mp3', 
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      );

      const NotificationDetails notificationDetails = NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      );

      // Schedule the notification
      await _notifications.zonedSchedule(
        id,
        title,
        body,
        scheduledDate,
        notificationDetails,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents:
            DateTimeComponents.time, // Repeat daily at the same time
      );

      print('✅ Scheduled $title for ${scheduledDate.toString()}');
    } catch (e) {
      print('❌ Error scheduling notification for $title: $e');
    }
  }

  // Show an immediate notification (for testing)
  Future<void> showImmediateNotification({
    required String title,
    required String body,
  }) async {
    if (!_isInitialized) {
      await initialize();
    }

    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
      'test_channel',
      'Test Notifications',
      channelDescription: 'Test notifications',
      importance: Importance.high,
      priority: Priority.high,
    );

    const DarwinNotificationDetails iosDetails = DarwinNotificationDetails();

    const NotificationDetails notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notifications.show(
      0,
      title,
      body,
      notificationDetails,
    );
  }

  // Cancel all notifications
  Future<void> cancelAllNotifications() async {
    await _notifications.cancelAll();
    print('🗑️ All notifications cancelled');
  }

  // Cancel a specific prayer notification
  Future<void> cancelPrayerNotification(int prayerId) async {
    await _notifications.cancel(prayerId);
    print('🗑️ Notification $prayerId cancelled');
  }

  // Get pending notifications (for debugging)
  Future<List<PendingNotificationRequest>> getPendingNotifications() async {
    return await _notifications.pendingNotificationRequests();
  }

  // Save notification preferences
  Future<void> saveNotificationPreferences({
    required bool enabled,
    bool? fajr,
    bool? dhuhr,
    bool? asr,
    bool? maghrib,
    bool? isha,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('notifications_enabled', enabled);

    if (fajr != null) await prefs.setBool('notification_fajr', fajr);
    if (dhuhr != null) await prefs.setBool('notification_dhuhr', dhuhr);
    if (asr != null) await prefs.setBool('notification_asr', asr);
    if (maghrib != null) await prefs.setBool('notification_maghrib', maghrib);
    if (isha != null) await prefs.setBool('notification_isha', isha);
  }

  // Get notification preferences
  Future<Map<String, bool>> getNotificationPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    return {
      'enabled': prefs.getBool('notifications_enabled') ?? true,
      'fajr': prefs.getBool('notification_fajr') ?? true,
      'dhuhr': prefs.getBool('notification_dhuhr') ?? true,
      'asr': prefs.getBool('notification_asr') ?? true,
      'maghrib': prefs.getBool('notification_maghrib') ?? true,
      'isha': prefs.getBool('notification_isha') ?? true,
    };
  }
}
