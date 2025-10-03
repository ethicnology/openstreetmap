import 'package:latlong2/latlong.dart';

sealed class MapEvent {
  const MapEvent();
}

class FetchMap extends MapEvent {
  const FetchMap();
}

class FetchLocation extends MapEvent {
  const FetchLocation();
}

class BeginActivity extends MapEvent {
  const BeginActivity();
}

class CeaseActivity extends MapEvent {
  const CeaseActivity();
}

class ScoreActivity extends MapEvent {
  const ScoreActivity();
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
