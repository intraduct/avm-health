import 'package:avm_symptom_tracker/database/database_helper.dart';
import 'package:flutter/material.dart';

import '../../model/journal_model.dart';

class LocationWidget extends StatefulWidget {
  final Journal journal;
  final bool readOnly;

  const LocationWidget({super.key, required this.journal, bool? readOnly}) : readOnly = readOnly ?? false;

  @override
  State<LocationWidget> createState() => _LocationWidgetState();
}

class _LocationWidgetState extends State<LocationWidget> {
  LocationMarker? selectedMarker;
  double imageWidth = -1;

  TextEditingController descriptionController = TextEditingController();

  void updateDescription() {
    if (selectedMarker == null) {
      descriptionController.text = '';
    } else {
      descriptionController.text = selectedMarker!.description;
    }
  }

  @override
  Widget build(BuildContext context) {
    final String markerText;
    if (selectedMarker == null) {
      markerText = 'Keine Markierung ausgewählt.';
    } else if (selectedMarker!.description.isEmpty) {
      markerText = 'Keine Notiz zur Markierung erfasst.';
    } else {
      markerText = selectedMarker!.description;
    }

    var textBox = widget.readOnly
        ? Text(markerText)
        : TextFormField(
            controller: descriptionController,
            readOnly: widget.readOnly,
            onChanged: (value) {
              if (selectedMarker != null) {
                selectedMarker!.description = value;
              }
            },
            decoration: const InputDecoration(
              labelText: 'Notiz zur gewählten Markierung',
              border: InputBorder.none,
            ),
          );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Körperkarte',
          style: TextStyle(fontSize: 20),
        ),
        const SizedBox(height: 10),
        LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraints) {
            final normFactor = 1000 / constraints.maxWidth;
            return GestureDetector(
              onTapUp: (details) {
                if (!widget.readOnly) {
                  setState(() {
                    var xNorm = (details.localPosition.dx) * normFactor; // Normalize to value between 0..1000
                    var yNorm = (details.localPosition.dy) * normFactor; // Normalize depending on image ratio
                    selectedMarker = LocationMarker(
                      x: xNorm,
                      y: yNorm,
                      description: '',
                    );
                    widget.journal.markers.add(selectedMarker!);
                    updateDescription();
                  });
                }
              },
              child: Stack(
                clipBehavior: Clip.none,
                alignment: Alignment.center,
                children: [
                  LayoutBuilder(
                    builder: (BuildContext context, BoxConstraints constraints) {
                      imageWidth = constraints.maxWidth;
                      return Image.asset(
                        'assets/images/koerperschema.png',
                        fit: BoxFit.contain,
                      );
                    },
                  ),
                  ...widget.journal.markers.map((marker) {
                    final isSelected = marker == selectedMarker;
                    return Positioned(
                      left: marker.x / normFactor - 16,
                      top: marker.y / normFactor - 30,
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            if (isSelected && !widget.readOnly) {
                              // If a selected marker is tapped again, remove it
                              DatabaseHelper().deleteJournalLocationMarker(selectedMarker!);
                              widget.journal.markers.remove(marker);
                              selectedMarker = null;
                            } else {
                              // Otherwise, select the marker
                              selectedMarker = marker;
                            }
                            updateDescription();
                          });
                        },
                        child: Icon(
                          isSelected ? Icons.location_on : Icons.location_on,
                          color: isSelected ? Colors.red : Colors.blue,
                          size: 32.0,
                        ),
                      ),
                    );
                  }),
                ],
              ),
            );
          },
        ),
        Visibility(
          child: textBox,
        ),
        const SizedBox(height: 20),
      ],
    );
  }
}
