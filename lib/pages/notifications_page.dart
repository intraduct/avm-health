import 'dart:io';

import 'package:avm_symptom_tracker/database/database_helper.dart';
import 'package:avm_symptom_tracker/model/notification_model.dart';
import 'package:avm_symptom_tracker/notifications/notifications_helper.dart' as nh;
import 'package:avm_symptom_tracker/widgets/notifications/notification_widget.dart';
import 'package:flutter/material.dart';

class NotificationsPage extends StatefulWidget {
  final DbNotifications notifications;

  const NotificationsPage({super.key, required this.notifications});

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  bool notificationPermission = false;

  @override
  void initState() {
    super.initState();
    _isAndroidPermissionGranted().then((_) {
      if (!notificationPermission) {
        widget.notifications.inputReminder.isEnabled == false;
        for (var notification in widget.notifications.medicationReminders) {
          notification.isEnabled = false;
        }
      }
    });
  }

  Future<void> _isAndroidPermissionGranted() async {
    if (Platform.isAndroid) {
      final bool granted = await nh.isAndroidPermissionGranted();

      setState(() {
        notificationPermission = granted;
      });
    }
  }

  Future<void> requestPermissions() async {
    await nh.requestPermissions().then((value) => setState(() => notificationPermission = value));
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        return DatabaseHelper()
            .storeNotifications(widget.notifications)
            .then((_) => nh.scheduleNotifications(widget.notifications))
            .then((_) => true);
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            'Erinnerungen',
            style: TextStyle(
              color: Theme.of(context).colorScheme.onPrimary,
            ),
          ),
          backgroundColor: Theme.of(context).colorScheme.primary,
        ),
        body: Padding(
          padding: const EdgeInsets.all(20),
          child: ListView(
            children: [
              const Text(
                'Allgemein',
                style: TextStyle(fontSize: 20),
              ),
              NotificationWidget(
                notification: widget.notifications.inputReminder,
                onTimeChanged: (time) => setState(() => widget.notifications.inputReminder.time = time),
                onSwitchChanged: (value) {
                  if (notificationPermission) {
                    setState(() => widget.notifications.inputReminder.isEnabled = value);
                  } else {
                    requestPermissions().then((_) =>
                        setState(() => widget.notifications.inputReminder.isEnabled = notificationPermission && value));
                  }
                },
              ),
              const SizedBox(height: 20),
              const Text(
                'Medikamente',
                style: TextStyle(fontSize: 20),
              ),
              ...widget.notifications.medicationReminders.map(
                (notification) => NotificationWidget(
                  notification: notification,
                  onTimeChanged: (time) => setState(() => notification.time = time),
                  onSwitchChanged: (value) {
                    if (notificationPermission) {
                      setState(() => notification.isEnabled = value);
                    } else {
                      requestPermissions()
                          .then((_) => setState(() => notification.isEnabled = notificationPermission && value));
                    }
                  },
                  onDelete: () {
                    setState(() => widget.notifications.medicationReminders.remove(notification));
                    if (notification.id == null) {
                      return;
                    }

                    nh
                        .cancelNotification(notification.id!)
                        .then((_) => DatabaseHelper().deleteNotification(notification));
                  },
                ),
              ),
              ListTile(
                title: const Text('Erinnerung hinzufügen'),
                contentPadding: EdgeInsets.zero,
                leading: ElevatedButton(
                  onPressed: () {
                    setState(
                      () => widget.notifications.medicationReminders.add(
                        DbNotification(
                          isEnabled: false,
                          title: '',
                          body: '',
                          time: TimeOfDay.now(),
                          type: NotificationType.medicationReminder,
                        ),
                      ),
                    );
                  },
                  child: const Icon(Icons.add),
                ),
              ),

              // For testing purpose
              // const Divider(),
              // ListTile(
              //   title: const Text('Send test notification'),
              //   trailing: ElevatedButton(
              //     onPressed: () async => await nh.showNotification(
              //         0, 'Tägliche Dateneingabe', 'Denke daran, den heutigen Tag in der App zu erfassen!'),
              //     child: const Icon(Icons.notifications),
              //   ),
              // ),
              // ListTile(
              //   title: const Text('Cancel all notifications'),
              //   trailing: ElevatedButton(
              //     onPressed: () async => await nh.cancelAllNotifications(),
              //     child: const Icon(Icons.notifications_off),
              //   ),
              // ),
            ],
          ),
        ),
      ),
    );
  }
}
