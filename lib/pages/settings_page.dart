import 'package:avm_symptom_tracker/database/database_helper.dart';
import 'package:avm_symptom_tracker/model/settings_model.dart';
import 'package:avm_symptom_tracker/widgets/settings/additional_parameters_settings_widget.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class SettingsPage extends StatefulWidget {
  final Settings settings;

  const SettingsPage({super.key, required this.settings});

  @override
  State<StatefulWidget> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        return DatabaseHelper().storeSettings(widget.settings).then((_) => true);
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            'Einstellungen',
            style: TextStyle(
              color: Theme.of(context).colorScheme.onPrimary,
            ),
          ),
          backgroundColor: Theme.of(context).colorScheme.primary,
        ),
        body: ListView(
          children: [
            const Padding(
              padding: EdgeInsets.fromLTRB(20, 20, 20, 0),
              child: Text(
                'Allgemein',
                style: TextStyle(fontSize: 20),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: ListTile(
                title: const Text('Quick-Unlock'),
                isThreeLine: true,
                subtitle: const Text('Entsperren mit Fingerabdruck oder FaceID'),
                trailing: Switch(
                  value: widget.settings.quickUnlock,
                  onChanged: (value) => setState(() => widget.settings.quickUnlock = value),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: ListTile(
                title: const Text('Teilnahme Alltagsstudie'),
                isThreeLine: true,
                subtitle: RichText(
                  text: TextSpan(
                    children: [
                      const TextSpan(
                        text: 'Informationen über die Alltagsstudie findest du hier: ',
                        style: TextStyle(color: Colors.black),
                      ),
                      TextSpan(
                        text: 'https://avm-studie.de/',
                        style: const TextStyle(color: Colors.blue),
                        recognizer: TapGestureRecognizer()
                          ..onTap = () {
                            launchUrl(Uri.https('avm-studie.de'));
                          },
                      ),
                    ],
                  ),
                ),
                trailing: Switch(
                  value: widget.settings.participationConsent,
                  onChanged: (value) {
                    setState(() {
                      widget.settings.participationConsent = value;
                    });
                  },
                ),
              ),
            ),
            AdditionalParametersSettingsWidget(additionalCategories: widget.settings.additionalCategories),
          ],
        ),
      ),
    );
  }
}
