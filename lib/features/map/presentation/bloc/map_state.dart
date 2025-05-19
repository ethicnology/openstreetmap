import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:vector_map_tiles/vector_map_tiles.dart';
import 'package:latlong2/latlong.dart';
import 'package:openstreetmap/features/map/domain/entities/gps_track_point_entity.dart';

part 'map_state.freezed.dart';

@freezed
class MapState with _$MapState {
  const factory MapState.initial() = MapInitial;
  const factory MapState.loading() = MapLoading;
  const factory MapState.loaded({required Style style}) = MapLoaded;
  const factory MapState.loadedWithLocation({
    required Style style,
    required LatLng currentLocation,
    @Default(<GpsTrackPointEntity>[]) List<GpsTrackPointEntity> gpsTraces,
    @Default(false) bool loadingGpsTraces,
    @Default(true) bool showLocationMarker,
    LatLng? searchCenter,
  }) = MapLoadedWithLocation;
  const factory MapState.error(String message) = MapError;
}
