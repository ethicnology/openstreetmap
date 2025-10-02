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

class StartActivity extends MapEvent {
  const StartActivity();
}

class StopActivity extends MapEvent {
  const StopActivity();
}

class AlterActivity extends MapEvent {
  const AlterActivity();
}

class PauseActivity extends MapEvent {
  const PauseActivity();
}

class FetchTraces extends MapEvent {
  const FetchTraces({required this.center});

  final LatLng center;
}
