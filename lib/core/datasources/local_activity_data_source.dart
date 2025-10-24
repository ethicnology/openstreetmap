import 'package:drift/drift.dart';
import 'package:openstreetmap/core/database/local_database.dart';
import 'package:openstreetmap/core/errors.dart';
import 'package:openstreetmap/core/locator.dart';
import 'package:openstreetmap/core/models/activity_model.dart';

class LocalActivityDataSource {
  final db = getIt.get<LocalDatabase>();

  LocalActivityDataSource();

  Future<void> store(ActivityModel activity) async {
    await db
        .into(db.activities)
        .insert(
          ActivitiesCompanion(
            id: Value(activity.id),
            name: Value(activity.name),
            description: Value(activity.description),
            createdAt: Value(activity.createdAt),
            startedAt: Value(activity.startedAt),
            stoppedAt: Value(activity.stoppedAt),
          ),
        );

    await score(activity.id, activity.points);
  }

  Future<void> score(String activityId, List<ActivityPointModel> points) async {
    for (final point in points) {
      await db
          .into(db.activityPoints)
          .insert(
            ActivityPointsCompanion(
              activityId: Value(activityId),
              latitude: Value(point.latitude),
              longitude: Value(point.longitude),
              elevation: Value(point.elevation),
              time: Value(point.time),
              status: Value(point.status),
            ),
          );
    }
  }

  Future<void> cease(String activityId) async {
    // if stoppedAt is not null, throw an error
    final activity =
        await (db.select(db.activities)
          ..where((t) => t.id.equals(activityId))).getSingleOrNull();

    if (activity == null) throw AppError('Activity not found');
    if (activity.stoppedAt != null) throw AppError('Activity already stopped');

    await (db.update(db.activities)..where(
      (t) => t.id.equals(activityId),
    )).write(ActivitiesCompanion(stoppedAt: Value(DateTime.now().toUtc())));
  }

  Future<List<ActivityModel>> fetch() async {
    final query = db.select(db.activities).join([
      leftOuterJoin(
        db.activityPoints,
        db.activityPoints.activityId.equalsExp(db.activities.id),
      ),
    ]);

    final results = await query.get();
    final activityMap = <String, ActivityModel>{};

    for (final row in results) {
      final activity = row.readTable(db.activities);
      final point = row.readTableOrNull(db.activityPoints);

      activityMap.putIfAbsent(
        activity.id.toString(),
        () => ActivityModel(
          id: activity.id.toString(),
          name: activity.name,
          description: activity.description,
          createdAt: activity.createdAt,
          points: [],
          startedAt: activity.startedAt,
          stoppedAt: activity.stoppedAt,
        ),
      );

      if (point != null) {
        activityMap[activity.id]!.points.add(
          ActivityPointModel(
            latitude: point.latitude,
            longitude: point.longitude,
            elevation: point.elevation,
            time: point.time,
            status: point.status,
          ),
        );
      }
    }

    for (final activity in activityMap.values) {
      // sort points by time
      activity.points.sort((a, b) => a.time.compareTo(b.time));
    }

    final activities = activityMap.values.toList();
    activities.sort((a, b) => b.startedAt.compareTo(a.startedAt));
    return activities;
  }
}
