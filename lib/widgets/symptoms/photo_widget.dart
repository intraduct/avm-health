import 'package:avm_symptom_tracker/database/database_helper.dart';
import 'package:avm_symptom_tracker/model/journal_model.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class PhotoWidget extends StatefulWidget {
  final Journal journal;
  final bool readOnly;

  const PhotoWidget({super.key, required this.journal, bool? readOnly}) : readOnly = readOnly ?? false;

  @override
  State<PhotoWidget> createState() => _PhotoWidgetState();
}

class _PhotoWidgetState extends State<PhotoWidget> {
  final picker = ImagePicker();
  Future<void> _takeNewPhoto() async {
    final pickedFile = await picker.pickImage(source: ImageSource.camera);

    if (pickedFile != null) {
      pickedFile.readAsBytes().then((bytes) => setState(() => widget.journal.photos.add(Photo(
            bytes: bytes,
            mimeType: pickedFile.mimeType,
            name: pickedFile.name,
            description: '',
          ))));
    }
  }

  Future<void> _pickImageFromGallery() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      pickedFile.readAsBytes().then((bytes) => setState(() {
            widget.journal.photos
                .add(Photo(bytes: bytes, description: '', name: pickedFile.name, mimeType: pickedFile.mimeType));
          }));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Bilder / Dokumente',
          style: TextStyle(fontSize: 20),
        ),
        for (int i = 0; i < widget.journal.photos.length; i++)
          DocumentItemWidget(
            key: ValueKey(widget.journal.photos[i]),
            document: widget.journal.photos[i],
            readOnly: widget.readOnly,
            onTextChanged: (value) => setState(() => widget.journal.photos[i].description = value),
            onDelete: () => setState(() {
              DatabaseHelper().deleteJournalPhoto(widget.journal.photos[i]);
              widget.journal.photos.removeAt(i);
            }),
          ),
        if (widget.journal.photos.isEmpty)
          const Padding(padding: EdgeInsets.fromLTRB(0, 10, 0, 10), child: Text('Keine Bilder erfasst.')),
        if (!widget.readOnly)
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              ElevatedButton(
                onPressed: _takeNewPhoto,
                child: const Icon(Icons.camera_alt),
              ),
              const SizedBox(width: 30),
              ElevatedButton(
                onPressed: _pickImageFromGallery,
                child: const Icon(Icons.image_search),
              ),
            ],
          ),
        const SizedBox(height: 20),
      ],
    );
  }
}

class DocumentItemWidget extends StatelessWidget {
  final ValueChanged<String>? onTextChanged;
  final Function()? onDelete;
  final bool readOnly;
  final Photo document;

  const DocumentItemWidget(
      {super.key, this.onTextChanged, this.onDelete, required this.document, required this.readOnly});

  void _showImageDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          child: GestureDetector(
            onTap: () {
              Navigator.of(context).pop();
            },
            child: Image.memory(
              document.bytes,
              fit: BoxFit.contain,
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 8, 0, 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          GestureDetector(
            onTap: () => _showImageDialog(context),
            child: Image.memory(
              document.bytes,
              height: 60,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: (readOnly)
                ? Text(document.description ?? 'Keine Beschreibung erfasst.')
                : TextFormField(
                    onChanged: onTextChanged,
                    initialValue: document.description,
                    decoration: const InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(10)),
                        ),
                        hintText: 'Beschreibung'),
                  ),
          ),
          if (!readOnly)
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: onDelete,
            ),
        ],
      ),
    );
  }
}
