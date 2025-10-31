import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:openstreetmap/core/errors.dart';
import 'package:openstreetmap/core/entities/activity_entity.dart';
import 'package:openstreetmap/core/entities/position_entity.dart';
import 'package:openstreetmap/core/logs.dart';
import 'package:openstreetmap/core/usecases/get_user_location_use_case.dart';
import 'package:openstreetmap/core/usecases/start_track_position_use_case.dart';
import 'package:openstreetmap/core/usecases/score_activity_use_case.dart';
import 'package:openstreetmap/core/usecases/start_activity_use_case.dart';
import 'package:openstreetmap/core/usecases/cease_activity_use_case.dart';
import 'package:openstreetmap/core/usecases/activity_notification_use_case.dart';
import 'package:openstreetmap/features/map/bloc/map_event.dart';
import 'package:openstreetmap/features/map/bloc/map_state.dart';
import 'package:openstreetmap/core/usecases/get_map_tile_url_use_case.dart';
import 'package:openstreetmap/core/usecases/get_traces_use_case.dart';
import 'package:openstreetmap/features/map/error.dart';

const double kSearchHalfSideDegrees = 0.01425;

class MapBloc extends Bloc<MapEvent, MapState> {
  final _getMapConfigUseCase = GetMapConfigUseCase();
  final _getPublicGpsTracesUseCase = GetTracesUseCase();
  final _beginActivityUseCase = StartActivityUseCase();
  final _scoreActivityUseCase = ScoreActivityUseCase();
  final _ceaseActivityUsecase = CeaseActivityUseCase();
  final _startTrackPositionUsecase = StartTrackPositionUseCase();
  final _getUserLocationUseCase = GetUserLocationUseCase();
  final _activityNotificationUseCase = ActivityNotificationUseCase();

  late StreamSubscription<PositionEntity> _positionStream;
  Timer? _elapsedTimer;
  DateTime? _activityStartTime;

  MapBloc() : super(const MapState()) {
    on<InitMap>(_onInitMap);
    on<FetchTraces>(_onTracesSearchRequested);
    on<StartActivity>(_onStartActivity);
    on<CeaseActivity>(_onCeaseActivity);
    on<ScoreActivity>(_onScoreActivity);
    on<PauseActivity>(_onPauseActivity);
    on<ClearError>(_onClearError);
    on<UpdateElapsedTime>(_onUpdateElapsedTime);
    on<UpdateUserLocation>(_onUpdateUserLocation);
    on<ToggleFollowUser>(_onToggleFollowUser);
    on<StopFollowingUser>(_onStopFollowingUser);

    add(const InitMap());
  }

  void _onUpdateUserLocation(UpdateUserLocation event, Emitter<MapState> emit) {
    if (state.activity != null) add(ScoreActivity(position: event.position));
    emit(state.copyWith(userLocation: event.position));
  }

  @override
  Future<void> close() async {
    await _positionStream.cancel();
    _elapsedTimer?.cancel();
    _elapsedTimer = null;
    return super.close();
  }

  Future<void> _onInitMap(InitMap event, Emitter<MapState> emit) async {
    emit(state.copyWith(isLoading: true));
    try {
      final userPosition = await _getUserLocationUseCase();
      emit(state.copyWith(userLocation: userPosition));

      final userPositionStream = await _startTrackPositionUsecase();
      _positionStream = userPositionStream
          .handleError((error) => logs.severe('error: $error'))
          .listen((position) => add(UpdateUserLocation(position: position)));

      final style = await _getMapConfigUseCase();
      emit(state.copyWith(style: style));
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
    try {
      _elapsedTimer?.cancel();

      final activity = await _beginActivityUseCase();
      _activityStartTime = activity.startedAt;
      emit(state.copyWith(activity: activity));

      final userPosition = await _getUserLocationUseCase();
      add(UpdateUserLocation(position: userPosition));

      _elapsedTimer = Timer.periodic(
        const Duration(seconds: 1),
        (_) => add(const UpdateElapsedTime()),
      );
    } catch (e) {
      emit(state.copyWith(errorMessage: AppError(e.toString())));
    }
  }

  Future<void> _onScoreActivity(
    ScoreActivity event,
    Emitter<MapState> emit,
  ) async {
    if (state.activity == null) throw ActivityNotStartedError();

    final activity = state.activity!;
    final position = event.position;
    final status =
        state.isPaused
            ? ActivityPointStatusEntity.paused
            : ActivityPointStatusEntity.active;

    try {
      final newPoint = await _scoreActivityUseCase(
        activityId: activity.id,
        position: position,
        status: status,
      );
      final newPoints = [...state.activity!.points, newPoint];
      final updatedActivity = activity.copyWith(points: newPoints);

      emit(state.copyWith(activity: updatedActivity));
    } catch (e) {
      emit(
        state.copyWith(
          errorMessage: AppError('$_onScoreActivity: ${e.toString()}'),
        ),
      );
    }
  }

  void _onPauseActivity(PauseActivity event, Emitter<MapState> emit) {
    if (state.activity == null) throw ActivityNotStartedError();
    emit(state.copyWith(isPaused: !state.isPaused));
  }

  void _onCeaseActivity(CeaseActivity event, Emitter<MapState> emit) {
    _ceaseActivityUsecase(state.activity!.id);
    _elapsedTimer?.cancel();
    _elapsedTimer = null;
    _activityStartTime = null;

    _activityNotificationUseCase.cancelActivityNotification();

    emit(
      state.copyWith(
        activity: null,
        elapsedTime: Duration.zero,
        isPaused: false,
      ),
    );
  }

  void _onClearError(ClearError event, Emitter<MapState> emit) {
    emit(state.copyWith(errorMessage: null));
  }

  void _onUpdateElapsedTime(UpdateElapsedTime event, Emitter<MapState> emit) {
    if (_activityStartTime != null && !state.isPaused) {
      final elapsed = DateTime.now().difference(_activityStartTime!);
      emit(state.copyWith(elapsedTime: elapsed));

      _activityNotificationUseCase.showActivityNotification(
        activity: state.activity!,
        elapsed: elapsed,
        isPaused: state.isPaused,
      );
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

  void _onToggleFollowUser(ToggleFollowUser event, Emitter<MapState> emit) {
    emit(state.copyWith(isFollowingUser: !state.isFollowingUser));
  }

  void _onStopFollowingUser(StopFollowingUser event, Emitter<MapState> emit) {
    emit(state.copyWith(isFollowingUser: false));
  }
}
