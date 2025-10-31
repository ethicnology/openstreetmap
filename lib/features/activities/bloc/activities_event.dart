import 'package:furtive/core/entities/activity_entity.dart';

sealed class ActivitiesEvent {
  const ActivitiesEvent();
}

class FetchActivities extends ActivitiesEvent {
  const FetchActivities();
}

class SelectActivity extends ActivitiesEvent {
  const SelectActivity({required this.activity});

  final ActivityEntity activity;
}
