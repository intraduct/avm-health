import 'package:avm_symptom_tracker/model/journal_model.dart';
import 'package:flutter/material.dart';

import '../../database/database_helper.dart';

class MedicationWidget extends StatefulWidget {
  final Journal journal;
  final bool readOnly;

  const MedicationWidget({super.key, required this.journal, bool? readOnly}) : readOnly = readOnly ?? false;

  @override
  State<StatefulWidget> createState() => _MedicationWidgetState();
}

class _MedicationWidgetState extends State<MedicationWidget> {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Medikamente',
          style: TextStyle(fontSize: 20),
        ),
        const SizedBox(width: 10),
        for (int i = 0; i < widget.journal.medications.length; i++)
          Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
            Expanded(
              child: MedicationItemWidget(
                key: ValueKey(widget.journal.medications[i]),
                readOnly: widget.readOnly,
                initialValue: widget.journal.medications[i].name,
                onTextChanged: (value) => setState(() => widget.journal.medications[i].name = value),
                onDelete: () => setState(() => widget.journal.medications.removeAt(i)),
              ),
            ),
            if (!widget.readOnly)
              IconButton(
                icon: const Icon(Icons.delete),
                onPressed: () {
                  DatabaseHelper().deleteJournalMedication(widget.journal.medications[i]);
                  setState(() => widget.journal.medications.removeAt(i));
                },
              ),
          ]),
        if (widget.journal.medications.isEmpty)
          const Padding(padding: EdgeInsets.fromLTRB(0, 10, 0, 10), child: Text('Keine Medikamente erfasst.')),
        if (!widget.readOnly)
          ElevatedButton(
            onPressed: () {
              setState(() {
                final newItem = Medication(name: '');
                widget.journal.medications.add(newItem);
              });
            },
            child: const Icon(Icons.add),
          ),
        const SizedBox(height: 20),
      ],
    );
  }
}

class MedicationItemWidget extends StatelessWidget {
  final ValueChanged<String>? onTextChanged;
  final String? initialValue;
  final bool readOnly;

  final Function()? onDelete;

  const MedicationItemWidget({super.key, this.onTextChanged, this.onDelete, this.initialValue, required this.readOnly});

  @override
  Widget build(BuildContext context) {
    var textBox = readOnly
        ? Text(initialValue!)
        : TextFormField(
            initialValue: initialValue,
            readOnly: readOnly,
            onChanged: onTextChanged,
            decoration: const InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(10)),
                ),
                hintText: 'Name des Medikaments'),
          );

    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 8, 0, 8),
      child: textBox,
    );
  }
}
