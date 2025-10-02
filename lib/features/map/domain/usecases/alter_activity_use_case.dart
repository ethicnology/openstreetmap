import 'package:openstreetmap/features/map/domain/entities/activity_entity.dart';
import 'package:openstreetmap/features/map/domain/repositories/activity_repository.dart';

class AlterActivityUseCase {
  final activityRepository = ActivityRepository();

  AlterActivityUseCase();

  Future<void> call({
    required String activityId,
    required ActivityPointEntity point,
  }) async {
    await activityRepository.storePoints(activityId, [point]);
  }
}
