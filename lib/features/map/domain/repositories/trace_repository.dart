import 'package:openstreetmap/features/map/data/datasources/trace_local_data_source.dart';
import 'package:openstreetmap/features/map/data/datasources/trace_remote_data_source.dart';
import 'package:openstreetmap/features/map/domain/entities/trace_entity.dart';
import 'package:openstreetmap/features/map/data/mappers/trace_mapper.dart';

class TraceRepository {
  final remoteTraces = TraceRemoteDataSource();
  final localTraces = TraceLocalDataSource();

  TraceRepository();

  Future<List<TraceEntity>> fetch(
    double left,
    double bottom,
    double right,
    double top,
    int page,
  ) async {
    final traces = await remoteTraces.getPublicTraces(
      left,
      bottom,
      right,
      top,
      page,
    );

    return TraceMapper.toEntities(traces);
  }

  Future<void> store(List<TraceEntity> traces) async {
    final models = TraceMapper.fromEntities(traces);
    for (final model in models) {
      await localTraces.store(model);
    }
  }
}
