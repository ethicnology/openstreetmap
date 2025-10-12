import 'package:openstreetmap/core/errors.dart';
import 'package:openstreetmap/core/entities/position_entity.dart';
import '../repositories/location_repository.dart';

class GetUserLocationUseCase {
  final repository = LocationRepository();

  GetUserLocationUseCase();

  Future<PositionEntity> call() async {
    final hasPermission = await repository.checkLocationPermission();
    if (!hasPermission) {
      final granted = await repository.requestLocationPermission();
      if (!granted) throw AppError('Location permission not granted');
    }
    return await repository.getCurrentLocation();
  }
}
