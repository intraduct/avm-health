import 'package:flutter/material.dart';

List<Contact> contacts = [
  Contact(
    category: 'Kliniken',
    entries: [
      ContactEntry(name: 'Charité Berlin', location: 'Charitépl. 1, 10117 Berlin'),
      ContactEntry(name: 'Spezial-Klinikum', location: '00000 Musterstadt'),
    ],
  ),
  Contact(
    category: 'Praxen',
    entries: [
      ContactEntry(name: 'Spezial-Praxis', location: '11111 Beispielstadt'),
    ],
  ),
  Contact(
    category: 'Ärzte',
    entries: [
      ContactEntry(name: 'Dr. med. Max Mustermann', location: 'Maxstr. 1, 00000 Musterstadt'),
    ],
  ),
  Contact(
    category: 'Verbände',
    entries: [
      ContactEntry(name: 'Bundesverband Angeborene Gefäßfehlbildungen', location: 'https://www.angiodysplasie.de/'),
    ],
  )
];

class ContactPage extends StatelessWidget {
  const ContactPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Ansprechpartner',
          style: TextStyle(
            color: Theme.of(context).colorScheme.onPrimary,
          ),
        ),
        backgroundColor: Theme.of(context).colorScheme.primary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: ListView(
          children: [
            ...contacts.map((contact) => ContactWidget(contact: contact)),
          ],
        ),
      ),
    );
  }
}

class ContactWidget extends StatelessWidget {
  final Contact contact;

  const ContactWidget({super.key, required this.contact});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          contact.category,
          style: const TextStyle(fontSize: 20),
        ),
        ...contact.entries.map(
          (e) => ListTile(
            title: Text(e.name),
            subtitle: Text(e.location),
          ),
        )
      ],
    );
  }
}

class Contact {
  String category;
  List<ContactEntry> entries;

  Contact({required this.category, required this.entries});
}

class ContactEntry {
  String name;
  String location;

  ContactEntry({required this.name, required this.location});
}
