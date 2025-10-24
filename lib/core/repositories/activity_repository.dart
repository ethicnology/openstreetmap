import 'package:openstreetmap/core/datasources/local_activity_data_source.dart';
import 'package:openstreetmap/core/models/activity_model.dart';
import 'package:openstreetmap/core/entities/activity_entity.dart';

class ActivityRepository {
  final localActivities = LocalActivityDataSource();

  ActivityRepository();

  Future<void> store(ActivityEntity activity) async {
    final model = ActivityModel.fromEntity(activity);
    await localActivities.store(model);
  }

  Future<List<ActivityEntity>> fetch() async {
    final models = await localActivities.fetch();
    return models.map(ActivityModel.toEntity).toList();
  }

  Future<void> score(
    String activityId,
    List<ActivityPointEntity> points,
  ) async {
    final models = points.map(ActivityPointModel.fromEntity).toList();
    await localActivities.score(activityId, models);
  }

  Future<void> cease(String activityId) async {
    await localActivities.cease(activityId);
  }
}
