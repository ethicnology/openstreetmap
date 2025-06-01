import 'package:openstreetmap/features/map/domain/entities/trace_entity.dart';
import 'package:openstreetmap/features/map/domain/repositories/trace_repository.dart';

class GetTracesUseCase {
  final TraceRepository repository;
  GetTracesUseCase(this.repository);

  Future<List<TraceEntity>> run(
    double left,
    double bottom,
    double right,
    double top,
    int page,
  ) async {
    final traces = await repository.fetch(left, bottom, right, top, page);
    return traces;
  }
}
