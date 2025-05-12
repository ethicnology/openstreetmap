import 'package:injectable/injectable.dart';
import 'package:vector_map_tiles/vector_map_tiles.dart';
import '../repositories/map_repository.dart';

@injectable
class GetMapConfig {
  final MapRepository repository;

  GetMapConfig(this.repository);

  Future<Style> call() async => await repository.getMapConfig();
}
