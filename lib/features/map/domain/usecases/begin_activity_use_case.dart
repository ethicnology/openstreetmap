import 'package:openstreetmap/features/map/domain/entities/activity_entity.dart';
import 'package:openstreetmap/features/map/domain/repositories/activity_repository.dart';
import 'package:openstreetmap/features/map/domain/repositories/location_repository.dart';

class BeginActivityUseCase {
  final activityRepository = ActivityRepository();
  final locationRepository = LocationRepository();

  BeginActivityUseCase();

  Future<ActivityEntity> call() async {
    final userLocation = await locationRepository.getCurrentLocation();

    final newActivity = ActivityEntity(
      id: DateTime.now().toUtc().toIso8601String(),
      name: 'Track',
      description: '',
      points: [
        ActivityPointEntity(
          latitude: userLocation.latitude,
          longitude: userLocation.longitude,
          elevation: userLocation.elevation,
          time: DateTime.now().toUtc(),
        ),
      ],
    );

    await activityRepository.store(newActivity);
    return newActivity;
  }
}
