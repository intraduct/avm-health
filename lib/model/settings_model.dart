class Settings {
  int? id;
  bool quickUnlock;
  bool participationConsent;
  List<SettingsCategory> additionalCategories;

  Settings({this.id, bool? quickUnlock, bool? participationConsent, List<SettingsCategory>? additionalCategories})
      : quickUnlock = quickUnlock ?? false,
        participationConsent = participationConsent ?? false,
        additionalCategories = additionalCategories ?? [];
}

class SettingsCategory {
  int? id;
  String name;
  List<SettingsParameter> parameters;

  SettingsCategory({this.id, String? name, List<SettingsParameter>? parameters})
      : name = name ?? '',
        parameters = parameters ?? [];
}

class SettingsParameter {
  int? id;
  String name;
  String type;
  String unit;

  SettingsParameter({this.id, String? name, String? type, String? unit})
      : name = name ?? '',
        type = type ?? 'number',
        unit = unit ?? '';
}
