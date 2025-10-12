import 'package:openstreetmap/core/entities/trace_entity.dart';
import 'package:openstreetmap/core/repositories/trace_repository.dart';

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
