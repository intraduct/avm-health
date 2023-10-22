import 'dart:async';
import 'dart:io';

import 'package:avm_symptom_tracker/pages/analysis_page.dart';
import 'package:avm_symptom_tracker/pages/calendar_page.dart';
import 'package:avm_symptom_tracker/pages/contact_page.dart';
import 'package:avm_symptom_tracker/pages/login_page.dart';
import 'package:avm_symptom_tracker/model/notification_model.dart';
import 'package:avm_symptom_tracker/model/settings_model.dart';
import 'package:avm_symptom_tracker/notifications/notifications_helper.dart' as nh;
import 'package:avm_symptom_tracker/pages/notifications_page.dart';
import 'package:avm_symptom_tracker/pages/settings_page.dart';
import 'package:avm_symptom_tracker/pages/input_page.dart';
import 'package:flutter/material.dart';
import 'model/journal_model.dart';
import 'package:intl/date_symbol_data_local.dart';

void main() async {
  nh
      .initializeFlutterLocalNotificationsPlugin()
      .then((_) => initializeDateFormatting(Platform.localeName, null).then((_) => runApp(const AvmHealthApp())));
}

class AvmHealthApp extends StatefulWidget {
  const AvmHealthApp({super.key});

  @override
  State<AvmHealthApp> createState() => _AvmHealthAppState();
}

class _AvmHealthAppState extends State<AvmHealthApp> {
  Timer? _timer;
  final _navigatorKey = GlobalKey<NavigatorState>();

  @override
  void initState() {
    super.initState();
    _resetLogoutTimer();
  }

  void _resetLogoutTimer() {
    _timer?.cancel();
    _timer = Timer(const Duration(minutes: 10), _logoutUser);
  }

  void _logoutUser() {
    _timer?.cancel();
    _timer = null;
    _navigatorKey.currentState?.pushNamedAndRemoveUntil('/login', (route) => false);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: _resetLogoutTimer,
      onPanDown: (_) => _resetLogoutTimer(),
      child: MaterialApp(
        navigatorKey: _navigatorKey,
        title: 'AVM Symptom Tracker',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.lightBlue),
          useMaterial3: true,
        ),
        initialRoute: '/login',
        routes: {
          '/login': (context) => const LoginPage(),
          '/calendar': (context) => const CalendarPage(),
          '/contacts': (context) => const ContactPage(),
        },
        onGenerateRoute: (route) {
          if (route.name == '/input') {
            final data = route.arguments as Journal;
            return MaterialPageRoute(
              builder: (context) {
                return SymptomInputPage(journal: data);
              },
            );
          } else if (route.name == '/settings') {
            final data = route.arguments as Settings;
            return MaterialPageRoute(builder: (context) {
              return SettingsPage(settings: data);
            });
          } else if (route.name == '/notifications') {
            final data = route.arguments as DbNotifications;
            return MaterialPageRoute(builder: (context) {
              return NotificationsPage(notifications: data);
            });
          } else if (route.name == '/analysis') {
            final data = route.arguments as List<Journal>;
            return MaterialPageRoute(builder: (context) {
              return AnalysisPage(journals: data);
            });
          }

          return null;
        },
      ),
    );
  }
}
