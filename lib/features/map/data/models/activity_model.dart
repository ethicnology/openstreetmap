import 'package:openstreetmap/core/database/tables/activity_points_table.dart';
import 'package:openstreetmap/core/entities/activity_entity.dart';
import 'package:openstreetmap/features/map/domain/entities/position_entity.dart';

class ActivityModel {
  final String id;
  final String name;
  final String description;
  final DateTime createdAt;
  final DateTime startedAt;
  final DateTime? stoppedAt;

  final List<ActivityPointModel> points;

  ActivityModel({
    required this.id,
    required this.name,
    required this.description,
    required this.points,
    required this.createdAt,
    required this.startedAt,
    required this.stoppedAt,
  });

  static ActivityModel fromEntity(ActivityEntity entity) {
    return ActivityModel(
      id: entity.id,
      name: entity.name,
      description: entity.description,
      createdAt: entity.createdAt,
      startedAt: entity.startedAt,
      stoppedAt: entity.stoppedAt,
      points:
          entity.points
              .map(
                (point) => ActivityPointModel(
                  latitude: point.position.latitude,
                  longitude: point.position.longitude,
                  elevation: point.position.elevation,
                  time: point.time,
                  status: ActivityPointsStatusColumn.fromEntity(point.status),
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
      createdAt: model.createdAt,
      startedAt: model.startedAt,
      stoppedAt: model.stoppedAt,
      points:
          model.points
              .map(
                (point) => ActivityPointEntity(
                  position: PositionEntity(
                    latitude: point.latitude,
                    longitude: point.longitude,
                    elevation: point.elevation,
                  ),
                  time: point.time,
                  status: point.status.toEntity(),
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
  final ActivityPointsStatusColumn status;

  ActivityPointModel({
    required this.latitude,
    required this.longitude,
    required this.elevation,
    required this.time,
    required this.status,
  });

  static ActivityPointModel fromEntity(ActivityPointEntity entity) {
    return ActivityPointModel(
      latitude: entity.position.latitude,
      longitude: entity.position.longitude,
      elevation: entity.position.elevation,
      time: entity.time,
      status: ActivityPointsStatusColumn.fromEntity(entity.status),
    );
  }

  static ActivityPointEntity toEntity(ActivityPointModel model) {
    return ActivityPointEntity(
      position: PositionEntity(
        latitude: model.latitude,
        longitude: model.longitude,
        elevation: model.elevation,
      ),
      time: model.time,
      status: model.status.toEntity(),
    );
  }
}
