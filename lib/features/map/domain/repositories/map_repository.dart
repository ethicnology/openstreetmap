import 'package:injectable/injectable.dart';
import 'package:vector_map_tiles/vector_map_tiles.dart';
import '../../data/datasources/map_remote_data_source.dart';

@LazySingleton()
class MapRepository {
  final remoteDataSource = MapRemoteDataSource();

  MapRepository();

  Future<Style> getMapConfig() async {
    return await remoteDataSource.getMapConfig();
  }
}
