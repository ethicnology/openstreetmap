import 'package:injectable/injectable.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';

@LazySingleton()
class LocationRemoteDataSource {
  Future<LatLng> getCurrentLocation() async {
    final position = await Geolocator.getCurrentPosition();
    return LatLng(position.latitude, position.longitude);
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
