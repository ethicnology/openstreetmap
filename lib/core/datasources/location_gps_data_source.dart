import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:furtive/core/errors.dart';

class LocationGpsDataSource {
  StreamSubscription<Position>? _positionStreamSubscription;
  StreamSubscription<ServiceStatus>? _serviceStatusStreamSubscription;

  Future<Position> getCurrentLocation() async {
    final hasPermission = await checkLocationPermission();
    if (!hasPermission) {
      final granted = await requestLocationPermission();
      if (!granted) throw LocationPermissionError();
    }

    final position = await Geolocator.getCurrentPosition();
    return position;
  }

  Stream<Position> getPositionStream({required int accuracyInMeters}) {
    final locationSettings = getLocationSettings(
      accuracyInMeters: accuracyInMeters,
    );
    return Geolocator.getPositionStream(locationSettings: locationSettings);
  }

  Stream<ServiceStatus> getServiceStatusStream() {
    return Geolocator.getServiceStatusStream();
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

  Future<bool> isLocationServiceEnabled() async {
    return await Geolocator.isLocationServiceEnabled();
  }

  getLocationSettings({required int accuracyInMeters}) {
    late LocationSettings locationSettings;

    if (defaultTargetPlatform == TargetPlatform.android) {
      locationSettings = AndroidSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: accuracyInMeters,
        forceLocationManager: true,
        intervalDuration: const Duration(milliseconds: 5000),
        useMSLAltitude: true,
        //(Optional) Set foreground notification config to keep the app alive
        //when going to the background
        foregroundNotificationConfig: const ForegroundNotificationConfig(
          notificationText:
              "This app will continue to receive your location when your phone is locked",
          notificationTitle: "Running in background",
          enableWakeLock: false,
        ),
      );
    } else if (defaultTargetPlatform == TargetPlatform.iOS ||
        defaultTargetPlatform == TargetPlatform.macOS) {
      locationSettings = AppleSettings(
        accuracy: LocationAccuracy.high,
        activityType: ActivityType.fitness,
        distanceFilter: accuracyInMeters,
        pauseLocationUpdatesAutomatically: true,
        // Only set to true if our app will be started up in the background.
        showBackgroundLocationIndicator: false,
        allowBackgroundLocationUpdates: false,
      );
    } else {
      locationSettings = LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: accuracyInMeters,
      );
    }
    return locationSettings;
  }

  void dispose() {
    _positionStreamSubscription?.cancel();
    _serviceStatusStreamSubscription?.cancel();
  }
}

class LocationPermissionError extends AppError {
  LocationPermissionError() : super('Location permission not granted');
}
