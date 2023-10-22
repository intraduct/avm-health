import 'dart:math';

import 'package:avm_symptom_tracker/database/secure_storage_helper.dart';
import 'package:avm_symptom_tracker/model/journal_model.dart';
import 'package:avm_symptom_tracker/model/notification_model.dart';
import 'package:avm_symptom_tracker/model/settings_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:intl/intl.dart';
import 'package:sqflite_sqlcipher/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();

  final secureStorage = const FlutterSecureStorage();

  factory DatabaseHelper() => _instance;

  static Database? _dbInternal;

  DatabaseHelper._internal();

  Future<Database> get _db async {
    if (_dbInternal != null) {
      return _dbInternal!;
    }
    final password = await _getDatabasePassword();
    await _initDatabase(password);
    return _dbInternal!;
  }

  Future<String> _getDatabasePassword() async {
    String? password = await SecureStorageHelper.read('db-pass');
    if (password == null || password.isEmpty) {
      password = generateRandomString(50);
      SecureStorageHelper.write('db-pass', password);
    }
    return password;
  }

  static const _chars = 'AaBbCcDdEeFfGgHhIiJjKkLlMmNnOoPpQqRrSsTtUuVvWwXxYyZz1234567890';
  final Random _rnd = Random.secure();

  String generateRandomString(int length) =>
      String.fromCharCodes(Iterable.generate(length, (_) => _chars.codeUnitAt(_rnd.nextInt(_chars.length))));

  Future<void> _initDatabase(String password) async {
    String databasesPath = await getDatabasesPath();
    String user = (await SecureStorageHelper.read('user'))!;
    String path = join(databasesPath, '$user.db');

    await _setupDatabase(path, password);
  }

  Future<void> _setupDatabase(String path, String password) async {
    await openDatabase(
      path,
      password: password,
      onCreate: _createDatabase,
      onConfigure: _configureDatabase,
      version: 1,
    ).then((db) => _dbInternal = db);

    // Enable foreign key constraints
    await _dbInternal!.execute('PRAGMA foreign_keys = ON;');
  }

  Future<void> _createDatabase(Database db, int version) async {
    return _configureDatabase(db);
  }

  Future<void> _configureDatabase(Database db) async {
    final ddlSqlFile = await rootBundle.loadString('assets/sql/ddl.sql');

    final batch = db.batch();
    ddlSqlFile.split(';').forEach((sqlStatement) {
      if (sqlStatement.trim().isNotEmpty) {
        batch.execute(sqlStatement);
      }
    });
    await batch.commit();
  }

  Future<List<DateTime>> fetchDaysWithData() async {
    final db = await _db;

    final result = await db.rawQuery('SELECT DISTINCT date FROM journal');
    final dates = result.map((row) {
      final dateStr = row['date'] as String;
      return DateTime.parse(dateStr);
    }).toList();

    return dates;
  }

  Future<Journal?> fetchJournalByDate(DateTime date) async {
    final db = await _db;

    final journalMapList = await db.query(
      'journal',
      where: 'date = ?',
      whereArgs: [DatabaseHelper.toDateString(date)],
    );

    if (journalMapList.isEmpty) {
      return null;
    }

    return _mapJournal(journalMapList.first, db);
  }

  Future<Journal> _mapJournal(Map<String, Object?> journalMap, Database db) async {
    final journalId = journalMap['id'] as int;
    final dateStr = journalMap['date'] as String;
    final date = DateTime.parse(dateStr);
    final symptoms = journalMap['symptoms'] as String?;
    final pain = journalMap['pain'] as int?;

    final painDescriptors = await db.query(
      'pain_descriptors',
      where: 'journalId = ?',
      whereArgs: [journalId],
    );

    final markers = await db.query(
      'location_markers',
      where: 'journalId = ?',
      whereArgs: [journalId],
    );

    final medications = await db.query(
      'medications',
      where: 'journalId = ?',
      whereArgs: [journalId],
    );

    final photos = await db.query(
      'photos',
      where: 'journalId = ?',
      whereArgs: [journalId],
    );

    final painDescriptorList = painDescriptors.map((entry) {
      final id = entry['id'] as int;
      final descriptor = PainDescriptorEnum.values.firstWhere((desc) => desc.value == entry['descriptor']);
      return PainDescriptor(id: id, descriptor: descriptor);
    }).toList();

    final markerList = markers
        .map((entry) => LocationMarker(
            id: entry['id'] as int,
            x: entry['x'] as double,
            y: entry['y'] as double,
            description: entry['description'] as String))
        .toList();

    final medicationList =
        medications.map((entry) => Medication(id: entry['id'] as int, name: entry['name'] as String)).toList();

    final photoList = photos
        .map((entry) => Photo(
            id: entry['id'] as int,
            bytes: entry['bytes'] as Uint8List,
            description: entry['description'] as String?,
            mimeType: entry['mimeType'] as String?,
            name: entry['name'] as String?))
        .toList();

    final additionalCategories = await fetchAdditionalCategories(journalId);

    var journal = Journal(
        id: journalId,
        date: date,
        symptoms: symptoms,
        pain: pain,
        painDescriptors: painDescriptorList,
        markers: markerList,
        medications: medicationList,
        photos: photoList,
        additionalCategories: additionalCategories);
    return journal;
  }

  Future<List<Journal>> fetchJournals() async {
    final db = await _db;

    final journalMapList = await db.query('journal');

    if (journalMapList.isEmpty) {
      return [];
    }

    List<Future<Journal>> futureJournals =
        journalMapList.map((journalMap) async => await _mapJournal(journalMap, db)).toList();
    return Future.wait(futureJournals);
  }

  Future<List<Category>> fetchAdditionalCategories(int? journalId) async {
    final db = await _db;

    final settingsCategories = (await fetchSettings()).additionalCategories;

    final categories = settingsCategories
        .map((sc) => Category(
            settingsCategoryId: sc.id!,
            name: sc.name,
            parameters: sc.parameters
                .map((sp) => Parameter(
                      settingsParameterId: sp.id!,
                      name: sp.name,
                      type: sp.type,
                      unit: sp.unit,
                    ))
                .toList()))
        .toList();

    if (journalId == null) {
      return categories;
    }

    const sql = '''
      SELECT 
        jc.id AS journal_category_id,
        jc.settingsCategoryId AS settings_category_id,
        jc.active AS journal_category_active,
        jp.id AS journal_parameter_id,
        jp.settingsParameterId AS settings_parameter_id,
        jp.value AS journal_parameter_value
      FROM journal_categories jc
      LEFT JOIN journal_parameters AS jp ON jp.journalCategoryId = jc.id
      WHERE jc.journalId = ?
    ''';

    final result = await db.rawQuery(sql, [journalId]);

    for (var row in result) {
      final settingsCategoryId = row['settings_category_id'] as int;
      final settingsParameterId = row['settings_parameter_id'] as int?;
      final journalCategoryId = row['journal_category_id'] as int;
      final journalCategoryActive = ((row['journal_category_active'] as int?) ?? 0) == 1;
      final journalParameterId = row['journal_parameter_id'] as int?;
      final journalParameterValue = row['journal_parameter_value'] as num?;

      categories.where((sc) => sc.settingsCategoryId == settingsCategoryId).forEach((category) {
        if (category.id == null) {
          category.id = journalCategoryId;
          category.active = journalCategoryActive;
        }
        category.parameters.where((jp) => jp.settingsParameterId == settingsParameterId).forEach((parameter) {
          parameter.id = journalParameterId;
          parameter.value = journalParameterValue;
        });
      });
    }

    return categories;
  }

  Future<Settings> fetchSettings() async {
    final db = await _db;

    final quickUnlock = await SecureStorageHelper.readQuickUnlock();

    final settingsMap = await db.query('settings');
    final bool participationConsent;
    final int? settingsId;

    if (settingsMap.isEmpty) {
      settingsId = null;
      participationConsent = false;
    } else {
      settingsId = settingsMap.first['id'] as int;
      int consentInt = settingsMap.first['participationConsent'] as int;
      participationConsent = consentInt == 1;
    }

    final List<SettingsCategory> additionalCategories = [];
    final categoriesMap = await db.query('settings_categories', orderBy: 'id');
    for (var element in categoriesMap) {
      final categoryId = element['id'] as int?;
      final name = element['name'] as String;

      final List<SettingsParameter> parameters = [];
      final parametersMap =
          await db.query('settings_parameters', where: 'categoryId = ?', whereArgs: [categoryId], orderBy: 'id');
      for (var element in parametersMap) {
        final parameterId = element['id'] as int?;
        final name = element['name'] as String;
        final type = element['type'] as String;
        final unit = element['unit'] as String?;
        parameters.add(SettingsParameter(id: parameterId, name: name, type: type, unit: unit));
      }

      additionalCategories.add(SettingsCategory(id: categoryId, name: name, parameters: parameters));
    }

    return Settings(
      id: settingsId,
      quickUnlock: quickUnlock ?? false,
      participationConsent: participationConsent,
      additionalCategories: additionalCategories,
    );
  }

  Future<void> storeJournal(Journal journal) async {
    final db = await _db;

    // Insert the journal entry
    journal.id = await upsert(db, 'journal', journal.id, journal.toDatabaseMap());

    // Insert pain descriptors
    for (final descriptor in journal.painDescriptors) {
      descriptor.id = await upsert(db, 'pain_descriptors', descriptor.id, descriptor.toDatabaseMap(journal.id));
    }

    // Insert location markers
    for (final marker in journal.markers) {
      marker.id = await upsert(db, 'location_markers', marker.id, marker.toDatabaseMap(journal.id));
    }

    // Insert medications
    for (final medication in journal.medications) {
      if (medication.name.isEmpty) {
        continue;
      }

      medication.id = await upsert(db, 'medications', medication.id, medication.toDatabaseMap(journal.id));
    }

    // Insert photos
    for (final photo in journal.photos) {
      photo.id = await upsert(db, 'photos', photo.id, photo.toDatabaseMap(journal.id));
    }

    // insert categories
    for (final category in journal.additionalCategories) {
      category.id = await upsert(db, 'journal_categories', category.id, category.toDatabaseMap(journal.id));

      for (final parameter in category.parameters) {
        parameter.id = await upsert(db, 'journal_parameters', parameter.id, parameter.toDatabaseMap(category.id));
      }
    }
  }

  Future<void> storeSettings(Settings settings) async {
    final db = await _db;

    SecureStorageHelper.writeQuickUnlock(settings.quickUnlock);

    var settingsMap = {
      'id': settings.id,
      'participationConsent': settings.participationConsent ? 1 : 0,
    };

    settings.id = await upsert(db, 'settings', settings.id, settingsMap);

    for (var category in settings.additionalCategories) {
      var categoryMap = {'id': category.id, 'name': category.name};
      category.id = await upsert(db, 'settings_categories', category.id, categoryMap);

      for (var parameter in category.parameters) {
        var parameterMap = {
          'id': parameter.id,
          'categoryId': category.id,
          'name': parameter.name,
          'type': parameter.type,
          'unit': parameter.unit,
        };
        parameter.id = await upsert(db, 'settings_parameters', parameter.id, parameterMap);
      }
    }
  }

  Future<int> upsert(Database db, String table, int? id, Map<String, Object?> upsertObject) async {
    if (id == null) {
      final dbId = await db.insert(table, upsertObject);
      return dbId;
    }

    await db.update(table, upsertObject, where: 'id = ?', whereArgs: [id]);
    return id;
  }

  Future<bool> deleteById(String table, int? id) async {
    if (id == null) {
      return true;
    }

    final db = await _db;
    int deletedRows = await db.delete(table, where: 'id = ?', whereArgs: [id]);
    return deletedRows > 0;
  }

  Future<bool> deleteSettingsParameter(SettingsParameter parameter) async {
    return deleteById('settings_parameters', parameter.id);
  }

  Future<bool> deleteSettingsCategory(SettingsCategory category) async {
    return deleteById('settings_categories', category.id);
  }

  Future<bool> deleteJournalPainDescriptor(PainDescriptor descriptor) async {
    return deleteById('pain_descriptors', descriptor.id);
  }

  Future<bool> deleteJournalLocationMarker(LocationMarker marker) async {
    return deleteById('location_markers', marker.id);
  }

  Future<bool> deleteJournalMedication(Medication medication) async {
    return deleteById('medications', medication.id);
  }

  Future<bool> deleteJournalPhoto(Photo photo) async {
    return deleteById('photos', photo.id);
  }

  static final DateFormat _dateFormatter = DateFormat('yyyy-MM-dd');
  static String toDateString(DateTime date) {
    return _dateFormatter.format(date);
  }

  Future<DbNotifications> fetchNotifications() async {
    final db = await _db;

    var defaultInputReminder = DbNotification(
      id: null,
      isEnabled: false,
      title: 'Tägliche Dateneingabe',
      body: 'Denke daran, den heutigen Tag in der App zu erfassen!',
      time: const TimeOfDay(hour: 17, minute: 0),
      type: NotificationType.inputReminder,
    );

    final notificationsMap = await db.query('notifications');

    if (notificationsMap.isEmpty) {
      return DbNotifications(inputReminder: defaultInputReminder, medicationReminders: []);
    }

    List<DbNotification> allNotifications = notificationsMap.map((notification) {
      return DbNotification(
        id: notification['id'] as int,
        isEnabled: (notification['isEnabled'] as int) == 1,
        title: notification['title'] as String,
        body: notification['body'] as String,
        time: TimeOfDay(hour: notification['hour'] as int, minute: notification['minute'] as int),
        type: NotificationType.fromString(notification['type'] as String),
      );
    }).toList();

    DbNotification inputReminder = allNotifications.firstWhere(
      (notification) => notification.type == NotificationType.inputReminder,
      orElse: () => defaultInputReminder,
    );

    List<DbNotification> medicationReminders =
        allNotifications.where((notification) => notification.type == NotificationType.medicationReminder).toList();

    return DbNotifications(
      inputReminder: inputReminder,
      medicationReminders: medicationReminders,
    );
  }

  Future<void> storeNotifications(DbNotifications notifications) async {
    final db = await _db;
    notifications.inputReminder.id =
        await upsert(db, 'notifications', notifications.inputReminder.id, notifications.inputReminder.toDatabaseMap());

    for (final notification in notifications.medicationReminders) {
      notification.id = await upsert(db, 'notifications', notification.id, notification.toDatabaseMap());
    }
  }

  Future<bool> deleteNotification(DbNotification notification) async {
    return deleteById('notifications', notification.id);
  }
}
