import 'package:openstreetmap/features/map/domain/entities/activity_entity.dart';

class ActivityModel {
  final String id;
  final String name;
  final String description;
  final List<ActivityPointModel> points;

  ActivityModel({
    required this.id,
    required this.name,
    required this.description,
    required this.points,
  });

  static ActivityModel fromEntity(ActivityEntity entity) {
    return ActivityModel(
      id: entity.id,
      name: entity.name,
      description: entity.description,
      points:
          entity.points
              .map(
                (point) => ActivityPointModel(
                  latitude: point.latitude,
                  longitude: point.longitude,
                  elevation: point.elevation,
                  time: point.time,
                ),
              )
              .toList(),
    );
  }

  static ActivityEntity toEntity(ActivityModel model) {
    return ActivityEntity(
      id: model.id,
      name: model.name,
      description: model.description,
      points:
          model.points
              .map(
                (point) => ActivityPointEntity(
                  latitude: point.latitude,
                  longitude: point.longitude,
                  elevation: point.elevation,
                  time: point.time,
                ),
              )
              .toList(),
    );
  }
}

class ActivityPointModel {
  final double latitude;
  final double longitude;
  final double elevation;
  final DateTime time;

  ActivityPointModel({
    required this.latitude,
    required this.longitude,
    required this.elevation,
    required this.time,
  });

  static ActivityPointModel fromEntity(ActivityPointEntity entity) {
    return ActivityPointModel(
      latitude: entity.latitude,
      longitude: entity.longitude,
      elevation: entity.elevation,
      time: entity.time,
    );
  }

  static ActivityPointEntity toEntity(ActivityPointModel model) {
    return ActivityPointEntity(
      latitude: model.latitude,
      longitude: model.longitude,
      elevation: model.elevation,
      time: model.time,
    );
  }
}
