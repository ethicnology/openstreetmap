import 'package:vector_map_tiles/vector_map_tiles.dart';
import 'package:latlong2/latlong.dart';

sealed class MapState {
  const MapState();
}

class MapInitial extends MapState {
  const MapInitial();
}

class MapLoading extends MapState {
  const MapLoading();
}

class MapLoaded extends MapState {
  final Style style;
  final LatLng? currentLocation;
  const MapLoaded(this.style, {this.currentLocation});
}

class MapError extends MapState {
  final String message;
  const MapError(this.message);
}
