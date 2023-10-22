import 'dart:typed_data';

import 'package:avm_symptom_tracker/database/database_helper.dart';

class Journal {
  int? id;
  DateTime date;

  String? symptoms;

  int? pain;
  List<PainDescriptor> painDescriptors;

  List<LocationMarker> markers;

  List<Medication> medications;

  List<Photo> photos;

  List<Category> additionalCategories;

  Journal(
      {this.id,
      required this.date,
      this.symptoms,
      this.pain,
      List<PainDescriptor>? painDescriptors,
      List<LocationMarker>? markers,
      List<Medication>? medications,
      List<Photo>? photos,
      List<Category>? additionalCategories})
      : painDescriptors = painDescriptors ?? [],
        medications = medications ?? [],
        markers = markers ?? [],
        photos = photos ?? [],
        additionalCategories = additionalCategories ?? [];

  Map<String, Object?> toDatabaseMap() {
    return {
      'id': id,
      'date': DatabaseHelper.toDateString(date),
      'symptoms': symptoms,
      'pain': pain,
    };
  }
}

class PainDescriptor {
  int? id;
  PainDescriptorEnum descriptor;

  PainDescriptor({this.id, required this.descriptor});

  Map<String, Object?> toDatabaseMap(int? journalId) {
    return {
      'id': id,
      'journalId': journalId,
      'descriptor': descriptor.value,
    };
  }
}

enum PainDescriptorEnum {
  dumpf('dumpf'),
  drueckend('drückend'),
  pochend('pochend'),
  klopfend('klopfend'),
  stechend('stechend'),
  ziehend('ziehend');

  const PainDescriptorEnum(this.value);
  final String value;
}

class LocationMarker {
  int? id;
  double x;
  double y;
  String description;

  LocationMarker({this.id, required this.x, required this.y, required this.description});

  Map<String, Object?> toDatabaseMap(int? journalId) {
    return {
      'id': id,
      'journalId': journalId,
      'x': x,
      'y': y,
      'description': description,
    };
  }
}

class Medication {
  int? id;
  String name;

  Medication({this.id, required this.name});

  Map<String, Object?> toDatabaseMap(int? journalId) {
    return {
      'id': id,
      'journalId': journalId,
      'name': name,
    };
  }
}

class Photo {
  int? id;
  Uint8List bytes;
  String? description;

  String? mimeType;
  String? name;

  Photo({this.id, required this.bytes, this.description, this.mimeType, this.name});

  Map<String, Object?> toDatabaseMap(int? journalId) {
    return {
      'id': id,
      'journalId': journalId,
      'bytes': bytes,
      'description': description,
      'mimeType': mimeType,
      'name': name,
    };
  }
}

class Category {
  int? id;
  int settingsCategoryId;
  String name;
  bool active;
  List<Parameter> parameters;

  Category({this.id, required this.settingsCategoryId, String? name, bool? active, List<Parameter>? parameters})
      : name = name ?? '',
        active = active ?? false,
        parameters = parameters ?? [];

  Map<String, Object?> toDatabaseMap(int? journalId) {
    return {
      'id': id,
      'journalId': journalId,
      'settingsCategoryId': settingsCategoryId,
      'active': active ? 1 : 0,
    };
  }
}

class Parameter {
  int? id;
  int settingsParameterId;
  String name;
  String type;
  String unit;
  num? value;

  Parameter({this.id, required this.settingsParameterId, String? name, String? type, String? unit, this.value})
      : name = name ?? '',
        type = type ?? 'number',
        unit = unit ?? '';

  Map<String, Object?> toDatabaseMap(int? journalCategoryId) {
    return {
      'id': id,
      'journalCategoryId': journalCategoryId,
      'settingsParameterId': settingsParameterId,
      'value': value,
    };
  }
}
