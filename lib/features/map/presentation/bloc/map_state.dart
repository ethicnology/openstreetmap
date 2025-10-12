import 'package:dart_mappable/dart_mappable.dart';
import 'package:openstreetmap/core/errors.dart';
import 'package:openstreetmap/core/entities/activity_entity.dart';
import 'package:openstreetmap/features/map/domain/entities/position_entity.dart';
import 'package:openstreetmap/features/map/domain/entities/trace_entity.dart';
import 'package:vector_map_tiles/vector_map_tiles.dart';

part 'map_state.mapper.dart';

@MappableClass()
class MapState with MapStateMappable {
  final Style? style;
  final PositionEntity? userLocation;
  final PositionEntity? searchCenter;
  final AppError? errorMessage;
  final List<TraceEntity> traces;
  final bool isLoading;
  final ActivityEntity? activity;
  final Duration elapsedTime;
  final bool isPaused;

  const MapState({
    this.style,
    this.userLocation,
    this.searchCenter,
    this.errorMessage,
    this.traces = const [],
    this.isLoading = false,
    this.activity,
    this.elapsedTime = Duration.zero,
    this.isPaused = false,
  });
}
