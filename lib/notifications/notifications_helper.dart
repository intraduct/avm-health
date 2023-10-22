import 'dart:io';

import 'package:avm_symptom_tracker/database/database_helper.dart';
import 'package:avm_symptom_tracker/model/notification_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

Future<void> initializeFlutterLocalNotificationsPlugin() async {
  WidgetsFlutterBinding.ensureInitialized();
  await _configureLocalTimeZone();

  final InitializationSettings initializationSettings = InitializationSettings(
    android: const AndroidInitializationSettings('notification_icon'),
    iOS: DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
      onDidReceiveLocalNotification: (int id, String? title, String? body, String? payload) async {},
    ),
  );

  await flutterLocalNotificationsPlugin.initialize(
    initializationSettings,
    onDidReceiveNotificationResponse: (NotificationResponse notificationResponse) {},
    onDidReceiveBackgroundNotificationResponse: _notificationTapBackground,
  );
}

@pragma('vm:entry-point')
void _notificationTapBackground(NotificationResponse notificationResponse) {
  // ignore: avoid_print
  print('notification(${notificationResponse.id}) action tapped: '
      '${notificationResponse.actionId} with'
      ' payload: ${notificationResponse.payload}');
  if (notificationResponse.input?.isNotEmpty ?? false) {
    // ignore: avoid_print
    print('notification action tapped with input: ${notificationResponse.input}');
  }
}

Future<void> _configureLocalTimeZone() async {
  tz.initializeTimeZones();
  final String timeZoneName = await FlutterTimezone.getLocalTimezone();
  tz.setLocalLocation(tz.getLocation(timeZoneName));
}

Future<bool> isAndroidPermissionGranted() async {
  return await flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
          ?.areNotificationsEnabled() ??
      false;
}

/// Android: If a user declines twice, he will NOT be prompted again and needs to turn on Notifications in the Settings
Future<bool> requestPermissions() async {
  if (Platform.isIOS) {
    return await flutterLocalNotificationsPlugin
            .resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>()
            ?.requestPermissions(
              alert: true,
              badge: true,
              sound: true,
            ) ??
        false;
  } else if (Platform.isAndroid) {
    final AndroidFlutterLocalNotificationsPlugin? androidImplementation =
        flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();

    return await androidImplementation?.requestNotificationsPermission() ?? false;
  }

  return false;
}

Future<void> showNotification(int id, String title, String body) async {
  const NotificationDetails notificationDetails = NotificationDetails(
      android: AndroidNotificationDetails('AVM Health ChannelId', 'AVM Health Channel',
          channelDescription: 'AVM Health Channel - Notifications',
          importance: Importance.max,
          priority: Priority.high,
          ticker: 'ticker'));
  await flutterLocalNotificationsPlugin.show(id, title, body, notificationDetails);
}

Future<void> scheduleNotifications(DbNotifications notifications) async {
  if (!notifications.inputReminder.isEnabled) {
    _cancelAllInputNotifications();
  } else {
    await _scheduleInputReminder(notifications.inputReminder);
    _cancelDaysWithData();
  }

  for (final notification in notifications.medicationReminders) {
    if (!notification.isEnabled) {
      cancelNotification(notification.id!);
    } else {
      _scheduleDailyMedicationNotification(notification);
    }
  }
}

Future<void> _cancelDaysWithData() {
  return DatabaseHelper().fetchDaysWithData().then((days) {
    for (final day in days) {
      cancelNotificationForDay(day);
    }
  });
}

Future<void> _scheduleDailyMedicationNotification(DbNotification notification) async {
  var now = tz.TZDateTime.now(tz.local);
  await flutterLocalNotificationsPlugin.zonedSchedule(
      notification.id!,
      'Nicht vergessen!',
      'Es ist Zeit für deine ${notification.title != '' ? notification.title : 'Medikamenten'}-Dosis.',
      tz.TZDateTime(tz.local, now.year, now.month, now.day, notification.time.hour, notification.time.minute),
      const NotificationDetails(
          android: AndroidNotificationDetails('AVM Health ChannelId', 'AVM Health Channel',
              channelDescription: 'AVM Health Channel - Notifications')),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time);
}

Future<void> _scheduleInputReminder(DbNotification notification) async {
  List<_IdWithDate> idWithDateList = _generateFutureDailyNotifications(notification.time);

  for (var idWidthDate in idWithDateList) {
    await flutterLocalNotificationsPlugin.zonedSchedule(
        idWidthDate.id,
        notification.title,
        notification.body,
        idWidthDate.scheduledDate,
        const NotificationDetails(
            android: AndroidNotificationDetails('AVM Health ChannelId', 'AVM Health Channel',
                channelDescription: 'AVM Health Channel - Notifications')),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime);
  }
}

List<_IdWithDate> _generateFutureDailyNotifications(TimeOfDay time) {
  var now = tz.TZDateTime.now(tz.local);
  return List.generate(30, (i) {
    var scheduledDate =
        tz.TZDateTime(tz.local, now.year, now.month, now.day, time.hour, time.minute).add(Duration(days: i));
    scheduledDate =
        tz.TZDateTime(tz.local, scheduledDate.year, scheduledDate.month, scheduledDate.day, time.hour, time.minute);
    return _IdWithDate(scheduledDate: scheduledDate);
  }).where((n) => n.scheduledDate.isAfter(now)).toList();
}

Future<void> _cancelAllInputNotifications() async {
  List<int> idsToCancel = _generateFutureDailyNotifications(TimeOfDay.now()).map((e) => e.id).toList();

  for (int id in idsToCancel) {
    flutterLocalNotificationsPlugin.cancel(id);
  }
}

Future<void> cancelAllNotifications() async {
  return flutterLocalNotificationsPlugin.cancelAll();
}

Future<void> cancelNotification(int id) async {
  return flutterLocalNotificationsPlugin.cancel(id);
}

class _IdWithDate {
  int id;
  tz.TZDateTime scheduledDate;

  _IdWithDate({required this.scheduledDate})
      : id = _getIdForDate(scheduledDate.year, scheduledDate.month, scheduledDate.day);

  @override
  String toString() {
    return '$id: $scheduledDate';
  }
}

int _getIdForDate(int year, int month, int day) {
  return ((year * 100) + month) * 100 + day;
}

Future<void> cancelNotificationForDay(DateTime day) async {
  return flutterLocalNotificationsPlugin.cancel(_getIdForDate(day.year, day.month, day.day));
}
