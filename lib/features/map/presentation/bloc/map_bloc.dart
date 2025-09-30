import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:openstreetmap/core/errors.dart';
import 'package:openstreetmap/features/map/presentation/bloc/map_event.dart';
import 'package:openstreetmap/features/map/presentation/bloc/map_state.dart';
import 'package:openstreetmap/features/map/domain/usecases/get_current_location_use_case.dart';
import 'package:openstreetmap/features/map/domain/usecases/get_map_tile_url_use_case.dart';
import 'package:openstreetmap/features/map/domain/usecases/get_traces_use_case.dart';

const double kSearchHalfSideDegrees = 0.01425;

@injectable
class MapBloc extends Bloc<MapEvent, MapState> {
  final _getMapConfig = GetMapConfigUseCase();
  final _getCurrentLocation = GetCurrentLocationUseCase();
  final _getPublicGpsTraces = GetTracesUseCase();

  MapBloc() : super(const MapState()) {
    on<MapRequested>(_onMapLoading);
    on<LocationRequested>(_onLocationRequested);
    on<TracesRequested>(_onTracesSearchRequested);

    add(const MapRequested());
  }

  Future<void> _onMapLoading(MapRequested event, Emitter<MapState> emit) async {
    emit(state.copyWith(isLoading: true));
    try {
      final style = await _getMapConfig();
      emit(state.copyWith(style: style));
    } catch (e) {
      emit(state.copyWith(errorMessage: AppError('Failed to load style: $e')));
    } finally {
      emit(state.copyWith(isLoading: false));
    }
  }

  Future<void> _onLocationRequested(
    LocationRequested event,
    Emitter<MapState> emit,
  ) async {
    try {
      final userLocation = await _getCurrentLocation();
      emit(state.copyWith(userLocation: userLocation));
    } catch (e) {
      emit(
        state.copyWith(errorMessage: AppError('Failed to get location: $e')),
      );
    }
  }

  Future<void> _onTracesSearchRequested(
    TracesRequested event,
    Emitter<MapState> emit,
  ) async {
    try {
      final center = event.center;
      final double lat = center.latitude;
      final double lon = center.longitude;
      final double halfBox = kSearchHalfSideDegrees;
      final double left = lon - halfBox;
      final double right = lon + halfBox;
      final double bottom = lat - halfBox;
      final double top = lat + halfBox;

      emit(state.copyWith(searchCenter: center, isLoading: true));
      final traces = await _getPublicGpsTraces(left, bottom, right, top, 0);
      emit(state.copyWith(traces: traces));
    } catch (e) {
      emit(state.copyWith(errorMessage: AppError('Failed to get traces: $e')));
    } finally {
      emit(state.copyWith(isLoading: false));
    }
  }
}
