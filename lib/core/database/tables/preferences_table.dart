import 'package:drift/drift.dart';

@DataClassName('PreferencesRow')
class Preferences extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get mapTheme => textEnum<MapThemeColumn>()();
  TextColumn get mapLanguage => textEnum<MapLanguageColumn>()();
  IntColumn get accuracyInMeters => integer()();
}

enum MapThemeColumn { light, dark }

enum MapLanguageColumn { en, fr }
