import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:openstreetmap/core/entities/preferences_entity.dart';
import 'package:openstreetmap/core/errors.dart';
import 'package:openstreetmap/core/usecases/get_preferences_use_case.dart';
import 'package:openstreetmap/core/usecases/update_preferences_use_case.dart';
import 'package:openstreetmap/features/preferences/bloc/preferences_event.dart';
import 'package:openstreetmap/features/preferences/bloc/preferences_state.dart';

class PreferencesBloc extends Bloc<PreferencesEvent, PreferencesState> {
  final _getPreferencesUseCase = GetPreferencesUseCase();
  final _updatePreferencesUseCase = UpdatePreferencesUseCase();

  PreferencesBloc() : super(const PreferencesState()) {
    on<LoadPreferences>(_onLoadPreferences);
    on<UpdateMapTheme>(_onUpdateMapTheme);
    on<UpdateMapLanguage>(_onUpdateMapLanguage);
    on<UpdateAccuracy>(_onUpdateAccuracy);

    add(const LoadPreferences());
  }

  Future<void> _onLoadPreferences(
    LoadPreferences event,
    Emitter<PreferencesState> emit,
  ) async {
    emit(state.copyWith(isLoading: true));
    try {
      final preferences = await _getPreferencesUseCase();
      emit(state.copyWith(preferences: preferences, isLoading: false));
    } catch (e) {
      emit(
        state.copyWith(errorMessage: AppError(e.toString()), isLoading: false),
      );
    }
  }

  Future<void> _onUpdateMapTheme(
    UpdateMapTheme event,
    Emitter<PreferencesState> emit,
  ) async {
    if (state.preferences == null) return;

    final updatedPreferences = PreferencesEntity(
      mapTheme: event.theme,
      mapLanguage: state.preferences!.mapLanguage,
      accuracyInMeters: state.preferences!.accuracyInMeters,
    );

    emit(state.copyWith(preferences: updatedPreferences));
    await _updatePreferencesUseCase(updatedPreferences);
  }

  Future<void> _onUpdateMapLanguage(
    UpdateMapLanguage event,
    Emitter<PreferencesState> emit,
  ) async {
    if (state.preferences == null) return;

    final updatedPreferences = PreferencesEntity(
      mapTheme: state.preferences!.mapTheme,
      mapLanguage: event.language,
      accuracyInMeters: state.preferences!.accuracyInMeters,
    );

    emit(state.copyWith(preferences: updatedPreferences));
    await _updatePreferencesUseCase(updatedPreferences);
  }

  Future<void> _onUpdateAccuracy(
    UpdateAccuracy event,
    Emitter<PreferencesState> emit,
  ) async {
    if (state.preferences == null) return;

    final updatedPreferences = PreferencesEntity(
      mapTheme: state.preferences!.mapTheme,
      mapLanguage: state.preferences!.mapLanguage,
      accuracyInMeters: event.accuracy,
    );

    emit(state.copyWith(preferences: updatedPreferences));
    await _updatePreferencesUseCase(updatedPreferences);
  }
}
