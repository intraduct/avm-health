import 'package:flutter/material.dart';

class DbNotifications {
  DbNotification inputReminder;
  List<DbNotification> medicationReminders;

  DbNotifications({required this.inputReminder, required this.medicationReminders});
}

class DbNotification {
  int? id;

  bool isEnabled;
  String title;
  String body;
  TimeOfDay time;
  NotificationType type;

  DbNotification({
    this.id,
    required this.isEnabled,
    required this.title,
    required this.body,
    required this.time,
    required this.type,
  });

  Map<String, Object?> toDatabaseMap() {
    return {
      'id': id,
      'isEnabled': isEnabled ? 1 : 0,
      'title': title,
      'body': body,
      'hour': time.hour,
      'minute': time.minute,
      'type': type.name
    };
  }
}

enum NotificationType {
  inputReminder,
  medicationReminder;

  static NotificationType fromString(String name) {
    return NotificationType.values.firstWhere(
      (value) => value.name == name,
      orElse: () => NotificationType.inputReminder,
    );
  }
}
