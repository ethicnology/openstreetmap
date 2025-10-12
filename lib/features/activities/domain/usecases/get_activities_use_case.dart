import 'package:openstreetmap/core/entities/activity_entity.dart';
import 'package:openstreetmap/features/map/domain/repositories/activity_repository.dart';

class GetActivitiesUseCase {
  final activityRepository = ActivityRepository();

  GetActivitiesUseCase();

  Future<List<ActivityEntity>> call() async {
    return await activityRepository.fetch();
  }
}
