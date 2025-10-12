import 'package:latlong2/latlong.dart' show LatLng;

class PositionEntity {
  final double latitude;
  final double longitude;
  final double elevation;

  PositionEntity({
    required this.latitude,
    required this.longitude,
    required this.elevation,
  });
}

extension PositionEntityExtension on PositionEntity {
  LatLng toLatLng() => LatLng(latitude, longitude);
}
