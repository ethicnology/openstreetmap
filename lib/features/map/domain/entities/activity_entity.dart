import 'package:dart_mappable/dart_mappable.dart';

part 'activity_entity.mapper.dart';

@MappableClass()
class ActivityEntity with ActivityEntityMappable {
  final String id;
  final String name;
  final String description;
  final List<ActivityPointEntity> points;

  ActivityEntity({
    required this.id,
    required this.name,
    required this.description,
    required this.points,
  });
}

@MappableClass()
class ActivityPointEntity with ActivityPointEntityMappable {
  final double latitude;
  final double longitude;
  final double? elevation;
  final DateTime time;

  ActivityPointEntity({
    required this.latitude,
    required this.longitude,
    required this.elevation,
    required this.time,
  });
}
