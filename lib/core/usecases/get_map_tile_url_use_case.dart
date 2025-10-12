import 'package:vector_map_tiles/vector_map_tiles.dart';
import '../repositories/map_repository.dart';

class GetMapConfigUseCase {
  final repository = MapRepository();

  GetMapConfigUseCase();

  Future<Style> call() async => await repository.getMapConfig();
}
