import 'package:openstreetmap/features/map/domain/repositories/activity_repository.dart';
import 'package:openstreetmap/features/map/domain/repositories/location_repository.dart';

class CeaseActivityUseCase {
  final locationRepository = LocationRepository();
  final activityRepository = ActivityRepository();

  CeaseActivityUseCase();

  void call(String activityId) {
    activityRepository.cease(activityId);
    locationRepository.dispose();
  }
}
