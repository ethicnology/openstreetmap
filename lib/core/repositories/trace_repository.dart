import 'package:openstreetmap/core/datasources/trace_local_data_source.dart';
import 'package:openstreetmap/core/datasources/trace_remote_data_source.dart';
import 'package:openstreetmap/core/models/trace_model.dart';
import 'package:openstreetmap/core/entities/trace_entity.dart';

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

    return traces.map(TraceModel.toEntity).toList();
  }

  Future<void> store(List<TraceEntity> traces) async {
    final models = traces.map(TraceModel.fromEntity).toList();
    for (final model in models) {
      await localTraces.store(model);
    }
  }
}
