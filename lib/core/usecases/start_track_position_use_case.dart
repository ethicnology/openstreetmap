import 'package:furtive/core/errors.dart';
import 'package:furtive/core/entities/position_entity.dart';
import 'package:furtive/core/repositories/location_repository.dart';
import 'package:furtive/core/repositories/preferences_repository.dart';

class StartTrackPositionUseCase {
  final locationRepository = LocationRepository();
  final preferencesRepository = PreferencesRepository();

  StartTrackPositionUseCase();

  Future<Stream<PositionEntity>> call() async {
    final hasPermission = await locationRepository.checkLocationPermission();
    if (!hasPermission) {
      final granted = await locationRepository.requestLocationPermission();
      if (!granted) throw AppError('Location permission not granted');
    }
    final preferences = await preferencesRepository.fetch();
    return locationRepository.getPositionStream(
      accuracyInMeters: preferences.accuracyInMeters,
    );
  }
}
