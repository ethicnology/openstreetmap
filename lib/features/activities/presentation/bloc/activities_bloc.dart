import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:openstreetmap/core/errors.dart';
import 'package:openstreetmap/features/activities/domain/usecases/get_activities_use_case.dart';
import 'package:openstreetmap/features/activities/presentation/bloc/activities_event.dart';
import 'package:openstreetmap/features/activities/presentation/bloc/activities_state.dart';

class ActivitiesBloc extends Bloc<ActivitiesEvent, ActivitiesState> {
  final _getActivitiesUseCase = GetActivitiesUseCase();

  ActivitiesBloc() : super(const ActivitiesState()) {
    on<FetchActivities>(_onFetchActivities);
    on<SelectActivity>(_onSelectActivity);
  }

  Future<void> _onFetchActivities(
    FetchActivities event,
    Emitter<ActivitiesState> emit,
  ) async {
    emit(state.copyWith(isLoading: true));
    try {
      final activities = await _getActivitiesUseCase();
      emit(state.copyWith(activities: activities));
    } catch (e) {
      emit(state.copyWith(errorMessage: AppError(e.toString())));
    } finally {
      emit(state.copyWith(isLoading: false));
    }
  }

  void _onSelectActivity(SelectActivity event, Emitter<ActivitiesState> emit) {
    emit(state.copyWith(selectedActivity: event.activity));
  }
}
