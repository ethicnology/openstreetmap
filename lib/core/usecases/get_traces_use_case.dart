import 'package:furtive/core/entities/trace_entity.dart';
import 'package:furtive/core/repositories/trace_repository.dart';

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
