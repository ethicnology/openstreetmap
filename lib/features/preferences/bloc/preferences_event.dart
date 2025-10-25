import 'package:openstreetmap/core/entities/preferences_entity.dart';

sealed class PreferencesEvent {
  const PreferencesEvent();
}

class LoadPreferences extends PreferencesEvent {
  const LoadPreferences();
}

class UpdatePreferences extends PreferencesEvent {
  final PreferencesEntity preferences;

  const UpdatePreferences(this.preferences);
}

class ChangeMapTheme extends PreferencesEvent {
  final MapThemeEntity theme;

  const ChangeMapTheme(this.theme);
}

class ChangeMapLanguage extends PreferencesEvent {
  final MapLanguageEntity language;

  const ChangeMapLanguage(this.language);
}

class ChangeAccuracy extends PreferencesEvent {
  final int accuracyInMeters;

  const ChangeAccuracy(this.accuracyInMeters);
}
