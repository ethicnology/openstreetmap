enum MapThemeEntity { light, dark }

enum MapLanguageEntity { en, fr }

class PreferencesEntity {
  final MapThemeEntity mapTheme;
  final MapLanguageEntity mapLanguage;
  final int accuracyInMeters;

  PreferencesEntity({
    required this.mapTheme,
    required this.mapLanguage,
    required this.accuracyInMeters,
  });
}
