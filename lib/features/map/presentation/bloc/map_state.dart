import 'package:vector_map_tiles/vector_map_tiles.dart';

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
  const MapLoaded(this.style);
}

class MapError extends MapState {
  final String message;
  const MapError(this.message);
}
