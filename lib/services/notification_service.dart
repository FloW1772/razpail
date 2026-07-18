import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

import '../models/reminder.dart';
import '../models/recurrence.dart';

/// Planifie et annule les notifications locales des rappels.
///
/// Aucune donnée ne quitte l'appareil : tout passe par le plugin
/// flutter_local_notifications, qui s'appuie sur AlarmManager côté Android.
class NotificationService {
  NotificationService._();

  static final NotificationService instance = NotificationService._();

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  static const AndroidNotificationDetails _androidDetails =
      AndroidNotificationDetails(
    'anniversaires_channel',
    'Rappels d\'anniversaires',
    channelDescription: 'Notifications des rappels d\'anniversaires',
    importance: Importance.high,
    priority: Priority.high,
    category: AndroidNotificationCategory.event,
  );

  bool _initialized = false;

  Future<void> init() async {
    if (_initialized) return;

    tz_data.initializeTimeZones();
    tz.setLocalLocation(tz.local);

    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
    const initSettings = InitializationSettings(android: androidInit);
    await _plugin.initialize(initSettings);

    _initialized = true;
  }

  /// Demande la permission de notification (obligatoire sur Android 13+).
  Future<bool> requestPermission() async {
    final androidPlugin = _plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    final granted =
        await androidPlugin?.requestNotificationsPermission() ?? true;
    await androidPlugin?.requestExactAlarmsPermission();
    return granted;
  }

  /// L'id de notification est dérivé du hash de l'id du rappel pour rester
  /// stable et tenir sur 31 bits (limite d'AlarmManager).
  int _notificationId(String reminderId) => reminderId.hashCode & 0x7fffffff;

  Future<void> scheduleForReminder(Reminder reminder) async {
    await cancelForReminder(reminder.id);

    final scheduled = tz.TZDateTime(
      tz.local,
      reminder.date.year,
      reminder.date.month,
      reminder.date.day,
      reminder.notificationHour,
      reminder.notificationMinute,
    );

    var next = scheduled;
    final now = tz.TZDateTime.now(tz.local);
    if (next.isBefore(now)) {
      if (reminder.recurrence == Recurrence.once) {
        // Rappel unique déjà passé : rien à planifier.
        return;
      }
      next = tz.TZDateTime(
        tz.local,
        now.year,
        reminder.date.month,
        reminder.date.day,
        reminder.notificationHour,
        reminder.notificationMinute,
      );
      if (next.isBefore(now)) {
        next = tz.TZDateTime(
          tz.local,
          now.year + 1,
          reminder.date.month,
          reminder.date.day,
          reminder.notificationHour,
          reminder.notificationMinute,
        );
      }
    }

    await _plugin.zonedSchedule(
      _notificationId(reminder.id),
      reminder.name,
      reminder.message,
      next,
      const NotificationDetails(android: _androidDetails),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      matchDateTimeComponents: reminder.recurrence == Recurrence.yearly
          ? DateTimeComponents.dateAndTime
          : null,
    );
  }

  Future<void> cancelForReminder(String reminderId) async {
    await _plugin.cancel(_notificationId(reminderId));
  }

  /// Reprogramme l'ensemble des rappels fournis, notamment après un
  /// redémarrage du téléphone ou une mise à jour de l'application.
  Future<void> rescheduleAll(List<Reminder> reminders) async {
    for (final reminder in reminders) {
      await scheduleForReminder(reminder);
    }
  }
}
