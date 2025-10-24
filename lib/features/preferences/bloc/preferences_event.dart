import 'package:openstreetmap/core/entities/preferences_entity.dart';

sealed class PreferencesEvent {
  const PreferencesEvent();
}

class LoadPreferences extends PreferencesEvent {
  const LoadPreferences();
}

class UpdateMapTheme extends PreferencesEvent {
  final MapThemeEntity theme;

  const UpdateMapTheme(this.theme);
}

class UpdateMapLanguage extends PreferencesEvent {
  final MapLanguageEntity language;

  const UpdateMapLanguage(this.language);
}

class UpdateAccuracy extends PreferencesEvent {
  final int accuracy;

  const UpdateAccuracy(this.accuracy);
}
