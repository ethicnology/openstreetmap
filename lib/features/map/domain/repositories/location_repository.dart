import 'package:injectable/injectable.dart';
import 'package:latlong2/latlong.dart';
import '../../data/datasources/location_remote_data_source.dart';

abstract class LocationRepository {
  Future<LatLng> getCurrentLocation();
  Future<bool> requestLocationPermission();
  Future<bool> checkLocationPermission();
}

@LazySingleton(as: LocationRepository)
class LocationRepositoryImpl implements LocationRepository {
  final LocationRemoteDataSource remoteDataSource;

  LocationRepositoryImpl(this.remoteDataSource);

  @override
  Future<LatLng> getCurrentLocation() async {
    return await remoteDataSource.getCurrentLocation();
  }

  @override
  Future<bool> requestLocationPermission() async {
    return await remoteDataSource.requestLocationPermission();
  }

  @override
  Future<bool> checkLocationPermission() async {
    return await remoteDataSource.checkLocationPermission();
  }
}
