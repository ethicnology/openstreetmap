import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:openstreetmap/core/errors.dart';
import 'package:openstreetmap/features/map/domain/entities/position_entity.dart';
import 'package:openstreetmap/features/map/domain/usecases/alter_activity_use_case.dart';
import 'package:openstreetmap/features/map/domain/usecases/begin_activity_use_case.dart';
import 'package:openstreetmap/features/map/presentation/bloc/map_event.dart';
import 'package:openstreetmap/features/map/presentation/bloc/map_state.dart';
import 'package:openstreetmap/features/map/domain/usecases/get_user_location_use_case.dart';
import 'package:openstreetmap/features/map/domain/usecases/get_map_tile_url_use_case.dart';
import 'package:openstreetmap/features/map/domain/usecases/get_traces_use_case.dart';
import 'package:openstreetmap/features/map/presentation/error.dart';

const double kSearchHalfSideDegrees = 0.01425;

class MapBloc extends Bloc<MapEvent, MapState> {
  final _getMapConfig = GetMapConfigUseCase();
  final _getUserLocation = GetUserLocationUseCase();
  final _getPublicGpsTraces = GetTracesUseCase();
  final _beginActivity = BeginActivityUseCase();
  final _alterActivity = AlterActivityUseCase();

  MapBloc() : super(const MapState()) {
    on<FetchMap>(_onMapLoading);
    on<FetchLocation>(_onLocationRequested);
    on<FetchTraces>(_onTracesSearchRequested);
    on<StartActivity>(_onStartActivity);
    on<StopActivity>(_onStopActivity);
    on<AlterActivity>(_onAlterActivity);
    on<PauseActivity>(_onPauseActivity);
    on<ClearError>(_onClearError);

    add(const FetchMap());
  }

  @override
  Future<void> close() {
    state.activityTimer?.cancel();
    return super.close();
  }

  Future<void> _onMapLoading(FetchMap event, Emitter<MapState> emit) async {
    emit(state.copyWith(isLoading: true));
    try {
      final style = await _getMapConfig();
      emit(state.copyWith(style: style));
    } catch (e) {
      emit(state.copyWith(errorMessage: AppError(e.toString())));
    } finally {
      emit(state.copyWith(isLoading: false));
    }
  }

  Future<void> _onLocationRequested(
    FetchLocation event,
    Emitter<MapState> emit,
  ) async {
    try {
      final userLocation = await _getUserLocation();
      emit(state.copyWith(userLocation: userLocation));
    } catch (e) {
      emit(state.copyWith(errorMessage: AppError(e.toString())));
    }
  }

  Future<void> _onTracesSearchRequested(
    FetchTraces event,
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

      emit(
        state.copyWith(
          searchCenter: PositionEntity(
            latitude: lat,
            longitude: lon,
            elevation: 0,
          ),
          isLoading: true,
        ),
      );
      final traces = await _getPublicGpsTraces(left, bottom, right, top, 0);
      emit(state.copyWith(traces: traces));
    } catch (e) {
      emit(state.copyWith(errorMessage: AppError(e.toString())));
    } finally {
      emit(state.copyWith(isLoading: false));
    }
  }

  Future<void> _onStartActivity(
    StartActivity event,
    Emitter<MapState> emit,
  ) async {
    state.activityTimer?.cancel();

    final activity = await _beginActivity();

    final activityTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      add(const AlterActivity());
    });

    emit(state.copyWith(activity: activity, activityTimer: activityTimer));
  }

  void _onStopActivity(StopActivity event, Emitter<MapState> emit) {
    state.activityTimer?.cancel();
    emit(
      state.copyWith(
        activityTimer: null,
        activity: null,
        elapsedTime: Duration.zero,
      ),
    );
  }

  void _onPauseActivity(PauseActivity event, Emitter<MapState> emit) {
    if (state.activityTimer == null) throw ActivityNotStartedError();

    final isTimerActive = state.activityTimer!.isActive;

    if (isTimerActive) {
      state.activityTimer?.cancel();
      emit(state.copyWith(isPaused: true));
    } else {
      final activityTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
        add(const AlterActivity());
      });
      emit(state.copyWith(activityTimer: activityTimer, isPaused: false));
    }
  }

  Future<void> _onAlterActivity(
    AlterActivity event,
    Emitter<MapState> emit,
  ) async {
    if (state.activity == null) throw ActivityNotStartedError();

    final newPoint = await _alterActivity(activityId: state.activity!.id);
    final updatedPoints = [...state.activity!.points, newPoint];

    final firstPointTime = DateTime.parse(state.activity!.id);
    final elapsedTime = DateTime.now().difference(firstPointTime);

    emit(
      state.copyWith(
        activity: state.activity?.copyWith(points: updatedPoints),
        elapsedTime: elapsedTime,
      ),
    );
  }

  void _onClearError(ClearError event, Emitter<MapState> emit) {
    emit(state.copyWith(errorMessage: null));
  }
}
