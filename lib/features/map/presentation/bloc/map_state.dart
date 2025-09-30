import 'package:dart_mappable/dart_mappable.dart';
import 'package:openstreetmap/core/errors.dart';
import 'package:openstreetmap/features/map/domain/entities/trace_entity.dart';
import 'package:vector_map_tiles/vector_map_tiles.dart';
import 'package:latlong2/latlong.dart';

part 'map_state.mapper.dart';

@MappableClass()
class MapState with MapStateMappable {
  final Style? style;
  final LatLng? userLocation;
  final LatLng? searchCenter;
  final AppError? errorMessage;
  final List<TraceEntity> traces;
  final bool isLoading;

  const MapState({
    this.style,
    this.userLocation,
    this.searchCenter,
    this.errorMessage,
    this.traces = const [],
    this.isLoading = false,
  });
}
