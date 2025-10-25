import 'package:dart_mappable/dart_mappable.dart';

part 'preferences_entity.mapper.dart';

enum MapThemeEntity { light, dark }

enum MapLanguageEntity { en, fr }

@MappableClass()
class PreferencesEntity with PreferencesEntityMappable {
  final MapThemeEntity mapTheme;
  final MapLanguageEntity mapLanguage;
  final int accuracyInMeters;

  PreferencesEntity({
    required this.mapTheme,
    required this.mapLanguage,
    required this.accuracyInMeters,
  });
}
