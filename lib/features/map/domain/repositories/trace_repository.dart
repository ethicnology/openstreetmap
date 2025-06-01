import 'package:openstreetmap/features/map/data/datasources/trace_local_data_source.dart';
import 'package:openstreetmap/features/map/data/datasources/trace_remote_data_source.dart';
import 'package:openstreetmap/features/map/domain/entities/trace_entity.dart';
import 'package:openstreetmap/features/map/data/models/trace_model.dart';

class TraceRepository {
  final TraceRemoteDataSource remoteTraces;
  final TraceLocalDataSource localTraces;

  TraceRepository(this.remoteTraces, this.localTraces);

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

    for (final trace in traces) {
      await localTraces.store(trace);
    }

    return traces
        .map(
          (trace) => TraceEntity(
            name: trace.name,
            description: trace.description,
            url: trace.url,
            points:
                trace.points
                    .map(
                      (point) => TracePointEntity(
                        latitude: point.latitude,
                        longitude: point.longitude,
                        elevation: point.elevation,
                        time: point.time,
                      ),
                    )
                    .toList(),
          ),
        )
        .toList();
  }

  Future<void> store(List<TraceEntity> traces) async {
    final models =
        traces
            .map(
              (trace) => TraceModel(
                name: trace.name,
                description: trace.description,
                url: trace.url,
                points:
                    trace.points
                        .map(
                          (point) => TracePointModel(
                            latitude: point.latitude,
                            longitude: point.longitude,
                            elevation: point.elevation,
                            time: point.time,
                          ),
                        )
                        .toList(),
              ),
            )
            .toList();

    for (final model in models) {
      await localTraces.store(model);
    }
  }
}
