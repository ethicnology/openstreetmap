import 'package:dart_mappable/dart_mappable.dart';
import 'package:openstreetmap/features/map/domain/entities/position_entity.dart';

part 'activity_entity.mapper.dart';

@MappableClass()
class ActivityEntity with ActivityEntityMappable {
  final String id;
  final String name;
  final String description;
  final DateTime createdAt;
  final DateTime startedAt;
  final DateTime? stoppedAt;
  final List<ActivityPointEntity> points;

  ActivityEntity({
    required this.id,
    required this.name,
    required this.description,
    required this.createdAt,
    required this.startedAt,
    required this.stoppedAt,
    this.points = const [],
  });
}

enum ActivityPointStatusEntity { active, paused }

@MappableClass()
class ActivityPointEntity with ActivityPointEntityMappable {
  final PositionEntity position;
  final DateTime time;
  final ActivityPointStatusEntity status;

  ActivityPointEntity({
    required this.position,
    required this.time,
    required this.status,
  });
}
