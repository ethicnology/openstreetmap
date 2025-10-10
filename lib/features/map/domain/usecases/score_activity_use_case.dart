import 'package:openstreetmap/features/map/domain/entities/activity_entity.dart';
import 'package:openstreetmap/features/map/domain/entities/position_entity.dart';
import 'package:openstreetmap/features/map/domain/repositories/activity_repository.dart';
import 'package:openstreetmap/features/map/domain/repositories/location_repository.dart';

class ScoreActivityUseCase {
  final activityRepository = ActivityRepository();
  final locationRepository = LocationRepository();

  ScoreActivityUseCase();

  Future<ActivityPointEntity> call({
    required String activityId,
    required PositionEntity position,
    required ActivityPointStatusEntity status,
  }) async {
    final newPoint = ActivityPointEntity(
      position: position,
      status: status,
      time: DateTime.now().toUtc(),
    );

    activityRepository.score(activityId, [newPoint]);

    return newPoint;
  }
}
