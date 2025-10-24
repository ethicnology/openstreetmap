import 'package:openstreetmap/core/database/tables/preferences_table.dart';
import 'package:openstreetmap/core/entities/preferences_entity.dart';

class PreferencesModel {
  final MapThemeColumn mapTheme;
  final MapLanguageColumn mapLanguage;
  final int accuracyInMeters;

  PreferencesModel({
    required this.mapTheme,
    required this.mapLanguage,
    required this.accuracyInMeters,
  });

  static fromEntity(PreferencesEntity preferences) {
    return PreferencesModel(
      mapTheme: MapThemeExtension.fromEntity(preferences.mapTheme),
      mapLanguage: MapLanguageExtension.fromEntity(preferences.mapLanguage),
      accuracyInMeters: preferences.accuracyInMeters,
    );
  }

  static PreferencesEntity toEntity(PreferencesModel model) {
    return PreferencesEntity(
      mapTheme: model.mapTheme.toEntity(),
      mapLanguage: model.mapLanguage.toEntity(),
      accuracyInMeters: model.accuracyInMeters,
    );
  }
}

extension MapThemeExtension on MapThemeColumn {
  static fromEntity(MapThemeEntity theme) {
    switch (theme) {
      case MapThemeEntity.light:
        return MapThemeColumn.light;
      case MapThemeEntity.dark:
        return MapThemeColumn.dark;
    }
  }

  toEntity() {
    switch (this) {
      case MapThemeColumn.light:
        return MapThemeEntity.light;
      case MapThemeColumn.dark:
        return MapThemeEntity.dark;
    }
  }
}

extension MapLanguageExtension on MapLanguageColumn {
  static fromEntity(MapLanguageEntity language) {
    switch (language) {
      case MapLanguageEntity.en:
        return MapLanguageColumn.en;
      case MapLanguageEntity.fr:
        return MapLanguageColumn.fr;
    }
  }

  toEntity() {
    switch (this) {
      case MapLanguageColumn.en:
        return MapLanguageEntity.en;
      case MapLanguageColumn.fr:
        return MapLanguageEntity.fr;
    }
  }
}
