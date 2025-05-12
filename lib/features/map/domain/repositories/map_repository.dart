import 'package:injectable/injectable.dart';
import 'package:vector_map_tiles/vector_map_tiles.dart';
import '../../data/datasources/map_remote_data_source.dart';

@LazySingleton()
class MapRepository {
  final MapRemoteDataSource remoteDataSource;

  MapRepository(this.remoteDataSource);

  Future<Style> getMapConfig() async {
    return await remoteDataSource.getMapConfig();
  }
}
