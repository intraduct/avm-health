import 'package:avm_symptom_tracker/model/journal_model.dart';
import 'package:flutter/material.dart';

class SymptomWidget extends StatelessWidget {
  final Journal journal;
  final bool readOnly;

  const SymptomWidget({super.key, required this.journal, bool? readOnly}) : readOnly = readOnly ?? false;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Symptome',
          style: TextStyle(fontSize: 20),
        ),
        const SizedBox(height: 10),
        (readOnly)
            ? Text(journal.symptoms ?? 'Keine Symptome erfasst.')
            : Container(
                decoration: readOnly
                    ? null
                    : BoxDecoration(
                        border: Border.all(color: Colors.grey), // Add a border
                        borderRadius: BorderRadius.circular(10), // Add rounded corners
                      ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: TextFormField(
                    initialValue: journal.symptoms,
                    onChanged: (value) => journal.symptoms = value,
                    maxLines: 4, // Allow multiple lines
                    decoration: const InputDecoration(
                      hintText: 'Bitte Symptome eingeben',
                      border: InputBorder.none,
                    ),
                  ),
                ),
              ),
        const SizedBox(height: 20),
      ],
    );
  }
}
