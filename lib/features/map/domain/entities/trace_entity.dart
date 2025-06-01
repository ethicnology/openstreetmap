class TraceEntity {
  final String name;
  final String description;
  final String url;
  final List<TracePointEntity> points;

  TraceEntity({
    required this.name,
    required this.description,
    required this.url,
    required this.points,
  });
}

class TracePointEntity {
  final double latitude;
  final double longitude;
  final double? elevation;
  final DateTime? time;

  TracePointEntity({
    required this.latitude,
    required this.longitude,
    required this.elevation,
    required this.time,
  });
}
