import 'dart:io';

import 'package:avm_symptom_tracker/database/database_helper.dart';
import 'package:avm_symptom_tracker/notifications/notifications_helper.dart' as nh;
import 'package:avm_symptom_tracker/widgets/symptoms/additional_parameters_widget.dart';
import 'package:avm_symptom_tracker/widgets/symptoms/location_widget.dart';
import 'package:avm_symptom_tracker/widgets/symptoms/medication_widget.dart';
import 'package:avm_symptom_tracker/widgets/symptoms/pain_widget.dart';
import 'package:avm_symptom_tracker/widgets/symptoms/photo_widget.dart';
import 'package:avm_symptom_tracker/widgets/symptoms/symptom_widget.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../model/journal_model.dart';

class SymptomInputPage extends StatefulWidget {
  final Journal journal;

  const SymptomInputPage({super.key, required this.journal});

  @override
  State<SymptomInputPage> createState() => _SymptomInputPageState();
}

class _SymptomInputPageState extends State<SymptomInputPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          DateFormat.yMEd(Platform.localeName).format(widget.journal.date),
          style: TextStyle(
            color: Theme.of(context).colorScheme.onPrimary,
          ),
        ),
        backgroundColor: Theme.of(context).colorScheme.primary,
      ),
      body: WillPopScope(
        onWillPop: () async {
          widget.journal.medications.removeWhere((m) => m.name.isEmpty);
          nh.cancelNotificationForDay(widget.journal.date);
          DatabaseHelper().storeJournal(widget.journal);
          return true;
        },
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                SymptomWidget(journal: widget.journal),
                PainWidget(journal: widget.journal),
                LocationWidget(journal: widget.journal),
                MedicationWidget(journal: widget.journal),
                PhotoWidget(journal: widget.journal),
                AdditionalParametersWidget(journal: widget.journal),
                const SizedBox(height: 200),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
