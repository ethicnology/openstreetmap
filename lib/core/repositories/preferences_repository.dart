import 'package:furtive/core/datasources/preferences_local_data_source.dart';
import 'package:furtive/core/models/preferences_model.dart';
import 'package:furtive/core/entities/preferences_entity.dart';

class PreferencesRepository {
  final preferencesDataSource = PreferencesLocalDataSource();

  PreferencesRepository();

  Future<void> store(PreferencesEntity preferences) async {
    final model = PreferencesModel.fromEntity(preferences);
    await preferencesDataSource.store(model);
  }

  Future<PreferencesEntity> fetch() async {
    final models = await preferencesDataSource.fetch();
    return PreferencesModel.toEntity(models);
  }
}
