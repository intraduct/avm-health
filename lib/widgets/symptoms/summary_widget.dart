import 'dart:io';

import 'package:avm_symptom_tracker/widgets/symptoms/additional_parameters_widget.dart';
import 'package:avm_symptom_tracker/widgets/symptoms/location_widget.dart';
import 'package:avm_symptom_tracker/widgets/symptoms/medication_widget.dart';
import 'package:avm_symptom_tracker/widgets/symptoms/pain_widget.dart';
import 'package:avm_symptom_tracker/widgets/symptoms/photo_widget.dart';
import 'package:avm_symptom_tracker/widgets/symptoms/symptom_widget.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../model/journal_model.dart';

class SummaryWidget extends StatefulWidget {
  final Journal journal;

  const SummaryWidget({super.key, required this.journal});

  @override
  State<SummaryWidget> createState() => _SummaryWidgetState();
}

class _SummaryWidgetState extends State<SummaryWidget> {
  ValueNotifier<DateTime> notifier = ValueNotifier(DateTime.now());

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
        child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        ListTile(
          title: Text(
            DateFormat.yMd(Platform.localeName).format(widget.journal.date),
            style: TextStyle(
              fontSize: 24,
              color: Theme.of(context).colorScheme.onSecondaryContainer,
            ),
          ),
          trailing: ElevatedButton(
            onPressed: () => Navigator.pushNamed(context, '/input', arguments: widget.journal)
                .then((_) => notifier.value = DateTime.now()),
            child: const Icon(Icons.edit),
          ),
          tileColor: Theme.of(context).colorScheme.secondaryContainer,
        ),
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: ValueListenableBuilder(
            valueListenable: notifier,
            builder: (context, value, child) => Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SymptomWidget(journal: widget.journal, readOnly: true),
                PainWidget(journal: widget.journal, readOnly: true),
                LocationWidget(journal: widget.journal, readOnly: true),
                MedicationWidget(journal: widget.journal, readOnly: true),
                PhotoWidget(journal: widget.journal, readOnly: true),
                AdditionalParametersWidget(journal: widget.journal, readOnly: true),
              ],
            ),
          ),
        ),
        const SizedBox(height: 100),
      ],
    ));
  }
}
