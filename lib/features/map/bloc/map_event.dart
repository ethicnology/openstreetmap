import 'package:latlong2/latlong.dart';
import 'package:furtive/core/entities/position_entity.dart';

sealed class MapEvent {
  const MapEvent();
}

class InitMap extends MapEvent {
  const InitMap();
}

class StartActivity extends MapEvent {
  const StartActivity();
}

class CeaseActivity extends MapEvent {
  const CeaseActivity();
}

class ScoreActivity extends MapEvent {
  final PositionEntity position;
  ScoreActivity({required this.position});
}

class UpdateUserLocation extends MapEvent {
  final PositionEntity position;
  UpdateUserLocation({required this.position});
}

class PauseActivity extends MapEvent {
  const PauseActivity();
}

class FetchTraces extends MapEvent {
  const FetchTraces({required this.center});

  final LatLng center;
}

class ClearError extends MapEvent {
  const ClearError();
}

class UpdateElapsedTime extends MapEvent {
  const UpdateElapsedTime();
}

class ToggleFollowUser extends MapEvent {
  const ToggleFollowUser();
}

class StopFollowingUser extends MapEvent {
  const StopFollowingUser();
}
