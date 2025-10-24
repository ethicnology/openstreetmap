import 'dart:async';
import 'package:geolocator/geolocator.dart';
import 'package:openstreetmap/core/entities/position_entity.dart';

import '../datasources/location_remote_data_source.dart';

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

  Stream<PositionEntity> getPositionStream() {
    return remoteDataSource.getPositionStream().map((position) {
      return PositionEntity(
        latitude: position.latitude,
        longitude: position.longitude,
        elevation: position.altitude,
      );
    });
  }

  Stream<ServiceStatus> getServiceStatusStream() {
    return remoteDataSource.getServiceStatusStream();
  }

  Future<bool> requestLocationPermission() async {
    return await remoteDataSource.requestLocationPermission();
  }

  Future<bool> checkLocationPermission() async {
    return await remoteDataSource.checkLocationPermission();
  }

  Future<bool> isLocationServiceEnabled() async {
    return await remoteDataSource.isLocationServiceEnabled();
  }

  void dispose() => remoteDataSource.dispose();
}
