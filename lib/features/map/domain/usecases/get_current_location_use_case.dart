import 'package:injectable/injectable.dart';
import 'package:latlong2/latlong.dart';
import '../repositories/location_repository.dart';

@injectable
class GetCurrentLocationUseCase {
  final LocationRepository repository;

  GetCurrentLocationUseCase(this.repository);

  Future<LatLng> run() async {
    final hasPermission = await repository.checkLocationPermission();
    if (!hasPermission) {
      final granted = await repository.requestLocationPermission();
      if (!granted) {
        throw Exception('Location permission denied');
      }
    }
    return await repository.getCurrentLocation();
  }
}
