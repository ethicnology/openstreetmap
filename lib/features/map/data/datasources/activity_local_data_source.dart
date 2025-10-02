import 'package:drift/drift.dart';
import 'package:openstreetmap/core/database/local_database.dart';
import 'package:openstreetmap/core/locator/locator.dart';
import 'package:openstreetmap/features/map/data/models/activity_model.dart';

class ActivityLocalDataSource {
  final db = getIt.get<LocalDatabase>();

  ActivityLocalDataSource();

  Future<void> store(ActivityModel activity) async {
    await db
        .into(db.activities)
        .insert(
          ActivitiesCompanion(
            id: Value(activity.id),
            name: Value(activity.name),
            description: Value(activity.description),
          ),
        );

    for (final point in activity.points) {
      await db
          .into(db.activityPoints)
          .insert(
            ActivityPointsCompanion(
              latitude: Value(point.latitude),
              longitude: Value(point.longitude),
              elevation: Value(point.elevation),
              time: Value(point.time),
              activityId: Value(activity.id),
            ),
          );
    }
  }

  Future<void> storePoints(
    String activityId,
    List<ActivityPointModel> points,
  ) async {
    for (final point in points) {
      await db
          .into(db.activityPoints)
          .insert(
            ActivityPointsCompanion(
              latitude: Value(point.latitude),
              longitude: Value(point.longitude),
              elevation: Value(point.elevation),
              time: Value(point.time),
              activityId: Value(activityId),
            ),
          );
    }
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
      final point = row.readTable(db.activityPoints);

      activityMap.putIfAbsent(
        activity.id.toString(),
        () => ActivityModel(
          id: activity.id.toString(),
          name: activity.name,
          description: activity.description,
          points: [],
        ),
      );

      activityMap[activity.id]!.points.add(
        ActivityPointModel(
          latitude: point.latitude,
          longitude: point.longitude,
          elevation: point.elevation,
          time: point.time,
        ),
      );
    }

    return activityMap.values.toList();
  }
}
