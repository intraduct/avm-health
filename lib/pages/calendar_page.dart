import 'dart:io';

import 'package:avm_symptom_tracker/widgets/app_drawer.dart';
import 'package:avm_symptom_tracker/database/database_helper.dart';
import 'package:avm_symptom_tracker/widgets/symptoms/summary_widget.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';

import '../model/journal_model.dart';

class CalendarPage extends StatefulWidget {
  const CalendarPage({super.key});

  @override
  State<CalendarPage> createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
  Future<Journal?> selectedJournal = initSelectedJournal();
  final CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  Future<List<DateTime>> daysWithData = Future.value([]);

  @override
  void initState() {
    super.initState();
    daysWithData = DatabaseHelper().fetchDaysWithData();
    _selectedDay = _focusedDay;
  }

  static Future<Journal?> initSelectedJournal() async {
    DateTime today = DateTime.now();
    return _getDataForDay(DateTime.utc(today.year, today.month, today.day));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'AVM Health',
          style: TextStyle(
            color: Theme.of(context).colorScheme.onPrimary,
          ),
        ),
        backgroundColor: Theme.of(context).colorScheme.primary,
      ),
      drawer: AppDrawer(
        onSettingsTap: () {
          selectedJournal = DatabaseHelper().fetchJournalByDate(_selectedDay!);
          setState(() {});
        },
      ),
      body: ListView(
        children: [
          FutureBuilder<List<DateTime>>(
            future: daysWithData,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              return TableCalendar<Journal>(
                firstDay: DateTime.parse("2023-01-01"),
                lastDay: DateTime.parse("2030-01-01"),
                startingDayOfWeek: StartingDayOfWeek.monday,
                eventLoader: (day) => getEntryForDay(day, snapshot.data!),
                onDaySelected: _onDaySelected,
                locale: Platform.localeName,
                focusedDay: _focusedDay,
                calendarFormat: _calendarFormat,
                availableCalendarFormats: const {CalendarFormat.month: "Monat"},
                selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
                onPageChanged: (focusedDay) => _focusedDay = focusedDay,
              );
            },
          ),
          const SizedBox(height: 8.0),
          FutureBuilder<Journal?>(
            future: selectedJournal,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              } else {
                if (snapshot.data == null) {
                  return Column(
                    children: [
                      ListTile(
                        title: Text(
                          DateFormat.yMd(Platform.localeName).format(_selectedDay!),
                          style: TextStyle(
                            fontSize: 24,
                            color: Theme.of(context).colorScheme.onSecondaryContainer,
                          ),
                        ),
                        trailing: ElevatedButton(
                          onPressed: () {
                            final newJournal = Journal(date: _selectedDay!);
                            DatabaseHelper()
                                .fetchAdditionalCategories(null)
                                .then((categories) => newJournal.additionalCategories = categories)
                                .then((_) => Navigator.pushNamed(context, '/input', arguments: newJournal))
                                .then((_) => setState(() {
                                      selectedJournal = Future.value(newJournal);
                                      daysWithData.then((days) => days.add(_selectedDay!));
                                    }));
                          },
                          child: const Icon(Icons.add),
                        ),
                        tileColor: Theme.of(context).colorScheme.secondaryContainer,
                      ),
                    ],
                  );
                }

                return SummaryWidget(journal: snapshot.data!);
              }
            },
          ),
        ],
      ),
    );
  }

  void _onDaySelected(DateTime selectedDay, DateTime focusedDay) async {
    if (!isSameDay(_selectedDay, selectedDay)) {
      setState(() {
        _selectedDay = selectedDay;
        _focusedDay = focusedDay;
        selectedJournal = _getDataForDay(selectedDay);
      });
    }
  }

  List<Journal> getEntryForDay(DateTime day, List<DateTime> days) {
    for (var element in days) {
      if (isSameDay(element, day)) {
        return [Journal(date: day)];
      }
    }

    return [];
  }

  static Future<Journal?> _getDataForDay(DateTime day) async {
    return DatabaseHelper().fetchJournalByDate(day);
  }
}
