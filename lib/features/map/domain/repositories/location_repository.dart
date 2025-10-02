import 'package:openstreetmap/features/map/domain/entities/position_entity.dart';

import '../../data/datasources/location_remote_data_source.dart';

class LocationRepository {
  final remoteDataSource = LocationRemoteDataSource();

  LocationRepository();

  Future<PositionEntity> getCurrentLocation() async {
    final position = await remoteDataSource.getCurrentLocation();
    return PositionEntity(
      latitude: position.latitude,
      longitude: position.longitude,
      elevation: position.altitude,
    );
  }

  Future<bool> requestLocationPermission() async {
    return await remoteDataSource.requestLocationPermission();
  }

  Future<bool> checkLocationPermission() async {
    return await remoteDataSource.checkLocationPermission();
  }
}
