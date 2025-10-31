import 'package:furtive/core/entities/activity_entity.dart';
import 'package:furtive/core/repositories/activity_repository.dart';

class GetActivitiesUseCase {
  final activityRepository = ActivityRepository();

  GetActivitiesUseCase();

  Future<List<ActivityEntity>> call() async {
    return await activityRepository.fetch();
  }
}
