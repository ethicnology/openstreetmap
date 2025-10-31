import 'package:dart_mappable/dart_mappable.dart';
import 'package:furtive/core/entities/preferences_entity.dart';
import 'package:furtive/core/errors.dart';

part 'preferences_state.mapper.dart';

@MappableClass()
class PreferencesState with PreferencesStateMappable {
  final PreferencesEntity preferences;
  final bool isLoading;
  final AppError? error;

  const PreferencesState({
    required this.preferences,
    this.isLoading = false,
    this.error,
  });
}
