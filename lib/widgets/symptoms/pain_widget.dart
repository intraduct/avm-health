import 'package:avm_symptom_tracker/database/database_helper.dart';
import 'package:flutter/material.dart';

import '../../model/journal_model.dart';

class PainWidget extends StatefulWidget {
  final Journal journal;
  final bool readOnly;

  const PainWidget({super.key, required this.journal, bool? readOnly}) : readOnly = readOnly ?? false;

  @override
  State<PainWidget> createState() => _PainWidgetState();
}

class _PainWidgetState extends State<PainWidget> {
  static const Map<int, String> painQuantities = {
    0: 'assets/images/pain-0.png',
    2: 'assets/images/pain-2.png',
    4: 'assets/images/pain-4.png',
    6: 'assets/images/pain-6.png',
    8: 'assets/images/pain-8.png',
    10: 'assets/images/pain-10.png',
  };

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Schmerzen',
          style: TextStyle(fontSize: 20),
        ),
        // const SizedBox(height: 10),
        LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraints) {
            double maxWidth = constraints.maxWidth;
            double buttonWidth = maxWidth / 6;
            buttonWidth = buttonWidth < 60 ? buttonWidth : 60;
            return Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: painQuantities.keys.map((quantity) {
                return RawMaterialButton(
                  enableFeedback: !widget.readOnly,
                  onPressed: widget.readOnly
                      ? null
                      : () {
                          if (!widget.readOnly) {
                            setState(() => widget.journal.pain = quantity);
                          }
                        },
                  constraints: BoxConstraints.tight(Size(buttonWidth, buttonWidth)),
                  elevation: 0.0,
                  fillColor: quantity == widget.journal.pain ? Colors.blue : Colors.white,
                  shape: const CircleBorder(),
                  child: Image.asset(
                    painQuantities[quantity]!,
                    width: 0.9 * buttonWidth,
                    height: 0.9 * buttonWidth,
                    fit: BoxFit.fill,
                  ),
                );
              }).toList(),
            );
          },
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8.0,
          runSpacing: 0.0,
          children: PainDescriptorEnum.values.map((descriptorEnum) {
            return ActionChip(
              label: Text(descriptorEnum.value),
              onPressed: () {
                setState(() {
                  if (!widget.readOnly) {
                    if (widget.journal.painDescriptors.map((e) => e.descriptor).contains(descriptorEnum)) {
                      final painDescriptor =
                          widget.journal.painDescriptors.firstWhere((p) => p.descriptor == descriptorEnum);
                      widget.journal.painDescriptors.remove(painDescriptor);
                      DatabaseHelper().deleteJournalPainDescriptor(painDescriptor);
                    } else {
                      final painDescriptor = PainDescriptor(descriptor: descriptorEnum);
                      widget.journal.painDescriptors.add(painDescriptor);
                    }
                  }
                });
              },
              backgroundColor: widget.journal.painDescriptors.map((e) => e.descriptor).contains(descriptorEnum)
                  ? Colors.blue
                  : Colors.white,
            );
          }).toList(),
        ),
        const SizedBox(height: 20),
      ],
    );
  }
}
