import 'package:openstreetmap/core/errors.dart';
import 'package:openstreetmap/features/map/domain/entities/position_entity.dart';
import 'package:openstreetmap/features/map/domain/repositories/location_repository.dart';

class StartTrackPositionUseCase {
  final locationRepository = LocationRepository();

  StartTrackPositionUseCase();

  Future<Stream<PositionEntity>> call() async {
    final hasPermission = await locationRepository.checkLocationPermission();
    if (!hasPermission) {
      final granted = await locationRepository.requestLocationPermission();
      if (!granted) throw AppError('Location permission not granted');
    }
    return locationRepository.getPositionStream();
  }
}
