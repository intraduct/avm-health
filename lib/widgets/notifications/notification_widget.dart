import 'dart:math';

import 'package:avm_symptom_tracker/model/notification_model.dart';
import 'package:flutter/material.dart';

class NotificationWidget extends StatefulWidget {
  final DbNotification notification;
  final Function(TimeOfDay) onTimeChanged;
  final Function(bool) onSwitchChanged;
  final Function()? onDelete;

  const NotificationWidget(
      {super.key,
      required this.notification,
      required this.onTimeChanged,
      required this.onSwitchChanged,
      this.onDelete});

  @override
  State<NotificationWidget> createState() => _NotificationWidgetState();
}

class _NotificationWidgetState extends State<NotificationWidget> {
  @override
  Widget build(BuildContext context) {
    var notificationTile = ListTile(
      onTap: () => showTimePicker(context: context, initialTime: widget.notification.time).then((value) {
        if (value != null) {
          widget.onTimeChanged(value);
        }
      }),
      title: Text(
        widget.notification.time.format(context),
        style: TextStyle(fontSize: 18, color: widget.notification.isEnabled ? Colors.black : Colors.grey),
      ),
      subtitle: buildSubtitle(),
      trailing: Switch(
        value: widget.notification.isEnabled,
        onChanged: widget.onSwitchChanged,
      ),
    );

    return widget.notification.type == NotificationType.inputReminder
        ? notificationTile
        : Dismissible(
            key: Key('${widget.notification.id ?? Random().nextDouble()}'),
            direction: DismissDirection.endToStart,
            onDismissed: (direction) => widget.onDelete?.call(),
            background: Container(
              color: Colors.red, // Hintergrundfarbe, wenn das Element entfernt wird
              alignment: Alignment.centerRight,
              padding: const EdgeInsets.only(right: 20.0),
              child: const Icon(Icons.delete, color: Colors.white),
            ),
            child: notificationTile,
          );
  }

  Widget buildSubtitle() {
    if (widget.notification.type == NotificationType.inputReminder) {
      return Text(
        widget.notification.title,
        style: TextStyle(color: widget.notification.isEnabled ? Colors.black : Colors.grey),
      );
    }

    return GestureDetector(
      onTap: () {
        // Show a dialog to edit the subtitle
        showDialog(
          context: context,
          builder: (context) {
            String newSubtitle = widget.notification.title;
            return AlertDialog(
              title: const Text("Name des Medikaments"),
              content: TextField(
                controller: TextEditingController(text: widget.notification.title),
                decoration: const InputDecoration(hintText: 'Bitte eingeben'),
                onChanged: (text) {
                  newSubtitle = text;
                },
              ),
              actions: <Widget>[
                TextButton(
                  child: const Text("Abbrechen"),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
                TextButton(
                  child: const Text("Speichern"),
                  onPressed: () {
                    // Save the new subtitle and close the dialog
                    setState(() => widget.notification.title = newSubtitle);
                    Navigator.of(context).pop();
                  },
                ),
              ],
            );
          },
        );
      },
      child: Text(
        widget.notification.title != '' ? widget.notification.title : 'Name des Medikaments',
        style: TextStyle(color: widget.notification.isEnabled ? Colors.black : Colors.grey),
      ),
    );
  }
}
