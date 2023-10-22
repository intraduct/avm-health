import 'dart:async';
import 'dart:math';

import 'package:avm_symptom_tracker/database/database_helper.dart';
import 'package:avm_symptom_tracker/model/settings_model.dart';
import 'package:flutter/material.dart';

class AdditionalParametersSettingsWidget extends StatefulWidget {
  final List<SettingsCategory> additionalCategories;

  const AdditionalParametersSettingsWidget({super.key, required this.additionalCategories});

  @override
  State<AdditionalParametersSettingsWidget> createState() => _AdditionalParametersSettingsWidgetState();
}

class _AdditionalParametersSettingsWidgetState extends State<AdditionalParametersSettingsWidget> {
  Widget categoryWidget(BuildContext context, SettingsCategory category) {
    return Column(
      children: [
        ListTile(
          // key: Key('${category.id ?? DateTime.now().millisecondsSinceEpoch}'),
          title: TextFormField(
            initialValue: category.name,
            onChanged: (value) => category.name = value,
            decoration: const InputDecoration(
              hintText: 'Kategorie eingeben',
              border: InputBorder.none,
              contentPadding: EdgeInsets.zero,
            ),
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          ),
        ),
        const Divider(),
      ],
    );
  }

  Future<bool?> showCategoryDismissDialog(SettingsCategory category) {
    return showConfirmDeleteDialog(
      title: 'Achtung Datenlöschung',
      content: 'Alle bisherigen Einträge zu dieser Kategorie werden gelöscht. Fortfahren?',
      confirmButtonText: 'Kategorie löschen',
      dismissButtonText: 'Kategorie behalten',
    );
  }

  Widget parameterWidget(BuildContext context, SettingsParameter parameter, SettingsCategory category) {
    return Dismissible(
      key: Key('${parameter.id ?? Random().nextDouble()}'),
      background: Container(
        color: Colors.red,
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20.0),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      direction: DismissDirection.endToStart,
      confirmDismiss: (_) => showParameterDeleteDialog(category, parameter),
      onDismissed: (direction) {
        setState(() => category.parameters.remove(parameter));
        DatabaseHelper().deleteSettingsParameter(parameter);
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ListTile(
            title: TextFormField(
              initialValue: parameter.name,
              onChanged: (value) => parameter.name = value,
              decoration: const InputDecoration(
                labelText: 'Namen des Parameters',
                border: InputBorder.none,
                contentPadding: EdgeInsets.zero,
                isDense: true,
              ),
            ),
          ),
          ListTile(
            title: DropdownMenu(
              label: const Text('Typ'),
              inputDecorationTheme: const InputDecorationTheme(
                border: UnderlineInputBorder(),
              ),
              hintText: 'Typ',
              initialSelection: parameter.type,
              onSelected: (value) {
                if (value != null) {
                  setState(() => parameter.type = value);
                }
              },
              dropdownMenuEntries: const [
                DropdownMenuEntry(value: 'bool', label: 'Ja / Nein'),
                DropdownMenuEntry(value: 'number', label: 'Numerisch'),
              ],
            ),
            trailing: (parameter.type == 'number')
                ? SizedBox(
                    width: 100,
                    child: TextFormField(
                      initialValue: parameter.unit,
                      onChanged: (value) => parameter.unit = value,
                      decoration: const InputDecoration(
                        labelText: 'Einheit',
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.zero,
                        isDense: true,
                      ),
                    ),
                  )
                : const SizedBox(width: 100),
          ),
          const Divider(),
        ],
      ),
    );
  }

  Future<bool?> showParameterDeleteDialog(SettingsCategory category, SettingsParameter parameter) {
    return showConfirmDeleteDialog(
      title: 'Achtung Datenlöschung',
      content: 'Alle bisherigen Einträge zu diesem Parameter werden gelöscht. Fortfahren?',
      confirmButtonText: 'Parameter löschen',
      dismissButtonText: 'Parameter behalten',
    );
  }

  Future<bool> showConfirmDeleteDialog(
      {required String title,
      required String content,
      required String confirmButtonText,
      required String dismissButtonText}) {
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(content),
        actions: [
          TextButton(
            child: Text(confirmButtonText),
            onPressed: () {
              Navigator.of(context).pop(true);
            },
          ),
          TextButton(
            child: Text(dismissButtonText),
            onPressed: () {
              Navigator.of(context).pop(false);
            },
          ),
        ],
      ),
    ).then((confirmed) => confirmed ?? false);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Divider(),
        const Padding(
          padding: EdgeInsets.all(20),
          child: Text(
            'Weitere Parameter',
            style: TextStyle(fontSize: 20),
          ),
        ),
        ...widget.additionalCategories.map(
          (category) => Dismissible(
            key: Key('${category.id ?? Random().nextDouble()}'),
            direction: DismissDirection.endToStart,
            background: Container(
              color: Colors.red,
              alignment: Alignment.centerRight,
              padding: const EdgeInsets.only(right: 20.0),
              child: const Icon(Icons.delete, color: Colors.white),
            ),
            confirmDismiss: (_) => showCategoryDismissDialog(category),
            onDismissed: (direction) {
              setState(() => widget.additionalCategories.remove(category));
              DatabaseHelper().deleteSettingsCategory(category);
            },
            child: Container(
              decoration:
                  BoxDecoration(border: Border.all(color: Colors.grey), borderRadius: BorderRadius.circular(10)),
              margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 20),
              padding: const EdgeInsets.only(bottom: 5),
              child: Column(
                children: [
                  categoryWidget(context, category),
                  ...category.parameters.map(
                    (parameter) => parameterWidget(context, parameter, category),
                  ),
                  ListTile(
                    title: const Text('Parameter hinzufügen'),
                    leading: ElevatedButton(
                      onPressed: () {
                        setState(() {
                          final newParameter = SettingsParameter();
                          category.parameters.add(newParameter);
                        });
                      },
                      child: const Icon(Icons.add),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: ListTile(
            title: const Text('Kategorie hinzufügen'),
            contentPadding: EdgeInsets.zero,
            leading: ElevatedButton(
              onPressed: () {
                setState(() {
                  final newCategory = SettingsCategory();
                  widget.additionalCategories.add(newCategory);
                });
              },
              child: const Icon(Icons.add),
            ),
          ),
        ),
      ],
    );
  }
}
