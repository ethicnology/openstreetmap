import 'package:openstreetmap/core/entities/activity_entity.dart';
import 'package:openstreetmap/features/map/domain/repositories/activity_repository.dart';

class StartActivityUseCase {
  final activityRepository = ActivityRepository();

  StartActivityUseCase();

  Future<ActivityEntity> call() async {
    final startedAt = DateTime.now().toUtc();
    final newActivity = ActivityEntity(
      id: startedAt.toIso8601String(),
      name: 'Track',
      description: '',
      createdAt: startedAt,
      startedAt: startedAt,
      stoppedAt: null,
    );

    activityRepository.store(newActivity);
    return newActivity;
  }
}
