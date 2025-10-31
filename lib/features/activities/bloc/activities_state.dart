import 'package:dart_mappable/dart_mappable.dart';
import 'package:furtive/core/errors.dart';
import 'package:furtive/core/entities/activity_entity.dart';

part 'activities_state.mapper.dart';

@MappableClass()
class ActivitiesState with ActivitiesStateMappable {
  final List<ActivityEntity> activities;
  final ActivityEntity? selectedActivity;
  final AppError? errorMessage;
  final bool isLoading;

  const ActivitiesState({
    this.activities = const [],
    this.selectedActivity,
    this.errorMessage,
    this.isLoading = false,
  });
}
