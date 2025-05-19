import 'package:openstreetmap/features/map/domain/repositories/gps_trace_repository.dart';
import 'package:openstreetmap/features/map/domain/entities/gps_track_point_entity.dart';

class GetPublicGpsTracesUseCase {
  final GpsTraceRepository repository;
  GetPublicGpsTracesUseCase(this.repository);

  Future<List<GpsTrackPointEntity>> run(
    double left,
    double bottom,
    double right,
    double top,
    int page,
  ) => repository.getPublicTraces(left, bottom, right, top, page);
}
