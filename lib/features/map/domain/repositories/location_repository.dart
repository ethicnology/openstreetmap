import 'package:injectable/injectable.dart';
import 'package:latlong2/latlong.dart';
import '../../data/datasources/location_remote_data_source.dart';

@LazySingleton()
class LocationRepository {
  final LocationRemoteDataSource remoteDataSource;

  LocationRepository(this.remoteDataSource);

  Future<LatLng> getCurrentLocation() async {
    return await remoteDataSource.getCurrentLocation();
  }

  Future<bool> requestLocationPermission() async {
    return await remoteDataSource.requestLocationPermission();
  }

  Future<bool> checkLocationPermission() async {
    return await remoteDataSource.checkLocationPermission();
  }
}
