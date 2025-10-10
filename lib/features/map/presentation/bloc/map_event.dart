import 'package:latlong2/latlong.dart';
import 'package:openstreetmap/features/map/domain/entities/position_entity.dart';

sealed class MapEvent {
  const MapEvent();
}

class FetchMap extends MapEvent {
  const FetchMap();
}

class FetchLocation extends MapEvent {
  const FetchLocation();
}

class StartActivity extends MapEvent {
  const StartActivity();
}

class CeaseActivity extends MapEvent {
  const CeaseActivity();
}

class ScoreActivity extends MapEvent {
  final PositionEntity position;
  const ScoreActivity({required this.position});
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
