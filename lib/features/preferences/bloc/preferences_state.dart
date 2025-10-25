import 'package:dart_mappable/dart_mappable.dart';
import 'package:openstreetmap/core/entities/preferences_entity.dart';
import 'package:openstreetmap/core/errors.dart';

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
