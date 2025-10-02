import 'package:openstreetmap/features/map/domain/entities/activity_entity.dart';
import 'package:openstreetmap/features/map/domain/repositories/activity_repository.dart';

class BeginActivityUseCase {
  final activityRepository = ActivityRepository();

  BeginActivityUseCase();

  Future<ActivityEntity> call() async {
    final newActivity = ActivityEntity(
      id: DateTime.now().toUtc().toIso8601String(),
      name: 'Track',
      description: '',
      points: [],
    );

    await activityRepository.store(newActivity);
    return newActivity;
  }
}
