import 'package:drift/drift.dart';
import 'package:openstreetmap/core/database/local_database.dart';
import 'package:openstreetmap/features/map/data/models/trace_model.dart';

class TraceLocalDataSource {
  final LocalDatabase db;

  TraceLocalDataSource(this.db);

  Future<void> store(TraceModel trace) async {
    final traceId = await db
        .into(db.traceMetadatas)
        .insert(
          TraceMetadatasCompanion(
            name: Value(trace.name),
            description: Value(trace.description),
            url: Value(trace.url),
          ),
        );

    for (final point in trace.points) {
      await db
          .into(db.tracePoints)
          .insert(
            TracePointsCompanion(
              latitude: Value(point.latitude),
              longitude: Value(point.longitude),
              elevation: Value(point.elevation),
              time: Value(point.time),
              traceId: Value(traceId),
            ),
          );
    }
  }

  Future<List<TraceModel>> fetch() async {
    final query = db.select(db.traceMetadatas).join([
      leftOuterJoin(
        db.tracePoints,
        db.tracePoints.traceId.equalsExp(db.traceMetadatas.id),
      ),
    ]);

    final results = await query.get();
    final traceMap = <int, TraceModel>{};

    for (final row in results) {
      final trace = row.readTable(db.traceMetadatas);
      final point = row.readTable(db.tracePoints);

      traceMap.putIfAbsent(
        trace.id,
        () => TraceModel(
          name: trace.name,
          description: trace.description,
          url: trace.url,
          points: [],
        ),
      );

      traceMap[trace.id]!.points.add(
        TracePointModel(
          latitude: point.latitude,
          longitude: point.longitude,
          elevation: point.elevation,
          time: point.time,
        ),
      );
    }

    return traceMap.values.toList();
  }
}
