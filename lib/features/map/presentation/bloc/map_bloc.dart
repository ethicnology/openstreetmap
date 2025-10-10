import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:openstreetmap/core/errors.dart';
import 'package:openstreetmap/features/activities/domain/usecases/get_activity_statistics_use_case.dart';
import 'package:openstreetmap/features/map/domain/entities/activity_entity.dart';
import 'package:openstreetmap/features/map/domain/entities/position_entity.dart';
import 'package:openstreetmap/features/map/domain/usecases/start_track_position_use_case.dart';
import 'package:openstreetmap/features/map/domain/usecases/score_activity_use_case.dart';
import 'package:openstreetmap/features/map/domain/usecases/start_activity_use_case.dart';
import 'package:openstreetmap/features/map/domain/usecases/cease_activity_use_case.dart';
import 'package:openstreetmap/features/map/presentation/bloc/map_event.dart';
import 'package:openstreetmap/features/map/presentation/bloc/map_state.dart';
import 'package:openstreetmap/features/map/domain/usecases/get_user_location_use_case.dart';
import 'package:openstreetmap/features/map/domain/usecases/get_map_tile_url_use_case.dart';
import 'package:openstreetmap/features/map/domain/usecases/get_traces_use_case.dart';
import 'package:openstreetmap/features/map/presentation/error.dart';

const double kSearchHalfSideDegrees = 0.01425;

class MapBloc extends Bloc<MapEvent, MapState> {
  final _getMapConfigUseCase = GetMapConfigUseCase();
  final _getUserLocationUseCase = GetUserLocationUseCase();
  final _getPublicGpsTracesUseCase = GetTracesUseCase();
  final _beginActivityUseCase = StartActivityUseCase();
  final _scoreActivityUseCase = ScoreActivityUseCase();
  final _ceaseActivityUsecase = CeaseActivityUseCase();
  final _startTrackPositionUsecase = StartTrackPositionUseCase();
  final _getActivityStatisticsUseCase = GetActivityStatisticsUseCase();

  StreamSubscription<PositionEntity>? _positionStream;
  Timer? _elapsedTimer;
  DateTime? _activityStartTime;

  MapBloc() : super(const MapState()) {
    on<FetchMap>(_onMapLoading);
    on<FetchLocation>(_onLocationRequested);
    on<FetchTraces>(_onTracesSearchRequested);
    on<StartActivity>(_onStartActivity);
    on<CeaseActivity>(_onCeaseActivity);
    on<ScoreActivity>(_onScoreActivity);
    on<PauseActivity>(_onPauseActivity);
    on<ClearError>(_onClearError);
    on<UpdateElapsedTime>(_onUpdateElapsedTime);

    add(const FetchMap());
  }

  @override
  Future<void> close() async {
    await _positionStream?.cancel();
    _positionStream = null;
    _elapsedTimer?.cancel();
    _elapsedTimer = null;
    return super.close();
  }

  Future<void> _onMapLoading(FetchMap event, Emitter<MapState> emit) async {
    emit(state.copyWith(isLoading: true));
    try {
      final style = await _getMapConfigUseCase();
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
      final userLocation = await _getUserLocationUseCase();
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
      final traces = await _getPublicGpsTracesUseCase(
        left,
        bottom,
        right,
        top,
        0,
      );
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
    await _positionStream?.cancel();
    _elapsedTimer?.cancel();

    final userPositionStream = await _startTrackPositionUsecase();
    final activity = await _beginActivityUseCase();

    _positionStream = userPositionStream
        .handleError((error) => print('error: $error'))
        .listen((position) => add(ScoreActivity(position: position)));

    _activityStartTime = DateTime.now();
    _elapsedTimer = Timer.periodic(
      const Duration(seconds: 1),
      (_) => add(const UpdateElapsedTime()),
    );

    emit(state.copyWith(activity: activity));
  }

  Future<void> _onScoreActivity(
    ScoreActivity event,
    Emitter<MapState> emit,
  ) async {
    if (state.activity == null) throw ActivityNotStartedError();

    final activity = state.activity!;
    final position = event.position;

    try {
      final newPoint = await _scoreActivityUseCase(
        activityId: activity.id,
        position: position,
        status:
            state.isPaused
                ? ActivityPointStatusEntity.paused
                : ActivityPointStatusEntity.active,
      );
      final updatedPoints = [...state.points, newPoint];

      final updatedActivity = activity.copyWith(points: updatedPoints);
      final statistics = _getActivityStatisticsUseCase(updatedActivity);

      emit(state.copyWith(points: updatedPoints, statistics: statistics));
    } catch (e) {
      emit(
        state.copyWith(
          errorMessage: AppError('Failed to record location: ${e.toString()}'),
        ),
      );
    }
  }

  Future<void> _onCeaseActivity(
    CeaseActivity event,
    Emitter<MapState> emit,
  ) async {
    _ceaseActivityUsecase(state.activity!.id);
    await _positionStream?.cancel();
    _positionStream = null;
    _elapsedTimer?.cancel();
    _elapsedTimer = null;
    _activityStartTime = null;

    emit(
      state.copyWith(
        activity: null,
        elapsedTime: Duration.zero,
        points: [],
        statistics: null,
        isPaused: false,
      ),
    );
  }

  void _onPauseActivity(PauseActivity event, Emitter<MapState> emit) {
    if (state.activity == null) throw ActivityNotStartedError();
    if (_positionStream == null) throw ActivityNotStartedError();

    if (state.isPaused) {
      emit(state.copyWith(isPaused: false));
    } else {
      emit(state.copyWith(isPaused: true));
    }
  }

  void _onClearError(ClearError event, Emitter<MapState> emit) {
    emit(state.copyWith(errorMessage: null));
  }

  void _onUpdateElapsedTime(UpdateElapsedTime event, Emitter<MapState> emit) {
    if (_activityStartTime != null && !state.isPaused) {
      final elapsed = DateTime.now().difference(_activityStartTime!);
      emit(state.copyWith(elapsedTime: elapsed));
    }
  }
}
