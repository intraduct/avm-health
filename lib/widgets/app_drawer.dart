import 'package:avm_symptom_tracker/database/database_helper.dart';
import 'package:flutter/material.dart';

class AppDrawer extends StatelessWidget {
  final VoidCallback onSettingsTap;

  const AppDrawer({super.key, required this.onSettingsTap});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        children: [
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                DrawerHeader(
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  child: ListTile(
                    leading: Image.asset('assets/icons/app_icon.png'),
                    title: Text(
                      'Alltagsstudie Vaskuläre Malformation',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onPrimary,
                        fontSize: 24,
                      ),
                    ),
                  ),
                ),
                ListTile(
                  leading: const Icon(Icons.calendar_month),
                  title: const Text('Kalender'),
                  onTap: () => Navigator.of(context).pop(),
                ),
                // Implementation of analysis incomplete, left in as an example
                // ListTile(
                //   leading: const Icon(Icons.data_exploration_rounded),
                //   title: const Text('Auswertungen'),
                //   onTap: () {
                //     DatabaseHelper()
                //         .fetchJournals()
                //         .then((journals) => Navigator.pushNamed(context, '/analysis', arguments: journals))
                //         .then((_) => onSettingsTap());
                //   },
                // ),
                ListTile(
                  leading: const Icon(Icons.notifications_active),
                  title: const Text('Erinnerungen'),
                  onTap: () => DatabaseHelper()
                      .fetchNotifications()
                      .then((notification) => Navigator.pushNamed(context, '/notifications', arguments: notification)),
                ),
                ListTile(
                  leading: const Icon(Icons.settings),
                  title: const Text('Einstellungen'),
                  onTap: () {
                    DatabaseHelper()
                        .fetchSettings()
                        .then((settings) => Navigator.pushNamed(context, '/settings', arguments: settings))
                        .then((_) => onSettingsTap());
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.person_pin_circle_rounded),
                  title: const Text('Ansprechpartner'),
                  onTap: () {
                    DatabaseHelper()
                        .fetchSettings()
                        .then((settings) => Navigator.pushNamed(context, '/contacts', arguments: settings))
                        .then((_) => onSettingsTap());
                  },
                ),
              ],
            ),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.logout_rounded),
            title: const Text('Logout'),
            onTap: () => Navigator.pushReplacementNamed(context, '/login'),
          ),
        ],
      ),
    );
  }
}
