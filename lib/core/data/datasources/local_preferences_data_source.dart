import 'package:drift/drift.dart';
import 'package:openstreetmap/core/data/models/preferences_model.dart';
import 'package:openstreetmap/core/database/local_database.dart';
import 'package:openstreetmap/core/locator.dart';

class LocalPreferencesDataSource {
  final db = getIt.get<LocalDatabase>();

  LocalPreferencesDataSource();

  Future<void> store(PreferencesModel preferences) async {
    await db
        .into(db.preferences)
        .insertOnConflictUpdate(
          PreferencesCompanion(
            id: Value(1),
            mapTheme: Value(preferences.mapTheme),
            mapLanguage: Value(preferences.mapLanguage),
            accuracyInMeters: Value(preferences.accuracyInMeters),
          ),
        );
  }

  Future<PreferencesModel> fetch() async {
    final preferences = await db.select(db.preferences).getSingle();
    return PreferencesModel(
      mapTheme: preferences.mapTheme,
      mapLanguage: preferences.mapLanguage,
      accuracyInMeters: preferences.accuracyInMeters,
    );
  }
}
