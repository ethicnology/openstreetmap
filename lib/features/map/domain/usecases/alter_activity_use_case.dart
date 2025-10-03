import 'package:openstreetmap/features/map/domain/entities/activity_entity.dart';
import 'package:openstreetmap/features/map/domain/repositories/activity_repository.dart';
import 'package:openstreetmap/features/map/domain/repositories/location_repository.dart';

class AlterActivityUseCase {
  final activityRepository = ActivityRepository();
  final locationRepository = LocationRepository();

  AlterActivityUseCase();

  Future<ActivityPointEntity> call({required String activityId}) async {
    final userLocation = await locationRepository.getCurrentLocation();
    final newPoint = ActivityPointEntity(
      latitude: userLocation.latitude,
      longitude: userLocation.longitude,
      elevation: userLocation.elevation,
      time: DateTime.now().toUtc(),
    );

    await activityRepository.storePoints(activityId, [newPoint]);
    return newPoint;
  }
}
