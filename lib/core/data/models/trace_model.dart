class TraceModel {
  final String name;
  final String description;
  final String url;
  final List<TracePointModel> points;

  TraceModel({
    required this.name,
    required this.description,
    required this.url,
    required this.points,
  });
}

class TracePointModel {
  final double latitude;
  final double longitude;
  final double? elevation;
  final DateTime? time;

  TracePointModel({
    required this.latitude,
    required this.longitude,
    required this.elevation,
    required this.time,
  });
}
