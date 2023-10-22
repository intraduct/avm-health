import 'dart:io';

import 'package:avm_symptom_tracker/model/journal_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

class AdditionalParametersWidget extends StatefulWidget {
  final Journal journal;
  final bool readOnly;

  const AdditionalParametersWidget({super.key, required this.journal, bool? readOnly}) : readOnly = readOnly ?? false;

  @override
  State<StatefulWidget> createState() => _AdditionalParametersWidgetState();
}

class _AdditionalParametersWidgetState extends State<AdditionalParametersWidget> {
  NumberFormat numberFormat = NumberFormat.decimalPattern(Platform.localeName);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Weitere Parameter',
          style: TextStyle(fontSize: 20),
        ),
        const SizedBox(height: 10),
        if (widget.journal.additionalCategories.isEmpty) const Text('Keine weiteren Parameter konfiguriert.'),
        ...widget.journal.additionalCategories.map(
          (category) => Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.only(left: 5),
                child: ListTile(
                  contentPadding: EdgeInsets.zero,
                  trailing: Switch(
                    value: category.active,
                    onChanged: (value) {
                      if (widget.readOnly) {
                        return;
                      }

                      setState(() => category.active = value);
                    },
                  ),
                  title: Text(
                    category.name,
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              if (category.active)
                Container(
                  decoration:
                      BoxDecoration(border: Border.all(color: Colors.grey), borderRadius: BorderRadius.circular(10)),
                  padding: EdgeInsets.symmetric(horizontal: 10, vertical: widget.readOnly ? 10 : 5),
                  child: Column(
                    children: [
                      if (category.parameters.isEmpty) const ListTile(title: Text('Keine Parameter konfiguriert')),
                      ...category.parameters.map(
                        (parameter) => Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Expanded(
                              flex: 3,
                              child: Text(parameter.name),
                            ),
                            Expanded(child: getWidgetForParameter(parameter)),
                            Text(parameter.unit, textAlign: TextAlign.end),
                          ],
                        ),
                      )
                    ],
                  ),
                ),
              const SizedBox(height: 10),
            ],
          ),
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  Widget getWidgetForParameter(Parameter parameter) {
    return (parameter.type == 'number') ? getWidgetForParameterNumber(parameter) : getWidgetForParameterBool(parameter);
  }

  Widget getWidgetForParameterNumber(Parameter parameter) {
    return widget.readOnly
        ? Padding(
            padding: const EdgeInsets.only(right: 4, top: 8, bottom: 8),
            child: Text(
              parameter.value == null ? '' : '${parameter.value}',
              textAlign: TextAlign.end,
            ))
        : TextFormField(
            initialValue: parameter.value == null ? null : '${parameter.value}',
            keyboardType: const TextInputType.numberWithOptions(decimal: true, signed: true),
            inputFormatters: [CustomNumberInputFormatter()],
            onChanged: (value) => setState(() {
              parameter.value = num.tryParse(value);
            }),
            textAlign: TextAlign.end,
            decoration: const InputDecoration(
              contentPadding: EdgeInsets.zero,
            ),
          );
  }

  Widget getWidgetForParameterBool(Parameter parameter) {
    return Switch(
        value: parameter.value == 1,
        onChanged: (value) => widget.readOnly ? null : setState(() => parameter.value = value ? 1 : 0));
  }
}

class CustomNumberInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    if (newValue.text == '' || newValue.text == '-') {
      return TextEditingValue(text: newValue.text);
    }
    final sanitizedText = newValue.text.replaceAll(',', '.');
    final formattedNumber = num.tryParse(sanitizedText);
    return TextEditingValue(
      text: formattedNumber != null ? sanitizedText : oldValue.text,
      selection:
          TextSelection.collapsed(offset: formattedNumber != null ? sanitizedText.length : oldValue.selection.end),
    );
  }
}
