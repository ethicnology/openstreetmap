import 'package:furtive/core/models/preferences_model.dart';
import 'package:furtive/core/entities/preferences_entity.dart';
import 'package:vector_map_tiles/vector_map_tiles.dart';
import '../datasources/map_remote_data_source.dart';

class MapRepository {
  final remoteDataSource = MapRemoteDataSource();

  MapRepository();

  Future<Style> getMapConfig(PreferencesEntity preferences) async {
    final model = PreferencesModel.fromEntity(preferences);
    return await remoteDataSource.getMapConfig(
      theme: model.mapTheme,
      language: model.mapLanguage,
    );
  }
}
