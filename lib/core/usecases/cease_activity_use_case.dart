import 'package:furtive/core/repositories/activity_repository.dart';
import 'package:furtive/core/repositories/location_repository.dart';

class CeaseActivityUseCase {
  final locationRepository = LocationRepository();
  final activityRepository = ActivityRepository();

  CeaseActivityUseCase();

  void call(String activityId) {
    activityRepository.cease(activityId);
    locationRepository.dispose();
  }
}
