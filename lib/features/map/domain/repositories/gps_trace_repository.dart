import 'package:openstreetmap/features/map/data/datasources/gps_trace_remote_data_source.dart';
import 'package:openstreetmap/features/map/domain/entities/gps_track_point_entity.dart';

class GpsTraceRepository {
  final GpsTraceRemoteDataSource remoteDataSource;
  GpsTraceRepository(this.remoteDataSource);
  Future<List<GpsTrackPointEntity>> getPublicTraces(
    double left,
    double bottom,
    double right,
    double top,
    int page,
  ) async {
    final models = await remoteDataSource.getPublicTraces(
      left,
      bottom,
      right,
      top,
      page,
    );
    return models
        .map((m) => GpsTrackPointEntity(lat: m.lat, lon: m.lon, time: m.time))
        .toList();
  }
}
