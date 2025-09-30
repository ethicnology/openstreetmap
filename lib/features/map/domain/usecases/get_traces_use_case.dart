import 'package:openstreetmap/features/map/domain/entities/trace_entity.dart';
import 'package:openstreetmap/features/map/domain/repositories/trace_repository.dart';

class GetTracesUseCase {
  final repository = TraceRepository();

  GetTracesUseCase();

  Future<List<TraceEntity>> call(
    double left,
    double bottom,
    double right,
    double top,
    int page,
  ) async {
    final traces = await repository.fetch(left, bottom, right, top, page);
    await repository.store(traces);
    return traces;
  }
}
