import 'package:latlong2/latlong.dart';

sealed class MapEvent {
  const MapEvent();
}

class MapRequested extends MapEvent {
  const MapRequested();
}

class LocationRequested extends MapEvent {
  const LocationRequested();
}

class TracesRequested extends MapEvent {
  const TracesRequested({required this.center});

  final LatLng center;
}
