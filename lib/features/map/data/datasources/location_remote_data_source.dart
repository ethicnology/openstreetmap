import 'package:geolocator/geolocator.dart';

class LocationRemoteDataSource {
  Future<Position> getCurrentLocation() async {
    final position = await Geolocator.getCurrentPosition();
    return position;
  }

  Future<bool> requestLocationPermission() async {
    final permission = await Geolocator.requestPermission();
    return permission == LocationPermission.whileInUse ||
        permission == LocationPermission.always;
  }

  Future<bool> checkLocationPermission() async {
    final permission = await Geolocator.checkPermission();
    return permission == LocationPermission.whileInUse ||
        permission == LocationPermission.always;
  }
}
